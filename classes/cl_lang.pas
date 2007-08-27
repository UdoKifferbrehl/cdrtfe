{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_lang.pas: Unterst�tzung f�r verschiedene Sprachen

  Copyright (c) 2004-2007 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte �nderung  27.08.2007

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.  

  cl_lang.pas stellt Funktionen zur Verf�gung, die die Verwendung verschiedener
  Sprachen in cdrtfe erm�glichen.


  TLang: Objekt, das die aktuellen Sprachinformationen enth�lt, sowie die
         Methoden, um auf diese zuzugreifen.

    Properties   LangFileFound

    Methoden     Create
                 ExportMessageStrings
                 GMS(const id: string): string
                 SelectLanguage: Boolean
                 SetFormLang(Form: TForm)

  exportierte Funktionen/Prozeduren:

    ExportStringProperties

}

unit cl_lang;

{$I directives.inc}

interface

uses Classes, Forms, SysUtils, Inifiles, Controls, StdCtrls, ComCtrls;

type TLang = class(TObject)
     private
       FMessageStrings: TStringList;
       FComponentStrings: TStringList;
       FLangList: TStringList;
       FLangFileFound: Boolean;
       FIniFileFound: Boolean;
       FIniFile: string;
       FCurrentLang: string;
       FDefaultLang: string;
       function GetIniPath: string;
       procedure GetDefaultLang;
       procedure GetLangList;
       procedure InitMessageStrings;
       procedure LoadLanguage;
       procedure SetDefaultLang;
     public
       constructor Create;
       destructor Destroy; override;
       function GMS(const id: string): string;
       function SelectLanguage: Boolean;       
       procedure ExportMessageStrings;
       procedure SetFormLang(Form: TForm);
       property LangFileFound: Boolean read FLangFileFound;
     end;

procedure ExportStringProperties;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     f_filesystem, f_misc, f_strings, f_wininfo, constant;

const LangFileName = '\cdrtfe_lang.ini';

type TFormSelectLang = class(TForm)
       ComboBox: TComboBox;
       ButtonOk: TButton;
       ButtonCancel: TButton;
       procedure FormShow(Sender: TObject);
       procedure ButtonClick(Sender: TObject);
     private
       FLang: TLang;
       FLangList: TStringList;
       FCurrentLang: string;
       procedure Init(List: TStringList);
     public
       property Lang: TLang write FLang;
       property LangList: TStringList write FLangList;
       property CurrentLang: string read FCurrentLang write FCurrentLang;
     end;

{ TLang ---------------------------------------------------------------------- }

{ TLang - private }

{ InitMessageStrings -----------------------------------------------------------

  InitMessageStrings initialisiert die StringList MessageString mit den Strings
  in der Default-Sprache (Deutsch).                                            }

