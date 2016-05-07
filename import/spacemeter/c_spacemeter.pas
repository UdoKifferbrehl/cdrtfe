{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  c_spacemeter.pas: Anzeigen des auf der Disk beanspruchten Speicherplatzes

  Copyright (c) 2008-2016 Oliver Valencia

  letzte Änderung  07.05.2016

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  c_spacemeter.pas implementiert eine visuelle Komponente, die den auf der Disk
  beanspruchten Speicherplatz darstellt.


  TSpaceMeter

    Properties   DiskSize                     (in MiB oder sec)
                 DiskSizeMax
                 DiskType
                 SpaceMeterMode

    Methoden     Create
                 Init

}

unit c_spacemeter;

{$I compiler.inc}

interface

uses Windows, Classes, Controls, ComCtrls, ExtCtrls, Graphics, Menus,
     QProgBar, SysUtils;

const cDiskTypeCount = 9;    // zählt von 0 an! counts from 0!

      cSpaceMeterDiskSizes: array[0..cDiskTypeCount] of Integer =
                              (650, 700, 800, 870, 4482, 8147, 23866, 47732,
                               95466, 122072);

      {$J+}
      cPopupMenuStrings: array[0..cDiskTypeCount] of string =
                           ('CD 650 MiB (74 min)',
                            'CD 700 MiB (80 min)',
                            'CD 800 MiB (90 min)',
                            'CD 870 MiB (99 min)',
                            'DVD 4.38 GiB',
                            'DVD/DL 7.96 GiB',
                            'BD 23.3 GiB',
                            'BD DL 46,6 GiB',
                            'BD TL 93,2 GiB',
                            'BD QL 119,2 GiB');

      cDiskTypeStrings: array[0..6] of string =
                          ('CD', 'DVD', 'DVD/DL', 'BD', 'BD DL',
                           'BD TL', 'BD QL');

      cUnitMiB: string = 'MiB';
      cUnitMin: string = 'min';
      {$J-}

type TSpaceMeterDiskType = (SMDT_CD650, SMDT_CD700, SMDT_CD800, SMDT_CD870,
                            SMDT_DVD, SMDT_DVD_DL, SMDT_BD, SMDT_BD_DL,
                            SMDT_BD_TL, SMDT_BD_QL);

     TSpaceMeterMode = (SMM_DataCD, SMM_XCD, SMM_AudioCD, SMM_NoDisk);

     TSMTypeChangeEvent = procedure of object;

     TScale = class(TGraphicControl)
     private
       FCapacity      : Integer;
       FSpaceMeterMode: TSpaceMeterMode;
       FUnitMiB       : string;
       FUnitMin       : string;
       FDiskType      : string;
     protected
       procedure Paint; override;
     public
       constructor Create(AOwner: TComponent); override;
     published
       property Capacity: Integer read FCapacity write FCapacity;
       property SpaceMeterMode: TSpaceMeterMode read FSpaceMeterMode write FSpaceMeterMode;
       property UnitMiB: string read FUnitMiB write FUnitMib;
       property UnitMin: string read FUnitMin write FUnitMin;
       property DiskType: string read FDiskType write FDiskType;
     end;

     TSpaceMeter = class(TPanel)
     private
       FCaptions      : string;
       FSpaceMeterMode: TSpaceMeterMode;
       FDiskType      : TSpaceMeterDiskType;
       FDiskSizeMax   : Integer;
       FDiskSize      : Integer;
       FProgressBar   : TQProgressBar;
       FScale         : TScale;
       FPopupMenu     : TPopupMenu;
       FColorOkStart  : TColor;
       FColorOkFinal  : TColor;
       FColorWarnStart: TColor;
       FColorWarnFinal: TColor;
       FRemainingSpaceString: string;
       FOnSpaceMeterTypeChange: TSMTypeChangeEvent;
       procedure AutoDestroy;
       procedure AutoInit;
       procedure InitPopupMenu;
       procedure SetCaptions(Value: string);
       procedure SetDiskSize(Value: Integer);
       procedure SetDiskSizeMax(Value: Integer);
       procedure SetDiskType(Value: TSpaceMeterDiskType);
       procedure SetSpaceMeterMode(Value: TSpaceMeterMode);
       procedure UpdateProgressBar;
       procedure UpdateRemainingSpace;
       procedure SpaceMeterTypeChange;
       {interne Eventhandler}
       procedure SpaceMeterResize(Sender: TObject);
       procedure MenuItemClick(Sender: TObject);
       procedure PopupMenuPopup(Sender: TObject);
     protected
     public
       constructor Create(AOwner: TComponent); override;
       destructor Destroy; override;
       procedure Init(CParent: TWinControl; PTop, PLeft, SWidth, SHeight: Integer; SMAnchors: TAnchors);
     published
       property Captions: string read FCaptions write SetCaptions;
       property DiskSize: Integer read FDiskSize write SetDiskSize;
       property DiskSizeMax: Integer read FDiskSizeMax write SetDiskSizeMax;
       property DiskType: TSpaceMeterDiskType read FDiskType write SetDiskType;
       property RemainingSpaceString: string read FRemainingSpaceString;
       property SpaceMeterMode: TSpaceMeterMode read FSpaceMeterMode write SetSpaceMeterMode;
       property OnSpaceMeterTypeChange: TSMTypeChangeEvent read FOnSpaceMeterTypeChange write FOnSpaceMeterTypeChange;
     end;

