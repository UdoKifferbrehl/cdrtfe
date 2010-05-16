{ $Id: cl_settings_winpos.pas,v 1.1 2010/05/16 15:25:38 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_winpos.pas: Objekt für Fensterposition und -größe

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  15.05.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_winpos.pas implemtiert ein Objekt für die Fensterposition und -größe. Die
  Breite der Lsitview-Spalten wird ebenfalls gespeichert.


  TWinPos

    Properties   MainTop      : Integer
                 MainLeft     : Integer
                 MainHeight   : Integer
                 MainWidth    : Integer
                 MainMaximized: Boolean
                 OutTop       : Integer
                 OutLeft      : Integer
                 OutHeight    : Integer
                 OutWidth     : Integer
                 OutMaximized : Boolean
                 OutScrolled  : Boolean
                 LVColWidth   : TLVColWidthArray

    Methoden     Init
                 Load(MIF: TMemIniFile)
                 Save(MIF: TMemIniFile)

}

unit cl_settings_winpos;

interface

uses Classes, SysUtils, IniFiles, cl_abstractbase;

const cLVCount       = 5;  // Anzahl der ListViews, zählt von Null an!
      cLVMaxColCount = 3;  // Ánzahl (max.) der Spalten, zählt von Null an!

type TLVColWidthArray = array[0..cLVCount, 0..cLVMaxColCount] of Integer;

     TWinPos = class(TCdrtfeSettings)
     private
       FMainTop      : Integer;
       FMainLeft     : Integer;
       FMainHeight   : Integer;
       FMainWidth    : Integer;
       FMainMaximized: Boolean;
       FOutTop       : Integer;
       FOutLeft      : Integer;
       FOutHeight    : Integer;
       FOutWidth     : Integer;
       FOutMaximized : Boolean;
       FOutScrolled  : Boolean;
       FLVColWidth   : TLVColWidthArray;
       function GetFLVColWidth(LV, Col: Integer): Integer;
       procedure SetFLVColWidth(LV, Col: Integer; const Value: Integer);
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       procedure Load(MIF: TMemIniFile); override;
       procedure Save(MIF: TMemIniFile); override;
       property MainTop      : Integer read FMainTop write FMainTop;
       property MainLeft     : Integer read FMainLeft write FMainLeft;
       property MainHeight   : Integer read FMainHeight write FMainHeight;
       property MainWidth    : Integer read FMainWidth write FMainWidth;
       property MainMaximized: Boolean read FMainMaximized write FMainMaximized;
       property OutTop       : Integer read FOutTop write FOutTop;
       property OutLeft      : Integer read FOutLeft write FOutLeft;
       property OutHeight    : Integer read FOutHeight write FOutHeight;
       property OutWidth     : Integer read FOutWidth write FOutWidth;
       property OutMaximized : Boolean read FOutMaximized write FoutMaximized;
       property OutScrolled  : Boolean read FOutScrolled write FOutScrolled;
       property LVColWidth[LV, Col: Integer]: Integer read GetFLVColWidth write SetFLVColWidth;
     end;

implementation

{ TWinPos -------------------------------------------------------------------- }

{ TWinPos - private }

{ GetGetFLVColWidth / SetGetFLVColWidth ----------------------------------------

  Getter- und Setter-Methoden für die Array-Propertier.                        }

function TWinPos.GetFLVColWidth(LV, Col: Integer): Integer;
begin
  Result := FLVColWidth[LV, Col];
end;

procedure TWinPos.SetFLVColWidth(LV, Col: Integer; const Value: Integer);
begin
  FLVColWidth[LV, Col] := Value;
end;

{ TWinPos - public }

constructor TWinPos.Create;
begin
  inherited Create;
  Init;
end;

destructor TWinPos.Destroy;
begin
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TWinPos.Init;
var i, j: Integer;
begin
  FMainTop       := 0;
  FMainLeft      := 0;
  FMainHeight    := 0;
  FMainWidth     := 0;
  FMainMaximized := False;
  FOutTop        := 0;
  FOutLeft       := 0;
  FOutHeight     := 0;
  FOutWidth      := 0;
  FOutMaximized  := False;
  FOutScrolled   := True;
  for i := 0 to cLVCount do
    for j := 0 to cLVMaxColCount  do
      FLVColWidth[i, j] := -1;
end;

{ Load -------------------------------------------------------------------------

  Variablen aus der Ini- bzw. cfp-Datei laden.                                 }

procedure TWinPos.Load(MIF: TMemIniFile);
var Section : string;
    TempList: TStringList;
    i, j    : Integer;
begin
  if FAsInifile then
  begin
    TempList := TSTringList.Create;
    Section := 'WinPos';
    with MIF do
    begin
      FMainTop := ReadInteger(Section, 'MainTop', 0);
      FMainLeft := ReadInteger(Section, 'MainLeft', 0);
      FMainWidth := ReadInteger(Section, 'MainWidth', 0);
      FMainHeight := ReadInteger(Section, 'MainHeight', 0);
      FMainMaximized := ReadBool(Section, 'MainMaximized', False);
      FOutTop := ReadInteger(Section, 'OutTop', 0);
      FOutLeft := ReadInteger(Section, 'OutLeft', 0);
      FOutWidth := ReadInteger(Section, 'OutWidth', 0);
      FOutHeight := ReadInteger(Section, 'OutHeight', 0);
      FOutMaximized := ReadBool(Section, 'OutMaximized', False);
      FOutScrolled := ReadBool(Section, 'OutScrolled', True);
      for i := 0 to cLVCount do
      begin
        TempList.Clear;
        TempList.CommaText := ReadString(Section, 'LVCols' + IntToStr(i), '');
        for j := 0 to TempList.Count - 1 do
          FLVColWidth[i, j] := StrToIntDef(TempList[j], -1);
      end;
    end;
    TempList.Free;
    FAsIniFile := False;
  end;
end;

{ Save -------------------------------------------------------------------------

  Variablen in einer Ini- bzw. cfp-Datei speichern.                            }

procedure TWinPos.Save(MIF: TMemIniFile);
var Section : string;
    TempList: TStringList;
    i, j    : Integer;
begin
  if FAsInifile then
  begin
    TempList := TStringList.Create;
    Section := 'WinPos';
    with MIF do
    begin
      WriteInteger(Section, 'MainTop', FMainTop);
      WriteInteger(Section, 'MainLeft', FMainLeft);
      WriteInteger(Section, 'MainWidth', FMainWidth);
      WriteInteger(Section, 'MainHeight', FMainHeight);
      WriteBool(Section, 'MainMaximized', FMainMaximized);
      WriteInteger(Section, 'OutTop', FOutTop);
      WriteInteger(Section, 'OutLeft', FOutLeft);
      WriteInteger(Section, 'OutWidth', FOutWidth);
      WriteInteger(Section, 'OutHeight', FOutHeight);
      WriteBool(Section, 'OutMaximized', FOutMaximized);
      WriteBool(Section, 'OutScrolled', FOutScrolled);
      for i := 0 to cLVCount do
      begin
        TempList.Clear;
        for j := 0 to cLVMaxColCount do
          TempList.Add(IntToStr(FLVColWidth[i, j]));
        WriteString(Section, 'LVCols' + IntToStr(i), TempList.CommaText);
      end;
    end;
    TempList.Free;
    FAsInifile := False;
  end;
end;

end.