procedure TLang.InitMessageStrings;
begin
  with FMessageStrings do
  begin
    {allgemein}
    Add('g001=Fehler!');
    Add('g002=Bitte ein Verzeichnis w�hlen!');
    Add('g003=Achtung:');
    Add('g004=Hinweis');
    Add('g005=Byte');
    Add('g006=KiByte');
    Add('g007=MiByte');
    Add('g008=GiByte');
    Add('g009=[aktiv]');
    Add('g010=vorige Session');
    Add('g011=Importiere vorige Session von Laufwerk %s (ID: %s) ...');
    Add('g012=ausgew�hlte Ordner');
    {$IFDEF ShowCmdError}
    Add('e001=Es ist ein Fehler aufgetreten!');
    Add('e002=cdrecord-ProDVD: Lizenzfehler!');
    {$ENDIF}
    {Filter}
    Add('f001=ISO-Image (*.iso)|*.iso;*.iso_00|CUE-Image (*.cue)|*.cue');
    Add('f002=ISO-Image (*.iso)|*.iso;*.iso_00');
    Add('f003=Namen ohne Endung eingeben!|*.*');
    Add('f004=Sound-Dateien (*.wav; *.mp3; *.ogg; *.flac; *.ape)|*.wav;*.mp3;*.ogg;*.flac;*.ape|Playlist (*.m3u)|*.m3u');
    Add('f005=Movie-Dateien (*.avi)|*.avi|Alle Dateien|*.*');
    Add('f006=cdrtfe Projekt-Dateien (*.cfp)|*.cfp');
    Add('f007=Image-Dateien (*.bin; *.img; *.ima)|*.bin;*.img;*.ima|Alle Dateien|*.*');
    Add('f008=cdrtfe Dateilisten (*.cfp.files)|*.cfp.files');
    Add('f009=MPEG-Dateien (*.mpg)|*.mpg');
    {GUI - Main}
    Add('c001=Brenngeschwindigkeit');
    Add('c002=Brenner');
    Add('c003=Laufwerk');
    Add('c004=Lesegeschwindigkeit');
    Add('c005=ISO-/CUE-Image auf CD schreiben');
    Add('c006=ISO-Image auf CD schreiben');
    Add('e101=Name f�r die Image-Datei fehlt!');
    Add('e102=Keine Dateien oder Ordner ausgew�hlt!');
    Add('e103=Keine Titel ausgew�hlt!');
    Add('e104=Keine Form2-Dateien ausgew�hlt!');
    Add('e105=Keine Audio-Tracks gew�hlt oder vorhanden!');
    Add('e106=Verzeichnisangabe fehlt!');
    Add('e107=Kein Image ausgew�hlt!');
    Add('e108=Fehler beim Verschieben');
    Add('e109=Ordner kann nicht in einen seiner eigenen Unterordner verschoben werden.');
    Add('e110=Ein Dateiname darf keines der folgenden Zeichen enthalten:\n\ / : * ? " < > | ;');
    Add('e111=%s: ein Ordner mit diesem Namen ist bereits vorhanden.');
    Add('e112=%s: eine Datei mit diesem Namen ist bereits vorhanden.');
    Add('e113=%s: Datei oder Ordner nicht gefunden.');
    Add('e114=%d Form2-Datei(en) gefunden mit weniger als 348.601 Bytes.\nXCDs mit so kleinen Dateien k�nnen nur als ''Single-Track-Image''\ngeschrieben werden. ');
    Add('e115=Angabe f�r Start- oder Endsektor fehlt.');
    Add('e116=Kein Ordner f�r die tempor�ren Dateien angegeben!');
    Add('e117=Dateien oder Ordner aus vorigen Sessions k�nnen nicht\nverschoben oder umbenannt werden.');
    Add('e118=Keine neuen Dateien/Ordner.\nKeine Ver�nderungen.');
    Add('m101=Image ausw�hlen');
    Add('m102=Image speichern unter');
    Add('m103=Dateien ausw�hlen');
    Add('m104=Titel ausw�hlen');
    Add('m105=Movie ausw�hlen');
    Add('m106=Projekt laden');
    Add('m107=Projekt speichern unter');
    Add('m108=Ordner ''%s'' mit allen Unterordnern entfernen?');
    Add('m110=Entfernen best�tigen');
    Add('m111=Neuer Ordner');
    Add('m112=%s Ordner, %s Dateien: %s');
    Add('m114=Alle Ordner und Dateien entfernen?');
    Add('m115=Ausgew�hlte Datei(en) entfernen?');
    Add('m116=F�ge Dateien hinzu ...');
    Add('m117=F�ge Ordner hinzu ...');
    Add('m118=Pr�fe Dateisystem ...');
    Add('m119=%s Track(s); Gesamtspielzeit %s');
    Add('m120=Dateiliste laden');
    Add('m121=Dateiliste speichern unter');
    Add('m122=%s Track(s): %s');
    {GUI - Mkisofs}
    Add('c201=DVD-Video - Optionen');
    Add('e201=Name f�r das Boot-Image fehlt!');
    Add('m202=Boot-Image ausw�hlen');
    {GUI - Settings}
    Add('e301=Es wurden keine Kommandozeilenoptionen eingegeben.');
    Add('m301=Die aktuellen Einstellungen (mit Ausnahme der Datei- Listen) k�nnen in der Registry gespeichert werden.');
    Add('m302=Die aktuellen Einstellungen (mit Ausnahme der Datei- Listen) k�nnen in der Datei cdrtfe.ini gespeichert werden.');
    {GUI - Filesystem check}
    Add('c501=Dateisystem�berpr�fung: Dateinamen');
    Add('c502=Dateisystem�berpr�fung: Ordner');
    Add('c503=Dateisystem�berpr�fung: Ung�ltige Quelldateien');
    Add('c504=Dateisystem�berpr�fung: Kein Zugriff auf Quelldateien');
    Add('e501=Dateiname zu lang.');
    Add('m501=%d Dateien/Ordner mit zu langen Namen');
    Add('m502=Maximal zul�ssige Anzahl von Zeichen: %d');
    Add('m503=Die folgenden Ordner weisen eine zu gro�e Verschachtelungstiefe auf');
    Add('m504=Momentan sind Dateinamen auf das 8.3-Format beschr�nkt. Diese Grenze kann durch das Ausw�hlen der entsprechenden Optionen f�r das ISO-Dateisystem oder durch Verwendung der Joliet-Extensions umgangen werden.');
    Add('m505=F�r Dateinamen mit mehr als 31 Zeichen, Option ''Dateinamen mit 37 Zeichen erlauben'' oder Joliet-Extensions aktivieren.');
    Add('m506=F�r Dateinamen mit mehr als 37 Zeichen Joliet Extension verwenden');
    Add('m507=Mit der Option ''Dateinamen mit 103 Zeichen erlauben'' k�nnen auch mit den Joliet-Extensions Dateinamen dieser L�nge verwendet werden. Dies verletzt zwar die Joliet-Spezifikation, scheint aber zu funktionieren.');
    Add('m508=Der l�ngste Dateiname hat mehr als 103 Zeichen. Falls die Joliet-Extensions nicht unbedingt ben�tigt werden, kann auch ein Dateisystem nach ISO9660:1999 (Option ''ISO-Level 4'') erstellt werden, womit dann Namen mit bis zu 207 Zeichen m�glich sind.');
    Add('m509=ISO9660:1999 mit Rock Ridge Extensions erlaubt 197 Zeichen. Ohne Rock Ridge Extensions sind 207 Zeichen erlaubt.');
    Add('m510=F�r Dateinamen mit mehr als 207 Zeichen kann ein UDF-Dateisystem erstellt werden.');
    Add('m511=Mehr als 247 Zeichen sind leider nicht m�glich.');
    Add('m512=Um die Ordnerstruktur unver�ndert zu lassen, mu� die Option ''tiefe Verzeichnisse nicht verschieben'' oder ''ISO-Level 4'' gew�hlt werden.');
    Add('m513=Die folgenden Dateien wurden aus der Dateiliste entfernt');
    Add('m514=Die Namen der Quelldateien sollten auf unzul�ssige Sonderzeichen �berpr�ft werden.');
    {Messages - Add files, errors}
    Add('eprocs01=%s: falsches Wave-Format.');
    Add('eprocs02=%s: falsches MPEG-Format.');
    Add('eprocs03=%s: falsches MP3-Format.');
    Add('eprocs04=%s: falsches Ogg-Format.');
    Add('eprocs05=%s: falsches FLAC-Format.');
    Add('eprocs06=%s: falsches APE-Format.');
    {Messages - Preferences}
    Add('mpref01=ShellExtensions registriert.');
    Add('mpref02=Registryeintr�ge der ShellExtensions entfernt.');
    Add('mpref03=Kommandozeilenparameter in Registry gespeichert.');
    Add('mpref04=Kommandozeilenparameter aus Registry gel�scht.');
    Add('mpref05=Einstellungen gespeichert.');
    Add('mpref06=Einstellungen gel�scht.');
    Add('mpref07=Lade Projekt-Datei: %s');
    Add('mpref08=Lade Einstellungen ...');
    Add('mpref09=Daten-CD: Lade Verzeichnisstruktur ...');
    Add('mpref10=Initialisiere Dateilisten ...');
    Add('mpref11=Daten-CD: Lade Dateien ...');
    Add('mpref12=Audio-CD: Lade Tracks ...');
    Add('mpref13=XCD: Lade Verzeichnisstruktur ...');
    Add('mpref14=XCD: Lade Dateien ...');
    Add('mpref15=Video-CD: Lade Tracks ...');
    Add('epref01=%s: Projekt-Datei nicht gefunden.');
    {Messages - Commandline}
    Add('moutput01=Ausf�hrung beendet.');
    Add('moutput02=Ausf�hrung durch Anwender abgebrochen.');
    {Messages - Init}
    Add('einit01=Die cdrtools konnten nicht (vollst�ndig) gefunden werden!\nFolgende Dateien werden unbedingt ben�tigt: cdrecord.exe,\nmkisofs.exe. Siehe auch readme.txt.');
    Add('einit02=Die Datei cygwin1.dll konnte nicht gefunden werden! Sie mu�\nentweder im cdrtfe-Verzeichnis oder im Suchpfad vorhanden sein.');
    Add('einit03=Es fehlen eine oder mehrere DLLs, die von mkisofs.exe ben�tigt werden!');
    Add('minit01=Ohne die Datei cdda2wav.exe ist das Auslesen von Audio-Tracks nicht m�glich.\n ');
    Add('minit02=Ohne die Datei sh.exe ist unter Win9x, ME ein on-the-fly-Brennen nicht m�glich.\nSiehe readme.txt f�r Download-Link.\n ');
    Add('minit03=Ohne die Datei mode2cdmaker.exe kann keine XCDs (Mode 2 Form 2)\nerstellt werden.\n ');
    Add('minit04=Um CUE-Images oder XCDs schreiben zu k�nnen, sind die cdrtools ab\nder Version 2.01a24 oder cdrdao.exe n�tig.\n ');
    Add('minit05=Es wurde kein CD-Brenner gefunden!\nImages (Daten-CD, XCD) k�nnen dennoch erstellt werden.\n ');
    Add('minit06=Ohne die Datei readcd.exe k�nnen keine Images von CDs angelegt weerden.\n ');
    Add('minit07=Mit der Mingw32-Version der cdrtools unter Win9x, ME kann cdrtfe zur\nZeit keine CDs on-the-fly schreiben.\n ');
    Add('minit08=Ohne die Datei vcdimager.exe k�nnen keine Video-CDs erstellt werden.\n ');
    Add('minit09=Ohne madplay.exe werden MP3-Tracks nicht unterst�tzt.\n ');
    Add('minit10=Ohne oggdec.exe werden Ogg-Vorbis-Tracks nicht unterst�tzt.\n ');
    Add('minit11=Ohne flac.exe werden FLAC-Tracks nicht unterst�tzt.\n ');
    Add('minit12=Ohne mac.exe werden APE-Tracks nicht unterst�tzt.\n ');            
    {Messages - Burning}
    Add('eburn01=Es ist keine CD eingelegt!');
    Add('eburn02=Diese CD kann nicht beschrieben werden. Entweder handelt es sich\num eine CD-ROM oder die CD-R(W) wurde bereits abgeschlossen.');
    Add('eburn03=Diese CD enth�lt bereits Daten und k�nnte fortgesetzt werden. Daf�r\ndie Option ''vorhandene Sessions importieren'' aktivieren. Geschieht\ndies nicht, werden die vorhandenen Sessions unsichtbar.');
    Add('eburn04=Auf dieser CD sind keine Sessions vorhanden. Trotzdem fortfahren?');
    Add('eburn05=Sessions einlesen fehlgeschlagen');
    Add('eburn06=Nicht gen�gend Speicher auf der CD!\n');
    Add('eburn07=%s MiByte sind verf�gbar.');
    Add('eburn08=Diese CD enth�lt bereits eine Daten-Session.\nAudio-Tracks k�nnen nicht hinzugef�gt werden.');
    Add('eburn09=Erste zu schreibende Adresse konnte nicht gelesen werden.\nFalls es sich um eine CD-RW handelt, mu� diese erst gel�scht werden.');
    Add('eburn10=DVDs m�ssen im DAO-Modus geschrieben werden!');
    Add('eburn11=Sorry, noch keine Unterst�tzung f�r Multisession-/Multiborder-DVDs.');
    Add('eburn12=Unbekanntes DVD-Medium, unbekannte Kapazit�t. Trotzdem fortfahren?');
    Add('eburn13=Sie k�nnen auch die Art des Mediums angeben.');
    Add('eburn14=\n%s MiByte (%d Sektoren) zuviel.');
    Add('eburn15=\n%s MiByte werden ben�tigt.');
    Add('eburn16=Soll die CD/DVD-RW automatisch gel�scht werden?');
    Add('eburn17=Diese DVD+RW enth�lt Daten. Soll sie �berschrieben werden?');
    Add('eburn18=Sie sind dabei, cdrtfe zu beenden, obwohl noch ein Kommando-\nzeilenprogramm l�uft. Dies k�nnte Probleme verursachen (z.B.\nSysteminstabilit�ten).\nTrotzdem beenden?');
    Add('eburn19=Bei DVD+R(W)s ist keine Simulation m�glich.');
    Add('mburn01=Alles bereit. Soll der Brennvorgang gestartet werden?');
    Add('mburn02=Brennvorgang starten?');
    Add('mburn03=In der Shell ausgef�hrte Befehlszeile:');
    Add('mburn04=%s verf�gbar.');
    Add('mburn05=Alles bereit. Soll der Vorgang gestartet werden?\nDaten auf der CD werden unwiederbringlich gel�scht!');
    Add('mburn06=CD-RW l�schen?');
    Add('mburn07=Gesamtkapazit�t: %s MiByte; %s:%s min');
    Add('mburn08=noch verf�gbar : %s MiByte; %s:%s min');
    Add('mburn09=Diese CD ist bereits fixiert.');
    Add('mburn10=Mode2CDMaker wird mit folgenden Optionen gestartet:');
    Add('mburn11=CD fixieren?');
    Add('mburn12=Image-Gr��e ermitteln ...');
    Add('mburn13=�berpr�fe Disk ...');
    Add('mburn14=%s MiByte zu schreiben; %s MiByte verbleibend.\n\n');
    Add('mburn15=DVD+RW-Disks k�nnen nicht gel�scht werden.\nSie werden einfach �berschrieben.');
    {Messages - Verify}
    Add('mverify01=Vergleiche Dateien ...');
    Add('mverify02=%d Fehler gefunden.');
    Add('mverify03=Vergleich durch Anwender abgebrochen!');
    Add('mverify04=Lese Inhaltsverzeichnis der CD ein. Bitte warten ...');
    Add('mverify05=%d Dateien werden mit den Quelldateien verglichen.');
    Add('everify01=Konnte CD nicht finden, Vergleich abgebrochen!');
    Add('everify02=Fehler! Dateien nicht identisch: %s <-> %s');
    Add('everify03=Konnte Reload nicht durchf�hren.\nLegen Sie die CD manuell ein und w�hlen Sie ''OK'', um den Vergleich zu starten.\nOder w�hlen Sie ''Abbrechen'', um den Vergleich nicht durchzuf�hren.');
    Add('everify04=Fehler beim Einlesen der CD');
    Add('everify05=Fehler beim erneuten Einlesen der CD. Vergleich abgebrochen.');
    Add('everify06=Fehler! Datei nicht gefunden   : %s');
    {Messages - CD Text}
    Add('ccdtext01=Titel');
    Add('ccdtext02=Interpret');
    Add('ccdtext03=Pause');
    Add('ecdtext01=Option ''CD-Text schreiben'' gew�hlt, aber\nkeine CD-Text-Informationen vorhanden!');
    Add('ecdtext02=Zu viele CD-Text-Daten!');
    Add('epause01=Die Anzahl der Sekunden oder Sektoren mu� als\nnicht negative, ganze Zahl angegeben werden.');
    {Messages - Duplicates}
    Add('mdup01=Suche identische Dateien ...');
    Add('mdup02=Dateien sind identisch: %s <-> %s');
    Add('mdup03=%s in %d doppelten Datei(en) (%s).');
    {Messages - Lang}
    Add('mlang01=Sprache w�hlen');
    Add('mlang02=Ok');
    Add('mlang03=Abbrechen');
    {Messages - XCD infofile}
    Add('mxcd01=Erstelle Info-Datei xcd.crc ...');
    Add('mxcd02=Lese Datei ...');
    {Messages - Video CD}
    Add('evcd01=Keine MPEG-Dateien ausgew�hlt!');
    {Messages - DVD Video}
    Add('edvdv01=Bitte Quellverzeichnis angeben!');
  end;
