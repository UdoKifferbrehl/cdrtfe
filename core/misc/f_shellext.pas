{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  f_shellext.pas: ShellExtensions registrieren/löschen

  Copyright (c) 2004-2014 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  25.05.2014

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

uses f_wininfo, f_process, f_strings, const_core, const_locations;

const CMHPath: string = '\shellex\ContextMenuHandlers\';
      KEY_WOW64_64KEY = $0100;
      KEY_WOW64_32KEY = $0200;

var Is64Bit: Boolean;

{ ShellExtensionsRegistered ----------------------------------------------------

  Prüft anhand der Registry-Einträge, ob die ShellExtensions registriert sind
  (Result = True) oder nicht (Result = False).                                 } 

function ShellExtensionsRegistered: Boolean;
var Reg    : TRegistry;
    ClassID: string;
    RegKey : string;
    aKey   : HKEY;
    iRes   : Integer;
begin
  if Is64Bit then
  begin
     ClassID := CdrtfeClassID64;
     RegKey := 'CLSID\' + ClassID;
     iRes := RegOpenKeyEx(HKEY_CLASSES_ROOT, PAnsiChar(RegKey), 0,
                          KEY_READ or KEY_WOW64_64KEY, aKey);
     Result := iRes = ERROR_SUCCESS;
     RegCloseKey(aKey);
  end else
  begin
    ClassID := CdrtfeClassID;
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CLASSES_ROOT;
      {$IFDEF UseRegistryKeyExists}
      {Dies ist die einfache Variante, die aber bei MemProof einen Fehler hervor-
       ruft (key handle must be closed), obwohl kein Registry-Key-Handle zum
       Schließen übrig bleibt. Der Fehler wird durch RegOpenKeyEx in der Funktion
       TRegistry.GetKey ausgelöst, wenn der Registry-Zweig nicht vorhanden ist.
       Wahrscheinlich ist es nur ein kosmetisches Problem.}
      Result := Reg.KeyExists('\CLSID\' + ClassID);
      {$ELSE}
      {In der alternativen Variante wird versucht den Registry-Zweig zu öffnen.
       Falls er nich vorhanden ist wird er erzeugt. Dann wird auf das Vorhanden-
       sein eines Wertes geprüft. Falls dieser nicht gefunden wird, war der
       Registry-Zweig ursprünglich nicht vorhanden, muß also wieder gelöscht
       werden.}
      if Reg.OpenKey('\CLSID\' + ClassID + '\InProcServer32', True) then
      begin
        Result := Reg.ValueExists('ThreadingModel');
        if not Result then
        begin
          Reg.DeleteKey('\CLSID\' + ClassID);
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
end;

{ DoRegisterShellExtensions ----------------------------------------------------

  RegisterShellExtensions träg alle nötigen Informationen in die Registry ein,
  damit die ShellExtensions verwendet werden können.                           }

procedure DoRegisterShellExtensions(const Reg64: Boolean);
var Reg    : TRegistry;
    DLLPath: string;
    DLLName: string;
    ClassID: string;
    Key    : string;
begin
  if Reg64 then ClassID := CdrtfeClassID64 else ClassID := CdrtfeClassID;
  if Reg64 then DLLName := cCdrtfeShlExDLL64 else DLLName := cCdrtfeShlExDLL;
  DLLPath := ExtractFilePath(Application.ExeName);
  if DLLPath[Length(DLLPath)] = '\' then Delete(DLLPath, Length(DLLPath), 1);
  if PlatformWin2kXP then
    DLLPath := Quote(DLLPath + DLLName)
  else
    DLLPath := DLLPath + DLLName;
  Reg := TRegistry.Create;
  try
    with Reg do
    begin
      {ShellExtensions registrieren}
      RootKey := HKEY_CLASSES_ROOT;
      Access := Key_Read or Key_Write;
      if Reg64 then Access := Access or KEY_WOW64_64KEY;
      OpenKey('\CLSID\' + ClassID, True);
      WriteString('', 'cdrtfe Context Menu Shell Extension');
      OpenKey('\CLSID\' + ClassID + '\InProcServer32', True);
      WriteString('', DLLPath);
      WriteString('ThreadingModel', 'Apartment');
      {Kontextmenü für * erweitern}
      Key := '\*' + CMHPath + ClassID;
      OpenKey(Key, True);
      WriteString('', ClassID);
      {Kontextmenü für Ordner erweitern}
      Key := '\folder' + CMHPath + ClassID;
      OpenKey(Key, True);
      WriteString('', ClassID);
      {cdrtfe-Programmpfad eintragen}
      RootKey := HKEY_LOCAL_MACHINE; //HKEY_CURRENT_USER;
      OpenKey('\Software\cdrtfe\Program', True);
      if PlatformWin2kXP then
        WriteString('Path', Quote(ParamStr(0)))
      else
        WriteString('Path', ParamStr(0));
    end;
  finally
    Reg.Free;
  end;
end;

{ DoUnregisterShellExtensions --------------------------------------------------

  UnregisterShellExtensions entfernt die zu den ShellExtensions gehörenden Ein-
  träge aus der Registry und deaktiviert diese.                                }

procedure DoUnregisterShellExtensions(const Reg64: Boolean);
var Reg    : TRegistry;
    ClassID: string;
    Key    : string;
    DLLPath: string;
begin
  if Reg64 then
  begin
    ClassID := CdrtfeClassID64;
    {Workaround für Delphi-Bug: Unter 64-Bit-Windows wird der Schlüssel 'cdrtfe'
     nicht gelöscht (Fehler in TRegistry). Daher rufen wir regsvr32 auf, das
     die DLL abmeldet.}
    if Reg64 then
    begin
      DLLPath := ExtractFilePath(Application.ExeName);
      if DLLPath[Length(DLLPath)] = '\' then Delete(DLLPath, Length(DLLPath), 1);
      DLLPath := '"' + DLLPath + cCdrtfeShlExDLL64 + '"';
      ShlExecute('regsvr32', '-u -s ' + DLLPath);
      {dem externen Programmaufruf etwas Zeit geben.}
      Sleep(500);
    end;                       
  end else
  begin
    ClassID := CdrtfeClassID;
    Reg := TRegistry.Create;
    try
      with Reg do
      begin
        {ShellExtensions löschen}
        RootKey := HKEY_CLASSES_ROOT;
        Access := Key_Read or Key_Write;
        if Reg64 then Access := Access or KEY_WOW64_64KEY;
        DeleteKey('\CLSID\' + ClassID + '\InProcServer32');
        DeleteKey('\CLSID\' + ClassID);
        {Kontextmenüeintrag für * löschen}
        Key := '\*' + CMHPath + ClassID;
        DeleteKey(Key);
        {Kontextmenü für Ordner löschen}
        Key := '\folder' + CMHPath + ClassID;
        DeleteKey(Key);
        {cdrtfe-Programmpfad löschen}
        RootKey := HKEY_LOCAL_MACHINE;
        DeleteKey('\Software\cdrtfe');     // Delphi-Bug: Key bleibt erhalten, x64
      end;
    finally
      Reg.Free;
    end;
  end;
end;

{ (Un)RegisterShellExtensions --------------------------------------------------

  unter Windows x64 sollen sowohl die 32- als auch die 64-Bit-ShellExtension
  registriert werden.                                                          }

procedure RegisterShellExtensions;
begin
  DoRegisterShellExtensions(False);
  if Is64Bit then DoRegisterShellExtensions(True);
end;

procedure UnRegisterShellExtensions;
begin
  DoUnRegisterShellExtensions(False);
  if Is64Bit then DoUnRegisterShellExtensions(True);
end;

initialization
  Is64Bit := IsWow64;

end.
