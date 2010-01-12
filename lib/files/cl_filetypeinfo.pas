{ $Id: cl_filetypeinfo.pas,v 1.2 2010/01/12 23:05:34 kerberos002 Exp $

  cl_filetypeinfo.pas: Dateityp und IconIndex cachen

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  12.01.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_filetypeinfo.pas implementiert ein Objekt, in welchem Informationen zum
  Dateityp (IconIndex und Dateityp in Abhängigkeit der Dateiendung) ge-
  speichert werden.


  TFileTypeInfo

    Properties   -

    Methoden     Create
                 GetFileInfo(const Name: string; var IconIndex: Integer; var FileType: string)

}

unit cl_filetypeinfo;

{$I directives.inc}

interface

uses Classes, ShellAPI, SysUtils, Windows;

type TFileTypeInfo = class(TObject)
     private
       FFileTypeInfoList: TStringList;
     public
       constructor Create;
       destructor Destroy; override;
       procedure GetFileInfo(const Name: string; var IconIndex: Integer; var FileType: string);
     end;

implementation


uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF} const_common;


{ TFileTypeInfo -------------------------------------------------------------- }

{ TFileTypeInfo - private }

{ TFileTypeInfo - public }

constructor TFileTypeInfo.Create;
begin
  inherited Create;
  FFileTypeInfoList := TStringList.Create;
end;

destructor TFileTypeInfo.Destroy;
begin
  FFileTypeInfoList.Free;
  inherited Destroy;
end;

{ GetFileInfo ------------------------------------------------------------------

  GetFileInfo liefert den Index des zur Datei gehörenden Icons in der
  SystemImagelist sowie die Dateityp zurück. Bereits ermittelte Infos werden
  zwischengespeichert, um die Zugriffszeiten zu minimieren.                    }
  
procedure TFileTypeInfo.GetFileInfo(const Name: string; var IconIndex: Integer;
                                    var FileType: string);
var Info     : TSHFileInfo;
    Extension: string;
    Infos    : string;
    IsFolder : Boolean;
    p        : Integer;
begin
  {Ein Ordner?}
  IsFolder := DirectoryExists(Name);
  {Dateiendung bestimmen}
  Extension := ExtractFileExt(Name);
  if IsFolder then Extension := ';';
  {Ist dieser Dateityp schon mal behandelt worden?}
  Infos := FFileTypeInfoList.Values[Extension];
  {Wenn nicht, dann Infos ermitteln}
  if Infos = '' then
  begin
    if (Extension = cExtExe) or IsFolder then
      SHGetFileInfo(PChar(Name), 0, Info,
                    SizeOf(TSHFileInfo),
                    SHGFI_SYSIconIndex or SHGFI_TYPENAME)
    else
      SHGetFileInfo(PChar(ExtractFileExt(Name)), FILE_ATTRIBUTE_NORMAL, Info,
                    SizeOf(TSHFileInfo),
                    SHGFI_SYSIconIndex or SHGFI_TYPENAME or
                    SHGFI_USEFILEATTRIBUTES);
    IconIndex := Info.IIcon;
    FileType := Info.szTypeName;
    {Infos in die Liste schreiben, außer es ist eine Verknüpfung, oder eine
     exe-Datei.}
    if (LowerCase(Extension) <> '.lnk') and
       (LowerCase(Extension) <> '.exe') then
    begin
      {$IFDEF DebugFileTypeInfoList}
      FormDebug.Memo1.Lines.Add(Extension + ': Dateiinfos nicht vorhanden, werden hinzugefügt.');
      {$ENDIF}
      FFileTypeInfoList.Add(Extension + '=' + IntToStr(IconIndex) + ':' +
                            FileType);
      {Debugging: List mit den Dateiinfos anzeigen}
      {$IFDEF DebugFileTypeInfoList}
      FormDebug.Memo2.Lines.Assign(FFileTypeInfoList);
      {$ENDIF}
    end;
  end else
  {Infos schon in der Liste}
  begin
    {$IFDEF DebugFileTypeInfoList}
    FormDebug.Memo1.Lines.Add(Extension + ': Dateiinfos vorhanden.');
    {$ENDIF}
    Delete(Infos, 1, Pos('=', Infos));
    p := Pos (':', Infos);
    IconIndex := StrToIntDef(Copy(Infos, 1, p - 1), 0);
    Delete(Infos, 1, p);
    FileType := Infos;
  end;
end;

end.
