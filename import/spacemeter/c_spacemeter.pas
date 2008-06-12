{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  c_spacemeter.pas: Anzeigen des auf der Disk beanspruchten Speicherplatzes

  Copyright (c) 2008 Oliver Valencia

  letzte Änderung  10.06.2008

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

{$IFDEF Delphi6Up}
  {$DEFINE UseQProgBar}
{$ENDIF}

interface

uses Windows, Classes, Controls, ComCtrls, ExtCtrls, Graphics, Menus,
     {$IFDEF UseQProgBar}QProgBar,{$ENDIF} SysUtils;

const cDiskTypeCount = 5;    // zählt von 0 an! counts from 0!

      cSpaceMeterDiskSizes: array[0..cDiskTypeCount] of Integer =
                              (650, 700, 800, 870, 4482, 8147);

      cPopupMenuStrings: array[0..cDiskTypeCount] of string =
                           ('CD 650 MiB (74 min)',
                            'CD 700 MiB (80 min)',
                            'CD 800 MiB (90 min)',
                            'CD 870 MiB (99 min)',
                            'DVD 4.38 GiB',
                            'DVD/DL 7.96 GiB');

type TSpaceMeterDiskType = (SMDT_CD650, SMDT_CD700, SMDT_CD800, SMDT_CD870,
                            SMDT_DVD, SMDT_DVD_DL);

     TSpaceMeterMode = (SMM_DataCD, SMM_XCD, SMM_AudioCD, SMM_NoDisk);

     TSMTypeChangeEvent = procedure of object;

     TScale = class(TGraphicControl)
     private
       FCapacity      : Integer;
       FSpaceMeterMode: TSpaceMeterMode;
       FUnitMiB       : string;
       FUnitMin       : string;
     protected
       procedure Paint; override;
     public
       constructor Create(AOwner: TComponent); override;
     published
       property Capacity: Integer read FCapacity write FCapacity;
       property SpaceMeterMode: TSpaceMeterMode read FSpaceMeterMode write FSpaceMeterMode;
       property UnitMiB: string read FUnitMiB write FUnitMib;
       property UnitMin: string read FUnitMin write FUnitMin;
     end;

     TSpaceMeter = class(TPanel)
     private
       FSpaceMeterMode: TSpaceMeterMode;
       FDiskType      : TSpaceMeterDiskType;
       FDiskSizeMax   : Integer;
       FDiskSize      : Integer;
       FProgressBar   : {$IFDEF UseQProgBar}TQProgressBar{$ELSE}TProgressBar{$ENDIF};
       FScale         : TScale;
       FPopupMenu     : TPopupMenu;
       FOnSpaceMeterTypeChange: TSMTypeChangeEvent;
       procedure AutoDestroy;
       procedure AutoInit;
       procedure InitPopupMenu;
       procedure SetDiskSize(Value: Integer);
       procedure SetDiskSizeMax(Value: Integer);
       procedure SetDiskType(Value: TSpaceMeterDiskType);
       procedure SetSpaceMeterMode(Value: TSpaceMeterMode);
       procedure UpdateProgressBar;
       procedure SpaceMeterTypeChange;
       {interne Eventhandler}
       procedure SpaceMeterResize(Sender: TObject);
       procedure MenuItemClick(Sender: TObject);
       procedure PopupMenuPopup(Sender: TObject);
     protected
     public
       constructor Create(AOwner: TComponent); override;
       destructor Destroy; override;
       procedure Init(CParent: TWinControl; PTop, PLeft, SWidth, SHeight: Integer);
     published
       property DiskSize: Integer read FDiskSize write SetDiskSize;
       property DiskSizeMax: Integer read FDiskSizeMax write SetDiskSizeMax;
       property DiskType: TSpaceMeterDiskType read FDiskType write SetDiskType;
       property SpaceMeterMode: TSpaceMeterMode read FSpaceMeterMode write SetSpaceMeterMode;
       property OnSpaceMeterTypeChange: TSMTypeChangeEvent read FOnSpaceMeterTypeChange write FOnSpaceMeterTypeChange;
     end;

implementation

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
    i         : Integer;
    TickWidth : Double;
    Divisor   : Integer;
    OutText   : string;
begin
  Canvas.Font.Name := (Owner as TPanel).Font.Name;
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
  end else
  begin
    {Daten-CD/DVD:
     <1000 MiB: Teilstrich = 10 MiB; >= 1000 MiB: Teilstrich = 100MiB}
    Divisor := 10;
    if FCapacity > 1000 then Divisor := 100;
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
  Canvas.TextOut(0, Tick{10 + 1}, TickUnit);
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
        if FSpaceMeterMode = SMM_NoDisk then OutText := '';
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
  FUnitMib := 'MiB';
  FUnitMin := 'min';
  Self.ParentFont := False;
end;


{ TSpaceMeter ---------------------------------------------------------------- }

{ TSpaceMeter - private }

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
  FDiskSIze       := 0;
  FSpaceMeterMode := SMM_DataCD;
  {Panel}
  BevelInner := bvNone;
  BevelOuter := bvNone;
  Color      := clBtnFace;
  OnResize   := SpaceMeterResize;
  {ProgressBar}
  {$IFDEF UseQProgBar}
  FProgressBar := TQProgressBar.Create(Self);
  FProgressBar.Parent := Self;
  FProgressBar.Top := 0;
  FProgressBar.Left := 0;
  FProgressBar.Height := 11;
  FProgressBar.Width := Self.Width;
  FprogressBar.StartColor := RGB (0, 184, 0);   // $00004000;
  FProgressBar.FinalColor := RGB (255, 255, 0); // $0000FFFF;
  FProgressBar.ShowInactivePos := True;
  FProgressBar.InactivePosColor := RGB(240, 240, 240);
  FProgressBar.BarKind := bkCylinder;
  FProgressBar.BarLook := blMetal;
  FProgressBar.Maximum := 100;
  FProgressBar.Position := 0;
  {$ELSE}
  FProgressBar := TProgressBar.Create(Self);
  FProgressBar.Parent := Self;
  FProgressBar.Top := 0;
  FProgressBar.Left := 0;
  FProgressBar.Height := 11;
  FProgressBar.Width := Self.Width;
  FProgressBar.Min := 0;
  FProgressBar.Max := 100;
  FProgressBar.Position := 0;
  {$ENDIF}
  {Scale - TGraphicControl}
  FScale := TScale.Create(Self);
  FScale.Parent := Self;
  FScale.Top := 13;
  FScale.Left := 0 {$IFDEF UseQProgBar} + 3{$ENDIF};
  FScale.Width := Self.Width {$IFDEF UseQProgBar} - 6{$ENDIF};
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
  UpdateProgressBar;
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
  else
    Size := Integer(SMDT_CD650);
  end;
  case FSpaceMeterMode of
    SMM_XCD    : Size := Round(Size * 1.13);     // XCDs have 13% more cpacity
    SMM_AudioCD: Size := Round(Size * 512 / 75); // Sizes in seconds
    SMM_NoDisk : Size := 100;                    // Dummy size
  end;
  SetDiskSizeMax(Size);
  FPopupMenu.Items[Integer(Value)].Checked := True;
  SpaceMeterTypeChange;
end;

{ UpdateProgressBar ------------------------------------------------------------

  ProgressBar aktualisieren.                                                   }

procedure TSpaceMeter.UpdateProgressBar;
begin
  FProgressBar.Position := Round((FDiskSize / FDiskSizeMax) * 100);
end;

{ SpaceMeterResize -------------------------------------------------------------

  Wenn ein Resize-Event auftritt.                                              }

procedure TSpaceMeter.SpaceMeterResize;
begin
  FProgressBar.Width := Self.Width;
  FScale.Width := Self.Width {$IFDEF UseQProgBar} - 6{$ENDIF};
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
                           PTop, PLeft, SWidth, SHeight: Integer);
begin
  {Panel}
  Parent := CParent;
  Top := PTop;
  Left := PLeft;
  Width := SWidth;
  Height := SHeight;
  {ProgressBar}
  FProgressBar.Width := SWidth;
  {Scale}
  FScale.Width := SWidth {$IFDEF UseQProgBar} - 6{$ENDIF};
end;


end.