implementation

uses f_strings, f_largeint;

{ TScale --------------------------------------------------------------------- }

{ TScale - protected }

procedure TScale.Paint;
const Tick   = 1;
      Tick5  = 3;
      Tick10 = 5;
var TickCount : Integer;
    TickPos   : Integer;
    TickNumTxt: Integer;
    TickUnit  : string;
    DiskText  : string;
    i         : Integer;
    TickWidth : Double;
    Divisor   : Integer;
    OutText   : string;
    DiskType  : TSpaceMeterDiskType;
begin
  DiskType := (Self.Parent as TSpaceMeter).FDiskType;
  Canvas.Font.Name := (Owner as TPanel).Font.Name;
  DiskText := '[' + FDiskType + '] ';
  if FSpaceMeterMode = SMM_AudioCD then
  begin
    {AudioCD: Teilstrich = 60 sec}
    Divisor := 60;
    TickUnit := FUnitMin;
  end else
  if FSpaceMeterMode = SMM_NoDisk then
  begin
    Divisor := 10;
    TickUnit := '';
    DiskText := '';
  end else
  begin
    {Daten-CD/DVD:
     <1000 MiB: Teilstrich = 10 MiB; >= 1000 MiB: Teilstrich = 100MiB
     Daten-BD:
     Teilstrich = 1000MiB}
    Divisor := 10;
    if FCapacity > 1000 then Divisor := 100;
    if FCapacity > 10000 then Divisor := 1000;
    TickUnit := FUnitMiB;
  end;
  {Anzahl der Teilstriche bestimmen}
  TickCount := Round(FCapacity / Divisor);
  TickWidth := (Width - 1) / TickCount;
  {Initialisierungen}
  Canvas.Pen.Width := 1;
  Canvas.Pen.Color := RGB(0, 60, 116); //FTickColour;
  Canvas.Font.Color := clBlack;        //FTextColour;
  Canvas.Brush.Style := bsClear;
  {Einheit angeben}
  OutText := DiskText + TickUnit;
  Canvas.TextOut(0, Tick{10 + 1}, OutText);
  {Skala zeichnen}
  for i := 1 to TickCount do
  begin
    TickPos := Round(i * TickWidth);
    Canvas.MoveTo(TickPos, 0);
    if (i mod 5) = 0 then
    begin
      if (i mod 10) = 0 then
      begin
        case FSpaceMeterMode of
          SMM_AudioCD: TickNumTxt := i;
        else
          TickNumTxt := i * Divisor;
        end;                        
        OutText := IntToStr(TickNumTxt);
        if (FSpaceMeterMode = SMM_NoDisk) or
           ((DiskType in [SMDT_BD_TL, SMDT_BD_QL]) and (i = 10)) then OutText := '';
        Canvas.LineTo(TickPos, Tick10);
        Canvas.TextOut(TickPos - Canvas.TextWidth(OutText) - 2, Tick{10 + 1}, OutText);
      end else
      begin
        Canvas.LineTo(TickPos, Tick5);
      end;
    end else
    begin
      Canvas.LineTo(TickPos, Tick);
    end;
  end;
