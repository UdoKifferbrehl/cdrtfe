object FormAudioCDOptions: TFormAudioCDOptions
  Left = 200
  Top = 108
  HelpContext = 1401
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Audio-CD - Optionen'
  ClientHeight = 371
  ClientWidth = 419
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
    419
    371)
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBoxCD: TGroupBox
    Left = 8
    Top = 56
    Width = 201
    Height = 73
    Caption = 'CD'
    TabOrder = 1
    object CheckBoxFix: TCheckBox
      Left = 8
      Top = 24
      Width = 177
      Height = 17
      Caption = 'CD abschlie'#223'en'
      TabOrder = 0
      OnClick = RadioButtonClick
    end
    object CheckBoxMulti: TCheckBox
      Left = 8
      Top = 48
      Width = 177
      Height = 17
      Caption = 'Multisession (f'#252'r CD+)'
      TabOrder = 1
    end
  end
  object GroupBoxWritingMode: TGroupBox
    Left = 216
    Top = 56
    Width = 193
    Height = 177
    Caption = 'Schreibmodus'
    TabOrder = 4
    object RadioButtonTAO: TRadioButton
      Left = 8
      Top = 24
      Width = 113
      Height = 17
      Caption = 'track-at-once'
      TabOrder = 0
      OnClick = RadioButtonClick
    end
    object RadioButtonDAO: TRadioButton
      Left = 8
      Top = 48
      Width = 113
      Height = 17
      Caption = 'disk-at-once'
      TabOrder = 1
      OnClick = RadioButtonClick
    end
    object RadioButtonRAW: TRadioButton
      Left = 8
      Top = 72
      Width = 97
      Height = 17
      Caption = 'Raw-Modus:'
      TabOrder = 2
      OnClick = RadioButtonClick
    end
    object Panel1: TPanel
      Left = 104
      Top = 64
      Width = 81
      Height = 73
      BevelOuter = bvNone
      TabOrder = 3
      object RadioButtonRaw96r: TRadioButton
        Left = 8
        Top = 8
        Width = 65
        Height = 17
        Caption = 'raw96r'
        TabOrder = 0
      end
      object RadioButtonRaw96p: TRadioButton
        Left = 8
        Top = 32
        Width = 65
        Height = 17
        Caption = 'raw96p'
        TabOrder = 1
      end
      object RadioButtonRaw16: TRadioButton
        Left = 8
        Top = 56
        Width = 65
        Height = 17
        Caption = 'raw16'
        TabOrder = 2
      end
    end
    object CheckBoxOverburn: TCheckBox
      Left = 8
      Top = 144
      Width = 153
      Height = 17
      Caption = #220'berbrennen'
      TabOrder = 4
    end
  end
  object ButtonOk: TButton
    Left = 255
    Top = 343
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 6
    OnClick = ButtonOkClick
  end
  object ButtonCancel: TButton
    Left = 336
    Top = 343
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Abbrechen'
    ModalResult = 2
    TabOrder = 0
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 136
    Width = 201
    Height = 97
    Caption = 'Optionen'
    TabOrder = 2
    object CheckBoxPreemphasis: TCheckBox
      Left = 8
      Top = 24
      Width = 177
      Height = 17
      Caption = 'Preemphasis'
      TabOrder = 0
    end
    object CheckBoxUseInfo: TCheckBox
      Left = 8
      Top = 48
      Width = 177
      Height = 17
      Caption = 'Info-Dateien verwenden'
      TabOrder = 1
    end
    object CheckBoxCDText: TCheckBox
      Left = 8
      Top = 72
      Width = 177
      Height = 17
      Caption = 'CD-Text schreiben'
      TabOrder = 2
    end
  end
  object GroupBoxCopy: TGroupBox
    Left = 8
    Top = 240
    Width = 201
    Height = 97
    Caption = 'Kopien'
    TabOrder = 3
    object RadioButtonNoCopy: TRadioButton
      Left = 8
      Top = 24
      Width = 177
      Height = 17
      Caption = 'eine Kopie erlaubt'
      TabOrder = 0
    end
    object RadioButtonCopy: TRadioButton
      Left = 8
      Top = 48
      Width = 177
      Height = 17
      Caption = 'beliebig viele Kopien erlaubt'
      TabOrder = 1
    end
    object RadioButtonSCMS: TRadioButton
      Left = 8
      Top = 72
      Width = 177
      Height = 17
      Caption = 'keine Kpien erlaubt'
      TabOrder = 2
    end
  end
  inline FrameTopBanner1: TFrameTopBanner
    Left = 0
    Top = 0
    Width = 419
    Height = 53
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 7
    inherited Bevel1: TBevel
      Width = 419
    end
    inherited PanelTop: TPanel
      Width = 419
      inherited Image2: TImage
        Width = 244
      end
      inherited LabelDescription: TLabel
        Width = 79
      end
    end
  end
  object GroupBoxReplayGain: TGroupBox
    Left = 215
    Top = 240
    Width = 196
    Height = 97
    Caption = 'ReplayGain'
    TabOrder = 5
    object LabelGain: TLabel
      Left = 28
      Top = 48
      Width = 115
      Height = 13
      Caption = 'zus'#228'tzliche Verst'#228'rkung:'
    end
    object LabelGain2: TLabel
      Left = 79
      Top = 70
      Width = 98
      Height = 13
      Caption = 'dB (-12,0 ... 12,0 dB)'
    end
    object CheckBoxReplayGain: TCheckBox
      Left = 8
      Top = 24
      Width = 169
      Height = 17
      Caption = 'ReplayGain anwenden'
      TabOrder = 0
      OnClick = RadioButtonClick
    end
    object EditGain: TEdit
      Left = 28
      Top = 67
      Width = 33
      Height = 21
      ReadOnly = True
      TabOrder = 2
      Text = '0'
    end
    object UpDownGain: TUpDown
      Left = 61
      Top = 67
      Width = 12
      Height = 21
      Associate = EditGain
      Min = -120
      Max = 120
      TabOrder = 1
      TabStop = True
      OnClick = UpDownGainClick
    end
  end
end
