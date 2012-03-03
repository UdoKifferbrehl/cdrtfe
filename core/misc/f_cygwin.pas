{ f_cygwin.pas: cygwin-Funktionen

  Copyright (c) 2004-2012 Oliver Valencia

  letzte Änderung  26.02.2012

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  f_cygwin.pas stellt Funktionen zur Verfügung, die mit der cygwin-Umgebung zu
  tun haben:
    * Zugriff auf Einstellungen der cygwin-Umgebung
    * Konvertieren von Pfadangaben


  exportierte Funktionen/Prozeduren:

    GetCygwinPathPrefix: string
    MakePathCygwinConform(Path: string; GraftPoints: Boolean = False): string;
    MakePathMkisofsConform(const Path: string):string
    MakePathMingwMkisofsConform(const Path: string):string
    SetUseOwnCygwinDLLs(Value: Boolean);
    UseOwnCygwinDLLs: Boolean
    
}

unit f_cygwin;

{$I directives.inc}

interface

uses Windows, SysUtils, Registry, IniFiles;

function CheckForActiveCygwinDLL: Boolean;
function GetCygwinPathPrefix: string;
function GetCygwinPathPrefixEx: string;
function MakePathCygwinConform(Path: string; GraftPoints: Boolean = False): string;
function MakePathMkisofsConform(const Path: string):string;
function MakePathMingwMkisofsConform(const Path: string): string;
function UseOwnCygwinDLLs: Boolean;
procedure CleanRegistryPortable;
procedure SetUseOwnCygwinDLLs(Value: Boolean);
procedure InitCygwinPathPrefix;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     {$IFDEF WriteLogfile} f_logfile, {$ENDIF}   // debug: f_window,
     f_getdosoutput,
     cl_cdrtfedata, f_strings, f_filesystem, f_locations, const_locations;

{ 'statische' Variablen }
var CygPathPrefix    : string;           // Cygwin-Mountpoint
    CygnusPresentHKLM: Boolean;
    CygnusPresentHKCU: Boolean;

{ CygnusPresent ----------------------------------------------------------------

  True, wenn Registry-Zweig "HK\Software\Cygnus Solutions" existiert.          }

function CygnusPresent(HK: HKEY): Boolean;
var Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HK;
    Reg.Access := Key_Read;
    Result := Reg.KeyExists('\Software\Cygnus Solutions');
  finally
    Reg.Free;
  end;
end;

{ DeleteCygnus -----------------------------------------------------------------

 löscht Registry-Zweig "HK\Software\Cygnus Solutions".                         }

function DeleteCygnus(HK: HKEY): Boolean;
var Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HK;
    Reg.Access := Key_Read or Key_Write;
    Result := Reg.DeleteKey('\Software\Cygnus Solutions');
  finally
    Reg.Free;
  end;
end;

{ CleanRegistryPortable --------------------------------------------------------

  löscht die von cygwin erzeugten Einträge, sofern sie beim Start nicht vor-
  handen waren.                                                                }

procedure CleanRegistryPortable;
// var Temp: string;
//    Ok  : Boolean;
begin
  if not CygnusPresentHKLM then DeleteCygnus(HKEY_LOCAL_MACHINE);
  if not CygnusPresentHKCU then DeleteCygnus(HKEY_CURRENT_USER);
(* debug:
  if CygnusPresentHKLM then Temp := 'CygnusHKLMPresent = True' + #13#10 else
                            Temp := 'CygnusHKLMPresent = False' + #13#10;
  if CygnusPresentHKCU then Temp := Temp + 'CygnusHKCUPresent = True' + #13#10 else
                            Temp := Temp + 'CygnusHKCUPresent = False' + #13#10;
  if not CygnusPresentHKLM then
  begin
    Ok := DeleteCygnus(HKEY_LOCAL_MACHINE);
    if OK then Temp := Temp + 'CygnusHKLM deleted' + #13#10 else
               Temp := Temp + 'CygnusHKLM delete failed' + #13#10;
  end;
  if not CygnusPresentHKCU then
  begin
    Ok := DeleteCygnus(HKEY_CURRENT_USER);
    if OK then Temp := Temp + 'CygnusHKLM deleted' + #13#10 else
               Temp := Temp + 'CygnusHKLM delete failed' + #13#10;
  end;
  ShowMsgDlg(Temp, 'StealthInfo', MB_cdrtfeInfo);
*)
end;

{ GetCygwinPathPrefix ----------------------------------------------------------

  liefert den Cygwin-Mountpoint für Windowslaufwerke (normalerweise /cygdrive).}

