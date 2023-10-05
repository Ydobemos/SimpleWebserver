unit Unit1;

{$IFDEF FPC}
//{$mode objfpc}{$H+}
{$mode delphi} {$H+}
{$ENDIF}

interface

uses
  {$IFNDEF UNIX}    //Wenn nicht Unix / Linux, dann ist es Windows und wir binden Windows ein!
  Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Forms, Controls, Graphics, Dialogs, ComCtrls, Menus,
  StdCtrls, ExtCtrls, FileCtrl,
  {$IFDEF FPC}
  fileutil, //für FindAllFiles
  {$ENDIF}
  //Indy 10 Stuff:
   IdContext, IdComponent, IdBaseComponent, IdCustomTCPServer, IdThreadSafe,
   IdTCPConnection, IdYarn, IdTCPServer, IdGlobal, IdURI,
  //Unsere Klasse für den ContentType Finder:
  MyContentTypeFinder;
   //Crt;

 {$IFNDEF FPC}
 const WM_TASKBAREVENT = WM_USER+1;
 {$ENDIF}

//ggf: ScktComp,  FileCtrl, Menus;

type

  {$IFDEF FPC}
  //See: https://wiki.freepascal.org/Asynchronous_Calls
   TLogMsgData = record // record can hold much more then a simple string :-)
    Text: string;
  end;
  PLogMsgData = ^TLogMsgData;
 {$ENDIF}


  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    MainMenu1: TMainMenu;
    Datei1: TMenuItem;
    Memo1: TMemo;
    Programm: TMenuItem;
    Beenden2: TMenuItem;
    N1: TMenuItem;
    OpenDialog1: TOpenDialog;
    PopupMenu1: TPopupMenu;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    StatusBar1: TStatusBar;
    Systray: TMenuItem;
    Beenden: TMenuItem;
    Info1: TMenuItem;
    Hilfe1: TMenuItem;
    Timer1: TTimer;
    Update1: TMenuItem;
    Info2: TMenuItem;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure Beenden2Click(Sender: TObject);
    procedure BeendenClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Hilfe1Click(Sender: TObject);
    procedure Info2Click(Sender: TObject);
    procedure ProgrammClick(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure SystrayClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    //////My callback functions
    procedure IdTCPServerDisconnect(AContext: TIdContext);
    procedure IdTCPServerExecute(AContext: TIdContext);
    procedure IdTCPServerStatus(ASender: TObject; const AStatus: TIdStatus;
                                    const AStatusText: string);
    procedure DisplayOnMemo(str : String);
    procedure Update1Click(Sender: TObject);
    procedure SendErrorPage(RequestedFile:String; AContext: TIdContext);
    procedure sendeVerzeichnis (Path: string; AContext: TIdContext);
    procedure ListFileDir(Path: string; FileList: TStrings);
    function pfadUrlEncoding (Path: string):String;
    function pfadUrlDecoding (Path: string):String;
  private
        {$IFDEF FPC}
        procedure WriteToMemo(const AMsg: string);
        {$ENDIF}
  public
        {$IFDEF FPC}
         procedure WriteAsyncQueue(Data: PtrInt);
         {$ENDIF}

         {$IFNDEF FPC}
         procedure WMTASKBAREVENT(var message: TMessage); message WM_TASKBAREVENT;
	 {$ENDIF}

  end;

var
  Form1: TForm1;
  IdTCPServer : TIdTCPServer;
  Version : String = '1.71';
  Path_delimiter_OS : String;

implementation


//uses shellapi nur für das SysTray, darum nur für Delphi einbinden, da nur dort das Systray implementiert ist!
  uses
         {$IFNDEF FPC}
          shellapi,
          {$ENDIF}
        Unit2;




  {$IFDEF FPC}
        {$R *.lfm}
  {$ELSE}
       {$R *.dfm}
  {$ENDIF}






{ TForm1 }

procedure TForm1.BeendenClick(Sender: TObject);
begin
 close;
end;




/////// Start - Button \\\\\\\
procedure TForm1.Button1Click(Sender: TObject);
var position:Integer;
    text:String;
begin
  Button2.Enabled := True; //Stop-Button aktivierbar machen

  if edit2.text='' then
  begin
    showmessage('Bitte wählen Sie das Arbeitsverzeichnis aus, in dem sich die Dateien befinden, die der Webserver verwenden soll');
    exit;
  end;

  if not DirectoryExists(edit2.text) then
  begin
    Showmessage('Das Arbeitsverzeichnis existiert garnicht ...'+#13+#10+'Bitte geben Sie ein korrektes Arbeitsverzeichnis an!');
    exit;
  end;



  //Checken ob eigene definierte 404 (html) Seite verwendet wird:
  if RadioButton2.checked=true then
  begin
    if (edit3.text='') then
    begin
      showmessage('Bitte geben Sie auch eine Fehlerseite an oder wählen Sie "Standard Error 404 Seite senden" aus.');
      exit;
    end;

    if not fileexists(Edit3.text) then
    begin
      Showmessage('Ihre Fehlerseite existiert nicht, bitte geben Sie eine existierende Fehlerseite an!');
      exit;
    end;

  end;


  /////überprüfen ob letztes zeichen ein '/' ist
  position :=length(edit2.Text);
  text := edit2.Text;
  text := Copy(text, position,1 ); //von der vorletzten position einen Char kopieren

  //if not pos(Path_delimiter_OS,text) = 1 then     //so geht das nicht...
  if pos(Path_delimiter_OS,text) <> 1 then          //Bei 1 hätte er ein "\" am Ende gefunden! Da er es nicht gefunden hat, ergänzen wir es!
  begin
    edit2.Text := Edit2.Text+Path_delimiter_OS;       //ein "\" ergänzen um Pfad richtig zu öffnen
  end;



  {
  if not pos('\',text) = 1 then
  begin
    edit2.Text := Edit2.Text+'\';       //ein "\" ergänzen um Pfad richtig zu öffnen
  end;
   }



////////////////
  // clearing the bindings property (socket handles )
  IdTCPServer.Bindings.Clear;

  try
    // Port hinzufügen:
    IdTCPServer.Bindings.Add.Port := strtoint(edit1.Text);
  except
    showmessage('Bitte einen gültigen Port eintragen!');
    exit;
  end;


  try
    // MaxConnections hinzufügen:
    IdTCPServer.MaxConnections  := strtoint(edit4.Text);
  except
    showmessage('Bitte eine gültige Anzahl an maximalen Verbindungen eintragen!');
    exit;
  end;



   //Arbeitsverzeichnis und Port während des Starts kann nicht mehr geändert werden!
   Edit2.Enabled := False;
   Button5.Enabled := False;
   Edit1.Enabled := False;
   Button1.Enabled := False;
   Edit4.Enabled := False;

   //Ein aktives binding auf IPv4 ist gerade nicht nötig. Kann man aber mal im Hinterkopf behalten:
   //IdTCPServer.Bindings.Items[0].IPVersion := Id_IPv4 ;

   try
      IdTCPServer.Active   := True;    //Server ist nun aktiv!
   except
      on e: Exception do
      Begin
          showmessage('Fehler beim Starten des Servers! ' +#13+#10+
                      'Ist der Port schon in Benutzung? Ein höherer Port, der keine speziellen Recht braucht und nicht bereits benutzt wird, könnte das Problem beheben!'  +#13+#10+
                      'Probieren Sie mal Port 8080 oder Port 8083 aus.'  +#13+#10 +#13+#10+
                      'Ansonsten lautet die Fehlermeldung: ' +#13+#10+
                      e.Message );
          Button2.Click;  //Den "Stop" Button drücken und somit alles wieder zurücksetzen!
      end;

   end;




end;

procedure TForm1.Button2Click(Sender: TObject);
begin
   IdTCPServer.Active := False;  //Server wird gestoppt
   //Arbeitsverzeichnis und Port wieder aktivieren, damit sie geändert werden können
   Edit2.Enabled := True;
   Button5.Enabled := True;
   Edit1.Enabled := True;
   Button1.Enabled := True;
   Button2.Enabled := False;
   Edit4.Enabled := True;
end;












procedure TForm1.Button4Click(Sender: TObject);
begin
     OpenDialog1.Filename:='';
     //  OpenDialog1.Filter:='HTML-Dateien (*html & *htm)|*.htm;*.html;*.HTML;*.HTM';
     OpenDialog1.Filter:='HTML-Dateien (*.html & *.htm)|*.htm;*.html;*.HTML;*.HTM | Alle Dateien Anzeigen | *.*';

     if OpenDialog1.Execute then
     begin
          Edit3.text:=(OpenDialog1.Filename);
     end;

end;

procedure TForm1.Button5Click(Sender: TObject);
var Pfad:String;
begin
//uses FileCtrl;
	SelectDirectory('Ordner auswählen', '' ,Pfad);
	edit2.Text:=pfad;
end;



procedure TForm1.FormCreate(Sender: TObject);
var pfad:String;
begin
     //Let's create idTCPServer
     IdTCPServer                 := TIdTCPServer.Create(self);
     IdTCPServer.Active          := False;

     Form1.position:=poMainFormCenter; //poDesktopCenter;

     //Wir erlauben erstmal nur 20 Verbindungen!
     //Vielleicht sollte man das hier später den User entscheiden lassen und/oder ändern!
     //ToDo: Überlegen, wie man es handhaben möchte: User entscheidet, unlimited, oder bei 20 belasssen
     // IdTCPServer.MaxConnections  := 20;   //User darf entscheiden!

     //adding my callback functions:
     IdTCPServer.OnDisconnect    := IdTCPServerDisconnect;
     IdTCPServer.OnExecute       := IdTCPServerExecute;
     IdTCPServer.OnStatus        := IdTCPServerStatus;

     //Version:='1.7';
     Path_delimiter_OS := '\';


     {$IFDEF FPC}
             //PathDelim is known in fpc, so we don't need to define it.
             Path_delimiter_OS := PathDelim;
     {$ELSE}   //Otherwise (It's not fpc, so it's Delphi)
            //In Delphi we just define it:
            {$IFDEF MSWINDOWS}
              //In windows we use the standard separator:
              Path_delimiter_OS := '\';
            {$ELSE} //not windows, so it's linux, unix, mac...   //{$IFDEF LINUX}        //{$IFDEF UNIX}        //{$IFDEF MACOS}
              Path_delimiter_OS := '/';
            {$ENDIF}
     {$ENDIF}
             //Ansonsten setzt fpc den passenden PathDelim / DirectorySeparator für uns für das betriebssystem -> PathDelim, DirectorySeparator: directory separator for each platform ('/', '\', ...)


	//Form1.ClientHeight:=273;

	//Form1.ClientHeight:=436;

     {$IFDEF FPC}                 //Wenn FPC
             {$IFDEF UNIX}        //Wenn Linux / Unix / ...
                     Form1.ClientHeight:=600;
             {$ELSE}              //Ansonsten Windows:
                    Form1.ClientHeight:=725;//485;
             {$ENDIF}

     {$ELSE}					  //Ansonsten Delphi
        Form1.ClientHeight:=436;
     {$ENDIF}



	pfad := ExtractFilePath(Application.ExeName); // der Pfad
	Edit2.Text:=pfad;  //den aktuellen pfad wo sich der webserver befindet (gestartet wurde) als standard start verzeichnis verwenden

	StatusBar1.Panels[1].text := FormatDateTime('dddd, d. mmmm yyyy - hh:nn', Now) + ' Uhr';
	Form1.caption:= 'Simple Webserver '+Version+' von Sönke Schmidt';
        Button2.Enabled := False;

        //Die Sachen für "Eigene definierte 404 (html) Seite verwenden:" deaktivieren:
        Edit3.enabled := False;
        Button4.enabled := False;
end;


procedure TForm1.Hilfe1Click(Sender: TObject);
begin
  showmessage('Gerade keine Lust eine Hilfe zu schreiben :P'+#10+#13+'Vielleicht kommt noch eine Hilfe, aber ich denke es müsste alles verständlich sein.');
end;

procedure TForm1.Info2Click(Sender: TObject);
begin
     form2.label3.Caption:=Version;
     Form2.position:=poMainFormCenter; //poDesktopCenter;
     form2.showmodal;
end;



procedure TForm1.RadioButton1Click(Sender: TObject);
begin
     Edit3.enabled := False;
     Button4.enabled := False;
end;

procedure TForm1.RadioButton2Click(Sender: TObject);
begin
     Edit3.enabled := True;
     Button4.enabled := True;
end;







{
////////////////////////////////////////////////////////////////////////////////
Ab hier beginnt das SysTray!!!
////////////////////////////////////////////////////////////////////////////////
}

//unter uses noch hinzufügen: const WM_TASKBAREVENT = WM_USER+1;
//unter   public  { Public-Deklarationen }
//noch hinzufügen:
// procedure WMTASKBAREVENT(var message: TMessage); message WM_TASKBAREVENT;
//noch hinzufügen der shellapi bei: implementation uses shellapi;
{$IFNDEF FPC}

procedure TaskBarRemoveIcon;
var tnid : TNOTIFYICONDATA ;
begin
    tnid.cbSize := sizeof(TNOTIFYICONDATA);
    tnid.Wnd := Form1.handle;
    tnid.uID := 1;
    Shell_NotifyIcon(NIM_DELETE, @tnid);
end;


procedure TForm1.WMTASKBAREVENT(var message: TMessage);
var point : TPoint;
begin
    case message.LParamLo of
         WM_LBUTTONDBLCLK : begin
                                 form1.show;
                                 TaskBarRemoveIcon;
                            end;
         WM_RBUTTONDOWN   : begin
                                 GetCursorPos(point);
                                 popupmenu1.popup(point.x,point.y);
                            end;
    end;
end;

procedure TaskBarAddIcon;
var tnid : TNOTIFYICONDATA ;
begin
    tnid.cbSize := sizeof(TNOTIFYICONDATA); // Größenangabe der Struktur
    tnid.Wnd := Form1.handle;               // Handle des Message-Empfängers
    tnid.uID := 1;                          // ID beliebig
    tnid.uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;  // siehe Tabelle
    tnid.uCallbackMessage := WM_TASKBAREVENT;        // Message# für Form1
    tnid.hIcon := form2.image1.picture.icon.handle;  // Iconhandle
    strcopy(tnid.szTip,'Simple Webserver');                // Tooltiptext
    Shell_NotifyIcon(NIM_ADD, @tnid);                // Registrieren ...
end;
{$ENDIF}





procedure TForm1.ProgrammClick(Sender: TObject);
begin
  {$IFNDEF FPC}
        TaskBarRemoveIcon;
        Form1.show;
  {$ENDIF}
end;


procedure TForm1.Beenden2Click(Sender: TObject);
begin
  {$IFNDEF FPC}
 	TaskBarRemoveIcon;   //könnte man auch im Form1.close machen..
	Form1.Close;
  {$ENDIF}
end;



procedure TForm1.SystrayClick(Sender: TObject);
begin
     {$IFDEF FPC}
     showmessage('Die Implementierung des Systrays für Free Pascal hat noch nicht begonnen.' +#13+#10+
                 'Bisher gibt es nur eine Implementierung für Delphi, somit also für Windows.' +#13+#10+
                 'Die Möglichkeit den Webserver in das Systray zu ziehen oder nicht, ' +
                 'hat keinerlei Auswirkungen auf die Funktionalität des Webservers und ist nur ein zusätzliches Feature!');
     {$ELSE}
     self.hide;
     TaskBarAddIcon;
     {$ENDIF}

end;

{
////////////////////////////////////////////////////////////////////////////////
Ende des SysTray!!!
////////////////////////////////////////////////////////////////////////////////
}






procedure TForm1.Timer1Timer(Sender: TObject);
begin
  	StatusBar1.Panels[1].text := FormatDateTime('dddd, d. mmmm yyyy - hh:nn:ss', Now) + ' Uhr';
end;






   

{$IFDEF FPC}
//See: https://wiki.freepascal.org/Asynchronous_Calls
//     https://forum.lazarus.freepascal.org/index.php?topic=48711.0
//     https://github.com/blikblum/multilog/blob/master/memochannel.pas
procedure TForm1.WriteToMemo(const AMsg: string);
var
  LogMsgToSend: PLogMsgData;
begin
  New(LogMsgToSend);
  LogMsgToSend^.Text:= AMsg;
  //Application.QueueAsyncCall(@WriteAsyncQueue, PtrInt(LogMsgToSend)); // put log msg into queue that will be processed from the main thread after all other messages
  Application.QueueAsyncCall(WriteAsyncQueue, PtrInt(LogMsgToSend)); // put log msg into queue that will be processed from the main thread after all other messages

end;

procedure TForm1.WriteAsyncQueue(Data: PtrInt);
var // called from main thread after all other messages have been processed to allow thread safe TMemo access
  ReceivedLogMsg: TLogMsgData;
begin
  ReceivedLogMsg := PLogMsgData(Data)^;
  try
    if (Memo1 <> nil) and (not Application.Terminated) then
    begin
      //...
      Memo1.Append(ReceivedLogMsg.Text) // <<< fully thread safe
    end;
  finally
    Dispose(PLogMsgData(Data));
  end;
end;
{$ENDIF}





 // DisplayOnMemo
procedure TForm1.DisplayOnMemo(str : String);
begin

  {$IFDEF FPC}
     WriteToMemo(str);
  {$ELSE}

        TThread.Queue(nil, procedure
                       begin
                           Memo1.Lines.Add( str );
                      end
                );
  {$ENDIF}

end;










procedure TForm1.SendErrorPage(RequestedFile:String; AContext: TIdContext);
var sendError, sendErrPage, DatumUndZeit, strForMemo, fromIp :String;
    laenge, peerPort :Integer;
    FileStream :TFileStream;
begin
  DatumUndZeit:=FormatDateTime('dddd, d. mmmm yyyy hh:nn', Now);
  fromIp    := AContext.Binding.PeerIP;
  peerPort  := AContext.Binding.PeerPort;

  if form1.RadioButton1.Checked=True then
  begin
    sendErrPage :=   '<!DOCTYPE html><html> <head> ' +
                     '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'+
                     '<title>ERROR 404 - Seite nicht gefunden</title></head>'+
                     '<p>ERROR 404 - Seite nicht gefunden! </p>'+                //<br><br><br><br><br>'+  //+#13+#10+
                     '<div style="position:absolute; bottom:0px;left:17px; width: 95%;"><hr>'+
                     '<address>Simple Webserver '+Version+' programmed by <a href="https://www.soenke-berlin.de">S&ouml;nke Schmidt</a></address>'+ //Das ö bei Sönke durch &ouml; ersetzen
                     '</div></html>';

    sendError:='HTTP/1.0 404 Not Found'+#13+#10+
           'Date: '+DatumUndZeit+' GMT'+#13+#10+  //lol, 18 SoP 2008 '+TimetoStr(Time)+' GMT'+#13+#10+
           'Server: Soenkes Simple Webserver '+Version+#13+#10+
           'Last-Modified: Thu, 22 Apr 2021 16:37:24 GMT'+#13+#10+    //Könnte man auch rausnehmen. Kann es aber für einige Webbrowser einfacher machen und Inhalt ggf aus den Cach nehmen.
           'Content-Length: ' + IntToStr(length(sendErrPage)) +#13+#10+
           'Connection: close' +#13+#10+
           'Content-Type: text/html' +
            #13+#10+ #13+#10+
            sendErrPage;


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
    strForMemo :=  strForMemo + form1.Edit2.text+RequestedFile +#13+#10;
    strForMemo :=  strForMemo + 'Standard Error 404 wurde gesendet.' +#13+#10;
    strForMemo :=  strForMemo +  '---------------------------------------------------------------------------------'+#13+#10 + #13+#10;
    DisplayOnMemo(strForMemo);
  end;



  if form1.RadioButton2.Checked=True then
  begin

    FileStream := TFileStream.Create(form1.Edit3.text, fmOpenRead or fmShareDenyNone );    //readonly status reicht aus ^^

    laenge:=FileStream.Size;

    sendError:='HTTP/1.0 404 Not Found'+#13+#10+
           'Date: '+DatumUndZeit+' GMT'+#13+#10+
           'Server: Soenkes Simple Webserver '+Version+#13+#10+
           'Last-Modified: Thu, 22 Jan 2008 16:37:24 GMT'+#13+#10+
           'Content-Length: '+inttostr(laenge) +#13+#10+
           'Connection: close' +#13+#10+
           //'Content-Type: text/html' +   ////WhatContenttype('index.txt')
           'Content-Type: '+ ContentTypeFinder.WhatContenttype(form1.Edit3.text) +
             #13+#10+ #13+#10;

    try
       AContext.Connection.IOHandler.LargeStream := True;
       AContext.Connection.IOHandler.Write(sendError);
       AContext.Connection.IOHandler.Write(FileStream);
       // AContext.Connection.IOHandler.Write(FileStream, LongInt(laenge));

       // AContext.Connection.IOHandler.WriteBufferFlush;
    finally
       // AContext.Connection.IOHandler.WriteBufferClose;
       AContext.Connection.IOHandler.Close;
    end;


    strForMemo := DatetoStr(now) + ' - ' + Timetostr(now)+' Verbindung mit: IP '+ fromIp + ' und Port: '+ IntToStr(PeerPort) + #13+#10;
    strForMemo :=  strForMemo +'Folgende Datei wurde nicht gefunden:' +#13+#10;
    strForMemo :=  strForMemo + form1.Edit2.text+RequestedFile +#13+#10;
    strForMemo :=  strForMemo + '"'+form1.Edit3.text+'"'+' wurde als Error 404 gesendet' +#13+#10;
    strForMemo :=  strForMemo +  '---------------------------------------------------------------------------------'+#13+#10 + #13+#10;
    DisplayOnMemo(strForMemo);

 end;

end;





function  TForm1.pfadUrlEncoding (Path: string):String;
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





function  TForm1.pfadUrlDecoding (Path: string):String;
var ret : String;
begin
     ret:= Path;
     ret := TIdURI.URLDecode(ret);   //Das Decoding überprüft keine url und decodiert einfach den ganzen string so um, wie es sein soll.
     result := ret;
end;




//sr.attr and faHidden <> 0 für alle NICHT verstecken Dateien
//sr.attr and faSysFile <> 0 für alle NICHT Systemdateien
//if (SR.Attr <> faDirectory) then    //ggf ändern zu: //if (SR.Attr and faDirectory) = 0
procedure TForm1.ListFileDir(Path: string; FileList: TStrings);
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

{
Wenn Du weder Verzeichnisse noch System- noch versteckte Dateien listen möchtest, musst Du die Attribute entweder einzeln nacheinander oder mit einer passenden Bitmaske abfragen.
if ((SR.Attr and faDirectory) = 0) and ((SR.Attr and faHidden) = 0) and ((SR.Attr and faSysFile) = 0) then oder
if (SR.Attr and (faDirectory or faHidden or faSysFile)) = 0 then Falls Dir das unklar ist, schau doch mal in mein Tutorial
//Siehe: https://www.delphipraxis.net/139926-dateien-eines-verzeichnis-auflisten.html
}

procedure TForm1.sendeVerzeichnis (Path: string; AContext: TIdContext);
var   i, laenge, temppfadInt, peerPort:Integer;
      send,DatumUndZeit,text,temppfad, temppfad_encoded, strForMemo, fromIp:String;
      liste, fileList: TStringList;
begin

        fromIp    := AContext.Binding.PeerIP;
        peerPort  := AContext.Binding.PeerPort;

	temppfadInt:=length(path)-length(form1.edit2.text);

	if temppfadint=0 then
	begin
	     temppfad:='Root';
	end
	else
	begin
	     temppfad:=Path;

             //anfang löschen, so dass nur der bzw die Unterordner da steht
             Delete(temppfad, 1, length(form1.Edit2.Text));

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

	DatumUndZeit:=FormatDateTime('dddd, d. mmmm yyyy hh:nn', Now);
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
                  '<address>Simple Webserver '+Version+' programmed by <a href="https://www.soenke-berlin.de">S&ouml;nke Schmidt</a></address>'+ //Das ö bei Sönke durch &ouml; ersetzen
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

        send:='HTTP/1.0 200 OK'+#13+#10+
              'Date: '+DatumUndZeit+' GMT'+#13+#10+
              'Server: Soenkes Simple Webserver '+Version+#13+#10+
              'Last-Modified: Thu, 22 Jan 2008 16:37:24 GMT'+#13+#10+
              'Content-Length: '+inttostr(laenge) +#13+#10+
              'Connection: close' +#13+#10+
              //'Content-Type: text/html' +
              'Content-Type: text/html'+         ////////+WhatContenttype(RequestedFile) +
               #13+#10+ #13+#10;

        try
           AContext.Connection.IOHandler.Write(send+Liste.text);
        finally
           AContext.Connection.IOHandler.Close;
        end;

        strForMemo := DatetoStr(now) + ' - ' + Timetostr(now)+' Verbindung mit: IP '+ fromIp + ' und Port: '+ IntToStr(PeerPort) + #13+#10;
        strForMemo := strForMemo +' Folgendes Unterverzeichnis wurde in FTP Ansicht übertragen:' +#13+#10;
        strForMemo :=  strForMemo + temppfad +#13+#10;
        strForMemo :=  strForMemo +  '---------------------------------------------------------------------------------'+#13+#10 + #13+#10;
        DisplayOnMemo(strForMemo);

        fileList.Free;
        Liste.Free;
end;







procedure TForm1.Update1Click(Sender: TObject);
begin
  showmessage('Ich arbeite unregelmäßig an diesem Projekt. Bitte checken Sie auf meiner Homepage oder der Github Seite nach einer neuen Version...'+ #10+#13+
              'Infos dazu finden Sie im Menüreiter unter Info und dann im Aufploppenden Menü auf Info ganz unten klicken.'+ #10+#13+
              'Falls sie Bugs oder ähnliches gefunden haben, dürfen Sie mich gerne anschreiben, damit ich die Software verbessern kann.'+#13+#10+
              'Um mich anzuschreiben, können sie unter Info->Info meine Homepage Adresse sowie die Github Webseite finden.');
end;








// .............................................................................

// *****************************************************************************
//   EVENT : onDisconnect()
//           OCCURS ANY TIME A CLIENT IS DISCONNECTED
// *****************************************************************************
procedure TForm1.IdTCPServerDisconnect(AContext: TIdContext);
var
    ip          : string;
    port        : Integer;
    fromIp      : string;
    peerPort    : Integer;
    strForMemo : String;
begin
  //Folgendes kann verwirrend sein, wenn der Client eine Datei aufruft, die er noch im Cache hat!
  //Dann baut der Browser zwar eine Verbindung zum Server auf, beendet sie aber sofort und lädt den Inhalt aus dem Cache.
  //Dadurch erscheint dann nur ein "Disconnected" bei den Server anfragen in memo1. Das kann dann seltsam aussehen, wenn man nicht weiß,
  //dass der Browser die Datei noch im Cache hatte und darum kein http-get-befehl gesendet hat.
  //Um diese Verwirrung nicht aufkommen zu lassen, ist der Code auskommentiert!

  {
    ip        := AContext.Binding.IP;
    port      := AContext.Binding.Port;
    fromIp    := AContext.Binding.PeerIP;
    peerPort  := AContext.Binding.PeerPort;

   strForMemo := Timetostr(now)+' Verbindung mit: IP '+ fromIp + ' und Port: '+ IntToStr(PeerPort) + #13+#10;
   strForMemo :=  strForMemo + 'Disconnected. Verbindung zu uns ('+ip+':'+IntToStr(port)+') getrennt.' +#13+#10 + #13+#10;   ;
   DisplayOnMemo(strForMemo);
   }
end;
// .............................................................................






// *****************************************************************************
//   EVENT : onExecute()
//           ON EXECUTE THREAD CLIENT
// *****************************************************************************
procedure TForm1.IdTCPServerExecute(AContext: TIdContext);
var
    PeerPort      : Integer;

    BufferAsBytes: TIdBytes;    //The TIdBytes type is declared in the IdGlobal unit.

    Text, text2, temp, sendError, RequestedFile, DatumUndZeit, send, letzteZeichen: string;
    fromIp, fromPort, strForMemo  : String;
    i, posi, laenge, position: integer;
    FileStream : TFileStream;
    Ordner_hat_index: Boolean;
    //sendError, sendErrPage, DatumUndZeit:String;
    //pfad, sendPage :String;
    //PeerIP        : string;
    //Port          : Integer;
         //msgFromClient : string;
    //msgToClient, RxBufStr   : string;
    //ReadedBytesAsStr: String;
begin
    BufferAsBytes := nil;
    with AContext.Connection.IOHandler do
    begin

      CheckForDataOnSource(10);
      if not InputBufferIsEmpty then
      begin
        //Alles aus dem Buffer holen (die komplette http anfrage holen und nicht nur eine zeile!)
        InputBuffer.ExtractToBytes(BufferAsBytes);
        Text := BytesToString(BufferAsBytes);
      end;
    end;

    //Wir lesen noch die IP und den Port aus, der sich verbindet:
    fromIp    := AContext.Binding.PeerIP;
    peerPort  := AContext.Binding.PeerPort;
    fromPort  := IntToStr(PeerPort);  //Direkt als string umwandeln, damit wir es später einfacher benutzen könenn

    if length(Text) > 0 then
    begin
        if AContext.Connection.IOHandler.Connected then
        begin
          DatumUndZeit:=FormatDateTime('dddd, d. mmmm yyyy hh:nn', Now);
          AContext.Connection.IOHandler.DefStringEncoding := IndyTextEncoding_UTF8;   //Direkt auf utf8 stellen, damit ich es später nicht immer wieder machen muss...

          strForMemo := DatetoStr(now) + ' - ' + Timetostr(now)+' Verbindung mit: IP '+ fromIp + ' und Port: '+ fromPort + #13+#10;
          strForMemo :=  strForMemo + 'HTTP-Request:' +#13+#10 + #13+#10;   ;
          strForMemo :=  strForMemo +  Text ;
          DisplayOnMemo(strForMemo);




	  if pos('GET /',Text)=1 then   //wenn ein get befehl kommt:
	  begin
	       temp:=Text;
	       Delete(temp, 1, 5);  //Lösche 'GET /'    //in temp ist nun also (z.B.): "infos/ HTTP/1.1 ..."

	       if pos(' ',temp)=1 then  //== "GET / HTTP/1.1" oder so ähnlich  //Leerzeichen hiner /  -> root aufruf
	       begin
	            //Priorisierung: Erst html dann htm senden (Darum zuletzt html überprüfen, damit es das letzte und somit erste gewählte ist)
		    if fileexists(Edit2.text+'index.htm') then
		       RequestedFile:='index.htm';

		    if fileexists(Edit2.text+'index.html') then
		       RequestedFile:='index.html';


		    if (not fileexists(Edit2.text+'index.html')) and (not fileexists(Edit2.text+'index.htm')) then
		    begin

		         if Radiobutton3.checked=true then
			 begin
			      SendErrorPage('index.html', AContext);   //index.html im root verzeichnis nicht gefunden...
			      exit;//ende, da eine erneute error page nicht gesendet werden muss...
			 end;

			 if Radiobutton4.checked=true then
			 begin
			      sendeVerzeichnis(Edit2.text, AContext);   //index.html im root verzeichnis nicht gefunden...
			      exit; //und raus hier, da sonst evtl noch eine error-page mit kommt ;D
			 end;  // sendeVerzeichnis (Path: string);

		    end;

	       end     //end von: if pos(' ',temp)=1 then
	       else    //Also kein Leerzeichen hinter 'GET /'
	       begin   //Dann steht dort eine Datei oder Verzeichnis!
                       //Man hat also sowas wie: 'GET /infos/ HTTP...

	             posi:= pos(' ',temp); //Das erste Leerzeichen hinter der Datei/Pfad finden. Ggf verbessern zu: ' HTTP'

		     text2:=Copy(temp, 1, posi-1);    //text2 ist nun "infos/"
		     RequestedFile := text2;

		     position :=length(text2);
		     letzteZeichen := Copy(text2, position,1 );  //nun sollte das letzte zeichen in "letzteZeichen" drin sein
		     //RequestedFile:=Copy(temp, 1, posi-1);


		     //noch die pfad angaben säubern
		     //Oktettfolge
		     //if AnsiPos('%20',LowerCase(RequestedFile)) > 0 then
		     //Begin
		     //     RequestedFile:=stringreplace(RequestedFile, '%20', ' ', [rfreplaceall,rfignorecase] );
		     //end;

                                                                          //Als bsp. bekommt man sowas wie: test/S%C3%B6nkes-Datei.txt/
                     RequestedFile:= pfadUrlDecoding( RequestedFile );    //Jetzt wird es zu:               test/Sönkes-Datei.txt

                     //Pfad-Trennzeichen auf das Betriebssystem anpassen:
                     RequestedFile:=stringreplace(RequestedFile, '/', Path_delimiter_OS, [rfreplaceall,rfignorecase] );
                                                                          //Jetzt wird es zu:               test\Sönkes-Datei.txt




                       //------------------------\\
                      /////    Spezialfall:    \\\\\
                     //----------------------------\\

                     //es wird ein verzeichnis angefordert... denn das letzte zeichen ist ein "/"
		     if pos('/',letzteZeichen) = 1 then
		     begin
                     //testen ob es in dem verzeichnis eine index.html/index.htm datei gibt und diese dann aufrufen...

		            Ordner_hat_index:=false;     //erstmal von ausgehen, dass wir kein index haben...

		            if fileexists(Edit2.text+RequestedFile+'index.htm') then
		            begin
		                 RequestedFile:=RequestedFile+'index.htm';         //pfad+index speichern
			         Ordner_hat_index := true;
		            end;

		            if fileexists(Edit2.text+RequestedFile+'index.html') then
		            begin
		                 RequestedFile:=RequestedFile+'index.html';                    //and (not fileexists(Edit2.text+RequestedFile+'index.htm')) then
			         Ordner_hat_index := true;    //index erkannt und genommen verzeichnis abarbeitung wird dann übersprungen...
		            end;


		            //ok index.htm/L existiert nicht, also normal weitermachen...
		            if Ordner_hat_index = false then  //ordner hat kein index.... also mache normal weiter...           //(not fileexists(Edit2.text+RequestedFile')) then     ///folgendes ist unnötig, da ja in requested schon der pfad + index drin ist....///// and (not fileexists(Edit2.text+RequestedFile+'index.htm')) then
		            begin

		                 if Radiobutton3.checked=true then
			         begin
			              SendErrorPage(RequestedFile, AContext);   //ordner wurde nicht gefunden, bzw darf nicht gefunden werden ;)
			              exit;//ende, da eine erneute error page nicht gesendet werden muss...
		                 end;

			         if Radiobutton4.checked=true then
			         begin
			              sendeVerzeichnis(Edit2.text+RequestedFile, AContext);  //gibt verzeichniss
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



	       if fileexists(Edit2.text+RequestedFile) then
	       begin  //angeforderte datei existiert, also senden ^^

	              FileStream := TFileStream.Create(Edit2.text+RequestedFile, fmOpenRead or fmShareDenyNone );    //readonly status reicht aus ^^

		      laenge:=FileStream.Size;

		      //send datei:
		      send:=	'HTTP/1.0 200 OK'+#13+#10+
		                'Date: '+DatumUndZeit+' GMT'+#13+#10+
				'Server: Soenkes Simple Webserver '+Version+#13+#10+
				'Last-Modified: Thu, 22 Apr 2021 16:37:24 GMT'+#13+#10+
				'Content-Length: '+inttostr(laenge) +#13+#10+
				'Connection: close' +#13+#10+
				//'Content-Type: text/html' +
				'Content-Type: '+ ContentTypeFinder.WhatContenttype(RequestedFile) +
				#13+#10+ #13+#10;


                      try
                         try
                               AContext.Connection.IOHandler.Write(send);
                               AContext.Connection.IOHandler.LargeStream := True;
                               AContext.Connection.IOHandler.Write(FileStream);
                         except
                               on e: Exception do
                               Begin
                                    strForMemo := DatetoStr(now) + ' - ' + Timetostr(now)+' Verbindung mit: IP '+ fromIp + ' und Port: '+ fromPort + #13+#10;
                                    strForMemo := strForMemo + 'Möglicher Verbindungsabbruch des Clienten/Browsers. Z.B. Abbruch eines Downloads...' +#13+#10;
                                    strForMemo :=  strForMemo + 'Ansonsten ist irgendetwas schief gegangen bei:' +#13+#10;
                                    strForMemo :=  strForMemo + Edit2.text+RequestedFile +#13+#10;
                                    strForMemo :=  strForMemo + 'Fehlermeldung: '+ e.Message + #13+#10;
                                    strForMemo :=  strForMemo +  '---------------------------------------------------------------------------------'+#13+#10+#13+#10 ;
                                    DisplayOnMemo(strForMemo);
                               End;
                         end;
                      finally
                               // AContext.Connection.IOHandler.WriteBufferClose;
                               AContext.Connection.IOHandler.Close;
                      end;

                      strForMemo := DatetoStr(now) + ' - ' + Timetostr(now)+' Verbindung mit: IP '+ fromIp + ' und Port: '+ fromPort + #13+#10;
                      strForMemo := strForMemo + 'Folgende Datei gesendet:' +#13+#10;
                      strForMemo :=  strForMemo + Edit2.text+RequestedFile +#13+#10;
                      strForMemo :=  strForMemo +  '---------------------------------------------------------------------------------'+#13+#10 +#13+#10;
                      DisplayOnMemo(strForMemo);

	       end      //ende zu: if fileexists(Edit2.text+RequestedFile) then
	       else     //fileexist=false also sende error!
	       begin
	              SendErrorPage(RequestedFile, AContext);
	       end; //ende von else von: if fileexists(Edit2.text+RequestedFile) then


	  end;  //ende zu: if pos('GET /',Text)=1 then begin [..] END;
        end; //ende zu: if AContext.Connection.IOHandler.Connected then
    end;  //ende zu: if length(Text) > 0 then


end;
// .............................................................................








// *****************************************************************************
//   EVENT : onStatus()
//           ON STATUS CONNECTION
// *****************************************************************************
procedure TForm1.IdTCPServerStatus(ASender: TObject; const AStatus: TIdStatus;
                                     const AStatusText: string);
begin
    // ... OnStatus is a TIdStatusEvent property that represents the event handler
    //     triggered when the current connection state is changed...

    //Maybe in Statusbar
    //StatusBar1.Panels[0].text := AStatusText
end;
// .............................................................................















///////////////////////////////////////
end.

