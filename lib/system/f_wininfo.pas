{ $Id: f_wininfo.pas,v 1.2 2010/08/10 13:41:08 kerberos002 Exp $

  f_wininfo.pas: Windows-System-Informationen

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  10.08.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  Basiert z.T. (CurrentUserName, WinInst*) auf WinFuncs.pas von Simon Reinhardt
  <S.Reinhardt@WTal.de>.

  f_wininfo.pas stellt Funktionen zur Verfügung, um Informationen über die
  Windows-Installation und das System zu erhalten:
    * ProductID, Registered Owner, Registered Company
    * aktueller Benutzer
    * Zugriffsrechte
    * Windows-Plattform


  exportierte Funktionen/Prozeduren:

    AccessToRegistryHKLM: Boolean
    CurrentUserName: string
    HasAdminPrivileges: TAdminPrivileges
    IsAdmin: Boolean
    IsFullAdmin: Boolean
    IsWow64: Boolean
    PlatformWinNT: Boolean
    PlatformWin2kXP: Boolean
    WinInstCompanyName: string
    WinInstOwnerName: string
    WinInstProductID: string;

}

unit f_wininfo;

{$I directives.inc}

interface

uses Windows, Registry, SysUtils;

type TAdminPrivileges = (apLimited, apAdmin, apFullAdmin);

function AccessToRegistryHKLM: Boolean;
function CurrentUserName: string;
function HasAdminPrivileges: TAdminPrivileges;
function IsAdmin: Boolean;
function IsFullAdmin: Boolean;
function IsWow64: Boolean;
function PlatformWinNT: Boolean;
function PlatformWin2kXP: Boolean;
function WinInstCompanyName: string;
function WinInstOwnerName: string;
function WinInstProductID: string;

implementation

{ AccessToRegistryHKLM ---------------------------------------------------------

  AccToRegistryHKLM prüft, ob der aktuelle Nutzer genügend Rechte besitzt, im
  Registry-Zweig HKEY_LOCAL_MACHINE\Software Schlüssel anzulegen. Dies ist
  nötig, um die ShellExtensions zu (ent-)registrieren.                         }

function AccessToRegistryHKLM: Boolean;
var Reg: TRegistry;
begin
  Result := True;
  Reg := TRegistry.Create;
  try
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      {Versuch, einen Schlüssel anzulegen. Wenn nicht genügend Rechte vorhanden,
       wird eine Exception geworfen.}
      Reg.CreateKey('Software\cdrtfetest');
      Reg.DeleteKey('Software\cdrtfetest');
    except
      on ERegistryException do
        Result := False;
    end;
  finally
    Reg.Free;
  end;
end;

{ HasAdminPrivileges -----------------------------------------------------------

  gibt die Art der Admin-Rechte zurück:
  Diese Funktion gibt unter XP entweder apLimited für eingeschränkte Rechte
  oder apFullAdmin für Administratorrechte zurück. Ab Vista wird apAdmin
  zurückgegeben, wenn es sich um einen Administrator handelt, das aktuelle
  Programm aber nicht per UAC elevated gestartet wurde. Läuft das Programm mit
  uneingeschränkten Adminrechten, so wird hier apFullAdmin zurückgegeben.
  Quelle: http://www.delphipraxis.net/119831-vista-administratorkonto-oder-
          reelle-elevated-adminrechte.html                                     }

function HasAdminPrivileges: TAdminPrivileges;

  function GetAdminSid: PSID;
  const
    SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority =
      (Value: (0, 0, 0, 0, 0, 5));
    SECURITY_BUILTIN_DOMAIN_RID: DWORD = $00000020;
    DOMAIN_ALIAS_RID_ADMINS: DWORD = $00000220;
  begin
    Result := nil;
    AllocateAndInitializeSid(SECURITY_NT_AUTHORITY, 2,
      SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS,
      0, 0, 0, 0, 0, 0, Result);
  end;

const SE_GROUP_USE_FOR_DENY_ONLY = $00000010;

var TokenHandle     : THandle;
    ReturnLength    : DWORD;
    TokenInformation: PTokenGroups;
    AdminSid        : PSID;
    Loop            : Integer;
begin
  Result := apLimited;
  TokenHandle := 0;
  if OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, TokenHandle) then
  try
    ReturnLength := 0;
    GetTokenInformation(TokenHandle, TokenGroups, nil, 0, ReturnLength);
    TokenInformation := GetMemory(ReturnLength);
    if Assigned(TokenInformation) then
    try
      if GetTokenInformation(TokenHandle, TokenGroups, TokenInformation,
        ReturnLength, ReturnLength) then
      begin
        AdminSid := GetAdminSid;
        for Loop := 0 to TokenInformation^.GroupCount - 1 do
        begin
          if EqualSid(TokenInformation^.Groups[Loop].Sid, AdminSid) then
          begin
            if (TokenInformation^.Groups[Loop].Attributes and
              SE_GROUP_USE_FOR_DENY_ONLY) = SE_GROUP_USE_FOR_DENY_ONLY then
            begin
              Result := apAdmin;
            end
              else
            begin
              Result := apFullAdmin;
            end;
            Break;
          end;
        end;
        FreeSid(AdminSid);
      end;
    finally
      FreeMemory(TokenInformation);
    end;
  finally
    CloseHandle(TokenHandle);
  end;
