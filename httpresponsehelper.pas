unit HTTPResponseHelper;

//Achtung: Ich mache hier Class Functions, damit man diese Klasse
//ohne Instanzierung aufrufen kann! Also keine Instanzierung/Objekt-Erstellung nötig!

{$mode Delphi}

interface

uses
  Classes, SysUtils,
  //Indy 10 Stuff:
   IdContext, IdComponent, IdBaseComponent, IdCustomTCPServer, IdThreadSafe,
   IdTCPConnection, IdYarn, IdTCPServer, IdGlobal, IdURI,
  {$IFDEF FPC}
  fileutil, //für FindAllFiles
  LazSysUtils, //Für NowUTC in Lazarus
  {$ENDIF}
  //Für NowUTC in Delphi:
  DateUtils,
    //My Class for the ContentType Finder:
  MyContentTypeFinder,
  //My Singleton Class to Save all the Settings and make it available for everyone
  ServerSettingsSingleton;

type
  THTTPResponseHelper = class
  public
    //class procedure SendErrorPage(AContext: TIdContext; const RequestedFile: string);
    //class procedure SendDirectoryListing(AContext: TIdContext; const Path: string);

    class procedure sendeVerzeichnis (Path: string; AContext: TIdContext);
    class procedure SendErrorPage(RequestedFile:String; AContext: TIdContext);

    class function pfadUrlEncoding (Path: string):String;
    class function pfadUrlDecoding (Path: string):String;
    class procedure ListFileDir(Path: string; FileList: TStrings);
    class function DatumUndZeitFuerHttpHeader:String;
    class function createHttpHeader (status: string; contentLength:NativeUInt; contentType: string):String;
  end;

