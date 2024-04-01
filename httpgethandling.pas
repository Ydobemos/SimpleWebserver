unit HTTPGetHandling;

{$mode Delphi}

interface

uses
  Classes, SysUtils,
  //Indy 10 Stuff:
   IdContext, IdComponent, IdBaseComponent, IdCustomTCPServer, IdThreadSafe,
   IdTCPConnection, IdYarn, IdTCPServer, IdGlobal, IdURI,
  {$IFDEF FPC}
  fileutil, //für FindAllFiles
  {$ENDIF}
  //My Class for the ContentType Finder:
  MyContentTypeFinder,
  //My Singleton Class to Save all the Settings and make it available for everyone
  ServerSettingsSingleton;

type
  THTTPGetHandling = class
  public
    class procedure CheckForGetAndSendResponse(AContext: TIdContext; Text: string);
    class function CheckIfRootRequestedAndSendIndexIfTrue(AContext: TIdContext; restText:string):Boolean;
    class procedure SendFileIfExistsOrError(AContext: TIdContext; RequestedFile: string);
  end;

implementation
   uses WriteLogOutputUnit, HTTPResponseHelper;





class procedure THTTPGetHandling.CheckForGetAndSendResponse(AContext: TIdContext; Text: string);
var
  //Settings: TServerSettingsSingleton;
  //ErrorMessage: string;
  temp, RequestedFile, letzteZeichen: string;
  PeerPort: Integer;
  fromIp, fromPort: string;
  i, posi, position: integer;
  Ordner_hat_index: Boolean;
  firstLine: string;
  lineEndPos: Integer;
