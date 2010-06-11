{ cl_exceptionlog.pas:

  The contents of this file are subject to the Mozilla Public License Version
  1.1 (the "License"); you may not use this file except in compliance with the
  License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

  Software distributed under the License is distributed on an "AS IS" basis,
  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
  the specific language governing rights and limitations under the License.

  The Original Code is ExceptDlg.pas (included in the JCL).

  The Initial Developer of the Original Code is Petr Vones.
  Portions created by Petr Vones are Copyright (C) of Petr Vones.

  Contributors:
    Oliver Valencia

  ------------------------------------------------------------------------------

  Get call stack and other information when an exception occurs. Based on the
  JEDI Code Library (JCL).

  Last modified: 2010/06/11

}


unit cl_exceptionlog;

{$I jcl.inc}
{$I directives.inc}

interface

uses Windows, Classes, Forms, Controls, SysUtils, JclDebug;

type TExceptionLog = class(TObject)
     private
       FException        : Exception;
       FThread           : TJclDebugThread;
       FReport           : TStringList;
       FCallStackData    : TStringList;
       FLastActiveControl: TWinControl;
       function GetDefaultFileName: string;
       procedure CreateReport;
     public
       constructor Create;
       destructor Destroy; override;
       class procedure ExceptionHandler(Sender: TObject; E: Exception);
       class procedure ExceptionThreadHandler(Thread: TJclDebugThread);
       class procedure ShowException(E: Exception; Thread: TJclDebugThread);
       property Report: TStringList read FReport;
     end;

     TExceptionLogClass = class of TExceptionLog;

var ExceptionLogClass: TExceptionLogClass = TExceptionLog;

implementation

uses JclHookExcept, JclSysUtils, JclFileUtils, JclStrings, JclPeImage,
     JclSysinfo,
     frm_exceptdlg;

resourcestring
  RsAppError = '%s - application error';
  RsAppErrorMessage = 'An error has occurred in this application.';
  RsExceptionClass = 'Exception class  : %s';
  RsExceptionAddr = 'Exception address: %p';
  RsExceptionMessage = 'Exception message: %s';
  RsStackList = 'Stack list, generated %s';
  RsModulesList = 'List of loaded modules:';
  RsOSVersion = 'System   : %s %s, Version: %d.%d, Build: %x, "%s"';
  RsProcessor = 'Processor: %s, %s, %d MHz %s%s';
  RsScreenRes = 'Display  : %dx%d pixels, %d bpp';
  RsActiveControl = 'Active Controls hierarchy:';
  RsThread = 'Thread: %s';
  RsMissingVersionInfo = '(no version info)';

const MaxLineLength = 79;

var ExceptionLog: TExceptionLog;
    ExceptionShowing: Boolean;  // True, wenn eine Exception behandelt wird

{ Hilfsprozeduren/-funktionen ------------------------------------------------ }

{ HookShowException ------------------------------------------------------------

  //============================================================================
  // TApplication.HandleException method code hooking for exceptions from DLLs
  //============================================================================

  // We need to catch the last line of TApplication.HandleException method:
  // [...]
  //   end else
  //    SysUtils.ShowException(ExceptObject, ExceptAddr);
  // end;

  from ExceptDlg.pas by Petr Vones                                             }

procedure HookShowException(ExceptObject: TObject; ExceptAddr: Pointer);
begin
  if JclValidateModuleAddress(ExceptAddr) and
     (ExceptObject.InstanceSize >= Exception.InstanceSize) then
    TExceptionLog.ExceptionHandler(nil, Exception(ExceptObject))
  else
    SysUtils.ShowException(ExceptObject, ExceptAddr);
end;

{ HookTApplicationHandleException ----------------------------------------------

  from ExceptDlg.pas by Petr Vones                                             }

function HookTApplicationHandleException: Boolean;
const CallOffset      = $86;
      CallOffsetDebug = $94;
type  PCALLInstruction = ^TCALLInstruction;
      TCALLInstruction = packed record
        Call: Byte;
        Address: Integer;
      end;