function GetCygwinPathPrefix: string;
var Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    with Reg do
    begin
      {Cygwin Path Prefix zuerst in HKCU suchen}
      RootKey := HKEY_CURRENT_USER;
      OpenKey('\Software\Cygnus Solutions\Cygwin\mounts v2', False);
      try
        Result := ReadString('cygdrive prefix');
      except
        {Wenn etwas schiefgeht 'cygdrive prefix' also nicht vorhanden ist,
         setzen wir das Ergebnis aus '', damit in HKLM gesucht wird. Aufgrund
         eines Fehlers in TRegistry wird diese Exception aber nie ausgelöst, was
         kein Problem ist, da Result in diesem Fall ein Leerstring ist.}
        Result := '';
      end;
      {Wenn in HKCU nichts gefunden wird, dann vielleicht in HKLM}
      if Result = '' then
      begin
        RootKey := HKEY_LOCAL_MACHINE;
        OpenKey('\Software\Cygnus Solutions\Cygwin\mounts v2', False);
        try
          Result := ReadString('cygdrive prefix');
        except
          Result := '';
        end;
      end;
      {Wenn das Prefix '/' ist, müssen wir mit '' arbeiten.}
      if Result = '/' then Result := '' else
      {Wenn nichts gefunden wurde, arbeiten wir mit dem cygwin-Default.}
      if Result = '' then Result := '/cygdrive';
    end;
  finally
    Reg.Free;
  end;
end;

{ GetCygwinPathPrefixEx --------------------------------------------------------

  liefert den Cygwin-Mountpoint für Windowslaufwerke (normalerweise /cygdrive).

  Zur Zeit wird hierfür ein externes Programm (cygpathprefix.exe) aufgerufen,
  das das Prefix nach StdOut ausgibt. Es wäre natürlich schöner, dies durch
  direkten Aufruf der entsprechenden Funktion der cygwin1.dll zu erledigen,
  aber hierfür muß der Stack manipuliert werden (unterste 4K sichern und an-
  schließend wiederherstellen, sonst überschreibt cygwin_dll_init diesen
  Bereich).                                                                    }