end;

{ GetIniPath -------------------------------------------------------------------

  GetIniPath bestimmt den Pfad zur cdrtfe.ini. Die identische Funktion aus
  cl_settings.pas kann nicht verwendet werden, da TSettings sp�ter instantiiert
  wird als TLang.                                                              }

function TLang.GetIniPath: string;
var Temp: string;
    Name: string;
begin
  Name := cDataDir + cIniFile;
  if PlatformWinNT then
  begin
    Temp := GetShellFolder(CSIDL_LOCAL_APPDATA) + Name;
    if not FileExists(Temp) then
    begin
      Temp := GetShellFolder(CSIDL_APPDATA) + Name;
      if not FileExists(Temp) then
      begin
        Temp := GetShellFolder(CSIDL_COMMON_APPDATA) + Name;
        if not FileExists(Temp) then
        begin
          Temp := StartUpDir + cIniFile;
          if not FileExists(Temp) then
          begin
            Temp := '';
          end;
        end;
      end;
    end;
    Result := Temp;
  end else
  begin
    Temp := StartUpDir + cIniFile;
    if not FileExists(Temp) then
    begin
      Temp := '';
    end;
    Result := Temp;
  end;
  FIniFileFound := not(Result = '');
  {$IFDEF DebugLang}
  if FIniFileFound then Deb('cdrtfe.ini found.', 1) else
                        Deb('cdrtfe.ini not found.', 1);
  {$ENDIF}
