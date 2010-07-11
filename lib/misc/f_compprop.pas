{ $Id: f_compprop.pas,v 1.2 2010/07/11 16:37:31 kerberos002 Exp $

  f_compprop.pas: Properties von Komponenten

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte �nderung  11.07.2010

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.

  f_compprop.pas stellt Hilfs-Funktionen zur Verf�gung:
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

implementation

uses f_locations;

{ GetPopupComp -----------------------------------------------------------------

  ermittelt, zu welcher Komponente das Popup-Men� geh�rt, dessen Menuitem
  als Sender �bergeben wurde.                                                  }

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

  GetCompProp gibt den Wert von Comp.Name zur�ck, falls Property 'Name' vor-
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

  SetCompProp setzt Comp.Name := Value. Nur f�r Strings.                       }

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

  ExportControls schreibt die Position und Gr��e alle Controls in eine Datei.  }

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

end.
