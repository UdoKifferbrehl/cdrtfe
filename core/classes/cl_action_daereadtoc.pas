{ $Id: cl_action_daereadtoc.pas,v 1.2 2010/07/05 12:34:52 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_action_daereadtoc.pas: TOC einer Audio-CD

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  04.07.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_action_daereadtoc.pas implementiert das Objekt, das die TOC einer Audio-CD
  ausliest.

  TCdrtfeActionErase ist ein Objekt, das die Kommandozeilen für das Auslesen der
  TOC einer Audio-CD erstellt und ausführt.


  TCdrtfeActionDAEReadTOC

    Properties   x

    Methoden     AbortAction
                 CleanUp(const Phase: Byte)
                 Reset
                 StartAction

}

unit cl_action_daereadtoc;

{$I directives.inc}

interface

uses Windows, Classes, SysUtils, cl_actionthread, cl_abstractbaseaction;

type TCdrtfeActionDAEReadTOC = class(TCdrtfeAction)
     private
       procedure DAEReadTOC;
       procedure ExtractTrackInfo(List: TStringList);
     protected
     public
       constructor Create;
       procedure CleanUp(const Phase: Byte); override;
       procedure Reset; override;
       procedure StartAction; override;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     f_strings, f_locations, const_locations, f_helper, f_dischelper,
     f_getdosoutput, f_window, const_tabsheets, const_common;

{ TCdrtfeActionDAEReadTOC ---------------------------------------------------- }

{ TCdrtfeActionDAEReadTOC - private }

{ ExtractTrackInfo -------------------------------------------------------------

  ExtractTrackInfo baut die einzelnen Zeilen der cdda2wav-Ausgabe um.          }

procedure TCdrtfeActionDAEReadTOC.ExtractTrackInfo(List: TStringList);
var i            : Integer;
    Temp         : string;
    p            : Integer;
    Seconds      : Double;
    Sectors      : Integer;
    Size         : Double;
    APerformer   : string;
    Performer    : string;
    Title        : string;
    NameString   : string;
    SizeString   : string;
    TimeString   : string;
    HiddenTrckOff: Integer;
begin
  FSettings.DAE.HiddenTrack := False;
  HiddenTrckOff := 0; // bei hidden tracks verschieben sich die Indizes um 1
  {Album-Performer}
  Temp := List.Text;
  Delete(Temp, 1, Pos('Album title:', Temp));
  Temp := Trim(Copy(Temp, 1, Pos(CR, Temp)));
  Delete(Temp, 1, Pos('from', Temp) + 4);
  APerformer := UnescapeString(Temp);
  {$IFDEF DebugReadAudioTOC}
  FormDebug.Memo1.Lines.Add(APerformer);
  FormDebug.Memo1.Lines.Add('');
  {$ENDIF}
  {Alles Löschen, was keine Trackinfos sind.}
  for i := List.Count - 1 downto 0 do
  begin
    FSettings.DAE.HiddenTrack := FSettings.DAE.HiddenTrack or
                                                   (Pos('T00:', List[i]) > 0);
    if not ((Pos('T', List[i]) = 1) and (Pos(':', List[i]) = 4)) or
       (Pos('audio', List[i]) = 0) then
    begin
      List.Delete(i);
    end
  end;
  if FSettings.DAE.HiddenTrack then HiddenTrckOff := 1;
  {$IFDEF DebugReadAudioTOC}
  AddCRStringToList(Output.Text, FormDebug.Memo1.Lines);
  FormDebug.Memo1.Lines.Add('');
  {$ENDIF}
  {Für jeden Track die Infos zusammenstellen.}
  for i := 0 to List.Count - 1 do
  begin
    {Laufzeit}
    TimeString := Trim(Copy(List[i], 13, 9));
    Temp := TimeString;
    p := Pos(':', Temp);
    Seconds := StrToIntDef(Copy(Temp, 1, p - 1), 0) * 60;
    Delete(Temp, 1, p);
    p := Pos('.', Temp);
    Seconds := Seconds + StrToIntDef(Copy(Temp, 1, p - 1), 0);
    {Größe}
    Delete(Temp, 1, p);
    Sectors := StrToIntDef(Temp, 0);
    Size := (((Seconds * 75) + Sectors) * 2352) / 1024;
    SizeString := FormatFloat('#,###,##0 KiByte', Size);
    {Titel und Interpret}
    Temp := List[i];
    p := Pos('title', Temp);
    Delete(Temp, 1, p + 5);
    p := Pos('from', Temp);
    Title := UnescapeString(Copy(Temp, 1, p - 2));
    Delete(Temp, 1, p + 4);
    Performer := UnescapeString(Trim(Temp));
    if (Performer = '') and (Title <> '') then Performer := APerformer;
    {Trackname}
    NameString := Format('Track %.2d', [i + 1 - HiddenTrckOff]);
    {Neuen Eintrag zusammenstellen.}
    List[i] :=  NameString + ':' + TimeString + '*' + SizeString +
                '|' + Title + '|' + Performer;
  end;