end;

{ GetDefaultLang ---------------------------------------------------------------

  ermittelt die eingestelle Default-Sprache, genauer das entsprechende Suffix. }

procedure TLang.GetDefaultLang;
var LangFile: TIniFile;
begin
  {Zuerst Einstellung in cdrtfe.ini suchen.}
  if FIniFileFound then
  begin
    LangFile := TIniFile.Create(FIniFile);
    FDefaultLang := LangFile.ReadString('General', 'DefaultLang', '');
    LangFile.Free;
    {$IFDEF DebugLang}
    Deb('cdrtfe.ini     : DefaultLang=' + FDefaultLang, 1);
    {$ENDIF}
  end;
  {Nichts gefunden? Dann in cdrtfe_lang.ini suchen.}
  if FDefaultLang = '' then
  begin
    LangFile := TIniFile.Create(StartUpDir + LangFileName);
    FDefaultLang := LangFile.ReadString('Languages', 'Default', '');
    LangFile.Free;
    {$IFDEF DebugLang}
    Deb('cdrtfe_lang.ini: DefaultLang=' + FDefaultLang, 1);
    {$ENDIF}
  end;
  FCurrentLang := FDefaultLang;
end;

{ SetDefaultLang ---------------------------------------------------------------

  setzt Suffix f�r die Default-Sprache.                                        }

