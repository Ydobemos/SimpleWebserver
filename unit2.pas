unit Unit2;

{$IFDEF FPC}
{$mode delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  {$IFDEF FPC}
     LCLIntf;
  {$ELSE}
      Windows, Shellapi;
  {$ENDIF}


type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Label1: TLabel;
    My_Github_url: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    soenke_url: TLabel;
    Label9: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure My_Github_urlClick(Sender: TObject);
    procedure My_Github_urlMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure soenke_urlClick(Sender: TObject);
    procedure soenke_urlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure openUrl_inBrowser(website: String);
  private

  public

  end;

var
  Form2: TForm2;

implementation

{$IFDEF FPC}
      {$R *.lfm}
{$ELSE}
     {$R *.dfm}
{$ENDIF}


{ TForm2 }


procedure TForm2.openUrl_inBrowser(website: String);
begin
  //website := 'https://www.soenke-berlin.de';


  {$IFDEF FPC}
     OpenURL(website);
  {$ELSE}
      ShellExecute(Application.Handle, 'open', PChar(website), nil, nil, sw_ShowNormal);
  {$ENDIF}



end;


procedure TForm2.soenke_urlClick(Sender: TObject);
var website : String;
begin
  openUrl_inBrowser('https://www.soenke-berlin.de');
end;

procedure TForm2.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  soenke_url.font.Color := clblue;
  My_Github_url.Font.color := clblue;
end;

procedure TForm2.My_Github_urlClick(Sender: TObject);
begin
  openUrl_inBrowser('https://github.com/Ydobemos/SimpleWebserver');
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
 close;
end;

procedure TForm2.My_Github_urlMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  My_Github_url.Font.color := clNavy;
end;

procedure TForm2.soenke_urlMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  soenke_url.Font.color := clNavy;
end;

end.

