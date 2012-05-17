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
    end
    inherited PanelTop: TPanel
      Width = 608
      inherited Image2: TImage
        Width = 433
      end
      inherited LabelDescription: TLabel
        Width = 79
        ExplicitWidth = 79
      end
    end
  end
end