var TApplicationHandleExceptionAddr,
    SysUtilsShowExceptionAddr       : Pointer;
    CALLInstruction                 : TCALLInstruction;
    CallAddress                     : Pointer;
    NW                              : DWORD;

  function CheckAddressForOffset(Offset: Cardinal): Boolean;
  begin
    try
      CallAddress := Pointer(Cardinal(TApplicationHandleExceptionAddr) +
                             Offset);
      CALLInstruction.Call := $E8;
      Result := PCALLInstruction(CallAddress)^.Call = CALLInstruction.Call;
      if Result then
      begin
        if IsCompiledWithPackages then
          Result := PeMapImgResolvePackageThunk(Pointer(Integer(CallAddress) +
                    Integer(PCALLInstruction(CallAddress)^.Address) +
                    SizeOf(CALLInstruction))) = SysUtilsShowExceptionAddr
        else
          Result := PCALLInstruction(CallAddress)^.Address =
                    Integer(SysUtilsShowExceptionAddr) - Integer(CallAddress) -
                    SizeOf(CALLInstruction);
      end;
    except
      Result := False;
    end;    
  end;

begin
  TApplicationHandleExceptionAddr :=
    PeMapImgResolvePackageThunk(@TApplication.HandleException);
  SysUtilsShowExceptionAddr :=
    PeMapImgResolvePackageThunk(@SysUtils.ShowException);
  Result := CheckAddressForOffset(CallOffset) or
            CheckAddressForOffset(CallOffsetDebug);
  if Result then
  begin
    CALLInstruction.Address := Integer(@HookShowException) -
                               Integer(CallAddress) - SizeOf(CALLInstruction);
    Result := WriteProcessMemory(GetCurrentProcess, CallAddress,
                                 @CALLInstruction, SizeOf(CALLInstruction), NW);
    if Result then
      FlushInstructionCache(GetCurrentProcess, CallAddress,
                            SizeOf(CALLInstruction));
  end;
end;

{ GetBPP -----------------------------------------------------------------------

  bestimmt die Farbtiefe.                                                      }

function GetBPP: Integer;
var DC: HDC;
begin
  DC := GetDC(0);
  Result := GetDeviceCaps(DC, BITSPIXEL) * GetDeviceCaps(DC, PLANES);
  ReleaseDC(0, DC);
end;

{ SortModulesListByAddressCompare ----------------------------------------------

  Vergleichsfunktion für Module (nach Adressen).                               }

function SortModulesListByAddressCompare(List: TStringList;
                                         Index1, Index2: Integer): Integer;
begin
  Result := Integer(List.Objects[Index1]) - Integer(List.Objects[Index2]);
end;

{ TExceptionLog -------------------------------------------------------------- }

{ TExceptionLog - private }

{ GetDefaultFileName -----------------------------------------------------------

  generiert den Standard-Dateinamen für das Protokoll.                         }

function TExceptionLog.GetDefaultFileName: string;
begin
  Result := // PathExtractFileDirFixed(ParamStr(0)) +
              PathExtractFileNameNoExt(ParamStr(0)) + '_err.log';
end;

{ CreateReport -----------------------------------------------------------------

  erstellt den Fehlerbericht.                                                  }

