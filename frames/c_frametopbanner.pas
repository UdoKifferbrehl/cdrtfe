{ c_frametopbanner: Komponente zur Darstellung eines Banners

  Copyright (c) 2009 Oliver Valencia

  letzte Änderung  09.08.2009

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  c_frametopbanner implementiert eine Komponente auf Basis einer TFrames, mit
  der eine Art Banner dargestellt werden kann.


  TFrameFileBrowser

    Properties       Caption
                     Description
                     BackgroundJPEGResourceName

    Methoden     x

}

unit c_frametopbanner;

interface

{$I directives.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,
  {$IFDEF UseImagingLib}ImagingComponents{$ELSE}jpeg{$ENDIF};

type
  TFrameTopBanner = class(TFrame)
    PanelTop: TPanel;
    Image2: TImage;
    LabelDescription: TLabel;
    LabelCaption: TLabel;
    Bevel1: TBevel;
  private
    { Private-Deklarationen }
    procedure SetLabelCaption(Value: string);
    procedure SetLabelDescription(Value: string);
    procedure SetBGJPEGResource(Value: string);
  public
    { Public-Deklarationen }
    property Caption: string write SetLabelCaption;
    property Description: string write SetLabelDescription;
    property BackgroundJPEGResourceName: string write SetBGJPEGResource;
  end;

implementation

{$R *.dfm}

procedure TFrameTopBanner.SetLabelCaption(Value: string);
begin
  LabelCaption.Caption := Value;
  LabelCaption.Font.Style := [fsBold];
end;

procedure TFrameTopBanner.SetLabelDescription(Value: string);
begin
  LabelDescription.Caption := Value;
end;

procedure TFrameTopBanner.SetBGJPEGResource(Value: string);
var TempStream : TResourceStream;
    JPEGImage  : {$IFDEF UseImagingLib}TImagingJpeg{$ELSE}TJPEGImage{$ENDIF};
begin
  TempStream := TResourceStream.Create(hInstance, Value, 'JPEG');
  JPEGImage := {$IFDEF UseImagingLib}TImagingJPEG.Create{$ELSE}
                                     TJPEGImage.Create{$ENDIF};
  try
    TempStream.Position := 0;
    JPEGImage.LoadFromStream(TempStream);
    Image2.Picture.Assign(JPEGImage);
  finally
    TempStream.Free;
    JPEGImage.Free;
  end;
end;

end.
