program project1;

{$IFDEF FPC}
//{$mode objfpc}{$H+}
{$mode delphi} {$H+}
{$ENDIF}


uses
  {$DEFINE UseCThreads}   //Für IdTCPServer auf Linux brauchen wir cthreads, also hier aktrivieren!
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, indylaz, Unit1, Unit2
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='Simple Webserver';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.

