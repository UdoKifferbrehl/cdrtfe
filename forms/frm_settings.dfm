object FormSettings: TFormSettings
  Left = 200
  Top = 108
  HelpContext = 1200
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'cdrtools Frontend - Einstellungen'
  ClientHeight = 385
  ClientWidth = 489
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
    489
    385)
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonOk: TButton
    Left = 326
    Top = 352
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 0
    OnClick = ButtonOkClick
  end
  object ButtonCancel: TButton
    Left = 406
    Top = 352
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Abbrechen'
    ModalResult = 2
    TabOrder = 1
  end
  object PageControlSettings: TPageControl
    Left = 8
    Top = 56
    Width = 473
    Height = 289
    ActivePage = TabSheetCdrtfe
    TabOrder = 2
    object TabSheetCdrtfe: TTabSheet
      HelpContext = 1201
      Caption = 'cdrtfe'
      object GroupBoxShellExt: TGroupBox
        Left = 8
        Top = 8
        Width = 241
        Height = 129
        Caption = 'ShellExtensions'
        TabOrder = 0
        object CheckBoxShellExt: TCheckBox
          Left = 8
          Top = 24
          Width = 201
          Height = 17
          Caption = 'ShellExtensions verwenden'
          TabOrder = 0
        end
        object StaticText4: TStaticText
          Left = 8
          Top = 56
          Width = 209
          Height = 65
          AutoSize = False
          Caption = 
            'Sind die ShellExtensions aktiviert, k'#246'nnen Dateien und Ordner '#252'b' +
            'er das Kontextmen'#252' des Explorers direkt an cdrtfe gesendet werde' +
            'n.'
          TabOrder = 1
        end
      end
      object GroupBoxConfirm: TGroupBox
        Left = 8
        Top = 144
        Width = 241
        Height = 113
        Caption = 'Best'#228'tigung'
        TabOrder = 1
        object CheckBoxNoConfirm: TCheckBox
          Left = 8
          Top = 24
          Width = 220
          Height = 17
          Caption = 'Alle (!) Sicherheitsabfragen abschalten'
          TabOrder = 0
        end
        object StaticText2: TStaticText
          Left = 8
          Top = 56
          Width = 201
          Height = 41
          AutoSize = False
          Caption = 
            'Ein Klick auf '#39'Start'#39' f'#252'hrt die gew'#228'hlte Aktion sofort ohne weit' +
            'ere Nachfrage aus.'
          TabOrder = 1
        end
      end
      object GroupBoxSettings: TGroupBox
        Left = 256
        Top = 8
        Width = 201
        Height = 153
        Caption = 'Einstellungen speichern'
        TabOrder = 2
        object StaticText5: TStaticText
          Left = 8
          Top = 56
          Width = 185
          Height = 65
          AutoSize = False
          Caption = 
            'Die aktuellen Einstellungen (mit Ausnahme der Datei- Listen) k'#246'n' +
            'nen gespeichert werden.'
          TabOrder = 0
        end
        object ButtonSettingsSave: TButton
          Left = 8
          Top = 24
          Width = 75
          Height = 25
          Caption = 'speichern'
          TabOrder = 1
          OnClick = ButtonSettingsSaveClick
        end
        object ButtonSettingsDelete: TButton
          Left = 112
          Top = 24
          Width = 75
          Height = 25
          Caption = 'l'#246'schen'
          TabOrder = 2
          OnClick = ButtonSettingsDeleteClick
        end
        object CheckBoxAutoSaveOnExit: TCheckBox
          Left = 8
          Top = 128
          Width = 185
          Height = 17
          Caption = 'beim Beenden speichern'
          TabOrder = 3
        end
      end
      object GroupBoxTempFolder: TGroupBox
        Left = 256
        Top = 168
        Width = 201
        Height = 65
        Caption = 'tempor'#228're Dateien'
        TabOrder = 3
        object EditTempFolder: TEdit
          Left = 8
          Top = 24
          Width = 105
          Height = 21
          TabOrder = 0
          OnExit = EditTempFolderExit
          OnKeyPress = ComboBoxKeyPress
        end
        object ButtonTempFolderBrowse: TButton
          Left = 120
          Top = 24
          Width = 75
          Height = 25
          Caption = 'Auswahl'
          TabOrder = 1
          OnClick = ButtonTempFolderBrowseClick
        end
      end
    end
    object TabSheetDrives: TTabSheet
      HelpContext = 1206
      Caption = 'Laufwerke'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupBoxDetectSpeeds: TGroupBox
        Left = 8
        Top = 8
        Width = 449
        Height = 49
        Caption = 'Geschwindigkeiten'
        TabOrder = 0
        object CheckBoxDetectSpeeds: TCheckBox
          Left = 8
          Top = 24
          Width = 361
          Height = 17
          Caption = 'Verf'#252'gbare Geschwindigkeiten automatisch ermitteln'
          TabOrder = 0
        end
      end
      object GroupBoxSCSI: TGroupBox
        Left = 8
        Top = 64
        Width = 449
        Height = 49
        Caption = 'SCSI-Interface'
        TabOrder = 1
        object RadioButtonSCSIAuto: TRadioButton
          Left = 8
          Top = 24
          Width = 113
          Height = 17
          Caption = 'automatisch'
          TabOrder = 0
        end
        object RadioButtonSCSIASPI: TRadioButton
          Left = 150
          Top = 24
          Width = 113
          Height = 17
          Caption = 'ASPI'
          TabOrder = 1
        end
        object RadioButtonSCSISPTI: TRadioButton
          Left = 300
          Top = 24
          Width = 113
          Height = 17
          Caption = 'SPTI'
          TabOrder = 2
        end
      end
    end
    object TabSheetCdrecord: TTabSheet
      HelpContext = 1202
      Caption = 'cdrecord'
      object GroupBoxAdditionalCmdLineOptions: TGroupBox
        Left = 8
        Top = 120
        Width = 449
        Height = 137
        Caption = 'zus'#228'tzliche Kommandozeilenoptionen'
        TabOrder = 1
        object ComboBoxCdrecordCustOpts: TComboBox
          Left = 80
          Top = 24
          Width = 225
          Height = 21
          ItemHeight = 13
          TabOrder = 1
          OnExit = ComboBoxExit
          OnKeyPress = ComboBoxKeyPress
        end
        object ComboBoxMkisofsCustOpts: TComboBox
          Left = 80
          Top = 56
          Width = 225
          Height = 21
          ItemHeight = 13
          TabOrder = 4
          OnExit = ComboBoxExit
          OnKeyPress = ComboBoxKeyPress
        end
        object CheckBoxCdrecordCustOpts: TCheckBox
          Left = 8
          Top = 24
          Width = 65
          Height = 17
          Caption = 'cdrecord'
          TabOrder = 0
          OnClick = CheckBoxClick
        end
        object CheckBoxMkisofsCustOpts: TCheckBox
          Left = 8
          Top = 56
          Width = 65
          Height = 17
          Caption = 'mkisofs'
          TabOrder = 3
          OnClick = CheckBoxClick
        end
        object StaticText1: TStaticText
          Left = 8
          Top = 88
          Width = 425
          Height = 41
          AutoSize = False
          Caption = 
            'Diese Optionen werden beim Aufruf von cdrecord bzw. mkisofs der ' +
            'Kommandozeile hinzugef'#252'gt. Die Schaltfl'#228'che [x] l'#246'scht den aktue' +
            'llen Eintrag aus der Liste.'
          TabOrder = 6
        end
        object ButtonCdrecordCustOptDelete: TButton
          Left = 312
          Top = 24
          Width = 25
          Height = 17
          Caption = 'x'
          TabOrder = 2
          OnClick = ButtonCustOptDeleteClick
        end
        object ButtonMkisofsCustOptDelete: TButton
          Left = 312
          Top = 56
          Width = 25
          Height = 17
          Caption = 'x'
          TabOrder = 5
          OnClick = ButtonCustOptDeleteClick
        end
      end
      object GroupBoxOptionsCdrecord: TGroupBox
        Left = 8
        Top = 8
        Width = 449
        Height = 105
        Caption = 'weitere Optionen'
        TabOrder = 0
        object LabelFIFOSize: TLabel
          Left = 356
          Top = 80
          Width = 69
          Height = 13
          Alignment = taRightJustify
          Caption = 'LabelFIFOSize'
        end
        object CheckBoxCdrecordVerbose: TCheckBox
          Left = 8
          Top = 24
          Width = 193
          Height = 17
          Caption = 'ausf'#252'hrlichere Ausgaben (-v)'
          TabOrder = 0
        end
        object CheckBoxCdrecordBurnfree: TCheckBox
          Left = 8
          Top = 48
          Width = 193
          Height = 17
          Caption = 'Burnfree verwenden'
          TabOrder = 1
        end
        object CheckBoxCdrecordSimulDrv: TCheckBox
          Left = 8
          Top = 72
          Width = 193
          Height = 17
          Caption = 'Simulations-Treiber (Timing-Tests)'
          TabOrder = 2
        end
        object TrackBarFIFOSize: TTrackBar
          Left = 248
          Top = 48
          Width = 190
          Height = 33
          Ctl3D = True
          Max = 128
          Min = 4
          ParentCtl3D = False
          Frequency = 16
          Position = 4
          TabOrder = 4
          OnChange = TrackBarFIFOSizeChange
        end
        object CheckBoxCdrecordFIFO: TCheckBox
          Left = 232
          Top = 24
          Width = 209
          Height = 17
          Caption = 'Gr'#246#223'e des FIFO-Puffers festlegen'
          TabOrder = 3
          OnClick = CheckBoxClick
        end
      end
    end
    object TabSheetCdrecord2: TTabSheet
      HelpContext = 1203
      Caption = 'cdrecord (2)'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupBoxCdrecordWritingSpeed: TGroupBox
        Left = 8
        Top = 8
        Width = 449
        Height = 49
        Caption = 'Schreibgeschwindigkeit'
        TabOrder = 0
        object CheckBoxCdrecordAllowHigherSpeed: TCheckBox
          Left = 8
          Top = 24
          Width = 433
          Height = 17
          Caption = 'Schreibgeschwindigkeit bis zu Drive-DMA-Geschwindigkeit erlauben'
          TabOrder = 0
        end
      end
      object GroupBoxCdrecordEject: TGroupBox
        Left = 8
        Top = 64
        Width = 449
        Height = 49
        Caption = 'Eject'
        TabOrder = 1
        object CheckBoxCdrecordEject: TCheckBox
          Left = 8
          Top = 24
          Width = 425
          Height = 17
          Caption = 'CD/DVD automatisch auswerfen'
          TabOrder = 0
        end
      end
      object GroupBoxAutoErase: TGroupBox
        Left = 8
        Top = 120
        Width = 449
        Height = 81
        Caption = 'automatisches L'#246'schen'
        TabOrder = 2
        object RadioButtonAutoEraseDisabled: TRadioButton
          Left = 8
          Top = 24
          Width = 113
          Height = 17
          Caption = 'deaktiviert'
          TabOrder = 0
        end
        object RadioButtonAutoErase: TRadioButton
          Left = 8
          Top = 48
          Width = 425
          Height = 17
          Caption = 'CD-RWs und DVD-RWs automatisch l'#246'schen.'
          TabOrder = 1
        end
      end
      object GroupBoxCdrecordFormat: TGroupBox
        Left = 8
        Top = 208
        Width = 449
        Height = 49
        Caption = 'DVD+RW formatieren'
        TabOrder = 3
        object CheckBoxCdrecordFormat: TCheckBox
          Left = 8
          Top = 24
          Width = 417
          Height = 17
          Caption = 'Separaten cdrecord-Aufruf zum Formatieren verwenden.'
          TabOrder = 0
        end
      end
    end
    object TabSheetCdrdao: TTabSheet
      HelpContext = 1204
      Caption = 'cdrdao'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupBoxCdrdaoDriver: TGroupBox
        Left = 8
        Top = 64
        Width = 449
        Height = 73
        Caption = 'cdrdao - Treiber'
        TabOrder = 0
        object CheckBoxForceGenericMMC: TCheckBox
          Left = 8
          Top = 24
          Width = 337
          Height = 17
          Caption = 'Treiber '#39'generic-mmc'#39' verwenden'
          TabOrder = 0
          OnClick = CheckBoxClick
        end
        object CheckBoxForceGenericMMCRaw: TCheckBox
          Left = 8
          Top = 48
          Width = 337
          Height = 17
          Caption = 'Treiber '#39'generic-mmc-raw'#39' verwenden'
          TabOrder = 1
          OnClick = CheckBoxClick
        end
      end
      object GroupBoxCdrdaoCue: TGroupBox
        Left = 8
        Top = 8
        Width = 449
        Height = 49
        Caption = 'CUE-Images'
        TabOrder = 1
        object CheckBoxCdrdaoCueImage: TCheckBox
          Left = 8
          Top = 24
          Width = 329
          Height = 17
          Caption = 'CUE-Images mit cdrdao schreiben'
          TabOrder = 0
        end
      end
    end
    object TabSheetAudioCD: TTabSheet
      HelpContext = 1205
      Caption = 'Audio-CD'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupBoxAudioCDText: TGroupBox
        Left = 8
        Top = 8
        Width = 449
        Height = 129
        Caption = 'CD-Text'
        TabOrder = 0
        object RadioButtonCDTextUseTags: TRadioButton
          Left = 8
          Top = 24
          Width = 417
          Height = 17
          Caption = 'Tags verwenden'
          TabOrder = 0
          OnClick = CheckBoxClick
        end
        object RadioButtonCDTextUseName: TRadioButton
          Left = 8
          Top = 48
          Width = 417
          Height = 17
          Caption = 'Dateinamen verwenden'
          TabOrder = 1
          OnClick = CheckBoxClick
        end
        object PanelCDText: TPanel
          Left = 24
          Top = 64
          Width = 409
          Height = 57
          BevelOuter = bvNone
          TabOrder = 2
          object RadioButtonCDTextPT: TRadioButton
            Left = 16
            Top = 8
            Width = 393
            Height = 17
            Caption = '<Interpret> - <Titel>'
            TabOrder = 0
          end
          object RadioButtonCDTextTP: TRadioButton
            Left = 16
            Top = 32
            Width = 393
            Height = 17
            Caption = '<Titel> - <Interpret>'
            TabOrder = 1
          end
        end
      end
      object GroupBoxMPlayer: TGroupBox
        Left = 8
        Top = 144
        Width = 449
        Height = 73
        Caption = 'externes Abspielprogramm'
        TabOrder = 1
        object LabelMPlayerCmd: TLabel
          Left = 8
          Top = 24
          Width = 50
          Height = 13
          Caption = 'Programm:'
        end
        object LabelMPlayerOpt: TLabel
          Left = 240
          Top = 24
          Width = 46
          Height = 13
          Caption = 'Optionen:'
        end
        object EditMPlayerCmd: TEdit
          Left = 8
          Top = 40
          Width = 201
          Height = 21
          TabOrder = 0
        end
        object EditMplayerOpt: TEdit
          Left = 240
          Top = 40
          Width = 201
          Height = 21
          TabOrder = 1
        end
      end
    end
    object TabSheetCygwin: TTabSheet
      Caption = 'Cygwin'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupBoxCygwinDLL: TGroupBox
        Left = 8
        Top = 8
        Width = 449
        Height = 113
        Caption = 'cygwin1.dll'
        TabOrder = 0
        object LabelUseDLL: TLabel
          Left = 16
          Top = 72
          Width = 425
          Height = 33
          AutoSize = False
          Caption = 
            'Eine Ver'#228'nderung dieser Einstellung wird erst nach einem erneute' +
            'n Start des Programms wirksam.'
          WordWrap = True
        end
        object RadioButtonUseOwnDLL: TRadioButton
          Left = 16
          Top = 24
          Width = 425
          Height = 17
          Caption = 'Die Verwendung der mitgelieferten DLL erzwingen.'
          TabOrder = 0
        end
        object RadioButtonUseSearchPathDLL: TRadioButton
          Left = 16
          Top = 48
          Width = 425
          Height = 17
          Caption = 'DLL aus dem Suchpfad verwenden, falls vorhanden.'
          TabOrder = 1
        end
      end
    end
  end
  inline FrameTopBanner1: TFrameTopBanner
    Left = 0
    Top = 0
    Width = 489
    Height = 53
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
    TabStop = True
    ExplicitWidth = 489
    inherited Bevel1: TBevel
      Width = 489
      ExplicitWidth = 489
    end
    inherited PanelTop: TPanel
      Width = 489
      ExplicitWidth = 489
      inherited Image2: TImage
        Width = 314
        ExplicitWidth = 314
      end
      inherited LabelDescription: TLabel
        Width = 79
        ExplicitWidth = 79
      end
    end
  end
end
