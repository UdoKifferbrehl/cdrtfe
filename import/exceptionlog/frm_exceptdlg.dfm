object ExceptionDialog: TExceptionDialog
  Left = 238
  Top = 146
  Caption = 'ExceptionDialog'
  ClientHeight = 317
  ClientWidth = 522
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnPaint = FormPaint
  OnShow = FormShow
  DesignSize = (
    522
    317)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 3
    Top = 99
    Width = 518
    Height = 9
    Anchors = [akLeft, akTop, akRight]
    Shape = bsTopLine
  end
  object TextLabel: TMemo
    Left = 56
    Top = 8
    Width = 281
    Height = 75
    Hint = 'Use Ctrl+C to copy the report to the clipboard'
    BorderStyle = bsNone
    Ctl3D = True
    Lines.Strings = (
      'TextLabel')
    ParentColor = True
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 0
    WantReturns = False
  end
  object PageControl1: TPageControl
    Left = 4
    Top = 120
    Width = 514
    Height = 185
    ActivePage = TabSheet2
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = 'Report'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        506
        157)
      object DetailsMemo: TMemo
        Left = 0
        Top = 0
        Width = 507
        Height = 158
        Anchors = [akLeft, akTop, akRight, akBottom]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
        WantReturns = False
        WordWrap = False
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Call stack'
      ImageIndex = 1
      DesignSize = (
        506
        157)
      object ListView1: TListView
        Left = 0
        Top = 0
        Width = 507
        Height = 155
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = 'address'
            Width = 71
          end
          item
            Alignment = taRightJustify
            Caption = 'rel.'
            Width = 45
          end
          item
            Caption = 'Function'
            MinWidth = -2
            Width = 210
          end
          item
            AutoSize = True
            Caption = 'Unit'
            MinWidth = -2
          end
          item
            Alignment = taRightJustify
            Caption = 'Line'
            Width = 45
          end
          item
            Alignment = taRightJustify
            Caption = 'rel.'
            Width = 45
          end>
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = []
        GridLines = True
        ParentFont = False
        TabOrder = 0
        ViewStyle = vsReport
        OnCustomDrawItem = ListView1CustomDrawItem
        OnCustomDrawSubItem = ListView1CustomDrawSubItem
      end
    end
  end
  object OkBtn: TButton
    Left = 442
    Top = 8
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object DetailsBtn: TButton
    Left = 442
    Top = 56
    Width = 75
    Height = 25
    Hint = 'Show or hide additional information|'
    Anchors = [akTop, akRight]
    Caption = '&Details'
    TabOrder = 3
    OnClick = DetailsBtnClick
  end
  object SaveBtn: TButton
    Left = 360
    Top = 56
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Save Report'
    TabOrder = 4
    OnClick = SaveBtnClick
  end
  object SaveDialog1: TSaveDialog
    Left = 8
    Top = 56
  end
end