end;

{ IsFullAdmin ------------------------------------------------------------------

  True, wenn volle Admin-Rechte bestehen (XP: Adminrechte; Vista + Win7: Admin-
  rechte + elevated                                                            }

function IsFullAdmin: Boolean;
begin
  Result := HasAdminPrivileges = apFullAdmin;
end;

{ IsAdmin ----------------------------------------------------------------------

  IsAdmin liefert True zurück, wenn der angemeldete Benutzer Administrator ist.}

function IsAdmin: Boolean;
begin
  Result := HasAdminPrivileges in [apAdmin, apFullAdmin];
end;

{ PlatformWinNT ----------------------------------------------------------------

  PlatformWinNT gibt True zurück, wenn Win32Platform = 2, d.h. es handelt sich
  um ein NT-artiges Windows (NT3, NT4, 2k, XP).                                }

function PlatformWinNT: Boolean;
begin
  Result := Win32Platform = 2;
end;

{ PlatformWin2kXP --------------------------------------------------------------

  True, wenn es sich um Win2k oder WinXP handelt (Win32Platform = 2 und
  Win32MajorVersion > 4).                                                      }

function PlatformWin2kXP: Boolean;
begin
  Result := (Win32Platform = 2) and (Win32MajorVersion > 4);
end;

{ WinInstProductID -------------------------------------------------------------

  liefert die Produkt-ID des installierten Windows.                            }

function WinInstProductID: string;
var Reg: TRegistry;
    Res: Boolean;
begin
  Reg := TRegistry.Create;
  try
    Reg.Rootkey := HKEY_LOCAL_MACHINE;
    if PlatformWinNT then
      Res := Reg.OpenKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion', False)
    else
      Res := Reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion', False);
    if Res then
    begin
      Result := Reg.ReadString('ProductId');
      Reg.CloseKey;
    end else
      Result := '0';
  finally
    Reg.Free;
  end;
end;

{ WinInstOwnerName -------------------------------------------------------------

  liefert den bei der Installation angegebenen Namen.                          }

function WinInstOwnerName: string;
var Reg: TRegistry;
    Res: Boolean;
begin
  Reg := TRegistry.Create;
  try
    Reg.Rootkey := HKEY_LOCAL_MACHINE;
    if PlatformWinNT then
      Res := Reg.OpenKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion', False)
    else
      Res := Reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion', False);
    if Res then
    begin
      Result := Reg.ReadString('RegisteredOwner');
      Reg.CloseKey;
    end else
      Result := '';
  finally
    Reg.Free;
  end;
end;

{ WinInstCompanyName -----------------------------------------------------------

  liefert den bei der Installation angegebenen Firmennamen.                    }

function WinInstCompanyName: string;
var Reg: TRegistry;
    Res: Boolean;
begin
  Reg := TRegistry.Create;
  try
    Reg.Rootkey := HKEY_LOCAL_MACHINE;
    if PlatformWinNT then
      Res := Reg.OpenKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion', False)
    else
      Res := Reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion', False);
    if Res then
    begin
      Result := Reg.ReadString('RegisteredOrganization');
      Reg.CloseKey;
    end else
      Result := '';
  finally
    Reg.Free;
  end;
end;

{ CurrentUserName --------------------------------------------------------------

  liefert den Namen des aktuell angemeldeten Benutzers.                        }

function CurrentUserName: string;
var UName: PChar;
    USize: DWord;
begin
  USize := 100;
  UName := StrAlloc(USize);
  try
    GetUserName(UName, USize);
    Result := string(UName);
  finally
    StrDispose(UName);
  end;
end;

{ IsWow64 ----------------------------------------------------------------------

  True, wenn Programm auf einem 64bit-Windows ausgeführt wird. Stammt von
  http://www.delphipraxis.net/86651-registry-wow6432node.html                  }

function IsWow64: Boolean;
type {Type of IsWow64Process API function}
    TIsWow64Process = function(Handle: Windows.THandle;
                               var Res: Windows.BOOL): Windows.BOOL; stdcall;
var IsWow64Result: Windows.BOOL;     // Result from IsWow64Process
    IsWow64Process: TIsWow64Process; // IsWow64Process fn reference
begin
  {Try to load required function from kernel32}
  IsWow64Process := Windows.GetProcAddress(Windows.GetModuleHandle('kernel32'),
                                           'IsWow64Process');
  if Assigned(IsWow64Process) then
  begin
    {Function is implemented: call it}
    if not IsWow64Process(Windows.GetCurrentProcess, IsWow64Result) then
      raise SysUtils.Exception.Create('IsWow64: bad process handle');
    {Return result of function}
    Result := IsWow64Result;
  end
  else
    {Function not implemented: can't be running on Wow64}
    Result := False;
end;

end.