procedure TLang.SetDefaultLang;
var LangFile: TStringList;
    IniFile : TIniFile;
    i: Integer;
begin
  if FIniFileFound then
  begin
    IniFile := TIniFile.Create(FIniFile);
    IniFile.WriteString('General', 'DefaultLang', FCurrentLang);
    INiFile.Free;
    {$IFDEF DebugLang}
    Deb('cdrtfe.ini     : DefaultLang=' + FCurrentLang + ' saved.', 1);
    {$ENDIF}
  end else
  begin
    { Da cdrtfe_lang.ini gr��er als 64 KiByte ist, k�nnen wir nicht mehr die
      Funktionen f�r Ini-Dateien verwenden, wenn wir speichern wollen. }
    LangFile := TStringList.Create;
    LangFile.LoadFromFile(StartUpDir + LangFileName);
    i := LangFile.IndexOf('Default=' + FDefaultLang);
    LangFile[i] := 'Default=' + FCurrentLang;
    LangFile.SaveToFile(StartUpDir + LangFileName);
    LangFile.Free;
    {$IFDEF DebugLang}
    Deb('cdrtfe_lang.ini: DefaultLang=' + FCurrentLang + ' saved.', 1);
    {$ENDIF}
  end;
  FDefaultLang := FCurrentLang;
end;

{ GetLangList ------------------------------------------------------------------

  liest die Liste aller verf�gbaren Sprachen ein.                              }

procedure TLang.GetLangList;
var LangFile: TIniFile;
    Temp    : string;
begin
  LangFile := TIniFile.Create(StartUpDir + LangFileName);
  LangFile.ReadSectionValues('Languages', FLangList);
  LangFile.Free;
  {Defaulteintrag entfernen}
  Temp := FLangList.Values['Default'];
  FLangList.Delete(FLangList.IndexOf('Default=' + Temp));
  {$IFDEF DebugLang}
  FormDebug.Memo3.Lines.Assign(FLangList);
  {$ENDIF}
end;

