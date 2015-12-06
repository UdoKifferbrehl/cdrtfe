{ cl_imagelists.pas: Zugriff auf SytemImageList und Icons

  Copyright (c) 2004-2015 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte ƒnderung  06.12.2015

  Dieses Programm ist freie Software. Sie kˆnnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew‰hrleistungsausschluﬂ) in license.txt, COPYING.txt.  

  cl_imagelist.pas bietet den Zugriff auf die SystemImageList (jeweils f¸r groﬂe
  und kleine Icons) und die Icons, die in die Exe einkompiliert wurden.


  TImageLists: Objekt, das die Image-Listen enth‰lt. Direkter Zugriff auf die
               Listen mˆglich. Keine Properties.

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

uses f_locations, f_filesystem, f_window, const_locations, const_common;

{ TImageLists ---------------------------------------------------------------- }

{ TImageLists - private }

{ InitIcons --------------------------------------------------------------------

  InitIcons l‰dt die Icons aus cdrtfe.exe, cdrtferes.dll oder \icons\*.        }

procedure TImageLists.InitIcons(AOwner: TComponent);
var Icon    : TIcon;
    IconFile: string;
    Info    : TSHFileInfo;
    Drives  : TStringList;
    IconSize: Integer;
begin
  IconSize := 16;
  if IsHighDPI then
  begin
    if ScaleByDPI(16) >= 24 then IconSize := 24;
    if ScaleByDPI(16) >= 32 then IconSize := 32;
  end;
  {eigene Icons aus der Exe laden}
  IconImages := TImageList.Create(AOwner);
  IconImages.Width := IconSize;
  IconImages.Height := IconSize;
  IconImages.Handle := ImageList_Create(IconSize, IconSize,
                                        ILC_COLOR32 or ILC_MASK, 0, 0);
  Icon := TIcon.Create;
  IconFile := Application.ExeName;
  {Application-Icon laden}
  Icon.Handle := ExtractIcon(Application.Handle, PChar(IconFile), 0);
  IconImages.AddIcon(Icon);
  {zus‰tzliche System-Icons laden}
  Icon.Handle := LoadIcon(0, IDI_INFORMATION);
  IconImages.AddIcon(Icon);
  Icon.Handle := LoadIcon(0, IDI_WARNING);
  IconImages.AddIcon(Icon);
  Icon.Handle := LoadIcon(0, IDI_ERROR);
  IconImages.AddIcon(Icon);
  Icon.Handle := LoadIcon(0, IDI_WINLOGO);
  IconImages.AddIcon(Icon);
  {systemabh‰ngige Ordner-Icons}
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
  {Laufwerksicon f¸r CD-Laufwerke}
  Drives := TStringList.Create;
  if GetDriveList(DRIVE_CDROM, Drives) > 0 then
  begin
    IconFile := Drives[0];
  end;
  Drives.Free;
  SHGetFileInfo(PChar(IconFile), 0, Info,
                SizeOf(TSHFileInfo),
                SHGFI_ICON or SHGFI_TYPENAME );
  Icon.Handle := Info.hIcon;
  IconImages.AddIcon(Icon);
  {cda-Icon}
  SHGetFileInfo(PChar('.cda'), 0, Info,
                SizeOf(TSHFileInfo),
                SHGFI_ICON or SHGFI_SMALLICON or SHGFI_SYSICONINDEX or
                SHGFI_USEFILEATTRIBUTES);
  Icon.Handle := Info.hIcon;
  IconImages.AddIcon(Icon);
  Icon.Free;
  {Icon-Indizes festlegen}
  IconCD             :=  0;
  IconInformation    :=  1;
  IconWarning        :=  2;
  IconError          :=  3;
  IconWinlogo        :=  4;
  IconFolder         :=  5;
  IconFolderSelected :=  6;
  IconCDDrive        :=  7;
  IconCDA            :=  8;
end;

{ InitToolButtonImages ---------------------------------------------------------

  l‰dt die Bitmaps f¸r die ToolButtons aus cdrtfe.exe.                         }

procedure TImageLists.InitToolButtonImages(AOwner: TComponent);
var InstanceHandle: THandle;
    Bitmap        : TBitmap;
    Mask          : TBitmap;
    i             : Integer;
    IconSize      : Integer;
    IconSizeStr   : string;
    ResNameA      : string;
    ResNameD      : string;
begin
  IconSize := 16;
  IconSizeStr := '';
  if IsHighDPI then
  begin
    if ScaleByDPI(16) >= 24 then IconSize := 24;
    if ScaleByDPI(16) >= 32 then IconSize := 32;
    if IconSize >= 24 then IconSizeStr := IntToStr(IconSize);
  end;
  ToolButtonImages := TImageList.Create(AOwner);
  ToolButtonImagesD := TImageList.Create(AOwner);
  ToolButtonImages.Width := IconSize;
  ToolButtonImages.Height := Iconsize;
  ToolButtonImagesD.Width := IconSize;
  ToolButtonImagesD.Height := Iconsize;
  Bitmap := TBitmap.Create;
  Mask := TBitmap.Create;
  InstanceHandle := hInstance;
  for i := 1 to cToolButtonCount do
  begin
    ResNameA := 'tb' + IntToStr(i) + 'a' + IconSizeStr;
    ResNameD := 'tb' + IntToStr(i) + 'd' + IconSizeStr;
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
  {SystemImageList: groﬂe Icons}
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

  LoadGlyphs l‰dt die Icons f¸r die Speedbuttons.                              }

procedure TImageLists.LoadGlyphs(Glyphs: TGlyphArray);
var DPIName       : string;
    i             : Integer;
    InstanceHandle: THandle;
begin
  InstanceHandle := hInstance;
  for i := 1 to High(Glyphs) do
  begin
    if IsHighDPI then
    begin
      DPIName := '';
      if ScaleByDPI(16) >= 24 then DPIName := '_24';
      if ScaleByDPI(16) >= 32 then DPIName := '_32';
    end;
    Glyphs[i].LoadFromResourceName(InstanceHandle, GlyphNames[i, 2] + DPIName);
  end;
end;

end.