begin

    if pos('GET /',Text)=1 then   //wenn ein get befehl kommt:
    begin
         fromIp    := AContext.Binding.PeerIP;
         peerPort  := AContext.Binding.PeerPort;
         fromPort  := IntToStr(PeerPort);  //Direkt als string umwandeln, damit wir es später einfacher benutzen könenn

	 temp:=Text;
	 Delete(temp, 1, 5);  //Lösche 'GET /'    //in temp ist nun also (z.B.): "infos/ HTTP/1.1 ..."

         //Für uns ist aktuell nur die erste Zeile Interessant, daher nehmen wir die Zeile bis zum Zeilenumbruch.
         //Der Umbruch findet bei http IMMER mit
         //     Carriage Return (CR, ASCII 13, \r) gefolgt von Line Feed (LF, ASCII 10, \n)
         //statt. Siehe: RFC 7230   ( https://datatracker.ietf.org/doc/html/rfc7230 )
         lineEndPos := Pos(#13#10, temp);   //Ersten Umbruch finden
         if lineEndPos < 1 then
            exit; //Keinen Umbruch gefunden, dann beenden wir das hier...

         // Extrahiere die erste Zeile bis zum ersten Zeilenumbruch
         firstLine := Copy(temp, 1, lineEndPos - 1);

         ////////////////////////////////////////////////////


         if CheckIfRootRequestedAndSendIndexIfTrue(AContext, firstLine) then
            exit;

         //Wenn nicht root abgefragt wurde, dann wurde eine Datei oder Verzeichnis angefragt:
          //Man hat also sowas wie: 'GET /infos/ HTTP...
	 begin
	       //posi:= pos(' HTTP',temp); //Das erste Leerzeichen hinter der Datei/Pfad finden.
               //Das letzte Vorkommens des Leerzeichen finden. Ich habe von Firefox schon anfragen mit 'GET / undefined' bekommen. Warum auch immer...
               //Darum kann man ggf. nicht nach ' HTTP' suchen. So ist es abgesichert.
               posi := LastDelimiter(' ', firstLine);
	       RequestedFile:=Copy(firstLine, 1, posi-1);    //text2 ist nun "infos/"

	       position :=length(RequestedFile);
	       letzteZeichen := Copy(RequestedFile, position,1 );  //nun sollte das letzte zeichen in "letzteZeichen" drin sein
	       //RequestedFile:=Copy(temp, 1, posi-1);


	       //noch die pfad angaben säubern
	       //Oktettfolge
	       //if AnsiPos('%20',LowerCase(RequestedFile)) > 0 then
	       //Begin
	       //     RequestedFile:=stringreplace(RequestedFile, '%20', ' ', [rfreplaceall,rfignorecase] );
	       //end;

                                                                    //Als bsp. bekommt man sowas wie: test/S%C3%B6nkes-Datei.txt/
               RequestedFile:= THTTPResponseHelper.pfadUrlDecoding( RequestedFile );    //Jetzt wird es zu:               test/Sönkes-Datei.txt

               //Pfad-Trennzeichen auf das Betriebssystem anpassen:
               RequestedFile:=stringreplace(RequestedFile, '/', TServerSettingsSingleton.Instance.Path_delimiter_OS, [rfreplaceall,rfignorecase] );
                                                                    //Jetzt wird es zu:               test\Sönkes-Datei.txt




                 //------------------------\\
                /////    Spezialfall:    \\\\\
               //----------------------------\\

               //ToDo: gf auch überprüfen, ob ein "/" am ende sein muss. Also bei datei checken ob es das gibt,
               //      wenn nicht, dann checken, ob es den pfad/ordner gibt....

               //es wird ein verzeichnis angefordert... denn das letzte zeichen ist ein "/"
	       if pos('/',letzteZeichen) = 1 then
	       begin
               //testen ob es in dem verzeichnis eine index.html/index.htm datei gibt und diese dann aufrufen...

		      Ordner_hat_index:=false;     //erstmal von ausgehen, dass wir kein index haben...

		      if fileexists(TServerSettingsSingleton.Instance.WorkingDirectoryPath+RequestedFile+'index.htm') then
		      begin
		           RequestedFile:=RequestedFile+'index.htm';         //pfad+index speichern
			   Ordner_hat_index := true;
		      end;

		      if fileexists(TServerSettingsSingleton.Instance.WorkingDirectoryPath+RequestedFile+'index.html') then
		      begin
		           RequestedFile:=RequestedFile+'index.html';                    //and (not fileexists(WorkingDirectoryEdit.text+RequestedFile+'index.htm')) then
			   Ordner_hat_index := true;    //index erkannt und genommen verzeichnis abarbeitung wird dann übersprungen...
		      end;


		      //ok index.htm/L existiert nicht, also normal weitermachen...
		      if Ordner_hat_index = false then  //ordner hat kein index.... also mache normal weiter...           //(not fileexists(WorkingDirectoryEdit.text+RequestedFile')) then     ///folgendes ist unnötig, da ja in requested schon der pfad + index drin ist....///// and (not fileexists(Edit2.text+RequestedFile+'index.htm')) then
		      begin

		           if not TServerSettingsSingleton.Instance.SendFtpLikeViewOnEmptyDir then
			   begin
			        THTTPResponseHelper.SendErrorPage(RequestedFile, AContext);   //ordner wurde nicht gefunden, bzw darf nicht gefunden werden ;)
			        exit;//ende, da eine erneute error page nicht gesendet werden muss...
		           end;

			   if TServerSettingsSingleton.Instance.SendFtpLikeViewOnEmptyDir then
			   begin
			        THTTPResponseHelper.sendeVerzeichnis(TServerSettingsSingleton.Instance.WorkingDirectoryPath+RequestedFile, AContext);  //gibt verzeichniss
			        exit; //und raus hier, da sonst evtl noch eine error-page mit kommt ;D
			   end;
	              end;


	       end;  //End zu: if pos('/',text2) = 1 then     //es wird ein verzeichnis angefordert...      //denn letzte zeichen ist ein "/"



		  // posi:= pos(' ',temp);
		  // RequestedFile:=Copy(temp, 1, posi-1);

                   (*
		  //Oktettfolge
		  if AnsiPos('%20',LowerCase(RequestedFile)) > 0 then
		  Begin
			  RequestedFile:=stringreplace(RequestedFile, '%20', ' ', [rfreplaceall,rfignorecase] );
		  end;
                 *)
	 end;  //ende zu:  else	//Kein Leerzeichen hinter 'GET /'? //Dann steht dort eine Datei oder Verzeichnis!



         THTTPGetHandling.SendFileIfExistsOrError(AContext, RequestedFile);

    end;  //ende des get befehls

end;








class function THTTPGetHandling.CheckIfRootRequestedAndSendIndexIfTrue(AContext: TIdContext; restText:string):Boolean;
var
  RequestedFile: string;
begin
     result := false;

     //if pos(' HTTP',restText)=1 then  //== "GET / HTTP/1.1" oder so ähnlich  //Leerzeichen hinter /  -> root aufruf
     //Das letzte Vorkommens des Leerzeichen finden. Ich habe von Firefox schon anfragen mit 'GET / undefined' bekommen. Warum auch immer...
     //Darum kann man ggf. nicht nach ' HTTP' suchen. Durch folgendes wird es sicher:
     //Es wird nun geschaut, ob das letzte Leerzeichen an Position 1 steht
     //Vorher wurde bereits 'GET /' gelöscht und auch alles ab dem ersten Umbruch wurde entfernt.
     //Kommt nun das letzte Leerzeichen, dann kommt danach nur noch "HTTP/1.1" oder ähnliches.
     //Somit ist es root:
     if LastDelimiter(' ', restText) = 1 then
     begin
          result := true;

	  //Priorisierung: Erst html dann htm senden (Darum zuletzt html überprüfen, damit es das letzte und somit erste gewählte ist)
	  if fileexists(TServerSettingsSingleton.Instance.WorkingDirectoryPath+'index.htm') then
          begin
	     RequestedFile:='index.htm';
             WriteLogOutput.WriteOutput('#### index.htm gefunden');
             THTTPGetHandling.SendFileIfExistsOrError(AContext, RequestedFile);
          end;

	  if fileexists(TServerSettingsSingleton.Instance.WorkingDirectoryPath+'index.html') then
          begin
	     RequestedFile:='index.html';
             THTTPGetHandling.SendFileIfExistsOrError(AContext, RequestedFile);
          end;


          //Es wurde zwar Root angefordert, aber es gibt keine Index Datei zum Senden?
          //Dann eine Fehlermeldung geben:
	  if (not fileexists(TServerSettingsSingleton.Instance.WorkingDirectoryPath+'index.html')) and (not fileexists(TServerSettingsSingleton.Instance.WorkingDirectoryPath+'index.htm')) then
	  begin
             //index.html im root verzeichnis nicht gefunden...

             //Überprüfen, ob die FTP ähnliche Ansicht übermittelt werden soll:
              if TServerSettingsSingleton.Instance.SendFtpLikeViewOnEmptyDir then
	      begin
		  THTTPResponseHelper.sendeVerzeichnis(TServerSettingsSingleton.Instance.WorkingDirectoryPath, AContext);  //gibt Root-Verzeichniss zurück
		  exit;
	      end
              else   //Der RadioCheck sitzt beim "Error 404 Ausgeben", daher Fehlermeldung ausgeben:
              begin
	         if TServerSettingsSingleton.Instance.SendFtpLikeViewOnEmptyDir then
	         begin
		    THTTPResponseHelper.sendeVerzeichnis(TServerSettingsSingleton.Instance.WorkingDirectoryPath, AContext);
		    exit;
	         end
                 else
                 begin
		    THTTPResponseHelper.SendErrorPage('index.html', AContext);   //index.html im root verzeichnis nicht gefunden...
		    exit;
                 end;
              end;
          end;

     end;
end;



class procedure THTTPGetHandling.SendFileIfExistsOrError(AContext: TIdContext; RequestedFile: string);
var   FileStream : TFileStream;
  DatumUndZeit, strForMemo, httpHeaderForSendingFile: string;
  laenge: NativeUInt;
  PeerPort: Integer;
  fromIp, fromPort: string;
begin
   DatumUndZeit:=THTTPResponseHelper.DatumUndZeitFuerHttpHeader;
   fromIp    := AContext.Binding.PeerIP;
   peerPort  := AContext.Binding.PeerPort;
   fromPort  := IntToStr(PeerPort);  //Direkt als string umwandeln, damit wir es später einfacher benutzen könenn

 	 if fileexists(TServerSettingsSingleton.Instance.WorkingDirectoryPath+RequestedFile) then
	 begin  //angeforderte datei existiert, also senden ^^

	        FileStream := TFileStream.Create(TServerSettingsSingleton.Instance.WorkingDirectoryPath+RequestedFile, fmOpenRead or fmShareDenyNone );    //readonly status reicht aus ^^

		laenge:=FileStream.Size;

		//create and send http header for file:
                {
		httpHeaderForSendingFile:= 'HTTP/1.0 200 OK'+#13+#10+
		          'Date: '+DatumUndZeit+' GMT'+#13+#10+
			  'Server: Soenkes Simple Webserver '+TServerSettingsSingleton.Instance.ProgramVersion+#13+#10+
			  //'Last-Modified: Thu, 22 Apr 2021 16:37:24 GMT'+#13+#10+
			  'Content-Length: '+inttostr(laenge) +#13+#10+
			  'Connection: close' +#13+#10+
			  //'Content-Type: text/html' +
			  'Content-Type: '+ ContentTypeFinder.WhatContenttype(RequestedFile) +
			  #13+#10+ #13+#10;
                }
                httpHeaderForSendingFile := THTTPResponseHelper.createHttpHeader('200 OK',
                                                                                  laenge,
                                                                                  ContentTypeFinder.WhatContenttype(RequestedFile));


                try
                   try
                         AContext.Connection.IOHandler.Write(httpHeaderForSendingFile);
                         AContext.Connection.IOHandler.LargeStream := True;
                         AContext.Connection.IOHandler.Write(FileStream);
                   except
                         on e: Exception do
                         Begin
                              strForMemo := DatetoStr(now) + ' - ' + Timetostr(now)+' Verbindung mit: IP '+ fromIp + ' und Port: '+ fromPort + #13+#10;
                              strForMemo := strForMemo + 'Möglicher Verbindungsabbruch des Clienten/Browsers. Z.B. Abbruch eines Downloads...' +#13+#10;
                              strForMemo := strForMemo + 'Ansonsten ist irgendetwas schief gegangen bei:' +#13+#10;
                              strForMemo := strForMemo + TServerSettingsSingleton.Instance.WorkingDirectoryPath+RequestedFile +#13+#10;
                              strForMemo := strForMemo + 'Fehlermeldung: '+ e.Message + #13+#10;
                              strForMemo := strForMemo +  '---------------------------------------------------------------------------------'+#13+#10+#13+#10 ;
                              WriteLogOutput.WriteOutput(strForMemo);
                         End;
                   end;
                finally
                         // AContext.Connection.IOHandler.WriteBufferClose;
                         AContext.Connection.IOHandler.Close;
                end;

                strForMemo := DatetoStr(now) + ' - ' + Timetostr(now)+' Verbindung mit: IP '+ fromIp + ' und Port: '+ fromPort + #13+#10;
                strForMemo := strForMemo + 'Folgende Datei gesendet:' +#13+#10;
                strForMemo :=  strForMemo + TServerSettingsSingleton.Instance.WorkingDirectoryPath+RequestedFile +#13+#10;
                strForMemo :=  strForMemo +  '---------------------------------------------------------------------------------'+#13+#10 +#13+#10;
                WriteLogOutput.WriteOutput(strForMemo);

	 end
	 else     //File existiert nicht => also sende error!
	 begin
	        THTTPResponseHelper.SendErrorPage(RequestedFile, AContext);
	 end;
end;





end.

