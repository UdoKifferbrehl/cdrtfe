{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_audiocd.pas: Objekt für Einstellungen des Audio-CD-Projektes

  Copyright (c) 2004-2015 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  06.05.2015

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_audiocd.pas implemtiert ein Objekt für die Einstellungen des
  Projektes Audio-CD.

    Achtung: Nach dem Laden muß ReplayGain in Abhängigkeit einiger FileFlags
             gesetzt werden!


  TSettingsAudioCD

    Properties   Device               : string
                 Speed                : string
                 Multi                : Boolean
                 Fix                  : Boolean
                 DAO                  : Boolean
                 TAO                  : Boolean
                 RAW                  : Boolean
                 RAWMode              : string
                 Overburn             : Boolean
                 Preemp               : Boolean
                 Copy                 : Boolean
                 SCMS                 : Boolean
                 UseInfo              : Boolean
                 CDText               : Boolean
                 CDTextFile           : string
                 Pause                : Integer
                 PauseLength          : string
                 PauseSector          : Boolean
                 UTFToAnsi            : Boolean
                 ReplayGain           : Boolean
                 Gain                 : Integer
                 RelaxedFormatChecking: Boolean
                 CustomConvCmdMP3     : string;
                 CustomConvCmdOgg     : string;
                 CustomConvCmdFLAC    : string;
                 CustomConvCmdApe     : string;

    Methoden     Init
                 Load(MIF: TMemIniFile)
                 Save(MIF: TMemIniFile)

}

unit cl_settings_audiocd;

interface

uses IniFiles, cl_abstractbase;

type TSettingsAudioCD = class(TCdrtfeSettings)
     private
       FDevice               : string;
       FSpeed                : string;
       FMulti                : Boolean;
       FFix                  : Boolean;
       FDAO                  : Boolean;
       FTAO                  : Boolean;
       FRAW                  : Boolean;
       FRAWMode              : string;
       FOverburn             : Boolean;
       FPreemp               : Boolean;
       FCopy                 : Boolean;
       FSCMS                 : Boolean;
       FUseInfo              : Boolean;
       FCDText               : Boolean;
       FCDTextFile           : string;
       FPause                : Integer;    // 0 = keine; 1 = für alle gleich; 2 = separat
       FPauseLength          : string;    // Länge in Sekunden bzw. Sektoren
       FPauseSector          : Boolean;    // Länge der Pause in Sektoren
       FUTFToAnsi            : Boolean;
       FReplayGain           : Boolean;
       FGain                 : Integer;
       FRelaxedFormatChecking: Boolean;
       FCustomConvCmdMP3     : string;
       FCustomConvCmdOgg     : string;
       FCustomConvCmdFLAC    : string;
       FCustomConvCmdApe     : string;
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       procedure Load(MIF: TMemIniFile); override;
       procedure Save(MIF: TMemIniFile); override;
       property Device     : string read FDevice write FDevice;
       property Speed      : string read FSpeed write FSpeed;
       property Multi      : Boolean read FMulti write FMulti;
       property Fix        : Boolean read FFix write FFix;
       property DAO        : Boolean read FDAO write FDAO;
       property TAO        : Boolean read FTAO write FTAO;
       property RAW        : Boolean read FRAW write FRAW;
       property RAWMode    : string read FRAWMode write FRAWMode;
       property Overburn   : Boolean read FOverburn write FOverburn;
       property Preemp     : Boolean read FPreemp write FPreemp;
       property Copy       : Boolean read FCopy write FCopy;
       property SCMS       : Boolean read FSCMS write FSCMS;
       property UseInfo    : Boolean read FUseInfo write FUseInfo;
       property CDText     : Boolean read FCDText write FCDText;
       property CDTextFile : string read FCDTextFile write FCDTextFile;
       property Pause      : Integer read FPause write FPause;
       property PauseLength: string read FPauseLength write FPauseLength;
       property PauseSector: Boolean read FPauseSector write FPauseSector;
       property UTFToAnsi  : Boolean read FUTFToAnsi write FUTFToAnsi;
       property ReplayGain : Boolean read FReplayGain write FReplayGain;
       property Gain       : Integer read FGain write FGain;
       property RelaxedFormatChecking: Boolean read FRelaxedFormatChecking write FRelaxedFormatChecking;
       property CustomConvCmdMP3 : string read FCustomConvCmdMP3 write FCustomConvCmdMP3;
       property CustomConvCmdOgg : string read FCustomConvCmdOgg write FCustomConvCmdOgg;
       property CustomConvCmdFLAC: string read FCustomConvCmdFLAC write FCustomConvCmdFLAC;
       property CustomConvCmdApe : string read FCustomConvCmdApe write FCustomConvCmdApe;
     end;

implementation


{ TSettingsAudioCD ----------------------------------------------------------- }

{ TSettingsAudioCD - private }

{ TSettingsAudioCD - public }

constructor TSettingsAudioCD.Create;
begin
  inherited Create;
  Init;
end;

