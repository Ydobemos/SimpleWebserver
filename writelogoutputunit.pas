unit WriteLogOutputUnit;

//Achtung: Ich mache hier Class Functions, damit man diese Klasse
//ohne Instanzierung aufrufen kann!
//Hier soll geregelt werden, wohin der Output geschrieben werden soll
//Vorerst kann es auf die Anwendungsoberfläche geschrieben werden.
//Für eine Konsolenanwendung kann es auf die Konsole ausgegeben werden.

{$mode Delphi}

interface

uses
  Classes, SysUtils;

type
  WriteLogOutput = class
  public
    class procedure WriteOutput(strToWrite: String);
  end;

implementation
  uses Unit1;


{
  Um es zu benutzen braucht man nur noch diese Unit bei den uses verwenden
  und folgendes schreiben:
  WriteLogOutput.WriteOutput(strForMemo);
  Keine Instanzierung/Objekt-Erstellung nötig!
}
class procedure WriteLogOutput.WriteOutput(strToWrite: String);
begin
   form1.DisplayOnMemo(strToWrite);
end;







end.

