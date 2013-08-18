object FormDataCDFS: TFormDataCDFS
  Left = 200
  Top = 108
  HelpContext = 1302
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'mkisofs - Optionen'
  ClientHeight = 463
  ClientWidth = 578
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
    578
    463)
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonCancel: TButton
    Left = 496
    Top = 432
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Abbrechen'
    ModalResult = 2
    TabOrder = 0
  end
  object ButtonOk: TButton
    Left = 416
    Top = 432
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 2
    OnClick = ButtonOkClick
  end
  object PageControlFileSystem: TPageControl
    Left = 8
    Top = 56
    Width = 561
    Height = 369
    ActivePage = TabSheetGeneral
    TabOrder = 1
    object TabSheetGeneral: TTabSheet
      Caption = 'Allgemein'
      object GroupBoxJoliet: TGroupBox
        Left = 8
        Top = 8
        Width = 265
        Height = 97
        Caption = 'Joliet-Dateisystem'
        TabOrder = 0
        object Label2: TLabel
          Left = 25
          Top = 70
          Width = 238
          Height = 25
          AutoSize = False
          Caption = 'Diese Option verletzt die Joliet-Spezifikation.'
          WordWrap = True
        end
        object CheckBoxJolietLong: TCheckBox
          Left = 8
          Top = 47
          Width = 254
          Height = 17
          Caption = 'Dateinamen mit 103 Zeichen erlauben'
          TabOrder = 1
        end
        object CheckBoxJoliet: TCheckBox
          Left = 8
          Top = 24
          Width = 254
          Height = 17
          Caption = 'Joliet-Dateisystem verwenden'
          TabOrder = 0
          OnClick = CheckBoxClick
        end
      end
      object GroupBoxDuplicateFiles: TGroupBox
        Left = 280
        Top = 8
        Width = 265
        Height = 49
        Caption = 'identische Dateien'
        TabOrder = 4
        object CheckBoxFindDups: TCheckBox
          Left = 8
          Top = 24
          Width = 254
          Height = 17
          Caption = 'identische Dateien suchen und verlinken'
          TabOrder = 0
        end
      end
      object GroupBoxUDF: TGroupBox
        Left = 8
        Top = 112
        Width = 265
        Height = 49
        Caption = 'UDF-Dateisystem'
        TabOrder = 1
        object CheckBoxUDF: TCheckBox
          Left = 8
          Top = 24
          Width = 249
          Height = 17
          Caption = 'UDF-Dateisystem verwenden'
          TabOrder = 0
        end
      end
      object GroupBoxRockRidge: TGroupBox
        Left = 8
        Top = 168
        Width = 265
        Height = 73
        Caption = 'Rock-Ridge-Dateisystem'
        TabOrder = 2
        object CheckBoxRockRidge: TCheckBox
          Left = 8
          Top = 24
          Width = 249
          Height = 17
          Hint = 'wird f'#252'r Multisession-CDs ben'#246'tigt'
          Caption = 'Rock-Ridge-Dateisystem verwenden'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnClick = CheckBoxClick
        end
        object CheckBoxRationalRock: TCheckBox
          Left = 32
          Top = 48
          Width = 230
          Height = 17
          Caption = 'Dateiattribute zur'#252'cksetzen'
          TabOrder = 1
        end
      end
      object GroupBoxBoot: TGroupBox
        Left = 280
        Top = 64
        Width = 265
        Height = 273
        Caption = 'Boot-Disk'
        TabOrder = 5
        object LabelBootLoadSegAdr: TLabel
          Left = 56
          Top = 119
          Width = 86
          Height = 13
          Caption = 'Segment-Adresse:'
        end
        object LabelBootLoadSize: TLabel
          Left = 56
          Top = 152
          Width = 81
          Height = 13
          Caption = 'Anzahl Sektoren:'
        end
        object ButtonBootImageSelect: TButton
          Left = 160
          Top = 240
          Width = 81
          Height = 25
          Caption = 'Auswahl'
          Enabled = False
          TabOrder = 8
          OnClick = ButtonBootImageSelectClick
        end
        object CheckBoxBoot: TCheckBox
          Left = 8
          Top = 24
          Width = 254
          Height = 17
          Caption = 'Boot-Disk erstellen'
          TabOrder = 0
          OnClick = CheckBoxClick
        end
        object CheckBoxBootCatHide: TCheckBox
          Left = 32
          Top = 72
          Width = 230
          Height = 17
          Caption = 'boot.catalog verstecken'
          Enabled = False
          TabOrder = 2
        end
        object StaticText1: TStaticText
          Left = 8
          Top = 216
          Width = 61
          Height = 17
          Caption = 'Boot-Image:'
          TabOrder = 9
        end
        object EditBootImage: TEdit
          Left = 8
          Top = 240
          Width = 145
          Height = 21
          Enabled = False
          TabOrder = 7
          OnKeyPress = EditKeyPress
        end
        object CheckBoxBootBinHide: TCheckBox
          Left = 32
          Top = 48
          Width = 230
          Height = 17
          Caption = 'Boot-Image verstecken'
          Enabled = False
          TabOrder = 1
        end
        object CheckBoxBootNoEmul: TCheckBox
          Left = 32
          Top = 96
          Width = 230
          Height = 17
          Caption = 'keine Disk-Emulation'
          TabOrder = 3
          OnClick = CheckBoxClick
        end
        object CheckBoxBootInfoTable: TCheckBox
          Left = 32
          Top = 184
          Width = 217
          Height = 17
          Caption = 'Boot-Info-Table erstellen'
          TabOrder = 6
        end
        object EditBootLoadSegAdr: TEdit
          Left = 168
          Top = 120
          Width = 65
          Height = 21
          TabOrder = 4
        end
        object EditBootLoadSize: TEdit
          Left = 168
          Top = 152
          Width = 65
          Height = 21
          TabOrder = 5
        end
      end
      object GroupBoxCharSet: TGroupBox
        Left = 8
        Top = 248
        Width = 265
        Height = 89
        Caption = 'Zeichensatz'
        TabOrder = 3
        object LabelCharsetIn: TLabel
          Left = 16
          Top = 24
          Width = 27
          Height = 13
          Caption = 'Input:'
        end
        object LabelCharsetOut: TLabel
          Left = 16
          Top = 56
          Width = 35
          Height = 13
          Caption = 'Output:'
        end
        object ComboBoxISOOutChar: TComboBox
          Left = 96
          Top = 56
          Width = 105
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
          OnKeyPress = EditKeyPress
          Items.Strings = (
            'cp437'
            'cp737'
            'cp775'
            'cp850'
            'cp852'
            'cp855'
            'cp857'
            'cp860'
            'cp861'
            'cp862'
            'cp863'
            'cp864'
            'cp865'
            'cp866'
            'cp869'
            'cp874'
            'cp1250'
            'cp1251'
            'cp10081'
            'cp10079'
            'cp10029'
            'cp10007'
            'cp10006'
            'cp10000'
            'iso8859-1'
            'iso8859-2'
            'iso8859-3'
            'iso8859-4'
            'iso8859-5'
            'iso8859-6'
            'iso8859-7'
            'iso8859-8'
            'iso8859-9'
            'iso8859-14'
            'iso8859-15'
            'koi8-u'
            'koi8-r')
        end
        object ComboBoxISOInChar: TComboBox
          Left = 96
          Top = 24
          Width = 105
          Height = 21
          ItemHeight = 13
          TabOrder = 0
        end
      end
    end
    object TabSheetISO: TTabSheet
      Caption = 'ISO9660'
      object GroupBoxISO: TGroupBox
        Left = 8
        Top = 8
        Width = 537
        Height = 273
        Caption = 'ISO-Dateisystem'
        TabOrder = 0
        object Label1: TLabel
          Left = 8
          Top = 96
          Width = 513
          Height = 13
          AutoSize = False
          Caption = 'Die folgenden Optionen versto'#223'en gegen den Standard ISO9660.'
          WordWrap = True
        end
        object CheckBoxISO31Chars: TCheckBox
          Left = 8
          Top = 24
          Width = 310
          Height = 17
          Caption = 'Dateinamen mit 31 Zeichen erlauben'
          TabOrder = 0
        end
        object CheckBoxISONoDot: TCheckBox
          Left = 24
          Top = 152
          Width = 257
          Height = 17
          Caption = 'Dateinamen ohne '#39'.'#39' zulassen'
          TabOrder = 4
        end
        object CheckBoxISODeepDir: TCheckBox
          Left = 296
          Top = 176
          Width = 233
          Height = 17
          Caption = 'tiefe Verzeichnisse nicht verschieben'
          TabOrder = 10
        end
        object CheckBoxISO37Chars: TCheckBox
          Left = 24
          Top = 128
          Width = 257
          Height = 17
          Caption = 'Dateinamen mit 37 Zeichen erlauben'
          TabOrder = 3
        end
        object CheckBoxISOStartDot: TCheckBox
          Left = 24
          Top = 176
          Width = 257
          Height = 17
          Caption = 'Dateinamen d'#252'rfen mit '#39'.'#39' beginnen'
          TabOrder = 5
        end
        object CheckBoxISOASCII: TCheckBox
          Left = 24
          Top = 224
          Width = 257
          Height = 17
          Caption = '7bit-ASCII-Zeichen erlauben (gro'#223')'
          TabOrder = 7
        end
        object CheckBoxISOLower: TCheckBox
          Left = 296
          Top = 128
          Width = 225
          Height = 17
          Caption = 'Kleinbuchstaben erlauben'
          TabOrder = 8
        end
        object CheckBoxISONoTrans: TCheckBox
          Left = 296
          Top = 152
          Width = 225
          Height = 17
          Caption = #39'#'#39' und '#39'~'#39' in Dateinamen zulassen'
          TabOrder = 9
        end
        object CheckBoxISOMultiDot: TCheckBox
          Left = 24
          Top = 200
          Width = 257
          Height = 17
          Caption = 'Dateinamen d'#252'rfen mehrere '#39'.'#39' enthalten'
          TabOrder = 6
        end
        object CheckBoxISOLevel: TCheckBox
          Left = 8
          Top = 48
          Width = 73
          Height = 17
          Caption = 'ISO-Level:'
          TabOrder = 1
          OnClick = CheckBoxClick
        end
        object ComboBoxISOLevel: TComboBox
          Left = 96
          Top = 48
          Width = 81
          Height = 21
          Style = csDropDownList
          Enabled = False
          ItemHeight = 13
          TabOrder = 2
          OnChange = CheckBoxClick
          OnKeyPress = EditKeyPress
          Items.Strings = (
            '1'
            '2'
            '3'
            '4')
        end
        object CheckBoxISONoVer: TCheckBox
          Left = 296
          Top = 200
          Width = 233
          Height = 17
          Caption = 'Dateinamen ohne Versionsnummern'
          TabOrder = 11
        end
      end
    end
    object TabSheetSpecial: TTabSheet
      Caption = 'Spezial'
      object GroupBoxMeta: TGroupBox
        Left = 8
        Top = 8
        Width = 265
        Height = 153
        Caption = 'Meta-Daten'
        TabOrder = 0
        object LabelPublisher: TLabel
          Left = 8
          Top = 48
          Width = 46
          Height = 13
          Caption = 'Publisher:'
        end
        object LabelPreparer: TLabel
          Left = 8
          Top = 72
          Width = 43
          Height = 13
          Caption = 'Preparer:'
        end
        object LabelCopyright: TLabel
          Left = 8
          Top = 96
          Width = 75
          Height = 13
          Caption = 'Copyright-Datei:'
        end
        object LabelSystem: TLabel
          Left = 8
          Top = 120
          Width = 37
          Height = 13
          Caption = 'System:'
        end
        object CheckBoxUseMeta: TCheckBox
          Left = 8
          Top = 24
          Width = 217
          Height = 17
          Caption = 'Meta-Daten verwenden'
          TabOrder = 0
          OnClick = CheckBoxClick
        end
        object EditPublisher: TEdit
          Left = 96
          Top = 48
          Width = 160
          Height = 21
          TabOrder = 1
          OnChange = EditChange
        end
        object EditPreparer: TEdit
          Left = 96
          Top = 72
          Width = 160
          Height = 21
          TabOrder = 2
          OnChange = EditChange
        end
        object EditCopyright: TEdit
          Left = 96
          Top = 96
          Width = 160
          Height = 21
          TabOrder = 3
          OnChange = EditChange
        end
        object EditSystem: TEdit
          Left = 96
          Top = 120
          Width = 160
          Height = 21
          TabOrder = 4
          OnChange = EditChange
        end
      end
      object GroupBoxSpecial: TGroupBox
        Left = 280
        Top = 8
        Width = 265
        Height = 153
        Caption = 'Spezielle Optionen'
        TabOrder = 1
        object CheckBoxTransTBL: TCheckBox
          Left = 8
          Top = 24
          Width = 241
          Height = 17
          Caption = #220'bersetzungstabellen (Trans.tbl) erstellen'
          TabOrder = 0
          OnClick = CheckBoxClick
        end
        object CheckBoxHideTransTBL: TCheckBox
          Left = 24
          Top = 48
          Width = 225
          Height = 17
          Caption = 'Trans.tbl unter Joliet verstecken'
          TabOrder = 1
        end
        object CheckBoxNLPathtables: TCheckBox
          Left = 8
          Top = 72
          Width = 241
          Height = 17
          Caption = 'Unbegrenzte Pfadtabellen'
          TabOrder = 2
        end
        object CheckBoxHideRRMoved: TCheckBox
          Left = 8
          Top = 96
          Width = 241
          Height = 17
          Caption = 'RR_MOVED verstecken'
          TabOrder = 3
        end
      end
    end
  end
  inline FrameTopBanner1: TFrameTopBanner
    Left = 0
    Top = 0
    Width = 578
    Height = 50
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
    TabStop = True
    ExplicitWidth = 578
    ExplicitHeight = 50
    inherited Bevel1: TBevel
      Top = 47
      Width = 578
      ExplicitTop = 47
      ExplicitWidth = 578
    end
    inherited PanelTop: TPanel
      Width = 578
      Height = 47
      ExplicitWidth = 578
      ExplicitHeight = 47
      inherited Image2: TImage
        Width = 403
        Height = 47
        ExplicitWidth = 403
        ExplicitHeight = 47
      end
      inherited LabelDescription: TLabel
        Width = 79
        ExplicitWidth = 79
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 368
    Top = 432
  end
end
