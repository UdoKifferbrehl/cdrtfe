object FormAudioCDTracks: TFormAudioCDTracks
  Left = 200
  Top = 108
  HelpContext = 1402
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Audio-CD - Track-Eigenschaften'
  ClientHeight = 476
  ClientWidth = 537
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnShow = FormShow
  DesignSize = (
    537
    476)
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonOk: TButton
    Left = 376
    Top = 440
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 3
    OnClick = ButtonOkClick
    OnExit = ExitTabSpecial
  end
  object ButtonCancel: TButton
    Left = 456
    Top = 440
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Abbrechen'
    ModalResult = 2
    TabOrder = 0
    OnExit = ExitTabSpecial
  end
  object GroupBoxCDText: TGroupBox
    Left = 8
    Top = 56
    Width = 521
    Height = 297
    Caption = 'CD-Text'
    TabOrder = 1
    object LabelAlbumTitle: TLabel
      Left = 16
      Top = 24
      Width = 80
      Height = 13
      Caption = 'Titel des Albums:'
    end
    object LabelAlbumPerformer: TLabel
      Left = 160
      Top = 24
      Width = 42
      Height = 13
      Caption = 'Interpret:'
    end
    object LabelCDTextRemaining: TLabel
      Left = 415
      Top = 24
      Width = 90
      Height = 13
      Alignment = taRightJustify
      Caption = 'Zeichen verf'#252'gbar:'
    end
    object LabelRemainingChars: TLabel
      Left = 470
      Top = 43
      Width = 35
      Height = 13
      Alignment = taRightJustify
      Caption = '0/3024'
    end
    object GridTextData: TStringGrid
      Left = 16
      Top = 80
      Width = 489
      Height = 201
      ColCount = 3
      Ctl3D = True
      RowCount = 3
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goTabs, goAlwaysShowEditor]
      ParentCtl3D = False
      ScrollBars = ssVertical
      TabOrder = 3
      OnDrawCell = GridTextDataDrawCell
      OnEnter = GridTextDataEnter
      OnExit = ExitTabSpecial
      OnKeyDown = GridTextDataKeyDown
      OnKeyUp = GridTextDataKeyUp
      ColWidths = (
        64
        66
        64)
    end
    object EditAlbumTitle: TEdit
      Left = 16
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 0
      OnChange = EditChange
      OnExit = ExitTabSpecial
      OnKeyPress = EditKeyPress
    end
    object EditAlbumPerformer: TEdit
      Left = 160
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 1
      OnChange = EditChange
      OnExit = ExitTabSpecial
      OnKeyPress = EditKeyPress
    end
    object CheckBoxSampler: TCheckBox
      Left = 296
      Top = 40
      Width = 97
      Height = 17
      Caption = 'Sampler'
      TabOrder = 2
      OnClick = CheckBoxClick
      OnExit = ExitTabSpecial
    end
  end
  object GroupBoxPause: TGroupBox
    Left = 8
    Top = 360
    Width = 353
    Height = 105
    Caption = 'Pausen zwischen den Tracks'
    TabOrder = 2
    object RadioButtonNoPause: TRadioButton
      Left = 16
      Top = 24
      Width = 153
      Height = 17
      Caption = 'keine Pausen'
      TabOrder = 0
      OnClick = CheckBoxClick
      OnExit = ExitTabSpecial
    end
    object RadioButtonPause: TRadioButton
      Left = 16
      Top = 48
      Width = 153
      Height = 17
      Caption = 'einheitliche Pausen:'
      TabOrder = 1
      OnClick = CheckBoxClick
      OnExit = ExitTabSpecial
    end
    object RadioButtonUserdefinedPause: TRadioButton
      Left = 16
      Top = 72
      Width = 153
      Height = 17
      Caption = 'benutzerdefinierte Pausen'
      TabOrder = 2
      OnClick = CheckBoxClick
      OnExit = ExitTabSpecial
    end
    object EditPause: TEdit
      Left = 176
      Top = 48
      Width = 49
      Height = 21
      TabOrder = 3
      Text = '2'
      OnExit = ExitTabSpecial
      OnKeyPress = EditKeyPress
    end
    object ComboBoxPause: TComboBox
      Left = 232
      Top = 48
      Width = 105
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 4
      OnExit = ExitTabSpecial
      OnKeyPress = EditKeyPress
      Items.Strings = (
        'Sekunden'
        'Sektoren')
    end
  end
  inline FrameTopBanner1: TFrameTopBanner
    Left = 0
    Top = 0
    Width = 537
    Height = 53
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
    TabStop = True
    inherited Bevel1: TBevel
      Width = 537
    end
    inherited PanelTop: TPanel
      Width = 537
      inherited Image2: TImage
        Width = 362
      end
      inherited LabelDescription: TLabel
        Width = 79
      end
    end
  end
end