end;

{ TScale - protected }

constructor TScale.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FUnitMib := cUnitMiB;
  FUnitMin := cUnitMin;
  Self.ParentFont := False;
end;


{ TSpaceMeter ---------------------------------------------------------------- }

{ TSpaceMeter - private }

{ SetCaptions ------------------------------------------------------------------

  SetCaptions setzt die Strings für die Menü-Einträge und die Einheiten.       }

procedure TSpaceMeter.SetCaptions(Value: string);
var List   : TStringList;
    i      : Integer;
    MSCount: Integer;
begin
  List := TStringList.Create;
  List.Text := Value;
  MSCount := List.Count - 10; {die letzen neun Einträge sind Einheiten und }
  for i := 0 to MSCount {cDiskTypeCount} do                      {DiskTypen }
  begin
    cPopupMenuStrings[i] := List[i];
    FPopupMenu.Items[i].Caption := List[i];
   end;
  FScale.UnitMiB := List[MSCount {cDiskTypeCount} + 1];
  FScale.UnitMin := List[MSCount {cDiskTypeCount} + 2];
  for i := MSCount + 3 to List.Count - 1 do
  begin
    cDiskTypeStrings[i - MSCount - 3] := List[i];
  end;
  List.Free;
end;

{ InitPopupMenu ----------------------------------------------------------------

  initialisiert das PopupMenü.                                                 }

procedure TSpaceMeter.InitPopupMenu;
var i          : Integer;
    NewMenuItem: TMenuItem;
begin
  Self.PopupMenu := FPopupMenu;
  for i := 0 to cDiskTypeCount do
  begin
    NewMenuItem := TMenuItem.Create(Self);
    NewMenuItem.Caption := cPopupMenuStrings[i];
    NewMenuItem.Tag := i;
    NewMenuItem.RadioItem := True;
    NewMenuItem.OnClick := MenuItemClick;
    FPopupMenu.Items.Add(NewMenuItem);
  end;
  FPopupMenu.Items[0].Checked := True;
  FPopupMenu.OnPopup := PopupMenuPopup;
end;

{ MenuItemClick ----------------------------------------------------------------

  wird ausgelöst, wenn ein Eintrag aus dem Popup-Menü gewählt wird.            }

procedure TSpaceMeter.MenuItemClick(Sender: TObject);
begin
  Self.DiskType := TSpaceMeterDiskType((Sender as TMenuItem).Tag);
  (Sender as TMenuItem).Checked := True;
end;

{ PopupMenuPopup ---------------------------------------------------------------

  wird ausgelöst, wenn das Kontextmenü aufgerufen wird.                        }

procedure TSpaceMeter.PopupMenuPopup(Sender: TObject);
var i   : Integer;
    Menu: TPopupMenu;
begin
  Menu := Sender as TPopupMenu;
  for i := 0 to Menu.Items.Count - 1 do
  begin
    Menu.Items[i].Enabled := ((FSpaceMeterMode = SMM_DataCD) or
                              (cSpaceMeterDiskSizes[i] < 1000)) and
                             (FSPaceMeterMode <> SMM_NoDisk);
  end;
end;

{ AutoInit ---------------------------------------------------------------------

  Beim Erstellen einige Einstellungen automatisch setzen.                      }

