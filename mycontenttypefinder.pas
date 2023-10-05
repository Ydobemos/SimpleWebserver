unit MyContentTypeFinder;

{$mode Delphi}

interface

uses
  Classes, SysUtils;

type
  ContentTypeFinder = class
  public
    class function whatContentType(datei: String): String;
  end;


implementation



//Eine einfache übersicht der mime types findet man hier:
//http://svn.apache.org/viewvc/httpd/httpd/trunk/docs/conf/mime.types?&view=co
//
//Die Content Types könnten vielleicht in eine extra Datei (ini-Datei o.ä.) ausgelagert werden, so dass der User diese auch selber einstellen und ergänzen kann.
//Zudem könnte es hier Übersichtlicher werden.
class function ContentTypeFinder.whatContentType(datei: String): String;
var position :Integer;      //intTemp
    text:String;
begin
  position:=0;
  position:=pos('.',datei);

  (*    //Alte Version. Unschön und bei Punkten im Dateinamen fehleranfällig!
  inttemp:=length(datei)-position;
  //text := Copy(datei, position,inttemp+1);      //.html
  text := Copy(datei, position+1,inttemp);        //html
  //in text ist nun die dateiendung drin
  *)
  //Kürzer und schöner mit Board-mitteln:
  text := ExtractFileExt(datei);          //Dateiendung holen
  text := Copy(text, 2,length(text)-1 );  //Den Punkt vor der Dateiendung entfernen. Dafür alles hinter dem Punkt kopieren

  text:=lowercase(text);
  //in text ist nun die Dateiendung drin

  if position=0 then //hat keine datei endung, also nicht zuordbar...
  begin
    result:='application/unknown';
    exit;                               //Hier erfolgt ein exit, da wir den restlichen code nicht mehr durchgehen müssen, result wird dennoch zurückgegeben -> Zeitersparnis
  end;


  if (text='html') or (text='htm') then
  begin
    result:='text/html';
    exit;
  end;

  //Content-Type: text/plain
  if (text='txt') then
  begin
    result:='text/plain';
    exit;
  end;

  //Content-Type: image/x-icon
  if (text='ico') then
  begin
    result:='image/x-icon';
    exit;
  end;

  //Content-Type: application/x-javascript
  if (text='js') then
  begin
    result:='application/x-javascript';
    exit;
  end;


  //Content-Type: application/x-shockwave-flash
  if (text='json') then
  begin
    result:='application/json';
    exit;
  end;


  //Content-Type: application/x-shockwave-flash
  if (text='swf') then
  begin
    result:='application/x-shockwave-flash';
    exit;
  end;

  //Content-Type: image/svg+xml
  if text='svg' then
  begin
    result:='image/svg+xml';
    exit;
  end;


  if (text='pdf') or (text='xml') or (text='zip') then
  begin                                 //Content-Type: application/xml
    result:='application/'+text;        //Content-Type: application/pdf
    exit;                               //Content-Type: application/zip
  end;


  if (text='exe') or (text='dll') or (text='com') or (text='bat') or (text='msi') then
  begin
    result:='application/x-msdownload';
    exit;
  end;


  if text='7z' then
  begin
    result:='application/x-7z-compressed';
    exit;
  end;

  if text='tar' then
  begin
    result:='application/x-tar';
    exit;
  end;

  if text='bz' then
  begin
    result:='application/x-bzip';
    exit;
  end;

  if (text='bz2') or (text='boz') then
  begin
    result:='application/x-bzip2';
    exit;
  end;

  if text='rar' then
  begin
    result:='application/x-rar-compressed';
    exit;
  end;


  //Bilddateien
  if (text='jpg') or (text='jpeg') or (text='gif') or (text='png') or (text='bmp') or (text='jpe')or (text='dip') or (text='tif')  or (text='tiff') then      //or (text='svg')
  begin
    result:='image/'+text;
    exit;
  end;

  //Musikdateien

  if (text='m4a') or (text='mp4a') then
  begin
    result:='audio/mp4';
    exit;
  end;

  if (text='mp3') or (text='mpga') or (text='mp2') or (text='mp2a') or (text='m2a') or (text='m3a') then
  begin
    result:='audio/mpeg';
    exit;
  end;

  if (text='ogg') or (text='oga') or (text='spx') or (text='opus') then
  begin
    result:='audio/ogg';
    exit;
  end;

  if (text='wma') or (text='wav') or (text='mka') then
  begin
    result:='audio/'+text;
    exit;
  end;
  //Hier wurden die Audioformate einfach zusammen geführt/gefügt. Eine bessere abtrennung bzw genauere Bezeichnung der Mime typen wäre möglich.
  //ggf ein ToDo...


  //weitere video formate: mkv, .mpg, .mpeg, .ps .ts, .tsp   (.vob) .evo .flv          (.rm, .ra) ist ein Container für RealAudio- und RealVideo-Streams und wird hier nicht abgedeckt!
  if (text='avi') or (text='divx') or (text='mpeg') or (text='mpg') or (text='wmv') or (text='flv') then         //video/flv
  begin
    result:='video/'+text;
    exit;
  end;
  //Anmerkung: Einige Video formate wurden hier angepasst, da es nicht so wichtig ist:
  //           Für flv wäre es eigtl: video/x-flv
  //           wmv wäre video/x-ms-wmv
  //           mpg wäre video/mpeg
  //           avi wäre video/x-msvideo


  if (text='mkv') or (text='mk3d') or (text='mks') then
  begin
    result:='video/x-matroska';
    exit;
  end;


  if (text='mp4') or (text='mp4v') or (text='mpg4') then
  begin
    result:='video/mp4';
    exit;
  end;

  if (text='mov') or (text='qt')  then
  begin
    result:='video/quicktime';
    exit;
  end;

  if (text='ogv')   then
  begin
    result:='video/ogg';
    exit;
  end;


  if text='pub' then
  begin
    result:='application/x-mspublisher';
    exit;
  end;




  //Der Content-Type wurde nicht weiter ermittelt? Dann sende die Dateiendung einfach als application Type...
  result:='application/'+text;
end;








end.

