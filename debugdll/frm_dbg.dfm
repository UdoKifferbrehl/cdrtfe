object FormDebug: TFormDebug
  Left = 200
  Top = 110
  BorderStyle = bsToolWindow
  Caption = 'cdrtfe debug window'
  ClientHeight = 383
  ClientWidth = 563
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 545
    Height = 369
    ActivePage = TabSheet1
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Log'
      object MemoLog: TMemo
        Left = 8
        Top = 8
        Width = 521
        Height = 297
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Lucida Console'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 0
      end
      object ButtonSaveLog: TButton
        Left = 8
        Top = 312
        Width = 75
        Height = 25
        Caption = 'Save Log'
        TabOrder = 1
        OnClick = ButtonSaveLogClick
      end
      object CheckBoxAutoSave: TCheckBox
        Left = 88
        Top = 320
        Width = 185
        Height = 17
        Caption = 'Save on Exit'
        TabOrder = 2
      end
    end
  end
  object SaveDialog1: TSaveDialog
    Left = 28
    Top = 48
  end
end