procedure TSpaceMeter.AutoInit;
begin
  FDiskSizeMax    := 650;
  FDiskSize       := 0;
  FSpaceMeterMode := SMM_DataCD;
  {Panel}
  BevelInner := bvNone;
  BevelOuter := bvNone;
  Color      := clBtnFace;
  OnResize   := SpaceMeterResize;
  {ProgressBar}
  FColorOkStart   := RGB(0, 184, 0);   // $00004000;
  FColorOkFinal   := RGB(255, 255, 0); // $0000FFFF;
  FColorWarnStart := RGB(64, 0, 0);
  FColorWarnFinal := RGB(255, 0, 0);
  FProgressBar := TQProgressBar.Create(Self);     // $0000FFFF;
  FProgressBar.Parent := Self;
  FProgressBar.Top := 0;
  FProgressBar.Left := 0;
  FProgressBar.Height := 11;
  FProgressBar.Width := Self.Width;
  FprogressBar.StartColor := FColorOkStart;
  FProgressBar.FinalColor := FColorOkFinal;
  FProgressBar.ShowInactivePos := True;
  FProgressBar.InactivePosColor := RGB(240, 240, 240);
  FProgressBar.BarKind := bkCylinder;
  FProgressBar.BarLook := blMetal;
  FProgressBar.Maximum := 100;
  FProgressBar.Position := 0;
  {Scale - TGraphicControl}
  FScale := TScale.Create(Self);
  FScale.Parent := Self;
  FScale.Top := 13;
  FScale.Left := 0 + 3;
  FScale.Width := Self.Width - 6;
  FScale.Height := 30;
  FScale.Capacity := FDiskSizeMax;
  FScale.SpaceMeterMode := FSpaceMeterMode;
  {PopupMenu}
  FPopupMenu := TPopupMenu.Create(Self);
  InitPopupMenu;
end;

{ AutoDestroy ------------------------------------------------------------------

  Alles zerstören, was wir selbst erzeugt haben.                               }

procedure TSpaceMeter.AutoDestroy;
begin
  FProgressBar.Free;
  FScale.Free;
  FPopupMenu.Free;
end;

{ SetDiskSizeMax ---------------------------------------------------------------

  legt die maximale Disk-Größe fest.                                           }

procedure TSpaceMeter.SetDiskSizeMax(Value: Integer);
begin
  FDiskSizeMax := Value;
  FScale.Capacity := Value;
  case FDiskType of
    SMDT_CD650,
    SMDT_CD700,
    SMDT_CD800,
    SMDT_CD870 : FScale.DiskType := cDiskTypeStrings[0];
    SMDT_DVD   : FScale.DiskType := cDiskTypeStrings[1];
    SMDT_DVD_DL: FScale.DiskType := cDiskTypeStrings[2];
    SMDT_BD    : FScale.DiskType := cDiskTypeStrings[3];
    SMDT_BD_DL : FScale.DiskType := cDiskTypeStrings[4];
    SMDT_BD_TL : FScale.DiskType := cDiskTypeStrings[5];
    SMDT_BD_QL : FScale.DiskType := cDiskTypeStrings[6];
  else
    FScale.DiskType := '';
  end;
  UpdateProgressBar;
  UpdateRemainingSpace;
  FScale.Invalidate;
end;

{ SetSpaceMeterMode ------------------------------------------------------------

  legt die Projekt-Art fest (Daten-CD, Audio-CD, XCD).                         }

procedure TSpaceMeter.SetSpaceMeterMode(Value: TSpaceMeterMode);
begin
  FSpaceMeterMode := Value;
  FScale.SpaceMeterMode := Value;
  SetDiskType(FDiskType);
end;

{ SetDiskSize ------------------------------------------------------------------

  setzt die Größe des belegten Speichers.                                      }

procedure TSpaceMeter.SetDiskSize(Value: Integer);
begin
  FDiskSize := Value;
  UpdateProgressBar;
  UpdateRemainingSpace;
end;

{ SetDiskType ------------------------------------------------------------------

  setzt die Größe der Disk anhand des Typs.                                    }

