object CdrtfeMainForm: TCdrtfeMainForm
  Left = 199
  Top = 114
  HelpContext = 1100
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Caption = 'cdrtools Frontend'
  ClientHeight = 486
  ClientWidth = 745
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDblClick = FormDblClick
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    745
    486)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 560
    Top = 232
    Width = 177
    Height = 9
    Anchors = [akTop, akRight]
    Shape = bsTopLine
    Visible = False
  end
  object Bevel4: TBevel
    Left = 0
    Top = 0
    Width = 745
    Height = 4
    Anchors = [akLeft, akTop, akRight]
    Shape = bsTopLine
  end
  object SpeedButtonFixCD: TSpeedButton
    Left = 672
    Top = 120
    Width = 65
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'CD fixieren'
    OnClick = SpeedButtonFixCDClick
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 546
    Height = 305
    ActivePage = TabSheet1
    Anchors = [akLeft, akTop, akRight, akBottom]
    MultiLine = True
    TabOrder = 0
    OnChange = PageControl1Change
    object TabSheet1: TTabSheet
      HelpContext = 1300
      Caption = 'Daten-CD'
      DesignSize = (
        538
        277)
      object CDESpeedButton1: TSpeedButton
        Left = 512
        Top = 32
        Width = 25
        Height = 25
        Hint = 'Datei hinzuf'#252'gen'
        Anchors = [akTop, akRight]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = CDESpeedButton1Click
      end
      object CDESpeedButton2: TSpeedButton
        Left = 512
        Top = 57
        Width = 25
        Height = 25
        Hint = 'Ordner hinzuf'#252'gen'
        Anchors = [akTop, akRight]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = CDESpeedButton2Click
      end
      object CDESpeedButton3: TSpeedButton
        Left = 512
        Top = 96
        Width = 25
        Height = 25
        Hint = 'Datei entfernen'
        Anchors = [akTop, akRight]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = CDESpeedButton3Click
      end
      object CDESpeedButton4: TSpeedButton
        Left = 512
        Top = 121
        Width = 25
        Height = 25
        Hint = 'Ordner entfernen'
        Anchors = [akTop, akRight]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = CDESpeedButton4Click
      end
      object CDESpeedButton5: TSpeedButton
        Left = 512
        Top = 153
        Width = 25
        Height = 25
        Hint = 'Alles entfernen'
        Anchors = [akTop, akRight]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = CDESpeedButton5Click
      end
      object PanelDataCD: TPanel
        Left = 8
        Top = 208
        Width = 497
        Height = 65
        Anchors = [akLeft, akRight, akBottom]
        BevelOuter = bvNone
        TabOrder = 0
        DesignSize = (
          497
          65)
        object Sheet1SpeedButtonCheckFS: TSpeedButton
          Left = 80
          Top = 0
          Width = 25
          Height = 25
          Hint = 'Dateisystem der CD pr'#252'fen'
          ParentShowHint = False
          ShowHint = True
          OnClick = Sheet1SpeedButtonCheckFSClick
        end
        object ButtonDataCDOptionsFS: TButton
          Left = 0
          Top = 0
          Width = 75
          Height = 25
          Caption = 'Dateisystem'
          TabOrder = 0
          OnClick = ButtonDataCDOptionsFSClick
        end
        object ButtonDataCDOptions: TButton
          Left = 0
          Top = 40
          Width = 75
          Height = 25
          Caption = 'CD Optionen'
          TabOrder = 1
          OnClick = ButtonDataCDOptionsClick
        end
        object CheckBoxDataCDVerify: TCheckBox
          Left = 88
          Top = 48
          Width = 73
          Height = 17
          Caption = 'Verify'
          PopupMenu = MiscPopupMenu
          TabOrder = 2
        end
        object PanelDataCDOptions: TPanel
          Left = 200
          Top = 0
          Width = 297
          Height = 65
          Anchors = [akRight, akBottom]
          BevelOuter = bvLowered
          TabOrder = 3
          object LabelDataCDSingle: TLabel
            Left = 8
            Top = 8
            Width = 62
            Height = 13
            Caption = 'singlesession'
            Color = clBtnFace
            ParentColor = False
          end
          object LabelDataCDMulti: TLabel
            Left = 8
            Top = 24
            Width = 56
            Height = 13
            Caption = 'multisession'
          end
          object LabelDataCDOTF: TLabel
            Left = 8
            Top = 40
            Width = 43
            Height = 13
            Caption = 'on-the-fly'
          end
          object LabelDataCDTAO: TLabel
            Left = 88
            Top = 8
            Width = 22
            Height = 13
            Caption = 'TAO'
          end
          object LabelDataCDDAO: TLabel
            Left = 88
            Top = 24
            Width = 23
            Height = 13
            Caption = 'DAO'
          end
          object LabelDataCDRAW: TLabel
            Left = 88
            Top = 40
            Width = 26
            Height = 13
            Caption = 'RAW'
          end
          object LabelDataCDJoliet: TLabel
            Left = 128
            Top = 8
            Width = 24
            Height = 13
            Caption = 'Joliet'
          end
          object LabelDataCDRockRidge: TLabel
            Left = 128
            Top = 24
            Width = 54
            Height = 13
            Caption = 'RockRidge'
          end
          object LabelDataCDUDF: TLabel
            Left = 128
            Top = 40
            Width = 22
            Height = 13
            Caption = 'UDF'
          end
          object LabelDataCDISOLevel: TLabel
            Left = 200
            Top = 8
            Width = 47
            Height = 13
            Caption = 'ISO-Level'
          end
          object LabelDataCDBoot: TLabel
            Left = 200
            Top = 24
            Width = 21
            Height = 13
            Caption = 'boot'
          end
          object Label12: TLabel
            Left = 200
            Top = 40
            Width = 3
            Height = 13
          end
          object LabelDataCDOverburn: TLabel
            Left = 200
            Top = 40
            Width = 62
            Height = 13
            Caption = #220'berbrennen'
          end
        end
      end
      object PanelDataCDView: TPanel
        Left = 8
        Top = 8
        Width = 497
        Height = 193
        Anchors = [akLeft, akTop, akRight, akBottom]
        BevelOuter = bvNone
        TabOrder = 1
        object SplitterDataCD: TSplitter
          Left = 200
          Top = 0
          Height = 193
          MinSize = 150
        end
        object CDETreeView: TTreeView
          Left = 0
          Top = 0
          Width = 200
          Height = 193
          Align = alLeft
          DragMode = dmAutomatic
          HideSelection = False
          Indent = 19
          PopupMenu = CDETreeViewPopupMenu
          TabOrder = 0
          OnChange = TreeViewChange
          OnDragDrop = TreeViewDragDrop
          OnDragOver = TreeViewDragOver
          OnEdited = TreeViewEdited
          OnExpanding = TreeViewExpanding
          OnKeyDown = TreeViewKeyDown
          OnMouseDown = TreeViewMouseDown
        end
        object CDEListView: TListView
          Left = 203
          Top = 0
          Width = 294
          Height = 193
          Align = alClient
          Columns = <
            item
              Caption = 'Name'
              Width = 120
            end
            item
              Alignment = taRightJustify
              Caption = 'Gr'#246#223'e'
              Width = 80
            end
            item
              Caption = 'Typ'
              Width = 120
            end
            item
              Caption = 'Herkunft'
              Width = 300
            end>
          DragMode = dmAutomatic
          HideSelection = False
          MultiSelect = True
          PopupMenu = CDEListViewPopupMenu
          TabOrder = 1
          ViewStyle = vsReport
          OnDblClick = ListViewDblClick
          OnEdited = ListViewEdited
          OnDragDrop = CDEListViewDragDrop
          OnDragOver = CDEListViewDragOver
          OnKeyDown = ListViewKeyDown
        end
      end
    end
    object TabSheet2: TTabSheet
      HelpContext = 1400
      Caption = 'Audio-CD'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        538
        277)
      object AudioSpeedButton1: TSpeedButton
        Left = 512
        Top = 32
        Width = 25
        Height = 25
        Hint = 'Track hinzuf'#252'gen'
        Anchors = [akTop, akRight]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = AudioSpeedButton1Click
      end
      object AudioSpeedButton2: TSpeedButton
        Left = 512
        Top = 64
        Width = 25
        Height = 25
        Hint = 'Track nach oben verschieben'
        Anchors = [akTop, akRight]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = AudioSpeedButton2Click
      end
      object AudioSpeedButton3: TSpeedButton
        Left = 512
        Top = 89
        Width = 25
        Height = 25
        Hint = 'Track nach unten verschieben'
        Anchors = [akTop, akRight]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = AudioSpeedButton3Click
      end
      object AudioSpeedButton4: TSpeedButton
        Left = 512
        Top = 128
        Width = 25
        Height = 25
        Hint = 'Track entfernen'
        Anchors = [akTop, akRight]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = AudioSpeedButton4Click
      end
      object AudioListView: TListView
        Left = 8
        Top = 8
        Width = 497
        Height = 193
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = 'Name'
            Width = 150
          end
          item
            Alignment = taRightJustify
            Caption = 'L'#228'nge'
            Width = 60
          end
          item
            Alignment = taRightJustify
            Caption = 'Gr'#246#223'e'
            Width = 80
          end
          item
            Caption = 'Herkunft'
            Width = 400
          end>
        HideSelection = False
        MultiSelect = True
        PopupMenu = AudioListViewPopupMenu
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = ListViewDblClick
        OnEditing = AudioListViewEditing
        OnDragDrop = CDEListViewDragDrop
        OnDragOver = CDEListViewDragOver
        OnKeyDown = AudioListViewKeyDown
      end
      object PanelAudioCD: TPanel
        Left = 8
        Top = 208
        Width = 497
        Height = 65
        Anchors = [akLeft, akRight, akBottom]
        BevelOuter = bvNone
        TabOrder = 1
        DesignSize = (
          497
          65)
        object ButtonAudioCDOptions: TButton
          Left = 0
          Top = 40
          Width = 75
          Height = 25
          Caption = 'Optionen'
          TabOrder = 0
          OnClick = ButtonAudioCDOptionsClick
        end
        object PanelAudioCDOptions: TPanel
          Left = 200
          Top = 0
          Width = 297
          Height = 65
          Anchors = [akRight, akBottom]
          BevelOuter = bvLowered
          TabOrder = 1
          object LabelAudioCDSingle: TLabel
            Left = 8
            Top = 8
            Width = 62
            Height = 13
            Caption = 'singlesession'
          end
          object LabelAudioCDMulti: TLabel
            Left = 8
            Top = 24
            Width = 86
            Height = 13
            Caption = 'multisession (CD+)'
          end
          object LabelAudioCDOverburn: TLabel
            Left = 8
            Top = 40
            Width = 62
            Height = 13
            Caption = #220'berbrennen'
          end
          object LabelAudioCDTAO: TLabel
            Left = 120
            Top = 8
            Width = 22
            Height = 13
            Caption = 'TAO'
          end
          object LabelAudioCDDAO: TLabel
            Left = 120
            Top = 24
            Width = 23
            Height = 13
            Caption = 'DAO'
          end
          object LabelAudioCDRAW: TLabel
            Left = 120
            Top = 40
            Width = 26
            Height = 13
            Caption = 'RAW'
          end
          object LabelAudioCDPreemp: TLabel
            Left = 168
            Top = 8
            Width = 60
            Height = 13
            Caption = 'Preemphasis'
          end
          object LabelAudioCDUseInfo: TLabel
            Left = 168
            Top = 24
            Width = 58
            Height = 13
            Caption = 'Info-Dateien'
          end
          object LabelAudioCDText: TLabel
            Left = 168
            Top = 40
            Width = 39
            Height = 13
            Caption = 'CD-Text'
          end
        end
        object ButtonAudioCDTracks: TButton
          Left = 0
          Top = 0
          Width = 75
          Height = 25
          Caption = 'Tracks'
          TabOrder = 2
          OnClick = ButtonAudioCDTracksClick
        end
      end
    end
    object TabSheet3: TTabSheet
      HelpContext = 1500
      Caption = 'XCD'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        538
        277)
      object XCDESpeedButton1: TSpeedButton
        Left = 512
        Top = 32
        Width = 25
        Height = 25
        Hint = 'Datei hinzuf'#252'gen'
        Anchors = [akTop, akRight]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = XCDESpeedButton1Click
      end
      object XCDESpeedButton2: TSpeedButton
        Left = 512
        Top = 57
        Width = 25
        Height = 25
        Hint = 'Ordner hinzuf'#252'gen'
        Anchors = [akTop, akRight]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = XCDESpeedButton2Click
      end
      object XCDESpeedButton3: TSpeedButton
        Left = 512
        Top = 88
        Width = 25
        Height = 25
        Hint = 'Datei entfernen'
        Anchors = [akTop, akRight]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = XCDESpeedButton3Click
      end
      object XCDESpeedButton4: TSpeedButton
        Left = 512
        Top = 152
        Width = 25
        Height = 25
        Hint = 'Movie (als Form2) hinzuf'#252'gen'
        Anchors = [akRight, akBottom]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = XCDESpeedButton4Click
      end
      object XCDESpeedButton5: TSpeedButton
        Left = 512
        Top = 184
        Width = 25
        Height = 25
        Hint = 'Movie entfernen'
        Anchors = [akRight, akBottom]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = XCDESpeedButton5Click
      end
      object XCDESpeedButton6: TSpeedButton
        Left = 480
        Top = 248
        Width = 25
        Height = 25
        Hint = 'Ordner entfernen'
        Anchors = [akRight, akBottom]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = XCDESpeedButton6Click
      end
      object XCDESpeedButton7: TSpeedButton
        Left = 512
        Top = 248
        Width = 25
        Height = 25
        Hint = 'Alles entfernen'
        Anchors = [akRight, akBottom]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = XCDESpeedButton7Click
      end
      object PanelXCDView: TPanel
        Left = 8
        Top = 8
        Width = 497
        Height = 235
        Anchors = [akLeft, akTop, akRight, akBottom]
        BevelOuter = bvNone
        TabOrder = 1
        object SplitterXCDVertical: TSplitter
          Left = 200
          Top = 0
          Height = 235
          MinSize = 200
        end
        object PanelXCDViewLeft: TPanel
          Left = 0
          Top = 0
          Width = 200
          Height = 235
          Align = alLeft
          BevelOuter = bvNone
          TabOrder = 0
          object XCDETreeView: TTreeView
            Left = 0
            Top = 0
            Width = 200
            Height = 161
            Align = alTop
            DragMode = dmAutomatic
            HideSelection = False
            Indent = 19
            PopupMenu = CDETreeViewPopupMenu
            TabOrder = 0
            OnChange = TreeViewChange
            OnDragDrop = TreeViewDragDrop
            OnDragOver = TreeViewDragOver
            OnEdited = TreeViewEdited
            OnExpanding = TreeViewExpanding
            OnKeyDown = TreeViewKeyDown
            OnMouseDown = TreeViewMouseDown
          end
        end
        object PanelXCDViewRight: TPanel
          Left = 203
          Top = 0
          Width = 294
          Height = 235
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          object SplitterXCDHorizontal: TSplitter
            Left = 0
            Top = 115
            Width = 294
            Height = 3
            Cursor = crVSplit
            Align = alTop
          end
          object XCDEListView1: TListView
            Left = 0
            Top = 0
            Width = 294
            Height = 115
            Align = alTop
            Columns = <
              item
                Caption = 'Name (Form 1)'
                Width = 120
              end
              item
                Alignment = taRightJustify
                Caption = 'Gr'#246#223'e'
                Width = 80
              end
              item
                Caption = 'Typ'
                Width = 120
              end
              item
                Caption = 'Herkunft'
                Width = 300
              end>
            DragMode = dmAutomatic
            HideSelection = False
            MultiSelect = True
            PopupMenu = CDEListViewPopupMenu
            TabOrder = 0
            ViewStyle = vsReport
            OnDblClick = ListViewDblClick
            OnEdited = ListViewEdited
            OnEditing = XCDEListView1Editing
            OnDragDrop = XCDEListView1DragDrop
            OnDragOver = XCDEListView1DragOver
            OnKeyDown = ListViewKeyDown
          end
          object XCDEListView2: TListView
            Left = 0
            Top = 118
            Width = 294
            Height = 117
            Align = alClient
            Columns = <
              item
                Caption = 'Name (Form 2)'
                Width = 120
              end
              item
                Alignment = taRightJustify
                Caption = 'Gr'#246#223'e'
                Width = 80
              end
              item
                Caption = 'Typ'
                Width = 120
              end
              item
                Caption = 'Herkunft'
                Width = 300
              end>
            DragMode = dmAutomatic
            HideSelection = False
            MultiSelect = True
            PopupMenu = CDEListViewPopupMenu
            TabOrder = 1
            ViewStyle = vsReport
            OnDblClick = ListViewDblClick
            OnEdited = ListViewEdited
            OnEditing = XCDEListView1Editing
            OnDragDrop = XCDEListView1DragDrop
            OnDragOver = XCDEListView1DragOver
            OnKeyDown = ListViewKeyDown
          end
        end
      end
      object PanelXCD: TPanel
        Left = 8
        Top = 176
        Width = 200
        Height = 97
        Anchors = [akLeft, akBottom]
        BevelOuter = bvNone
        TabOrder = 0
        DesignSize = (
          200
          97)
        object ButtonXCDOptions: TButton
          Left = 0
          Top = 72
          Width = 75
          Height = 25
          Anchors = [akLeft, akBottom]
          Caption = 'Optionen'
          TabOrder = 0
          OnClick = ButtonXCDOptionsClick
        end
        object PanelXCDOptions: TPanel
          Left = 0
          Top = 0
          Width = 200
          Height = 65
          BevelOuter = bvLowered
          TabOrder = 1
          object LabelXCDSingle: TLabel
            Left = 8
            Top = 8
            Width = 54
            Height = 13
            Caption = 'single-track'
          end
          object LabelXCDIsoLEvel1: TLabel
            Left = 8
            Top = 24
            Width = 56
            Height = 13
            Caption = 'ISO-Level 1'
          end
          object LabelXCDIsoLevel2: TLabel
            Left = 8
            Top = 40
            Width = 56
            Height = 13
            Caption = 'ISO-Level 2'
          end
          object LabelXCDKeepExt: TLabel
            Left = 80
            Top = 8
            Width = 105
            Height = 13
            Caption = 'Dateiendung behalten'
          end
          object LabelXCDOverburn: TLabel
            Left = 80
            Top = 24
            Width = 62
            Height = 13
            Caption = #220'berbrennen'
          end
          object LabelXCDCreateInfoFile: TLabel
            Left = 80
            Top = 40
            Width = 46
            Height = 13
            Caption = 'Info-Datei'
          end
        end
        object CheckBoxXCDVerify: TCheckBox
          Left = 88
          Top = 80
          Width = 97
          Height = 17
          Anchors = [akLeft, akBottom]
          Caption = 'Verify'
          PopupMenu = MiscPopupMenu
          TabOrder = 2
        end
      end
    end
    object TabSheet4: TTabSheet
      HelpContext = 1600
      Caption = 'CD-RW'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        538
        277)
      object GroupBoxCDRWDelete: TGroupBox
        Left = 136
        Top = 31
        Width = 265
        Height = 177
        Anchors = []
        Caption = 'CD-RW l'#246'schen'
        TabOrder = 0
        object RadioButtonCDRWBlankAll: TRadioButton
          Left = 24
          Top = 32
          Width = 233
          Height = 17
          Caption = 'gesamte CD l'#246'schen'
          TabOrder = 0
        end
        object RadioButtonCDRWBlankFast: TRadioButton
          Left = 24
          Top = 56
          Width = 233
          Height = 17
          Caption = 'Schnelll'#246'schung (PMA, TOC, pregap)'
          TabOrder = 1
        end
        object RadioButtonCDRWBlankOpenSession: TRadioButton
          Left = 24
          Top = 80
          Width = 233
          Height = 17
          Caption = 'letzte Session '#246'ffnen'
          TabOrder = 2
        end
        object RadioButtonCDRWBlankSession: TRadioButton
          Left = 24
          Top = 104
          Width = 233
          Height = 17
          Caption = 'letzte Session l'#246'schen'
          TabOrder = 3
        end
        object CheckBoxCDRWBlankForce: TCheckBox
          Left = 24
          Top = 144
          Width = 233
          Height = 17
          Caption = 'L'#246'schen erzwingen'
          TabOrder = 4
        end
      end
    end
    object TabSheet5: TTabSheet
      HelpContext = 1700
      Caption = 'CD-Infos'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        538
        277)
      object GroupBoxCDInfo: TGroupBox
        Left = 112
        Top = 33
        Width = 313
        Height = 193
        Anchors = []
        Caption = 'Aktion ausw'#228'hlen'
        TabOrder = 0
        object RadioButtonToc: TRadioButton
          Left = 168
          Top = 32
          Width = 137
          Height = 17
          Caption = 'TOC anzeigen'
          TabOrder = 2
        end
        object RadioButtonAtip: TRadioButton
          Left = 168
          Top = 64
          Width = 137
          Height = 17
          Caption = 'ATIP anzeigen'
          TabOrder = 3
        end
        object RadioButtonMSInfo: TRadioButton
          Left = 168
          Top = 96
          Width = 137
          Height = 17
          Caption = 'Multisession-Info'
          TabOrder = 4
        end
        object RadioButtonScanbus: TRadioButton
          Left = 24
          Top = 32
          Width = 137
          Height = 17
          Caption = 'SCSI-Bus-Scan'
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object RadioButtonPrcap: TRadioButton
          Left = 24
          Top = 64
          Width = 137
          Height = 17
          Caption = 'Ger'#228'teinfo'
          TabOrder = 1
        end
        object RadioButtonCapacity: TRadioButton
          Left = 168
          Top = 160
          Width = 137
          Height = 17
          Caption = 'Kapazit'#228't anzeigen'
          TabOrder = 5
        end
        object RadioButtonMInfo: TRadioButton
          Left = 168
          Top = 128
          Width = 113
          Height = 17
          Caption = 'Disk Informationen'
          TabOrder = 6
        end
      end
    end
    object TabSheet6: TTabSheet
      HelpContext = 1800
      Caption = 'DAE'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        538
        277)
      object DAEListView: TListView
        Left = 8
        Top = 8
        Width = 497
        Height = 193
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = 'Track'
            Width = 250
          end
          item
            Alignment = taRightJustify
            Caption = 'L'#228'nge'
            Width = 60
          end
          item
            Alignment = taRightJustify
            Caption = 'Gr'#246#223'e'
            Width = 80
          end>
        HideSelection = False
        MultiSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnEditing = DAEListViewEditing
        OnKeyDown = DAEListViewKeyDown
      end
      object PanelDAE: TPanel
        Left = 8
        Top = 208
        Width = 497
        Height = 65
        Anchors = [akLeft, akRight, akBottom]
        BevelOuter = bvNone
        TabOrder = 1
        DesignSize = (
          497
          65)
        object Label1: TLabel
          Left = 96
          Top = 0
          Width = 109
          Height = 13
          Caption = 'Tracks speichern unter'
        end
        object ButtonDAEOptions: TButton
          Left = 0
          Top = 40
          Width = 75
          Height = 25
          Caption = 'Optionen'
          TabOrder = 0
          OnClick = ButtonDAEOptionsClick
        end
        object ButtonDAEReadToc: TButton
          Left = 0
          Top = 0
          Width = 75
          Height = 25
          Caption = 'TOC einlesen'
          TabOrder = 1
          OnClick = ButtonDAEReadTocClick
        end
        object EditDAEPath: TEdit
          Left = 96
          Top = 16
          Width = 113
          Height = 21
          TabOrder = 2
          OnKeyPress = EditKeyPress
        end
        object ButtonDAESelectPath: TButton
          Left = 96
          Top = 40
          Width = 65
          Height = 25
          Caption = 'Auswahl'
          TabOrder = 3
          OnClick = ButtonDAESelectPathClick
        end
        object PanelDAEOptions: TPanel
          Left = 280
          Top = 0
          Width = 217
          Height = 65
          Anchors = [akRight, akBottom]
          BevelOuter = bvLowered
          TabOrder = 4
          object LabelDAEBulk: TLabel
            Left = 8
            Top = 8
            Width = 63
            Height = 13
            Caption = 'Einzeldateien'
          end
          object LabelDAEParanoia: TLabel
            Left = 8
            Top = 24
            Width = 41
            Height = 13
            Caption = 'paranoia'
          end
          object LabelDAEInfoFiles: TLabel
            Left = 8
            Top = 40
            Width = 58
            Height = 13
            Caption = 'Info-Dateien'
          end
          object LabelDAECDDB: TLabel
            Left = 96
            Top = 8
            Width = 30
            Height = 13
            Caption = 'freedb'
          end
          object LabelDAEMp3: TLabel
            Left = 152
            Top = 8
            Width = 20
            Height = 13
            Caption = 'mp3'
          end
          object LabelDAEOgg: TLabel
            Left = 152
            Top = 24
            Width = 52
            Height = 13
            Caption = 'Ogg Vorbis'
          end
          object LabelDAEFlac: TLabel
            Left = 152
            Top = 40
            Width = 26
            Height = 13
            Caption = 'FLAC'
          end
          object LabelDAECustom: TLabel
            Left = 96
            Top = 40
            Width = 42
            Height = 13
            Caption = 'ben.-def.'
          end
          object LabelDAECopy: TLabel
            Left = 96
            Top = 24
            Width = 45
            Height = 13
            Caption = '1:1-Kopie'
          end
        end
      end
    end
    object TabSheet7: TTabSheet
      HelpContext = 1900
      Caption = 'CD-Image'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        538
        277)
      object PanelImage: TPanel
        Left = 8
        Top = 16
        Width = 521
        Height = 249
        Anchors = []
        BevelOuter = bvNone
        TabOrder = 0
        object GroupBoxReadCD: TGroupBox
          Left = 0
          Top = 24
          Width = 257
          Height = 217
          Caption = 'Image von CD erstellen'
          TabOrder = 0
          object CheckBoxReadCDNoerror: TCheckBox
            Left = 16
            Top = 72
            Width = 233
            Height = 17
            Caption = 'kein Abbruch bei unkorrigierbaren Fehlern'
            TabOrder = 2
          end
          object CheckBoxReadCDNocorr: TCheckBox
            Left = 16
            Top = 96
            Width = 233
            Height = 17
            Caption = 'Fehlerkorrektur des Laufwerks abschalten'
            TabOrder = 3
          end
          object CheckBoxReadCDClone: TCheckBox
            Left = 16
            Top = 120
            Width = 233
            Height = 17
            Caption = 'Klon-Modus'
            TabOrder = 4
          end
          object CheckBoxReadCDRange: TCheckBox
            Left = 16
            Top = 144
            Width = 233
            Height = 17
            Caption = 'Bereich:'
            TabOrder = 5
            OnClick = CheckBoxClick
          end
          object StaticTextReadCDStartSec: TStaticText
            Left = 40
            Top = 168
            Width = 58
            Height = 17
            Caption = 'Startsektor:'
            Enabled = False
            TabOrder = 8
          end
          object StaticTextReadCDEndSec: TStaticText
            Left = 120
            Top = 168
            Width = 55
            Height = 17
            Caption = 'Endsektor:'
            Enabled = False
            TabOrder = 9
          end
          object EditReadCDStartSec: TEdit
            Left = 40
            Top = 184
            Width = 65
            Height = 21
            Enabled = False
            TabOrder = 6
            OnKeyPress = EditKeyPress
          end
          object EditReadCDEndSec: TEdit
            Left = 120
            Top = 184
            Width = 65
            Height = 21
            Enabled = False
            TabOrder = 7
            OnKeyPress = EditKeyPress
          end
          object EditReadCDIsoPath: TEdit
            Left = 16
            Top = 32
            Width = 145
            Height = 21
            TabOrder = 0
            OnKeyPress = EditKeyPress
          end
          object ButtonReadCDSelectPath: TButton
            Left = 168
            Top = 32
            Width = 75
            Height = 25
            Caption = 'Auswahl'
            TabOrder = 1
            OnClick = ButtonReadCDSelectPathClick
          end
        end
        object GroupBoxImage: TGroupBox
          Left = 264
          Top = 24
          Width = 257
          Height = 217
          Caption = 'ISO-/CUE-Image auf CD schreiben'
          TabOrder = 1
          object EditImageIsoPath: TEdit
            Left = 16
            Top = 32
            Width = 145
            Height = 21
            TabOrder = 0
            OnExit = EditExit
            OnKeyPress = EditKeyPress
          end
          object ButtonImageSelectPath: TButton
            Left = 168
            Top = 32
            Width = 75
            Height = 25
            Caption = 'Auswahl'
            TabOrder = 1
            OnClick = ButtonImageSelectPathClick
          end
          object RadioButtonImageRAW: TRadioButton
            Left = 16
            Top = 96
            Width = 97
            Height = 17
            Caption = 'Raw-Modus:'
            TabOrder = 4
            OnClick = CheckBoxClick
          end
          object PanelImageWriteRawOptions: TPanel
            Left = 112
            Top = 88
            Width = 81
            Height = 73
            BevelOuter = bvNone
            TabOrder = 5
            object RadioButtonImageRaw96r: TRadioButton
              Left = 16
              Top = 8
              Width = 65
              Height = 17
              Caption = 'raw96r'
              TabOrder = 0
            end
            object RadioButtonImageRaw96p: TRadioButton
              Left = 16
              Top = 32
              Width = 65
              Height = 17
              Caption = 'raw96p'
              TabOrder = 1
            end
            object RadioButtonImageRaw16: TRadioButton
              Left = 16
              Top = 56
              Width = 65
              Height = 17
              Caption = 'raw16'
              TabOrder = 2
            end
          end
          object RadioButtonImageTAO: TRadioButton
            Left = 16
            Top = 72
            Width = 89
            Height = 17
            Caption = 'track-at-once'
            TabOrder = 2
            TabStop = True
            OnClick = CheckBoxClick
          end
          object RadioButtonImageDAO: TRadioButton
            Left = 128
            Top = 72
            Width = 89
            Height = 17
            Caption = 'disk-at-once'
            TabOrder = 3
            TabStop = True
            OnClick = CheckBoxClick
          end
          object CheckBoxImageOverburn: TCheckBox
            Left = 16
            Top = 168
            Width = 105
            Height = 17
            Caption = #220'berbrennen'
            TabOrder = 6
          end
          object CheckBoxImageClone: TCheckBox
            Left = 16
            Top = 192
            Width = 97
            Height = 17
            Caption = 'Klon-Modus'
            TabOrder = 7
          end
          object CheckBoxImageCDText: TCheckBox
            Left = 128
            Top = 192
            Width = 97
            Height = 17
            Caption = 'CD-Text'
            TabOrder = 8
          end
          object CheckBoxISOVerify: TCheckBox
            Left = 128
            Top = 168
            Width = 113
            Height = 17
            Caption = 'Verify'
            PopupMenu = MiscPopupMenu
            TabOrder = 9
          end
        end
        object RadioButtonImageRead: TRadioButton
          Left = 0
          Top = 0
          Width = 129
          Height = 17
          Caption = 'Image erstellen'
          TabOrder = 2
          OnClick = CheckBoxClick
        end
        object RadioButtonImageWrite: TRadioButton
          Left = 264
          Top = 0
          Width = 129
          Height = 17
          Caption = 'Image schreiben'
          TabOrder = 3
          OnClick = CheckBoxClick
        end
        object CheckBoxReadCDWriteCopy: TCheckBox
          Left = 136
          Top = 0
          Width = 121
          Height = 17
          Caption = 'Kopie schreiben'
          TabOrder = 4
        end
      end
    end
    object TabSheet8: TTabSheet
      HelpContext = 2000
      Caption = '(S)VideoCD'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        538
        277)
      object VideoSpeedButton1: TSpeedButton
        Left = 512
        Top = 32
        Width = 25
        Height = 25
        Hint = 'Track hinzuf'#252'gen'
        Anchors = [akTop, akRight]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = VideoSpeedButton1Click
      end
      object VideoSpeedButton2: TSpeedButton
        Left = 512
        Top = 64
        Width = 25
        Height = 25
        Hint = 'Track nach oben verschieben'
        Anchors = [akTop, akRight]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = VideoSpeedButton2Click
      end
      object VideoSpeedButton3: TSpeedButton
        Left = 512
        Top = 89
        Width = 25
        Height = 25
        Hint = 'Track nach unten verschieben'
        Anchors = [akTop, akRight]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = VideoSpeedButton3Click
      end
      object VideoSpeedButton4: TSpeedButton
        Left = 512
        Top = 128
        Width = 25
        Height = 25
        Hint = 'Track entfernen'
        Anchors = [akTop, akRight]
        Flat = True
        ParentShowHint = False
        ShowHint = True
        OnClick = VideoSpeedButton4Click
      end
      object VideoListView: TListView
        Left = 8
        Top = 8
        Width = 497
        Height = 193
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = 'Name'
            Width = 150
          end
          item
            Caption = 'L'#228'nge'
            Width = 60
          end
          item
            Alignment = taRightJustify
            Caption = 'Gr'#246#223'e'
            Width = 80
          end
          item
            Caption = 'Herkunft'
            Width = 400
          end>
        MultiSelect = True
        PopupMenu = AudioListViewPopupMenu
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = ListViewDblClick
        OnEditing = VideoListViewEditing
        OnDragDrop = CDEListViewDragDrop
        OnDragOver = CDEListViewDragOver
        OnKeyDown = VideoListViewKeyDown
      end
      object PanelVideoCD: TPanel
        Left = 8
        Top = 208
        Width = 497
        Height = 65
        Anchors = [akLeft, akRight, akBottom]
        BevelOuter = bvNone
        TabOrder = 1
        DesignSize = (
          497
          65)
        object ButtonVideoCDOptions: TButton
          Left = 0
          Top = 40
          Width = 75
          Height = 25
          Caption = 'Optionen'
          TabOrder = 0
          OnClick = ButtonVideoCDOptionsClick
        end
        object PanelVideoCDOptions: TPanel
          Left = 344
          Top = 0
          Width = 153
          Height = 65
          Anchors = [akRight, akBottom]
          BevelOuter = bvLowered
          TabOrder = 1
          object LabelVideoCDVCD1: TLabel
            Left = 8
            Top = 8
            Width = 40
            Height = 13
            Caption = 'VCD 1.1'
          end
          object LabelVideoCDVCD2: TLabel
            Left = 8
            Top = 24
            Width = 40
            Height = 13
            Caption = 'VCD 2.0'
          end
          object LabelVideoCDSVCD: TLabel
            Left = 8
            Top = 40
            Width = 29
            Height = 13
            Caption = 'SVCD'
          end
          object LabelVideoCDOverburn: TLabel
            Left = 72
            Top = 8
            Width = 62
            Height = 13
            Caption = #220'berbrennen'
          end
        end
      end
    end
    object TabSheet9: TTabSheet
      HelpContext = 2100
      Caption = 'DVD-Video'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        538
        277)
      object GroupBoxDVDVideo: TGroupBox
        Left = 152
        Top = 61
        Width = 233
        Height = 153
        Anchors = []
        Caption = 'Video-DVD schreiben'
        TabOrder = 0
        object LabelDVDVideoPath: TLabel
          Left = 16
          Top = 24
          Width = 80
          Height = 13
          Caption = 'Quellverzeichnis:'
        end
        object LabelDVDVideoVolID: TLabel
          Left = 16
          Top = 72
          Width = 65
          Height = 13
          Caption = 'Bezeichnung:'
        end
        object EditDVDVideoSourcePath: TEdit
          Left = 16
          Top = 40
          Width = 121
          Height = 21
          TabOrder = 0
          OnKeyPress = EditKeyPress
        end
        object ButtonDVDVideoSelectPath: TButton
          Left = 144
          Top = 40
          Width = 75
          Height = 25
          Caption = 'Auswahl'
          TabOrder = 1
          OnClick = ButtonDVDVideoSelectPathClick
        end
        object EditDVDVideoVolID: TEdit
          Left = 16
          Top = 88
          Width = 121
          Height = 21
          TabOrder = 2
          OnChange = EditChange
          OnDblClick = EditDblClick
          OnKeyPress = EditKeyPress
        end
        object ButtonDVDVideoOptions: TButton
          Left = 16
          Top = 120
          Width = 75
          Height = 25
          Caption = 'Optionen'
          TabOrder = 3
          OnClick = ButtonDVDVideoOptionsClick
        end
        object CheckBoxDVDVideoVerify: TCheckBox
          Left = 104
          Top = 120
          Width = 121
          Height = 17
          Caption = 'Verify'
          PopupMenu = MiscPopupMenu
          TabOrder = 4
        end
      end
    end
  end
  object Memo1: TMemo
    Left = 8
    Top = 320
    Width = 545
    Height = 105
    Anchors = [akLeft, akRight, akBottom]
    PopupMenu = MiscPopupMenu
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 3
    OnKeyDown = Memo1KeyDown
  end
  object GroupBoxDrive: TGroupBox
    Left = 560
    Top = 24
    Width = 177
    Height = 89
    Anchors = [akTop, akRight]
    Caption = 'Brenner'
    TabOrder = 1
    object ComboBoxDrives: TComboBox
      Left = 8
      Top = 24
      Width = 161
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      PopupMenu = MiscPopupMenu
      TabOrder = 0
      OnChange = ComboBoxChange
      OnKeyPress = EditKeyPress
    end
    object ComboBoxSpeed: TComboBox
      Left = 120
      Top = 56
      Width = 49
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
      OnChange = ComboBoxChange
      OnKeyPress = EditKeyPress
      Items.Strings = (
        ''
        '0'
        '1'
        '2'
        '4'
        '6'
        '8'
        '10'
        '12'
        '16'
        '20'
        '24'
        '32'
        '36'
        '40'
        '42'
        '48'
        '50'
        '52')
    end
    object StaticTextSpeed: TStaticText
      Left = 8
      Top = 60
      Width = 111
      Height = 17
      Alignment = taCenter
      Caption = 'Brenngeschwindigkeit:'
      TabOrder = 2
    end
  end
  object CheckBoxDummy: TCheckBox
    Left = 568
    Top = 120
    Width = 97
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Simulation'
    TabOrder = 2
  end
  object StatusBar: TStatusBar
    Left = 8
    Top = 467
    Width = 545
    Height = 19
    Align = alNone
    Anchors = [akLeft, akRight, akBottom]
    Panels = <
      item
        Width = 250
      end
      item
        Width = 50
      end>
    SizeGrip = False
  end
  object Panel1: TPanel
    Left = 560
    Top = 264
    Width = 185
    Height = 220
    Anchors = [akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 5
    object Bevel2: TBevel
      Left = 0
      Top = 16
      Width = 177
      Height = 9
      Shape = bsTopLine
      Visible = False
    end
    object Bevel3: TBevel
      Left = 0
      Top = 56
      Width = 177
      Height = 9
      Shape = bsTopLine
    end
    object ButtonSettings: TButton
      Left = 102
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Einstellungen'
      TabOrder = 0
      Visible = False
      OnClick = ButtonSettingsClick
    end
    object ButtonStart: TButton
      Left = 22
      Top = 64
      Width = 75
      Height = 25
      Caption = 'Start'
      TabOrder = 1
      OnClick = ButtonStartClick
    end
    object ButtonCancel: TButton
      Left = 102
      Top = 64
      Width = 75
      Height = 25
      Caption = 'Beenden'
      TabOrder = 2
      OnClick = ButtonCancelClick
    end
    object ButtonAbort: TButton
      Left = 102
      Top = 95
      Width = 75
      Height = 25
      Caption = 'Abbrechen!'
      TabOrder = 3
      Visible = False
      OnClick = ButtonAbortClick
    end
    object ProgressBar: TProgressBar
      Left = 0
      Top = 205
      Width = 177
      Height = 13
      TabOrder = 4
      Visible = False
    end
    object ProgressBarTotal: TProgressBar
      Left = 0
      Top = 186
      Width = 177
      Height = 13
      TabOrder = 5
      Visible = False
    end
  end
  object PanelBrowser: TPanel
    Left = 560
    Top = 169
    Width = 50
    Height = 41
    BevelOuter = bvNone
    TabOrder = 6
    Visible = False
  end
  object OpenDialog1: TOpenDialog
    Options = [ofHideReadOnly, ofAllowMultiSelect]
    Left = 384
    Top = 432
  end
  object SaveDialog1: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly]
    Left = 416
    Top = 432
  end
  object MainMenu1: TMainMenu
    Left = 352
    Top = 432
    object Datei1: TMenuItem
      Caption = '&Datei'
      object MainMenuClose: TMenuItem
        Caption = 'S&chlie'#223'en'
        OnClick = MainMenuCloseClick
      end
    end
    object Projekt1: TMenuItem
      Caption = '&Projekt'
      object MainMenuLoadProject: TMenuItem
        Caption = 'Projekt &laden'
        OnClick = MainMenuLoadProjectClick
      end
      object MainMenuSaveProject: TMenuItem
        Caption = 'Projekt &speichern'
        OnClick = MainMenuSaveProjectClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object MainMenuLoadFileList: TMenuItem
        Caption = 'Dateiliste l&aden'
        OnClick = MainMenuLoadFileListClick
      end
      object MainMenuSaveFileList: TMenuItem
        Caption = 'Dateiliste s&peichern'
        OnClick = MainMenuSaveFileListClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object MainMenuReloadDefaults: TMenuItem
        Caption = 'Standardeinstellungen'
        OnClick = MainMenuReloadDefaultsClick
      end
      object MainMenuReset: TMenuItem
        Caption = 'Alles zur'#252'cksetzen'
        OnClick = MainMenuResetClick
      end
    end
    object Ansicht1: TMenuItem
      Caption = '&Ansicht'
      object MainMenuToggleFileExplorer: TMenuItem
        Caption = 'Datei-Explorer'
        OnClick = MainMenuToggleFileExplorerClick
      end
      object MainMenuShowOutputWindow: TMenuItem
        Caption = 'Ausgabefenster'
        OnClick = MainMenuShowOutputWindowClick
      end
    end
    object Extras1: TMenuItem
      Caption = 'E&xtras'
      object MainMenuSetLang: TMenuItem
        Caption = '&Sprache '#228'ndern'
        Visible = False
        OnClick = MainMenuSetLangClick
      end
      object MainMenuLang: TMenuItem
        Caption = 'Sprache'
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object MainMenuCdrtfeIni: TMenuItem
        Caption = 'cdrtfe.ini anzeigen'
        OnClick = MainMenuCdrtfeIniClick
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object MainMenuSettings: TMenuItem
        Caption = 'Einstellungen'
        OnClick = MainMenuSettingsClick
      end
    end
    object N1: TMenuItem
      Caption = '&?'
      object MainMenuHelp: TMenuItem
        Caption = 'Hilfe'
        OnClick = MainMenuHelpClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object MainMenuInfo: TMenuItem
        Caption = 'Inf&o'
        OnClick = MainMenuInfoClick
      end
    end
  end
  object CDETreeViewPopupMenu: TPopupMenu
    OnPopup = CDETreeViewPopupMenuPopup
    Left = 20
    Top = 432
    object CDETreeViewPopupSetCDLabel: TMenuItem
      Caption = 'CD-Label '#228'ndern'
      OnClick = CDETreeViewPopupSetCDLabelClick
    end
    object CDETreeViewPopupN1: TMenuItem
      Caption = '-'
    end
    object CDETreeViewPopupAddFolder: TMenuItem
      Caption = 'Ordner hinzuf'#252'gen'
      OnClick = CDETreeViewPopupAddFolderClick
    end
    object CDETreeViewPopupAddFile: TMenuItem
      Caption = 'Datei hinzuf'#252'gen'
      OnClick = CDETreeViewPopupAddFileClick
    end
    object CDETreeViewPopupN2: TMenuItem
      Caption = '-'
    end
    object CDETreeViewPopupDeleteFolder: TMenuItem
      Caption = 'Ordner entfernen'
      OnClick = CDETreeViewPopupDeleteFolderClick
    end
    object CDETreeViewPopupRenameFolder: TMenuItem
      Caption = 'Ordner umbenennen'
      OnClick = CDETreeViewPopupRenameFolderClick
    end
    object CDETreeViewPopupN3: TMenuItem
      Caption = '-'
    end
    object CDETreeViewPopupNewFolder: TMenuItem
      Caption = 'Neuer Ordner'
      OnClick = CDETreeViewPopupNewFolderClick
    end
    object CDETreeViewPopupN4: TMenuItem
      Caption = '-'
    end
    object CDETreeViewPopupImport: TMenuItem
      Caption = 'CD importieren'
      OnClick = CDETreeViewPopupImportClick
    end
  end
  object CDEListViewPopupMenu: TPopupMenu
    OnPopup = CDEListViewPopupMenuPopup
    Left = 52
    Top = 432
    object CDEListViewPopupAddFile: TMenuItem
      Caption = 'Datei hinzuf'#252'gen'
      OnClick = CDEListViewPopupAddFileClick
    end
    object CDEListViewPopupAddFolder: TMenuItem
      Caption = 'Ordner hinzuf'#252'gen'
      OnClick = CDEListViewPopupAddFolderClick
    end
    object CDEListViewPopupAddMovie: TMenuItem
      Caption = 'Movie (als Form2) hinzuf'#252'gen'
      OnClick = CDEListViewPopupAddMovieClick
    end
    object CDEListViewPopupN1: TMenuItem
      Caption = '-'
    end
    object CDEListViewPopupRenameFile: TMenuItem
      Caption = 'Umbenennen'
      OnClick = CDEListViewPopupRenameFileClick
    end
    object CDEListViewPopupDeleteFile: TMenuItem
      Caption = 'Entfernen'
      OnClick = CDEListViewPopupDeleteFileClick
    end
    object CDEListViewPopupN5: TMenuItem
      Caption = '-'
    end
    object CDEListViewPopupNewFolder: TMenuItem
      Caption = 'Neuer Ordner'
      OnClick = CDEListViewPopupNewFolderClick
    end
    object CDEListViewPopupN6: TMenuItem
      Caption = '-'
    end
    object CDEListViewPopupOpen: TMenuItem
      Caption = #214'ffnen'
      OnClick = CDEListViewPopupOpenClick
    end
  end
  object AudioListViewPopupMenu: TPopupMenu
    OnPopup = AudioListViewPopupMenuPopup
    Left = 96
    Top = 432
    object AudioListViewPopupAddTrack: TMenuItem
      Caption = 'Track hinzuf'#252'gen'
      OnClick = AudioListViewPopupAddTrackClick
    end
    object AudioListViewPopupDeleteTrack: TMenuItem
      Caption = 'Track entfernen'
      OnClick = AudioListViewPopupDeleteTrackClick
    end
    object AudioListViewPopupN1: TMenuItem
      Caption = '-'
    end
    object AudioListViewPopupMoveUp: TMenuItem
      Caption = 'Track nach oben verschieben'
      OnClick = AudioListViewPopupMoveUpClick
    end
    object AudioListViewPopupMoveDown: TMenuItem
      Caption = 'Track nach unten verschieben'
      OnClick = AudioListViewPopupMoveDownClick
    end
    object AudioListViewPopupN2: TMenuItem
      Caption = '-'
    end
    object AudioListViewPopupPlay: TMenuItem
      Caption = 'Abspielen'
      Default = True
      OnClick = AudioListViewPopupPlayClick
    end
  end
  object MiscPopupMenu: TPopupMenu
    OnPopup = MiscPopupMenuPopup
    Left = 136
    Top = 432
    object MiscPopupVerify: TMenuItem
      Caption = 'Vergleich starten'
      OnClick = MiscPopupVerifyClick
    end
    object MiscPopupClearOutput: TMenuItem
      Caption = 'Ausgabe l'#246'schen'
      OnClick = MiscPopupClearOutputClick
    end
    object MiscPopupEject: TMenuItem
      Caption = #214'ffnen'
      OnClick = MiscPopupEjectClick
    end
    object MiscPopupLoad: TMenuItem
      Caption = 'Schlie'#223'en'
      OnClick = MiscPopupLoadClick
    end
    object MiscPopupSaveOutput: TMenuItem
      Caption = 'Ausgabe speichern'
      OnClick = MiscPopupSaveOutputClick
    end
  end
  object TimerNodeExpand: TTimer
    Enabled = False
    Interval = 1500
    OnTimer = TimerNodeExpandTimer
    Left = 504
    Top = 432
  end
end
