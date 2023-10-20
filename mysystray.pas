unit MySystray;

{$mode Delphi}

interface

uses
  Classes, SysUtils
  {$IFDEF FPC}
   , ExtCtrls, Graphics ,  Dialogs, StdCtrls, Menus , Forms  , Controls
  {$ENDIF}
  ;

{$IFNDEF FPC}
const WM_TASKBAREVENT = WM_USER+1;
{$ENDIF}

type
  SystrayClass = class
  private
  public
    {$IFNDEF FPC}
     class procedure TaskBarAddIcon;
     class procedure TaskBarRemoveIcon;
    {$ENDIF}

    {$IFNDEF FPC}
     procedure WMTASKBAREVENT(var message: TMessage); message WM_TASKBAREVENT;
    {$ENDIF}

    {$IFDEF FPC}
     procedure CreateSystrayStuffForFPC;
     procedure MinimizeToSystray;
     procedure TheTrayIconClick(Sender: TObject);
    {$ENDIF}

     procedure PopupMenuClickOnProgramm;
     procedure PopupMenuClickOnBeenden;
     procedure SystrayClick;

  end;

 {$IFDEF FPC}
  var
   TheTrayIcon : TTrayIcon;
 {$ENDIF}

implementation
 {$IFDEF FPC}
   uses Unit1;
 {$ENDIF}

//unter uses noch hinzufügen: const WM_TASKBAREVENT = WM_USER+1;
//unter   public  { Public-Deklarationen }
//noch hinzufügen:
// procedure WMTASKBAREVENT(var message: TMessage); message WM_TASKBAREVENT;
//noch hinzufügen der shellapi bei: implementation uses shellapi;
{$IFNDEF FPC}

class procedure SystrayClass.TaskBarRemoveIcon;
var tnid : TNOTIFYICONDATA ;
begin
    tnid.cbSize := sizeof(TNOTIFYICONDATA);
    tnid.Wnd := Form1.handle;
    tnid.uID := 1;
    Shell_NotifyIcon(NIM_DELETE, @tnid);
end;

class procedure SystrayClass.TaskBarAddIcon;
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



 //Here the Systray Version for Lazarus / Free Pascal:
{$IFDEF FPC}
procedure SystrayClass.CreateSystrayStuffForFPC;
var
   MyIcon : TIcon;
begin
  TheTrayIcon := TTrayIcon.Create(nil);
  TheTrayIcon.Icons  := TImageList.Create(nil);
  MyIcon := Application.Icon;
  TheTrayIcon.Icon.Assign(MyIcon);
  TheTrayIcon.Icons.AddIcon(MyIcon);

  TheTrayIcon.PopUpMenu :=  Form1.PopupMenu1;
  TheTrayIcon.OnClick := TheTrayIconClick;
end;

procedure SystrayClass.TheTrayIconClick(Sender: TObject);
begin
   with form1 do
   Begin
        if WindowState = wsMinimized then
        begin
             WindowState := wsNormal;
        end;
        Show;
   end;
 TheTrayIcon.Visible := false;
end;

procedure SystrayClass.MinimizeToSystray;
begin
   with form1 do
   Begin
       WindowState:=wsMinimized;
       Hide;
   end;
  TheTrayIcon.Visible:= true;
end;
{$ENDIF}


procedure SystrayClass.PopupMenuClickOnProgramm;
begin
  {$IFNDEF FPC}
    TaskBarRemoveIcon;
    Form1.show;
  {$ENDIF}

  {$IFDEF FPC}
  TheTrayIcon.Visible := false;
  with form1 do
  Begin
       WindowState := wsNormal;
       Show;
       Application.BringToFront();
  end;
  {$ENDIF}
end;



procedure SystrayClass.PopupMenuClickOnBeenden;
begin
 {$IFNDEF FPC}
    TaskBarRemoveIcon;   //könnte man auch im Form1.close machen..
    Form1.Close;
 {$ENDIF}

 {$IFDEF FPC}
    TheTrayIcon.Visible := false;
    Form1.Close;
{$ENDIF}
end;

procedure SystrayClass.SystrayClick;
begin
 {$IFDEF FPC}
   MinimizeToSystray;
 {$ELSE}
 form1.self.hide;
 TaskBarAddIcon;
 {$ENDIF}
end;

end.

