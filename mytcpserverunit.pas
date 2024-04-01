unit MyTCPServerUnit;

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
  //My Singleton Class to Save all the Settings and make it available for everyone
  ServerSettingsSingleton;

type
  TMyTCPServer = class
  private
    FIdTCPServer: TIdTCPServer;
    //////My callback functions
    procedure IdTCPServerDisconnect(AContext: TIdContext);
    procedure IdTCPServerExecute(AContext: TIdContext);
    procedure IdTCPServerStatus(ASender: TObject; const AStatus: TIdStatus;
                                    const AStatusText: string);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure StartServer;
    procedure StopServer;
    procedure ClearBindings;
    procedure SetServerPort;
    procedure SetMaxConnections;
  end;

//var IdTCPServer : TIdTCPServer;

implementation
    uses WriteLogOutputUnit, HTTPGetHandling;


constructor TMyTCPServer.Create(AOwner: TComponent);
begin
  inherited Create;

  //Let's create idTCPServer
  FIdTCPServer                 := TIdTCPServer.Create(AOwner);//TIdTCPServer.Create(self);
  FIdTCPServer.Active          := False;

  //adding my callback functions:
  FIdTCPServer.OnDisconnect    := IdTCPServerDisconnect;
  FIdTCPServer.OnExecute       := IdTCPServerExecute;
  FIdTCPServer.OnStatus        := IdTCPServerStatus;

end;



destructor TMyTCPServer.Destroy;
begin
  FIdTCPServer.Free;
  inherited;
end;



procedure TMyTCPServer.StartServer;
begin
  FIdTCPServer.Active := True;
end;



procedure TMyTCPServer.StopServer;
begin
  FIdTCPServer.Active := False;
end;



procedure TMyTCPServer.ClearBindings;
begin
  // clearing the bindings property (socket handles )
  FIdTCPServer.Bindings.Clear;
end;



procedure TMyTCPServer.SetServerPort;
begin
    // Port hinzufügen:
    FIdTCPServer.Bindings.Add.Port := TServerSettingsSingleton.Instance.Port;
end;



procedure TMyTCPServer.SetMaxConnections;
begin
    // MaxConnections hinzufügen:
    FIdTCPServer.MaxConnections  := TServerSettingsSingleton.Instance.MaxConnections;
end;



// .............................................................................



// *****************************************************************************
//   EVENT : onExecute()
//           ON EXECUTE THREAD CLIENT
// *****************************************************************************
procedure TMyTCPServer.IdTCPServerExecute(AContext: TIdContext);
var
    PeerPort: Integer;
    BufferAsBytes: TIdBytes;    //The TIdBytes type is declared in the IdGlobal unit.
    Text: string;
    fromIp, fromPort, strForMemo: String;
    i, posi, laenge, position: integer;
begin
    BufferAsBytes := nil;
    Text := '';

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

    if length(Text) > 0 then
    begin
        if AContext.Connection.IOHandler.Connected then
        begin
          AContext.Connection.IOHandler.DefStringEncoding := IndyTextEncoding_UTF8;   //Direkt auf utf8 stellen, damit ich es später nicht immer wieder machen muss...

          //Wir lesen noch die IP und den Port aus, der sich verbindet:
          fromIp    := AContext.Binding.PeerIP;
          peerPort  := AContext.Binding.PeerPort;
          fromPort  := IntToStr(PeerPort);  //Direkt als string umwandeln, damit wir es später einfacher benutzen könenn

          strForMemo := DatetoStr(now) + ' - ' + Timetostr(now)+' Verbindung mit: IP '+ fromIp + ' und Port: '+ fromPort + #13+#10;
          strForMemo :=  strForMemo + 'HTTP-Request:' +#13+#10 + #13+#10;   ;
          strForMemo :=  strForMemo +  Text ;
          WriteLogOutput.WriteOutput(strForMemo);

           //Check for Get and send the Response\\
          THTTPGetHandling.CheckForGetAndSendResponse(AContext, Text);

        end;
    end;

end;
// .............................................................................



// *****************************************************************************
//   EVENT : onStatus()
//           ON STATUS CONNECTION
// *****************************************************************************
procedure TMyTCPServer.IdTCPServerStatus(ASender: TObject; const AStatus: TIdStatus;
                                     const AStatusText: string);
begin
    // ... OnStatus is a TIdStatusEvent property that represents the event handler
    //     triggered when the current connection state is changed...

    //Maybe in Statusbar
    //StatusBar1.Panels[0].text := AStatusText
end;
// .............................................................................



// *****************************************************************************
//   EVENT : onDisconnect()
//           OCCURS ANY TIME A CLIENT IS DISCONNECTED
// *****************************************************************************
procedure TMyTCPServer.IdTCPServerDisconnect(AContext: TIdContext);
{var
    ip          : string;
    port        : Integer;
    fromIp      : string;
    peerPort    : Integer;
    strForMemo : String;   }
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



end.

