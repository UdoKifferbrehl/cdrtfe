{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  directives.inc: Symbol-Definitionen

  Copyright (c) 2004-2007 Oliver Valencia

  letzte Änderung  20.01.2007

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  - Damit diese Symbole in einer Unit gültig sind, muß directives.inc mit $I
    bzw. $INCLUDE eingebunden werden.

  - um die entsprechende Funktion zu aktivieren, das 'x' vor dem Symbolnamen
    entfernen
}

(* ------------------------------------------------------------ Delphiversion *)

{$I compiler.inc}


(* ------------------------------------------------------------------- Lizenz *)

{$DEFINE xGPLonly}
         // Wenn dieses Symbol definiert ist, werden nur die Teile von cdrtfe
         // kompiliert, die unter der GPL oder einer kompatiblen Lizenz stehen.
         // Einige Funktionen stehen dann aber nicht zur Verfügung.
         //
         // If this symbol is defines only the GPL'ed (and compatible) parts of
         // cdrtfe will be compiled. In this case, some functions are not
         // available.


(* -------------------------------------------------------------- Testversion *)

{$DEFINE xTestVersion}
         // kennzeichnet cdrtfe als Testversion
         //    - betrifft: frm_about.pas


(* -------------------------------------------- Fortschritt in Taskbar zeigen *)

{$DEFINE ShowProgressTaskBar}
         // Fortschritt der Aktionen im Taskbar-Eintrag zeigen
         //    - betrifft: cl_actionthread.pas, cl_logwindow.pas


(* ------------------------------------- Einstellungen in Registry spreichern *)

{$DEFINE xTitleFirst}
         // Taskbar-Eintrag: cdrtfe [aktiv] statt [aktiv] cdrtfe
         //    - betrifft: frm_amin.pas, cl_logwindow.pas


(* ------------------------------------- Einstellungen in Registry spreichern *)

{$DEFINE xRegistrySettings}
         // Einstellungen werden auf Wunsch in der Registry gespeichert und beim
         // Programmstart automatisch geladen.
         //    - betrifft: frm_main.pas, frm_settings.pas, cl_settings.pas


(* ----------------------------------- Einstellungen in cdrtfe.ini spreichern *)

{$DEFINE IniSettings}
         // Einstellungen werden auf Wunsch in cdrtfe.ini gespeichert und beim
         // Programmstart automatisch geladen.
         //    - betrifft: frm_main.pas, frm_settings.pas, cl_settings.pas

{$IFDEF IniSettings}{$UNDEF RegistrySettings}{$ENDIF}
         // Dies stellt sicher, daß die Einstellungen nicht sowohl in der
         // Registry als auch in der cdrtfe.ini gesichert werden.
         // Falls beide Direktiven aktiv sind, hat die Speicherung in der
         // Ini-Datei Vorrang.


(* ----------------------------------------------------- QuoteCommandlinePath *)

{$DEFINE QuoteCommandlinePath}
         // Wenn dieses Symbol definiert ist, wird der Pfad des Kommandozeilen-
         // programmes in doppelte Anführungszeichen (") gesetzt, wenn er
         // Leerzeichen enthält.
         //    - betrifft: cl_action.pas, f_init.pas


(* ----------------------------------------------------- Bestätigungs-Dialoge *)

{$DEFINE Confirm}
         // aktiviert die Sicherheitsabfrage vor dem Brennen
         //    - gilt für Daten-CD, Audio-CD, XCD, Brennen von Images
         //    - betrifft: cl_action


(* -------------------------------------------- expliziter Hinweis auf Fehler *)

{$DEFINE xShowCmdError}
         // Falls beim Ausführen der Kommandozeile ein Fehler auftritt (d.h.
         // ProcessExitCode <> 0), wird eine Warnung ausgegeben.
         //    - betrifft: frm_main.pas, cl_actionthread.pas, cl_lang.pas


(* -------------------------------------------------------- OLE-Drag-and-Drop *)

{$DEFINE UseOLEDragDrop}
         // OLE-Funktionen für das Drag-and-Drop aus dem Explorer in den Tree-
         // View von cdrtfe verwenden.
         //    - betrifft: frm_main.pas


(* --------------------------------------------------------- Optionen togglen *)

{$DEFINE AllowToggle}
         // erlaubt das Umstellen von Optionen durch Klick auf ein Label im
         // OptionPanel
         //    - betrifft: frm_main.pas

{$IFDEF AllowToggle}
         // die verschiedenen Möglichkeiten, anzuzeigen, daß ein Label klickbar
         // ist, machen nur Sinn, wenn das Togglen erlaubt ist

