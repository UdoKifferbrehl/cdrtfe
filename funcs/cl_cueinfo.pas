{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_cueinfo.pas: Infos über Cue-Dateien

  Copyright (c) 2007 Oliver Valencia

  letzte Änderung  24.07.2007

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_cueinfo.pas implementiert ein Objekt, das Informationen über Cue-Dateien
  ermittelt:
    * Audio-Tracks


  TCueFile

    Properties   Name
                 IsAudio
                 CompressedFilesPresent
                 CueOk

    Methoden     Create
                 GetInfo
                 
}

unit cl_cueinfo;

{$I directives.inc}

interface

uses Windows, Classes, SysUtils,
     cl_settings, cl_lang;

type TCueFile = class(TObject)
     private
       FFileName              : string;
       FTempFileName          : string;
       FSettings              : TSettings;
       FLang                  : TLang;
       FCueFile               : TStringList;
       FTempCueFile           : TStringList;
       FTempFiles             : TStringList;
       FCommandLines          : string;
       FIsAudio               : Boolean;
       FCompressedFilesPresent: Boolean;
       FMP3                   : Boolean;
       FOgg                   : Boolean;
       FFlac                  : Boolean;
       FApe                   : Boolean;
       FCueOk                 : Boolean;
       function GetIsAudio: Boolean;
       function GetCompressedFilesPresent: Boolean;
       function GetCueOk: Boolean;
       procedure AddCommandLine(const Source, Target: string);
       procedure CreateTempCueFile;
     public
       constructor Create(const CueFile: string);
       destructor Destroy; override;
       procedure GetInfo;
       procedure SaveTempCueFile;
       property IsAudio: Boolean read FIsAudio;
       property CompressedFilesPresent: Boolean read FCompressedFilesPresent;
       property Settings: TSettings read FSettings write FSettings;
       property Lang: TLang read FLang write FLang;
       property TempFiles: TStringList read FTempFiles;
       property CommandLines: string read FCommandLines;
       property TempFileName: string read FTempFileName;
       property CueOk: Boolean read FCueOk;
     end;

implementation

uses {$IFDEF WriteLogFile} f_logfile, {$ENDIF}
     constant, f_strings, f_filesystem, f_misc;

{ TCueFile ------------------------------------------------------------------- }

{ TCueFile - private }

{ GetIsAudio -------------------------------------------------------------------

  True, wenn Cue-Sheet Audio-Tracks enthält, False sonst.                      }

function TCueFile.GetIsAudio: Boolean;
begin
  Result := (Pos('audio', FCueFile.Text) > 0) or
            (Pos('AUDIO', FCueFile.Text) > 0);
end;

{ GetCompressedFilesPresent ----------------------------------------------------

  True, wenn komprimierte Audio-Tracks vorhanden sind, False sonst.            }

function TCueFile.GetCompressedFilesPresent: Boolean;
var Temp: string;
begin
  Temp := LowerCase(FCueFile.Text);
  Result := (Pos(cExtMp3, Temp) > 0) or
            (Pos(cExtOgg, Temp) > 0) or
            (Pos(cExtFlac, Temp) > 0) or
            (Pos(cExtApe, Temp) > 0);
end;

{ AddCommandLine ---------------------------------------------------------------

 fügt an FCommandLine eine Kommandozeile zum Dekoieren hinzu.                  }

procedure TCueFile.AddCommandLine(const Source, Target: string);
var CmdTemp: string;
    Ext    : string;
begin
  CmdTemp := '';
  Ext := LowerCase(ExtractFileExt(Source));
  if (Ext <> cExtWav) then
  begin
    if (Ext = cExtMP3) then
    begin
      FMP3 := True;
      CmdTemp := StartUpDir + cMadplayBin +
                 ' -v -S -b 16 -R 44100 -o wave:' +
                 QuotePath(Target) + ' ' + QuotePath(Source) + CR
    end else
    if (Ext = cExtOgg) then
    begin
      FOgg := True;
      CmdTemp := StartUpDir + cOggdecBin + ' -b 16 -o ' +
                 QuotePath(Target) + ' ' + QuotePath(Source) + CR
    end else
    if (Ext = cExtFlac) then
    begin
      FFlac := True;
      CmdTemp := StartUpDir + cFLACBin + ' -d ' + QuotePath(Source) +
                 ' -o ' + QuotePath(Target) + CR
    end else
    if (Ext = cExtApe) then
    begin
      FApe := True;
      CmdTemp := StartUpDir + cMonkeyBin + ' ' + QuotePath(Source) + ' ' +
                 QuotePath(Target) + ' -d' + CR
    end;
  end;
  FCommandLines := FCommandLines + CmdTemp;