implementation
   uses WriteLogOutputUnit;

 {
class procedure THTTPResponseHelper.CheckForGetAndSendResponse(AContext: TIdContext; const RequestedFile: string);
var
  Settings: TServerSettingsSingleton;
  ErrorMessage: string;
begin



  Settings := TServerSettingsSingleton.Instance;
  ErrorMessage := '<html><head><title>404 Not Found</title></head><body><h1>Not Found</h1><p>The requested URL was not found on this server.</p></body></html>';
  AContext.Connection.IOHandler.Write(Format('HTTP/1.1 404 Not Found'#13#10'Content-Type: text/html'#13#10'Content-Length: %d'#13#10#13#10'%s', [Length(ErrorMessage), ErrorMessage]));


end;
     }



{
 Erstellt den Http Header.
 Input:
       status: Der Status der Antwort. Bsp.: '200 OK' oder '404 Not Found'
       contentLength: Länge der Datei, die gesendet werden soll.
       contentType: Der Content-Type der Datei, die gesendet werden soll. Bsp.: 'text/html'
}
class function THTTPResponseHelper.createHttpHeader (status: string; contentLength:NativeUInt; contentType: string):String;
var DatumUndZeit : String;
begin
  DatumUndZeit:=THTTPResponseHelper.DatumUndZeitFuerHttpHeader;
  result := 'HTTP/1.0 ' + status + #13+#10+
            'Date: ' + DatumUndZeit + ' GMT' + #13+#10+
            'Server: Soenkes Simple Webserver ' + TServerSettingsSingleton.Instance.ProgramVersion + #13+#10+
            //'Last-Modified: Thu, 22 Jan 2008 16:37:24 GMT'+#13+#10+
            'Content-Length: ' + inttostr(contentLength) +#13+#10+
            'Connection: close' + #13+#10+
            //'Content-Type: text/html' +
            'Content-Type: ' + contentType + #13+#10+
            #13+#10;
end;




{
Wenn Du weder Verzeichnisse noch System- noch versteckte Dateien listen möchtest, musst Du die Attribute entweder einzeln nacheinander oder mit einer passenden Bitmaske abfragen.
if ((SR.Attr and faDirectory) = 0) and ((SR.Attr and faHidden) = 0) and ((SR.Attr and faSysFile) = 0) then oder
if (SR.Attr and (faDirectory or faHidden or faSysFile)) = 0 then Falls Dir das unklar ist, schau doch mal in mein Tutorial
//Siehe: https://www.delphipraxis.net/139926-dateien-eines-verzeichnis-auflisten.html
}

class procedure THTTPResponseHelper.sendeVerzeichnis (Path: string; AContext: TIdContext);
var   i, laenge, temppfadInt, peerPort:Integer;
      httpHeader,text,temppfad, temppfad_encoded, strForMemo, fromIp:String;
      liste, fileList: TStringList;
begin
        fromIp    := AContext.Binding.PeerIP;
        peerPort  := AContext.Binding.PeerPort;

	temppfadInt:=length(path)-length(TServerSettingsSingleton.Instance.WorkingDirectoryPath);

	if temppfadint=0 then
	begin
	     temppfad:='Root';
	end
	else
	begin
	     temppfad:=Path;

             //anfang löschen, so dass nur der bzw die Unterordner da steht
             Delete(temppfad, 1, length(TServerSettingsSingleton.Instance.WorkingDirectoryPath));

             //Path Delimiter für den Browser wieder umdrehen, falls es vorher für das OS (Windows) angepasst wurde:
             if AnsiPos('\',LowerCase(temppfad)) > 0 then
             Begin
	          temppfad:=stringreplace(temppfad, '\', '/', [rfreplaceall,rfignorecase] );
             end;

        end;
        //temppfad_normalStr := temppfad;   //Wir behalten das original, um es im memo schön darstellen zu können!
        //showmessage(temppfad_normalStr);
        //temppfad := pfadUrlDecoding(temppfad);  //Den temppfad werden wir aber umwandeln, falls sonderzeichen o.ä sind, damit sie imbrowser dargestellt werden können.
        //showmessage(Path);
        //Path := pfadUrlDecoding(Path);
        //showmessage(Path);
        temppfad_encoded := pfadUrlEncoding( temppfad );

	//DatumUndZeit:=THTTPResponseHelper.DatumUndZeitFuerHttpHeader; //FormatDateTime('dddd, d. mmmm yyyy hh:nn', Now);
	liste := TStringList.Create;
        fileList := TStringList.Create;

        fileList.Clear;
        ListFileDir(Path, fileList);
        fileList.Sorted := True;

	Liste.clear;
	Liste.Add('<!DOCTYPE html><html><head>'+
                  '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />' +
                  '<title>Index of '+temppfad+'</title></head><body>'+
		  '<h1>Index of '+temppfad+'</h1>');
	//Liste.add('Parent Directory  ...... eher nicht zu umständlich xD
	Liste.Add('<BR><pre>');


        if temppfadint=0 then
        begin       //root index:
             for i:=0 to fileList.Count-1 do
             begin
                  text := fileList[i];
                  Liste.add('<a href="/'+ pfadUrlEncoding(text) +'">'+text+'</a>');
             end;
        end
        else       //kein root index, also pfad noch angeben um dateien auch öffnen zu können:
        begin
             for i:=0 to fileList.Count-1 do
             begin
                  text := fileList[i];
                  Liste.add('<a href="/'+temppfad_encoded + pfadUrlEncoding(text) +'">'+text+'</a>');
             end;
        end;


        Liste.Add('</pre><hr>'+
                  '<address>Simple Webserver '+TServerSettingsSingleton.Instance.ProgramVersion+' programmed by <a href="https://www.soenke-berlin.de">S&ouml;nke Schmidt</a></address>'+ //Das ö bei Sönke durch &ouml; ersetzen
                  '</html>');


        laenge:= 0;
        //for i:=0 to Liste.count-1 do
        //begin
        //     laenge:=laenge+length(Liste[i]);
        //end;
        //in laenge ist nun die länge ^^

        //Die Länge ist nicht gleich, darum mit for i:=0 to Liste.count-1 do
        //anstatt length(Liste.text)
        //showmessage('for i='+ IntToStr(laenge) + 'count: '+IntToStr(length(Liste.text)) );
        //Unterschiedliche länge, weil die Umbrüche (\r\n) in der For-Schleife nicht mitgezählt werden,
        //sind aber wichtig mit zu zählen! Darum nicht pro Zeile auslesen, sondern die gesamte Textlänge,
        //da ja auch der gesamte Text gesendet wird!
        laenge := length(Liste.text);

        httpHeader := THTTPResponseHelper.createHttpHeader('200 OK', laenge, 'text/html');

        try
           AContext.Connection.IOHandler.Write(httpHeader + Liste.text);
        finally
           AContext.Connection.IOHandler.Close;
        end;

        strForMemo := DatetoStr(now) + ' - ' + Timetostr(now)+' Verbindung mit: IP '+ fromIp + ' und Port: '+ IntToStr(PeerPort) + #13+#10;
        strForMemo := strForMemo +' Folgendes Unterverzeichnis wurde in FTP Ansicht übertragen:' +#13+#10;
        strForMemo :=  strForMemo + temppfad +#13+#10;
        strForMemo :=  strForMemo +  '---------------------------------------------------------------------------------'+#13+#10 + #13+#10;
        WriteLogOutput.WriteOutput(strForMemo);

        fileList.Free;
        Liste.Free;
end;



class procedure THTTPResponseHelper.SendErrorPage(RequestedFile:String; AContext: TIdContext);
var sendError, sendErrPage, httpHeader, strForMemo, fromIp :String;
    peerPort :Integer;
    laenge: NativeUInt;
    FileStream :TFileStream;
begin
  fromIp    := AContext.Binding.PeerIP;
  peerPort  := AContext.Binding.PeerPort;

  if not TServerSettingsSingleton.Instance.SendIndividualErrorPage then
  begin
    sendErrPage :=   '<!DOCTYPE html><html> <head> ' +
                     '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'+
                     '<title>ERROR 404 - Seite nicht gefunden</title></head>'+
                     '<p>ERROR 404 - Seite nicht gefunden! </p>'+                //<br><br><br><br><br>'+  //+#13+#10+
                     '<div style="position:absolute; bottom:0px;left:17px; width: 95%;"><hr>'+
                     '<address>Simple Webserver '+TServerSettingsSingleton.Instance.ProgramVersion+' programmed by <a href="https://www.soenke-berlin.de">S&ouml;nke Schmidt</a></address>'+ //Das ö bei Sönke durch &ouml; ersetzen
                     '</div></html>';

    httpHeader := THTTPResponseHelper.createHttpHeader('404 Not Found', length(sendErrPage), 'text/html');
    sendError:= httpHeader + sendErrPage;


    try
        //AContext.Connection.IOHandler.DefStringEncoding := IndyTextEncoding_UTF8;  //Ich habe es direkt bei IdTCPServerExecute eingefügt, damit es für alle immer gilt!
        AContext.Connection.IOHandler.Write(sendError);
       //Alternativ geht auch in einem Schritt:
       //AContext.Connection.IOHandler.Write(sendError, IndyTextEncoding_UTF8 );
       //Möglichkeiten für verschiedene Codierungstypen habe ich hier gesehen: https://www.delphipraxis.net/176954-tidtextencoding-fehler.html
       //Für uns ist aber utf8 interessant...
    finally
       AContext.Connection.IOHandler.Close;
    end;

    strForMemo := DatetoStr(now) + ' - ' + Timetostr(now)+' Verbindung mit: IP '+ fromIp + ' und Port: '+ IntToStr(PeerPort) + #13+#10;
    strForMemo :=  strForMemo +'Folgende Datei wurde nicht gefunden:' +#13+#10;
    strForMemo :=  strForMemo + TServerSettingsSingleton.Instance.WorkingDirectoryPath + RequestedFile +#13+#10;
    strForMemo :=  strForMemo + 'Standard Error 404 wurde gesendet.' +#13+#10;
    strForMemo :=  strForMemo +  '---------------------------------------------------------------------------------'+#13+#10 + #13+#10;
    WriteLogOutput.WriteOutput(strForMemo);
  end;



  if TServerSettingsSingleton.Instance.SendIndividualErrorPage then
  begin

    FileStream := TFileStream.Create(TServerSettingsSingleton.Instance.IndividualErrorPagePath, fmOpenRead or fmShareDenyNone );    //readonly status reicht aus ^^

    laenge:=FileStream.Size;

    httpHeader := THTTPResponseHelper.createHttpHeader('404 Not Found',
                                                       laenge,
                                                       ContentTypeFinder.WhatContenttype(TServerSettingsSingleton.Instance.IndividualErrorPagePath));

    try
       AContext.Connection.IOHandler.LargeStream := True;
       AContext.Connection.IOHandler.Write(httpHeader);
       AContext.Connection.IOHandler.Write(FileStream);
       // AContext.Connection.IOHandler.Write(FileStream, LongInt(laenge));

       // AContext.Connection.IOHandler.WriteBufferFlush;
    finally
       // AContext.Connection.IOHandler.WriteBufferClose;
       AContext.Connection.IOHandler.Close;
    end;


    strForMemo := DatetoStr(now) + ' - ' + Timetostr(now)+' Verbindung mit: IP ' + fromIp + ' und Port: ' + IntToStr(PeerPort) + #13+#10;
    strForMemo :=  strForMemo +'Folgende Datei wurde nicht gefunden:' +#13+#10;
    strForMemo :=  strForMemo + TServerSettingsSingleton.Instance.WorkingDirectoryPath + RequestedFile +#13+#10;
    strForMemo :=  strForMemo + '"'+TServerSettingsSingleton.Instance.IndividualErrorPagePath + '"' + ' wurde als Error 404 gesendet' +#13+#10;
    strForMemo :=  strForMemo +  '---------------------------------------------------------------------------------'+#13+#10 + #13+#10;
    WriteLogOutput.WriteOutput(strForMemo);

 end;

end;



class function THTTPResponseHelper.pfadUrlEncoding (Path: string):String;
var ret : String;
begin
     ret:= Path;
     if AnsiPos('%20',LowerCase(Path)) > 0 then
     Begin
          ret :=stringreplace(Path, '%20', ' ', [rfreplaceall,rfignorecase] );
     end;
     //showmessage('1: '+ret);
     //ret := TIdURI.URLEncode(ret);   //überprüft eine url und geht darum so nicht. Man könnte stattdessen aber sagen wir haben
                                       //nur einen parameter, was ja so in etwa stimmt... URLEncode ruft intern das auch für Parameter auf
     ret :=TIdURI.ParamsEncode(ret);   //Für unsere Zwecke also passend.
     //showmessage('2: '+ret);
     result := ret;
end;

//Something like this would have also worked:
//See: https://stackoverflow.com/questions/776302/standard-url-encode-function
//function MyEncodeUrl(source:string):string;
// var i:integer;
// begin
//   result := '';
//   for i := 1 to length(source) do
//       if not (source[i] in ['A'..'Z','a'..'z','0','1'..'9','-','_','~','.']) then result := result + '%'+inttohex(ord(source[i]),2) else result := result + source[i];
// end;
//It may have problems with unicode / UTF-8 Strings... So we better use the inbuild indy thing...



class function THTTPResponseHelper.pfadUrlDecoding (Path: string):String;
var ret : String;
begin
     ret:= Path;
     ret := TIdURI.URLDecode(ret);   //Das Decoding überprüft keine url und decodiert einfach den ganzen string so um, wie es sein soll.
     result := ret;
end;



//sr.attr and faHidden <> 0 für alle NICHT verstecken Dateien
//sr.attr and faSysFile <> 0 für alle NICHT Systemdateien
//if (SR.Attr <> faDirectory) then    //ggf ändern zu: //if (SR.Attr and faDirectory) = 0
class procedure THTTPResponseHelper.ListFileDir(Path: string; FileList: TStrings);
var
   {$IFDEF FPC}
     text : String;
     i : Integer;
   {$ELSE}
     SR: TSearchRec;
   {$ENDIF}
begin
  {$IFDEF FPC}
    FindAllFiles(FileList, Path, '*.*', false);    //See: https://wiki.freepascal.org/FindAllFiles
    //Da kompletter Pfad noch mit angegeben wird (wir diesen aber nicht brauchen), entfernen wir diesen:
    for i:=0 to FileList.Count-1 do
    begin
        text := FileList[i];
        Delete(text, 1, length(Path));  //löschen des pfades
        FileList[i] := text;
    end;

  {$ELSE}      //In delphi machen wir das etwas anders:
  if FindFirst(Path + '*.*', faAnyFile, SR) = 0 then
  begin
    repeat
      if (SR.Attr <> faDirectory) then
      begin
        FileList.Add(SR.Name);
      end;
    until FindNext(SR) <> 0;
    //FindClose(SR);                        //Diese Funktion gibt es doppelt. Vorsicht! Damit er hier die richtige Funktion nimmt, müssen oben bei der Einbindung bei uses die Reihenfolge:  Windows,  Messages, SysUtils, sein. Ansonsten nimmt er die andere Funktion und sagt dann, es sind inkompatible typen!!!
                                            //Ist Windows nicht for SysUtils bei uses, kommt der Fehler: E2010 Inkompatible Typen: 'NativeUInt' und 'TSearchRec'
    SysUtils.FindClose(SR);                 //So ist es eindeutig und nicht mehr problematisch!
  end;
  {$ENDIF}



end;



//Wir müssen sicherstellen, dass das Datum auf englisch eingestellt ist
//und dementsprechend auf englisch Formatiert ist.
//Zudem muss die Zeit in GMT sein, also nicht GMT+1 oder sonst was.
//Das bekommen wir mit NowUTC hin. NowUTC benötigt bei den uses dann noch LazSysUtils.
//Fürs Datum Format siehe:
//Siehe: https://datatracker.ietf.org/doc/html/rfc7231#section-7.1.1.2
//und: https://datatracker.ietf.org/doc/html/rfc7231#section-7.1.1.1
class function THTTPResponseHelper.DatumUndZeitFuerHttpHeader:String;
var
  FS: TFormatSettings;
begin
  FS := DefaultFormatSettings; // Kopiere die Standard-FormatSettings
  //FS.ShortMonthNames := ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  //                       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  //FS.ShortDayNames := ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  //Direkte Zuweisung für jedes Element da das vorherige leider nicht geht...
  FS.ShortMonthNames[1] := 'Jan';
  FS.ShortMonthNames[2] := 'Feb';
  FS.ShortMonthNames[3] := 'Mar';
  FS.ShortMonthNames[4] := 'Apr';
  FS.ShortMonthNames[5] := 'May';
  FS.ShortMonthNames[6] := 'Jun';
  FS.ShortMonthNames[7] := 'Jul';
  FS.ShortMonthNames[8] := 'Aug';
  FS.ShortMonthNames[9] := 'Sep';
  FS.ShortMonthNames[10] := 'Oct';
  FS.ShortMonthNames[11] := 'Nov';
  FS.ShortMonthNames[12] := 'Dec';

  FS.ShortDayNames[1] := 'Sun';
  FS.ShortDayNames[2] := 'Mon';
  FS.ShortDayNames[3] := 'Tue';
  FS.ShortDayNames[4] := 'Wed';
  FS.ShortDayNames[5] := 'Thu';
  FS.ShortDayNames[6] := 'Fri';
  FS.ShortDayNames[7] := 'Sat';

  result := FormatDateTime('ddd, dd mmm yyyy HH:NN:SS', NowUTC, FS);  //FormatDateTime('dddd, d. mmmm yyyy hh:nn', Now);
end;



end.