{ LoadLanguage -----------------------------------------------------------------

  LoadLanguage l�dt aus der Datei cdrtfe_lang.ini die dort eingestellte Sprache
  und speichert die Daten in den Stringlisten FMessageStrings und
  FComponentStrings.                                                           }

procedure TLang.LoadLanguage;
var NewStrings: TStringList;
    List: TStringList;
    i: Integer;
    Ok: Boolean;
begin
  NewStrings := TSTringList.Create;
  List := TStringList.Create;
  {gesamte Sprachdatei laden}
  List.LoadFromFile(StartUpDir + LangFileName);
  {MessageStrings laden}
  Ok := GetSection(List, NewStrings, '[Messages_' + FDefaultLang + ']', '');
  if Ok then
  begin
    {falls in cdrtfe_lang.ini Eintr�ge fehlen, die Original-Eintr�ge nehmen}
    for i := 0 to FMessageStrings.Count - 1 do
    begin
      if NewStrings.Values[FMessageStrings.Names[i]] = '' then
      begin
        NewStrings.Add(FMessageStrings[i]);
      end;
    end;
    FMessageStrings.Clear;
    FMessageStrings.Assign(NewStrings);
  end;
  NewStrings.Clear;
  {ComponentStrings laden}
  Ok := GetSection(List, NewStrings, '[Components_' + FDefaultLang + ']', '');
  if Ok then
  begin
    FComponentStrings.Assign(NewStrings);
  end;
  NewStrings.Free;
  List.Free;
end;

{ TLang - public }

constructor TLang.Create;
begin
  inherited Create;
  FMessageStrings := TStringList.Create;
  FComponentStrings := TStringList.Create;
  FLangList := TStringList.Create;
  InitMessageStrings;
  if FileExists(StartUpDir + LangFileName) then
  begin
    {cdrtfe.ini suchen}
    FIniFile := GetIniPath;
    {es wurde eine Sprachdatei gefunden}
    FLangFileFound := True;
    {Defaultwert auslesen}
    GetDefaultLang;
    {List der verf�gbaren Sprachen einlesen}
    GetLangList;
    {Sprachinformationen laden}
    LoadLanguage;
  end else
  begin
    {es wurde keine Sprachdatei gefunden}
    FLangFileFound := False;
  end;
end;

destructor TLang.Destroy;
begin
  FMessageStrings.Free;
  FComponentStrings.Free;
  FLangList.Free;
  inherited Destroy;
end;

{ GMS --------------------------------------------------------------------------

  GMS (GetMessageString) erm�glicht den Zugriff auf einzelne Strings aus der
  StringList MessageString �ber die zugeh�rige ID.                             }

function TLang.GMS(const id: string): string;
const //CR = #13;
      CRLF = #13#10;
begin
  Result := FMessageStrings.Values[id];
  Result := ReplaceString(Result, '\n', CRLF);
end;

{ SetFormLang ------------------------------------------------------------------

  SetFormLang ersetzt die aktuellen String-Properties des als Argument �ber-
  gebenen Forms durch Strings in der aus cdrt_lang.ini geladenen Sprache. Sollte
  diese Datei fehlen, bleiben die Stringproperties unver�ndert.                }

procedure TLang.SetFormLang(Form: TForm);
var j, k: Integer;
    FormName: string;
    Name: string;
    Value: string;
    C: TComponent;
