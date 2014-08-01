object FormAbout: TFormAbout
  Left = 200
  Top = 108
  BorderStyle = bsDialog
  Caption = 'Info '#252'ber cdrtfe'
  ClientHeight = 327
  ClientWidth = 379
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    379
    327)
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl: TPageControl
    Left = 0
    Top = 56
    Width = 381
    Height = 234
    ActivePage = TabSheetInfo
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    object TabSheetInfo: TTabSheet
      Caption = 'Infos'
      DesignSize = (
        373
        206)
      object Image1: TImage
        Left = 3
        Top = 11
        Width = 80
        Height = 65
      end
      object Label1: TLabel
        Left = 105
        Top = 99
        Width = 15
        Height = 13
        Caption = 'CH'
        OnClick = Label1Click
      end
      object Label2: TLabel
        Left = 105
        Top = 122
        Width = 16
        Height = 13
        Caption = 'CM'
        OnClick = Label2Click
      end
      object LabelHintTest: TLabel
        Left = 3
        Top = 155
        Width = 364
        Height = 55
        Alignment = taCenter
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'LabelHintTest'
      end
      object StaticTextVersion: TStaticText
        Left = 105
        Top = 11
        Width = 87
        Height = 17
        Caption = 'StaticTextVersion'
        TabOrder = 0
      end
      object StaticText3: TStaticText
        Left = 105
        Top = 41
        Width = 18
        Height = 17
        Caption = 'CC'
        TabOrder = 1
      end
      object StaticText6: TStaticText
        Left = 105
        Top = 64
        Width = 24
        Height = 17
        Caption = 'CC2'
        TabOrder = 2
      end
      object StaticText4: TStaticText
        Left = 3
        Top = 99
        Width = 89
        Height = 17
        Caption = 'cdrtfe-Homepage:'
        TabOrder = 3
      end
      object StaticText5: TStaticText
        Left = 3
        Top = 122
        Width = 32
        Height = 17
        Caption = 'eMail:'
        TabOrder = 4
      end
      object StaticText7: TStaticText
        Left = 291
        Top = 11
        Width = 26
        Height = 17
        Caption = 'CNV'
        TabOrder = 5
      end
    end
    object TabSheetLicense: TTabSheet
      Caption = 'Lizenz'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object RichEdit1: TRichEdit
        Left = 3
        Top = 3
        Width = 329
        Height = 192
        TabStop = False
        Color = clWhite
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object TabSheetCredits: TTabSheet
      Caption = 'Credits'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object RichEdit2: TRichEdit
        Left = 3
        Top = 3
        Width = 329
        Height = 192
        TabStop = False
        Color = clWhite
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
  object Button1: TButton
    Left = 298
    Top = 296
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 0
  end
  inline FrameTopBanner1: TFrameTopBanner
    Left = 0
    Top = 0
    Width = 379
    Height = 53
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    TabStop = True
    ExplicitWidth = 379
    inherited Bevel1: TBevel
      Width = 379
      ExplicitWidth = 379
    end
    inherited PanelTop: TPanel
      Width = 379
      ExplicitWidth = 379
      inherited Image2: TImage
        Width = 204
        ExplicitWidth = 204
      end
      inherited LabelDescription: TLabel
        Width = 79
        ExplicitWidth = 79
      end
    end
  end
end
