{ cl_imagelists.pas: Zugriff auf SytemImageList und Icons

  Copyright (c) 2004-2012 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  12.05.2012

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  cl_imagelist.pas bietet den Zugriff auf die SystemImageList (jeweils für große
  und kleine Icons) und die Icons, die in die Exe einkompiliert wurden.


  TImageLists: Objekt, das die Image-Listen enthält. Direkter Zugriff auf die
               Listen möglich. Keine Properties.

    Properties   -

    Variablen    LargeImages, SmallImages, IconImages, ToolButtonImages,
                 ToolButtonImagesD, IconFolder, IconFolderSelected, IconCD,
                 IconCDA, IconCDDrive

    Methoden     Create(AOwner: TComponent)
                 LoadGlyphs(Glyphs: TGlyphArray)
                 
}

unit cl_imagelists;

{$I directives.inc}

interface

uses Classes, Forms, Controls, Windows, ShellApi, Graphics, SysUtils, CommCtrl,
     const_glyphs;


type TGlyphArray = array[1..cGlyphCount] of TBitmap;

     TImageLists = class(TObject)
     private
       procedure InitIcons(AOwner: TComponent);
       procedure InitToolButtonImages(AOwner: TComponent);
     public
       LargeImages       : TImageList;
       SmallImages       : TImageList;
       IconImages        : TImageList;
       ToolButtonImages  : TImageList;
       ToolButtonImagesD : TImageList;
       IconFolder        : Integer;
       IconFolderSelected: Integer;
       IconCD            : Integer;
       IconCDA           : Integer;
       IconInformation   : Integer;
       IconWarning       : Integer;
       IconError         : Integer;
       IconWinlogo       : Integer;
       IconCDDrive       : Integer;
       constructor Create(AOwner: TComponent);
       destructor Destroy; override;
       procedure LoadGlyphs(Glyphs: TGlyphArray);
     end;

implementation

uses f_locations, f_filesystem, const_locations, const_common;

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
    Info    : TSHFileInfo;
    Drives  : TStringList;
begin
  {eigene Icons aus der Exe laden}
  IconImages := TImageList.Create(AOwner);
  IconImages.Handle := ImageList_Create(16, 16, ILC_COLOR32 or ILC_MASK, 0, 0);
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
  {zusätzliche System-Icons laden}
  Icon.Handle := LoadIcon(0, IDI_INFORMATION);
  IconImages.AddIcon(Icon);
  Icon.Handle := LoadIcon(0, IDI_WARNING);
  IconImages.AddIcon(Icon);
  Icon.Handle := LoadIcon(0, IDI_ERROR);
  IconImages.AddIcon(Icon);
  Icon.Handle := LoadIcon(0, IDI_WINLOGO);
  IconImages.AddIcon(Icon);
  {systemabhängige Ordner-Icons}
  IconFile := ExtractFileDir(ParamStr(0));
  SHGetFileInfo(PChar(IconFile), 0, Info,
                SizeOf(TSHFileInfo),
                SHGFI_ICON or SHGFI_SMALLICON);
  Icon.Handle := Info.hIcon;
  IconImages.AddIcon(Icon);
  SHGetFileInfo(PChar(IconFile), 0, Info,
                SizeOf(TSHFileInfo),
                SHGFI_ICON or SHGFI_SMALLICON or SHGFI_OPENICON);
  Icon.Handle := Info.hIcon;
  IconImages.AddIcon(Icon);
  {Laufwerksicon für CD-Laufwerke}
  Drives := TStringList.Create;
  if GetDriveList(DRIVE_CDROM, Drives) > 0 then
  begin
    IconFile := Drives[0];
  end;
  Drives.Free;
  SHGetFileInfo(PChar(IconFile), 0, Info,
                SizeOf(TSHFileInfo),
                SHGFI_ICON or SHGFI_SMALLICON);
  Icon.Handle := Info.hIcon;
  IconImages.AddIcon(Icon);

  Icon.Free;
  Bitmap.Free;
  Mask.Free;
  {Icon-Indizes festlegen}
  IconFolder         :=  9; //1;
  IconFolderSelected := 10; //2;
  IconCD             :=  3;
  IconCDA            :=  4;
  IconInformation    :=  5;
  IconWarning        :=  6;
  IconError          :=  7;
  IconWinlogo        :=  8;
  IconCDDrive        := 11;
end;

{ InitToolButtonImages ---------------------------------------------------------

  lädt die Bitmaps für die ToolButtons aus cdrtfe.exe.                         }

procedure TImageLists.InitToolButtonImages(AOwner: TComponent);
var InstanceHandle: THandle;
    Bitmap        : TBitmap;
    Mask          : TBitmap;
    i             : Integer;
    ResNameA      : string;
    ResNameD      : string;
begin
  ToolButtonImages := TImageList.Create(AOwner);
  ToolButtonImagesD := TImageList.Create(AOwner);
  Bitmap := TBitmap.Create;
  Mask := TBitmap.Create;
  InstanceHandle := hInstance;
  for i := 1 to cToolButtonCount do
  begin
    ResNameA := 'tb' + IntToStr(i) + 'a';
    ResNameD := 'tb' + IntToStr(i) + 'd';
    Bitmap.LoadFromResourceName(InstanceHandle, ResNameA);
    Mask.Assign(Bitmap);
    Mask.Mask(clFuchsia);
    ToolButtonImages.Add(Bitmap, Mask);
    Bitmap.LoadFromResourceName(InstanceHandle, ResNameD);
    Mask.Assign(Bitmap);
    Mask.Mask(clFuchsia);
    ToolButtonImagesD.Add(Bitmap, Mask);
  end;
  Bitmap.Free;
  Mask.Free;
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
  {ToolButtonImages laden}
  InitToolButtonImages(AOwner);
end;

destructor TImageLists.Destroy;
begin
  LargeImages.Free;
  SmallImages.Free;
  ToolButtonImages.Free;
  ToolButtonImagesD.Free;
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