(*
type TCygwinGetinfoTypes = (
       CW_LOCK_PINFO,
       CW_UNLOCK_PINFO,
       CW_GETTHREADNAME,
       CW_GETPINFO,
       CW_SETPINFO,
       CW_SETTHREADNAME,
       CW_GETVERSIONINFO,
       CW_READ_V1_MOUNT_TABLES,
       CW_USER_DATA,
       CW_PERFILE,
       CW_GET_CYGDRIVE_PREFIXES,
       CW_GETPINFO_FULL,
       CW_INIT_EXCEPTIONS,
       CW_GET_CYGDRIVE_INFO,
       CW_SET_CYGWIN_REGISTRY_NAME,
       CW_GET_CYGWIN_REGISTRY_NAME,
       CW_STRACE_TOGGLE,
       CW_STRACE_ACTIVE,
       CW_CYGWIN_PID_TO_WINPID,
       CW_EXTRACT_DOMAIN_AND_USER,
       CW_CMDLINE,
       CW_CHECK_NTSEC,
       CW_GET_ERRNO_FROM_WINERROR,
       CW_GET_POSIX_SECURITY_ATTRIBUTE,
       CW_GET_SHMLBA,
       CW_GET_UID_FROM_SID,
       CW_GET_GID_FROM_SID,
       CW_GET_BINMODE,
       CW_HOOK,
       CW_ARGV,
       CW_ENVP,
       CW_DEBUG_SELF,
       CW_SYNC_WINENV,
       CW_CYGTLS_PADSIZE);

     TInitCygDLL = procedure; stdcall;
     TCygInternal = procedure(InfoType: TCygwinGetinfoTypes;
                              user, system, u_flags, s_flags: Pointer); stdcall;

function GetCygwinPathPrefixEx: string;
var CygDLLHandle: THandle;
    InitCygDLL  : TInitCygDLL;
    CygInternal : TCygInternal;
    DLLName     : string;
    user, system,
    u_flags,
    s_flags     : array[0..MAX_PATH] of Char;
    Prefix,
    pu, ps      : string;
begin
  Prefix := '';
  CygDLLHandle := 0;
  ZeroMemory(@system, SizeOf(system));
  try
    DLLName := cCygwin1Dll;
    CygDLLHandle := LoadLibrary(PChar(DLLName));
    if CygDLLHandle > 0 then
    begin
      @InitCygDLL  := GetProcAddress(CygDLLHandle, 'cygwin_dll_init');
      @CygInternal := GetProcAddress(CygDLLHandle, 'cygwin_internal');
      {cygwin1.dll initialisieren}
      InitCygDLL;
      {Infos abrufen}
      CygInternal(CW_GET_CYGDRIVE_INFO, @user, @system, @u_flags, @s_flags);
      ps := StrPas(@system);
      pu := StrPas(@user);
      {$IFDEF WriteLogfile}
      AddLog('cygwin path prefix (system): ' + ps, 0);
      AddLog('cygwin path prefix (user)  : ' + pu, 0);
      {$ENDIF}
      if ps <> '' then Prefix := ps else Prefix := pu;
    end;
  finally
    if CygDLLHandle > 0 then FreeLibrary(CygDLLHandle);
    if Prefix = '/' then Prefix := '' else
    if Prefix = '' then Prefix := '/cygdrive';
  end;
  Result := Prefix;
  {$IFDEF WriteLogfile}
  AddLog('cygwin path prefix         : ' + Prefix + #13#10 + ' ', 0);
  {$ENDIF}
end;
*)
function GetCygwinPathPrefixEx: string;
var Cmd    : string;
    Output : string;
    Prefix : string;
    i      : Integer;
begin
  Result := '';
  Cmd := StartUpDir + cCygPathPref;
  Cmd := QuotePath(Cmd);
  Output := GetDosOutput(PChar(Cmd), True, True, 3);
  Prefix := Output;
  i := LastDelimiter('/', Prefix);
  if i > 1 then Delete(Prefix, 1, i - 1);
  Prefix := Trim(Prefix);
  if Prefix = '/' then Prefix := '' else
  if Prefix = '' then Prefix := '/cygdrive';
  Result := Prefix;
  {$IFDEF WriteLogfile}
  AddLog('cygwin path prefix         : ' + Prefix + #13#10 + ' ', 0);
  {$ENDIF}
end;                            

procedure InitCygwinPathPrefix;
begin
  if CygPathPrefix = 'unknown' then CygPathPrefix := GetCygwinPathPrefixEx;
end;

{ MakePathCygwinConform --------------------------------------------------------

  MakePathCygwinconform wandelt Pfade so um, daß sie kompatibel sind zu den
  Konventionen der Cygwin-Umgebung.
  Wenn die Pfadangaben '=' enthalten (aus der Graft-Points-Pfadliste), wird dies
  korrekt behandelt.                                                           }

function MakePathCygwinConform(Path: string;
                               GraftPoints: Boolean = False): string;
var p     : Integer;
    Target: string;
begin
  if CygPathPrefix = 'unknown' then CygPathPrefix := GetCygwinPathPrefix;
  {standardkonforme Pfadangaben benutzen / statt \}
  Path := ReplaceChar(Path, '\', '/');
  {Doppelpunkt bei Laufwerksangabe entfernen}
  p := Pos(':', Path);
  if p <> 0 then
  begin
    Delete(Path, p, 1);
  end;
  {Pfade für Cygwin anpassen, dabei auf das = für -graft-points achten. UNC-
   Pfade (\\server\...) können bleiben, wie sie sind.}
  p := Pos('=', Path);
  if (p <> 0) and GraftPoints then
  begin
    SplitString(Path, '=', Target, Path);
    if IsUNCPath(Path) then
    begin
      Path := Target + '=' + Path;
    end else
    begin
      Path := Target + '=' + CygPathPrefix + '/' + Path;
    end;
  end else
  begin
    if not IsUNCPath(Path) then Path := CygPathPrefix +'/' + Path;
  end;
  Result := Path;
end;

{ MakePathMkisofsConform -------------------------------------------------------

  MakePathMkisofsconform ist nötig, um das Vorkommen von '=' in Dateinamen
  richtig zu behandeln.                                                        }

function MakePathMkisofsConform(const Path: string):string;
var Temp: string;
begin
  Temp := Path;                                            {$IFDEF DebugMMkC}
                                                           Deb(Path, 2);{$ENDIF}
  {nötiger Zwischenschritt:  = -> *}
  Temp := ReplaceChar(Temp, '=', '*');                     {$IFDEF DebugMMkC}
                                                           Deb(Temp, 2);{$ENDIF}
  {erster : -> =}
  Temp := ReplaceCharFirst(Temp, ':', '=');                {$IFDEF DebugMMkC}
                                                           Deb(Temp, 2);{$ENDIF}
  {\ -> / und x: -> /cygdrive/x}
  Temp := MakePathCygwinConform(Temp, True);               {$IFDEF DebugMMkC}
                                                           Deb(Temp, 2);{$ENDIF}
  {* - > \=}
  Temp := ReplaceString(Temp, '*', '\=');
  Result := Temp;                                          {$IFDEF DebugMMkC}
                                                  Deb(Temp + #13#10, 2);{$ENDIF}
end;

{ MakePathMingwMkisofsConform --------------------------------------------------

  MakePathMkisofsconform ist nötig, um das Vorkommen von '=' in Dateinamen
  richtig zu behandeln. Da die Mingw-Version von mkisofs anders mit Pfaden um
  geht, ist eine eigene Funktion nötig.                                        }

function MakePathMingwMkisofsConform(const Path: string): string;
var Temp: string;
begin
  Temp := Path;
  {nötiger Zwischenschritt:  = -> *}
  Temp := ReplaceChar(Temp, '=', '*');
  {erster : -> =}
  Temp := ReplaceCharFirst(Temp, ':', '=');
  {\ -> /}
  Temp := ReplaceChar(Temp, '\', '/');
  {* - > \=}
  Temp := ReplaceString(Temp, '*', '\=');
  Result := Temp;
end;

const cCygOwnDLLSec  : string = 'CygwinDLL';
      cCygOwnDLL     : string = 'UseOwnDLLs';
      cCygCheckActive: string = 'CheckForActiveDLL';

{ UseOwnDLLs -------------------------------------------------------------------

  Wertet die Datei tools\cygwin\cygwin.ini aus.

  True:  Die mitgelieferten DLLs sollen verwendet werden, unabhängig davon, ob
         die cygwin1.dll im Suchpfad gefunden wurde.
  False: Die mitgelieferten DLLs sollen nur verwendet werden, wenn die
         cygwin1.dll nicht im Suchpfad gefunden wurde.                         }

function UseOwnCygwinDLLs: Boolean;
var Ini : TIniFile;
    Name: string;
begin
  Name := StartUpDir + cToolDir + cCygwinDir + cIniCygwin;
  Result := False;
  if FileExists(Name) then
  begin
    {$IFDEF WriteLogFile}
    AddLogCode(1256);
    {$ENDIF}
    Ini := TIniFile.Create(Name);
    Result := Ini.ReadBool(cCygOwnDLLSec, cCygOwnDLL, False);
    Ini.Free;
  end;
  {$IFDEF WriteLogFile}
  if Result then AddLogCode(1257) else AddLogCode(1258);
  {$ENDIF}
  {Wir benötigen den Wert in FSettings, daher hier Zugrif über Singleton. Sehr
   unschöne Lösung. Demnächst mal ändern.}
  TCdrtfeData.Instance.Settings.FileFlags.UseOwnDLLs := Result;
end;

{ SetUseOwnCygwinDLLs ----------------------------------------------------------

  Setzt die Option [CygwinDLL], UseOwnDLLs in tools\cygwin\cygwin.ini.         }

procedure SetUseOwnCygwinDLLs(Value: Boolean);
var Ini : TIniFile;
    Name: string;
begin
  Name := StartUpDir + cToolDir + cCygwinDir + cIniCygwin;
  Ini := TIniFile.Create(Name);
  Ini.WriteBool(cCygOwnDLLSec, cCygOwnDLL, Value);
  Ini.Free;
end;

{ CheckForActiveCygwinDLL ------------------------------------------------------

  True: nach geladener cygwin1.dll suchen
  False: nicht nach geladener cygwin1.dll suchen                               }

function CheckForActiveCygwinDLL: Boolean;
var Ini : TIniFile;
    Name: string;
begin
  Name := StartUpDir + cToolDir + cCygwinDir + cIniCygwin;
  Result := False;
  if FileExists(Name) then
  begin
    {$IFDEF WriteLogFile}
    AddLogCode(1256);
    {$ENDIF}
    Ini := TIniFile.Create(Name);
    Result := Ini.ReadBool(cCygOwnDLLSec, cCygCheckActive, False);
    Ini.Free;
  end;
end;
                
initialization
  CygPathPrefix := 'unknown';
  CygnusPresentHKLM := CygnusPresent(HKEY_LOCAL_MACHINE);
  CygnusPresentHKCU := CygnusPresent(HKEY_CURRENT_USER);  

end.
