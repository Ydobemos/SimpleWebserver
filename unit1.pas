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
  //{$IFDEF FPC}
 // fileutil, //für FindAllFiles
 // {$ENDIF}
  //Indy 10 Stuff:
   IdContext, IdComponent, IdBaseComponent, IdCustomTCPServer, IdThreadSafe,
   IdTCPConnection, IdYarn, IdTCPServer, IdGlobal, IdURI,
  //My Class for the ContentType Finder:
  MyContentTypeFinder,
  //My Class for the Systray:
  MySystray,
  //My Singleton Class to Save all the Settings and make it available for everyone
  ServerSettingsSingleton,
  //My TCP Server Stuff. Putting all TCP related stuff here
  MyTCPServerUnit;
   //Crt;

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
    StartButton: TButton;
    StopButton: TButton;
    ErrorPagePathSelectButton: TButton;
    WorkDirectorySelectButton: TButton;
    PortEdit: TEdit;
    WorkingDirectoryEdit: TEdit;
    ErrorPagePathEdit: TEdit;
    MaxConnectionsEdit: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
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
    StandardErrorPageToSendRadioButton: TRadioButton;
    OwnErorPageToSendRadioButton: TRadioButton;
    SendErrorOnCleanPathRadioButton: TRadioButton;
    SendFtpViewRadioButton: TRadioButton;
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
    procedure StartButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure ErrorPagePathSelectButtonClick(Sender: TObject);
    procedure WorkDirectorySelectButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Hilfe1Click(Sender: TObject);
    procedure Info2Click(Sender: TObject);
    procedure ProgrammClick(Sender: TObject);
    procedure StandardErrorPageToSendRadioButtonClick(Sender: TObject);
    procedure OwnErorPageToSendRadioButtonClick(Sender: TObject);
    procedure SystrayClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    //////My callback functions
    //procedure IdTCPServerDisconnect(AContext: TIdContext);
    //procedure IdTCPServerExecute(AContext: TIdContext);
    //procedure IdTCPServerStatus(ASender: TObject; const AStatus: TIdStatus;
    //                                const AStatusText: string);
    procedure DisplayOnMemo(str : String);
    procedure Update1Click(Sender: TObject);
   // procedure SendErrorPage(RequestedFile:String; AContext: TIdContext);
  //  procedure sendeVerzeichnis (Path: string; AContext: TIdContext);
  //  procedure ListFileDir(Path: string; FileList: TStrings);
  //  function pfadUrlEncoding (Path: string):String;
  //  function pfadUrlDecoding (Path: string):String;
    function SaveServerSettingsToSingleton: Boolean;
    procedure DeactivateTheVisualControlls;
    procedure TryActivateServer;
    procedure ResetServerStateVisuals;
  //  procedure CreateIdTCPServerAndCallbackFunctions;
  private
        {$IFDEF FPC}
        procedure WriteToMemo(const AMsg: string);
        {$ENDIF}
  public
        {$IFDEF FPC}
         procedure WriteAsyncQueue(Data: PtrInt);
        {$ENDIF}
  end;

var
  Form1: TForm1;
//  IdTCPServer : TIdTCPServer;
  Version : String = '1.71';
  Path_delimiter_OS : String;
  MySystrayClass : SystrayClass;
  MyTCPServer: TMyTCPServer;

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




