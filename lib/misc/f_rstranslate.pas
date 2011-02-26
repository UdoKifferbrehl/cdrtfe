{ f_rstranslate.pas: delphieigene Resource-Strings übersetzen

  Copyright (c) 2010 Oliver Valencia

  letzte Änderung  07.07.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt. 

}

unit f_rstranslate;

{$I directives.inc}

interface

uses Windows, SysUtils, Consts;

procedure SetButtonCaptions(const Ok, Cancel, Yes, No: string);
procedure TranslateResourceStrings;

implementation

const User32DLL: string = 'user32.dll';

var PNewOk, PNewCancel, PNewYes, PNewNo        : PChar;
    StrNewOk, StrNewCancel, StrNewYes, StrNewNo: string;

procedure SetButtonCaptions(const Ok, Cancel, Yes, No: string);
begin
  StrNewOk := Ok;
  StrNewCancel := Cancel;
  StrNewYes := Yes;
  StrNewNo:= No;
end;

procedure HookResourceString(rs: PResStringRec; newStr: PChar);
var oldprotect: DWORD;
begin
  VirtualProtect(rs, SizeOf(rs^), PAGE_EXECUTE_READWRITE, @oldProtect);
  rs^.Identifier := Integer(newStr);
  VirtualProtect(rs, SizeOf(rs^), oldProtect, @oldProtect);
end;

function LoadWindowsStr(const LibraryName: string; const Ident: Integer;
                        const DefaultText: string = ''): string;
const BUF_SIZE = 1024;
var hLibrary: THandle;
    iSize: Integer;
begin
  hLibrary := GetModuleHandle(PChar(LibraryName));
  if (hLibrary <> 0) then
  begin
    SetLength(Result, BUF_SIZE);
    iSize := LoadString(hLibrary, Ident, PChar(Result), BUF_SIZE);
    if (iSize > 0) then
      SetLength(Result, iSize)
    else
      Result := DefaultText;
  end else
    Result := DefaultText;
end;

procedure HookResourceStrings;
begin
  HookResourceString(@SMsgDlgOK, PNewOK);
  HookResourceString(@SMsgDlgCancel, PNewCancel);
  HookResourceString(@SMsgDlgYes, PNewYes);
  HookResourceString(@SMsgDlgNo, PNewNo);
end;

procedure FreeStrings;
begin
  StrDispose(PNewOK);
  StrDispose(PNewCancel);
  StrDispose(PNewYes);
  StrDispose(PNewNo);
end;

procedure InitNewStrings;
begin
  FreeStrings;
  if StrNewOk = '' then
    StrNewOk := LoadWindowsStr(User32DLL, 800, LoadResString(@SMsgDlgOK));
  PNewOK := StrNew(PChar(StrNewOk));

  if StrNewCancel = '' then
    StrNewCancel := LoadWindowsStr(User32DLL, 801, LoadResString(@SMsgDlgCancel));
  PNewCancel := StrNew(PChar(StrNewCancel));

  if StrNewYes = '' then
    StrNewYes := LoadWindowsStr(User32DLL, 805, LoadResString(@SMsgDlgYes));
  PNewYes := StrNew(PChar(StrNewYes));

  if StrNewNo = '' then
    StrNewNo := LoadWindowsStr(User32DLL, 806, LoadResString(@SMsgDlgNo));
  PNewNo := StrNew(PChar(StrNewNo));
end;

procedure TranslateResourceStrings;
begin
  InitNewStrings;
  HookResourceStrings;
end;

initialization
  // InitNewStrings;
  // TranslateResourceStrings;

finalization
  FreeStrings;

end.
