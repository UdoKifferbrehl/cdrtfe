object FormOutput: TFormOutput
  Left = 200
  Top = 108
  Caption = 'cdrtfe - Ausgabe'
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
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    608
    534)
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 8
    Top = 56
    Width = 593
    Height = 441
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 1
    OnKeyDown = Memo1KeyDown
  end
  object ButtonOk: TButton
    Left = 528
    Top = 504
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 0
  end
  object CheckBoxAutoUpdate: TCheckBox
    Left = 8
    Top = 504
    Width = 185
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'automatisch aktualisieren'
    Checked = True
    State = cbChecked
    TabOrder = 2
    OnClick = CheckBoxAutoUpdateClick
  end
  inline FrameTopBanner1: TFrameTopBanner
    Left = 0
    Top = 0
    Width = 608
    Height = 50
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
    TabStop = True
    inherited Bevel1: TBevel
      Top = 47
      Width = 608
    end
    inherited PanelTop: TPanel
      Width = 608
      Height = 47
      inherited Image2: TImage
        Width = 433
        Height = 47
      end
      inherited LabelDescription: TLabel
        Width = 79
      end
    end
  end
end
