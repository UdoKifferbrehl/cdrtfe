{ f_wininfo.pas: Windows-System-Informationen

  Copyright (c) 2004-2016 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  17.04.2016

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
    GetWindowsLanguage: string
    HasAdminPrivileges: TAdminPrivileges
    IsAdmin: Boolean
    IsFullAdmin: Boolean
    IsWow64: Boolean
    PlatformWinNT: Boolean
    PlatformWin2kXP: Boolean
    PlatformWinVista: Boolean
    WinInstCompanyName: string
    WinInstOwnerName: string
    WinInstProductID: string
    WinInstProductName: string

}

unit f_wininfo;

{$I directives.inc}

interface

uses Windows, Registry, SysUtils;

type TAdminPrivileges = (apLimited, apAdmin, apFullAdmin);

function AccessToRegistryHKLM: Boolean;
function CurrentUserName: string;
function GetWindowsLanguage: string;
function HasAdminPrivileges: TAdminPrivileges;
function IsAdmin: Boolean;
function IsFullAdmin: Boolean;
function IsWow64: Boolean;
function PlatformWinNT: Boolean;
function PlatformWin2kXP: Boolean;
function PlatformWinVista: Boolean;
function WinInstCompanyName: string;
function WinInstOwnerName: string;
function WinInstProductID: string;
function WinInstProductName: string;

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

  True, wenn es sich um Win2k, WinXP oder neuer handelt (Win32Platform = 2 und
  Win32MajorVersion > 4).                                                      }

function PlatformWin2kXP: Boolean;
begin
  Result := (Win32Platform = 2) and (Win32MajorVersion > 4);
end;

{ PlatformWinVista -------------------------------------------------------------

  True, wenn es sich um WinVista oder neuer handelt (Win32Platform = 2 und
  Win32MajorVersion > 4).                                                      }

function PlatformWinVista: Boolean;
begin
  Result := (Win32Platform = 2) and (Win32MajorVersion > 5);
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
      Result := Reg.ReadString('ProductID');
      Reg.CloseKey;
    end else
      Result := '0';
  finally
    Reg.Free;
  end;
end;

{ WinInstProductName -----------------------------------------------------------

  liefert den Produktnamen des installierten Windows.                          }

function WinInstProductName: string;
var Reg: TRegistry;
    Res: Boolean;
begin
  Reg := TRegistry.Create;
  try
    Reg.Rootkey := HKEY_LOCAL_MACHINE;
    Reg.Access := Key_Read;
    if PlatformWinNT then
      Res := Reg.OpenKey('\SOFTWARE\Microsoft\Windows NT\CurrentVersion', False)
    else
      Res := Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion', False);
    if Res then
    begin
      Result := Reg.ReadString('ProductName');
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

{ GetWindowsLanguage -----------------------------------------------------------

  gibt aktuelle Sprache und Territorium aus. Gefunden bei delphipraxis.de      }

