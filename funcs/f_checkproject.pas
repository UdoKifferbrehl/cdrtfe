{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  f_checkproject.pas: Einstellungen und Daten prüfen

  Copyright (c) 2004 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  15.02.2005

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_checkproject.pas stellt Funktionen und Prozeduren zur Verfügung, die von
  cdrtfe benötigt werden, um zu überprüfen, ob für ein bestimmtes Projekt alle
  nötigen Angaben gemacht wurden.
  Eigentlich müßte dies Teil von TProjectData bzw. TSettings sein, aber da Daten
  aus beiden Objekten für die Prüfung notwendig sind, ist es einfacher, die
  Überprüfung auszulagern.


  exportierte Funktionen/Prozeduren:

    CheckProject(FData: TProjectData; FSettings: TSettings): Boolean

}

unit f_checkproject;

{$I directives.inc}

interface

uses Forms, Windows, SysUtils, FileCtrl,
     {eigene Klassendefinitionen/Units}
     cl_projectdata, cl_settings, cl_lang, constant;

function CheckProject(FData: TProjectData; FSettings: TSettings; FLang: TLang): Boolean;

implementation

uses f_misc;

function CheckProject(FData: TProjectData; FSettings: TSettings;
                      FLang: TLang): Boolean;

  function CheckProjectDataCD: Boolean;
  var FileCount: Integer;
      DummyI   : Integer;
      DummyL: {$IFDEF LargeProject} Comp {$ELSE} Longint {$ENDIF};
      DummyE   : Extended;
  begin
    with FData, FSettings.DataCD, FLang do
    begin
      Result := True;
      if not OnTheFly and (IsoPath = '') then
      begin
        Result := False;
        // Fehlermeldung := 'Name für die Image-Datei fehlt!';
        Application.MessageBox(PChar(GMS('e101')), PChar(GMS('g001')),
          MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
      end;
      GetProjectInfo(FileCount, DummyI, DummyL, DummyE, DummyI,
                     FSettings.General.Choice);
      if (FileCount = 0) and not Boot then
      begin
        Result := False;
        // Fehlermeldung := 'Keine Dateien oder Ordner ausgewählt!';
        Application.MessageBox(PChar(GMS('e102')), PChar(GMS('g001')),
          MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
      end;
    end;
  end;

  function CheckProjectAudioCD: Boolean;
  var TrackCount: Integer;
      DummyI   : Integer;
      DummyL   : {$IFDEF LargeProject} Comp {$ELSE} Longint {$ENDIF};
      DummyE   : Extended;
  begin
    with FData, FSettings.AudioCD, FLang do
    begin
      Result := True;
      GetProjectInfo(DummyI, DummyI, DummyL, DummyE, TrackCount,
                     FSettings.General.Choice);
      if TrackCount = 0 then
      begin
        Result := False;
        // Fehlermeldung := 'Keine Titel ausgewählt!';
        Application.MessageBox(PChar(GMS('e103')), PChar(GMS('g001')),
          MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
      end;
      if CDText and not CDTextPresent and not UseInfo then
      begin
        Result := False;
        // keine CD-Text-Daten
        Application.MessageBox(PChar(GMS('ecdtext01')), PChar(GMS('g001')),
          MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
      end;
      if CDTextLength > (252 * 12) then
      begin
        Result := False;
        // zu viel CD-Text
        Application.MessageBox(PChar(GMS('ecdtext02')), PChar(GMS('g001')),
          MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
      end;
    end;
  end;

  function CheckProjectXCD: Boolean;
  var Meldung   : string;
  begin
    with FData, FSettings.XCD, FLang do
    begin
      Result := True;
      {XCD macht nur Sinn, wenn mindestens eine Form2-Datei dabei ist}
      if GetForm2FileCount = 0 then
      begin
        Result := False;
        // Fehlermeldung := 'Keine Form2-Dateien ausgewählt!';
        Application.MessageBox(PChar(GMS('e104')), PChar(GMS('g001')),
          MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
      end;
      {Wenn es Form2-Dateien mit weniger als 348.601 Bytes gibt, dann warnen und
       Single-Track-Image empfehlen}
      if not Single and (GetSmallForm2FileCount > 0) then
      begin
        Result := False;
        Meldung := Format(GMS('e114'), [GetSmallForm2FileCount]);
        Application.MessageBox(PChar(Meldung), PChar(GMS('g001')),
          MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
      end;
      {Eine Pfad für das Image brauchen wir auch.}
      if IsoPath = '' then
      begin
        Result := False;
        // Fehlermeldung := 'Name für die Image-Datei fehlt!';
        Application.MessageBox(PChar(GMS('e101')), PChar(GMS('g001')),
          MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
      end;
    end;
  end;

  function CheckProjectDAE: Boolean;
  var TrackCount: Integer;
      DummyI   : Integer;
      DummyL   : {$IFDEF LargeProject} Comp {$ELSE} Longint {$ENDIF};
      DummyE   : Extended;
  begin
    with FData, FSettings.DAE, FLang do
    begin
      Result := True;
      GetProjectInfo(DummyI, DummyI, DummyL, DummyE, TrackCount,
                     FSettings.General.Choice);
      if (TrackCount = 0) or (Tracks = '') then
      begin
        Result := False;
        // Fehlermeldung := 'Keine Audio-Tracks gewählt oder vorhanden!';
        Application.MessageBox(PChar(GMS('e105')), PChar(GMS('g001')),
          MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
      end;
      if Path = '' then
      begin
        Result := False;
        // Fehlermeldung := 'Verzeichnisangabe fehlt!';
        Application.MessageBox(PChar(GMS('e106')), PChar(GMS('g001')),
          MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
      end;
    end;
  end;

  function CheckProjectImage: Boolean;
  begin
    Result := True;
    with FData, FLang do
    begin
      if ((FSettings.Image.IsoPath = '') and not FSettings.General.ImageRead) or
         ((FSettings.Readcd.IsoPath = '') and FSettings.General.ImageRead) then
      begin
        Result := False;
        // Fehlermeldung := 'Name für die Image-Datei fehlt!';
        Application.MessageBox(PChar(GMS('e101')), PChar(GMS('g001')),
          MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
      end;
      if FSettings.Readcd.Range then
      begin
        if (FSettings.Readcd.Startsec = '') or
           (FSettings.Readcd.Endsec = '') then
        begin
          Result := False;
          Application.MessageBox(PChar(GMS('e115')), PChar(GMS('g001')),
            MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
        end;
      end;
    end;
  end;

  function CheckProjectVideoCD: Boolean;
  var TrackCount: Integer;
      DummyI   : Integer;
      DummyL   : {$IFDEF LargeProject} Comp {$ELSE} Longint {$ENDIF};
      DummyE   : Extended;
  begin
    with FData, FSettings.VideoCD, FLang do
    begin
      Result := True;
      {Video-Tracks sollten schon vorhanden sein.}
      GetProjectInfo(DummyI, DummyI, DummyL, DummyE, TrackCount,
                     FSettings.General.Choice);
      if TrackCount = 0 then
      begin
        Result := False;
        // Fehlermeldung := 'Keine Titel ausgewählt!';
        Application.MessageBox(PChar(GMS('evcd01')), PChar(GMS('g001')),
          MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
      end;
      {Eine Pfad für das Image brauchen wir auch.}
      if IsoPath = '' then
      begin
        Result := False;
        // Fehlermeldung := 'Name für die Image-Datei fehlt!';
        Application.MessageBox(PChar(GMS('e101')), PChar(GMS('g001')),
          MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
      end;
    end;
  end;

  function CheckProjectDVDVideo: Boolean;
  begin
    Result := True;
    with FSettings.DVDVideo, FLang do
    begin
      if (SourcePath = '') or not DirectoryExists(SourcePath) then
      begin
        Result := False;
        Application.MessageBox(PChar(GMS('edvdv01')), PChar(GMS('g001')),
          MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
      end;
    end;
  end;

begin
  Result := True;
  case FSettings.General.Choice of
    cDataCD  : Result := CheckProjectDataCD;
    cAudioCD : Result := CheckProjectAudioCD;
    cXCD     : Result := CheckProjectXCD;
    cCDRW    : Result := True; {da keine Eingaben nötig}
    cCDInfos : Result := True; {da keine Eingaben nötig}
    cDAE     : Result := CheckProjectDAE;
    cCDImage : Result := CheckProjectImage;
    cVideoCD : Result := CheckProjectVideoCD;
    cDVDVideo: Result := CheckProjectDVDVideo;
  end;

end;

end.
