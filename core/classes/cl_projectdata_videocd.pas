{ $Id: cl_projectdata_videocd.pas,v 1.1 2010/05/18 17:01:59 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_projectdata_videocd.pas: Datentypen zur Speicherung der Pfadlisten

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  18.05.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_projectdata_videocd.pas implementiert das Objekt, in dem die zu dem Projekt
  (S)VideoCD hinzugefügten Dateien gespeichert werden.


  TVideoCD

    Properties   CDTime
                 LastError
                 TrackCount

    Methoden     AddTrack(const Name: string)
                 Create
                 CreateBurnList(List: TStringList)
                 DeleteAll
                 DeleteTrack(const Index: Integer)
                 GetFileList: TStringList
                 MoveTrack(const Index: Integer; const Direction: TDirection)

}

unit cl_projectdata_videocd;

{$I directives.inc}

interface

uses Classes, SysUtils, const_core;

type TVideoCD = class(TObject)
     private
       FCDSize: Int64;
       FCDSizeChanged: Boolean;
       FCDTime: Extended;
       FCDTimeChanged: Boolean;
       FError: Byte;
       FTrackCount: Integer;
       FTrackCountChanged: Boolean;
       FTrackList: TStringList;
       function ExtractFileSizeFromEntry(const Entry: string): Int64;
       function ExtractTimeFromEntry(const Entry: string): Extended;
       function GetLastError: Byte;
       function GetCDTime: Extended;
       function GetCDSize: Int64;
       function GetTrackCount: Integer;
     public
       constructor Create;
       destructor Destroy; override;
       function GetFileList: TStringList;
       procedure AddTrack(const Name: string);
       procedure CreateBurnList(List: TStringList);
       procedure DeleteAll;
       procedure DeleteTrack(const Index: Integer);
       procedure MoveTrack(const Index: Integer; const Direction: TDirection);
       property CDTime: Extended read GetCDTime;
       property CDSize: Int64 read GetCDSize;
       property LastError: Byte read GetLastError;
       property TrackCount: Integer read GetTrackCount;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     f_filesystem, f_strings, cl_mpegvinfo;

{ TVideoCD ------------------------------------------------------------------- }

{ TVideoCD - private }

{ GetLastError -----------------------------------------------------------------

  GetLastError gibt den Fehlercode aus FError und setzt FError auf No_Error.   }

function TVideoCD.GetLastError: Byte;
begin
  Result := FError;
  FError := CD_NoError;
end;

{ GetFileSize ------------------------------------------------------------------

  GetFileSize extrahiert aus dem Filelisten-Eintrag die Dateigröße.            }

function TVideoCD.ExtractFileSizeFromEntry(const Entry: string): Int64;
var Temp: string;
begin
  Temp := StringLeft(StringRight(Entry, '|'), '*');
  Result := StrToInt64Def(Temp, 0);
end;

{ GetCDTime --------------------------------------------------------------------

  GetCDTime gibt die Gesamtspielzeit zurück.                                   }

function TVideoCD.GetCDTime: Extended;
var Time: Extended;
    i: Integer;
begin
  if FCDTimeChanged then
  begin
    {$IFDEF DebugUpdateGauges}
    FormDebug.Memo3.Lines.Add('CDTime invalid');
    {$ENDIF}
    Time := 0;
    for i := 0 to FTrackList.Count - 1 do
    begin
      Time := Time + ExtractTimeFromEntry(FTrackList[i]);
    end;
    FCDTime := Time;
    Result := FCDTime;
    FCDTimeChanged := False;
  end else
  begin
    Result := FCDTime;
  end;
end;

{ GetCDSize --------------------------------------------------------------------

  GetCDSize liefert die Größe aller Datein in Bytes.                           }

function TVideoCD.GetCDSize: Int64;
var i: Integer;
begin
  if FCDSizeChanged then
  begin
    {$IFDEF DebugUpdateGauges}
    FormDebug.Memo3.Lines.Add('CDSize invalid');
    {$ENDIF}
    FCDSize := 0;
    for i := 0 to FTrackList.Count - 1 do
    begin
      FCDSize := FCDSize + ExtractFileSizeFromEntry(FTrackList[i]);
    end;
    Result := FCDSize;
    FCDSizeChanged := False;
  end else
  begin
    Result := FCDSize;
  end;
end;

{ GetTrackCount ----------------------------------------------------------------

  GetTrackCount gibt die Anzahl der Tracks zurück.                             }

