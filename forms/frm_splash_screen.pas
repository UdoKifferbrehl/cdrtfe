{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  frm_splash_screen: Splash-Screen

  Copyright (c) 2008      Oliver Valencia, Fabrice Tiercelin

  letzte Änderung  22.06.2008

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

}

unit frm_splash_screen;

{$I directives.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,
  {$IFDEF UseImagingLib}ImagingComponents;{$ELSE}jpeg;{$ENDIF}

type
  TFormSplashScreen = class(TForm)
    Image1: TImage;
    LabelVersion: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  FormSplashScreen: TFormSplashScreen;

implementation

{$R *.dfm}

uses f_filesystem;

const SplashClientWidth  = 399;
      SplashClientHeight = 300;
      LabelTop           = 176;
      LabelLeft          = 278;
      LabelWidth         = 100;

procedure TFormSplashScreen.FormCreate(Sender: TObject);
var TempStream : TResourceStream;
    JPEGImage  : {$IFDEF UseImagingLib}TImagingJpeg{$ELSE}TJPEGImage{$ENDIF};
begin
  TempStream := TResourceStream.Create(hInstance, 'logo1', 'JPEG');
  JPEGImage := {$IFDEF UseImagingLib}TImagingJPEG.Create{$ELSE}
                                     TJPEGImage.Create{$ENDIF};
  try
    TempStream.Position := 0;
    JPEGImage.LoadFromStream(TempStream);
    Image1.Picture.Assign(JPEGImage);
  finally
    TempStream.Free;
    JPEGImage.Free;
  end;

  LabelVersion.Caption := GetFileVersionString(Application.ExeName);
end;

procedure TFormSplashScreen.FormShow(Sender: TObject);
begin
  FormSplashScreen.ClientWidth := SplashClientWidth;
  FormSplashScreen.ClientHeight := SplashClientHeight;
  LabelVersion.Top := LabelTop;
  LabelVersion.Left := LabelLeft;
  LabelVersion.Width := LabelWidth;
  LabelVersion.Transparent := True;
end;

end.
