object FormMAOutput: TFormMAOutput
  Left = 200
  Top = 108
  Caption = 'cdrtfe - Mehrfachkopien'
  ClientHeight = 534
  ClientWidth = 608
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    608
    534)
  PixelsPerInch = 96
  TextHeight = 13
  inline FrameTopBanner1: TFrameTopBanner
    Left = 0
    Top = 0
    Width = 608
    Height = 53
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    TabStop = True
    ExplicitWidth = 608
    inherited Bevel1: TBevel
      Width = 608
      ExplicitWidth = 608
    end
    inherited PanelTop: TPanel
      Width = 608
      ExplicitWidth = 608
      inherited Image2: TImage
        Width = 433
        ExplicitWidth = 433
      end
      inherited LabelDescription: TLabel
        Width = 79
        ExplicitWidth = 79
      end
    end
  end
  object Memo1: TMemo
    Left = 8
    Top = 59
    Width = 513
    Height = 89
    TabOrder = 1
  end
  object Button1: TButton
    Left = 527
    Top = 59
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 2
    OnClick = Button1Click
  end
  object PageControl: TPageControl
    Left = 8
    Top = 154
    Width = 592
    Height = 372
    TabOrder = 3
  end
  object Button2: TButton
    Left = 527
    Top = 90
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 4
    OnClick = Button2Click
  end
end
