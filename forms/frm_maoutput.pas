{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  frm_maoutput.pas: Darstellung der Ausgabe der Konsolenprogramme wenn mehrere
                    Brenner gleichzeitig verwendet werden

  Copyright (c) 2012 Oliver Valencia

  letzte Änderung  19.05.2012

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
  cl_lang, cl_devices, cl_imagelists, c_frametopbanner, StdCtrls, ComCtrls;
  
type
  TFormMAOutput = class(TForm)
    FrameTopBanner1: TFrameTopBanner;
    Memo1: TMemo;
    Button1: TButton;
    PageControl: TPageControl;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
    FLang           : TLang;
    FDevices        : TDevices;
    FImageLists     : TImageLists;
    FSelectedDevices: TStringList;
    FSelDevCount    : Integer;
    procedure CreateControls;
  public
    { Public-Deklarationen }
    procedure StartActionShowModal;
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
  SetFont(Self);
  FLang.SetFormLang(Self);
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

{ Button-Events -------------------------------------------------------------- }

procedure TFormMAOutput.Button1Click(Sender: TObject);
begin
  Memo1.Lines.Add('test');
  Memo1.Lines.Add('Tab2Owner: ' +  PageControl.Pages[0].Owner.Name);
  Memo1.Lines.Add('Tab2.Parent: ' + PageControl.Pages[0].Parent.Name);
end;

{ TFormMAOutput - private }

{ CreateControls ---------------------------------------------------------------

  CreateControls erzeugt in Abhängigkeit der Anzahl der ausgewählten Laufwerke
  Controls zur Anzeige der Ausgabe.                                            }

procedure TFormMAOutput.CreateControls;
var i       : Integer;
    TabSheet: TTabSheet;
    Memo    : TMemo;
    DevLabel: TLabel;
begin
  for i := 0 to FSelDevCount - 1 do
  begin
    {TabSheet}
    TabSheet := TTabSheet.Create(Self);
    TabSheet.Parent := PageControl;
    TabSheet.PageControl := PageControl;
    TabSheet.Caption := FLang.GMS('c003') + ' ' + IntToStr(i);
    {Label}
    DevLabel := TLabel.Create(Self);
    DevLabel.Parent := TabSheet;
    DevLabel.Top := 4;
    DevLabel.Left := 4;
    DevLabel.Caption := FLang.GMS('c003') + ' ' +
                          FDevices.GetDriveLetter(FSelectedDevices[i]) +
                          ' (' + FSelectedDevices[i] + ')';
    {Memo}
    Memo := TMemo.Create(Self);
    Memo.Parent := TabSheet;
    Memo.Top := DevLabel.Top + DevLabel.Height + 4;
    Memo.Left := 4;
    Memo.Width := TabSheet.ClientWidth - 8;
    Memo.Height := TabSheet.ClientHeight - 8;
    Memo.ScrollBars := ssBoth;
  end;
end;

{ TFormMAOutput - public }

{ StartActionShowModal ---------------------------------------------------------

  startet den Brennvorgang und zeigt das Ausgabefenster an.                    }

procedure TFormMAOutput.StartActionShowModal;
begin
  CreateControls;
  Self.ShowModal;
end;

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
  FSelDevCount := FSelectedDevices.Count;
  Result := FSelDevCount > 0;
end;

end.