function TVideoCD.GetTrackCount: Integer;
begin
  if FTrackCountChanged then
  begin
    {$IFDEF DebugUpdateGauges}
    FormDebug.Memo3.Lines.Add('TrackCount invalid');
    {$ENDIF}
    FTrackCount := FTrackList.Count;
    Result := FTrackCount;
    FTrackCountChanged := False;
  end else
  begin
    Result := FTrackCount;
  end;
end;

{ ExtractTimeFromEntry ---------------------------------------------------------

  ExtractTimeFromEntry gibt die Tracklänge in Sekunden zurück.                 }

function TVideoCD.ExtractTimeFromEntry(const Entry: string): Extended;
begin
  Result := StrToFloatDef(StringRight(Entry, '*'), 0);
end;

{ TVideoCD - public }

constructor TVideoCD.Create;
begin
  inherited Create;
  FTrackList := TStringList.Create;
  FError := CD_NoError;
  FTrackCount := 0;
  FTrackCountChanged := False;
  FCDTime := 0;
  FCDTimeChanged := False;
  FCDSize := 0;
  FCDSizeChanged := False;
end;

destructor TVideoCD.Destroy;
begin
  FTrackList.Free;
  inherited Destroy;
end;

{ AddTrack ---------------------------------------------------------------------

  AddTrack fügt die Audio-Datei Name in die TrackList ein.

  Pfadlisten-Eintrag: <Quellpfad>|<Größe in Bytes>*<Länge in Sekunden>         }

procedure TVideoCD.AddTrack(const Name: string);
var Size       : Int64;
    TrackLength: Extended;
    Temp       : string;
    MPEGFile   : TMPEGVideoFile;
begin
  if FileExists(Name) then
  begin
    if (Pos('.mpg', LowerCase(Name)) > 0) then
    begin
      if True {MpegIsValid(Name)} then
      begin
        MPEGFile := TMPEGVideoFile.Create(Name);
        MPEGFile.GetInfo;
        Size := GetFileSize(Name);
        TrackLength := MPEGFile.Length; //0;
        Temp := Name + '|' + FloatToStr(Size) + '*' +  FloatToStr(TrackLength);
        FTrackList.Add(Temp);
        FTrackCountChanged := True;
        FCDTimeChanged := True;
        FCDSizeChanged := True;
        MPEGFile.Free;
      end else
      begin
        FError := CD_InvalidMpegFile;
      end;
    end;
  end else
  begin
    FError := CD_FileNotFound;
  end;
end;

{ GetFileList ------------------------------------------------------------------

  GetFileList gibt eine Referenz auf die interne TrackListe zurück.            }

function TVideoCD.GetFileList: TStringList;
begin
  Result := FTrackList;
end;

{ MoveTrack --------------------------------------------------------------------

  MoveTrack verschiebt einen Video-Track um eine Position nach oben bzw. unten.}

procedure TVideoCD.MoveTrack(const Index: Integer; const Direction: TDirection);
begin
  if Direction = dUp then
  begin
    if Index > 0 then
    begin
      FTrackList.Exchange(Index, Index - 1);
    end;
  end else
  if Direction = dDown then
  begin
    if Index < FTrackList.Count - 1 then
    begin
      FTrackList.Exchange(Index, Index + 1);
    end;
  end;
end;

{ DeleteTrack ------------------------------------------------------------------

  DeleteTrack entfernt den (Index + 1)-ten Track aus der Liste.                }

procedure TVideoCD.DeleteTrack(const Index: Integer);
begin
  FTrackList.Delete(Index);          // Track löschen
  FTrackCountChanged := True;
  FCDTimeChanged := True;
  FCDSizeChanged := True;
end;

{ CreateBurnList ---------------------------------------------------------------

  CreateBurnList erzeugt die Pfadliste mit den zu schreibenden Tracks.         }

procedure TVideoCD.CreateBurnList(List: TStringList);
var i: Integer;
begin
  for i := 0 to FTrackList.Count - 1 do
  begin
    List.Add(StringLeft(FTrackList[i], '|'));
  end;
end;

{ DeleteAll --------------------------------------------------------------------

  Alle Datei- und Info-Listen löschen.                                         }

procedure TVideoCD.DeleteAll;
begin
  FTrackList.Clear;
  FTrackCount := 0;
  FCDTime := 0;
end;

end.
