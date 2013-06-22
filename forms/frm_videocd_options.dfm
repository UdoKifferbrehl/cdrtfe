object FormVideoCDOptions: TFormVideoCDOptions
  Left = 200
  Top = 108
  HelpContext = 2001
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'VideoCD - Optionen'
  ClientHeight = 248
  ClientWidth = 474
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
    474
    248)
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonOk: TButton
    Left = 312
    Top = 216
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 5
    OnClick = ButtonOkClick
  end
  object ButtonCancel: TButton
    Left = 392
    Top = 216
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
    Width = 225
    Height = 105
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
  end
  object GroupBoxVCDType: TGroupBox
    Left = 240
    Top = 56
    Width = 225
    Height = 153
    Caption = 'VideoCD-Typ'
    TabOrder = 2
    object RadioButtonVCD1: TRadioButton
      Left = 8
      Top = 24
      Width = 201
      Height = 17
      Caption = 'VideoCD 1.1'
      TabOrder = 0
      OnClick = CheckBoxClick
    end
    object RadioButtonVCD2: TRadioButton
      Left = 8
      Top = 48
      Width = 201
      Height = 17
      Caption = 'VideoCD 2.0'
      TabOrder = 1
      OnClick = CheckBoxClick
    end
    object RadioButtonSVCD: TRadioButton
      Left = 8
      Top = 72
      Width = 201
      Height = 17
      Caption = 'Super VideoCD 1.0'
      TabOrder = 2
      OnClick = CheckBoxClick
    end
    object CheckBoxSVCDCompat: TCheckBox
      Left = 24
      Top = 96
      Width = 199
      Height = 17
      Caption = 'Kompatibilit'#228'tsmodus'
      TabOrder = 3
    end
    object CheckBoxSec2336: TCheckBox
      Left = 8
      Top = 128
      Width = 209
      Height = 17
      Caption = '2336-Byte-Sektoren verwenden'
      TabOrder = 4
    end
  end
  object CheckBoxOverBurn: TCheckBox
    Left = 16
    Top = 168
    Width = 97
    Height = 17
    Caption = #220'berbrennen'
    TabOrder = 3
  end
  object CheckBoxVerbose: TCheckBox
    Left = 16
    Top = 192
    Width = 169
    Height = 17
    Caption = 'ausf'#252'hrliche Ausgabe'
    TabOrder = 4
  end
  inline FrameTopBanner1: TFrameTopBanner
    Left = 0
    Top = 0
    Width = 474
    Height = 53
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 6
    inherited Bevel1: TBevel
      Width = 474
    end
    inherited PanelTop: TPanel
      Width = 474
      inherited Image2: TImage
        Width = 299
      end
      inherited LabelDescription: TLabel
        Width = 79
      end
    end
  end
  object SaveDialog1: TSaveDialog
    Left = 200
    Top = 168
  end
end
