{ $Id: f_compprop.pas,v 1.3 2010/11/27 20:35:03 kerberos002 Exp $

  f_compprop.pas: Properties von Komponenten

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  27.11.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  f_compprop.pas stellt Hilfs-Funktionen zur Verfügung:
    * Umgang mit Komponenten


  exportierte Funktionen/Prozeduren:
    ExportControls
    ExportFontList
    GetCompProp(Comp: TComponent; Name: string): string
    function GetPopupComp(Sender: TObject): TComponent
    PropertyExists(Comp: TComponent; Name: string): Boolean
    SetCompProp(Comp: TComponent; const Name, Value: string)

}

unit f_compprop;

{$I directives.inc}

interface

uses Classes, Forms, Controls, ComCtrls, StdCtrls, ExtCtrls, Buttons, Menus,
     SysUtils, TypInfo;

function GetCompProp(Comp: TComponent; Name: string): string;
function GetPopupComp(Sender: TObject): TComponent;
function PropertyExists(Comp: TComponent; Name: string): Boolean;
procedure ExportControls;
procedure ExportFontList;
procedure SetCompProp(Comp: TComponent; const Name, Value: string);
procedure SetDoubleBuffered(const Value: Boolean);

implementation

uses f_locations;

{ GetPopupComp -----------------------------------------------------------------

  ermittelt, zu welcher Komponente das Popup-Menü gehört, dessen Menuitem
  als Sender übergeben wurde.                                                  }

function GetPopupComp(Sender: TObject): TComponent;
begin
  if Sender is TMenuItem then
  begin
    Result :=
      ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent;
  end else
    Result := nil;
end;

{ Hilfsprozeduren zum Setzen/Lesen der Properties----------------------------- }

{ GetCompProp ------------------------------------------------------------------

  GetCompProp gibt den Wert von Comp.Name zurück, falls Property 'Name' vor-
  handen ist. Ist nur auf String-Properties anwendbar.                         }

function GetCompProp(Comp: TComponent; Name: string): string;
var PropInf: PPropInfo;
begin
  PropInf := GetPropInfo(Comp.ClassInfo, Name);
  if Assigned(PropInf) then
  begin
    Result := GetStrProp(Comp, PropInf);
  end else
  begin
    Result := '';
  end;
end;

{ SetCompProp ------------------------------------------------------------------

  SetCompProp setzt Comp.Name := Value. Nur für Strings.                       }

procedure SetCompProp(Comp: TComponent; const Name, Value: string);
var PropInf: PPropInfo;
begin
  if Value <> '' then
  begin
    PropInf := GetPropInfo(Comp.ClassInfo, Name);
    if Assigned(PropInf) then
    begin
      SetStrProp(Comp, PropInf, Value);
    end;
  end;
end;

{ PropertyExists ---------------------------------------------------------------

  PropertyExist liefert True, wenn Comp.Name existiert, sonst False.           }

function PropertyExists(Comp: TComponent; Name: string): Boolean;
begin
  Result := (Comp.Name <> '') and (GetPropInfo(Comp.ClassInfo, Name) <> nil);
end;

{ ExportControls ---------------------------------------------------------------

  ExportControls schreibt die Position und Größe alle Controls in eine Datei.  }

procedure ExportControls;
var i: Integer;
    List: TStringList;

  procedure ExportControlsRek(Comp: TComponent);
  var i: Integer;
  begin
    if Comp.Name <> '' then
    begin
      List.Add(Comp.Name +
               '.Top := ' + IntToStr((Comp as TControl).Top) + ';');
      List.Add(Comp.Name +
               '.Left := ' + IntToStr((Comp as TControl).Left) + ';');
      List.Add(Comp.Name +
               '.Width := ' + IntToStr((Comp as TControl).Width) + ';');
      List.Add(Comp.Name +
               '.Height := ' + IntToStr((Comp as TControl).Height) + ';');
    end;
    if Comp.ComponentCount > 0 then
    begin
      for i := 0 to Comp.ComponentCount - 1 do
      begin
        ExportControlsRek(Comp.Components[i]);
      end;
    end;
  end;

begin
  List := TStringList.Create;
  for i:= 0 to Application.ComponentCount - 1 do
  begin
    if Application.Components[i] is TForm then
    begin
      ExportControlsRek(Application.Components[i]);
      List.Add('');
    end;
  end;
  List.SaveToFile(StartUpDir + '\controls.txt');
  List.Free;
end;

{ ExportFontList ---------------------------------------------------------------

  ExportFontList schreibt eine List der verwendeten Schriftarten in eine Datei.}

