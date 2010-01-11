{ $Id: f_wininfo.pas,v 1.1 2010/01/11 06:37:39 kerberos002 Exp $

  f_wininfo.pas: Windows-System-Informationen

  Copyright (c) 2004-2008 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  01.10.2008

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
    IsAdmin: Boolean
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

function AccessToRegistryHKLM: Boolean;
function CurrentUserName: string;
function IsAdmin: Boolean;
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

{ IsAdmin ----------------------------------------------------------------------

  IsAdmin liefert True zurück, wenn Administratorrechte vorhanden sind. Die ur-
  sprüngliche Fassung dieser Funktion stammt von
  http://community.borland.com/article/0,1410,26752,00.html                    }

function IsAdmin: Boolean;
const SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority  = (Value: (0, 0, 0, 0, 0, 5));
      SECURITY_BUILTIN_DOMAIN_RID                     = $00000020;
      DOMAIN_ALIAS_RID_ADMINS                         = $00000220;

var hAccessToken      : THandle;
    ptgGroups         : PTokenGroups;
    dwInfoBufferSize  : DWORD;
    psidAdministrators: PSID;
    x                 : Integer;
    bSuccess          : BOOL;
begin
  Result := False;
  bSuccess := OpenThreadToken(GetCurrentThread, TOKEN_QUERY, True,
                              hAccessToken);
  if not bSuccess then
  begin
    if GetLastError = ERROR_NO_TOKEN then
      bSuccess := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY,
                                   hAccessToken);
  end;
  if bSuccess then
  begin
    GetMem(ptgGroups, 1024);
    bSuccess := GetTokenInformation(hAccessToken, TokenGroups,
                                    ptgGroups, 1024, dwInfoBufferSize);
    CloseHandle(hAccessToken);
    if bSuccess then
    begin
      AllocateAndInitializeSid(SECURITY_NT_AUTHORITY, 2,
                               SECURITY_BUILTIN_DOMAIN_RID,
                               DOMAIN_ALIAS_RID_ADMINS,
                               0, 0, 0, 0, 0, 0,
                               psidAdministrators);
      {$R-}
      for x := 0 to ptgGroups.GroupCount - 1 do
        if EqualSid(psidAdministrators, ptgGroups.Groups[x].Sid) then
        begin
          Result := True;
          Break;
        end;
      {$R+}
      FreeSid(psidAdministrators);
    end;
    FreeMem(ptgGroups);
  end;
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

end.
