{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  f_shellext.pas: ShellExtensions registrieren/l�schen

  Copyright (c) 2004-2014 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte �nderung  25.05.2014

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.  

  f_shellext.pas stellt Funktionen f�r die ShellExtensions zur Verf�gung:
    * ShellExtemsions registrieren
    * Registry-Eintr�ge wieder entfernen
    * Pr�fen: Sind sie Shellextensions registriert


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

  Pr�ft anhand der Registry-Eintr�ge, ob die ShellExtensions registriert sind
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
       Schlie�en �brig bleibt. Der Fehler wird durch RegOpenKeyEx in der Funktion
       TRegistry.GetKey ausgel�st, wenn der Registry-Zweig nicht vorhanden ist.
       Wahrscheinlich ist es nur ein kosmetisches Problem.}
      Result := Reg.KeyExists('\CLSID\' + ClassID);
      {$ELSE}
      {In der alternativen Variante wird versucht den Registry-Zweig zu �ffnen.
       Falls er nich vorhanden ist wird er erzeugt. Dann wird auf das Vorhanden-
       sein eines Wertes gepr�ft. Falls dieser nicht gefunden wird, war der
       Registry-Zweig urspr�nglich nicht vorhanden, mu� also wieder gel�scht
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

  RegisterShellExtensions tr�g alle n�tigen Informationen in die Registry ein,
  damit die ShellExtensions verwendet werden k�nnen.                           }

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
      {Kontextmen� f�r * erweitern}
      Key := '\*' + CMHPath + ClassID;
      OpenKey(Key, True);
      WriteString('', ClassID);
      {Kontextmen� f�r Ordner erweitern}
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

  UnregisterShellExtensions entfernt die zu den ShellExtensions geh�renden Ein-
  tr�ge aus der Registry und deaktiviert diese.                                }

procedure DoUnregisterShellExtensions(const Reg64: Boolean);
var Reg    : TRegistry;
    ClassID: string;
    Key    : string;
    DLLPath: string;
begin
  if Reg64 then
  begin
    ClassID := CdrtfeClassID64;
    {Workaround f�r Delphi-Bug: Unter 64-Bit-Windows wird der Schl�ssel 'cdrtfe'
     nicht gel�scht (Fehler in TRegistry). Daher rufen wir regsvr32 auf, das
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
        {ShellExtensions l�schen}
        RootKey := HKEY_CLASSES_ROOT;
        Access := Key_Read or Key_Write;
        if Reg64 then Access := Access or KEY_WOW64_64KEY;
        DeleteKey('\CLSID\' + ClassID + '\InProcServer32');
        DeleteKey('\CLSID\' + ClassID);
        {Kontextmen�eintrag f�r * l�schen}
        Key := '\*' + CMHPath + ClassID;
        DeleteKey(Key);
        {Kontextmen� f�r Ordner l�schen}
        Key := '\folder' + CMHPath + ClassID;
        DeleteKey(Key);
        {cdrtfe-Programmpfad l�schen}
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
