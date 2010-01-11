object FormAudioCDOptions: TFormAudioCDOptions
  Left = 200
  Top = 108
  HelpContext = 1401
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Audio-CD - Optionen'
  ClientHeight = 344
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
    344)
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
    Height = 169
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
    Left = 256
    Top = 312
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 5
    OnClick = ButtonOkClick
  end
  object ButtonCancel: TButton
    Left = 336
    Top = 312
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
    TabOrder = 6
    TabStop = True
    ExplicitWidth = 419
    inherited Bevel1: TBevel
      Width = 419
      ExplicitWidth = 419
    end
    inherited PanelTop: TPanel
      Width = 419
      ExplicitWidth = 419
      inherited Image2: TImage
        Width = 244
        ExplicitWidth = 244
      end
      inherited LabelDescription: TLabel
        Width = 79
        ExplicitWidth = 79
      end
    end
  end
end
