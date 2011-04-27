{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_fileexplorer.pas: Objekt für FileExplorer-Einstellungen

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  19.10.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_fileexplorer.pas implemtiert ein Objekt für die Fensterposition
  und -größe.


  TFileExplorer

    Properties   Showing      : Boolean;
                 HideLogWindow: Boolean;
                 Path         : string;
                 Height       : Integer;

    Methoden     Init
                 Load(MIF: TMemIniFile)
                 Save(MIF: TMemIniFile)

}

unit cl_settings_fileexplorer;

interface

uses IniFiles, cl_abstractbase;

type TFileExplorer = class(TCdrtfeSettings)
     private
       FShowing      : Boolean;
       FHideLogWindow: Boolean;
       FPath         : string;
       FHeight       : Integer;
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       procedure Load(MIF: TMemIniFile); override;
       procedure Save(MIF: TMemIniFile); override;
       property Showing: Boolean read FShowing write FShowing;
       property HideLogWindow: Boolean read fHideLogWindow write FHideLogWindow;
       property Path   : string read FPath write FPath;
       property Height : Integer read FHeight write FHeight;
     end;

implementation

{ TFileExplorer -------------------------------------------------------------- }

{ TFileExplorer - private }

{ TFileExplorer - public }

constructor TFileExplorer.Create;
begin
  inherited Create;
  Init;
end;

destructor TFileExplorer.Destroy;
begin
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TFileExplorer.Init;
begin
  FHeight := 192;
  FShowing := False;
  FHideLogWindow := False;
  FPath := '';
end;

{ Load -------------------------------------------------------------------------

  Variablen aus der Ini- bzw. cfp-Datei laden.                                 }

procedure TFileExplorer.Load(MIF: TMemIniFile);
var Section : string;
begin
  Section := 'FileExplorer';
  with MIF do
  begin
    FShowing := ReadBool(Section, 'Showing', False);
    FHideLogWindow := ReadBool(Section, 'HideLogWindow', False);
    FPath := ReadString(Section, 'Path', '');
//  FHeight := ReadInteger(Section, 'Height', 192);
  end;
end;

{ Save -------------------------------------------------------------------------

  Variablen in einer Ini- bzw. cfp-Datei speichern.                            }

procedure TFileExplorer.Save(MIF: TMemIniFile);
var Section : string;
begin
  Section := 'FileExplorer';
  with MIF do
  begin
    WriteBool(Section, 'Showing', FShowing);
    WriteBool(Section, 'HideLogWindow', FHideLogWindow);
    WriteString(Section, 'Path', FPath);
//  WriteInteger(Section, 'Height', FHeight);
  end;
end;

end.

