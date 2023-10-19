unit MySystray;

{$mode Delphi}

interface

uses
  Classes, SysUtils;

{$IFNDEF FPC}
const WM_TASKBAREVENT = WM_USER+1;
{$ENDIF}

type
  SystrayClass = class
  public
    {$IFNDEF FPC}
     class procedure TaskBarAddIcon;
     class procedure TaskBarRemoveIcon;
    {$ENDIF}

    {$IFNDEF FPC}
             procedure WMTASKBAREVENT(var message: TMessage); message WM_TASKBAREVENT;
    {$ENDIF}

  end;

implementation



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





end.

