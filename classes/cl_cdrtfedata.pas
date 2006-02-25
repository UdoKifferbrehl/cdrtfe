{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  cl_cdrtfedata.pas: Singleton für einfachen Zugriff auf die Datenobjekte

  Copyright (c) 2006 Oliver Valencia

  letzte Änderung  15.01.2006

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_cdrtfedata.pas implementiert ein Singleton-Objekt, das für einen einfachen
  Zugriff auf die in cdrtfe verwendeten Objekte ermöglicht.

  Verwendung: TCdrtfeData.Instance.SetObjects(...);
              Flang := TCdrtfeData.Instance.Lang;
              

  TCdrtfeData

    Properties   Lang
                 Settings
                 Data

    Methoden     Create
                 Instance: TCdrtfeData
                 ReleaseInstance
                 SetObjects(Lang: TDummy; Settings: TDummy; Data: TDummy)

}

unit cl_cdrtfedata;

{$I directives.inc}

{$J+}

interface

uses SysUtils,
     cl_lang, cl_settings, cl_projectdata;

type TDummy = Integer;

type TCdrtfeData = class(TObject)
     private
       FLang    : TLang;
       FSettings: TSettings;
       FData    : TProjectData;
     protected
       constructor CreateInstance;
       class function AccessInstance(Request: Integer): TCdrtfeData;
     public
       constructor Create;
       destructor Destroy; override;
       class function Instance: TCdrtfeData;
       class procedure ReleaseInstance;
       procedure SetObjects(Lang: TLang; Settings: TSettings; Data: TProjectData);
       property Lang: TLang read FLang;
       property Settings: TSettings read FSettings;
       property Data: TProjectData read FData;
     end;

implementation

{ TCdrtfeData ---------------------------------------------------------------- }

{ TCdrtfeData - private }

{ TCdrtfeData - protected }

constructor TCdrtfeData.CreateInstance;
begin
  inherited Create;
end;

class function TCdrtfeData.AccessInstance(Request: Integer): TCdrtfeData;
const FInstance: TCdrtfeData = nil;
begin
  case Request of
    0: ;
    1: if not Assigned(FInstance) then FInstance := CreateInstance;
    2: FInstance := nil;
  else
    raise Exception.CreateFmt('Illegal request %d in AccesInstance!',
                              [Request]);
  end;
  Result := FInstance;
end;

{ TCdrtfeData - public }

constructor TCdrtfeData.Create;
begin
  inherited Create;
  raise Exception.CreateFmt('Access class %s through instance only!',
                            [ClassName]);
end;

destructor TCdrtfeData.Destroy;
begin
  if AccessInstance(0) = Self then AccessInstance(2);
  inherited Destroy;
end;

class function TCdrtfeData.Instance: TCdrtfeData;
begin
  Result := AccessInstance(1);
end;

class procedure TCdrtfeData.ReleaseInstance;
begin
  AccessInstance(0).Free;
end;

procedure TCdrtfeData.SetObjects(Lang: TLang; Settings: TSettings;
                                 Data: TProjectData);
begin
  FLang     := Lang;
  FSettings := Settings;
  FData     := Data;
end;


procedure ReleaseCdrtfeData;
begin
  TCdrtfeData.ReleaseInstance;
end;


initialization

finalization
  ReleaseCdrtfeData;

end.