function TForm1.SaveServerSettingsToSingleton: Boolean;
begin
 Result := True;
  TServerSettingsSingleton.Instance.WorkingDirectoryPath := WorkingDirectoryEdit.Text;

  try
    TServerSettingsSingleton.Instance.Port := StrToInt(PortEdit.text);
  except
      on e: Exception do
      Begin
         showmessage('Bitte einen gültigen Port eintragen! ' +#13+#10+#13+#10+
          'Die Fehlermeldung lautet: ' +#13+#10+
           e.Message );
         Result := False;
      end;
  end;

  try
    TServerSettingsSingleton.Instance.MaxConnections := StrToInt(MaxConnectionsEdit.text);
  except
      on e: Exception do
      Begin
         showmessage('Bitte eine gültige Anzahl an maximalen Verbindungen eintragen! ' +#13+#10+#13+#10+
          'Die Fehlermeldung lautet: ' +#13+#10+
           e.Message );
         Result := False;
      end;
  end;

  TServerSettingsSingleton.Instance.SendIndividualErrorPage := OwnErorPageToSendRadioButton.checked;
  if TServerSettingsSingleton.Instance.SendIndividualErrorPage = true then
     TServerSettingsSingleton.Instance.IndividualErrorPagePath := ErrorPagePathEdit.text;

  TServerSettingsSingleton.Instance.SendFtpLikeViewOnEmptyDir := SendFtpViewRadioButton.checked;
  TServerSettingsSingleton.Instance.ProgramVersion := Version;
  TServerSettingsSingleton.Instance.Path_delimiter_OS := Path_delimiter_OS;
end;



function ValidateDirectory(const Dir: string): Boolean;
begin
  Result := True;
  if Dir = '' then
  begin
    showmessage('Bitte wählen Sie das Arbeitsverzeichnis aus, in dem sich die Dateien befinden, die der Webserver verwenden soll');
    Result := False;
  end
