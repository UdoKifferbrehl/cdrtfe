{ cl_imagelists.pas: Zugriff auf SytemImageList und Icons

  Copyright (c) 2004 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  25.07.2004

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  cl_imagelist.pas bietet den Zugriff auf die SystemImageList (jeweils für große
  und kleine Icons) und die Icons, die in die Exe einkompiliert wurden.


  TImageLists: Objekt, das die Image-Listen enthält. Direkter Zugriff auf die
               Listen möglich. Keine Properties. Keine speziellen Methoden.

    Properties   -

    Variablen    LargeImages, SmallImages, IconImages,
                 IconFolder, IconFolderSelected, IconCD, IconCDA

    Methoden     Create(AOwner: TComponent)
                 
}

unit cl_imagelists;

interface

uses Classes, Forms, Controls, Windows, ShellApi, Graphics;

type TImageLists = class(TObject)
     private
     public
       LargeImages: TImageList;
       SmallImages: TImageList;
       IconImages: TImageList;
       IconFolder        : Integer;
       IconFolderSelected: Integer;
       IconCD            : Integer;
       IconCDA           : Integer;
       constructor Create(AOwner: TComponent);
       destructor Destroy; override;
     end;

implementation

{ TImageLists ---------------------------------------------------------------- }

{ TImageLists - private }

{ TImageLists - public }

constructor TImageLists.Create(AOwner: TComponent);
var SysIL: uint;
    SFI  : TSHFileInfo;
    Icon : TIcon;
    i    : Integer;
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
  {eigene Icons aus der Exe laden}
  IconImages := TImageList.Create(AOwner);
  Icon := TIcon.Create;
  for i := 0 to ExtractIcon(Application.Handle,
                            PChar(Application.ExeName), -1) - 1 do
  begin
    Icon.Handle := ExtractIcon(Application.Handle,
                               PChar(Application.ExeName), i);
    IconImages.AddIcon(Icon);
  end;
  Icon.Free;
  {Icon-Indizes festlegen}
  IconFolder := 2;
  IconFolderSelected :=3;
  IconCD := 4;
  IconCDA := 5;
end;

destructor TImageLists.Destroy;
begin
  LargeImages.Free;
  SmallImages.Free;
  IconImages.Free;
  inherited Destroy;
end;

end.