const IDAfrikaans = $0436; IDAlbanian = $041C;
      IDArabicAlgeria = $1401; IDArabicBahrain = $3C01;
      IDArabicEgypt = $0C01; IDArabicIraq = $0801;
      IDArabicJordan = $2C01; IDArabicKuwait = $3401;
      IDArabicLebanon = $3001; IDArabicLibya = $1001;
      IDArabicMorocco = $1801; IDArabicOman = $2001;
      IDArabicQatar = $4001; IDArabic = $0401;
      IDArabicSyria = $2801; IDArabicTunisia = $1C01;
      IDArabicUAE = $3801; IDArabicYemen = $2401;
      IDArmenian = $042B; IDAssamese = $044D;
      IDAzeriCyrillic = $082C; IDAzeriLatin = $042C;
      IDBasque = $042D; IDByelorussian = $0423;
      IDBengali = $0445; IDBulgarian = $0402;
      IDBurmese = $0455; IDCatalan = $0403;
      IDChineseHongKong = $0C04; IDChineseMacao = $1404;
      IDSimplifiedChinese = $0804; IDChineseSingapore = $1004;
      IDTraditionalChinese = $0404; IDCroatian = $041A;
      IDCzech = $0405; IDDanish = $0406;
      IDBelgianDutch = $0813; IDDutch = $0413;
      IDEnglishAUS = $0C09; IDEnglishBelize = $2809;
      IDEnglishCanadian = $1009; IDEnglishCaribbean = $2409;
      IDEnglishIreland = $1809; IDEnglishJamaica = $2009;
      IDEnglishNewZealand = $1409; IDEnglishPhilippines = $3409;
      IDEnglishSouthAfrica = $1C09; IDEnglishTrinidad = $2C09;
      IDEnglishUK = $0809; IDEnglishUS = $0409;
      IDEnglishZimbabwe = $3009; IDEstonian = $0425;
      IDFaeroese = $0438; IDFarsi = $0429;
      IDFinnish = $040B; IDBelgianFrench = $080C;
      IDFrenchCameroon = $2C0C; IDFrenchCanadian = $0C0C;
      IDFrenchCotedIvoire = $300C; IDFrench = $040C;
      IDFrenchLuxembourg = $140C; IDFrenchMali = $340C;
      IDFrenchMonaco = $180C; IDFrenchReunion = $200C;
      IDFrenchSenegal = $280C; IDSwissFrench = $100C;
      IDFrenchWestIndies = $1C0C; IDFrenchZaire = $240C;
      IDFrisianNetherlands = $0462; IDGaelicIreland = $083C;
      IDGaelicScotland = $043C; IDGalician = $0456;
      IDGeorgian = $0437; IDGermanAustria = $0C07;
      IDGerman = $0407; IDGermanLiechtenstein = $1407;
      IDGermanLuxembourg = $1007; IDSwissGerman = $0807;
      IDGreek = $0408; IDGujarati = $0447;
      IDHebrew = $040D; IDHindi = $0439;
      IDHungarian = $040E; IDIcelandic = $040F;
      IDIndonesian = $0421; IDItalian = $0410;
      IDSwissItalian = $0810; IDJapanese = $0411;
      IDKannada = $044B; IDKashmiri = $0460;
      IDKazakh = $043F; IDKhmer = $0453;
      IDKirghiz = $0440; IDKonkani = $0457;
      IDKorean = $0412; IDLao = $0454;
      IDLatvian = $0426; IDLithuanian = $0427;
      IDMacedonian = $042F; IDMalaysian = $043E;
      IDMalayBruneiDarussalam = $083E; IDMalayalam = $044C;
      IDMaltese = $043A; IDManipuri = $0458;
      IDMarathi = $044E; IDMongolian = $0450;
      IDNepali = $0461; IDNorwegianBokmol = $0414;
      IDNorwegianNynorsk = $0814; IDOriya = $0448;
      IDPolish = $0415; IDBrazilianPortuguese = $0416;
      IDPortuguese = $0816; IDPunjabi = $0446;
      IDRhaetoRomanic = $0417; IDRomanianMoldova = $0818;
      IDRomanian = $0418; IDRussianMoldova = $0819;
      IDRussian = $0419; IDSamiLappish = $043B;
      IDSanskrit = $044F; IDSerbianCyrillic = $0C1A;
      IDSerbianLatin = $081A; IDSesotho = $0430;
      IDSindhi = $0459; IDSlovak = $041B;
      IDSlovenian = $0424; IDSorbian = $042E;
      IDSpanishArgentina = $2C0A; IDSpanishBolivia = $400A;
      IDSpanishChile = $340A; IDSpanishColombia = $240A;
      IDSpanishCostaRica = $140A; IDSpanishDominicanRepublic = $1C0A;
      IDSpanishEcuador = $300A; IDSpanishElSalvador = $440A;
      IDSpanishGuatemala = $100A; IDSpanishHonduras = $480A;
      IDMexicanSpanish = $080A; IDSpanishNicaragua = $4C0A;
      IDSpanishPanama = $180A; IDSpanishParaguay = $3C0A;
      IDSpanishPeru = $280A; IDSpanishPuertoRico = $500A;
      IDSpanishModernSort = $0C0A; IDSpanish = $040A;
      IDSpanishUruguay = $380A; IDSpanishVenezuela = $200A;
      IDSutu = $0430; IDSwahili = $0441;
      IDSwedishFinland = $081D; IDSwedish = $041D;
      IDTajik = $0428; IDTamil = $0449;
      IDTatar = $0444; IDTelugu = $044A;
      IDThai = $041E; IDTibetan = $0451;
      IDTsonga = $0431; IDTswana = $0432;
      IDTurkish = $041F; IDTurkmen = $0442;
      IDUkrainian = $0422; IDUrdu = $0420;
      IDUzbekCyrillic = $0843; IDUzbekLatin = $0443;
      IDVenda = $0433; IDVietnamese = $042A;
      IDWelsh = $0452; IDXhosa = $0434;
      IDZulu = $0435;

function GetWindowsLanguage: string;
var LangID      : Cardinal;
    LangCode    : string;
    CountryName : array[0..4] of Char;
    LanguageName: array[0..4] of Char;
    Ok          : Boolean;
begin
  {The return value of GetLocaleInfo is compared with 3 = 2 characters and
   a zero}
  Ok := 3 = GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SISO639LANGNAME,
                          LanguageName, SizeOf(LanguageName));
  Ok := Ok and (3 = GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SISO3166CTRYNAME,
                                  CountryName, SizeOf(CountryName)));
  if Ok then begin
    {Windows 98, Me, NT4, 2000, XP and newer}
    LangCode := PChar(@LanguageName[0]);
    if LowerCase(LangCode) = 'no' then LangCode := 'nb';
    LangCode := LangCode + '_' + PChar(@CountryName[0]);
  end else begin
    {This part should only happen on Windows 95.}
    LangID := GetThreadLocale;
    case LangID of
      IDBelgianDutch: LangCode := 'nl_BE';
      IDBelgianFrench: LangCode := 'fr_BE';
      IDBrazilianPortuguese: LangCode := 'pt_BR';
      IDDanish: LangCode := 'da_DK';
      IDDutch: LangCode := 'nl_NL';
      IDEnglishUK: LangCode := 'en_GB';
      IDEnglishUS: LangCode := 'en_US';
      IDFinnish: LangCode := 'fi_FI';
      IDFrench: LangCode := 'fr_FR';
      IDFrenchCanadian: LangCode := 'fr_CA';
      IDGerman: LangCode := 'de_DE';
      IDGermanLuxembourg: LangCode := 'de_LU';
      IDGreek: LangCode := 'el_GR';
      IDIcelandic: LangCode := 'is_IS';
      IDItalian: LangCode := 'it_IT';
      IDKorean: LangCode := 'ko_KO';
      IDNorwegianBokmol: LangCode := 'nb_NO';
      IDNorwegianNynorsk: LangCode := 'nn_NO';
      IDPolish: LangCode := 'pl_PL';
      IDPortuguese: LangCode := 'pt_PT';
      IDRussian: LangCode := 'ru_RU';
      IDSpanish, IDSpanishModernSort: LangCode := 'es_ES';
      IDSwedish: LangCode := 'sv_SE';
      IDSwedishFinland: LangCode := 'sv_FI';
    else
      LangCode := 'C';
    end;
  end;
  Result := LangCode;
end;

end.
