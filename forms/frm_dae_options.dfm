object FormDAEOptions: TFormDAEOptions
  Left = 200
  Top = 108
  HelpContext = 1801
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'DAE - Optionen'
  ClientHeight = 336
  ClientWidth = 481
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
    481
    336)
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonOk: TButton
    Left = 318
    Top = 304
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 2
    OnClick = ButtonOkClick
  end
  object ButtonCancel: TButton
    Left = 398
    Top = 304
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Abbrechen'
    ModalResult = 2
    TabOrder = 0
  end
  object PageControlDAE: TPageControl
    Left = 8
    Top = 56
    Width = 465
    Height = 241
    ActivePage = TabSheetDAE
    TabOrder = 1
    object TabSheetDAE: TTabSheet
      HelpContext = 1802
      Caption = 'DAE'
      object LabelSpeedW: TLabel
        Left = 16
        Top = 188
        Width = 115
        Height = 13
        Caption = 'Schreibgeschwindigkeit:'
      end
      object GroupBoxFileNames: TGroupBox
        Left = 8
        Top = 8
        Width = 217
        Height = 145
        Caption = 'Dateinamen'
        TabOrder = 0
        object RadioButtonDAEUsePrefix: TRadioButton
          Left = 8
          Top = 24
          Width = 201
          Height = 17
          Caption = 'Pr'#228'fix f'#252'r Dateinamen:'
          TabOrder = 0
          OnClick = CheckBoxClick
        end
        object RadioButtonDAEUseNamePattern: TRadioButton
          Left = 8
          Top = 80
          Width = 201
          Height = 17
          Caption = 'Namen aus CD-Infos:'
          TabOrder = 2
          OnClick = CheckBoxClick
        end
        object EditDAEPrefix: TEdit
          Left = 32
          Top = 48
          Width = 153
          Height = 21
          TabOrder = 1
          OnKeyPress = EditKeyPress
        end
        object EditDAENamePattern: TEdit
          Left = 32
          Top = 104
          Width = 153
          Height = 21
          TabOrder = 3
          OnKeyPress = EditKeyPress
        end
      end
      object GroupBoxOptions: TGroupBox
        Left = 232
        Top = 8
        Width = 217
        Height = 97
        Caption = 'Optionen'
        TabOrder = 1
        object CheckBoxDAEBulk: TCheckBox
          Left = 8
          Top = 24
          Width = 201
          Height = 17
          Caption = 'separate Datei f'#252'r jeden Track'
          TabOrder = 0
        end
        object CheckBoxDAELibParanoia: TCheckBox
          Left = 8
          Top = 48
          Width = 201
          Height = 17
          Caption = 'Lib Paranoia verwenden'
          TabOrder = 1
        end
        object CheckBoxDAENoInfofiles: TCheckBox
          Left = 8
          Top = 72
          Width = 201
          Height = 17
          Caption = 'keine Info-Dateien erzeugen'
          TabOrder = 2
        end
      end
      object GroupBoxDAEFormat: TGroupBox
        Left = 232
        Top = 112
        Width = 217
        Height = 97
        Caption = 'Format'
        TabOrder = 2
        object RadioButtonDAEWav: TRadioButton
          Left = 8
          Top = 24
          Width = 89
          Height = 17
          Caption = 'Wave'
          TabOrder = 0
        end
        object RadioButtonDAEMp3: TRadioButton
          Left = 8
          Top = 48
          Width = 89
          Height = 17
          Caption = 'mp3'
          TabOrder = 1
        end
        object RadioButtonDAEOgg: TRadioButton
          Left = 8
          Top = 72
          Width = 89
          Height = 17
          Caption = 'Ogg Vorbis'
          TabOrder = 2
        end
        object RadioButtonDAEFlac: TRadioButton
          Left = 112
          Top = 24
          Width = 89
          Height = 17
          Caption = 'FLAC'
          TabOrder = 3
        end
        object RadioButtonDAECustom: TRadioButton
          Left = 112
          Top = 72
          Width = 97
          Height = 17
          Caption = 'benutzerdef.'
          TabOrder = 4
        end
      end
      object CheckBoxDAEWriteCopy: TCheckBox
        Left = 16
        Top = 160
        Width = 209
        Height = 17
        Caption = 'Tracks automatisch auf CD schreiben'
        TabOrder = 3
      end
      object ComboBoxSpeedW: TComboBox
        Left = 160
        Top = 184
        Width = 49
        Height = 21
        ItemHeight = 13
        TabOrder = 4
      end
    end
    object TabSheetCDDB: TTabSheet
      HelpContext = 1803
      Caption = 'freedb'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupBox1: TGroupBox
        Left = 8
        Top = 8
        Width = 433
        Height = 105
        TabOrder = 0
        object LabelCDDBServer: TLabel
          Left = 32
          Top = 40
          Width = 34
          Height = 13
          Caption = 'Server:'
        end
        object LabelCDDBPort: TLabel
          Left = 32
          Top = 72
          Width = 22
          Height = 13
          Caption = 'Port:'
        end
        object CheckBoxDAEUseCDDB: TCheckBox
          Left = 8
          Top = 16
          Width = 393
          Height = 17
          Caption = 'Freedb-Informationen abrufen:'
          TabOrder = 0
          OnClick = CheckBoxClick
        end
        object EditDAECDDBServer: TEdit
          Left = 96
          Top = 40
          Width = 153
          Height = 21
          TabOrder = 1
          OnKeyPress = EditKeyPress
        end
        object EditDAECDDBPort: TEdit
          Left = 96
          Top = 72
          Width = 153
          Height = 21
          TabOrder = 2
          OnKeyPress = EditKeyPress
        end
      end
    end
    object TabSheetCompression: TTabSheet
      HelpContext = 1804
      Caption = 'Encoding'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupBoxDAETags: TGroupBox
        Left = 8
        Top = 8
        Width = 433
        Height = 41
        Caption = 'Tags'
        TabOrder = 0
        object CheckBoxDAETags: TCheckBox
          Left = 8
          Top = 16
          Width = 401
          Height = 17
          Caption = 'Tags (Titel und Interpret) hinzuf'#252'gen'
          TabOrder = 0
        end
      end
      object GroupBoxDAEFlac: TGroupBox
        Left = 8
        Top = 56
        Width = 208
        Height = 73
        Caption = 'FLAC'
        TabOrder = 1
        object LabelDAEFlacCurQuality: TLabel
          Left = 30
          Top = 48
          Width = 116
          Height = 13
          Alignment = taRightJustify
          Caption = 'LabelDAEFlacCurQuality'
        end
        object LabelDAEFlac1: TLabel
          Left = 16
          Top = 48
          Width = 63
          Height = 13
          Caption = 'Kompression:'
        end
        object TrackBarFlac: TTrackBar
          Left = 8
          Top = 16
          Width = 150
          Height = 33
          Max = 8
          Position = 5
          TabOrder = 0
          OnChange = TrackBarChange
        end
      end
      object GroupBoxDAEOgg: TGroupBox
        Left = 232
        Top = 56
        Width = 208
        Height = 73
        Caption = 'Ogg Vorbis'
        TabOrder = 3
        object LabelDAEOggCurQuality: TLabel
          Left = 32
          Top = 48
          Width = 116
          Height = 13
          Alignment = taRightJustify
          Caption = 'LabelDAEOggCurQuality'
        end
        object LabelDAEOgg1: TLabel
          Left = 16
          Top = 48
          Width = 39
          Height = 13
          Caption = 'Qualit'#228't:'
        end
        object TrackBarOgg: TTrackBar
          Left = 8
          Top = 16
          Width = 150
          Height = 33
          Position = 6
          TabOrder = 0
          OnChange = TrackBarChange
        end
      end
      object GroupBoxDAEMp3: TGroupBox
        Left = 8
        Top = 136
        Width = 209
        Height = 73
        Caption = 'mp3 (Lame-Preset)'
        TabOrder = 2
        object ComboBoxDAEMp3Quality: TComboBox
          Left = 8
          Top = 24
          Width = 145
          Height = 21
          ItemHeight = 0
          TabOrder = 0
        end
      end
      object GroupBoxDAECustom: TGroupBox
        Left = 232
        Top = 136
        Width = 209
        Height = 73
        Caption = 'benutzerdefiniert'
        TabOrder = 4
        object LabelCustomCmd: TLabel
          Left = 8
          Top = 16
          Width = 27
          Height = 13
          Caption = 'Cmd.:'
        end
        object LabelCustomOpt: TLabel
          Left = 8
          Top = 48
          Width = 23
          Height = 13
          Caption = 'Opt.:'
        end
        object EditCustomCmd: TEdit
          Left = 56
          Top = 16
          Width = 145
          Height = 21
          TabOrder = 0
          OnExit = EditExit
          OnKeyPress = EditKeyPress
        end
        object EditCustomOpt: TEdit
          Left = 56
          Top = 48
          Width = 145
          Height = 21
          TabOrder = 1
          OnKeyPress = EditKeyPress
        end
      end
    end
  end
  inline FrameTopBanner1: TFrameTopBanner
    Left = 0
    Top = 0
    Width = 481
    Height = 53
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
    TabStop = True
    ExplicitWidth = 481
    inherited Bevel1: TBevel
      Width = 481
      ExplicitWidth = 481
    end
    inherited PanelTop: TPanel
      Width = 481
      ExplicitWidth = 481
      inherited Image2: TImage
        Width = 306
        ExplicitWidth = 306
      end
      inherited LabelDescription: TLabel
        Width = 79
        ExplicitWidth = 79
      end
    end
  end
end
