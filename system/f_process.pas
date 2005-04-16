{ f_process.pas: Prozesse, Fenster, ...

  Copyright (c) 2004-2005 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  08.01.2005

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_process.pas stellt systembezogene Funktionen zur Verfügung:
    * Instanzenmanagement
    * Ausführen von Kommandozeilenprogrammen


  exportierte Funktionen/Prozeduren:

    GetDOSOutput(const lpCommandLine: PChar; const GetStdErr: Boolean): string
    IsFirstInstance(var hwndPrevInstance: HWnd; WType, WCaption: string): Boolean

}

unit f_process;

interface

uses Windows;

function GetDOSOutput(const lpCommandLine: PChar; const GetStdErr: Boolean): string;
function IsFirstInstance(var hwndPrevInstance: HWnd; WType, WCaption: string): Boolean;

implementation

{ IsFirstInstance --------------------------------------------------------------

  IsFirstInstance prüft, ob die Instanz, die diese Funktion aufruft, die erste
  Instanz von cdrtfe ist.
  Argumente:    hwndPrevInstance  Variable für die Rückgabe des Handles zur
                                  vorigen Instanz, sofern vorhanden. Wenn keine
                                  andere Instanz läuft, wird das Handle der
                                  aktuellen Instanzzurückgegeben.
                WType             Typ des Hauptfensters
                WCAption          Fenstertitel
  Rückgabewert: True, wenn keine weitere Instanz gefunden wurde, False sonst   }

function IsFirstInstance(var hwndPrevInstance: HWnd;
                         WType, WCaption: string): Boolean;
var hwndIDE: HWnd;
    hwndInstance: HWnd;
begin
  {find other instance, first own window handle}
  hwndInstance := FindWindow(PChar(WType), PChar(WCaption));
  {  if hwndInstance <> self.Handle then
    hwndPrevInstance := hwndInstance
  else}
  {first other instances window}
  hwndPrevInstance := FindWindowEx(0, hwndInstance, PChar(WType), PChar(WCaption));
  {Delphi IDE}
  hwndIDE := FindWindow('TAppBuilder', nil);
  if (hwndIDE <> 0) or // hwndIDE is 0 if there's no Delphi IDE running
     (hwndPrevInstance = 0) or
     (hwndPrevInstance = 65934) then // there is another instance running
  begin
    hwndPrevInstance := hwndInstance;
  end;
  if hwndInstance <> hwndPrevInstance then
  begin
    Result := False;
  end else
  begin
    Result := True;
  end;
end;

{ GetDOSOutput -----------------------------------------------------------------

  GetDOSOutput führt die Kommandozeile lpCommandline aus und leitet die Ausgaben
  der Konsolenanwendung in eine Stringvariable um. Diese Funktion stammt aus dem
  Internet und wurde ein wenig verändert. Wenn GetStdErr = False, dann werden
  Fehlermeldungen ignoriert. Steuerzeichen (z.B. LF) werden nicht entfernt.
  Diese Funktion erzeugt im Fehlerprotokoll von MemProof die Meldung 'Attempt to
  free unexisting resource' für die CloseHandle-Anweisungen von hReadPipe und
  hWritePipe, was keinen Einfluß auf die Funktion hat.                         }

function GetDOSOutput(const lpCommandLine: PChar;
                      const GetStdErr: Boolean): string;

var lpPipeAttributes: TSecurityAttributes;
    hReadPipe: THandle;
    hWritePipe: THandle;
    lpStartupInfo: TStartupInfo;
    lpProcessInformation: TProcessInformation;
    lpNumberOfBytesRead: DWORD;
    Buffer: array[0..1023] of Char;
begin
  Result := '';
  ZeroMemory(@lpPipeAttributes, SizeOf(TSecurityAttributes));
  lpPipeAttributes.nLength := SizeOf(TSecurityAttributes);
  lpPipeAttributes.bInheritHandle := True;
  if CreatePipe(hReadPipe, hWritePipe, @lpPipeAttributes, 0) then
  begin
    ZeroMemory(@lpStartupInfo, SizeOf(TStartupInfo));
    lpStartupInfo.cb := SizeOf(TStartupInfo);
    lpStartupInfo.dwFlags := STARTF_USESTDHANDLES;
    lpStartupInfo.hStdOutput := hWritePipe;
    if GetStdErr then
    begin
      lpStartupInfo.hStdError := hWritePipe;
    end;
    lpStartupInfo.dwFlags := lpStartupInfo.dwFlags or STARTF_USESHOWWINDOW;
    lpStartupInfo.wShowWindow := SW_hide;
    if CreateProcess(nil, lpCommandLine, nil, nil, True, CREATE_NEW_CONSOLE,
      nil, nil, lpStartupInfo, lpProcessInformation) then
      try
        CloseHandle(hWritePipe);
        Buffer[0] := #0;
        repeat
          Result := Result + Buffer;
          ZeroMemory(@Buffer, SizeOf(Buffer));
          lpNumberOfBytesRead := 0;
        until not ReadFile(hReadPipe, Buffer, SizeOf(Buffer) - 1,
                           lpNumberOfBytesRead, nil);
      finally
        CloseHandle(hReadPipe);
        CloseHandle(lpProcessInformation.hThread);
        CloseHandle(lpProcessInformation.hProcess);
      end;
  end;
