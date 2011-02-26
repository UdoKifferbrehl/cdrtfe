{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_environment.pas: Objekt für Umgebungsdaten

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  16.05.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_environment.pas implemtiert ein Objekt für die Umgebungsdaten.


  TEnvironment

    Properties   ProDVDKey       : string
                 EnvironmentSize : Integer
                 ProcessRunning  : Boolean

    Variablen    EnvironmentBlock: Pointer

    Methoden     Init

}

unit cl_settings_environment;

interface

uses cl_abstractbase;

type TEnvironment = class(TCdrtfeData)
     private
       FProDVDKey       : string;
       FEnvironmentSize : Integer;
       FProcessRunning  : Boolean;
     public
       EnvironmentBlock: Pointer;
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       property ProDVDKey       : string read FProDVDKey write FProDVDKey;
       property EnvironmentSize : Integer read FEnvironmentSize write FEnvironmentSize;
       property ProcessRunning  : Boolean read FProcessRunning write FProcessRunning;
     end;

implementation

{ TEnvironment -------------------------------------------------------------- }

{ TEnvironment - private }

{ TEnvironment - public }

constructor TEnvironment.Create;
begin
  inherited Create;
  Init;
end;

destructor TEnvironment.Destroy;
begin
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TEnvironment.Init;
begin
  FProDVDKey        := '';
  EnvironmentBlock := nil;
  FEnvironmentSize  := 0;
  FProcessRunning   := False;
end;

end.
