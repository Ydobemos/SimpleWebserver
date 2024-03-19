unit ServerSettingsSingleton;

{$IFDEF FPC}
{$mode delphi}
{$ENDIF}

interface

uses
  Classes, SysUtils;


type
  TServerSettingsSingleton = class
  private
    FPath: string;
    FPort: Integer;
    FServerIsRunning: Boolean;
    FMaxConnections : Integer;
    FSendIndividualErrorPage: Boolean;
    FIndividualErrorPagePath: string;
    FSendFtpLikeViewOnEmptyDir: Boolean;

    class var FInstance: TServerSettingsSingleton;
    constructor Create;
  public
    class function Instance: TServerSettingsSingleton;
    property WorkingDirectoryPath: string read FPath write FPath;
    property Port: Integer read FPort write FPort;
    property ServerIsRunning: Boolean read FServerIsRunning write FServerIsRunning;
    property MaxConnections: Integer read FMaxConnections write FMaxConnections;
    property SendIndividualErrorPage: Boolean read FSendIndividualErrorPage write FSendIndividualErrorPage;
    property IndividualErrorPagePath: string read FIndividualErrorPagePath write FIndividualErrorPagePath;
    property SendFtpLikeViewOnEmptyDir: Boolean read FSendFtpLikeViewOnEmptyDir write FSendFtpLikeViewOnEmptyDir;
  end;

implementation




constructor TServerSettingsSingleton.Create;
begin
  inherited;
  // Initialisiere hier die Standardwerte
  FPath := '';
  FPort := 0;
  FServerIsRunning := false;
  FMaxConnections := 20;
  FSendIndividualErrorPage := false;
  FIndividualErrorPagePath := '';
  FSendFtpLikeViewOnEmptyDir := false;
end;

class function TServerSettingsSingleton.Instance: TServerSettingsSingleton;
begin
  if not Assigned(FInstance) then
    FInstance := TServerSettingsSingleton.Create;
  Result := FInstance;
end;

initialization

finalization
  FreeAndNil(TServerSettingsSingleton.FInstance);





end.