end;

{ DAEReadTOC -------------------------------------------------------------------

  DAEReadTOC liest die TOC einer AudioCD aus und speichert die Informationen
  in FData.DAE.TrackList.                                                      }

procedure TCdrtfeActionDAEReadTOC.DAEReadTOC;
var Output     : TStringList;
    TrackList  : TStringList;
    CommandLine: string;
    CDPresent  : Boolean;

begin
  {$IFDEF DebugReadAudioTOC}
  FormDebug.Memo1.Lines.Add('Reading TOC ...');
  {$ENDIF}
  Output := TStringList.Create;
  {feststellen, ob CD eingelegt ist, sonst würde cdda2wav auf Benutzereingabe
   warten}
  CDPresent := DiskInserted(SCSIIF(FSettings.DAE.Device));
  {Toc auslesen}
  CommandLine := StartUpDir + cCdda2wavBin;
  CommandLine := QuotePath(CommandLine);
  CommandLine := CommandLine + ' dev=' + SCSIIF(FSettings.DAE.Device) +
                 ' verbose-level=toc -gui -info-only -no-infofile';
  if FSettings.DAE.UseCDDB then
  begin
    CommandLine := CommandLine + ' cddb=1';
    if FSettings.DAE.CDDBServer <> '' then
      CommandLine := CommandLine + ' -cddbp-server=' + FSettings.DAE.CDDBServer;
    if FSettings.DAE.CDDBPort <> '' then
      CommandLine := CommandLine + ' -cddbp-port=' + FSettings.DAE.CDDBPort;
  end;
  if CDPresent then
  begin
    Output.Text := GetDOSOutput(PChar(CommandLine), True, False);
    {$IFDEF DebugReadAudioTOC}
    AddCRStringToList(Output.Text, FormDebug.Memo1.Lines);
    FormDebug.Memo1.Lines.Add('');
    {$ENDIF}
    {TrackListe zuweisen}
    TrackList := FData.GetFileList('', cDAE);
    TrackList.Assign(Output);
    {Aus der cdda2wav-Ausgabe die Infos herausholen.}
    ExtractTrackInfo(TrackList);
    {$IFDEF DebugReadAudioTOC}
    FormDebug.Memo2.Lines.Assign(TrackList);
    {$ENDIF}
    if TrackList.Count = 0 then
    begin
      ShowMsgDlg(FLang.GMS('everify04'), FLang.GMS('g001'), MB_cdrtfeError);
    end;
  end else
      ShowMsgDlg(FLang.GMS('eburn01'), FLang.GMS('g001'), MB_cdrtfeError);
  Output.Free;
end;

{ TCdrtfeActionDAEReadTOC - protected }

{ TCdrtfeActionDAEReadTOC - public }

constructor TCdrtfeActionDAEReadTOC.Create;
begin
  inherited Create;
end;

{ CleanUp ----------------------------------------------------------------------

  CleanUp löscht temporäre Dateien.                                            }

procedure TCdrtfeActionDAEReadTOC.CleanUp;
begin
  // wird hier nicht benötigt
end;

{ Reset ------------------------------------------------------------------------

  setzt einige der internen Variablen zurück.                                  }

procedure TCdrtfeActionDAEReadTOC.Reset;
begin
  // wird hier nicht benötigt
end;

{ StartAction ------------------------------------------------------------------

  StartAction führt die gewählte Aktion aus. Die Aktion wird mit der Eigenschaft
  Action festgelegt.                                                           }

procedure TCdrtfeActionDAEReadTOC.StartAction;
begin
  DAEReadTOC;
end;

end.