procedure TExceptionLog.CreateReport;

  procedure AddSeperatorLine;
  begin
    FReport.Add(StrRepeat('-', MaxLineLength));
  end;

  procedure AddHeader;
  begin
    AddSeperatorLine;
    FReport.Add(Format('| %-*s |', [MaxLineLength - 4, DateTimeToStr(Now)]));
    AddSeperatorLine;
  end;

  procedure AddExceptionInfo;
  begin
    with FReport do
    begin
      Add(Format(RsExceptionClass, [FException.ClassName]));
      Add(Format(RsExceptionMessage, [FException.Message]));
      if FThread = nil then
        Add(Format(RsExceptionAddr, [ExceptAddr]))
      else
        Add(Format(RsThread, [FThread.ThreadInfo]));
    end;
    AddSeperatorLine;
  end;

  procedure AddStackList;
  var StackList: TJclStackInfoList;
  //  i        : Integer;
  begin
    StackList := JclLastExceptStackList;
    if Assigned(StackList) then
    begin
      FReport.Add(Format(RsStackList, [DateTimeToStr(StackList.TimeStamp)]));
      StackList.AddToStrings(FReport, False, True, True);
  {   for i := 0 to StackList.Count - 1 do
        FReport.Add('  ' +
          GetLocationInfoStr(StackList.Items[I].CallerAdr, False, True, True));}
    end;
    AddSeperatorLine;
  end;

  procedure AddModuleList;              { based on ExceptDlg.pas by Petr Vones }
  var SL          : TStringList;
      i           : Integer;
      ModuleName  : TFileName;
      ModuleBase  : Cardinal;
      NtHeaders   : PImageNtHeaders;
      ImageBaseStr: string;
  begin
    SL := TStringList.Create;
    try
      if LoadedModulesList(SL, GetCurrentProcessId) then
      begin
        FReport.Add(RsModulesList);
        SL.CustomSort(SortModulesListByAddressCompare);
        for I := 0 to SL.Count - 1 do
        begin
          ModuleName := SL[i];
          ModuleBase := Cardinal(SL.Objects[I]);
          FReport.Add(Format('[%.8x] %s', [ModuleBase, ModuleName]));
          NtHeaders := PeMapImgNtHeaders(Pointer(ModuleBase));
          if (NtHeaders <> nil) and
             (NtHeaders^.OptionalHeader.ImageBase <> ModuleBase) then
            ImageBaseStr := Format('<%.8x> ',
                                   [NtHeaders^.OptionalHeader.ImageBase])
          else
            ImageBaseStr := StrRepeat(' ', 11);
          if VersionResourceAvailable(ModuleName) then
            with TJclFileVersionInfo.Create(ModuleName) do
            try
              FReport.Add(ImageBaseStr + BinFileVersion + ' - ' + FileVersion);
              if FileDescription <> '' then
                FReport.Add(StrRepeat(' ', 11) + FileDescription);
            finally
              Free;
            end
          else
            FReport.Add(ImageBaseStr + RsMissingVersionInfo);
        end;
      end;
    finally
      SL.Free;
    end;
    AddSeperatorLine;
  end;

  procedure AddCPUInfo;                 { based on ExceptDlg.pas by Petr Vones }
  const MMXText : array[Boolean] of PChar = ('', 'MMX');
        FDIVText: array[Boolean] of PChar = (' [FDIV Bug]', '');
  var CpuInfo: TCpuInfo;
  begin
    FReport.Add(Format(RsOSVersion, [GetWindowsVersionString,
                                     NtProductTypeString, Win32MajorVersion,
                                     Win32MinorVersion, Win32BuildNumber,
                                     Win32CSDVersion]));
    GetCpuInfo(CpuInfo);
    with CpuInfo do
      FReport.Add(Format(RsProcessor,
                         [Manufacturer, CpuName,
                          RoundFrequency(FrequencyInfo.NormFreq),
                          MMXText[MMX], FDIVText[IsFDIVOK]]));
    FReport.Add(Format(RsScreenRes, [Screen.Width, Screen.Height, GetBPP]));
    AddSeperatorLine;
  end;

  procedure AddLastActiveControl;       { based on ExceptDlg.pas by Petr Vones }
  var C: TWinControl;
  begin
    if (FLastActiveControl <> nil) then
    begin
      FReport.Add(RsActiveControl);
      C := FLastActiveControl;
      while C <> nil do
      begin
        FReport.Add(Format('%s "%s"', [C.ClassName, C.Name]));
        C := C.Parent;
      end;
      AddSeperatorLine;
    end;
  end;

  procedure GenerateCallstackData;
  var StackList: TJclStackInfoList;
      StackInfo: TJclLocationInfo;
      i        : Integer;
      s        : string;
  begin
    FCallstackData.Clear;
    StackList := JclLastExceptStackList;
    if Assigned(StackList) then
    begin
      for i := 0 to StackList.Count - 1 do
      begin
        GetLocationInfo(StackList.Items[i].CallerAdr, StackInfo);
        s := IntToHex(Integer(StackList.Items[i].CallerAdr), 8) + '|';
        s := s + '$' + Format('%.3x', [StackInfo.OffsetFromProcName]) + '|';
        s := s + StackInfo.ProcedureName + '|';
        s := s + ExtractFileName(StackInfo.SourceName) + '|';
        s := s + IntToStr(StackInfo.LineNumber) + '|';
        s := s + Format('%d', [StackInfo.OffsetFromLineNumber]);
        FCallstackData.Add(s);
      end;
    end;
  end;

