{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  frm_maoutput.pas: Darstellung der Ausgabe der Konsolenprogramme wenn mehrere
                    Brenner gleichzeitig verwendet werden

  Copyright (c) 2012 Oliver Valencia

  letzte Änderung  17.05.2012

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

}

unit frm_maoutput;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  {eigene Klassendefinitionen/Units}
  cl_lang, cl_devices, cl_imagelists, c_frametopbanner;
  
type
  TFormMAOutput = class(TForm)
    FrameTopBanner1: TFrameTopBanner;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private-Deklarationen }
    FLang           : TLang;
    FDevices        : TDevices;
    FImageLists     : TImageLists;
    FSelectedDevices: TStringList;
  public
    { Public-Deklarationen }
    function SelectDevices: Boolean;
    property Lang      : TLang write FLang;
    property ImageLists: TImageLists write FImageLists;
    property Devices   : TDevices write FDevices;
  end;

implementation

uses f_window;

{$R *.dfm}

{ Form-Events ---------------------------------------------------------------- }

{ FormCreate -------------------------------------------------------------------

  Diese Prozedur wird beim Erzeugen des Fensters abgearbeitet. Hier werden not-
  wendige Initialisierungen vorgenommen.                                       }

procedure TFormMAOutput.FormCreate(Sender: TObject);
begin
  SetFont(Self);
  FSelectedDevices := TStringList.Create;
end;

{ FormDestroy ------------------------------------------------------------------

  Hier werden die in FormCreate erzeugten Objekte wieder freigegeben.          }

procedure TFormMAOutput.FormDestroy(Sender: TObject);
begin
  FSelectedDevices.Free;
end;

{ FormShow ---------------------------------------------------------------------

  Hier werden Dinge erledigt, die vor dem ersten Anzeigen des Fensters nötig
  sind, aber in FormCreate noch nicht ausgeführt werden können.                }

procedure TFormMAOutput.FormShow(Sender: TObject);
begin
  FLang.SetFormLang(self);
  {Banner}
  FrameTopBanner1.Init(Self.Caption, ''{FLang.GMS('desc01')}, 'grad1');
//  {falls vorhanden, alte Größe und Position wiederherstellen}
//  with FSettings.WinPos do
//  begin
//    if (OutWidth <> 0) and (OutHeight <> 0) then
//    begin
//      self.Top := OutTop;
//      self.Left := OutLeft;
//      self.Width := OutWidth;
//      self.Height := OutHeight;
//    end else
//    begin
//      {Falls keine Werte vorhanden, dann Fenster zentrieren. Die muß hier
//       manuell geschehen, da poScreenCenter zu Fehlern beim Setzen der
//       Eigenschaften führt. Deshalb muß poDefault verwendet werden.}
//      self.Top := (Screen.Height - self.Height) div 2;
//      self.Left := (Screen.Width - self.Width) div 2;
//    end;
//    if OutMaximized then self.WindowState := wsMaximized;
end;

{ TFormMAOutput - private }

{ TFormMAOutput - public }

{ SelectDevices ----------------------------------------------------------------

  SelectDevices ruft einen Dialog zur Auswahl der Brenner auf.                 }

function TFormMAOutput.SelectDevices: Boolean;
var FormSelectWriter: TFormSelectWriter;
begin
  FormSelectWriter := TFormSelectWriter.CreateNew(nil);
  try
    FormSelectWriter.Lang := FLang;
    FormSelectWriter.ImageLists := FImageLists;
    FormSelectWriter.CDWriter := FDevices.CDWriter;
    FormSelectWriter.Init;
    FormSelectWriter.ShowModal;
    FSelectedDevices.Text := FormSelectWriter.SelectedDevices;
  finally
    FormSelectWriter.Release;
  end;
  Result := FSelectedDevices.Count > 0;
end;

end.