procedure TSpaceMeter.SetDiskType(Value: TSpaceMeterDiskType);
var Size: Integer;
begin
  FDiskType := Value;
  case Value of
    SMDT_CD650 : Size := cSpaceMeterDiskSizes[Integer(SMDT_CD650)];
    SMDT_CD700 : Size := cSpaceMeterDiskSizes[Integer(SMDT_CD700)];
    SMDT_CD800 : Size := cSpaceMeterDiskSizes[Integer(SMDT_CD800)];
    SMDT_CD870 : Size := cSpaceMeterDiskSizes[Integer(SMDT_CD870)];
    SMDT_DVD   : Size := cSpaceMeterDiskSizes[Integer(SMDT_DVD)];
    SMDT_DVD_DL: Size := cSpaceMeterDiskSizes[Integer(SMDT_DVD_DL)];
    SMDT_BD    : Size := cSpaceMeterDiskSizes[Integer(SMDT_BD)];
    SMDT_BD_DL : Size := cSpaceMeterDiskSizes[Integer(SMDT_BD_DL)];
    SMDT_BD_TL : Size := cSpaceMeterDiskSizes[Integer(SMDT_BD_TL)];
    SMDT_BD_QL : Size := cSpaceMeterDiskSizes[Integer(SMDT_BD_QL)];
  else
    Size := Integer(SMDT_CD650);
  end;
  case FSpaceMeterMode of
    SMM_XCD    : Size := Round(Size * 1.13);     // XCDs have 13% more cpacity
    SMM_AudioCD: Size := Round(Size * 512 / 75); // Sizes in seconds
    SMM_NoDisk : Size := 100;                    // Dummy size
  end;
  SetDiskSizeMax(Size);
  SpaceMeterTypeChange;
  FPopUpMenu.Items[Integer(Value)].Checked := True;
end;

{ UpdateProgressBar ------------------------------------------------------------

  ProgressBar aktualisieren.                                                   }

procedure TSpaceMeter.UpdateProgressBar;
var Position: Extended;
begin
  Position := (FDiskSize / FDiskSizeMax) * 100;
  if Position > 100 then
  begin
    FProgressBar.StartColor := FColorWarnStart;
    FProgressBar.FinalColor := FColorWarnFinal;
  end else
  begin
    FProgressBar.StartColor := FColorOkStart;
    FProgressBar.FinalColor := FColorOkFinal;
  end;
  FProgressBar.Position := Round(Position);
end;

{ UpdateRemainingSpace ---------------------------------------------------------

  FRemainingSpaceString aktualisieren.                                         }

procedure TSpaceMeter.UpdateRemainingSpace;
var RemainingSpace: Int64;
begin
  RemainingSpace := FDiskSizeMax - FDiskSize;
  if RemainingSpace < 0 then RemainingSpace := 0;
  if FSpaceMeterMode in [SMM_DataCD, SMM_XCD] then
  begin
    FRemainingSpaceString := SizeToString(RemainingSpace * 1024 *1024);
  end else
  if FSpaceMeterMode = SMM_AudioCD then
  begin
    FRemainingSpaceString := FormatTime(RemainingSpace);
  end else
    FRemainingSpaceString := '';
end;
    
{ SpaceMeterResize -------------------------------------------------------------

  Wenn ein Resize-Event auftritt.                                              }

procedure TSpaceMeter.SpaceMeterResize;
begin
  FProgressBar.Width := Self.Width;
  FScale.Width := Self.Width  - 6;
end;

{ SpaceMeterTypeChange ---------------------------------------------------------

  löst das TypeChangeEvent aus.                                                }

procedure TSpaceMeter.SpaceMeterTypeChange;
begin
  if Assigned(FOnSpaceMeterTypeChange) then FOnSpaceMeterTypeChange;
end;

{ TSpaceMeter - public }

constructor TSpaceMeter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AutoInit;
end;

destructor TSpaceMeter.Destroy;
begin
  AutoDestroy;
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Init setzt den Parent, Position und Größe.                                   }

procedure TSpaceMeter.Init(CParent: TWinControl;
                           PTop, PLeft, SWidth, SHeight: Integer; SMAnchors: TAnchors);
begin
  {Panel}
  Parent := CParent;
  Top := PTop;
  Left := PLeft;
  Width := SWidth;
  Height := SHeight;
  Anchors := SMAnchors;
  {ProgressBar}
  FProgressBar.Width := SWidth;
  {Scale}
  FScale.Width := SWidth - 6;
end;


end.


