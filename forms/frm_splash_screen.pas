{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  frm_splash_screen: Splash-Screen

  Copyright (c) 2008-2010 Oliver Valencia, Fabrice Tiercelin

  letzte �nderung  08.09.2010

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.

}

unit frm_splash_screen;

{$I directives.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, IniFiles, usermessages,
  {$IFDEF UseImagingLib}ImagingComponents;{$ELSE}jpeg;{$ENDIF}

type
  TFormSplashScreen = class(TForm)
    Image1: TImage;
    LabelVersion: TLabel;
    LabelPortable: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormHide(Sender: TObject);
  private
    { D�clarations priv�es }
    FShowSplash: Boolean;
    function GetIniFileName: string;
    function GetNoSplashIni: Boolean;
    procedure InitShowSplash;
    { Messagehandling }
    procedure WMSplashScreen(var Msg: TMessage); message WM_SplashScreen;
  public
    { D�clarations publiques }
    procedure ShowEx;
    procedure HideEx;
    procedure UpdateEx;
  end;

var
  FormSplashScreen: TFormSplashScreen;

implementation

{$R *.dfm}

uses f_filesystem, f_window, f_wininfo, f_locations, const_locations,
     f_commandline;

const SplashClientWidth  = 399;
      SplashClientHeight = 300;
      LabelTop           = 176;
      LabelLeft          = 278;
      LabelWidth         = 100;

{ Messagehandling ------------------------------------------------------------ }

procedure TFormSplashScreen.WMSplashScreen(var Msg: TMessage);
begin
  if Msg.WParam = wmwpSetPortable then
  begin
    LabelPortable.Caption := 'portable';
  end;
end;

{ Form-Events ---------------------------------------------------------------- }

{ FormCreate -------------------------------------------------------------------

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
  SetFont(Self);
  InitShowSplash;
end;

{ FormShow ---------------------------------------------------------------------

  Gr��e setzen.                                                                }

procedure TFormSplashScreen.FormShow(Sender: TObject);
begin
  FormSplashScreen.ClientWidth := SplashClientWidth;
  FormSplashScreen.ClientHeight := SplashClientHeight;
  LabelVersion.Top := LabelTop;
  LabelVersion.Left := LabelLeft;
  LabelVersion.Width := LabelWidth;
  LabelVersion.Transparent := True;
  LabelPortable.Transparent := True;
  LabelPortable.Left := (LabelVersion.Left + LabelVersion.Width) - LabelPortable.Width;
end;

{ FormClose --------------------------------------------------------------------

  Animation.                                                                   }

procedure TFormSplashScreen.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  AnimateWindow(Handle, 400, AW_HIDE or AW_BLEND);
end;

procedure TFormSplashScreen.FormHide(Sender: TObject);
begin
  AnimateWindow(Handle, 400, AW_HIDE or AW_BLEND);
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

  InitShowSplash pr�ft, ob der Splashscreen angezeigt werden soll oder nicht.  }

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