begin
  AddHeader;
  AddExceptionInfo;
  AddStackList;
  AddModuleList;
  AddCPUInfo;
  AddLastActiveControl;
  GenerateCallstackData;
  {debug}
  // FReport.SaveToFile(GetDefaultFileName);
end;

{ TExceptionLog - public }

constructor TExceptionLog.Create;
begin
  inherited Create;
  FReport := TStringList.Create;
  FCallStackData := TStringList.Create;
end;

destructor TExceptionLog.Destroy;
begin
  FreeAndNil(FReport);
  FreeAndNil(FCallstackData);
  inherited Destroy;
end;

{ ExceptionHandler -------------------------------------------------------------

  wird Application.OnException zugewiesen.                                     }

class procedure TExceptionLog.ExceptionHandler(Sender: TObject; E: Exception);
begin
  if ExceptionShowing then
    Application.ShowException(E)
  else
  begin
    ExceptionShowing := True;
    try
      ShowException(E, nil);
    finally
      ExceptionShowing := False;
    end;
  end;
end;

{ ExceptionThreadHandler -------------------------------------------------------

  wird JclDebugThreadList.OnSyncException zugewiesen.                          }

class procedure TExceptionLog.ExceptionThreadHandler(Thread: TJclDebugThread);
var E: Exception;
begin
  E := Exception(Thread.SyncException);
  if Assigned(E) then
    if ExceptionShowing then
      Application.ShowException(E)
    else
    begin
      ExceptionShowing := True;
      try
        if IsIgnoredException(E.ClassType) then
          Application.ShowException(E)
        else
          ShowException(E, Thread);
      finally
        ExceptionShowing := False;
      end;
    end;
end;

{ ShowException ----------------------------------------------------------------

  ermittelt die Informationen, speichert die Log-Datei und zeigt die Infos in
  einem Dialog an.                                                             }

class procedure TExceptionLog.ShowException(E: Exception;
                                            Thread: TJclDebugThread);
var ExceptDlg: TExceptionDialog;
begin
  if ExceptionLog = nil then
    ExceptionLog := ExceptionLogClass.Create;
  try
    with ExceptionLog do
    begin
      FException := E;
      FThread := Thread;
      {Infos sammeln}
      FLastActiveControl := Screen.ActiveControl;
      {Report erstellen}
      CreateReport;
      {Dialog anzeigen}
      ExceptDlg := TExceptionDialog.Create(nil);
      try
        ExceptDlg.Caption := Format(RsAppError, [Application.Title]);
        ExceptDlg.ErrorMessage := AdjustLineBreaks(RsAppErrorMessage +
                                    #13#10 + #13#10 +
                                    StrEnsureSuffix('.', E.Message));
        ExceptDlg.Report := FReport;
        ExceptDlg.CallStackData := FCallStackData;
        ExceptDlg.DefaultFileName := GetDefaultFileName;
        ExceptDlg.ShowModal;
      finally
        ExceptDlg.Release;
      end;
    end;
  finally
    FreeAndNil(ExceptionLog);
  end;
end;

{ Initialisierungen ---------------------------------------------------------- }

procedure InitializeHandler;
begin
  JclStackTrackingOptions := JclStackTrackingOptions + [stRawMode];
  { $IFNDEF HOOK_DLL_EXCEPTIONS}
  JclStackTrackingOptions := JclStackTrackingOptions + [stStaticModuleList];
  { $ENDIF HOOK_DLL_EXCEPTIONS}
  JclDebugThreadList.OnSyncException := TExceptionLog.ExceptionThreadHandler;
  JclStartExceptionTracking;
  { $IFDEF HOOK_DLL_EXCEPTIONS}
  if HookTApplicationHandleException then
    JclTrackExceptionsFromLibraries;
  { $ENDIF HOOK_DLL_EXCEPTIONS}
  Application.OnException := TExceptionLog.ExceptionHandler;
end;

procedure UnInitializeHandler;
begin
  Application.OnException := nil;
  JclDebugThreadList.OnSyncException := nil;
  JclUnhookExceptions;
  JclStopExceptionTracking;
end;

initialization
  InitializeHandler;

finalization
  UnInitializeHandler;


end.
