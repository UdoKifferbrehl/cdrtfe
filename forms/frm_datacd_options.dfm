object FormDataCDOptions: TFormDataCDOptions
  Left = 200
  Top = 108
  HelpContext = 1301
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Daten-CD - Optionen'
  ClientHeight = 338
  ClientWidth = 458
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    458
    338)
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBoxCD: TGroupBox
    Left = 8
    Top = 224
    Width = 441
    Height = 73
    Caption = 'CD'
    TabOrder = 3
    object CheckBoxMulti: TCheckBox
      Left = 8
      Top = 24
      Width = 193
      Height = 17
      Caption = 'Multisession'
      TabOrder = 0
      OnClick = CheckBoxClick
    end
    object CheckBoxContinue: TCheckBox
      Left = 8
      Top = 48
      Width = 193
      Height = 17
      Caption = 'vorhandene Sessions importieren'
      TabOrder = 1
      OnClick = CheckBoxClick
    end
    object CheckBoxLastSession: TCheckBox
      Left = 208
      Top = 24
      Width = 225
      Height = 17
      Caption = 'CD abschlie'#223'en (keine weiteren Sessions)'
      TabOrder = 2
    end
    object CheckBoxSelectSess: TCheckBox
      Left = 208
      Top = 48
      Width = 225
      Height = 17
      Caption = 'Session manuell w'#228'hlen'
      TabOrder = 3
    end
  end
  object GroupBoxWritingMode: TGroupBox
    Left = 256
    Top = 56
    Width = 193
    Height = 161
    Caption = 'Schreibmodus'
    TabOrder = 2
    object RadioButtonTAO: TRadioButton
      Left = 8
      Top = 24
      Width = 113
      Height = 17
      Caption = 'track-at-once'
      TabOrder = 0
      OnClick = CheckBoxClick
    end
    object RadioButtonDAO: TRadioButton
      Left = 8
      Top = 48
      Width = 113
      Height = 17
      Caption = 'disk-at-once'
      TabOrder = 1
      OnClick = CheckBoxClick
    end
    object RadioButtonRAW: TRadioButton
      Left = 8
      Top = 72
      Width = 97
      Height = 17
      Caption = 'Raw-Modus:'
      TabOrder = 2
      OnClick = CheckBoxClick
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
      Top = 136
      Width = 153
      Height = 17
      Caption = #220'berbrennen'
      TabOrder = 4
    end
  end
  object ButtonOk: TButton
    Left = 296
    Top = 304
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 4
    OnClick = ButtonOkClick
  end
  object ButtonCancel: TButton
    Left = 376
    Top = 304
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Abbrechen'
    ModalResult = 2
    TabOrder = 0
  end
  object GroupBoxImage: TGroupBox
    Left = 8
    Top = 56
    Width = 241
    Height = 161
    Caption = 'ISO-Image'
    TabOrder = 1
    object RadioButtonImage: TRadioButton
      Left = 8
      Top = 24
      Width = 145
      Height = 17
      Caption = 'Image verwenden'
      TabOrder = 0
      OnClick = CheckBoxClick
    end
    object RadioButtonOnTheFly: TRadioButton
      Left = 8
      Top = 136
      Width = 217
      Height = 17
      Caption = 'on-the-fly, kein Image'
      TabOrder = 5
      OnClick = CheckBoxClick
    end
    object EditIsoPath: TEdit
      Left = 24
      Top = 48
      Width = 121
      Height = 21
      TabOrder = 1
      OnKeyPress = EditKeyPress
    end
    object ButtonImageSelect: TButton
      Left = 152
      Top = 48
      Width = 75
      Height = 25
      Caption = 'Auswahl'
      TabOrder = 2
      OnClick = ButtonImageSelectClick
    end
    object CheckBoxImageOnly: TCheckBox
      Left = 24
      Top = 80
      Width = 201
      Height = 17
      Caption = 'Image nur erstellen, nicht brennen'
      TabOrder = 3
      OnClick = CheckBoxClick
    end
    object CheckBoxImageKeep: TCheckBox
      Left = 24
      Top = 104
      Width = 201
      Height = 17
      Caption = 'Image nicht l'#246'schen'
      TabOrder = 4
      OnClick = CheckBoxClick
    end
  end
  inline FrameTopBanner1: TFrameTopBanner
    Left = 0
    Top = 0
    Width = 458
    Height = 53
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
    ExplicitWidth = 458
    inherited Bevel1: TBevel
      Width = 458
      ExplicitWidth = 458
    end
    inherited PanelTop: TPanel
      Width = 458
      ExplicitWidth = 458
      inherited Image2: TImage
        Width = 283
        ExplicitWidth = 283
      end
      inherited LabelDescription: TLabel
        Width = 79
        ExplicitWidth = 79
      end
    end
  end
  object SaveDialog1: TSaveDialog
    Left = 264
    Top = 304
  end
end
