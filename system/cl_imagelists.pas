{ cl_imagelists.pas: Zugriff auf SytemImageList und Icons

  Copyright (c) 2004-2006 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  06.10.2006

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  cl_imagelist.pas bietet den Zugriff auf die SystemImageList (jeweils für große
  und kleine Icons) und die Icons, die in die Exe einkompiliert wurden.


  TImageLists: Objekt, das die Image-Listen enthält. Direkter Zugriff auf die
               Listen möglich. Keine Properties.

    Properties   -

    Variablen    LargeImages, SmallImages, IconImages,
                 IconFolder, IconFolderSelected, IconCD, IconCDA

    Methoden     Create(AOwner: TComponent)
                 LoadGlyphs(Glyphs: TGlyphArray)
                 
}

unit cl_imagelists;

{$I directives.inc}

interface

uses Classes, Forms, Controls, Windows, ShellApi, Graphics, SysUtils,
     constant;

type TGlyphArray = array[1..cGlyphCount] of TBitmap;

     TImageLists = class(TObject)
     private
       procedure InitIcons(AOwner: TComponent);
     public
       LargeImages       : TImageList;
       SmallImages       : TImageList;
       IconImages        : TImageList;
       IconFolder        : Integer;
       IconFolderSelected: Integer;
       IconCD            : Integer;
       IconCDA           : Integer;
       constructor Create(AOwner: TComponent);
       destructor Destroy; override;
       procedure LoadGlyphs(Glyphs: TGlyphArray);
     end;

implementation

uses f_filesystem, f_init;

{ TImageLists ---------------------------------------------------------------- }

{ TImageLists - private }

{ InitIcons --------------------------------------------------------------------

  InitIcons lädt die Icons aus cdrtfe.exe, cdrtferes.dll oder \icons\*.        }

procedure TImageLists.InitIcons(AOwner: TComponent);
var Icon    : TIcon;
    Bitmap  : TBitmap;
    Mask    : TBitmap;
    Dummy   : HICON;
    i       : Integer;
    IconFile: string;
    Ok      : Boolean;
begin
  {eigene Icons aus der Exe laden}
  IconImages := TImageList.Create(AOwner);
  Icon := TIcon.Create;
  Bitmap := TBitmap.Create;
  Mask := TBitmap.Create;
  IconFile := StartUpDir + cCdrtfeResDll;
  if not FileExists(IconFile) or
     (ExtractIconEx(PChar(IconFile), -1, Dummy, Dummy, 0) < 5) then
    IconFile := Application.ExeName;
  {Application-Icon laden}
  Icon.Handle := ExtractIcon(Application.Handle, PChar(IconFile), 0);
  IconImages.AddIcon(Icon);
  {Treeview-/Listview-Icons laden}
  for i := 1 to 4 do
  begin
    Ok := True;
    try
      Bitmap.LoadFromFile(StartUpDir + cIconDir + '\' + IconNames[i] + cExtBmp);
    except
      Ok := False;
    end;
    if Ok then
    begin
      Mask.Assign(Bitmap);
      Mask.Mask(clFuchsia);
      IconImages.Add(Bitmap, Mask);
    end else
    begin
      Icon.Handle := ExtractIcon(Application.Handle, PChar(IconFile), i);
      IconImages.AddIcon(Icon);    
    end;
  end;
  Icon.Free;
  Bitmap.Free;
  Mask.Free;
  {Icon-Indizes festlegen}
  IconFolder := 1;
  IconFolderSelected := 2;
  IconCD := 3;
  IconCDA := 4;
end;

{ TImageLists - public }

constructor TImageLists.Create(AOwner: TComponent);
var SysIL: uint;
    SFI  : TSHFileInfo;
begin
  inherited Create;
  {SystemImageList: große Icons}
  LargeImages := TImageList.Create(AOwner);
  SysIL := SHGetFileInfo('', 0, SFI, SizeOf(SFI),
                         SHGFI_SYSICONINDEX or SHGFI_LARGEICON);
  if SysIL <> 0 then
  begin
    LargeImages.Handle := SysIL;
    LargeImages.ShareImages := True;
  end;
  {SystemImageList: kleine Icons}
  SmallImages := TImageList.Create(AOwner);
  SysIL := SHGetFileInfo('', 0, SFI, SizeOf(SFI),
                         SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
  if SysIL <> 0 then
  begin
    SmallImages.Handle := SysIL;
    SmallImages.ShareImages := True;
  end;
  {Icons laden}
  InitIcons(AOwner);
end;

destructor TImageLists.Destroy;
begin
  LargeImages.Free;
  SmallImages.Free;
  IconImages.Free;
  inherited Destroy;
end;

{ LoadGlyphs -------------------------------------------------------------------

  LoadGlyphs lädt die Icons für die Speedbuttons.                              }

procedure TImageLists.LoadGlyphs(Glyphs: TGlyphArray);
var Path          : string;
    SrcName       : string;
    ResDllName    : string;
    Ok            : Boolean;
    UseResDll     : Boolean;
    i, Index      : Integer;
    InstanceHandle: THandle;
begin
  Path := StartUpDir + cIconDir + '\';
  ResDllName := StartUpDir + cCdrtfeResDll;
  if FileExists(ResDllName) then
  begin
    InstanceHandle := LoadLibrary(PChar(ResDllName));
    UseResDll := True;
  end else
  begin
    InstanceHandle := hInstance;
    UseResDll := False;
  end;
  for i := 1 to High(Glyphs) do
  begin
    Ok := True;
    SrcName := Path + GlyphNames[i, 1] + cExtBmp;
    if not FileExists(SrcName) then
    begin
      Index := StrToIntDef(GlyphNames[i, 3], 0);
      if Index > 0 then SrcName := Path + GlyphNames[Index, 1] + cExtBmp;
      Ok := FileExists(SrcName);
    end;
    if Ok then
    begin
      try
        Glyphs[i].LoadFromFile(SrcName);
      except
        Ok := False;
      end;
    end;
    if not Ok then
    begin
      Glyphs[i].LoadFromResourceName(InstanceHandle, GlyphNames[i, 2]);
    end;
  end;
  if UseResDll then FreeLibrary(InstanceHandle);
end;

end.