{$DEFINE xMouseOverLabelHighlight}
         // erzeugt einen Highlight-Effekt, wenn sich der Mauszeiger über einem
         // anklickbaren Option-Label befindet
         //    - betrifft: frm_main.pas

{$DEFINE MouseOverLabelCursor}
         // verwendet einen anderen Cursor, wenn sich der Mauszeiger über einem
         // anklickbaren Option-Label befindet.
         //    - betrifft: frm_main.pas

{$ENDIF}


(* ----------------------------------------------------- spezielle Funktionen *)

{$DEFINE xCreateAllForms}
         // erzeugt bei Doppelklick auf Form1 alle anderen Forms, damit deren
         // String-Properties ausgelesen werden können
         //    - betrifft: frm_main.pas

{$DEFINE xExportStrings}
         // Strings in Datei schreiben
         //    - Stringproperties aller Controls und alle Messagestrings
         //    - auszulösen durch Doppelklick auf Hintergrund von Form 1
         //    - betrifft: frm_main.pas

{$DEFINE xExportControls}
         // Größe und Position aller Controls exportieren
         //    - auszulösen durch Doppelklick auf Hintergrund von Form 1
         //    - betriff: frm_main.pas

{$DEFINE xExportFontList}
         // Alle verwendeten Fonts ausgeben
         //    - auszulösen durch Doppelklick auf Hintergrund von Form 1
         //    - betrifft: frm_main.pas


(* ---------------------------------------------------------- Verify-Funktion *)

{$DEFINE BitwiseVerify}
         // Bitweiser Vergleich
         //    - Ist dieses Symbol definiert, wird statt des Vergleiches über
         //      CRC32-Prüfsummen ein bitweiser Vergleich der Dateien vorge-
         //      nommen.
         //    - betrifft: cl_verifythread.pas

{$DEFINE xVerifyShowDetails}
         // ein paar mehr (Debug-)Informationen anzeigen
         //    - betrifft: cl_verifythread.pas

{$DEFINE xTestVerify}
         // zum Test der Verify-Funktion
         //    - Doppelklick auf Hintergrund von Form 1 löst Test aus
         //    - Brennvorgang wird übersprungen, daher muß eine CD mit Daten
         //      vorliegen, diese Dateien müssen zum Projekt hinzugefügt sein
         //    - betrift: frm_main.pas

{$DEFINE xNoReload}
         // Reload beim Verify für Testzwecke abschalten
         //    - betriff: cl_verifythread.pas

{$DEFINE xForceReloadError}
         // immer Fehler beim Reload annehmen
         //    - betrifft: cl_verifythread.pas

{$DEFINE xUseMD5}
         // beim Suchen nach identischen Dateien MD5-Hashes statt CRC32
         // verwenden
         //    - betrifft: cl_verifythread.pas


(* --------------------------------------------------------- CD-Text-Funktion *)

{$DEFINE xAddCDText}
         // generiert CD-Text zu der aktuellen Trackliste
         //    - Doppelklick auf Hintergrund von Form 1 löst Funktion aus
         //    - betrifft: frm_main.pas


(* ----------------------------------------------------------------- NoDevice *)

{$DEFINE xNoDevice}
         // simuliert das Nicht-Vorhandensein von Laufwerken
         //    - betrifft: cl_devices.pas

{$DEFINE xUseDummyDevices}
         // simuliert eine größere Laufwerksliste
         //    - betrifft: cl_devices.pas


(* -------------------------------------------------------------- DVD-Support *)

{$DEFINE DVDSupport}

{$IFDEF DVDSupport}
         // Die folgenden Symbole sollen nur berücksichtigt werden, wenn cdrtfe
         // mit DVD-Unterstützung kompiliert wird.

{$DEFINE LargeProject}
         // Unterstützung für Projekte > 2 GiByte
         //   - Für Berechnungen der Gesamtgröße der zu schreibenden Daten wird
         //     der Typ Comp statt Integer verwendet.
         //   - betrifft: frm_main.pas, cl_projectdata.pas, cl_cd.pas,
         //     cl_action.pas, frm_audiocd_tracks.pas, f_chekproject.pas,
         //     f_strings.pas

{$DEFINE LargeFiles}
         // Unterstützung für Dateien > 2 GiByte
         //   - Für Dateigrößen wird der Type Comp statt Integer verwendet.
         //   - Die Funktion GetFileSize verwendet Daten aus TWin32FindData
         //   - betrifft:

{$DEFINE xForceUnknownMedium}
         // Erzwingt das Nicht-Erkennen des DVD-Rohlings. Zu Testzwecken.
         //   - betrifft: f_diskinfo.pas

