{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_lang.pas: Unterstützung für verschiedene Sprachen

  Copyright (c) 2004-2012 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  12.05.2012

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  cl_lang.pas stellt Funktionen zur Verfügung, die die Verwendung verschiedener
  Sprachen in cdrtfe ermöglichen.


  TLang: Objekt, das die aktuellen Sprachinformationen enthält, sowie die
         Methoden, um auf diese zuzugreifen.

    Properties   LangFileFound
                 CurrentLangName
                 OnLangChange

    Methoden     Create
                 CreateLangSubMenu(MenuItem: TMenuItem)
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

uses Classes, Forms, SysUtils, Inifiles, Controls, StdCtrls, ComCtrls, Menus;

type TLangChangeEvent = procedure of object;

     TLang = class(TObject)
     private
       FMessageStrings  : TStringList;
       FComponentStrings: TStringList;
       FLangList        : TStringList;
       FLangIniFileFound: Boolean;       // translation\cdrtfe_lang.ini
       FLangFileFound   : Boolean;       // ausgewählte Übersetzung
       FIniFileFound    : Boolean;       // cdrtfe.ini
       FIniFile         : string;
       FCurrentLang     : string;
       FCurrentLangName : string;
       FDefaultLang     : string;
       FDefaultLangName : string;
       FOnLangChange    : TLangChangeEvent;
       function GetIniPath: string;
       function LangIniFileFound: Boolean;
       function TranslationFileFound: Boolean;
       procedure GetDefaultLang;
       procedure GetLangList;
       procedure InitMessageStrings;
       procedure LangChange;
       procedure LangListSort;
       procedure LangMenuItemClick(Sender: TObject);
       procedure LoadLanguage;
       procedure SetDefaultLang;
     public
       constructor Create;
       destructor Destroy; override;
       function GMS(const id: string): string;
       function SelectLanguage: Boolean;
       procedure CreateLangSubMenu(MenuItem: TMenuItem);
       procedure ExportMessageStrings;
       procedure SetFormLang(Form: TForm);
       property LangFileFound: Boolean read FLangFileFound;
       property CurrentLangName: string read FCurrentLangName;
       property OnLangChange: TLangChangeEvent read FOnLangChange write FOnLangChange;
     end;

procedure ExportStringProperties;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     f_logfile, f_filesystem, f_strings, f_stringlist, f_wininfo, f_locations,
     const_locations, f_window, f_compprop, c_frametopbanner;

type TFormSelectLang = class(TForm)
       ComboBox: TComboBox;
       ButtonOk: TButton;
       ButtonCancel: TButton;
       LabelOk: TLabel;
       LabelCancel: TLabel;
       FrameTopBanner1: TFrameTopBanner;
       procedure FormShow(Sender: TObject);
       procedure ButtonClick(Sender: TObject);
     private
       FLang       : TLang;
       FLangList   : TStringList;
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
    Add('g002=Bitte ein Verzeichnis wählen!');
    Add('g003=Achtung:');
    Add('g004=Hinweis');
    Add('g005=Byte');
    Add('g006=KiByte');
    Add('g007=MiByte');
    Add('g008=GiByte');
    Add('g009=[aktiv]');
    Add('g010=vorige Session');
    Add('g011=Importiere vorige Session von Laufwerk %s (ID: %s) ...');
    Add('g012=ausgewählte Ordner (mit Entf aus Liste löschen)');
    Add('g013=mehrere Ordner mit Alt-Einfg auswählen');
    Add('g014=CD 650 MiB (74 min)\nCD 700 MiB (80 min)\nCD 800 MiB (90 min)\nCD 870 MiB (99 min)\nDVD 4.38 GiB\nDVD/DL 7.96 GiB\nBD 23.3 GiB\nBD DL 46,6 GiB\nMiB\nmin\nCD\nDVD\nDVD/DL\nBD\nBD DL');
    Add('g015=Geändert am');
    Add('g016=Quelldateien');
    Add('g017=Aktivieren');
    Add('g018=Deaktivieren');
    Add('g019=mehrere Brenner');
    {$IFDEF ShowCmdError}
    Add('e001=Es ist ein Fehler aufgetreten!');
    Add('e002=cdrecord-ProDVD: Lizenzfehler!');
    {$ENDIF}
    {Resource-Strings}
    Add('rs01=OK');
    Add('rs02=Abbrechen');
    Add('rs03=Ja');
    Add('rs04=Nein');
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
    Add('c005=ISO-/CUE-Image auf Disk schreiben');
    Add('c006=ISO-Image auf Disk schreiben');
    Add('e101=Name für die Image-Datei fehlt!');
    Add('e102=Keine Dateien oder Ordner ausgewählt!');
    Add('e103=Keine Titel ausgewählt!');
    Add('e104=Keine Form2-Dateien ausgewählt!');
    Add('e105=Keine Audio-Tracks gewählt oder vorhanden!');
    Add('e106=Verzeichnisangabe fehlt!');
    Add('e107=Kein Image ausgewählt!');
    Add('e108=Fehler beim Verschieben');
    Add('e109=Ordner kann nicht in einen seiner eigenen Unterordner verschoben werden.');
    Add('e110=Ein Dateiname darf keines der folgenden Zeichen enthalten:\n\ / : * ? " < > | ;');
    Add('e111=%s: ein Ordner mit diesem Namen ist bereits vorhanden.');
    Add('e112=%s: eine Datei mit diesem Namen ist bereits vorhanden.');
    Add('e113=%s: Datei oder Ordner nicht gefunden.');
    Add('e114=%d Form2-Datei(en) gefunden mit weniger als 348.601 Bytes.\nXCDs mit so kleinen Dateien können nur als ''Single-Track-Image''\ngeschrieben werden. ');
    Add('e115=Angabe für Start- oder Endsektor fehlt.');
    Add('e116=Kein Ordner für die temporären Dateien angegeben!');
    Add('e117=Dateien oder Ordner aus vorigen Sessions können nicht\nverschoben oder umbenannt werden.');
    Add('e118=Keine neuen Dateien/Ordner.\nKeine Veränderungen.');
    Add('e119=Um Dateien ab 4 GiB zu schreiben, muß\nzusätzlich ISO Level 3 oder 4 verwendet werden.');
    Add('e120=Dateizusammenstellung verändert.\nTrotzdem beenden?');
    Add('m101=Image auswählen');
    Add('m102=Image speichern unter');
    Add('m103=Dateien auswählen');
    Add('m104=Titel auswählen');
    Add('m105=Movie auswählen');
    Add('m106=Projekt laden');
    Add('m107=Projekt speichern unter');
    Add('m108=Ordner ''%s'' mit allen Unterordnern entfernen?');
    Add('m110=Entfernen bestätigen');
    Add('m111=Neuer Ordner');
    Add('m112=%s Ordner, %s Dateien: %s');
    Add('m114=Alle Ordner und Dateien entfernen?');
    Add('m115=Ausgewählte Datei(en) entfernen?');
    Add('m116=Füge Dateien hinzu ...');
    Add('m117=Füge Ordner hinzu ...');
    Add('m118=Prüfe Dateisystem ...');
    Add('m119=%s Track(s); Gesamtspielzeit %s');
    Add('m120=Dateiliste laden');
    Add('m121=Dateiliste speichern unter');
    Add('m122=%s Track(s): %s');
    Add('m123=Suche Laufwerke ...');
    Add('m124=Prüfe verfügbare Geschwindigkeiten ...');
    Add('m125=Kopiere WAV-Datei vor Anwendung von ReplayGain:');
    {GUI - Mkisofs}
    Add('c201=DVD-Video - Optionen');
    Add('e201=Name für das Boot-Image fehlt!');
    Add('m202=Boot-Image auswählen');
    {GUI - Settings}
    Add('e301=Es wurden keine Kommandozeilenoptionen eingegeben.');
    Add('m301=Die aktuellen Einstellungen (mit Ausnahme der Datei- Listen) können in der Registry gespeichert werden.');
    Add('m302=Die aktuellen Einstellungen (mit Ausnahme der Datei- Listen) können in der Datei cdrtfe.ini gespeichert werden.');
    Add('m303=cdrtfe hat keine weiteren Versionen der cygwin1.dll gefunden. Es wird die mitgelieferte DLL verwendet.');
    {GUI - Filesystem check}
    Add('c501=Dateisystemüberprüfung: Dateinamen');
    Add('c502=Dateisystemüberprüfung: Ordner');
    Add('c503=Dateisystemüberprüfung: Ungültige Quelldateien');
    Add('c504=Dateisystemüberprüfung: Kein Zugriff auf Quelldateien');
    Add('e501=Dateiname zu lang.');
    Add('m501=%d Dateien/Ordner mit zu langen Namen');
    Add('m502=Maximal zulässige Anzahl von Zeichen: %d');
    Add('m503=Die folgenden Ordner weisen eine zu große Verschachtelungstiefe auf');
    Add('m504=Momentan sind Dateinamen auf das 8.3-Format beschränkt. Diese Grenze kann durch das Auswählen der entsprechenden Optionen für das ISO-Dateisystem oder durch Verwendung der Joliet-Extensions umgangen werden.');
    Add('m505=Für Dateinamen mit mehr als 31 Zeichen, Option ''Dateinamen mit 37 Zeichen erlauben'' oder Joliet-Extensions aktivieren.');
    Add('m506=Für Dateinamen mit mehr als 37 Zeichen Joliet Extension verwenden');
    Add('m507=Mit der Option ''Dateinamen mit 103 Zeichen erlauben'' können auch mit den Joliet-Extensions Dateinamen dieser Länge verwendet werden. Dies verletzt zwar die Joliet-Spezifikation, scheint aber zu funktionieren.');
    Add('m508=Der längste Dateiname hat mehr als 103 Zeichen. Falls die Joliet-Extensions nicht unbedingt benötigt werden, kann auch ein Dateisystem nach ISO9660:1999 (Option ''ISO-Level 4'') erstellt werden, womit dann Namen mit bis zu 207 Zeichen möglich sind.');
    Add('m509=ISO9660:1999 mit Rock Ridge Extensions erlaubt 197 Zeichen. Ohne Rock Ridge Extensions sind 207 Zeichen erlaubt.');
    Add('m510=Für Dateinamen mit mehr als 207 Zeichen kann ein UDF-Dateisystem erstellt werden.');
    Add('m511=Mehr als 247 Zeichen sind leider nicht möglich.');
    Add('m512=Um die Ordnerstruktur unverändert zu lassen, muß die Option ''tiefe Verzeichnisse nicht verschieben'' oder ''ISO-Level 4'' gewählt werden.');
    Add('m513=Die folgenden Dateien wurden aus der Dateiliste entfernt');
    Add('m514=Die Namen der Quelldateien sollten auf unzulässige Sonderzeichen überprüft werden.');
    {Messages - Add files, errors}
    Add('eprocs01=%s: falsches Wave-Format.');
    Add('eprocs02=%s: falsches MPEG-Format.');
    Add('eprocs03=%s: falsches MP3-Format.');
    Add('eprocs04=%s: falsches Ogg-Format.');
    Add('eprocs05=%s: falsches FLAC-Format.');
    Add('eprocs06=%s: falsches APE-Format.');
    {Messages - Preferences}
    Add('mpref01=ShellExtensions registriert.');
    Add('mpref02=Registryeinträge der ShellExtensions entfernt.');
    Add('mpref03=Kommandozeilenparameter in Registry gespeichert.');
    Add('mpref04=Kommandozeilenparameter aus Registry gelöscht.');
    Add('mpref05=Einstellungen gespeichert.');
    Add('mpref06=Einstellungen gelöscht.');
    Add('mpref07=Lade Projekt-Datei: %s');
    Add('mpref08=Lade Einstellungen ...');
    Add('mpref09=Daten-Disk: Lade Verzeichnisstruktur ...');
    Add('mpref10=Initialisiere Dateilisten ...');
    Add('mpref11=Daten-Disk: Lade Dateien ...');
    Add('mpref12=Audio-CD: Lade Tracks ...');
    Add('mpref13=XCD: Lade Verzeichnisstruktur ...');
    Add('mpref14=XCD: Lade Dateien ...');
    Add('mpref15=Video-CD: Lade Tracks ...');
    Add('epref01=%s: Projekt-Datei nicht gefunden.');
    {Messages - Commandline}
    Add('moutput01=Ausführung beendet.');
    Add('moutput02=Ausführung durch Anwender abgebrochen.');
    {Messages - Init}
    Add('einit01=Die cdrtools konnten nicht (vollständig) gefunden werden!\nFolgende Dateien werden unbedingt benötigt: cdrecord.exe,\nmkisofs.exe. Siehe auch readme.txt.');
    Add('einit02=Die Datei cygwin1.dll konnte nicht gefunden werden! Sie muß\nentweder im cdrtfe-Verzeichnis oder im Suchpfad vorhanden sein.');
    Add('einit03=Es fehlen eine oder mehrere DLLs, die von mkisofs.exe benötigt werden!');
    Add('einit04=cdrtfe hat ein Problem festgestellt. Entweder sind die\nBinaries (cdrecord/mkisofs) beschädigt, oder es gibt ein\nProblem mit der cygwin1.dll (Versionskonflikt bzw.\nInkompatibilität).');
    Add('einit05=Warnung:\nDie Datei cygwin1.dll wurde auch in einem Windows-System-Ordner gefunden.\nDaher kann die Verwendung der mitgelieferten DLL nicht erzwungen werden.\n ');
    Add('minit01=Ohne die Datei cdda2wav.exe ist das Auslesen von Audio-Tracks nicht möglich.\n ');
    Add('minit02=Ohne die Datei sh.exe ist unter Win9x, ME ein on-the-fly-Brennen nicht möglich.\nSiehe readme.txt für Download-Link.\n ');
    Add('minit03=Ohne die Datei mode2cdmaker.exe kann keine XCDs (Mode 2 Form 2)\nerstellt werden.\n ');
    Add('minit04=Um CUE-Images oder XCDs schreiben zu können, sind die cdrtools ab\nder Version 2.01a24 oder cdrdao.exe nötig.\n ');
    Add('minit05=Es wurde kein Brenner gefunden!\nImages (Daten-Disk, XCD) können dennoch erstellt werden.\n ');
    Add('minit06=Ohne die Datei readcd.exe können keine Images von Disks angelegt weerden.\n ');
    Add('minit07=Mit der Mingw32-Version der cdrtools unter Win9x, ME kann cdrtfe zur\nZeit keine Disks on-the-fly schreiben.\n ');
    Add('minit08=Ohne die Datei vcdimager.exe können keine Video-CDs erstellt werden.\n ');
    Add('minit09=Ohne mpg123.exe werden MP3-Tracks nicht unterstützt.\n ');
    Add('minit10=Ohne oggdec.exe werden Ogg-Vorbis-Tracks nicht unterstützt.\n ');
    Add('minit11=Ohne flac.exe werden FLAC-Tracks nicht unterstützt.\n ');
    Add('minit12=Ohne mac.exe werden APE-Tracks nicht unterstützt.\n ');            
    {Messages - Burning}
    Add('eburn01=Es ist keine Disk eingelegt!');
    Add('eburn02=Diese Disk kann nicht beschrieben werden. Entweder handelt es sich\num eine CD/DVD/BD-ROM oder die Disk wurde bereits abgeschlossen.');
    Add('eburn03=Diese Disk enthält bereits Daten und könnte fortgesetzt werden. Dafür\ndie Option ''vorhandene Sessions importieren'' aktivieren. Geschieht\ndies nicht, werden die vorhandenen Sessions unsichtbar.');
    Add('eburn04=Auf dieser Disk sind keine Sessions vorhanden. Trotzdem fortfahren?');
    Add('eburn05=Sessions einlesen fehlgeschlagen');
    Add('eburn06=Nicht genügend Speicher auf der Disk!\n');
    Add('eburn07=%s MiByte sind verfügbar.');
    Add('eburn08=Diese CD enthält bereits eine Daten-Session.\nAudio-Tracks können nicht hinzugefügt werden.');
    Add('eburn09=Erste zu schreibende Adresse konnte nicht gelesen werden.\nFalls es sich um eine CD-RW handelt, muß diese erst gelöscht werden.');
    Add('eburn10=DVDs müssen im DAO-Modus geschrieben werden!');
    Add('eburn11=Sorry, noch keine Unterstützung für Multisession-/Multiborder-DVDs.');
    Add('eburn12=Unbekanntes DVD-Medium, unbekannte Kapazität. Trotzdem fortfahren?');
    Add('eburn13=Sie können auch die Art des Mediums angeben.');
    Add('eburn14=\n%s MiByte (%d Sektoren) zuviel.');
    Add('eburn15=\n%s MiByte werden benötigt.');
    Add('eburn16=Soll die Disk automatisch gelöscht werden?');
    Add('eburn17=Diese DVD+RW enthält Daten. Soll sie überschrieben werden?');
    Add('eburn18=Sie sind dabei, cdrtfe zu beenden, obwohl noch ein Kommando-\nzeilenprogramm läuft. Dies könnte Probleme verursachen (z.B.\nSysteminstabilitäten).\nTrotzdem beenden?');
    Add('eburn19=Bei DVD+R(W)s ist keine Simulation möglich.');
    Add('eburn20=Image kann nicht geschrieben werden.\nNicht genügend Speicher auf Laufwerk %s.');
    Add('eburn21=Es soll eine Multisession-Disk im Disk-at-Once-Modus (DAO) geschrieben werden.\nDies wird nicht von allen Laufwerken unterstützt und kann zu unerwünschenten\nErgebnissen führen. Trotzdem fortfahren?');
    Add('mburn01=Alles bereit. Soll der Brennvorgang gestartet werden?');
    Add('mburn02=Brennvorgang starten?');
    Add('mburn03=In der Shell ausgeführte Befehlszeile:');
    Add('mburn04=%s verfügbar.');
    Add('mburn05=Alles bereit. Soll der Vorgang gestartet werden?\nDaten auf der Disk werden unwiederbringlich gelöscht!');
    Add('mburn06=Disk löschen?');
    Add('mburn07=Gesamtkapazität: %s MiByte; %s:%s min');
    Add('mburn08=noch verfügbar : %s MiByte; %s:%s min');
    Add('mburn09=Diese Disk ist bereits fixiert.');
    Add('mburn10=Mode2CDMaker wird mit folgenden Optionen gestartet:');
    Add('mburn11=Disk fixieren?');
    Add('mburn12=Image-Größe ermitteln ...');
    Add('mburn13=Überprüfe Disk ...');
    Add('mburn14=%s MiByte zu schreiben; %s MiByte verbleibend.\n\n');
    Add('mburn15=DVD+RW-Disks können nicht gelöscht werden.\nSie werden einfach überschrieben.');
    Add('mburn16=Bitte Ziel-Disk einlegen.\nSoll der Brennvorgang gestartet werden?');
    {Messages - Verify}
    Add('mverify01=Vergleiche Dateien ...');
    Add('mverify02=%d Fehler gefunden.');
    Add('mverify03=Vergleich durch Anwender abgebrochen!');
    Add('mverify04=Lese Inhaltsverzeichnis der Disk ein. Bitte warten ...');
    Add('mverify05=%d Dateien werden mit den Quelldateien verglichen.');
    Add('everify01=Konnte Disk nicht finden, Vergleich abgebrochen!');
    Add('everify02=Fehler! Dateien nicht identisch: %s <-> %s');
    Add('everify03=Konnte Reload nicht durchführen.\nLegen Sie die Disk manuell ein und wählen Sie ''OK'', um den Vergleich zu starten.\nOder wählen Sie ''Abbrechen'', um den Vergleich nicht durchzuführen.');
    Add('everify04=Fehler beim Einlesen der Disk');
    Add('everify05=Fehler beim erneuten Einlesen der Disk. Vergleich abgebrochen.');
    Add('everify06=Fehler! Datei nicht gefunden   : %s');
    {Messages - CD Text}
    Add('ccdtext01=Titel');
    Add('ccdtext02=Interpret');
    Add('ccdtext03=Pause');
    Add('ecdtext01=Option ''CD-Text schreiben'' gewählt, aber\nkeine CD-Text-Informationen vorhanden!');
    Add('ecdtext02=Zu viele CD-Text-Daten!');
    Add('epause01=Die Anzahl der Sekunden oder Sektoren muß als\nnicht negative, ganze Zahl angegeben werden.');
    {Messages - Duplicates}
    Add('mdup01=Suche identische Dateien ...');
    Add('mdup02=Dateien sind identisch: %s <-> %s');
    Add('mdup03=%s in %d doppelten Datei(en) (%s).');
    {Messages - Lang}
    Add('mlang01=Sprache wählen');
    Add('mlang02=Ok');
    Add('mlang03=Abbrechen');
    {Messages - XCD infofile}
    Add('mxcd01=Erstelle Info-Datei xcd.crc ...');
    Add('mxcd02=Lese Datei ...');
    {Messages - Video CD}
    Add('evcd01=Keine MPEG-Dateien ausgewählt!');
    {Messages - DVD Video}
    Add('edvdv01=Bitte Quellverzeichnis angeben!');
    {Messages - Import Session}
    Add('msess01=Session auswählen');
    Add('msess02=Fortzusetzende Session:');
    Add('msess03=Session');
    {Messages - Select Writer}
    Add('mselw01=Brennerauswahl');
    Add('mselw02=Bitte die zu nutzenden Brenner auswählen');
    {Dialog-Beschreibungen}
    Add('desc01=Ausgabe der Kommandozeilenprogramme');
    Add('desc02=Einstellungen für das Dateisystem der Disk');
    Add('desc03=Einstellungen für das Schreiben der Disk');
    Add('desc04=Einstellungen für das Schreiben von Audio-CDs');
    Add('desc05=Eigenschaften der einzelnen Audio-Tracks');
    Add('desc06=Potentielle Fehler im Dateisystem der Disk korrigieren');
    Add('desc07=Einstellungen für das Auslesen von Audio-CD-Tracks');
    Add('desc08=Einstellungen für die Erstellung von XCDs');
    Add('desc09=Einstellungen für das Schreiben von (S)VCDs');
    Add('desc10=Allgemeine Programmeinstellungen von cdrtfe');
  end;
end;

{ LangChange -------------------------------------------------------------------

  löst das OnLangChangeEvent aus.                                              }

procedure TLang.LangChange;
begin
  if Assigned(FOnLangChange) then FOnLangChange;
end;

{ GetIniPath -------------------------------------------------------------------

  GetIniPath bestimmt den Pfad zur cdrtfe.ini. Die identische Funktion aus
  cl_settings.pas kann nicht verwendet werden, da TSettings später instantiiert
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

{ LangIniFileFound -------------------------------------------------------------

  True, wenn \translations\cdrtfe_lang.ini gefunden wurde.                     }

function TLang.LangIniFileFound: Boolean;
begin
  Result := FileExists(StartUpDir + cLangDir + cLangFileName);
end;

{ TranslationFileFound ---------------------------------------------------------

  True, wenn \translations\<lang>\cdrtfe_lang.ini gefunden wurde.              }

function TLang.TranslationFileFound: Boolean;
begin
  Result := FileExists(StartUpDir + cLangDir + '\' +
                       LowerCase(FCurrentLangName) + cLangFileName);
end;

{ LangListSort -----------------------------------------------------------------

  sortiert die Liste nach den Namen der Sprachen.                              }

procedure TLang.LangListSort;
begin
  SortListByValue(FLangList);
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
    LangFile := TIniFile.Create(StartUpDir + cLangDir + cLangFileName);
    FDefaultLang := LangFile.ReadString('Languages', 'Default', '');
    LangFile.Free;
    {$IFDEF DebugLang}
    Deb('cdrtfe_lang.ini: DefaultLang=' + FDefaultLang, 1);
    {$ENDIF}
  end;
  FDefaultLangName := FLangList.Values[FDefaultLang];
  FCurrentLang := FDefaultLang;
  FCurrentLangName := FDefaultLangName;
  {$IFDEF DebugLang}
  Deb('Translation name: ' + FDefaultLangName, 1);
  Deb('File            : ' + StartUpDir + cLangDir + '\' +
                             LowerCase(FCurrentLangName) + cLangFileName, 1);
  {$ENDIF}
end;

{ SetDefaultLang ---------------------------------------------------------------

  setzt Suffix für die Default-Sprache.                                        }

procedure TLang.SetDefaultLang;
var IniFile : TIniFile;
begin
  if FIniFileFound then
  begin
    IniFile := TIniFile.Create(FIniFile);
    IniFile.WriteString('General', 'DefaultLang', FCurrentLang);
    IniFile.Free;
    {$IFDEF DebugLang}
    Deb('cdrtfe.ini     : DefaultLang=' + FCurrentLang + ' saved.', 1);
    {$ENDIF}
  end else
  begin
    IniFile := TIniFile.Create(StartUpDir + cLangDir + cLangFileName);
    IniFile.WriteString('Languages', 'Default', FCurrentLang);
    IniFile.Free;
    {$IFDEF DebugLang}
    Deb('cdrtfe_lang.ini: Default=' + FCurrentLang + ' saved.', 1);
    {$ENDIF}
  end;
  FDefaultLang := FCurrentLang;
end;

{ GetLangList ------------------------------------------------------------------

  liest die Liste aller verfügbaren Sprachen ein.                              }

procedure TLang.GetLangList;
var LangFile: TIniFile;
    Temp    : string;
begin
  LangFile := TIniFile.Create(StartUpDir + cLangDir + cLangFileName);
  LangFile.ReadSectionValues('Languages', FLangList);
  LangFile.Free;
  {Defaulteintrag entfernen}
  Temp := FLangList.Values['Default'];
  FLangList.Delete(FLangList.IndexOf('Default=' + Temp));
  LangListSort;
  {$IFDEF DebugLang}
  FormDebug.Memo3.Lines.Assign(FLangList);
  {$ENDIF}
end;

{ LoadLanguage -----------------------------------------------------------------

  LoadLanguage lädt aus der Datei cdrtfe_lang.ini die dort eingestellte Sprache
  und speichert die Daten in den Stringlisten FMessageStrings und
  FComponentStrings.                                                           }

procedure TLang.LoadLanguage;
var NewStrings: TStringList;
    List      : TStringList;
    i         : Integer;
    Ok        : Boolean;
begin
  NewStrings := TSTringList.Create;
  List := TStringList.Create;
  {gesamte Sprachdatei laden}
  List.LoadFromFile(StartUpDir + cLangDir + '\' + LowerCase(FCurrentLangName) +
                    cLangFileName);
  {MessageStrings laden}
  Ok := GetSection(List, NewStrings, '[Messages]', '');
  if Ok then
  begin
    {falls in cdrtfe_lang.ini Einträge fehlen, die Original-Einträge nehmen}
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
  Ok := GetSection(List, NewStrings, '[Components]', '');
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
  FLangFileFound    := False;
  FMessageStrings   := TStringList.Create;
  FComponentStrings := TStringList.Create;
  FLangList         := TStringList.Create;
  InitMessageStrings;
  {\translation\cdrtfe_lang.ini suchen}
  FLangIniFileFound := LangIniFileFound;
  if FLangIniFileFound then
  begin
    {$IFDEF WriteLogFile}
    AddLogCode(1400);
    {$ENDIF}
    {List der verfügbaren Sprachen einlesen}
    GetLangList;
    {cdrtfe.ini suchen}
    FIniFile := GetIniPath;
    {Defaultwert auslesen}
    GetDefaultLang;
    {\translation\<lang>\cdrtfe_lang.ini suchen}
    FLangFileFound := TranslationFileFound;
    if FLangFileFound then
    begin
      AddLogCode(1401);
      {Sprachinformationen laden}
      LoadLanguage;
    end;
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

  GMS (GetMessageString) ermöglicht den Zugriff auf einzelne Strings aus der
  StringList MessageString über die zugehörige ID.                             }

function TLang.GMS(const id: string): string;
const CRLF = #13#10;
begin
  Result := FMessageStrings.Values[id];
  Result := ReplaceString(Result, '\n', CRLF);
end;

{ SetFormLang ------------------------------------------------------------------

  SetFormLang ersetzt die aktuellen String-Properties des als Argument über-
  gebenen Forms durch Strings in der aus cdrt_lang.ini geladenen Sprache. Sollte
  diese Datei fehlen, bleiben die Stringproperties unverändert.                }

procedure TLang.SetFormLang(Form: TForm);

  procedure LoadComps(Comp: TComponent; Prefix: string);
  var j, k        : Integer;
      CurrCompName: string;
      CurrCompCap : string;
      CurrCompHint: string;
      Name        : string;
      Value       : string;
      C           : TComponent;
  begin
    if (Comp is TForm) then
    begin
      CurrCompName := (Comp as TForm).Name;
      CurrCompCap  := (Comp as TForm).Caption;
      CurrCompHint := (Comp as TForm).Hint;
    end else
    if (Comp is TFrame) then
    begin
      CurrCompName := (Comp as TFrame).Name;
      CurrCompCap  := '';
      CurrCompHint := (Comp as TFrame).Hint;
    end;
    CurrCompName := Prefix + CurrCompName;
    {Form.Caption}
    Name := CurrCompName + '.Caption';
    Value := FComponentStrings.Values[Name];
    if Value <> '' then
    begin
      if (Comp is TForm) then (Comp as TForm).Caption := Value;
    end;
    {Form.Hint}
    Name := CurrCompName + '.Hint';
    Value := FComponentStrings.Values[Name];
    if Value <> '' then
    begin
      Form.Hint := Value;
    end;
    {jetzt die Komponenten des Forms}
    for j := 0 to Comp.ComponentCount - 1 do
    begin
      C := Comp.Components[j];
      {C.Caption}
      if PropertyExists(C, 'Caption') then
      begin
        Name := CurrCompName + '.' + C.Name + '.Caption';
        Value := FComponentStrings.Values[Name];
        if Value <> '' then
        begin
          SetCompProp(C, 'Caption', Value);
        end;
      end;
      {C.Hint}
      if PropertyExists(C, 'Hint') then
      begin
        Name := CurrCompName + '.' + C.Name + '.Hint';
        Value := FComponentStrings.Values[Name];
        if Value <> '' then
        begin
          SetCompProp(C, 'Hint', Value);
          {standarmäßig sind die Hints abgeschaltet, daher muß die Anzeige hier
           explizit eingeschaltet werden. Ob es auf diese Art sicher ist?}
          (C as TControl).ShowHint := True;
        end;
      end;
      {C.Title}
      if PropertyExists(C, 'Title') then
      begin
        Name := CurrCompName + '.' + C.Name + '.Title';
        Value := FComponentStrings.Values[Name];
        if Value <> '' then
        begin
          SetCompProp(C, 'Caption', Value);
        end;
      end;
      {C.DisplayLabel}
      if PropertyExists(C, 'DisplayLabel') then
      begin
        Name := CurrCompName + '.' + C.Name + '.DisplayLabel';
        Value := FComponentStrings.Values[Name];
        if Value <> '' then
        begin
          SetCompProp(C, 'Caption', Value);
        end;
      end;
      {C.Filter}
      if PropertyExists(C, 'Filter') then
      begin
        Name := CurrCompName + '.' + C.Name + '.Filter';
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
            Name := CurrCompName + '.' + C.Name + '.Lines' + IntToStr(k);
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
            Name := CurrCompName + '.' + C.Name + '.Items' + IntToStr(k);
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
              Name := CurrCompName + '.' + C.Name + '.Items' + IntToStr(k);
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
            Name := CurrCompName + '.' + C.Name + '.Columns' + IntToStr(k) +
                    '.Caption';
            Value := FComponentStrings.Values[Name];
            if Value <> '' then
            begin
              (C as TListView).Columns[k].Caption := Value
            end;
          end;
        end;
      end;
      {C ist ein Frame}
      if (C is TFrame) then LoadComps(C, CurrCompName + '.');
    end;
  end;

begin
  if FLangFileFound then
  begin
    LoadComps(Form, '');
  end;
end;

{ SelectLanguage ---------------------------------------------------------------

  zeigt ein Auswahlfenster an, mit dem die aktive Sprache geändert werden kann.
  Wenn die Sprache geändert wurde ist der Ruckgabewert True.                   }

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
      FCurrentLangName := FLangList.Values[FCurrentLang];
      SetDefaultLang;
      LoadLanguage;
      LangChange;
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

{ CreateLangSubMenue -----------------------------------------------------------

  baut unterhalb von MenuItem ein Menü auf.                                    }

procedure TLang.CreateLangSubMenu(MenuItem: TMenuItem);
var NewItem: TMenuItem;
    i      : Integer;
begin
  for i := 0 to FLangList.Count - 1 do
  begin
    NewItem := TMenuItem.Create(MenuItem);
    NewItem.Caption := FLangList.Values[FLangList.Names[i]];
    NewItem.OnClick := LangMenuItemClick;
    NewItem.Tag := i;
    NewItem.RadioItem := True;
    if FLangList.Names[i] = FCurrentLang then NewItem.Checked :=True;
    MenuItem.Add(NewItem);
  end;
end;

{ LangMenuItemClick ------------------------------------------------------------

  Sprache abhängig von Menüauswahl setzen.                                     }

procedure TLang.LangMenuItemClick(Sender: TObject);
var NewLang: string;
begin
  (Sender as TMenuItem).Checked := True;
  NewLang := FLangList.Names[(Sender as TMenuItem).Tag];
  if NewLang <> FCurrentLang then
  begin
    FCurrentLang := NewLang;
    FCurrentLangName := FLangList.Values[NewLang];
    SetDefaultLang;
    LoadLanguage;
    LangChange;
  end;
end;

{ weitere Prozeduren --------------------------------------------------------- }

{ ExportStringProperties -------------------------------------------------------

  ExportStringProperties schreibt alle String-Poperties aller Komponenten des
  Programms in die Textdatei StartUpDir\StringProps.txt.                       }

procedure ExportStringProperties;
var OutFile: TIniFile;
    i      : Integer;

  {lokale Prozedur von ExportProperties}
  procedure SaveComps(Comp: TComponent; Prefix: string);
  var j, k        : Integer;
      Section     : string;
      CurrCompName: string;
      CurrCompCap : string;
      CurrCompHint: string;
      Name        : string;
      Value       : string;
      C           : TComponent;
  begin
    Section := 'Lang1';
    if (Comp is TForm) then
    begin
      CurrCompName := (Comp as TForm).Name;
      CurrCompCap  := (Comp as TForm).Caption;
      CurrCompHint := (Comp as TForm).Hint;
    end else
    if (Comp is TFrame) then
    begin
      CurrCompName := (Comp as TFrame).Name;
      CurrCompCap  := '';
      CurrCompHint := (Comp as TFrame).Hint;
    end;
    CurrCompName := Prefix + CurrCompName;
    {Form.Caption}
    Name := CurrCompName + '.Caption';
    Value := CurrCompCap;
    if Value <> '' then OutFile.WriteString(Section, Name, Value);
    {Form.Hint}
    Name := CurrCompName + '.Hint';
    Value := CurrCompHint;
    if Value <> '' then OutFile.WriteString(Section, Name, Value);
    {jetzt die Komponenten des Forms}
    for j := 0 to Comp.ComponentCount - 1 do
    begin
      C := Comp.Components[j];
      {C.Caption}
      if PropertyExists(C, 'Caption') then
      begin
        Name := CurrCompName + '.' + C.Name + '.Caption';
        Value := GetCompProp(C, 'Caption');
        if Value <> '' then OutFile.WriteString(Section, Name, Value);
      end;
      {C.Hint}
      if PropertyExists(C, 'Hint') then
      begin
        Name := CurrCompName + '.' + C.Name + '.Hint';
        Value := GetCompProp(C, 'Hint');
        if Value <> '' then OutFile.WriteString(Section, Name, Value);
      end;
      {C.Title}
      if PropertyExists(C, 'Title') then
      begin
        Name := CurrCompName + '.' + C.Name + '.Title';
        Value := GetCompProp(C, 'Title');
        if Value <> '' then OutFile.WriteString(Section, Name, Value);
      end;
      {C.DisplayLabel}
      if PropertyExists(C, 'DisplayLabel') then
      begin
        Name := CurrCompName + '.' + C.Name + '.DisplayLabel';
        Value := GetCompProp(C, 'DisplayLabel');
        if Value <> '' then OutFile.WriteString(Section, Name, Value);
      end;
      {C.Filter}
      if PropertyExists(C, 'Filter') then
      begin
        Name := CurrCompName + '.' + C.Name + '.Filter';
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
            Name := CurrCompName + '.' + C.Name + '.Lines' + IntToStr(k);
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
            Name := CurrCompName + '.' + C.Name + '.Items' + IntToStr(k);
            Value := (C as TListBox).Items[k];
            if Value <> '' then OutFile.WriteString(Section, Name, Value);
          end;
        end else
        begin
          if C is TComboBox then
          begin
            for k := 0 to (C as TComboBox).Items.Count - 1 do
            begin
              Name := CurrCompName + '.' + C.Name + '.Items' + IntToStr(k);
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
            Name := CurrCompName + '.' + C.Name + '.Columns' + IntToStr(k) +
                    '.Caption';
            Value := (C as TListView).Columns[k].Caption;
            if Value <> '' then OutFile.WriteString(Section, Name, Value);
          end;
        end;
      end;
      {C ist ein Frame}
      if (C is TFrame) then SaveComps(C, CurrCompName + '.');
    end;
  end;

begin
  OutFile := TIniFile.Create(StartUpDir + '\StringProps.txt');
  for i:= 0 to Application.ComponentCount - 1 do
  begin
    if (Application.Components[i] is TForm) then
    begin
      SaveComps(Application.Components[i], '');
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
  ClientHeight := 118; //70; // Height := 98;
  ClientWidth := 220; // Width := 227;
  OnShow := FormShow;
  {Banner}
  FrameTopBanner1 := TFrameTopBanner.Create(Self);
  FrameTopBanner1.Parent := Self;
  FrameTopBanner1.Top := 0;
  FrameTopBanner1.Left := 0;
  FrameTopBanner1.Width := ClientWidth;
  FrameTopBanner1.Init(Self.Caption, '', 'grad1');
  {ComboBox}
  ComboBox := TComboBox.Create(Self);
  with ComboBox do
  begin
    Parent := Self;
    Left := 8;
    Top := 56; //8;
    Height := 98;
    Width := 203;
    Visible := True;
    Style := csDropDownList;
    Hint := 'Select language';
    ShowHint := True;
  end;
  {Ok-Button}
  ButtonOk := TButton.Create(Self);
  with ButtonOk do
  begin
    Parent := Self;
    Left := 56;
    Top := 88; //40;
    Height := 25;
    Width := 75;
    Caption := FLang.GMS('mlang02');
    Hint := '[Ok]';
    ShowHint := True;
    OnClick := ButtonClick;
  end;
  {Cancel-Button}
  ButtonCancel := TButton.Create(Self);
  with ButtonCancel do
  begin
    Parent := Self;
    Left := 136;
    Top := 88; //40;
    Height := 25;
    Width := 75;
    Caption := FLang.GMS('mlang03');
    Hint := '[Cancel]';
    ShowHint := True;
    ModalResult := mrCancel;
    Cancel := True;
  end;
  {Liste übernehmen}
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
