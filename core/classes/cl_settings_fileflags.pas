{ $Id: cl_settings_fileflags.pas,v 1.2 2010/10/11 16:23:23 kerberos002 Exp $
 
  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_fileflags.pas: Objekt für Flags bzgl. der Tools

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  11.10.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_fileflags.pas implemtiert ein Objekt für die Flags bezüglich der
  Kommandozeilentools (Vorhandensein, ...).


  TFileFlags

    Properties   Mingw      : Boolean
                 IniFileOk  : Boolean
                 CygwinOk   : Boolean
                 CdrtoolsOk : Boolean
                 VerInfoOk  : Boolean
                 CdrdaoOk   : Boolean
                 Cdda2wavOk : Boolean
                 ReadcdOk   : Boolean
                 ISOInfoOk  : BOolean
                 ShOk       : Boolean
                 ShNeeded   : Boolean
                 UseSh      : Boolean
                 M2CDMOk    : Boolean
                 VCDImOk    : Boolean
                 ShlExtDllOk: Boolean
                 ProDVD     : Boolean
                 MPG123Ok   : Boolean
                 OggdecOk   : Boolean
                 OggencOk   : Boolean
                 FLACOk     : Boolean
                 LameOk     : Boolean
                 MonkeyOk   : Boolean
                 WaveGainOk : Boolean
                 RrencOk    : Boolean
                 RrdecOk    : Boolean
                 MPlayerOk  : Boolean
                 UseOwnDLLs : Boolean
                 CygInPath  : Boolean

    Methoden     Init

}

unit cl_settings_fileflags;

interface

uses cl_abstractbase;

type TFileFlags = class(TCdrtfeData)
     private
       FMingw      : Boolean;    // Mingw32-Port der cdrtools
       FIniFileOk  : Boolean;
       FCygwinOk   : Boolean;    // cygwin1.dll
       FCdrtoolsOk : Boolean;    // cdrecord.exe, mkisofs.exe
       FVerInfoOk  : Boolean;    // cdrecord -version, mkisofs -version
       FCdrdaoOk   : Boolean;
       FCdda2wavOk : Boolean;
       FReadcdOk   : Boolean;
       FISOInfoOk  : BOolean;
       FShOk       : Boolean;
       FShNeeded   : Boolean;
       FUseSh      : Boolean;
       FM2CDMOk    : Boolean;
       FVCDImOk    : Boolean;
       FShlExtDllOk: Boolean;
       FProDVD     : Boolean;
       FMPG123Ok   : Boolean;
       FOggdecOk   : Boolean;
       FOggencOk   : Boolean;
       FFLACOk     : Boolean;
       FLameOk     : Boolean;
       FMonkeyOk   : Boolean;
       FWavegainOk : Boolean;
       FRrencOk    : Boolean;
       FRrdecOk    : Boolean;
       FMPlayerOk  : Boolean;
       FUseOwnDLLs : Boolean;
       FCygInPath  : Boolean;    // cygwin1.dll found in searchpath
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       property Mingw      : Boolean read FMingw write FMingw;
       property IniFileOk  : Boolean read FIniFileOk write FIniFileOk;
       property CygwinOk   : Boolean read FCygwinOk write FCygwinOk;
       property CdrtoolsOk : Boolean read FCdrtoolsOk write FCdrtoolsOk;
       property VerInfoOk  : Boolean read FVerInfoOk write FVerInfoOk;
       property CdrdaoOk   : Boolean read FCdrdaoOk write FCdrdaoOk;
       property Cdda2wavOk : Boolean read FCdda2wavOk write FCdda2wavOk;
       property ReadcdOk   : Boolean read FReadcdOk write FReadcdOk;
       property ISOInfoOk  : BOolean read FISOInfoOk write FISOInfoOk;
       property ShOk       : Boolean read FShOk write FShOk;
       property ShNeeded   : Boolean read FShNeeded write FShNeeded;
       property UseSh      : Boolean read FUseSh write FUseSh;
       property M2CDMOk    : Boolean read FM2CDMOk write FM2CDMOk;
       property VCDImOk    : Boolean read FVCDImOk write FVCDImOk;
       property ShlExtDllOk: Boolean read FShlExtDllOk write FShlExtDllOk;
       property ProDVD     : Boolean read FProDVD write FProDVD;
       property MPG123Ok   : Boolean read FMPG123Ok write FMPG123Ok;
       property OggdecOk   : Boolean read FOggdecOk write FOggdecOk;
       property OggencOk   : Boolean read FOggencOk write FOggencOk;
       property FLACOk     : Boolean read FFLACOk write FFLACOk;
       property LameOk     : Boolean read FLameOk write FLameOk;
       property MonkeyOk   : Boolean read FMonkeyOk write FMonkeyOk;
       property WaveGainOk: Boolean read FWaveGainOk write FWaveGainOk;
       property RrencOk    : Boolean read FRrencOk write FRrencOk;
       property RrdecOk    : Boolean read FRrdecOk write FRrdecOk;
       property MPlayerOk  : Boolean read FMplayerOk write FMplayerOk;
       property UseOwnDLLs : Boolean read FUseOwnDLLs write FUseOwnDLLs;
       property CygInPath  : Boolean read FCygInPath write FCygInPath;
     end;

implementation

{ TFileFlags ----------------------------------------------------------------- }

{ TFileFlags - private }

{ TFileFlags - public }

constructor TFileFlags.Create;
begin
  inherited Create;
  Init;
end;

destructor TFileFlags.Destroy;
begin
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TFileFLags.Init;
begin
  FMingw       := False;
  FIniFileOk   := True;
  FCygwinOk    := True;
  FCdrtoolsOk  := True;
  FVerInfoOk   := True;
  FCdrdaoOk    := True;
  FCdda2wavOk  := True;
  FReadcdOk    := True;
  FISOInfoOk   := True;
  FShOk        := True;
  FShNeeded    := True;
  FUseSh       := True;
  FM2CDMOk     := True;
  FVCDImOk     := True;
  FShlExtDllOk := True;
  FProDVD      := False;
  FMPG123OK    := True;
  FLameOk      := True;
  FOggdecOk    := True;
  FOggencOk    := True;
  FFLACOk      := True;
  FMonkeyOk    := True;
  FWaveGainOk  := True;
  FRrencOk     := True;
  FRrdecOk     := True;
  FMPlayerOk   := True;
  FUseOwnDLLs  := True;
  FCygInPath   := False;
end;

end.