begin
  if FLangFileFound then
  begin
    FormName := Form.Name;
    {Form.Caption}
    Name := FormName + '.Caption';
    Value := FComponentStrings.Values[Name];
    if Value <> '' then
    begin
      Form.Caption := Value;
    end;
    {Form.Hint}
    Name := FormName + '.Hint';
    Value := FComponentStrings.Values[Name];
    if Value <> '' then
    begin
      Form.Hint := Value;
    end;
    {jetzt die Komponenten des Forms}
    for j := 0 to Form.ComponentCount - 1 do
    begin
      C := Form.Components[j];
      {C.Caption}
      if PropertyExists(C, 'Caption') then
      begin
        Name := FormName + '.' + C.Name + '.Caption';
        Value := FComponentStrings.Values[Name];
        if Value <> '' then
        begin
          SetCompProp(C, 'Caption', Value);
        end;
      end;
      {C.Hint}
      if PropertyExists(C, 'Hint') then
      begin
        Name := FormName + '.' + C.Name + '.Hint';
        Value := FComponentStrings.Values[Name];
        if Value <> '' then
        begin
          SetCompProp(C, 'Hint', Value);
          {standarm��ig sind die Hints abgeschaltet, daher mu� die Anzeige hier
           explizit eingeschaltet werden. Ob es auf diese Art sicher ist?}
          (C as TControl).ShowHint := True;
        end;
      end;
      {C.Title}
      if PropertyExists(C, 'Title') then
      begin
        Name := FormName + '.' + C.Name + '.Title';
        Value := FComponentStrings.Values[Name];
        if Value <> '' then
        begin
          SetCompProp(C, 'Caption', Value);
        end;
      end;
      {C.DisplayLabel}
      if PropertyExists(C, 'DisplayLabel') then
      begin
        Name := FormName + '.' + C.Name + '.DisplayLabel';
        Value := FComponentStrings.Values[Name];
        if Value <> '' then
        begin
          SetCompProp(C, 'Caption', Value);
        end;
      end;
      {C.Filter}
      if PropertyExists(C, 'Filter') then
      begin
        Name := FormName + '.' + C.Name + '.Filter';
        Value := FComponentStrings.Values[Name];
        if Value <> '' then
        begin
          SetCompProp(C, 'Caption', Value);
        end;
      end;
      {C.Lines}
      if PropertyExists(C, 'Lines') then
      begin
        if C is TMemo then
        begin
          for k := 0 to (C as TMemo).Lines.Count - 1 do
          begin
            Name := FormName + '.' + C.Name + '.Lines' + IntToStr(k);
            Value := FComponentStrings.Values[Name];
            if Value <> '' then
            begin
              (C as TMemo).Lines[k] := Value
            end;
          end;
        end;
      end;
      {C.Items}
      if PropertyExists(C, 'Items') then
      begin
        if C is TListBox then
        begin
          for k := 0 to (C as TListBox).Items.Count - 1 do
          begin
            Name := FormName + '.' + C.Name + '.Items' + IntToStr(k);
            Value := FComponentStrings.Values[Name];
            if Value <> '' then
            begin
              (C as TListBox).Items[k] := Value
            end;
          end;
        end else
        begin
          if C is TComboBox then
          begin
            for k := 0 to (C as TComboBox).Items.Count - 1 do
            begin
              Name := FormName + '.' + C.Name + '.Items' + IntToStr(k);
              Value := FComponentStrings.Values[Name];
              if Value <> '' then
              begin
                (C as TComboBox).Items[k] := Value
              end;
            end;
          end;
        end;
      end;
      {C.Columns}
      if PropertyExists(C, 'Columns') then
      begin
        if C is TListView then
        begin
          for k := 0 to (C as TListView).Columns.Count - 1 do
          begin
            Name := FormName + '.' + C.Name + '.Columns' + IntToStr(k) +
                    '.Caption';
            Value := FComponentStrings.Values[Name];
            if Value <> '' then
            begin
              (C as TListView).Columns[k].Caption := Value
            end;
          end;
        end;
      end;
      {auf weitere Properties kann verzichtet werden, da sie in cdrtfe nicht
       verwendet werden}
    end;
  end;
end;

{ SelectLanguage ---------------------------------------------------------------

  zeigt ein Auswahlfenster an, mit dem die aktive Sprache ge�ndert werden kann.
  Wenn die Sprache ge�ndert wurde ist der Ruckgabewert True.                   }

function TLang.SelectLanguage: Boolean;
var FormSelectLang: TFormSelectLang;
begin
  Result := False;
  FormSelectLang := TFormSelectLang.CreateNew(nil);
  try
    FormSelectLang.Lang := Self;
    FormSelectLang.LangList := FLangList;
    FormSelectLang.CurrentLang := FDefaultLang;
    FormSelectLang.Init(FLangList);
    FormSelectLang.ShowModal;
    if FormSelectLang.CurrentLang <> FCurrentLang then
    begin
      FCurrentLang := FormSelectLang.CurrentLang;
      SetDefaultLang;
      LoadLanguage;
      Result := True;
    end;
  finally
    FormSelectLang.Release;
  end;
end;

{ Export MessageStrings --------------------------------------------------------

  ExportMessageStrings schreibt den Inhalt von MessageString in die Textdatei
  StartUpDir\MessageStrings.txt.                                               }

procedure TLang.ExportMessageStrings;
begin
  FMessageStrings.SaveToFile(StartUpDir + '\MessageStrings.txt');
end;

{ weitere Prozeduren --------------------------------------------------------- }

{ ExportStringProperties -------------------------------------------------------

  ExportStringProperties schreibt alle String-Poperties aller Komponenten des
  Programms in die Textdatei StartUpDir\StringProps.txt.                       }