else
if not DirectoryExists(Dir) then
begin
    Showmessage('Das Arbeitsverzeichnis existiert garnicht ...'+#13+#10+'Bitte geben Sie ein korrektes Arbeitsverzeichnis an!');
    Result := False;
  end;
end;



function ValidateErrorDirectory: Boolean;
begin
   Result := True;
  //Checken ob eigene definierte 404 (html) Seite verwendet wird:
  if TServerSettingsSingleton.Instance.SendIndividualErrorPage then
  begin
    if (TServerSettingsSingleton.Instance.IndividualErrorPagePath = '') then
    begin
      showmessage('Bitte geben Sie auch eine Fehlerseite an oder wählen Sie "Standard Error 404 Seite senden" aus.');
      Result := False;
    end;

    if not fileexists(TServerSettingsSingleton.Instance.IndividualErrorPagePath) then
    begin
      Showmessage('Ihre Fehlerseite existiert nicht, bitte geben Sie eine existierende Fehlerseite an!');
      Result := False;
    end;
  end;
end;



procedure TForm1.DeactivateTheVisualControlls;
begin
   //Arbeitsverzeichnis, Port etc. kann während des Starts nicht mehr geändert werden!
   WorkingDirectoryEdit.Enabled := False;
   WorkDirectorySelectButton.Enabled := False;
   PortEdit.Enabled := False;
   MaxConnectionsEdit.Enabled := False;
   StartButton.Enabled := False;

   StandardErrorPageToSendRadioButton.Enabled := False;
   OwnErorPageToSendRadioButton.Enabled := False;
   ErrorPagePathEdit.Enabled := False;
   ErrorPagePathSelectButton.Enabled := False;

   SendErrorOnCleanPathRadioButton.Enabled := False;
   SendFtpViewRadioButton.Enabled := False;
end;



procedure EnsureTrailingPathDelimiter;
var path:String;
begin
  path := TServerSettingsSingleton.Instance.WorkingDirectoryPath;
  if not Path.EndsWith(Path_delimiter_OS) then
     TServerSettingsSingleton.Instance.WorkingDirectoryPath := Path + Path_delimiter_OS;
end;



procedure TForm1.TryActivateServer;
begin

  MyTCPServer.ClearBindings;


  try
    // Port hinzufügen:
    MyTCPServer.SetServerPort;
  except
    showmessage('Bitte einen gültigen Port eintragen!');
    exit;
  end;


  try
    // MaxConnections hinzufügen:
    MyTCPServer.SetMaxConnections;
  except
    showmessage('Bitte eine gültige Anzahl an maximalen Verbindungen eintragen!');
    exit;
  end;


  DeactivateTheVisualControlls;


//Ein aktives binding auf IPv4 ist gerade nicht nötig. Kann man aber mal im Hinterkopf behalten:
   //IdTCPServer.Bindings.Items[0].IPVersion := Id_IPv4 ;

      try
      MyTCPServer.StartServer;    //Server ist nun aktiv!
   except
      on e: Exception do
      Begin
          showmessage('Fehler beim Starten des Servers! ' +#13+#10+
                      'Ist der Port schon in Benutzung? Ein höherer Port, der keine speziellen Recht braucht und nicht bereits benutzt wird, könnte das Problem beheben!'  +#13+#10+
                      'Probieren Sie mal Port 8080 oder Port 8083 aus.'  +#13+#10 +#13+#10+
                      'Ansonsten lautet die Fehlermeldung: ' +#13+#10+
                      e.Message );
          ResetServerStateVisuals;
      end;
   end;

end;



procedure TForm1.ResetServerStateVisuals;
begin
  StopButton.Click; //Den "Stop" Button drücken und somit alle Visuellen Komponenten wieder zurücksetzen!
end;



/////// Start - Button \\\\\\\
procedure TForm1.StartButtonClick(Sender: TObject);
begin
  if not SaveServerSettingsToSingleton then Exit;

  StopButton.Enabled := True; //Stop-Button aktivierbar machen

  if not ValidateDirectory(TServerSettingsSingleton.Instance.WorkingDirectoryPath) then Exit;
  if not ValidateErrorDirectory then Exit;


  EnsureTrailingPathDelimiter;
  //Falls ein delemiter am Ende geschrieben wurde schreiben wir es zurück, damit es angezeigt wird: (ist nur visuel und daher eigentlich optional)
  WorkingDirectoryEdit.Text := TServerSettingsSingleton.Instance.WorkingDirectoryPath;

  TryActivateServer;
end;



procedure TForm1.StopButtonClick(Sender: TObject);
begin
   //IdTCPServer.Active := False;  //Server wird gestoppt
   MyTCPServer.StopServer;
   //Arbeitsverzeichnis, Port etc. wieder aktivieren, damit sie geändert werden können
   WorkingDirectoryEdit.Enabled := True;
   WorkDirectorySelectButton.Enabled := True;
   PortEdit.Enabled := True;
   MaxConnectionsEdit.Enabled := True;
   StartButton.Enabled := True;
   StopButton.Enabled := False;

   StandardErrorPageToSendRadioButton.Enabled := True;
   OwnErorPageToSendRadioButton.Enabled := True;
   ErrorPagePathEdit.Enabled := True;
   ErrorPagePathSelectButton.Enabled := True;

   SendErrorOnCleanPathRadioButton.Enabled := True;
   SendFtpViewRadioButton.Enabled := True;
end;



procedure TForm1.ErrorPagePathSelectButtonClick(Sender: TObject);
begin
  OpenDialog1.Filename:='';
  OpenDialog1.Filter:='HTML-Dateien (*.html & *.htm)|*.htm;*.html;*.HTML;*.HTM | Alle Dateien Anzeigen | *.*';

  if OpenDialog1.Execute then
  begin
    ErrorPagePathEdit.text:=(OpenDialog1.Filename);
  end;
end;



procedure TForm1.WorkDirectorySelectButtonClick(Sender: TObject);
var Pfad:String;
begin
   //uses FileCtrl;
   SelectDirectory('Ordner auswählen', '' ,Pfad);
   WorkingDirectoryEdit.Text:=pfad;
end;



procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
   MySystrayClass.Free;
end;


 {
procedure TForm1.CreateIdTCPServerAndCallbackFunctions;
begin
   //Let's create idTCPServer
   IdTCPServer                 := TIdTCPServer.Create(self);
   IdTCPServer.Active          := False;

   //adding my callback functions:
   IdTCPServer.OnDisconnect    := IdTCPServerDisconnect;
   IdTCPServer.OnExecute       := IdTCPServerExecute;
   IdTCPServer.OnStatus        := IdTCPServerStatus;
end;
  }


procedure TForm1.FormCreate(Sender: TObject);
var pfad:String;
begin
  Form1.position:=poMainFormCenter; //poDesktopCenter;

  //CreateIdTCPServerAndCallbackFunctions;

  //Let's create idTCPServer and adding my callback functions:
  MyTCPServer := TMyTCPServer.Create(Self);


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


  //Höhe und Größe der Form Einstellen. Unterschiede zwischen Delphi und Lazarus sowie bei Linux und Windows
  {$IFDEF FPC}            //Wenn FPC
          {$IFDEF UNIX}   //Wenn Linux / Unix / ...
                  Form1.ClientHeight:=600;
          {$ELSE}         //Ansonsten Windows:
                  Form1.ClientHeight:=725;//485;
          {$ENDIF}

  {$ELSE}                //Ansonsten Delphi
     Form1.ClientHeight:=436;
  {$ENDIF}


  pfad := ExtractFilePath(Application.ExeName); // der Pfad
  WorkingDirectoryEdit.Text:=pfad;  //den aktuellen pfad wo sich der webserver befindet (gestartet wurde) als standard start verzeichnis verwenden

  StatusBar1.Panels[1].text := FormatDateTime('dddd, d. mmmm yyyy - hh:nn', Now) + ' Uhr';
  Form1.caption:= 'Simple Webserver '+Version+' von Sönke Schmidt';
  StopButton.Enabled := False;

  //Die Sachen für "Eigene definierte 404 (html) Seite verwenden:" deaktivieren:
  ErrorPagePathEdit.enabled := False;
  ErrorPagePathSelectButton.enabled := False;

  //Systray initialisieren:
  MySystrayClass := SystrayClass.create();
  {$IFDEF FPC}
      MySystrayClass.CreateSystrayStuffForFPC;
  {$ENDIF}
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



procedure TForm1.StandardErrorPageToSendRadioButtonClick(Sender: TObject);
begin
     ErrorPagePathEdit.enabled := False;
     ErrorPagePathSelectButton.enabled := False;
end;



procedure TForm1.OwnErorPageToSendRadioButtonClick(Sender: TObject);
begin
     ErrorPagePathEdit.enabled := True;
     ErrorPagePathSelectButton.enabled := True;
end;







{
////////////////////////////////////////////////////////////////////////////////
Ab hier beginnt das SysTray!!!
Überwiegend ausgelagert in die Klasse "MySystray"
////////////////////////////////////////////////////////////////////////////////
}

{$IFNDEF FPC}
class procedure TForm1.WMTASKBAREVENT(var message: TMessage);
var point : TPoint;
begin
    case message.LParamLo of
         WM_LBUTTONDBLCLK : begin
                                 form1.show;
                                 MySystrayClass.TaskBarRemoveIcon;
                            end;
         WM_RBUTTONDOWN   : begin
                                 GetCursorPos(point);
                                 popupmenu1.popup(point.x,point.y);
                            end;
    end;
end;
{$ENDIF}

procedure TForm1.ProgrammClick(Sender: TObject);
begin
   MySystrayClass.PopupMenuClickOnProgramm;
end;


procedure TForm1.Beenden2Click(Sender: TObject);
begin
   MySystrayClass.PopupMenuClickOnBeenden;
end;



procedure TForm1.SystrayClick(Sender: TObject);
begin
   MySystrayClass.SystrayClick;
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













procedure TForm1.Update1Click(Sender: TObject);
begin
  showmessage('Ich arbeite unregelmäßig an diesem Projekt. Bitte checken Sie auf meiner Homepage oder der Github Seite nach einer neuen Version...'+ #10+#13+
              'Infos dazu finden Sie im Menüreiter unter Info und dann im Aufploppenden Menü auf Info ganz unten klicken.'+ #10+#13+
              'Falls sie Bugs oder ähnliches gefunden haben, dürfen Sie mich gerne anschreiben, damit ich die Software verbessern kann.'+#13+#10+
              'Um mich anzuschreiben, können sie unter Info->Info meine Homepage Adresse sowie die Github Webseite finden.');
end;



















///////////////////////////////////////
end.

