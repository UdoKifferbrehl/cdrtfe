{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  frm_splash_screen: Splash-Screen

  Copyright (c) 2008      Oliver Valencia, Fabrice Tiercelin

  letzte Änderung  12.09.2008

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

}

unit frm_splash_screen;

{$I directives.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, IniFiles,
  {$IFDEF UseImagingLib}ImagingComponents;{$ELSE}jpeg;{$ENDIF}

type
  TFormSplashScreen = class(TForm)
    Image1: TImage;
    LabelVersion: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Déclarations privées }
    FShowSplash: Boolean;
    function GetIniFileName: string;
    function GetNoSplashIni: Boolean;
    procedure InitShowSplash;
  public
    { Déclarations publiques }
    procedure ShowEx;
    procedure HideEx;
    procedure UpdateEx;
  end;

var
  FormSplashScreen: TFormSplashScreen;

implementation

{$R *.dfm}

uses f_filesystem, f_misc, f_wininfo, constant;

const SplashClientWidth  = 399;
      SplashClientHeight = 300;
      LabelTop           = 176;
      LabelLeft          = 278;
      LabelWidth         = 100;

{ Form-Events ---------------------------------------------------------------- }

{ FormCreateOnClick ------------------------------------------------------------

  Splashscreen initialisieren, Bild laden.                                     }

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
  InitShowSplash;
end;

{ FormShow ---------------------------------------------------------------------

  Größe setzen.                                                                }

procedure TFormSplashScreen.FormShow(Sender: TObject);
begin
  FormSplashScreen.ClientWidth := SplashClientWidth;
  FormSplashScreen.ClientHeight := SplashClientHeight;
  LabelVersion.Top := LabelTop;
  LabelVersion.Left := LabelLeft;
  LabelVersion.Width := LabelWidth;
  LabelVersion.Transparent := True;
end;

{ TFormSplashScreen - private }

{ GetIniFileName ---------------------------------------------------------------

  GetIniFileName liefert den Namen der Ini-Datei.                              }

function TFormSplashScreen.GetIniFileName;
var Temp: string;
    Name: string;
begin
  Name := cDataDir + cIniFile;
  if PlatformWinNT then
  begin
    Temp := GetShellFolder(CSIDL_LOCAL_APPDATA) + Name;
    if not FileExists(Temp) then
    begin
      Temp := GetShellFolder(CSIDL_APPDATA) + Name;
      if not FileExists(Temp) then
      begin
        Temp := GetShellFolder(CSIDL_COMMON_APPDATA) + Name;
        if not FileExists(Temp) then
        begin
          Temp := StartUpDir + cIniFile;
          if not FileExists(Temp) then
          begin
            Temp := '';
          end;
        end;
      end;
    end;
    {Sonderbehanldung, wenn cdrtfe im Portable-Mode ist}
    if CheckCommandLineSwitch('/portable') then
    begin
      Temp := StartUpDir + cIniFile;
      if not FileExists(Temp) then
      begin
        Temp := '';
      end;
    end;
    Result := Temp;
  end else
  begin
    Temp := StartUpDir + cIniFile;
    if not FileExists(Temp) then
    begin
      Temp := '';
    end;
    Result := Temp;
  end;
end;

{ GetNoSplashIni ---------------------------------------------------------------

  NoSplashIni liest NoSplahs aus cdrtfe.ini aus.                               }

function TFormSplashScreen.GetNoSplashIni: Boolean;
var Name: string;
    Ini : TIniFile;
begin
  Result := False;
  Name := GetIniFileName;
  if Name <> '' then
  begin
    Ini := TIniFile.Create(Name);
    Result := Ini.ReadBool('General', 'NoSplash', False);
    Ini.Free;
  end;
end;

{ InitShowSplash ---------------------------------------------------------------

  InitShowSplash prüft, ob der Splashscreen angezeigt werden soll oder nicht.  }

procedure TFormSplashScreen.InitShowSplash;
var NoSplash   : Boolean;
    NoSplashIni: Boolean;
begin
  NoSplash := CheckCommandLineSwitch('/nosplash');
  NoSplashIni := GetNoSplashIni;
  FShowSplash := not (NoSplash or NoSplashIni);
end;

{ TFormSplashScreen - public }

procedure TFormSplashScreen.ShowEx;
begin
  if FShowSplash then Show;
end;

procedure TFormSplashScreen.HideEx;
begin
  if FShowSplash then Hide;
end;

procedure TFormSplashScreen.UpdateEx;
begin
  if FShowSplash then Update;
end;

end.
