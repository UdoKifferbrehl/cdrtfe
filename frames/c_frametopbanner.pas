{ $Id: c_frametopbanner.pas,v 1.3 2010/01/11 06:37:38 kerberos002 Exp $

  c_frametopbanner: Komponente zur Darstellung eines Banners

  Copyright (c) 2009 Oliver Valencia

  letzte �nderung  10.08.2009

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.

  c_frametopbanner implementiert eine Komponente auf Basis einer TFrames, mit
  der eine Art Banner dargestellt werden kann.


  TFrameFileBrowser

    Properties   Caption
                 Description
                 BackgroundJPEGResourceName

    Methoden     Init(const Cap, Desc, BGJPEGRN: string)

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
    procedure Init(const Cap, Desc, BGJPEGRN: string);
    property Caption: string write SetLabelCaption;
    property Description: string write SetLabelDescription;
    property BackgroundJPEGResourceName: string write SetBGJPEGResource;
  end;

implementation

{$R *.dfm}

{ TFrameTopBanner ------------------------------------------------------------ }

{ TFrameTopBanner - private }

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

{ TFrameTopBanner - public }

procedure TFrameTopBanner.Init(const Cap: string; const Desc: string; const BGJPEGRN: string);
begin
  Caption := Cap;
  Description := Desc;
  BackgroundJPEGResourceName := BGJPEGRN;
end;

end.