end;

{ CreateTempCueFile ------------------------------------------------------------

  erzeugt ein temporäres Cue-Sheet mit angepaßten FILE-Einträgen.              }

procedure TCueFile.CreateTempCueFile;
var i       : Integer;
    Temp    : string;
    Name    : string;
    p, q    : Integer;
    Quoted  : Boolean;
    Source  : string;
begin
  FTempCueFile.Assign(FCueFile);
  for i := 0 to FTempCueFile.Count - 1 do
  begin
    Temp := FTempCueFile[i];
    if Pos('FILE', Trim(Temp)) = 1 then
    begin
      p := Pos(' ', Temp) + 1;
      q := LastDelimiter(' ', Temp) - 1;
      Name := Copy(Temp, p, q - p + 1);
      Delete(Temp, p, q - p + 1);
      Quoted := IsQuoted(Name);
      if Quoted then Name := UnQuote(Name);
      if LowerCase(ExtractFileExt(Name)) <> cExtWav then
      begin
        Source := Name;
        Name := FSettings.General.TempFolder + '\' +
                ExtractFileName(Name) + cExtWav;
        FTempFiles.Add(Name);
        AddCommandLine(Source, Name);
        if Quoted then Name := QuotePath(Name); 
        Insert(Name, Temp, p);
        FTempCueFile[i] := Temp;
      end;
    end;
  end;
  {$IFDEF WriteLogFile}
  AddLogCode(1270);
  AddLog(FTempCueFile.Text, 3);
  AddLog(' ', 3);
  AddLog(FTempFiles.Text, 3);
  AddLog(' ', 3);
  AddLog(FCommandLines, 3);
  {$ENDIF}
end;

{ GetCueOk ---------------------------------------------------------------------

  prüft, ob die komprimierten Formate unterstützt werden, wenn nicht wird
  eine Fehlermeldung ausgegeben und FCueOk auf False gesetzt.                  }

function TCueFile.GetCueOk: Boolean;
var Temp: string;
begin
  Result := True;
  if FMP3 and not FSettings.FileFlags.MadplayOk then
  begin
    Result := False;
    Temp := FLang.GMS('minit09');
  end else
  if FOgg and not FSettings.FileFlags.OggdecOk then
  begin
    Result := False;
    Temp := FLang.GMS('minit10')
  end else
  if FFlac and not FSettings.FileFlags.FLACOk then
  begin
    Result := False;
    Temp := FLang.GMS('minit11')
  end else
  if FApe and not FSettings.FileFlags.MonkeyOk then
  begin
    Result := False;
    Temp := FLang.GMS('minit12')
  end;
  if not Result then
  begin
    ShowMsgDlg(Temp, FLang.GMS('g001'), MB_OK or MB_ICONWARNING);
  end;
end;

{ TCueFile - public }

constructor TCueFile.Create(const CueFile: string);
begin
  FFileName := CueFile;
  FCueFile := TStringList.Create;
  FTempCueFile := TSTringList.Create;
  FTempFiles := TSTringList.Create;
  FCommandLines := '';
  FTempFileName := '';
  FIsAudio := False;
  FMp3 := False;
  FOgg := False;
  FFlac := False;
  FApe := False;
  FCueOk := True;
end;

destructor TCueFile.Destroy;
begin
  FCueFile.Free;
  FTempCueFile.Free;
  FTempFiles.Free;
end;

{ GetInfo ----------------------------------------------------------------------

  lädt die Cue-Datei und ermittelt die Informationen.                          }

procedure TCueFile.GetInfo;
begin
  if FileExists(FFileName) then
  begin
    FCueFile.LoadFromFile(FFileName);
    FIsAudio := GetIsAudio;
    FCompressedFilesPresent := GetCompressedFilesPresent;
    if FCompressedFilesPresent then
    begin
      CreateTempCueFile;
      FCueOk := GetCueOk;
    end;
  end;
end;

{ SaveTempCueFile --------------------------------------------------------------

  speichert das temporäre Cue-Sheet.                                           }

procedure TCueFile.SaveTempCueFile;
var Name: string;
begin
  if FCueOk then
  begin
    Name := FFileName;
    Insert('.tmp', Name, LastDelimiter('.', Name));
    FTempFiles.Add(Name);
    FTempCueFile.SaveToFile(Name);
    FTempFileName := Name;
  end;
end;

end.