procedure ExportStringProperties;
var OutFile: TIniFile;
    i: Integer;

  {lokale Prozedur von ExportProperties}
  procedure SaveForm(Comp: TComponent);
  var j, k: Integer;
      Section: string;
      FormName: string;
      Name: string;
      Value: string;
      C: TComponent;
  begin
    Section := 'Lang1';
    FormName := (Comp as TForm).Name;
    {Form.Caption}
    Name := FormName + '.Caption';
    Value := (Comp as TForm).Caption;
    if Value <> '' then OutFile.WriteString(Section, Name, Value);
    {Form.Hint}
    Name := FormName + '.Hint';
    Value := (Comp as TForm).Hint;
    if Value <> '' then OutFile.WriteString(Section, Name, Value);
    {jetzt die Komponenten des Forms}
    for j := 0 to Comp.ComponentCount - 1 do
    begin
      C := Comp.Components[j];
      {C.Caption}
      if PropertyExists(C, 'Caption') then
      begin
        Name := FormName + '.' + C.Name + '.Caption';
        Value := GetCompProp(C, 'Caption');
        if Value <> '' then OutFile.WriteString(Section, Name, Value);
      end;
      {C.Hint}
      if PropertyExists(C, 'Hint') then
      begin
        Name := FormName + '.' + C.Name + '.Hint';
        Value := GetCompProp(C, 'Hint');
        if Value <> '' then OutFile.WriteString(Section, Name, Value);
      end;
      {C.Title}
      if PropertyExists(C, 'Title') then
      begin
        Name := FormName + '.' + C.Name + '.Title';
        Value := GetCompProp(C, 'Title');
        if Value <> '' then OutFile.WriteString(Section, Name, Value);
      end;
      {C.DisplayLabel}
      if PropertyExists(C, 'DisplayLabel') then
      begin
        Name := FormName + '.' + C.Name + '.DisplayLabel';
        Value := GetCompProp(C, 'DisplayLabel');
        if Value <> '' then OutFile.WriteString(Section, Name, Value);
      end;
      {C.Filter}
      if PropertyExists(C, 'Filter') then
      begin
        Name := FormName + '.' + C.Name + '.Filter';
        Value := GetCompProp(C, 'Filter');
        if Value <> '' then OutFile.WriteString(Section, Name, Value);
      end;
      {C.Lines}
      if PropertyExists(C, 'Lines') then
      begin
        if C is TMemo then
        begin
          for k := 0 to (C as TMemo).Lines.Count - 1 do
          begin
            Name := FormName + '.' + C.Name + '.Lines' + IntToStr(k);
            Value := (C as TMemo).Lines[k];
            if Value <> '' then OutFile.WriteString(Section, Name, Value);
          end;
        end;
      end;
      {C.Items}
      if PropertyExists(C, 'Items') then
      begin
        if C is TListBox then
        begin
          for k := 0 to (C as TListBox).Items.Count - 1 do
          begin
            Name := FormName + '.' + C.Name + '.Items' + IntToStr(k);
            Value := (C as TListBox).Items[k];
            if Value <> '' then OutFile.WriteString(Section, Name, Value);
          end;
        end else
        begin
          if C is TComboBox then
          begin
            for k := 0 to (C as TComboBox).Items.Count - 1 do
            begin
              Name := FormName + '.' + C.Name + '.Items' + IntToStr(k);
              Value := (C as TComboBox).Items[k];
              if Value <> '' then OutFile.WriteString(Section, Name, Value);
            end;
          end;
        end;
      end;
      {C.Columns}
      if PropertyExists(C, 'Columns') then
      begin
        if C is TListView then
        begin
          for k := 0 to (C as TListView).Columns.Count - 1 do
          begin
            Name := FormName + '.' + C.Name + '.Columns' + IntToStr(k) +
                    '.Caption';
            Value := (C as TListView).Columns[k].Caption;
            if Value <> '' then OutFile.WriteString(Section, Name, Value);
          end;
        end;
      end;
      {auf weitere Properties kann verzichtet werden, da sie in cdrtfe nicht
       verwendet werden}
    end;
  end;

begin
  OutFile := TIniFile.Create(StartUpDir + '\StringProps.txt');
  for i:= 0 to Application.ComponentCount - 1 do
  begin
    if Application.Components[i] is TForm then
    begin
      SaveForm(Application.Components[i]);
    end;
  end;
  OutFile.Free;
end;


{ TFormSetLang --------------------------------------------------------------- }

{ TFormSetLang - private }

procedure TFormSelectLang.Init;
var i: Integer;
begin
  SetFont(Self);
  {Form}
  Caption := FLang.GMS('mlang01');
  Position := poScreenCenter;
  BorderIcons := [biSystemMenu];
  ClientHeight := 70; // Height := 98;
  ClientWidth := 220; // Width := 227;
  OnShow := FormShow;
  {ComboBox}
  ComboBox := TComboBox.Create(Self);
  with ComboBox do
  begin
    Parent := Self;
    Left := 8;
    Top := 8;
    Height := 98;
    Width := 203;
    Visible := True;
    Style := csDropDownList;
  end;
  {Ok-Button}
  ButtonOk := TButton.Create(Self);
  with ButtonOk do
  begin
    Parent := Self;
    Left := 56;
    Top := 40;
    Height := 25;
    Width := 75;
    Caption := FLang.GMS('mlang02');
    OnClick := ButtonClick;
  end;
  {Cancel-Button}
  ButtonCancel := TButton.Create(Self);
  with ButtonCancel do
  begin
    Parent := Self;
    Left := 136;
    Top := 40;
    Height := 25;
    Width := 75;
    Caption := FLang.GMS('mlang03');
    ModalResult := mrCancel;
    Cancel := True;
  end;
  {Liste �bernehmen}
  for i := 0 to FLangList.Count - 1 do
  begin
    ComboBox.Items.Add(FlangList.Values[FLangList.Names[i]]);
    if FLangList.Names[i] = FCurrentLang then ComboBox.ItemIndex := i;
  end;
end;

procedure TFormSelectLang.FormShow(Sender: TObject);
begin
  ButtonCancel.SetFocus;
end;

procedure TFormSelectLang.ButtonClick(Sender: TObject);
begin
  FCurrentLang := FLangList.Names[ComboBox.ItemIndex];
  ModalResult := mrOk;
end;

{ TFormSetLang - public }

end.