end;

(*
{ Alternative Variante von GetDOSOutput, die leider auch nicht weniger Fehler
  hat.}

function GetDOSOutput(const lpCommandLine: PChar;
                      const GetStdErr: Boolean): string;
var hChildStdinRd, hChildStdinWr, hChildStdinWrDup,
    hChildStdoutRd, hChildStdoutWr,
    hSaveStdin, hSaveStdout: THandle;

    saAttr: TSecurityAttributes;
    siStartInfo: TStartupInfo;
    piProcInfo: TProcessInformation;

    Success: Boolean;
    lpNumberOfBytesRead: DWORD;
    Buffer: array[0..1023] of Char;

begin
  {Pipe-Handles vererbbar machen}
  saAttr.nLength := SizeOf(TSecurityAttributes);
  saAttr.bInheritHAndle := True;
  saAttr.lpSecurityDescriptor := nil;

  {Umleitung von Stdout des Child-Prozesses:}

  {aktuellen Handle von Stdout sichern}
  hSaveStdout := GetStdHandle(STD_OUTPUT_HANDLE);

  {Pipe erzeugen für Stdout des Child-Prozesses}
  Success := CreatePipe(hChildStdoutRd, hChildStdoutWr, @saAttr, 0);
  if not Success then
    raise Exception.Create('Stdout-Pipe konnte nicht erzeugt werden!');

  {Stdout umleiten}
  Success := SetStdHandle(STD_OUTPUT_HANDLE, hChildStdoutWr);
  if not Success then
    raise Exception.Create('Umleitung von Stdout fehlgeschlagen!');

  {Umleitung von Stdin des Child-Prozesses}

  {aktuellen Handle von Stdin sichern}
  hSaveStdin := GetStdHandle(STD_INPUT_HANDLE);

  {Pipe erzeugen für Stdin des Child-Prozesses}
  Success := CreatePipe(hChildStdinRd, hChildStdinWr, @saAttr, 0);
  if not Success then
    raise Exception.Create('Stdin-Pipe konnte nicht erzeugt werden!');

  {Stdin umleiten}
  Success := SetStdHandle(STD_INPUT_HANDLE, hChildStdinRd);
  if not Success then
    raise Exception.Create('Umleitung von Stdin fehlgeschlagen!');

  {Write-Handle zur Pipe verdoppeln, damit Handle nicht vererbt wird}
  Success := DuplicateHandle(GetCurrentProcess(), hChildStdinWr,
                             GetCurrentProcess(), @hChildStdinWrDup,
                             0, False, DUPLICATE_SAME_ACCESS);
  if not Success then
    raise Exception.Create('Handle konnte nicht dupliziert werden!');
  CloseHandle(hChildStdinWr);

  {Child-Prozess erzeugen}
  siStartInfo.cb := SizeOf(TStartupInfo);
  siStartInfo.lpReserved  := nil;
  siStartInfo.lpReserved2 := nil;
  siStartInfo.cbReserved2 := 0;
  siStartInfo.lpDesktop   := nil;
  siStartInfo.dwFlags     := siStartInfo.dwFlags or STARTF_USESHOWWINDOW;
  siStartInfo.wShowWindow := SW_hide;
  if GetStdErr then
  begin
    siStartInfo.hStdError := siStartInfo.hStdOutput;
  end;
  Success := CreateProcess(nil,
                           lpCommandLine,
                           nil,
                           nil,
                           True,
                           CREATE_NEW_CONSOLE,
                           nil,
                           nil,
                           siStartInfo,
                           piProcInfo);
  if not Success then
    raise Exception.Create('Prozess konnte nicht gestartet werden!');

  {Stdin und Stdout wiederherstellen}
  Success := SetStdHandle(STD_INPUT_HANDLE, hSaveStdin);
  if not Success then
    raise Exception.Create('Wiederherstellung von Stdin fehlgeschlagen!');

  Success := SetStdHandle(STD_OUTPUT_HANDLE, hSaveStdout);
  if not Success then
    raise Exception.Create('Wiederherstellung von Stdout fehlgeschlagen!');

  {in die Input-Pipe des Child-Prozesses schreiben}
  // WriteFile(hChildStdinWrDup, ...)

  {Pipe schließen, damit der Prozess aufhört zu lesen}
  Success := CloseHandle(hChildStdinWrDup);
  if not Success then
    raise Exception.Create('Schließen der Pipe fehlgeschlagen!');

  {aus der Output-Pipe des Child-Prozesses lesen}

  {erst das Write-Ende schließen}
  Success := CloseHandle(hChildStdoutWr);
  if not Success then
    raise Exception.Create('Schließen der Pipe fehlgeschlagen!');

  {lesen}
   Buffer[0] := #0;
   repeat
     Result := Result + Buffer;
     ZeroMemory(@Buffer, SizeOf(Buffer));
     lpNumberOfBytesRead := 0;
   until not ReadFile(hChildStdoutRd, Buffer, SizeOf(Buffer) - 1,
                      lpNumberOfBytesRead, nil);

   {Aufräumen}
   CloseHandle(piProcInfo.hThread);
   CloseHandle(piProcInfo.hProcess);
   CloseHandle(hSaveStdin);
   CloseHandle(hSaveStdout);
end;                        *)

end.
