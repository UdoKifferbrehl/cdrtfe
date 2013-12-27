{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  frm_about.pas: About-Dialog

  Copyright (c) 2004-2013 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  27.12.2013

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
     cl_lang, c_frametopbanner;

type
  TFormAbout = class(TForm)
    Button1: TButton;
    PageControl: TPageControl;
    TabSheetInfo: TTabSheet;
    TabSheetLicense: TTabSheet;
    TabSheetCredits: TTabSheet;
    StaticTextVersion: TStaticText;
    StaticText3: TStaticText;
    StaticText6: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    Image1: TImage;
    StaticText7: TStaticText;
    Label1: TLabel;
    Label2: TLabel;
    RichEdit1: TRichEdit;
    RichEdit2: TRichEdit;
    LabelHintTest: TLabel;
    FrameTopBanner1: TFrameTopBanner;
    procedure FormCreate(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FLang    : TLang;
    FPortable: Boolean;
  public
    { Public declarations }
    property Lang: TLang read FLang write FLang;
    property Portable: Boolean read FPortable write FPortable;
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

uses f_filesystem, f_window, const_common;

const Cdrtfe_Name        = 'cdrtfe';
      Cdrtfe_Version     = 'cdrtfe 1.5.1'
                           {$IFDEF TestVersion} + '-test' {$ENDIF};
      Cdrtfe_Portable    = ' portable';
      Cdrtfe_Description = 'cdrtools/Mode2CDMaker/VCDImager Frontend';
      Cdrtfe_Copyright   = 'Copyright © 2004-2013  O. Valencia';
      Cdrtfe_Copyright2  = 'Copyright © 2002-2004  O. Valencia, O. Kutsche';
      Cdrtfe_Homepage    = 'http://cdrtfe.sourceforge.net';
      Cdrtfe_eMail       = 'kerberos002@users.sourceforge.net';
      {$IFDEF TestVersion}
      Cdrtfe_HintTest    = 'Achtung/Attention!' + CRLF +
                           'Dies ist eine Testversion, die noch schwere ' +
                           'Fehler enthalten könnte.' + CRLF +
                           'This is a test version which still may have ' +
                           'severe bugs.';
      {$ENDIF}

procedure TFormAbout.FormCreate(Sender: TObject);
var TempStream : TResourceStream;
    JPEGImage  : {$IFDEF UseImagingLib}TImagingJpeg{$ELSE}TJPEGImage{$ENDIF};
begin
  SetFont(Self);

  {Banner}
  FrameTopBanner1.Init(Cdrtfe_Name, Cdrtfe_Description, 'grad1');

  {special Font settings}
  Label1.Font.Color := clBlue;
  Label1.Font.Style := [fsUnderline];
  Label1.Cursor := crHandPoint;

  Label2.Font.Color:=clBlue;
  Label2.Font.Style:=[fsUnderline];
  Label2.Cursor:=crHandPoint;

  StaticTextVersion.Font.Style := [fsBold];
  LabelHintTest.Font.Color := clMaroon;
  LabelHintTest.Caption := '';

  {set captions}
  StaticTextVersion.Caption  := Cdrtfe_Version;
  StaticText3.Caption := Cdrtfe_Copyright;
  StaticText6.Caption := Cdrtfe_Copyright2;
  StaticText7.Caption := '(' + GetFileVersionString(Application.ExeName) + ')';
  Label1.Caption      := Cdrtfe_Homepage;
  Label2.Caption      := Cdrtfe_eMail;

  TempStream := TResourceStream.Create(hInstance, 'License', RT_RCDATA);
  try
    TempStream.Position := 0;
    RichEdit1.Lines.LoadFromStream(TempStream);
  finally
    TempStream.Free;
  end;

  TempStream := TResourceStream.Create(hInstance, 'Credits', RT_RCDATA);
  try
    TempStream.Position := 0;
    RichEdit2.Lines.LoadFromStream(TempStream);
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
  LabelHintTest.Caption := Cdrtfe_HintTest;
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
  FLang.SetFormLang(Self);
  if FPortable then
    StaticTextVersion.Caption := StaticTextVersion.Caption + Cdrtfe_Portable;
  StaticText7.Left := StaticTextVersion.Left + StaticTextVersion.Width + 10;      
end;

initialization

end.