destructor TSettingsAudioCD.Destroy;
begin
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TSettingsAudioCD.Init;
begin
  FDevice                := '';
  FSpeed                 := '';
  FMulti                 := False;
  FFix                   := True;
  FDAO                   := True;
  FTAO                   := False;
  FRAW                   := False;
  FRAWMode               := 'raw96r';
  FOverburn              := False;
  FPreemp                := False;
  FCopy                  := False;
  FSCMS                  := False;
  FUseInfo               := False;
  FCDText                := False;
  FCDTextFile            := '';
  FPause                 := 1;       // für alle Tracks gleiche Pausenlänge
  FPauseLength           := '2';     // Länge 2
  FPauseSector           := False;   // Länge in Sekunden
  FUTFToAnsi             := False;
  FReplayGain            := False;
  FGain                  := 0;
  FRelaxedFormatChecking := False;
  FCustomConvCmdMP3      := '';
  FCustomConvCmdOgg      := '';
  FCustomConvCmdFLAC     := '';
  FCustomConvCmdApe      := '';
end;

{ Load -------------------------------------------------------------------------

  Variablen aus der Ini- bzw. cfp-Datei laden.                                 }

procedure TSettingsAudioCD.Load(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'Audio-CD';
  with MIF do
  begin
    FDevice := ReadString(Section, 'Device', '');
    FSpeed := ReadString(Section, 'Speed', '');
    FMulti := ReadBool(Section, 'Multi', False);
    FFix := ReadBool(Section, 'Fix', True);
    FDAO := ReadBool(Section, 'DAO', False);
    FTAO := ReadBool(Section, 'TAO', True);
    FRAW := ReadBool(Section, 'RAW', False);
    FRAWMode := ReadString(Section, 'RAWMode', 'raw96r');
    FOverburn := ReadBool(Section, 'Overburn', False);
    FPreemp := ReadBool(Section, 'Preemp', False);
    FCopy := ReadBool(Section, 'Copy', False);
    FSCMS := ReadBool(Section, 'SCMS', False);
    FUseInfo := ReadBool(Section, 'UseInfo', False);
    FCDText := ReadBool(Section, 'CDText', False);
    FPause := ReadInteger(Section, 'Pause', 1);
    FPauseLength := ReadString(Section, 'PauseLength', '2');
    FPauseSector := ReadBool(Section, 'PauseSector', False);
    FUTFToAnsi := ReadBool(Section, 'UTFToAnsi', False);
    FReplayGain := ReadBool(Section, 'ReplayGain', False); // and
                  // FileFlags.WavegainOk;
    FGain       := ReadInteger(Section, 'Gain', 0);
    FCustomConvCmdMP3  := ReadString(Section, 'CustomConvCmdMP3', '');
    FCustomConvCmdOgg  := ReadString(Section, 'CustomConvCmdOgg', '');
    FCustomConvCmdFLAC := ReadString(Section, 'CustomConvCmdFLAC', '');
    FCustomConvCmdApe  := ReadString(Section, 'CustomConvCmdApe', '');
    FRelaxedFormatChecking := ReadBool(Section, 'RelaxedFormatChecking', False);
  end;
end;

{ Save -------------------------------------------------------------------------

  Variablen in einer Ini- bzw. cfp-Datei speichern.                            }

procedure TSettingsAudioCD.Save(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'Audio-CD';
  with MIF do
  begin
    WriteString(Section, 'Device', FDevice);
    WriteString(Section, 'Speed', FSpeed);
    WriteBool(Section, 'Multi', FMulti);
    WriteBool(Section, 'Fix', FFix);
    WriteBool(Section, 'DAO', FDAO);
    WriteBool(Section, 'TAO', FTAO);
    WriteBool(Section, 'RAW', FRAW);
    WriteString(Section, 'RAWMode', FRAWMode);
    WriteBool(Section, 'Overburn', FOverburn);
    WriteBool(Section, 'Preemp', FPreemp);
    WriteBool(Section, 'Copy', FCopy);
    WriteBool(Section, 'SCMS', FSCMS);
    WriteBool(Section, 'UseInfo', FUseInfo);
    WriteBool(Section, 'CDText', FCDText);
    WriteInteger(Section, 'Pause', FPause);
    WriteString(Section, 'PauseLength', FPauseLength);
    WriteBool(Section, 'PauseSector', FPauseSector);
    WriteBool(Section, 'UTFToAnsi', FUTFToAnsi);
    WriteBool(Section, 'ReplayGain', FReplayGain);
    WriteInteger(Section, 'Gain', FGain);
    WriteBool(Section, 'RelaxedFormatChecking', FRelaxedFormatChecking);
    WriteString(Section, 'CustomConvCmdMP3', FCustomConvCmdMP3);
    WriteString(Section, 'CustomConvCmdOgg', FCustomConvCmdOgg);
    WriteString(Section, 'CustomConvCmdFLAC', FCustomConvCmdFLAC);
    WriteString(Section, 'CustomConvCmdApe', FCustomConvCmdApe);
  end;
end;

end.

