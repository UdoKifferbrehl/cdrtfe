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
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
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
      end
    end
  end
  object Memo1: TMemo
    Left = 8
    Top = 59
    Width = 513
    Height = 89
    Anchors = [akLeft, akTop, akRight]
    ScrollBars = ssBoth
    TabOrder = 5
  end
  object ButtonCancel: TButton
    Left = 527
    Top = 121
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Beenden'
    TabOrder = 3
    OnClick = ButtonCancelClick
  end
  object PageControl: TPageControl
    Left = 8
    Top = 154
    Width = 592
    Height = 372
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 4
    OnChange = PageControlChange
  end
  object ButtonStart: TButton
    Left = 527
    Top = 59
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Start'
    TabOrder = 1
    OnClick = ButtonStartClick
  end
  object ButtonAbort: TButton
    Left = 527
    Top = 90
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Abbrechen'
    TabOrder = 2
    Visible = False
    OnClick = ButtonAbortClick
  end
end