{$DEFINE UseCurrentProfile}
         // Verwendet zur Erkennung des DVD-Typs die Angabe von cdrecord zum
         // Current Profile. Andernfalls wird die Angabe zum Booktype benutzt.
         //   - betrifft: f_diskinfo.pas

{$ENDIF}


(* ------------------------------------------------------------- GetDOSOutput *)

{$DEFINE ThreadedGetDOSOutput}
         // Die internen Aufrufe der Kommandozeilenprogramme erfolgen in einem
         // eigenen Thread. Damit wird es möglich, auf Aufforderungen (z.B.
         // 'Reload disk, press ENTER' zu reagieren.
         //   - betrifft: f_process.pas

         
(* -------------------------------------------------------------- Zeitmessung *)

{$DEFINE xShowTime}
         // Die Dauer bestimmter Aktionen messen.
         //   - nur wenn ShowTime definiert ist, werden die anderen Symbole
         //     berücksichtigt.

{$IFDEF ShowTime}

{$DEFINE xShowVerifyTime}
         // Dauer des Vergleichs anzeigen
         //   - betrifft: cl_verifythread.pas

{$DEFINE xShowTimeAddFolder}
         // zeigt die Dauer des Hinzufügens eines Ordners an
         //   - betrifft: frm_main.pas

{$DEFINE xShowTimeCheckFS}
         // zeigt die Dauer der Dateisystemüberprüfung an
         //   - betrifft: frm_main.pas

{$DEFINE xShowExecutionTime}
         // Gesamtdauer der Ausführung
         //   - betrifft: frm_main.pas

{$DEFINE xShowStartupTime}
         // Startzeit anzeigen (frm_main initialization - 
         //   - betrifft: frm_main.pas

{$ENDIF}


(* ------------------------------------------------------------------ Logfile *)

{$DEFINE xWriteLogfile}
         // schreibt ein Logfile
         //   - betrifft: f_process.pas, cl_devices.pas, cl_logwindow.pas,
         //     frm_main.pas


(* --------------------------------------------------------- ExceptionLogging *)

{$DEFINE ExceptionDlg}
         // fängt Exceptions ab und zeigt Infos an
         //   - betrifft: cdrtfe.dpr, cl_exceptionlog.pas, frm_exceptdlg.pas

{$IFDEF GPLonly}
  {$UNDEF ExceptionDlg}
{$ENDIF}
{$IFNDEF Delphi7Up}
  {$UNDEF ExceptionDlg}
{$ENDIF}


(* ---------------------------------------------------------------- Debugging *)

{$DEFINE xShowDebugWindow}
         // bindet die Unit frm_debug.pas ein und zeigt beim Start
         // automatisch das Debugfenster an
         //   - nur wenn ShowDebugWindow definiert ist, werden die anderen
         //     DebugSymbole brücksichtigt
         //   - betrifft: frm_main.pas, frm_debug.pas, cl_projectdata.pas,
         //     cl_cd.pas, cl_settings.pas, cl_filetypeinfo.pas, cl_lang.pas

{$IFDEF ShowDebugWindow}
         // Die folgenden Symbole sollten nur einzeln verwendet werden, da
         // zur Darstellung der Informationen stets die selben Memos verwendet
         // werden.

{$DEFINE xDebugMMkC}
         // Anzeige der Zwischenschritte beim Bearbeiten der Pfadlisten
         //   - betrifft: f_cygwin.pas

{$DEFINE xDebugFileLists}
         // Anzeige der internen Dateilisten:
         //   - für die Anzeige wird das Debugfenster verwendet
         //   - betrifft: frm_main.pas

{$DEFINE xDebugDVDVideoLists}
         // Anzeige der gefundenen Einträge im Quellordner
         //   - betrifft: cl_cd.pas

{$DEFINE xDebugAddFiles}
         // Anzeige der Prozeduraufrufe, wenn Dateien oder Ordner
         // hinzugefügt werden
         //   - betrifft: cl_cd.pas

{$DEFINE xDebugAddFilesDragDrop}
         // Anzeige der Prozedureaufrufe, wenn Dateien oder Ordner
         // per Drag-and-Drop hinzugefügt werden
         //   - betrifft frm_main.pas

{$DEFINE xDebugDeleteAll}
         // Anzeige der Funktionsaufrufe, wenn alles gelöscht werden soll
         //   - betrifft: cl_cd.pas

{$DEFINE xDebugFileTypeInfoList}
         // Anzeige der FileTypeInfoList
         //   - Anzeige der gesamten Liste
         //   - Anzeige der Treffer/Fehler
         //   - betrifft: cl_filetypeinfo.pas

