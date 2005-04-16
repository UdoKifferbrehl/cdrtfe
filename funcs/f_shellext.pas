{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  f_shellext.pas: ShellExtensions registrieren/löschen

  Copyright (c) 2004-2005 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  01.04.2005

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_shellext.pas stellt Funktionen für die ShellExtensions zur Verfügung:
    * ShellExtemsions registrieren
    * Registry-Einträge wieder entfernen
    * Prüfen: Sind sie Shellextensions registriert


  exportierte Funktionen/Prozeduren:

    RegisterShellExtensions
    ShellExtensionsRegistered: Boolean;
    UnregisterShellExtensions

}

unit f_shellext;

{$I directives.inc}

interface

uses Forms, Windows, Registry, SysUtils;

function ShellExtensionsRegistered: Boolean;
procedure RegisterShellExtensions;
procedure UnregisterShellExtensions;

implementation

uses constant;

{ ShellExtensionsRegistered ----------------------------------------------------

  Prüft anhand der Registry-Einträge, ob die ShellExtensions registriert sind
  (Result = True) oder nicht (Result = False).                                 } 

function ShellExtensionsRegistered: Boolean;
var Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    {$IFDEF UseRegistryKeyExists}
    {Dies ist die einfache Variante, die aber bei MemProof einen Fehler hervor-
     ruft (key handle must be closed), obwohl kein Registry-Key-Handle zum
     Schließen übrig bleibt. Der Fehler wird durch RegOpenKeyEx in der Funktion
     TRegistry.GetKey ausgelöst, wenn der Registry-Zweig nicht vorhanden ist.
     Wahrscheinlich ist es nur ein kosmetisches Problem.}
    Result := Reg.KeyExists('\CLSID\' + CdrtfeClassID);
    {$ELSE}
    {In der alternativen Variante wird versucht den Registry-Zweig zu öffnen.
     Falls er nich vorhanden ist wird er erzeugt. Dann wird auf das Vorhanden-
     sein eines Wertes geprüft. Falls dieser nicht gefunden wird, war der
     Registry-Zweig ursprünglich nicht vorhanden, muß also wieder gelöscht
     werden.}
    if Reg.OpenKey('\CLSID\' + CdrtfeClassID + '\InProcServer32', True) then
    begin
      Result := Reg.ValueExists('ThreadingModel');
      if not Result then
      begin
        Reg.DeleteKey('\CLSID\' + CdrtfeClassID);
      end;
    end else
    begin
      Result := False;
    end;
    {$ENDIF}
  finally
    Reg.Free;
  end;
end;

{ RegisterShellExtensions ------------------------------------------------------

  RegisterShellExtensions träg alle nötigen Informationen in die Registry ein,
  damit die ShellExtensions verwendet werden können. Im UNterschied zu früheren
  Versionen ist eine Aktivierung per Kommandozeile nicht mehr möglich.         }

procedure RegisterShellExtensions;
var Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    with Reg do
    begin
      {ShellExtensions registrieren}
      RootKey := HKEY_CLASSES_ROOT;
      OpenKey('\CLSID\' + CdrtfeClassID, True);
      WriteString('', 'cdrtfe Context Menu Shell Extension');
      OpenKey('\CLSID\' + CdrtfeClassID + '\InProcServer32', True);
      WriteString('', ExtractFilePath(Application.ExeName) +
                      cCdrtfeShlExDll );
      WriteString('ThreadingModel', 'Apartment');
      CreateKey('\*\shellex\ContextMenuHandlers\' + CdrtfeClassID);
      CreateKey('\folder\shellex\ContextMenuHandlers\' + CdrtfeClassID);
      {cdrtfe-Programmpfad eintragen}
      RootKey := HKEY_LOCAL_MACHINE; //HKEY_CURRENT_USER;
      OpenKey('\Software\cdrtfe\Program', True);
      WriteString('Path', ParamStr(0));
    end;
  finally
    Reg.Free;
  end;
  // ShellExtensions registriert.
  // Form1.Memo1.Lines.Add(GMS('mpref01'));
end;

{ UnregisterShellExtensions ----------------------------------------------------

  UnregisterShellExtensions entfernt die zu den ShellExtensions gehörenden Ein-
  träge aus der Registry und deaktiviert diese. Im Gegensatz zu zu früheren
  Versionen ist eine Deaktivierung per Kommandozeile nicht mehr möglich.       }

procedure UnregisterShellExtensions;
var Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    with Reg do
    begin
      {ShellExtensions löschen}
      RootKey := HKEY_CLASSES_ROOT;
      DeleteKey('\CLSID\' + CdrtfeClassID + '\InProcServer32');
      DeleteKey('\CLSID\' + CdrtfeClassID);
      DeleteKey('\*\shellex\ContextMenuHandlers\' + CdrtfeClassID);
      DeleteKey('\folder\shellex\ContextMenuHandlers\' + CdrtfeClassID);
      {cdrtfe-Programmpfad löschen}
      RootKey := HKEY_LOCAL_MACHINE;
      DeleteKey('\Software\cdrtfe');
    end;
  finally
    Reg.Free;
  end;
  // Registryeinträge der ShellExtensions entfernt.
  // Form1.Memo1.Lines.Add(GMS('mpref02'));
end;

end.
