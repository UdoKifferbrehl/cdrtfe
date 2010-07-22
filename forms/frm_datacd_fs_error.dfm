object FormDataCDFSError: TFormDataCDFSError
  Left = 200
  Top = 108
  HelpContext = 1303
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 409
  ClientWidth = 684
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    684
    409)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 56
    Width = 3
    Height = 13
  end
  object Label2: TLabel
    Left = 669
    Top = 56
    Width = 3
    Height = 13
    Alignment = taRightJustify
  end
  object GroupBox1: TGroupBox
    Left = 288
    Top = 280
    Width = 385
    Height = 121
    TabOrder = 1
    object StaticText1: TStaticText
      Left = 16
      Top = 16
      Width = 273
      Height = 41
      AutoSize = False
      Caption = 
        'Die angezeigten Dateinamen unver'#228'ndert lassen und die '#220'berpr'#252'fun' +
        'g auf zu lange Dateinamen abschalten.'
      TabOrder = 2
    end
    object ButtonIgnore: TButton
      Left = 296
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Ignorieren'
      TabOrder = 1
      OnClick = ButtonIgnoreClick
    end
    object ButtonOk: TButton
      Left = 296
      Top = 72
      Width = 75
      Height = 25
      Caption = 'Ok'
      TabOrder = 0
      OnClick = ButtonOkClick
    end
    object StaticText2: TStaticText
      Left = 16
      Top = 72
      Width = 273
      Height = 41
      AutoSize = False
      Caption = 
        'Die angezeigten Dateinamen unver'#228'ndert lassen. Neu hinzugef'#252'gte ' +
        'Dateien werden weiterhin '#252'berpr'#252'ft.'
      TabOrder = 3
    end
  end
  object ListView: TListView
    Left = 8
    Top = 80
    Width = 665
    Height = 193
    Columns = <
      item
        Caption = 'Name'
        Width = 350
      end
      item
        Alignment = taRightJustify
        Caption = 'L'#228'nge'
      end
      item
        Caption = 'Herkunft'
        Width = 600
      end>
    PopupMenu = PopupMenu
    TabOrder = 0
    ViewStyle = vsReport
    OnEdited = ListViewEdited
    OnEditing = ListViewEditing
    OnKeyDown = ListViewKeyDown
  end
  object Hinweis: TGroupBox
    Left = 8
    Top = 280
    Width = 273
    Height = 121
    Caption = 'Hinweis'
    TabOrder = 2
    object Label3: TLabel
      Left = 8
      Top = 16
      Width = 257
      Height = 97
      AutoSize = False
      WordWrap = True
    end
  end
  inline FrameTopBanner1: TFrameTopBanner
    Left = 0
    Top = 0
    Width = 684
    Height = 53
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
    ExplicitWidth = 684
    inherited Bevel1: TBevel
      Width = 684
      ExplicitWidth = 684
    end
    inherited PanelTop: TPanel
      Width = 684
      ExplicitWidth = 684
      inherited Image2: TImage
        Width = 509
        ExplicitWidth = 509
      end
      inherited LabelDescription: TLabel
        Width = 79
        ExplicitWidth = 79
      end
    end
  end
  object PopupMenu: TPopupMenu
    Left = 640
    Top = 176
    object Rename: TMenuItem
      Caption = 'Umbenennen'
      OnClick = RenameClick
    end
  end
  object Timer1: TTimer
    Interval = 250
    OnTimer = Timer1Timer
    Left = 608
    Top = 176
  end
end