procedure ExportFontList;
var i: Integer;
    List: TStringList;

  procedure ExportFontsRek(Comp: TComponent);
  var i: Integer;
      s: string;
  begin
    if (Comp.Name <> '') and PropertyExists(Comp, 'Font') then
    begin
      if Comp is TMemo        then s := (Comp as TMemo).Font.Name else
      if Comp is TLabel       then s := (Comp as TLabel).Font.Name else
      if Comp is TForm        then s := (Comp as TForm).Font.Name else
      if Comp is TGroupBox    then s := (Comp as TGroupBox).Font.Name else
      if Comp is TButton      then s := (Comp as TButton).Font.Name else
      if Comp is TRadioButton then s := (Comp as TRadioButton).Font.Name else
      if Comp is TCheckBox    then s := (Comp as TCheckBox).Font.Name else
      if Comp is TComboBox    then s := (Comp as TComboBox).Font.Name else
      if Comp is TEdit        then s := (Comp as TEdit).Font.Name else
      if Comp is TTabSheet    then s := (Comp as TTabSheet).Font.Name else
      if Comp is TPanel       then s := (Comp as TPanel).Font.Name else
      if Comp is TPageControl then s := (Comp as TPageControl).Font.Name else
      if Comp is TTreeView    then s := (Comp as TTreeView).Font.Name else
      if Comp is TListView    then s := (Comp as TListView).Font.Name else
      if Comp is TStatusBar   then s := (Comp as TStatusBar).Font.Name else
      if Comp is TStaticText  then s := (Comp as TStaticText).Font.Name else
      if Comp is TSpeedButton then s := (Comp as TSpeedButton).Font.Name;
      List.Add(s + ' <- ' + Comp.Name);
    end;
    if Comp.ComponentCount > 0 then
    begin
      for i := 0 to Comp.ComponentCount - 1 do
      begin
        ExportFontsRek(Comp.Components[i]);
      end;
    end;
  end;

begin
  List := TStringList.Create;
  for i:= 0 to Application.ComponentCount - 1 do
  begin
    if Application.Components[i] is TForm then
    begin
      ExportFontsRek(Application.Components[i]);
      List.Add('');
    end;
  end;
  List.SaveToFile(StartUpDir + '\fonts.txt');
  List.Free;
end;

{ SetDoubleBuffered ------------------------------------------------------------

  setzt DoubleBuffered für alle Componenten auf Value.                         }

procedure SetDoubleBuffered(const Value: Boolean);
var i: Integer;

  procedure SetDoubleBufferedRek(Comp: TComponent; const Value: Boolean);
  var i: Integer;
  begin
    if (Comp.Name <> '') {and PropertyExists(Comp, 'DoubleBuffered')} then
    begin
      if Comp is TMemo        then (Comp as TMemo).DoubleBuffered := Value else
      if Comp is TForm        then (Comp as TForm).DoubleBuffered := Value else
      if Comp is TGroupBox    then (Comp as TGroupBox).DoubleBuffered := Value else
      if Comp is TButton      then (Comp as TButton).DoubleBuffered := Value else
      if Comp is TRadioButton then (Comp as TRadioButton).DoubleBuffered := Value else
      if Comp is TCheckBox    then (Comp as TCheckBox).DoubleBuffered := Value else
      if Comp is TComboBox    then (Comp as TComboBox).DoubleBuffered := Value else
      if Comp is TEdit        then (Comp as TEdit).DoubleBuffered := Value else
      if Comp is TTabSheet    then (Comp as TTabSheet).DoubleBuffered := Value else
      if Comp is TPanel       then (Comp as TPanel).DoubleBuffered := Value else
      if Comp is TPageControl then (Comp as TPageControl).DoubleBuffered := Value else
      if Comp is TTreeView    then (Comp as TTreeView).DoubleBuffered := Value else
      if Comp is TListView    then (Comp as TListView).DoubleBuffered := Value else
      if Comp is TStatusBar   then (Comp as TStatusBar).DoubleBuffered := Value else
      if Comp is TStaticText  then (Comp as TStaticText).DoubleBuffered := Value;
    end;
    if Comp.ComponentCount > 0 then
    begin
      for i := 0 to Comp.ComponentCount - 1 do
      begin
        SetDoubleBufferedRek(Comp.Components[i], Value);
      end;
    end;
  end;

begin
  for i:= 0 to Application.ComponentCount - 1 do
  begin
    //if Application.Components[i] is TForm then
    begin
      SetDoubleBufferedRek(Application.Components[i], Value);
    end;
  end;
end;

end.