{$DEFINE xDebugSort}
         // Anzeige der sortierten Ordner
         //   - betrifft frm_main.pas

{$DEFINE xDebugGetFolderSize}
         // Anzeige der Funktionsaufrufe und Zwischenergebnisse
         //   - betrifft: cd_cd.pas

{$DEFINE xDebugUpdateGauges}
         // Anzeige aller Projektinfos
         //   - Anzeige, wann Properties aktualisiert werden
         //   - betrifft: frm_main.pas, cl_cd.pas

{$DEFINE xDebugSettings}
         // Anzeige der internen Einstellungen
         //   - betrifft: frm_main.pas, cl_settings.pas

{$DEFINE xDebugMaxFileNameLength}
         // Anzeige der maximalen Dateinamenlänge
         //   - betrifft: frm_main.pas

{$DEFINE xDebugErrorLists}
         // Anzeige der Listen mit zu langen Dateinamen und zu tiefen Ordnern
         //   - betrifft: frm_main.pas, cl_cd.pas

{$DEFINE xDebugReadAudioTOC}
         // zeigt die Zwischenergebnisse beim Auslesen der TOC einer Audio-CD an
         //   - betrifft: cl_action.pas

{$DEFINE xDebugCreateFileLists}
         // Statusinfos
         //   - betrifft: cl_cd.pas

{$DEFINE xDebugAddFileLoad}
         // zeigt Pfadnamen beim Laden von Dateien an
         //   - betrifft: cl_projectdata.pas

{$DEFINE xDebugReadCDInfo}
         // zeigt Zwischenergebnisse in TAction.ReadCDInfo an
         //   - betrifft: cl_action.pas, f_diskinfo.pas

{$DEFINE xShowCDTextInfo}
         // zeigt die CD-Text-Informationen an (Doppelklick auf Hintergrund)
         //   - betrifft: frm_main.pas

{$DEFINE xDebugCreateCDText}
         // zeigt Zwischenergebnisse beim Erstellen von cdtext.dat an
         //   - wird durch Doppelklick auf den Hintergrund von Form1
         //     ausgelöst
         //   - betrifft: frm_main.pas, f_cdtext.pas

{$DEFINE xShowBurnList}
         // zeigt die Pfadliste an, bevor sie für mkisosfs bearbeitet wird
         //   - sowohl BurnList als auch FVList werden angezeigt
         //   - betrifft: cl_action.pas

{$DEFINE xDebugFindDups}
         // hält die Programmausführung nach dem Suchvorgang an
         //   - betrifft: frm_main.pas

{$DEFINE xDebugLang}
         // Anzeige der Sprach-Liste
         //   - betrifft: cl_lang.pas

{$DEFINE xDebugCheckEnv}
         // zeigt Infos zum Environment-Block
         //   - betrifft: f_init.pas

{$DEFINE xDebugCreateInfoFile}
         // hält die Programmausführung nach der Dateierstellung an
         //   - frm_main.pas

{$DEFINE xDebugDeviceList}
         // zeigt den Inhalt aller Laufwerkslisten
         //   - betrifft: cl_devices.pas

{$DEFINE xDebugDriveDetection}
         // Anzeige der cdrecord-Aufrufe zur Laufwerkserkennung
         //   - betrifft: cl_devices.pas

{$DEFINE xDebugDriveSpeedDetection}
         // Anzeige der Zwischenergebnisse zur Speed-Erkennung
         //   - betrifft: cl_devices.pas

{$DEFINE xDebugGetDOSOutputThread}
         // Anzeige der Kommandozeilenaufrufe in GetDOSOutputThreaded
         //   - betrifft: f_process.pas

{$ENDIF}


(* ------------------------------------------- List-View: Unknown Win32 Error *)

{$DEFINE ManualFreeListView}
         // Gibt einen List-View im FormDestroy frei, bevor dies automatisch
         // durch das Programm geschieht. Das verhindert einen unbekannten
         // Win32 Fehler in TWinControl.DestroyWindowHandle
         //   - betrifft frm_main.pas, frm_datacd_fs_error.pas


(* -------------------------------------- RegOpenKeyEx: Handle must be closed *)

{$DEFINE UseRegistryKeyExists}
         // Wenn dieses Symbol definiert ist, wird die Delphi-Funktion
         // TRegistry.KeyExists verwendet, um auf das Vorhandensein eines
         // Registry-Zweiges zu prüfen.
         // Andernfalls wird eine alternative Methode verwendet, da KeyExists
         // unter Umständen Fehler erzeugt. Nähere Erklärungen in
         // f_shellext.pas (Funktion ShellExtensionsRegistered).
         //   - betrifft f_shellext.pas

