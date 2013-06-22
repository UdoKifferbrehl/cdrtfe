object FormXCDOptions: TFormXCDOptions
  Left = 200
  Top = 108
  HelpContext = 1501
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'XCD - Optionen'
  ClientHeight = 328
  ClientWidth = 473
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
    473
    328)
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBoxImage: TGroupBox
    Left = 8
    Top = 56
    Width = 225
    Height = 129
    Caption = 'Image'
    TabOrder = 1
    object EditIsoPath: TEdit
      Left = 8
      Top = 24
      Width = 121
      Height = 21
      TabOrder = 0
      OnKeyPress = EditKeyPress
    end
    object ButtonImageSelect: TButton
      Left = 136
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Auswahl'
      TabOrder = 1
      OnClick = ButtonImageSelectClick
    end
    object CheckBoxImageOnly: TCheckBox
      Left = 8
      Top = 56
      Width = 201
      Height = 17
      Caption = 'Image nur erstellen, nicht brennen'
      TabOrder = 2
      OnClick = CheckBoxClick
    end
    object CheckBoxImageKeep: TCheckBox
      Left = 8
      Top = 80
      Width = 201
      Height = 17
      Caption = 'Image nicht l'#246'schen'
      TabOrder = 3
      OnClick = CheckBoxClick
    end
    object CheckBoxSingle: TCheckBox
      Left = 8
      Top = 104
      Width = 201
      Height = 17
      Caption = 'Single-Track-Image erstellen'
      TabOrder = 4
    end
  end
  object GroupBoxISO: TGroupBox
    Left = 8
    Top = 192
    Width = 225
    Height = 97
    Caption = 'ISO-Dateisystem'
    TabOrder = 2
    object RadioButtonISOLevelX: TRadioButton
      Left = 8
      Top = 24
      Width = 209
      Height = 17
      Caption = 'keine Einschr'#228'nkungen'
      TabOrder = 0
      OnClick = CheckBoxClick
    end
    object RadioButtonISOLevel1: TRadioButton
      Left = 8
      Top = 48
      Width = 209
      Height = 17
      Caption = 'ISO9660 Level 1 erzwingen'
      TabOrder = 1
      OnClick = CheckBoxClick
    end
    object RadioButtonISOLevel2: TRadioButton
      Left = 8
      Top = 72
      Width = 209
      Height = 17
      Caption = 'ISO9960 Level 2 erzwingen'
      TabOrder = 2
      OnClick = CheckBoxClick
    end
  end
  object GroupBoxOptions: TGroupBox
    Left = 240
    Top = 56
    Width = 225
    Height = 81
    Caption = 'Optionen'
    TabOrder = 4
    object Label1: TLabel
      Left = 8
      Top = 50
      Width = 116
      Height = 13
      Caption = 'Dateiendung f'#252'r Movies:'
    end
    object CheckBoxKeepExt: TCheckBox
      Left = 8
      Top = 24
      Width = 201
      Height = 17
      Caption = 'Dateiendung erhalten'
      TabOrder = 0
    end
    object EditExt: TEdit
      Left = 152
      Top = 48
      Width = 65
      Height = 21
      TabOrder = 1
      OnKeyPress = EditKeyPress
    end
  end
  object ButtonOk: TButton
    Left = 312
    Top = 296
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 7
    OnClick = ButtonOkClick
  end
  object ButtonCancel: TButton
    Left = 392
    Top = 296
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Abbrechen'
    ModalResult = 2
    TabOrder = 0
  end
  object CheckBoxOverburn: TCheckBox
    Left = 16
    Top = 296
    Width = 201
    Height = 17
    Caption = #220'berbrennen'
    TabOrder = 3
  end
  object GroupBoxInfoFile: TGroupBox
    Left = 240
    Top = 144
    Width = 225
    Height = 49
    Caption = 'Info-Datei'
    TabOrder = 5
    object CheckBoxCreateInfoFile: TCheckBox
      Left = 8
      Top = 24
      Width = 209
      Height = 17
      Caption = 'Info-Datei (xcd.crc) erzeugen'
      TabOrder = 0
      OnClick = CheckBoxClick
    end
  end
  object GroupBoxErrorProtection: TGroupBox
    Left = 240
    Top = 200
    Width = 225
    Height = 81
    Caption = 'Fehlerkorrektur'
    TabOrder = 6
    object LabelSecCount: TLabel
      Left = 8
      Top = 48
      Width = 99
      Height = 13
      Caption = 'Anzahl der Sektoren:'
    end
    object CheckBoxUseErrorProtection: TCheckBox
      Left = 8
      Top = 24
      Width = 209
      Height = 17
      Caption = 'Fehlerkorrektur erm'#246'glichen (rrenc)'
      TabOrder = 0
      OnClick = CheckBoxClick
    end
    object EditSecCount: TEdit
      Left = 152
      Top = 48
      Width = 65
      Height = 21
      TabOrder = 1
    end
  end
  inline FrameTopBanner1: TFrameTopBanner
    Left = 0
    Top = 0
    Width = 473
    Height = 53
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 8
    inherited Bevel1: TBevel
      Width = 473
    end
    inherited PanelTop: TPanel
      Width = 473
      inherited Image2: TImage
        Width = 298
      end
      inherited LabelDescription: TLabel
        Width = 79
      end
    end
  end
  object SaveDialog1: TSaveDialog
    Left = 240
    Top = 296
  end
end
