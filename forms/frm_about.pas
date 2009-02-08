{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  frm_about.pas: About-Dialog

  Copyright (c) 2004-2009 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  08.02.2009

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

}

unit frm_about;

{$I directives.inc}

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
     StdCtrls, ExtCtrls, ShellAPI, ComCtrls,
     {$IFDEF UseImagingLib}ImagingComponents,{$ELSE}jpeg,{$ENDIF}
     cl_lang;

type
  TFormAbout = class(TForm)
    Button1: TButton;
    Image1: TImage;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    Label1: TLabel;
    Label2: TLabel;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    RichEdit1: TRichEdit;
    StaticText6: TStaticText;
    ButtonSwitch: TButton;
    StaticText7: TStaticText;
    procedure FormCreate(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButtonSwitchClick(Sender: TObject);
  private
    { Private declarations }
    FLang: TLang;
  public
    { Public declarations }
    property Lang: TLang read Flang write FLang;
  end;

{ var }

implementation

{$R *.DFM}

{$R ../resource/license_ex.res}

{$IFNDEF ExceptionDlg}
  {$R ../resource/credits.res}
{$ELSE}
  {$R ../resource/credits_ex.res}
{$ENDIF}

uses constant, f_misc, f_filesystem;

const Cdrtfe_Version     = 'cdrtfe 1.3.4'
                           {$IFDEF TestVersion} + '-test' {$ENDIF};
      Cdrtfe_Description = 'cdrtools/Mode2CDMaker/VCDImager Frontend';
      Cdrtfe_Copyright   = 'Copyright © 2004-2009  O. Valencia';
      Cdrtfe_Copyright2  = 'Copyright © 2002-2004  O. Valencia, O. Kutsche';
      Cdrtfe_Homepage    = 'http://cdrtfe.sourceforge.net';
      Cdrtfe_eMail       = 'kerberos002@arcor.de';
      {$IFDEF TestVersion}
      Cdrtfe_HintTest    = 'Achtung/Attention!' + CRLF + CRLF +
                           'Dies ist eine Testversion, die noch schwere ' +
                           'Fehler enthalten könnte.' + CRLF + CRLF +
                           'This is a test version which still may have ' +
                           'severe bugs.' + CRLF + CRLF;
      {$ENDIF}

procedure TFormAbout.FormCreate(Sender: TObject);
var TempStream : TResourceStream;
    JPEGImage  : {$IFDEF UseImagingLib}TImagingJpeg{$ELSE}TJPEGImage{$ENDIF};
begin
  SetFont(Self);
  StaticText1.Caption := Cdrtfe_Version;
  StaticText2.Caption := Cdrtfe_Description;
  StaticText3.Caption := Cdrtfe_Copyright;
  StaticText6.Caption := Cdrtfe_Copyright2;
  StaticText7.Caption := '(' + GetFileVersionString(Application.ExeName) + ')';
  StaticText7.Left := StaticText1.Left + StaticText1.Width + 10;
  Label1.Caption      := Cdrtfe_Homepage;
  Label2.Caption      := Cdrtfe_eMail;

  Label1.Font.Color:=clBlue;
  Label1.Font.Style:=[fsUnderline];
  Label1.Cursor:=crHandPoint;

  Label2.Font.Color:=clBlue;
  Label2.Font.Style:=[fsUnderline];
  Label2.Cursor:=crHandPoint;

  TempStream := TResourceStream.Create(hInstance, 'License', RT_RCDATA);

  try
    TempStream.Position := 0;
    RichEdit1.Lines.LoadFromStream(TempStream);
  finally
    TempStream.Free;
  end;

  TempStream := TResourceStream.Create(hInstance, 'logo2', 'JPEG');
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

  {$IFDEF TestVersion}
  RichEdit1.Lines.Insert(0, Cdrtfe_HintTest);
  {$ENDIF}

end;

procedure TFormAbout.Label1Click(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open',
               PCHar(Label1.Caption), nil, nil,
               SW_ShowNormal);
end;

procedure TFormAbout.Label2Click(Sender: TObject);
begin
  ShellExecute(Application.Handle,
               'open',
               PChar('mailto:' + Label2.Caption + '?subject=[cdrtfe]'),
               nil, nil,
               SW_SHOWNORMAL);
end;

procedure TFormAbout.FormShow(Sender: TObject);
begin
  FLang.SetFormLang(self);
end;

procedure TFormAbout.ButtonSwitchClick(Sender: TObject);
const {$J+} ShowCredits: Boolean = True; {$J-}
var TempStream : TResourceStream;
    Section    : string;
begin
  if ShowCredits then Section := 'Credits' else Section := 'License';
  TempStream := TResourceStream.Create(hInstance, Section, RT_RCDATA);
  try
    TempStream.Position := 0;
    RichEdit1.Lines.LoadFromStream(TempStream);
  finally
    TempStream.Free;
  end;
  ShowCredits := not ShowCredits;
end;

initialization

end.
