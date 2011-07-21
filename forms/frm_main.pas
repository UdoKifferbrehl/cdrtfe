{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  frm_main.pas: Hauptfenster

  Copyright (c) 2004-2011 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  10.07.2011

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

}

unit frm_main;

{$I directives.inc}

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
     StdCtrls, ComCtrls, ExtCtrls, ShellAPI, Menus, FileCtrl, CommCtrl, Buttons,
     ActnList, ShellCtrls, Clipbrd, XPMan, ToolWin,
     {$IFDEF Delphi2005Up}
     HTMLHelpViewer,
     {$ENDIF}
     {externe Komponenten}
     DropTarget, DropSource, VistaAltFixUnit,
     c_filebrowser,
     {eigene Klassendefinitionen/Units}
     cl_lang, cl_imagelists, cl_settings, cl_projectdata, cl_filetypeinfo,
     cl_action, cl_cmdlineparser, cl_devices, cl_logwindow, c_spacemeter,
     usermessages, const_core;

type
  TCdrtfeMainForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Memo1: TMemo;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    GroupBoxDrive: TGroupBox;
    CheckBoxDummy: TCheckBox;
    GroupBoxCDRWDelete: TGroupBox;
    RadioButtonCDRWBlankAll: TRadioButton;
    RadioButtonCDRWBlankFast: TRadioButton;
    RadioButtonCDRWBlankOpenSession: TRadioButton;
    RadioButtonCDRWBlankSession: TRadioButton;
    CheckBoxCDRWBlankForce: TCheckBox;
    TabSheet5: TTabSheet;
    GroupBoxCDInfo: TGroupBox;
    RadioButtonToc: TRadioButton;
    RadioButtonAtip: TRadioButton;
    RadioButtonMSInfo: TRadioButton;
    RadioButtonScanbus: TRadioButton;
    RadioButtonPrcap: TRadioButton;
    MainMenu1: TMainMenu;
    Projekt1: TMenuItem;
    MainMenuLoadProject: TMenuItem;
    MainMenuSaveProject: TMenuItem;
    Bevel4: TBevel;
    Datei1: TMenuItem;
    MainMenuClose: TMenuItem;
    TabSheet6: TTabSheet;
    RadioButtonCapacity: TRadioButton;
    CDETreeViewPopupSetCDLabel: TMenuItem;
    CDETreeViewPopupN1: TMenuItem;
    CDETreeViewPopupAddFolder: TMenuItem;
    CDETreeViewPopupAddFile: TMenuItem;
    CDETreeViewPopupN2: TMenuItem;
    CDETreeViewPopupDeleteFolder: TMenuItem;
    CDETreeViewPopupRenameFolder: TMenuItem;
    CDETreeViewPopupN3: TMenuItem;
    CDETreeViewPopupNewFolder: TMenuItem;
    CDEListViewPopupAddFile: TMenuItem;
    CDEListViewPopupN1: TMenuItem;
    CDEListViewPopupRenameFile: TMenuItem;
    CDEListViewPopupDeleteFile: TMenuItem;
    StatusBar: TStatusBar;
    CDESpeedButton1: TSpeedButton;
    CDESpeedButton2: TSpeedButton;
    CDESpeedButton3: TSpeedButton;
    CDESpeedButton4: TSpeedButton;
    CDESpeedButton5: TSpeedButton;
    AudioListView: TListView;
    AudioSpeedButton1: TSpeedButton;
    AudioSpeedButton2: TSpeedButton;
    AudioSpeedButton3: TSpeedButton;
    AudioSpeedButton4: TSpeedButton;
    AudioListViewPopupAddTrack: TMenuItem;
    AudioListViewPopupDeleteTrack: TMenuItem;
    AudioListViewPopupN1: TMenuItem;
    AudioListViewPopupMoveUp: TMenuItem;
    AudioListViewPopupMoveDown: TMenuItem;
    CDEListViewPopupAddMovie: TMenuItem;
    XCDESpeedButton1: TSpeedButton;
    XCDESpeedButton2: TSpeedButton;
    XCDESpeedButton3: TSpeedButton;
    XCDESpeedButton4: TSpeedButton;
    XCDESpeedButton5: TSpeedButton;
    XCDESpeedButton6: TSpeedButton;
    XCDESpeedButton7: TSpeedButton;
    DAEListView: TListView;
    N1: TMenuItem;
    MainMenuInfo: TMenuItem;
    MiscPopupMenu: TPopupMenu;
    MiscPopupVerify: TMenuItem;
    TabSheet7: TTabSheet;
    PanelDataCD: TPanel;
    Sheet1SpeedButtonCheckFS: TSpeedButton;
    ButtonDataCDOptionsFS: TButton;
    ButtonDataCDOptions: TButton;
    CheckBoxDataCDVerify: TCheckBox;
    PanelDataCDOptions: TPanel;
    LabelDataCDSingle: TLabel;
    LabelDataCDMulti: TLabel;
    LabelDataCDOTF: TLabel;
    LabelDataCDTAO: TLabel;
    LabelDataCDDAO: TLabel;
    LabelDataCDRAW: TLabel;
    LabelDataCDJoliet: TLabel;
    LabelDataCDRockRidge: TLabel;
    LabelDataCDUDF: TLabel;
    LabelDataCDISOLevel: TLabel;
    LabelDataCDBoot: TLabel;
    Label12: TLabel;
    LabelDataCDOverburn: TLabel;
    PanelAudioCD: TPanel;
    ButtonAudioCDOptions: TButton;
    PanelAudioCDOptions: TPanel;
    LabelAudioCDSingle: TLabel;
    LabelAudioCDMulti: TLabel;
    LabelAudioCDOverburn: TLabel;
    LabelAudioCDTAO: TLabel;
    LabelAudioCDDAO: TLabel;
    LabelAudioCDRAW: TLabel;
    LabelAudioCDPreemp: TLabel;
    LabelAudioCDUseInfo: TLabel;
    PanelXCD: TPanel;
    ButtonXCDOptions: TButton;
    PanelXCDOptions: TPanel;
    LabelXCDSingle: TLabel;
    LabelXCDIsoLEvel1: TLabel;
    LabelXCDIsoLevel2: TLabel;
    LabelXCDKeepExt: TLabel;
    LabelXCDOverburn: TLabel;
    PanelDAE: TPanel;
    ButtonDAEOptions: TButton;
    ButtonDAEReadToc: TButton;
    Label1: TLabel;
    EditDAEPath: TEdit;
    ButtonDAESelectPath: TButton;
    PanelImage: TPanel;
    GroupBoxReadCD: TGroupBox;
    CheckBoxReadCDNoerror: TCheckBox;
    CheckBoxReadCDNocorr: TCheckBox;
    CheckBoxReadCDClone: TCheckBox;
    CheckBoxReadCDRange: TCheckBox;
    StaticTextReadCDStartSec: TStaticText;
    StaticTextReadCDEndSec: TStaticText;
    EditReadCDStartSec: TEdit;
    EditReadCDEndSec: TEdit;
    GroupBoxImage: TGroupBox;
    EditReadCDIsoPath: TEdit;
    EditImageIsoPath: TEdit;
    ButtonImageSelectPath: TButton;
    ButtonReadCDSelectPath: TButton;
    RadioButtonImageRead: TRadioButton;
    RadioButtonImageWrite: TRadioButton;
    RadioButtonImageRAW: TRadioButton;
    PanelImageWriteRawOptions: TPanel;
    RadioButtonImageRaw96r: TRadioButton;
    RadioButtonImageRaw96p: TRadioButton;
    RadioButtonImageRaw16: TRadioButton;
    RadioButtonImageTAO: TRadioButton;
    RadioButtonImageDAO: TRadioButton;
    CheckBoxImageOverburn: TCheckBox;
    CheckBoxImageClone: TCheckBox;
    MiscPopupClearOutput: TMenuItem;
    Panel1: TPanel;
    ButtonSettings: TButton;
    ButtonStart: TButton;
    ButtonCancel: TButton;
    ButtonAbort: TButton;
    ButtonAudioCDTracks: TButton;
    LabelAudioCDText: TLabel;
    N2: TMenuItem;
    MainMenuLoadFileList: TMenuItem;
    MainMenuSaveFileList: TMenuItem;
    N3: TMenuItem;
    MainMenuReloadDefaults: TMenuItem;
    CheckBoxXCDVerify: TCheckBox;
    Extras1: TMenuItem;
    MainMenuSetLang: TMenuItem;
    LabelXCDCreateInfoFile: TLabel;
    TabSheet8: TTabSheet;
    TabSheet9: TTabSheet;
    GroupBoxDVDVideo: TGroupBox;
    LabelDVDVideoPath: TLabel;
    EditDVDVideoSourcePath: TEdit;
    ButtonDVDVideoSelectPath: TButton;
    VideoListView: TListView;
    PanelVideoCD: TPanel;
    ButtonVideoCDOptions: TButton;
    VideoSpeedButton1: TSpeedButton;
    VideoSpeedButton2: TSpeedButton;
    VideoSpeedButton4: TSpeedButton;
    VideoSpeedButton3: TSpeedButton;
    PanelVideoCDOptions: TPanel;
    LabelVideoCDVCD1: TLabel;
    LabelVideoCDVCD2: TLabel;
    LabelVideoCDSVCD: TLabel;
    LabelVideoCDOverburn: TLabel;
    MiscPopupEject: TMenuItem;
    MiscPopupLoad: TMenuItem;
    LabelDVDVideoVolID: TLabel;
    EditDVDVideoVolID: TEdit;
    ButtonDVDVideoOptions: TButton;
    CheckBoxDVDVideoVerify: TCheckBox;
    MiscPopupSaveOutput: TMenuItem;
    TimerNodeExpand: TTimer;
    PanelDAEOptions: TPanel;
    LabelDAEBulk: TLabel;
    LabelDAEParanoia: TLabel;
    LabelDAEInfoFiles: TLabel;
    LabelDAECDDB: TLabel;
    LabelDAEMp3: TLabel;
    LabelDAEOgg: TLabel;
    LabelDAEFlac: TLabel;
    LabelDAECustom: TLabel;
    RadioButtonMInfo: TRadioButton;
    MainMenuReset: TMenuItem;
    MainMenuHelp: TMenuItem;
    N4: TMenuItem;
    CDETreeViewPopupN4: TMenuItem;
    CDETreeViewPopupImport: TMenuItem;
    CheckBoxReadCDWriteCopy: TCheckBox;
    LabelDAECopy: TLabel;
    AudioListViewPopupN2: TMenuItem;
    AudioListViewPopupPlay: TMenuItem;
    CheckBoxImageCDText: TCheckBox;
    CDEListViewPopupN5: TMenuItem;
    CDEListViewPopupOpen: TMenuItem;
    MainMenuLang: TMenuItem;
    PanelDataCDView: TPanel;
    CDETreeView: TTreeView;
    SplitterDataCD: TSplitter;
    CDEListView: TListView;
    PanelXCDView: TPanel;
    PanelXCDViewLeft: TPanel;
    SplitterXCDVertical: TSplitter;
    PanelXCDViewRight: TPanel;
    XCDEListView1: TListView;
    SplitterXCDHorizontal: TSplitter;
    XCDEListView2: TListView;
    XCDETreeView: TTreeView;
    CDEListViewPopupAddFolder: TMenuItem;
    CDEListViewPopupN6: TMenuItem;
    CDEListViewPopupNewFolder: TMenuItem;
    PanelBrowser: TPanel;
    Ansicht1: TMenuItem;
    MainMenuToggleFileExplorer: TMenuItem;
    MainMenuShowOutputWindow: TMenuItem;
    MainMenuSettings: TMenuItem;
    N5: TMenuItem;
    MainMenuCdrtfeIni: TMenuItem;
    N6: TMenuItem;
    CheckBoxISOVerify: TCheckBox;
    TreeListViewPopupMenu: TPopupMenu;
    TreeListViewPopupN1: TMenuItem;
    TreeListViewPopupPaste: TMenuItem;
    LabelReadCDRetries: TLabel;
    EditReadCDRetries: TEdit;
    MainMenuToggleLogWindow: TMenuItem;
    XPManifest1: TXPManifest;
    PanelTabSheet1: TPanel;
    PanelTabSheet2: TPanel;
    PanelTabSheet3: TPanel;
    PanelTabSheet8: TPanel;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButtonLoad: TToolButton;
    ToolButtonSave: TToolButton;
    ToolButton4: TToolButton;
    ToolButtonSettings: TToolButton;
    ToolButton6: TToolButton;
    ToolButtonStart: TToolButton;
    ToolButtonAbort: TToolButton;
    ToolButton9: TToolButton;
    ToolButtonClose: TToolButton;
    Bevel5: TBevel;
    StaticTextSpeed: TStaticText;
    ComboBoxSpeed: TComboBox;
    ComboBoxDrives: TComboBox;
    ProgressBarTotal: TProgressBar;
    ProgressBar: TProgressBar;
    SpeedButtonFixCD: TSpeedButton;
    Aktion1: TMenuItem;
    MainMenuStart: TMenuItem;
    MainMenuAbort: TMenuItem;
    N7: TMenuItem;
    MainMenuFixate: TMenuItem;
    RadioButtonMetaData: TRadioButton;
    MainMenuErase: TMenuItem;
    N8: TMenuItem;
    MainMenuEraseFast: TMenuItem;
    MainMenuEraseFull: TMenuItem;
    MainMenuShowInfo: TMenuItem;
    MainMenuInfoDev: TMenuItem;
    MainMenuInfoDisk: TMenuItem;
    MainMenuInfoSCSI: TMenuItem;
    MainMenuInfoDevice: TMenuItem;
    MainMenuInfoTOC: TMenuItem;
    MainMenuInfoATIP: TMenuItem;
    MainMenuInfoMSI: TMenuItem;
    MainMenuInfoDiskInfo: TMenuItem;
    MainMenuInfoCap: TMenuItem;
    MainMenuInfoMeta: TMenuItem;
    AudioListViewPopupN3: TMenuItem;
    AudioListViewPopupSort: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure MainMenuAboutClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure FormShow(Sender: TObject);
    procedure CDESpeedButton1Click(Sender: TObject);
    procedure CDESpeedButton2Click(Sender: TObject);
    procedure TreeViewExpanding(Sender: TObject; Node: TTreeNode; var AllowExpansion: Boolean);
    procedure CDESpeedButton3Click(Sender: TObject);
    procedure XCDESpeedButton1Click(Sender: TObject);
    procedure XCDESpeedButton2Click(Sender: TObject);
    procedure XCDESpeedButton3Click(Sender: TObject);
    procedure XCDESpeedButton5Click(Sender: TObject);
    procedure XCDESpeedButton4Click(Sender: TObject);
    procedure CDESpeedButton4Click(Sender: TObject);
    procedure XCDESpeedButton6Click(Sender: TObject);
    procedure CDESpeedButton5Click(Sender: TObject);
    procedure XCDESpeedButton7Click(Sender: TObject);
    procedure TreeViewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TreeViewDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure TreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TreeViewEdited(Sender: TObject; Node: TTreeNode; var S: String);
    procedure ListViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ListViewEdited(Sender: TObject; Item: TListItem; var S: String);
    procedure XCDEListView1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure XCDEListView1DragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure XCDEListView1Editing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
    procedure CDETreeViewPopupMenuPopup(Sender: TObject);
    procedure CDETreeViewPopupAddFolderClick(Sender: TObject);
    procedure CDETreeViewPopupAddFileClick(Sender: TObject);
    procedure CDETreeViewPopupDeleteFolderClick(Sender: TObject);
    procedure CDETreeViewPopupRenameFolderClick(Sender: TObject);
    procedure CDETreeViewPopupNewFolderClick(Sender: TObject);
    procedure CDETreeViewPopupSetCDLabelClick(Sender: TObject);
    procedure CDEListViewPopupMenuPopup(Sender: TObject);
    procedure CDEListViewPopupAddFileClick(Sender: TObject);
    procedure CDEListViewPopupAddMovieClick(Sender: TObject);
    procedure CDEListViewPopupRenameFileClick(Sender: TObject);
    procedure CDEListViewPopupDeleteFileClick(Sender: TObject);
    procedure AudioSpeedButton1Click(Sender: TObject);
    procedure AudioSpeedButton2Click(Sender: TObject);
    procedure AudioSpeedButton3Click(Sender: TObject);
    procedure AudioSpeedButton4Click(Sender: TObject);
    procedure AudioListViewPopupMenuPopup(Sender: TObject);
    procedure AudioListViewPopupAddTrackClick(Sender: TObject);
    procedure AudioListViewPopupDeleteTrackClick(Sender: TObject);
    procedure AudioListViewPopupMoveUpClick(Sender: TObject);
    procedure AudioListViewPopupMoveDownClick(Sender: TObject);
    procedure AudioListViewEditing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
    procedure AudioListViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ButtonDataCDOptionsFSClick(Sender: TObject);
    procedure ButtonDataCDOptionsClick(Sender: TObject);
    procedure Sheet1SpeedButtonCheckFSClick(Sender: TObject);
    procedure ButtonAudioCDOptionsClick(Sender: TObject);
    procedure ButtonXCDOptionsClick(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonDAESelectPathClick(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure ButtonReadCDSelectPathClick(Sender: TObject);
    procedure ButtonImageSelectPathClick(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure EditExit(Sender: TObject);
    procedure ButtonSettingsClick(Sender: TObject);
    procedure ComboBoxChange(Sender: TObject);
    procedure ButtonDAEReadTocClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure MainMenuCloseClick(Sender: TObject);
    procedure MainMenuLoadProjectClick(Sender: TObject);
    procedure MainMenuSaveProjectClick(Sender: TObject);
    procedure ButtonAbortClick(Sender: TObject);
    procedure MiscPopupVerifyClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MiscPopupMenuPopup(Sender: TObject);
    procedure MiscPopupClearOutputClick(Sender: TObject);
    procedure SpeedButtonFixCDClick(Sender: TObject);
    procedure ButtonAudioCDTracksClick(Sender: TObject);
    {$IFDEF AllowToggle}
    procedure LabelClick(Sender: TObject);
    {$ENDIF}
    {$IFDEF MouseOverLabelHighlight}
    procedure LabelMouseMove(Sender: TObject;  Shift: TShiftState; X, Y: Integer);
    procedure PanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    {$ENDIF}
    procedure DAEListViewEditing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
    procedure DAEListViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MainMenuLoadFileListClick(Sender: TObject);
    procedure MainMenuSaveFileListClick(Sender: TObject);
    procedure MainMenuReloadDefaultsClick(Sender: TObject);
    procedure MainMenuSetLangClick(Sender: TObject);
    procedure ButtonDVDVideoSelectPathClick(Sender: TObject);
    procedure VideoSpeedButton1Click(Sender: TObject);
    procedure VideoSpeedButton2Click(Sender: TObject);
    procedure VideoSpeedButton3Click(Sender: TObject);
    procedure VideoSpeedButton4Click(Sender: TObject);
    procedure VideoListViewEditing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
    procedure VideoListViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ButtonVideoCDOptionsClick(Sender: TObject);
    procedure MiscPopupEjectClick(Sender: TObject);
    procedure MiscPopupLoadClick(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure ButtonDVDVideoOptionsClick(Sender: TObject);
    procedure EditDblClick(Sender: TObject);
    procedure MiscPopupSaveOutputClick(Sender: TObject);
    procedure TimerNodeExpandTimer(Sender: TObject);
    procedure ButtonDAEOptionsClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MainMenuResetClick(Sender: TObject);
    procedure MainMenuHelpClick(Sender: TObject);
    procedure CDETreeViewPopupImportClick(Sender: TObject);
    procedure AudioListViewPopupPlayClick(Sender: TObject);
    procedure ListViewDblClick(Sender: TObject);
    procedure CDEListViewPopupOpenClick(Sender: TObject);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CDEListViewPopupAddFolderClick(Sender: TObject);
    procedure CDEListViewPopupNewFolderClick(Sender: TObject);
    procedure CDEListViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure CDEListViewDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure MainMenuToggleFileExplorerClick(Sender: TObject);
    procedure MainMenuShowOutputWindowClick(Sender: TObject);
    procedure MainMenuSettingsClick(Sender: TObject);
    procedure MainMenuCdrtfeIniClick(Sender: TObject);
    procedure TreeListViewPopupMenuPopup(Sender: TObject);
    procedure TreeListViewPopupPasteClick(Sender: TObject);
    procedure MainMenuToggleLogWindowClick(Sender: TObject);
    procedure MainMenuStartClick(Sender: TObject);
    procedure MainMenuAbortClick(Sender: TObject);
    procedure MainMenuFixateClick(Sender: TObject);
    procedure MainMenuEraseFastClick(Sender: TObject);
    procedure MainMenuEraseFullClick(Sender: TObject);
    procedure MainMenuShowInfoClick(Sender: TObject);
    procedure AudioListViewPopupSortClick(Sender: TObject);
  private
    { Private declarations }
    FImageLists: TImageLists;              // FormCreate - FormDestroy
    FLang: TLang;                          // FormCreate - FormDestroy
    FSettings: TSettings;                  // FormCreate - FormDestroy
    FData: TProjectData;                   // FormCreate - FormDestroy
    FFileTypeInfo: TFileTypeInfo;          // FormCreate - FormDestroy
    FAction: TCDAction;                    // FormCreate - FormDestroy
    FCmdLineParser: TCmdLineParser;        // FormCreate - FormDestroy
    FDevices: TDevices;                    // FormCreate - FormDestroy
    FInstanceTermination: Boolean;
    {$IFDEF ShowCmdError}
    FExitCode: Integer;
    {$ENDIF}
    DropFileTargetCDETreeView: TDropFileTarget;
    DropFileTargetXCDETreeView: TDropFileTarget;
    SpaceMeter: TSpaceMeter;
    FileBrowser: TFrameFileBrowser;
    StayOnTopState: Boolean;
    ActionList: TActionList;
    ActionUserAddFile: TAction;
    ActionUserAddFileForm2: TAction;
    ActionUserAddFolder: TAction;
    ActionUserDeleteAll: TAction;
    ActionUserTrackUp  : TAction;
    ActionUserTrackDown: TAction;
    ActionUserToggleFileExplorer: TAction;
    ActionUserSettings : TAction;
    ActionUserShowOutputWindow: TAction;
    ActionUserSpecialTab: TAction;
    ActionUserToggleLogWindow: TAction;
    ActionUserToggleExplorerLog: TAction;
    FImageTabFirstShow  : Boolean;
    FImageTabFirstWrite : Boolean;
    FCheckingControls   : Boolean;
    FFileExplorerShowing: Boolean;
    FOutputWindowShowing: Boolean;
    FLogWindowShowing   : Boolean;
    FLVArray: array[0..cLVCount] of TListView;
    function GetActivePage: Byte;
    function GetCurrentListView(Sender: TObject): TListView;
    function GetCurrentTreeView: TTreeView;
    function GetProgressBar(const PB: Integer): TProgressBar;
    function InputOk: Boolean;
    procedure ActivateTab(const PageToActivate: Byte);
    procedure AddFromClipboard;
    procedure AddListToPathList(List: TStringList);
    procedure AddToPathList(const Filename: string);
    procedure AddToPathListSort(const FolderAdded: Boolean);
    procedure AddItemToListView(const Item: string; ListView: TListView);
    procedure CheckDataCDFS(const CheckAccess: Boolean);
    procedure CheckControls;
    procedure CheckControlsSpeeds;
    {$IFDEF ShowCmdError}
    procedure CheckExitCode;
    {$ENDIF}
    procedure ExpandNodeDelayed(Node: TTreeNode; const TimerEvent: Boolean);
    procedure DoMenuEraseDisk(const FastErase: Boolean);
    procedure DoMenuShowInfo(const ID: Integer);
    procedure GetSettings;
    procedure InitMainform;
    procedure InitSpaceMeter;
    procedure InitTreeView(Tree: TTreeView; const Choice: Byte);
    procedure InitTreeViews;
    procedure LoadProject(const ListsOnly: Boolean);
    procedure SaveProject(const ListsOnly: Boolean);
    procedure SaveWinPos;
    procedure SetFileBrowserParent;
    procedure SetPanelSize(const Status: Boolean; const FileExplorerHeight: Integer);
    procedure SetGlobalWriter;
    procedure SetHelpFile;
    procedure SetSettings;
    procedure SetWinPos;
    procedure SetButtons(const Status: TOnOff);
    procedure ShowFolderContent(const Tree: TTreeView; ListView: TListView);
    procedure ShowTracks;
    procedure ShowTracksDAE;
    procedure SpecialTab;
    procedure ToggleFileExplorer(const Status: Boolean);
    procedure ToggleOutputWindow(const Status: Boolean);
    procedure ToggleLogWindow(const Status: Boolean);
    {$IFDEF AllowToggle}
    procedure ToggleOptions(Sender: TObject);
    {$ENDIF}
    procedure ToggleStayOnTopState;
    procedure UpdateGauges;
    procedure UpdateSpaceMeter(Size, Time: Integer);
    procedure UpdateTaskBarEntry(s: string);
    procedure UpdateOptionPanel;
    procedure UserAddFile(Tree: TTreeView);
    procedure UserAddFolder(Tree: TTreeView);
    procedure UserAddFolderUpdateTree(Tree: TTreeView);
    procedure UserAddTrack;
    procedure UserDeleteAll(Tree: TTreeView);
    procedure UserDeleteFile(Tree: TTreeView; View: TListView);
    procedure UserDeleteFolder(Tree: TTreeView);
    procedure UserImportCD;
    procedure UserMoveFile(SourceNode, DestNode: TTreeNode; View: TListView);
    procedure UserMoveFolder(SourceNode, DestNode: TTreeNode);
    procedure UserMoveTrack(List: TListView; const Direction: TDirection);
    procedure UserSortTracks(List: TListView);
    procedure UserNewFolder(Tree: TTreeView);
    procedure UserOpenFile(List: TListView);
    procedure UserRenameFile(View: TListView);
    procedure UserRenameFolder(Tree: TTreeView);
    procedure UserRenameFolderByKey(Tree: TTreeView);
    procedure UserSetCDLabel(Tree: TTreeView);
    procedure UserSort(Force: Boolean);
    {Message-Handler}
    procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;
    procedure WMDROPFILES(var Msg: TMessage); message WM_DROPFILES;
    procedure WMButtonsOff(var Msg: TMessage); message WM_ButtonsOff;
    procedure WMButtonsOn(var Msg: TMessage); message WM_ButtonsOn;
    procedure WMTTerminated(var Msg: TMessage); message WM_TTerminated;
    procedure WMVTerminated(var Msg: TMessage); message WM_VTerminated;
    procedure WMFTerminated(var Msg: TMessage); message WM_FTerminated;
    procedure WMITerminated(var Msg: TMessage); message WM_ITerminated;
    procedure WMUpdateGauges(var Msg: TMessage); message WM_UPDATEGAUGES;
    procedure WMActivateDataTab(var Msg: TMessage); message WM_ACTIVATEDATATAB;
    procedure WMActivateAudioTab(var Msg: TMessage); message WM_ACTIVATEAUDIOTAB;
    procedure WMActivateXcdTab(var Msg: TMessage); message WM_ACTIVATEXCDTAB;
    procedure WMActivateVcdTab(var Msg: TMessage); message WM_ACTIVATEVCDTAB;
    procedure WMActivateImgTab(var Msg: TMessage); message WM_ACTIVATEIMGTAB;
    procedure WMActivateDVDTab(var Msg: TMessage); message WM_ACTIVATEDVDTAB;
    procedure WMExecute(var Msg: TMessage); message WM_EXECUTE;
    procedure WMExitAfterExecute(var Msg: TMessage); message WM_ExitAfterExec;
    procedure WMWriteLog(var Msg: TMessage); message WM_WriteLog;
    procedure WMCheckDataFS(var Msg: TMessage); message WM_CheckDataFS;
    procedure WMMinimize(var Msg: TMessage); message WM_Minimize;
    procedure WMDriveSettings(var Msg: TMessage); message WM_DriveSettings;
    {eigene Event-Handler}
    procedure DeviceArrival(Drive: string);
    procedure DeviceRemoval(Drive: string);
    procedure FileBrowserSelected(Sender: TObject);
    procedure HandleError(const ErrorCode: Byte; const Name: string);
    procedure HandleKeyboardShortcut(const Key: Word);
    procedure LangChange;
    procedure MessageShow(const s: string);
    procedure ProgressBarDoMarquee(const PB: Integer; const Active: Boolean);
    procedure ProgressBarHide(const PB: Integer);
    procedure ProgressBarShow(const PB, Max: Integer);
    procedure ProgressBarUpdate(const PB, Position: Integer);
    procedure SpaceMeterTypeChange;
    procedure UpdatePanels(const s1, s2: string);
    {Ole-Drop-Target-Funktionen}
    procedure InitDropTargets;
    procedure FreeDropTargets;
    procedure DropFileTargetTreeViewDragOver(Sender: TObject; ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
    procedure DropFileTargetTreeViewDrop(Sender: TObject; ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
    procedure DropFileTargetTreeViewLeave(Sender: TObject);
    {ActionList/Actions}
    procedure InitActions;
    procedure ActionUserAddFileExecute(Sender: TObject);
    procedure ActionUserAddFileForm2Execute(Sender: TObject);
    procedure ActionUserAddFolderExecute(Sender: TObject);
    procedure ActionUserDeleteAllExecute(Sender: TObject);
    procedure ActionUserTrackUpExecute(Sender: TObject);
    procedure ActionUserTrackDownExecute(Sender: TObject);
    procedure ActionUserToggleFileExplorerExecute(Sender: TObject);
    procedure ActionUserSettingsExecute(Sender: TObject);
    procedure ActionUserShowOutputWindowExecute(Sender: TObject);
    procedure ActionUserSpecialTabExecute(Sender: TObject);
    procedure ActionUserToggleLogWindowExecute(Sender: TObject);
    procedure ActionUserToggleExplorerLogExecute(Sender: TObject);
    procedure ImageTabInitRadioButtons;
  public
    { Public declarations }
  end;

var CdrtfeMainForm: TCdrtfeMainForm;

implementation

{$R *.DFM}
{$R ../resource/icons.res}
{$R ../resource/buttons.res}
{$R ../resource/toolbuttons.res}
{$R ../resource/logo.res}

uses frm_datacd_fs, frm_datacd_options, frm_datacd_fs_error,
     frm_audiocd_options, frm_audiocd_tracks,
     frm_xcd_options, frm_settings, frm_about, frm_output,
     frm_videocd_options, frm_dae_options,
     cl_cdrtfedata, cl_devicechange, cl_sessionimport,
     {$IFDEF ShowTime} cl_timecount, {$ENDIF}
     {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     {$IFDEF WriteLogfile} f_logfile, {$ENDIF}
     {$IFDEF ShowCDTextInfo} f_cdtext, {$ENDIF}
     {$IFDEF AddCDText} f_cdtext, {$ENDIF}
     f_filesystem, f_process, f_window, f_strings, f_largeint, f_init, f_helper,
     f_checkproject, f_foldernamecache, f_screensaversup, f_locations,
     f_treelistfuncs, f_dischelper, f_instance, f_compprop, f_cygwin, f_system,
     const_tabsheets, const_common, const_locations;

var DeviceChangeNotifier: TDeviceChangeNotifier;
    {$IFDEF ShowTime}
    TC, TC2: TTimeCount;
    {$ENDIF}

{ Messagehandling ------------------------------------------------------------ }

{ WMCopyData -------------------------------------------------------------------

  Nimmt Dateinamen entgegen und fügt sie der aktuellen Dateiliste hinzu, wenn
  WM_COPYDATA empfangen wird.                                                  }

procedure TCdrtfeMainForm.WMCopyData(var Msg: TWMCopyData);
var temp: PChar;
    FolderAdded: Boolean;
begin
  temp := Msg.CopyDataStruct.lpData;
  AddToPathList(string(temp));
  {Flag setzen, wenn Order hinzugefügt wurde}
  FolderAdded := DirectoryExists(string(temp));
  AddToPathlistSort(FolderAdded);
end;

{ WMDROPFILES ------------------------------------------------------------------

  WMDROPFILES nimmt Datei- und Verzeichnisnamen entgegen, wenn per Drag-and-Drop
  diese aus dem Explorer auf cdrtfe gezogen werden.                            }

procedure TCdrtfeMainForm.WMDROPFILES (var Msg: TMessage);
var FileList   : TStringList;
begin
  inherited;
  FileList := TStringList.Create;
  Self.StatusBar.Panels[0].Text := FLang.GMS('m116');
  GetDragQueryFileList(Msg.WParam, FileList, True);
  AddListToPathList(FileList);
  FileList.Free;
end;

{ WMButtonsOff/On --------------------------------------------------------------

  Ermöglichen das (De-)Aktivieren der Buttons aus einer anderen Klasse  heraus,
  ohne direkten Zugriff auf die Controls.                                      }

procedure TCdrtfeMainForm.WMButtonsOff(var Msg: TMessage);
begin
  SetButtons(oOff);
end;

procedure TCdrtfeMainForm.WMButtonsOn(var Msg: TMessage);
begin
  SetButtons(oOn);
end;

{ WMFTerminated ----------------------------------------------------------------

  Wenn WM_FTerminated empfangen wird, ist der Thread, der Dateiduplikate sucht
  beendet worden.                                                              }

procedure TCdrtfeMainForm.WMFTerminated(var Msg: TMessage);
begin
  {$IFDEF DebugFindDups}
  SendMessage(Handle, WM_VTerminated, 0, 0);
  exit;
  {$ENDIF}
  if (Msg.WParam = -1) and (Msg.LParam = -1) then
  begin
    {Suche wurde vom User abgebrochen}
    SendMessage(Handle, WM_VTerminated, 0, 0);
  end else
  begin
    {WParam: high order longword, LParam: low order longword von FDupSize}
    // Memo1.Lines.Add(SizeToString(Msg.WParam));
    // Memo1.Lines.Add(SizeToString(Msg.LParam));
    // Memo1.Lines.Add(SizeToString(IntToComp(Msg.LParam, Msg.WParam)));
    FAction.DuplicateFileSize := IntToComp(Msg.LParam, Msg.WParam);
    StatusBar.Panels[1].Text := '';
    UpdateGauges;
    FAction.Action := FSettings.General.Choice;
    FAction.StartAction;
  end;
end;

{ WMITerminated ----------------------------------------------------------------

  Wenn WM_ITerminated empfangen wird, ist der Thread, der die XCD-Info-Datei
  erstellt, beendet worden.                                                    }

procedure TCdrtfeMainForm.WMITerminated(var Msg: TMessage);
begin
  {$IFDEF DebugCreateInfoFile}
  SendMessage(Handle, WM_VTerminated, 0, 0);
  exit;
  {$ENDIF}
  if (Msg.WParam = -1) and (Msg.LParam = -1) then
  begin
    {Suche wurde vom User abgebrochen}
    FAction.CleanUp(1);
    SendMessage(Handle, WM_VTerminated, 0, 0);
  end else
  begin
    {Datei zu den Daten hinzufügen}
    FData.AddToPathlist(FSettings.XCD.XCDInfoFile, '', cXCD);
    StatusBar.Panels[1].Text := '';
    UpdateGauges;
    FAction.Action := FSettings.General.Choice;
    FAction.StartAction;
  end;
end;

{ WMTTerminated ----------------------------------------------------------------

  Wenn WM_TTerminated empfangen wird, ist der zweite Thread beendet worden.    }

procedure TCdrtfeMainForm.WMTTerminated(var Msg: TMessage);
var Ok: Boolean;
begin
  {$IFDEF ShowCmdError}
  FExitCode := Msg.wParam;
  Ok := FExitCode = 0;
  {$ENDIF}
  TLogWin.Inst.ProgressBarDoMarquee(False);
  {EnvironmentBlock entsorgen, falls nötig}
  if FSettings.Environment.EnvironmentSize > 0 then CheckEnvironment(FSettings);
  {Aufräumen: aufgrund des Multithreadings hierher verschoben}
  FAction.CleanUp(2);  
  {Thread zu Vergleichen der Dateien starten}
  if not Ok then
  begin
    {Im Fehlerfaller abbrechen}
    SendMessage(Handle, WM_VTerminated, 0, 0);
  end else
  if (FAction.LastAction = cDataCD) and FSettings.DataCD.Verify  and
     not ((FSettings.DataCD.ImageOnly and not FSettings.DataCD.OnTheFly)
          or FSettings.Cdrecord.Dummy) then
  begin
    FAction.Action := cVerify;
    FAction.StartAction;
  end else
  if (FAction.LastAction = cXCD) and FSettings.XCD.Verify  and
     not (FSettings.XCD.ImageOnly or FSettings.Cdrecord.Dummy) then
  begin
    FAction.Action := cVerifyXCD;
    FAction.StartAction;
  end else
  if (FAction.LastAction = cDVDVideo) and FSettings.DVDVideo.Verify  and
     not ((FSettings.DVDVideo.ImageOnly and not FSettings.DVDVideo.OnTheFly)
          or FSettings.Cdrecord.Dummy) then
  begin
    FAction.Action := cVerifyDVDVideo;
    FAction.StartAction;
  end else
  {1:1-Kopie: Nach dem Auslesen gleich schreiben}
  if (FAction.LastAction = cCDImage) and FSettings.Readcd.DoCopy and
     FSettings.General.ImageRead and FSettings.General.CDCopy then
  begin
    FAction.Action := cCDImage;
    FAction.StartAction;
  end else
  if (FAction.LastAction = cCDImage) and FSettings.Image.Verify  and
     not FSettings.Cdrecord.Dummy and not FSettings.General.ImageRead then
  begin
    if LowerCase(ExtractFileExt(FSettings.Image.IsoPath)) = cExtISO then
    begin
      FAction.Action := cVerifyISOImage;
      FAction.StartAction;
    end else
      SendMessage(Handle, WM_VTerminated, 0, 0);
  end else
  {1:1-Kopie (Audio-CD): Nach dem Auslesen sofort schreiben}
  if (FAction.LastAction = cDAE) and FSettings.General.CDCopy then
  begin
    FAction.Action := cDAE;
    FAction.StartAction;
  end else
  begin
    {Falls kein Vergleich stattfindet, gleich weiter}
    SendMessage(Handle, WM_VTerminated, 0, 0);
  end;
end;

{ WMVTerminated ----------------------------------------------------------------

  Wenn WM_VTerminated empfangen wird, ist der dritte Thread beendet bzw. gar
  nicht gestartet worden.                                                      }

procedure TCdrtfeMainForm.WMVTerminated(var Msg: TMessage);
var LogFile: string;
begin
  {$IFDEF ShowExecutionTime}
  TC2.StopTimeCount;
  TLogWin.Inst.Add('Time: ' + TC2.TimeAsString);
  {$ENDIF}
  {Die XCD-Info-Datei darf erst nach dem Vergleich entsorgt werden.}
  FAction.CleanUp(3);
  with FSettings.CmdLineFlags do
  begin
    {Flag für automatisches Brennen zurücksetzten}
    if ExecuteProject then ExecuteProject := False;
    {Buttons freigeben}
    SetButtons(oOn);
    StatusBar.Panels[1].Text := '';
    UpdateGauges;
    {Log-File schreiben}
    if WriteLogFile then
    begin
      if FSettings.General.LastProject = '' then
      begin
        LogFile := ProgDataDir + '\cdrtfe.log';
      end else
      begin
        LogFile := FSettings.General.LastProject + '.log';
      end;
      TLogWin.Inst.SaveLog(LogFile);
    end;
    {automatisches Beenden}
    if ExitAfterExecution then
    begin
      Application.Terminate;
    end;
  end;
  {Hinweis, falls Fehler aufgetreten ist}
  {$IFDEF ShowCmdError}
  CheckExitCode;
  {$ENDIF}
end;

{ WMActivate[Data|Audio|Xcd|Vcd]Tab --------------------------------------------

  Wenn eine dieser Messages empfangen wird, ist die entsprechende Registerkarte
  in den Vordergrund zu bringen.                                               }

procedure TCdrtfeMainForm.WMActivateDataTab(var Msg: TMessage);
begin
  ActivateTab(cDataCD);
end;

procedure TCdrtfeMainForm.WMActivateAudioTab(var Msg: TMessage);
begin
  ActivateTab(cAudioCD);
end;

procedure TCdrtfeMainForm.WMActivateXcdTab(var Msg: TMessage);
begin
  ActivateTab(cXCD);
end;

procedure TCdrtfeMainForm.WMActivateVcdTab(var Msg: TMessage);
begin
  ActivateTab(cVideoCD);
end;

procedure TCdrtfeMainForm.WMActivateImgTab(var Msg: TMessage);
begin
  ActivateTab(cCDImage);
  RadioButtonImageWrite.Checked := True;
end;

procedure TCdrtfeMainForm.WMActivateDVDTab(var Msg: TMessage);
begin
  ActivateTab(cDVDVideo);
end;

{ WMUpdateGauges ---------------------------------------------------------------

  Wird diese Message empfangen, soll die Anzeige der Statusinformationen
  aktualisiert werden.                                                         }

procedure TCdrtfeMainForm.WMUpdateGauges(var Msg: TMessage);
begin
  UpdateGauges;
end;

{ WMExecute --------------------------------------------------------------------

  Wenn WM_EXECUTE empfangen wird, soll automatisch gestartet werden.           }

procedure TCdrtfeMainForm.WMExecute(var Msg: TMessage);
begin
  FSettings.CmdLineFlags.ExecuteProject := True;
  Self.Activate;
end;

{ WMExitAfterExecute -----------------------------------------------------------

  Wenn WM_ExitAfterExecute empfangen wird, soll cdrtfe nach dem automatischen
  Start beendet werden.                                                        }

procedure TCdrtfeMainForm.WMExitAfterExecute(var Msg: TMessage);
begin
  FSettings.CmdLineFlags.ExitAfterExecution := True;
end;

{ WMWriteLog -------------------------------------------------------------------

  Wenn WM_WriteLog empfangen wird, soll eine Log-Datei angelegt werden, die alle
  Ausgabe der Konsolenprogramme enthält.                                       }

procedure TCdrtfeMainForm.WMWriteLog(var Msg: TMessage);
begin
  FSettings.CmdLineFlags.WriteLogFile := True;
end;

{ WMCheckDataFS ----------------------------------------------------------------

  Wird WM_CheckDataFS empfangen, soll das Dateisystem der CD geprüft werden.   }

procedure TCdrtfeMainForm.WMCheckDataFS(var Msg: TMessage);
begin
  CheckDataCDFS(False);
end;

{ WMMinimize -------------------------------------------------------------------

  Wird WM_Minimize empfangen, soll das Hauptfenster minimiert werden.   }

procedure TCdrtfeMainForm.WMMinimize(var Msg: TMessage);
begin
  FSettings.CmdLineFlags.Minimize := True;
end;

{ WMDriveSettings --------------------------------------------------------------

  Wird WM_DriveSettings empfangen, haben sich Einstellungen für die Laufwerke
  geändert.                                                                    }

procedure TCdrtfeMainForm.WMDriveSettings(var Msg: TMessage);
begin
  {$IFDEF WRiteLogFile} AddLogCode(1057); {$ENDIF}
  if Msg.WParam = wmwpDrvSetSCSIChange then
  begin
    UpdatePanels('<>', FLang.GMS('m123'));
    {anderes SCSI-Interface -> Rescan}
    SetSCSIInterface(FSettings.Drives.SCSIInterface);
    FDevices.Rescan;
    CheckControls;
    UpdatePanels('<>', '');
  end;
end;


{ Drop-Target-Funktionen ----------------------------------------------------- }

{ InitDropTargets --------------------------------------------------------------

  InitDropTargets initialisiert die DropFileTarget-Komponenten.                }

procedure TCdrtfeMainForm.InitDropTargets;
begin
  {CDETreeView}
  DropFileTargetCDETreeView := TDropFileTarget.Create(Self);
  DropFileTargetCDETreeView.OnDragOver := DropFileTargetTreeViewDragOver;
  DropFileTargetCDETreeView.OnDrop := DropFileTargetTreeViewDrop;
  DropFileTargetCDETreeView.OnLeave := DropFileTargetTreeViewLeave;
  DropFileTargetCDETreeView.Dragtypes := [dtCopy];
  DropFileTargetCDETreeView.Register(CDETreeView);
  {XCDETreeView}
  DropFileTargetXCDETreeView := TDropFileTarget.Create(Self);
  DropFileTargetXCDETreeView.OnDragOver := DropFileTargetTreeViewDragOver;
  DropFileTargetXCDETreeView.OnDrop := DropFileTargetTreeViewDrop;
  DropFileTargetXCDETreeView.OnLeave := DropFileTargetTreeViewLeave;
  DropFileTargetXCDETreeView.Dragtypes := [dtCopy];
  DropFileTargetXCDETreeView.Register(XCDETreeView);
end;

{ FreeDropTargets --------------------------------------------------------------

  FreeDropTargets gibt die DropFileTarget-Komponenten wieder frei.             }

procedure TCdrtfeMainForm.FreeDropTargets;
begin
  DropFileTargetCDETreeView.UnregisterAll;
  DropFileTargetXCDETreeView.UnregisterAll;  
end;

{ DropFileTargetTreeView-Events ---------------------------------------------- }

{ DropFileTargetTreeViewDragOver -----------------------------------------------

  regelt das Verhalten bei OLE-DragOver-Ereignissen.                           }

procedure TCdrtfeMainForm.DropFileTargetTreeViewDragOver(Sender: TObject;
                                                ShiftState: TShiftState;
                                                Point: TPoint;
                                                var Effect: Integer);
var Tree: TTreeView;
    Node: TTreeNode;
    DoRepaint: Boolean;
begin
  DoRepaint := False;
  Tree := ((Sender as TDropFileTarget).Target as TTreeView);
  if (Point.Y > Tree.Height - 20) and (Point.Y < Tree.Height) then
  begin
    Tree.Perform(WM_VSCROLL, SB_LINEDOWN, 0);
    DoRepaint := True;
  end;
  if (Point.Y < 20) {and (Tree.TopItem <> Tree.Items[0]) }then
  begin
    Tree.Perform(WM_VSCROLL, SB_LINEUP, 0);
    DoRepaint := True;
  end;
  {Zielknoten markieren}
  Node := Tree.GetNodeAt(Point.X, Point.Y);
  if Tree.DropTarget <> Node then
  begin
    (Sender as TDropfileTarget).ShowImage := False;
    Tree.DropTarget := Node;
    (Sender as TDropfileTarget).ShowImage := True;
  end;
  {automatisches Expandieren}
  if Node <> nil then
    if Node.HasChildren and not Node.Expanded then
    begin
      ExpandNodeDelayed(Node, False);
    end;
  if DoRepaint then
  begin
    (Sender as TDropfileTarget).ShowImage := False;
    Tree.Repaint;
    (Sender as TDropfileTarget).ShowImage := True;
  end;
end;

{ DropFileTargetTreeViewDrop ---------------------------------------------------

  regelt das Verhalten bei OLE-Drop-Ereignissen.                               }

procedure TCdrtfeMainForm.DropFileTargetTreeViewDrop(Sender: TObject;
                                            ShiftState: TShiftState;
                                            Point: TPoint; var Effect: Integer);
var FolderAdded: Boolean;
    i          : Integer;
    FileName   : string;
    Tree       : TTreeView;
    // OldNode    : TTreeNode;
begin
  FolderAdded := False;
  Self.StatusBar.Panels[0].Text := FLang.GMS('m116');
  {aktuellen Knoten bestimmen}
  Tree := ((Sender as TDropFileTarget).Target as TTreeView);;
  SelectRootIfNoneSelected(Tree);
  // OldNode := Tree.Selected;
  if Tree.DropTarget <> nil then Tree.Selected := Tree.DropTarget;
  {Dateien hinzufügen}
  for i := 0 to (Sender as TDropFileTarget).Files.Count - 1 do
  begin
    FileName := (Sender as TDropFileTarget).Files[i];
    AddToPathList(FileName);
    {Flag setzen, wenn Order hinzugefügt wurde}
    if not FolderAdded then
    begin
      if DirectoryExists(FileName) then FolderAdded := True;
    end;
  end;
  // Tree.Selected := OldNode;
  Tree.DropTarget := nil;
  {Ordner sortieren}
  AddToPathlistSort(FolderAdded);
end;

procedure TCdrtfeMainForm.DropFileTargetTreeViewLeave(Sender: TObject);
begin
  CDETreeView.DropTarget := nil;
  XCDETreeView.DropTarget := nil;
end;


{ Lesen/Speichern der Einstellungen ------------------------------------------ }

{ GetSettings ------------------------------------------------------------------

  GetSettings setzt die Controls des Fensters entsprechend den Daten in
  FSettings.                                                                   }

procedure TCdrtfeMainForm.GetSettings;
var i: Integer;
begin
  {allgemein}
  MainMenuReloadDefaults.Enabled := FSettings.FileFlags.IniFileOk;
  MainMenuCdrtfeIni.Enabled := FileExists(FSettings.General.IniFile);
  CheckBoxDummy.Checked := FSettings.Cdrecord.Dummy;
  {Devices, Speeds}
  for i := 1 to TabSheetCount do
  begin
    if ComboBoxDrives.Items.Count <= FSettings.General.TabSheetDrive[i] then
    begin
      ComboBoxDrives.ItemIndex := 0;
      FSettings.General.TabSheetDrive[i] := 0;
    end;
  end;
  {Data-CD}
  with FSettings.DataCD do
  begin
    CheckBoxDataCDVerify.Checked := Verify;
    FData.SetCDLabel(VolID, cDataCD);
  end;
  {XCD}
  with FSettings.XCD do
  begin
    CheckBoxXCDVerify.Checked := Verify;
    FData.SetCDLabel(VolID, cXCD);
  end;
  {CDRW}
  with FSettings.CDRW do
  begin
    RadioButtonCDRWBlankAll.Checked         := All;
    RadioButtonCDRWBlankFast.Checked        := Fast;
    RadioButtonCDRWBlankOpenSession.Checked := OpenSession;
    RadioButtonCDRWBlankSession.Checked     := BlankSession;
    CheckBoxCDRWBlankForce.Checked          := Force;
  end;
  {CDInfos}
  with FSettings.CDInfo do
  begin
    RadioButtonScanbus.Checked  := Scanbus;
    RadioButtonPrcap.Checked    := Prcap;
    RadioButtonToc.Checked      := Toc;
    RadioButtonAtip.Checked     := Atip;
    RadioButtonMSInfo.Checked   := MSInfo;
    RadioButtonMInfo.Checked    := MInfo;    
    RadioButtonCapacity.Checked := CapInfo;
    RadioButtonMetaData.Checked := MetaInfo;
  end;
  {DAE}
  with FSettings.DAE do
  begin
    EditDAEPath.Text               := Path;
  end;
  {Image}
  RadioButtonImageRead.Checked := FSettings.General.ImageRead;
  RadioButtonImageWrite.Checked := not FSettings.General.ImageRead;  
  with FSettings.Readcd do
  begin
    EditReadCDIsoPath.Text          := IsoPath;
    EditReadCDStartSec.Text         := StartSec;
    EditReadCDEndSec.Text           := EndSec;
    CheckBoxReadCDNoerror.Checked   := Noerror;
    CheckBoxReadCDNocorr.Checked    := Nocorr;
    CheckBoxReadCDClone.Checked     := Clone;
    CheckBoxReadCDRange.Checked     := Range;
    CheckBoxReadCDWriteCopy.Checked := DoCopy;
    EditReadCDRetries.Text          := Retries;
  end;
  with FSettings.Image do
  begin
    EditImageIsoPath.Text          := IsoPath;
    RadioButtonImageTAO.Checked    := TAO;
    RadioButtonImageDAO.Checked    := DAO;
    RadioButtonImageRAW.Checked    := RAW;
    CheckBoxISOVerify.Checked      := Verify;
    if RawMode = 'raw96r' then
    begin
      RadioButtonImageRaw96r.Checked := True;
    end else
    if RawMode = 'raw96p' then
    begin
      RadioButtonImageRaw96p.Checked := True;
    end else
    if RawMode = 'raw16' then
    begin
      RadioButtonImageRaw16.Checked := True;
    end;
    CheckBoxImageOverburn.Checked := Overburn;
    CheckBoxImageClone.Checked := Clone;
    CheckBoxImageCDText.Checked := CDText;
  end;
  {DVD-Video}
  with FSettings.DVDVideo do
  begin
    EditDVDVideoSourcePath.Text := SourcePath;
    EditDVDVideoVolID.Text := VolID;
    CheckBoxDVDVideoVerify.Checked := Verify;
  end;
end;

{ SetSettings ------------------------------------------------------------------

  SetSettings übernimmt die Einstellungen der Controls in FSettings.           }

procedure TCdrtfeMainForm.SetSettings;
var i   : Integer;
    Temp: string;

  {Der Übersichtlichkeit wegen wurde die Bestimmung des gewählten Laufwerks und
   der Geschwindigkeit in eigene Funktionen ausgelagert.}
  function GetDevice(Choice: Byte): string;
  var Index: Byte;
      DeviceList: TStringList;
  begin
    with FDevices do
    begin
      case Choice of
        cDataCD,
        cAudioCD,
        cXCD,
        cCDRW,
        cVideoCD,
        cDVDVideo: DeviceList := CDWriter;
        cCDInfos : DeviceList := CDDevices;
        cDAE     : DeviceList := CDDevices;
      else
        if RadioButtonImageRead.Checked then
        begin
          DeviceList := CDDevices;
        end else
        begin
          DeviceList := CDWriter;
        end;
      end;
      Index := FSettings.General.TabSheetDrive[Choice];
      // Result := DeviceList.Values[DeviceList.Names[Index]];
      Result := GetValueFromString(DeviceList[Index]);
    end;
  end;

  function GetSpeed(Choice: Byte): string;
  var Index: Integer;
  begin
    Result := '';
    Index := FSettings.General.TabSheetSpeed[Choice];
    if Index <> -1 then
    begin
      Result := ComboBoxSpeed.Items[Index]
    end;
  end;

begin
  {allgemein}
  FSettings.Cdrecord.Dummy := CheckBoxDummy.Checked;
  {Data-CD}
  with FSettings.DataCD do
  begin
    Verify := CheckBoxDataCDVerify.Checked;
    Device := GetDevice(cDataCD);
    Speed  := GetSpeed(cDataCD);
    VolId  := FData.GetCDLabel(cDataCD);
  end;
  {Audio-CD}
  with FSettings.AudioCD do
  begin
    Device := GetDevice(cAudioCD);
    Speed  := GetSpeed(cAudioCD);
  end;
  {xCD}
  with FSettings.XCD do
  begin
    Verify := CheckBoxXCDVerify.Checked;
    Device := GetDevice(cXCD);
    Speed  := GetSpeed(cXCD);
    VolId  := FData.GetCDLabel(cXCD);
  end;
  {CDRW}
  with FSettings.CDRW do
  begin
    All          := RadioButtonCDRWBlankAll.Checked;
    Fast         := RadioButtonCDRWBlankFast.Checked;
    OpenSession  := RadioButtonCDRWBlankOpenSession.Checked;
    BlankSession := RadioButtonCDRWBlankSession.Checked;
    Force        := CheckBoxCDRWBlankForce.Checked;
    Device       := GetDevice(cCDRW);
  end;
  {CDInfos}
  with FSettings.CDInfo do
  begin
    Scanbus  := RadioButtonScanbus.Checked;
    Prcap    := RadioButtonPrcap.Checked;
    Toc      := RadioButtonToc.Checked;
    Atip     := RadioButtonAtip.Checked;
    MSInfo   := RadioButtonMSInfo.Checked;
    MInfo    := RadioButtonMInfo.Checked;
    CapInfo  := RadioButtonCapacity.Checked;
    MetaInfo := RadioButtonMetaData.Checked;
    Device   := GetDevice(cCDInfos);
  end;
  {DAE}
  with FSettings.DAE do
  begin
    Path       := EditDAEPath.Text;
    Device     := GetDevice(cDAE);
    Speed      := GetSpeed(cDAE);
    {ausgwählte Tracks merken}
    Temp := '';
    for i := 0 to (DAEListView.Items.Count - 1) do
    begin
      if DAEListView.Items[i].Selected then
      begin
        Temp := Temp + IntToStr(i + 1) + ',';
      end;
    end;
    {Letztes ',' entfernen, da sich TStringlist.Commatext je nach Compiler
     unterschiedlich verhält}
    Delete(Temp, Length(Temp), 1);
    Tracks := Temp;
  end;
  {Image}
  FSettings.General.ImageRead := RadioButtonImageRead.Checked;
  with FSettings.Readcd do
  begin
    IsoPath  := EditReadCDIsoPath.Text;
    StartSec := EditReadCDStartSec.Text;
    EndSec   := EditReadCDEndSec.Text;
    Noerror  := CheckBoxReadCDNoerror.Checked;
    Nocorr   := CheckBoxReadCDNocorr.Checked;
    Clone    := CheckBoxReadCDClone.Checked;
    Range    := CheckBoxReadCDRange.Checked;
    Device   := GetDevice(cCDImage);
    Speed    := GetSpeed(cCDImage);
    DoCopy   := CheckBoxReadCDWriteCopy.Checked;
    Retries  := EditReadCDRetries.Text;
  end;
  with FSettings.Image do
  begin
    IsoPath    := EditImageIsoPath.Text;
    TAO        := RadioButtonImageTAO.Checked;
    DAO        := RadioButtonImageDAO.Checked;
    RAW        := RadioButtonImageRAW.Checked;
    Verify     := CheckBoxISOVerify.Checked;                
    if RadioButtonImageRaw96r.Checked then
    begin
      RawMode := 'raw96r';
    end else
    if RadioButtonImageRaw96p.Checked then
    begin
      RawMode := 'raw96p';
    end else
    if  RadioButtonImageRaw16.Checked then
    begin
      RawMode := 'raw16';
    end;
    OverBurn := CheckBoxImageOverburn.Checked;
    Clone    := CheckBoxImageClone.Checked;
    CDText   := CheckBoxImageCDText.Checked;
    Device   := GetDevice(cCDImage);
    Speed    := GetSpeed(cCDImage);
  end;
  {Video-CD}
  with FSettings.VideoCD do
  begin
    Device   := GetDevice(cVideoCD);
    Speed    := GetSpeed(cVideoCD);
  end;
  {DVD-Video}
  with FSettings.DVDVideo do
  begin
    SourcePath := EditDVDVideoSourcePath.Text;
    VolID    := EditDVDVideoVolID.Text;
    Device   := GetDevice(cDVDVideo);
    Speed    := GetSpeed(cDVDVideo);
    Verify   := CheckBoxDVDVideoVerify.Checked;
  end;
end;

{ InputOk ----------------------------------------------------------------------

  InputOk überprüft die eingaben auf Gültigkeit bzw. ob alle nötigen Infos
  vorhanden sind.                                                              }

function TCdrtfeMainForm.InputOk: Boolean;
begin
  Result := CheckProject(FData, FSettings, FLang);
end;

{ SaveProject ------------------------------------------------------------------

  SaveProject speichert die aktuellen Einstellungen und Dateilisten oder nur die
  Dateilisten, wenn ListsOnly = True. Aufruf erfolgt vom Hauptmenü aus.        }

procedure TCdrtfeMainForm.SaveProject(const ListsOnly: Boolean);
var DialogID: TDialogID;
begin
  if not ListsOnly then SetSettings;
  SaveDialog1 := TSaveDialog.Create(Self);
  if not ListsOnly then
  begin
    DialogID := DIDLoadProject;
    SaveDialog1.Title := FLang.GMS('m107');
    SaveDialog1.DefaultExt := 'cfp';
    SaveDialog1.Filter := FLang.GMS('f006');
  end else
  begin
    DialogID := DIDLoadList;
    SaveDialog1.Title := FLang.GMS('m121');
    SaveDialog1.DefaultExt := 'cfp.files';
    SaveDialog1.Filter := FLang.GMS('f008');
  end;
  SaveDialog1.InitialDir := GetCachedFolderName(DialogID);
  SaveDialog1.Options := [ofOverwritePrompt,ofHideReadOnly];
  if SaveDialog1.Execute then
  begin
    if not ListsOnly then
    begin
      FSettings.SaveToFile(SaveDialog1.FileName);
      FData.SaveToFile(SaveDialog1.FileName + '.files');
    end else
    begin
      FData.SaveToFile(SaveDialog1.FileName);
    end;
    CacheFolderName(DialogID, SaveDialog1.FileName);
  end;
  SaveDialog1.Free;
end;

{ LoadProject ------------------------------------------------------------------

  LoadProject lädt Einstellungen und Dateilisten oder nur die Dateilisten, wenn
  ListsOnly = True. Aufruf erfolgt vom Hauptmenü aus.                          }

procedure TCdrtfeMainForm.LoadProject(const ListsOnly: Boolean);
var i       : Byte;
    DialogID: TDialogID;
begin
  OpenDialog1 := TOpenDialog.Create(Self);
  if not ListsOnly then
  begin
    DialogID := DIDLoadProject;
    OpenDialog1.Title := FLang.GMS('m106');
    OpenDialog1.Filter := FLang.GMS('f006');
  end else
  begin
    DialogID := DIDLoadList;
    OpenDialog1.Title := FLang.GMS('m120');
    OpenDialog1.Filter := FLang.GMS('f008');
  end;
  OpenDialog1.InitialDir := GetCachedFolderName(DialogID);
  if OpenDialog1.Execute then
  begin
    CDETreeView.Selected := CDETreeView.Items[0];
    XCDETreeView.Selected := XCDETreeView.Items[0];
    if not ListsOnly then
    begin
      FSettings.LoadFromFile(OpenDialog1.FileName);
      FData.LoadFromFile(OpenDialog1.FileName + '.files');
    end else
    begin
      FData.LoadFromFile(OpenDialog1.FileName);
    end;
    CacheFolderName(DialogID, OpenDialog1.FileName);
  end;
  OpenDialog1.Free;
  if not ListsOnly then
  begin
    GetSettings;
    CheckControls;
  end;
  i := FSettings.General.Choice;
  {jetzt die Daten in GUI übernehmen}
  InitTreeViews;
  CDETreeView.Items[0].Expand(False);
  XCDETreeView.Items[0].Expand(False);
  FSettings.General.Choice := cAudioCD;
  ShowTracks;
  FSettings.General.Choice := cDAE;    
  ShowTracksDAE;
  FSettings.General.Choice := cVideoCD;
  ShowTracks;
  FSettings.General.Choice := i;
  ActivateTab(FSettings.General.Choice);
  UpdateOptionPanel;
  UpdateGauges;
end;


{ Bearbeitung der Dateilisten ------------------------------------------------ }

{ HandleError ------------------------------------------------------------------

  HandleError wertet den ErroCode aus UserAddTrack und AddToPathlist aus. Außer-
  dem kann diese Prozedur als Event-Handler für TProjectData und andere Objekte
  dienen.                                                                      }

procedure TCdrtfeMainForm.HandleError(const ErrorCode: Byte; const Name: string);
begin
  with TLogWin.Inst do
  begin
    case ErrorCode of
      PD_FolderNotUnique: Add(Format(FLang.GMS('e111'), [Name]));
      PD_FileNotUnique  : Add(Format(FLang.GMS('e112'), [Name]));
      PD_FileNotFound   : Add(Format(FLang.GMS('e113'), [Name]));
      PD_InvalidWaveFile: Add(Format(FLang.GMS('eprocs01'), [Name]));
      PD_InvalidMpegFile: Add(Format(FLang.GMS('eprocs02'), [Name]));
      PD_InvalidMP3File : Add(Format(FLang.GMS('eprocs03'), [Name]));
      PD_InvalidOggFile : Add(Format(FLang.GMS('eprocs04'), [Name]));
      PD_InvalidFLACFile: Add(Format(FLang.GMS('eprocs05'), [Name]));
      PD_InvalidApeFile : Add(Format(FLang.GMS('eprocs06'), [Name]));
      PD_NoMP3Support   : Add(Name + ': ' + FLang.GMS('minit09'));
      PD_NoOggSupport   : Add(Name + ': ' + FLang.GMS('minit10'));
      PD_NoFLACSupport  : Add(Name + ': ' + FLang.GMS('minit11'));
      PD_NoApeSupport   : Add(Name + ': ' + FLang.GMS('minit12'));
    end;
  end;
end;

{ CheckDataCDFS ----------------------------------------------------------------

  CheckDataCDFS überprüft das Dateisystem der Daten-CD auf zu lange Dateinamen
  und zu tief liegende Ordner.                                                 }

procedure TCdrtfeMainForm.CheckDataCDFS(const CheckAccess: Boolean);
var OldStatusText    : string;
    Path             : string;
    CheckFolder      : Boolean;
    FormDataCDFSError: TFormDataCDFSError;
begin
  {$IFDEF ShowTimeCheckFS}
  TC.StartTimeCount;
  {$ENDIF}
  OldStatusText := Self.StatusBar.Panels[0].Text;
  Self.StatusBar.Panels[0].Text := FLang.GMS('m118');
  {zu überprüfenden Ordner ermitteln}
  Path := GetPathFromNode(CDETreeView.Selected);
  {Verzeichnistiefe prüfen?}
  with FSettings.DataCD do
  begin
    {Anmerkung: Erlaubt UDF wirklich beliebig tief liegende Ordner?}
    CheckFolder := not (ISODeepDir or (ISOLevel and (ISOLevelNr = 4)) or UDF);
  end;
  FData.CheckDataCDFS(Path, FSettings.DataCD.GetMaxFileNameLength, CheckFolder,
                      CheckAccess);
  {$IFDEF DebugErrorLists}
  FormDebug.Memo2.Lines.Assign(FData.ErrorListFiles);
  FormDebug.Memo1.Lines.Assign(FData.ErrorListDir);
  FormDebug.Memo3.Lines.Assign(FData.NoAccessFiles);
  {$ENDIF}
  {Wenn Fehler gefunden, dann Dialog aufrufen}
  if FData.ErrorListFiles.Count > 0 then
  begin
    FormDataCDFSError := TFormDataCDFSError.Create(nil);
    try
      FormDataCDFSError.Data := FData;
      FormDataCDFSError.ImageLists := FImageLists;
      FormDataCDFSError.Lang := FLang;
      FormDataCDFSError.Settings := FSettings;
      FormDataCDFSError.Mode := mFiles;
      FormDataCDFSError.ShowModal;
      {Ordner sortieren, Namen könnten sich geändert haben}
      FData.SortFolder('', cDataCD);
      {Und eventuelle Änderungen im GUI nachvollziehen}
      UserAddFolderUpdateTree(CDETreeView);
    finally
      FormDataCDFSError.Release;
    end;
  end;
  {Verschachtelung der Ordner prüfen, falls zu tief, dann Dialog}
  if FData.ErrorListDir.Count > 0 then
  begin
    FormDataCDFSError := TFormDataCDFSError.Create(nil);
    try
      FormDataCDFSError.Data := FData;
      FormDataCDFSError.ImageLists := FImageLists;
      FormDataCDFSError.Lang := FLang;
      FormDataCDFSError.Settings := FSettings;
      FormDataCDFSError.Mode := mFolders;
      FormDataCDFSError.ShowModal;
    finally
      FormDataCDFSError.Release;
    end;
  end;
  {Quelldateien mit illegalen Dateinamen}
  if FData.InvalidSrcFiles.Count > 0 then
  begin
    FormDataCDFSError := TFormDataCDFSError.Create(nil);
    try
      FormDataCDFSError.Data := FData;
      FormDataCDFSError.ImageLists := FImageLists;
      FormDataCDFSError.Lang := FLang;
      FormDataCDFSError.Settings := FSettings;
      FormDataCDFSError.Mode := mInvalidFiles;
      FormDataCDFSError.ShowModal;
    finally
      FormDataCDFSError.Release;
    end;
  end;
  {Quelldateien, auf die nicht zugegriffen werden kann}
  if FData.NoAccessFiles.Count > 0 then
  begin
    FormDataCDFSError := TFormDataCDFSError.Create(nil);
    try
      FormDataCDFSError.Data := FData;
      FormDataCDFSError.ImageLists := FImageLists;
      FormDataCDFSError.Lang := FLang;
      FormDataCDFSError.Settings := FSettings;
      FormDataCDFSError.Mode := mNoAccess;
      FormDataCDFSError.ShowModal;
    finally
      FormDataCDFSError.Release;
    end;
  end;
  Self.StatusBar.Panels[0].Text := OldStatusText;
  {$IFDEF ShowTimeCheckFS}
  TC.StopTimeCount;
  TLogWin.Inst.Add('check FS  : ' + TC.TimeAsString);
  {$ENDIF}
end;

{ AddFromClipboard -------------------------------------------------------------

  AddFromClipborad fügt Dateien aus der Zwischenablage ein.                    }

procedure TCdrtfeMainForm.AddFromClipboard;
var Handle  : THandle;
    FileList: TStringList;
begin
  if Clipboard.HasFormat(CF_HDROP) then
  begin
    FileList := TStringList.Create;
    Clipboard.Open;
    try
      Handle := Clipboard.GetAsHandle(CF_HDROP);
      if Handle <> 0 then
      begin
        GetDragQueryFileList(Handle, FileList, False);
        AddListToPathList(FileList);        
      end;
    finally
      Clipboard.Close;
      FileList.Free;
    end;
  end;
end;

{ AddListToPathList ------------------------------------------------------------

  fügt den Inhalt von List zur Pfadliste hinzu.                                }

procedure TCdrtfeMainForm.AddListToPathList(List: TStringList);
var i       : Integer;
    FolderAdded: Boolean;
begin
  FolderAdded := False;
  for i := 0 to List.Count - 1 do
  begin
    AddToPathList(List[i]);
    {Flag setzen, wenn Order hinzugefügt wurde}
    if not FolderAdded then
    begin
      if DirectoryExists(List[i]) then FolderAdded := True;
    end;
  end;
  {Ordner sortieren}
  AddToPathlistSort(FolderAdded);
end;

{ AddToPathlist ----------------------------------------------------------------

  AddToPathlist fügt Dateien oder Ordner in die Pfadlisten ein, wenn die Aktion
  über die Kommandozeile oder per Drag-and-Drop ausgelöst wurde. Hierbei
  auftretende Fehler werden direkt im Memo angezeigt und nicht über eine eigene
  Message-Box.                                                                 }

procedure TCdrtfeMainForm.AddToPathList(const FileName: string);
var Path: string;
begin
  {sicherstellen, daß ein Knoten selektiert ist, und Pfad bestimmen}
  case FSettings.General.Choice of
    cDataCD  : begin
                 SelectRootIfNoneSelected(CDETreeView);
                 Path := GetPathFromNode(CDETreeView.Selected);
               end;
    cXCD     : begin
                 SelectRootIfNoneSelected(XCDETreeView);
                 Path := GetPathFromNode(XCDETreeView.Selected);
               end;
    cAudioCD : Path := '';
    cVideoCD : Path := '';
    cDVDVideo: if DirectoryExists(FileName) and IsValidDVDSource(FileName) then
                                            // temporary Hack
                 EditDVDVideoSourcePath.Text := FileName;
    cCDImage : EditImageIsoPath.Text := FileName;
  end;
  {$IFDEF DebugAddFilesDragDrop}
  Deb('Dateiname: ' + FileName, 3);
  Deb('Pfad     : ' + Path, 3);
  Deb('Choice   : ' + IntToStr(FSettings.General.Choice), 3);
  Deb('', 3);
  {$ENDIF}
  {Datei/Ordner hinzufügen}
  FData.AddToPathlist(FileName, Path, FSettings.General.Choice);
  {Fehler auswerten}
  HandleError(FData.LastError, FileName);
end;

{ AddToPathlistSort ------------------------------------------------------------

  AddToPathlistSort sortiert die Dateilisten, nachdem über AddToPathlist Dateien
  hinzugefügt wurden. Außerdem wird das GUI aktualisiert.                      }

procedure TCdrtfeMainForm.AddToPathlistSort(const FolderAdded: Boolean);
var Path: string;
begin
  {Ordner sortieren}
  case FSettings.General.Choice of
    cDataCD: begin
               Path := GetPathFromNode(CDETreeView.Selected);
               FData.SortFileList(Path, cDataCD);
               {Dateisystem prüfen}
               CheckDataCDFS(False);
             end;
    cXCD   : begin
               Path := GetPathFromNode(XCDETreeView.Selected);
               FData.SortFileList(Path, cXCD);
             end;
  end;
  {GUI aktualisieren}
  case FSettings.General.Choice of
    cDataCD : if FolderAdded then
              begin
                UserAddFolderUpdateTree(CDETreeView);
              end else
              begin
                ShowFolderContent(CDETreeView, CDEListView);
              end;
    cXCD    : if FolderAdded then
              begin
                UserAddFolderUpdateTree(XCDETreeView);
              end else
              begin
                ShowFolderContent(XCDETreeView, XCDEListView1);
              end;
    cAudioCD,
    cVideoCD: ShowTracks;
  end;
  UpdateGauges;
end;

{ UserAddFile ------------------------------------------------------------------

  UserAddFile fügt eine Datei hinzu, wenn die Aktion über das GUI ausgelöst
  wurde.                                                                       }

procedure TCdrtfeMainForm.UserAddFile(Tree: TTreeView);
var i        : Integer;
    Path     : string;
    ErrorCode: Byte;
    DialogID : TDialogID;
begin
  DialogID := DIDDummy;
  {sicherstellen, daß ein Knoten im Tree-View selektiert ist}
  SelectRootIfNoneSelected(Tree);
  Self.OpenDialog1 := TOpenDialog.Create(Self);
  case FSettings.General.Choice of
    cDataCD: begin
               Self.OpenDialog1.Title := FLang.GMS('m103');
               DialogID := DIDDataCDFile;
             end;
    cXCD   : begin
               if FSettings.General.XCDAddMovie then
               begin
                 Self.OpenDialog1.Title := FLang.GMS('m105');
                 Self.OpenDialog1.Filter := FLang.GMS('f005');
                 DialogID := DIDXCDFile2;
               end else
               begin
                 Self.OpenDialog1.Title := FLang.GMS('m103');
                 DialogID := DIDXCDFile;
               end;
             end;
  end;
  Self.OpenDialog1.InitialDir := GetCachedFolderName(DialogID);
  Self.OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist];
  if Self.OpenDialog1.Execute then
  begin
    Self.StatusBar.Panels[0].Text := FLang.GMS('m116');
    {Flag setzen, wenn 'normale' Dateien als Form2-Dateien ausgewählt werden}
    if Self.OpenDialog1.FilterIndex > 1 then
    begin
      FData.AddAsForm2 := True;
    end;
    {Pfad des gewählten Knotens feststellen}
    Path := GetPathFromNode(Tree.Selected);
    for i :=0 to Self.OpenDialog1.Files.Count - 1 do
    begin
      FData.AddToPathlist(OpenDialog1.Files[i], Path, FSettings.General.Choice);
      ErrorCode := FData.LastError;
      if ErrorCode = PD_FileNotUnique then
      begin
        ShowMsgDlg(Format(FLang.GMS('e112'), [OpenDialog1.Files[i]]),
                   FLang.GMS('g001'), MB_cdrtfeError);
      end;
    end;
    CacheFolderName(DialogID, OpenDialog1.FileName);
    {Dateiliste sortieren}
    FData.SortFileList(Path, Fsettings.General.Choice);
    if FSettings.General.Choice = cDataCD then
    begin
      CheckDataCDFS(False);
    end;
    UpdateGauges;
  end;
  Self.OpenDialog1.Free;
  {XCD-Flags zurücksetzen}
  if FSettings.General.Choice = cXCD then
  begin
    FSettings.General.XCDAddMovie := False;
    FData.AddAsForm2 := False;
  end;
end;

{ UserAddFolder ----------------------------------------------------------------

  UserAddFolder fügt einen Ordner hinzu, wenn die Aktion über das GUI aus-
  gelöst wurde.                                                                }

procedure TCdrtfeMainForm.UserAddFolder(Tree: TTreeView);
var Dir        : string;
    Name       : string;
    Path       : string;
    PathList   : TStringList;
    ErrorCode  : Byte;
    Count, i   : Integer;
    DialogID   : TDialogID;
    StartFolder: string;
begin
  case FSettings.General.Choice of
    cDataCD: DialogID := DIDDataCDFolder;
    cXCD   : DialogID := DIDXCDFolder;
  else
    DialogID := DIDDummy;
  end;
  StartFolder := GetCachedFolderName(DialogID);
  {sicherstellen, daß ein Knoten selektiert ist}
  SelectRootIfNoneSelected(Tree);
  PathList := TStringList.Create;
  {$IFDEF MultipleFolderBrowsing}
  Dir := ChooseMultipleFolders(FLang.GMS('g002'), FLang.GMS('g013'),
                               FLang.GMS('g012'), FLang.GMS('mlang02'),
                               FLang.GMS('mlang03'), Self.Handle, PathList,
                               StartFolder);
  Count := PathList.Count;
  {$ELSE}
  Dir := ChooseDir(FLang.GMS('g002'), StartFolder, Self.Handle);
  Count := 1;
  {$ENDIF}
  CacheFolderName(DialogID, Dir);
  for i := 0 to Count - 1 do
  begin
    {$IFDEF MultipleFolderBrowsing}
    Dir := PathList[i];
    {$ENDIF}
    Name := Dir;    
    Delete(Name, 1, LastDelimiter('\', Name));
    if Name <> '' then
    begin
      {$IFDEF ShowTimeAddFolder}
      TC.StartTimeCount;
      {$ENDIF}
      Path := GetPathFromNode(Tree.Selected);
      Self.StatusBar.Panels[0].Text := FLang.GMS('m117');
      {$IFDEF DebugAddFiles}
      Deb('', 3);
      Deb('calling AddToPathlist: add folder ' + Dir + '; Choice is: ' +
          IntToStr(FSettings.General.Choice), 3);
      {$ENDIF}
      FData.AddToPathlist(Dir, Path, FSettings.General.Choice);
      ErrorCode := FData.LastError;
      {$IFDEF ShowTimeAddFolder}
      TC.StopTimeCount;
      TLogWin.Inst.Add('add folder: ' + TC.TimeAsString);
      {$ENDIF}
      if ErrorCode = PD_FolderNotUnique then
      begin
        ShowMsgDlg(Format(FLang.GMS('e111'), [Name]), FLang.GMS('g001'),
                   MB_cdrtfeError);
      end else
      begin
        {Änderungen im GUI nachvollziehen}
        CheckDataCDFS(False);
        UserAddFolderUpdateTree(Tree);
        UpdateGauges;
      end;
    end;
  end;
  PathList.Free;
end;

{ UserAddFolderUpdateTree ------------------------------------------------------

  Nach dem Hinzufügen eines Ordners muß die Baumstruktur auf den neuesten Stand
  gebraht werden.                                                              }

procedure TCdrtfeMainForm.UserAddFolderUpdateTree(Tree: TTreeView);
var Path: string;
    Node: TTreeNode;
begin
  Path := GetPathFromNode(Tree.Selected);
  InitTreeView(Tree, FSettings.General.Choice);
  Node := GetNodeFromPath(Tree.Items[0], Path);
  Tree.Selected := Node;
  Node.Expand(False);
  case FSettings.General.Choice of
    cDataCD: ShowFolderContent(CDETreeView, CDEListView);
    cXCD   : ShowFolderContent(XCDETreeView, XCDEListView1);
  end;
end;

{ UserDeleteFile ---------------------------------------------------------------

  UserDeleteFile entfernt die im List-View selektierten Dateien aus dem ListView
  und der Dateiliste des TreeViews.                                            }

procedure TCdrtfeMainForm.UserDeleteFile(Tree: TTreeView; View: TListView);
var i       : Integer;
    Offset  : Integer;
    Meldung : string;
    Path    : string;
    DelPath : string;
    IsFolder: Boolean;
    Node    : TTreeNode;
    {$IFDEF DebugFileLists}
    FileList: TStringList;
    {$ENDIF}
begin
  Offset := View.Tag;
  if View.SelCount > 0 then
  begin
    Meldung := FLang.GMS('m115');
    if not FSettings.General.NoConfirm then
    begin
      i := ShowMsgDlg(Meldung, FLang.GMS('m110'), MB_cdrtfeConfirm);
    end else
    begin
      i := 1;
    end;
    if i = 1 then
    begin
      if FSettings.General.Choice in [cDataCD, cXCD] then
      begin
        Path := GetPathFromNode(Tree.Selected);
      end;
      if View.Selected <> nil then
      begin
        for i := (View.Items.Count - 1) downto 0 do
        begin
          if View.Items[i].Selected then
          begin
            IsFolder := ItemIsFolder(View.Items[i]);
            with FSettings.General do
            begin
              if Choice = cDataCD then
              begin
                if not IsFolder then
                  FData.DeleteFromPathlistByIndex(i - Offset, Path, Choice)
                else
                begin
                  DelPath := Path + View.Items[i].Caption + '/';
                  FData.DeleteFolder(DelPath, Choice);
                  Node := GetNodeFromPath(CDETreeView.Items[0], DelPath);
                  Node.Delete;
                end;
              end else
              if Choice = cXCD then
              begin
                if not IsFolder then
                  FData.DeleteFromPathlistByName(View.Items[i].Caption,
                                                 Path, Choice)
                else
                begin
                  DelPath := Path + View.Items[i].Caption + '/';
                  FData.DeleteFolder(DelPath, Choice);
                  Node := GetNodeFromPath(XCDETreeView.Items[0], DelPath);
                  Node.Delete;
                end;
              end else
              if Choice = cAudioCD then
              begin
                FData.DeleteFromPathlistByIndex(i, '', cAudioCD);
              end;
              if Choice = cVideoCD then
              begin
                FData.DeleteFromPathlistByIndex(i, '', cVideoCD);
              end;
              {Änderung im GUI nachvollziehen}
              View.Items[i].Delete;
            end;
          end;
        end;
        UpdateGauges;
      end;
      {Debugging: interne Pfadliste anzeigen}
      {$IFDEF DebugFileLists}
      case FSettings.General.Choice of
        cDataCD : ShowFolderContent(Tree, View);
        cXCD    : ShowFolderContent(Tree, XCDEListView1);
        cAudioCD: begin
                    FileList := FData.GetFileList('', cAudioCD);
                    FormDebug.Memo2.Lines.Assign(FileList);
                  end;
        cVideoCD: begin
                    FileList := FData.GetFileList('', cVideoCD);
                    FormDebug.Memo2.Lines.Assign(FileList);
                  end;
      end;
      {$ENDIF}
    end;
  end;
end;

{ UserDeleteFolder -------------------------------------------------------------

  UserDeleteFolder entfernt den ausgewählten Ordner aus der Zusammenstellung
  Daten-CD bzw. XCD, es sei denn, es handelt sich um das Wurzelverzeichnis.    }

procedure TCdrtfeMainForm.UserDeleteFolder(Tree: TTreeView);
var i: Integer;
    Meldung: string;
    Path: string;
begin
  Path := GetPathFromNode(Tree.Selected);
  if Path <> '' then
  begin
    Meldung := Format(FLang.GMS('m108'), [Tree.Selected.Text]);
    if not FSettings.General.NoConfirm then
    begin
      i := ShowMsgDlg(Meldung, FLang.GMS('m110'), MB_cdrtfeConfirm);
    end else
    begin
      i := 1;
    end;
    if i = 1 then
    begin
      {Ordner aus Datenstruktur löschen}
      FData.DeleteFolder(Path, FSettings.General.Choice);
      {entsprechenden Tree-Node löschen}
      Tree.Selected.Delete;
      UpdateGauges;
    end;
  end;
end;

{ UserDeleteAll ----------------------------------------------------------------

  UserDeleteAll löscht alle hinzugefügten Dateien und Ordner.                  }

procedure TCdrtfeMainForm.UserDeleteAll(Tree: TTreeView);
var i: Integer;
begin
  if not FSettings.General.NoConfirm then
  begin
    i := ShowMsgDlg(FLang.GMS('m114'), FLang.GMS('m110'), MB_cdrtfeConfirm);
  end else
  begin
    i := 1;
  end;
  if i = 1 then
  begin
    Tree.Selected := Tree.Items[0];
    case FSettings.General.Choice of
      cDataCD: begin
                 FData.DeleteAll(cDataCD);
                 InitTreeView(Tree, cDataCD);
                 {sicherstellen, daß ein Knoten im Tree-View selektiert ist}
                 SelectRootIfNoneSelected(Tree);
                 ShowFolderContent(Tree, CDEListView);
               end;
      cXCD   : begin
                 FData.DeleteAll(cXCD);
                 InitTreeView(Tree, cXCD);
                 SelectRootIfNoneSelected(Tree);
                 ShowFolderContent(Tree, XCDEListView1);
               end;
    end;
    UpdateGauges;
  end;
end;

{ UserMoveFile -----------------------------------------------------------------

  UerMoveFile verschiebt Dateien aus einem Verzeichnis in ein anderes.         }

procedure TCdrtfeMainForm.UserMoveFile(SourceNode, DestNode: TTreeNode;
                                       View: TListView);
var i          : Integer;
    Offset     : Integer;
    ErrorCode  : Byte;
    SourcePath,
    DestPath   : string;
    Node       : TTreeNode;
begin
   Offset := View.Tag;
   SourcePath := GetPathFromNode(SourceNode);
   DestPath := GetPathFromNode(DestNode);
   for i := View.Items.Count - 1 downto 0 do
   begin
     if View.Items[i].Selected then
     begin
       if not ItemIsFolder(View.Items[i]) then
       begin
         case FSettings.General.Choice of
           cDataCD: FData.MoveFileByIndex(i - Offset, SourcePath, DestPath,
                                          cDataCD);
           cXCD   : FData.MoveFileByName(View.Items[i].Caption, SourcePath,
                                         DestPath, cXCD);
         end;
       end else
       begin
         Node := nil;
         case FSettings.General.Choice of
           cDataCD: Node := GetNodeFromPath(CDETreeView.Items[0],
                                      SourcePath + View.Items[i].Caption + '/');
           cXCD   : Node := GetNodeFromPath(XCDETreeView.Items[0],
                                      SourcePath + View.Items[i].Caption + '/');
         end;
         if Node <> DestNode then UserMoveFolder(Node, DestNode);
       end;
       ErrorCode := FData.LastError;
       if ErrorCode = PD_FileNotUnique then
       begin
         ShowMsgDlg(Format(FLang.GMS('e112'), [View.Items[i].Caption]),
                    FLang.GMS('e108'), MB_cdrtfeError);
       end else
       if ErrorCode = PD_PreviousSession then
       begin
         ShowMsgDlg(FLang.GMS('e117'), FLang.GMS('e108'), MB_cdrtfeError);
       end else
       begin
         if not ItemIsFolder(View.Items[i]) then
         begin
           {geänderte Dateiliste sortieren}
           FData.SortFileList(DestPath, FSettings.General.Choice);
           {Änderungen auch im GUI  nachvollziehen}
           View.Items.BeginUpdate;
           View.Items[i].Delete;
           View.Items.EndUpdate;
         end;
       end;
     end;
   end;
   case FSettings.General.Choice of
     cDataCD: ShowFolderContent(CDETreeView, CDELIstView);
     cXCD   : ShowFolderContent(XCDETreeView, XCDEListView1);
   end;
end;

{ UserMoveFolder ---------------------------------------------------------------

  UerMoveFolder verschiebt einen Ordner in einen anderen.                      }

procedure TCdrtfeMainForm.UserMoveFolder(SourceNode, DestNode: TTreeNode);
var SourcePath, DestPath: string;
    ErrorCode: Byte;
begin
   SourcePath := GetPathFromNode(SourceNode);
   DestPath := GetPathFromNode(DestNode);
   FData.MoveFolder(SourcePath, DestPath, FSettings.General.Choice);
   ErrorCode := FData.LastError;
   if ErrorCode = PD_DestFolderIsSubFolder then
   begin
     ShowMsgDlg(FLang.GMS('e109'), FLang.GMS('e108'), MB_cdrtfeError);
   end else
   if ErrorCode = PD_FolderNotUnique then
   begin
     ShowMsgDlg(Format(FLang.GMS('e111'), [SourceNode.Text]), FLang.GMS('e108'),
                MB_cdrtfeError);
   end else
   if ErrorCode = PD_PreviousSession then
   begin
     ShowMsgDlg(FLang.GMS('e117'), FLang.GMS('e108'), MB_cdrtfeError);
   end else
   begin
     {Zielordner sortieren}
     FData.SortFolder(DestPath, FSettings.General.Choice);
     {Änderungen auch im GUI nachvollziehen}
     (DestNode.TreeView as TTreeView).Items.BeginUpdate;
     SourceNode.MoveTo(DestNode, naAddChild);
     DestNode.AlphaSort;
     SourceNode.ImageIndex := FImageLists.IconFolder;  // <- sonst manchmal Dar-
     (DestNode.TreeView as TTreeView).Items.EndUpdate; //    stellungsfehler
   end;
end;

{ UserRenameFile ---------------------------------------------------------------

  Eine Datei umbenennen. Die eigentliche Auswertung wird im onEdited-Handler
  vorgenommen.                                                                 }

procedure TCdrtfeMainForm.UserRenameFile(View: TListView);
begin
  if View.Selected <> nil then
  begin
    View.Selected.EditCaption;
  end;
end;

{ UserRenameFolderByKey --------------------------------------------------------

  UserRenameFolderByKey reagiert auf die Taste F2 und löst das Umbenennen des
  CD-Lables oder eines Ordner aus.                                             }

procedure TCdrtfeMainForm.UserRenameFolderByKey(Tree: TTreeView);
begin
  if Tree.Selected = Tree.Items[0] then
  begin
    UserSetCDLabel(Tree);
  end else
  begin
    UserRenameFolder(Tree);
  end;
end;

{ UserSetCDLabel ---------------------------------------------------------------

  Das Label der CD festelgen.                                                  }

procedure TCdrtfeMainForm.UserSetCDLabel(Tree: TTreeView);
begin
  if Tree.Items[0] <> nil then
  begin
    Tree.Items[0].EditText;
  end;
end;

{ UserRenameFolder -------------------------------------------------------------

  Einen Ordner umbenennen. Die eigentliche Auswertung wird im onEdited-Handler
  vorgenommen.                                                                 }

procedure TCdrtfeMainForm.UserRenameFolder(Tree: TTreeView);
begin
  if Tree.Selected <> Tree.Items[0] then
  begin
    Tree.Selected.EditText;
  end;
end;

{ UserSort ---------------------------------------------------------------------

  UserSort sortiert die Datei- oder die Ordnerlisten, wenn die Flags
  CDEFilesToSort oder FolderRenamed gesetzt sind. Aufruf erfolgt aus dem
  OnChanging-Event des TreeViews oder dem OnKeyDown-Event.
  Mit Force=True wird die Sortierung der Ordner erzwungen, auch wenn der
  aktuelle Ordner auf gleicher Ebene liegt, wie der umbenannte.                }

procedure TCdrtfeMainForm.UserSort(Force: Boolean);
var Node: TTreeNode;
begin
  if FData.DataCDFilesToSort then
  begin
    {$IFDEF DebugSort}
    Node := GetNodeFromPath(CDETreeView.Items[0],
                            FData.DataCDFilesToSortFolder);
    Deb('sortiere Dateien im Ordner: ' + Node.Text, 3);
    {$ENDIF}
    FData.SortFileList(FData.DataCDFilesToSortFolder, cDataCD);
    FData.DataCDFilesToSort := False;
    FData.DataCDFilesToSortFolder := '';
    ShowFolderContent(CDETreeView, CDEListView);
  end;
  if FData.DataCDFoldersToSort then
  begin
    Node := GetNodeFromPath(CDETreeView.Items[0],
                            FData.DataCDFoldersToSortParent);
    if (Self.CDETreeView.Selected.Parent <> Node) or Force then
    begin
      {$IFDEF DebugSort}
      with FormDebug.Memo3.Lines do
      begin
        Add('aktueller Ordner: ' + CDETreeView.Selected.Text);
        Add('1: sortiere Unterordner im Ordner: ' + Node.Text);
      end;
      {$ENDIF}
      FData.SortFolder(FData.DataCDFoldersToSortParent, cDataCD);
      Node.AlphaSort;
      FData.DataCDFoldersToSort := False;
      FData.DataCDFoldersToSortParent := '';
    end;
  end;
  if FData.XCDFoldersToSort then
  begin
    Node := GetNodeFromPath(XCDETreeView.Items[0],
                            FData.XCDFoldersToSortParent);
    if (Self.XCDETreeView.Selected.Parent <> Node) or Force then
    begin
      {$IFDEF DebugSort}
      with FormDebug.Memo3.Lines do
      begin
        Add('aktueller Ordner: ' + XCDETreeView.Selected.Text);
        Add('3: sortiere Unterordner im Ordner: ' + Node.Text);
      end;
      {$ENDIF}
      FData.SortFolder(FData.XCDFoldersToSortParent, cXCD);
      Node.AlphaSort;
      FData.XCDFoldersToSort := False;
      FData.XCDFoldersToSortParent := '';
    end;
  end;
end;

{ UserNewFolder ----------------------------------------------------------------

  Einen neuen Ordner anlegen.                                                  }

procedure TCdrtfeMainForm.UserNewFolder(Tree: TTreeView);
var Path: string;
    Name: string;
    Node: TTreeNode;
begin
  SelectRootIfNoneSelected(Tree);
  Path := GetPathFromNode(Tree.Selected);
  {Standardnamen für neue Ordner holen}
  Name := FLang.GMS('m111');
  FData.NewFolder(Path, Name, FSettings.General.Choice);
  Name := FData.LastFolderAdded;
  {Änderungen im GUI nachvollziehen}
  Node := Tree.Items.AddChild(Tree.Selected, Name);
  Node.ImageIndex := FImageLists.IconFolder;
  Node.SelectedIndex := FImageLists.IconFolderSelected;
  {Neuen Ordner benamsen und User die Möglichkeit zum Editieren geben.}
  Tree.Selected := Node;
  Tree.Selected.Focused := True;
  Tree.Selected.EditText;
  UpdateGauges;
end;

{ UserAddTrack -----------------------------------------------------------------

  UserAddTrack fügt eine Audio-Datei oder eine MPEG-Datei zur Trackliste hinzu.
  Ausgelöst über GUI.                                                          }

procedure TCdrtfeMainForm.UserAddTrack;
var i       : Integer;
    DialogID: TDialogID;
    FileList: TStringList;
begin
  DialogID := DIDDummy;
  FileList := TStringList.Create;
  with Self do
  begin
    OpenDialog1 := TOpenDialog.Create(Self);
    case FSettings.General.Choice of
      cAudioCD: begin
                  DialogID := DIDAudioCDTrack;
                  OpenDialog1.Title := FLang.GMS('m104');
                  OpenDialog1.DefaultExt := 'wav';
                  OpenDialog1.Filter := FLang.GMS('f004');
                end;
      cVideoCD: begin
                  DialogID := DIDVideoCDTrack;
                  OpenDialog1.Title := FLang.GMS('m105');
                  OpenDialog1.DefaultExt := 'mpg';
                  OpenDialog1.Filter := FLang.GMS('f009');
                end;
    end;
    OpenDialog1.InitialDir := GetCachedFolderName(DialogID);
    OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist];
    if OpenDialog1.Execute then
    begin
      Self.StatusBar.Panels[0].Text := FLang.GMS('m116');
      FileList.Assign(OpenDialog1.Files);
      FileList.Sort;
      {$IFDEF ShowTimeAddTracks}
      TC.StartTimeCount;
      {$ENDIF}
      for i := 0 to FileList.Count - 1 do
      begin
        case FSettings.General.Choice of
          cAudioCD: FData.AddToPathlist(FileList[i], '', cAudioCD);
          cVideoCD: FData.AddToPathlist(FileList[i], '', cVideoCD);
        end;
        HandleError(FData.LastError, FileList[i]);
      end;
      {$IFDEF ShowTimeAddTracks}
      TC.StopTimeCount;
      TLogWin.Inst.Add('add Tracks: ' + TC.TimeAsString);
      {$ENDIF}
      CacheFolderName(DialogID, OpenDialog1.FileName);
    end;
    OpenDialog1.Free;
    ShowTracks;
    UpdateGauges;
  end;
  FileList.Free;
end;

{ UserMoveTrack ----------------------------------------------------------------

  UserMoveTrack verschiebt einen Audio-Track um eine Position nach oben bzw.
  unten.                                                                       }

procedure TCdrtfeMainForm.UserMoveTrack(List: TListView;
                                        const Direction: TDirection);
var TempItem: TListItem;
    Index: Integer;
    {$IFDEF DebugFileLists}
    FileList: TSTringList;
    {$ENDIF}
begin
  if List.SelCount > 0 then
  begin
    Index := List.Selected.Index;
    if Direction = dUp then
    begin
      if List.Selected.Index > 0 then
      begin
        FData.MoveTrack(Index, Direction, FSettings.General.Choice);
        {Änderungen im GUI nachvollziehen}
        TempItem := TListItem.Create(List.Items);
        TempItem.Assign(List.Items[Index]);
        List.Items[Index].Assign(List.Items[Index - 1]);
        List.Items[Index - 1].Assign(TempItem);
        List.Selected := nil;
        List.Selected := List.Items[Index - 1];
        TempItem.Free;
        if List.Selected.Index < List.TopItem.Index then
        begin
          List.Scroll(0, -40);
        end;
      end;
    end else
    if Direction = dDown then
    begin
      if List.Selected.Index < List.Items.Count - 1 then
      begin
        FData.MoveTrack(Index, Direction, FSettings.General.Choice);
        {Änderungen im GUI nachvollziehen}
        TempItem := TListItem.Create(List.Items);
        TempItem.Assign(List.Items[Index]);
        List.Items[Index].Assign(List.Items[Index + 1]);
        List.Items[Index + 1].Assign(TempItem);
        List.Selected := nil;
        List.Selected := List.Items[Index + 1];
        TempItem.Free;
        if List.Selected.Top > List.ClientHeight - 17 then
        begin
          List.Scroll(0, 40);
        end;
      end;
    end;
    {$IFDEF DebugFileLists}
    FileList := FData.GetFileList('', FSettings.General.Choice);
    FormDebug.Memo2.Lines.Assign(FileList);
    {$ENDIF}
  end;
end;

{ UserSortTracks ---------------------------------------------------------------

  UserSortTracks sortiert die Trackliste nach Namen.                           }

procedure TCdrtfeMainForm.UserSortTracks(List: TListView);
begin
  if List.Items.Count > 1 then
  begin
    FData.SortTracks(FSettings.General.Choice);
    ShowTracks;
  end;
end;

{ UserOpenFile -----------------------------------------------------------------

  UserOpenFile öffnet eine Datei oder einen Track.                             }

procedure TCdrtfeMainForm.UserOpenFile(List: TListView);
var Item: TListItem;
    Tree: TTreeView;
    Path: string;
    Node: TTreeNode;
begin
  if FSettings.General.AllowFileOpen and (List <> nil) then
  begin
    Item := List.Selected;
    if Item <> nil then
    begin
      if ((List = AudioListView) or (List = VideoListView)) and
         FSettings.General.UseMPlayer then
      begin
        {$IFDEF WriteLogfile}
        AddLogCode(1058);
        {$ENDIF}
        if FSettings.FileFlags.MPlayerOk then
          ShlExecute(QuotePath(FSettings.General.MPlayerCmd),
                     ReplaceString(FSettings.General.MPlayerOpt, '%N',
                                   QuotePath(List.Selected.SubItems[2])));
      end else
      begin
        if not ItemIsFolder(Item) then
        begin
          {$IFDEF WriteLogfile}
          AddLogCode(1059);
          {$ENDIF}
          ShlExecute('', QuotePath(List.Selected.SubItems[2]));
        end else
        begin
          Tree := GetCurrentTreeView;
          Path := GetPathFromNode(Tree.Selected) + Item.Caption + '/';
          Node := GetNodeFromPath(Tree.Items[0], Path);
          Node.Selected := True;
        end;
      end;
    end;
  end;
end;

{ UserImportCD -----------------------------------------------------------------

  UserImp0rtCD importiert die vorhandenen Sessions einer eingelegten CD.       }

procedure TCdrtfeMainForm.UserImportCD;
var Index          : Integer;
    DeviceID       : string;
    Drive          : string;
    VolInfo        : TVolumeInfo;
    SessionImporter: TSessionImportHelper;
begin
  Index := FSettings.General.TabSheetDrive[FSettings.General.Choice];
  DeviceID := GetValueFromString(FDevices.CDWriter[Index]);
  Drive := FDevices.GetDriveLetter(DeviceID);
  if Drive = '' then
  begin
    TLogWin.Inst.Add('No drive letter ...');
    Exit;
  end;
  TLogWin.Inst.Add(Format(FLang.GMS('g011'), [Drive, DeviceID]));
  {Welche Session importieren?}
  if not FSettings.DataCD.SelectSess then
  begin
    {einfach die letzte Session importieren}
    VolInfo.Drive := Drive;
    FData.CDImportSession := True;
    AddToPathlist(Drive);
    FData.CDImportSession := False;
    CheckDataCDFS(False);
    UserAddFolderUpdateTree(CDETreeView);
    GetVolumeInfo(VolInfo);
    if VolInfo.Name <> '' then
    begin
      FData.SetCDLabel(VolInfo.Name, FSettings.General.Choice);
      CDETreeView.Items[0].Text := VolInfo.Name;
    end;
    SessionImporter := TSessionIMportHelper.Create;
    SessionImporter.Device := DeviceID;
    SessionImporter.Drive := Drive;
    SessionImporter.GetSpaceUsedUser;
    SessionImporter.Free;
  end else
  begin
    {User wählt Session aus.}
    SessionImporter := TSessionImportHelper.Create;
    SessionImporter.Device := DeviceID;
    SessionImporter.Drive := Drive;
    SessionImporter.GetSessionUser;
    FSettings.DataCD.MsInfo := SessionImporter.StartSector;
    InitTreeView(CDETreeView, cDataCD);
    CDETreeView.Items[0].Expand(False);
    SessionImporter.Free;
  end;
  UpdateGauges;
end;


{ Anzeige der Dateilisten ---------------------------------------------------- }

{ AddItemToListView: -----------------------------------------------------------

  Anzeige der in den Dateilisten gespeicherten Dateien.
  Wenn Choice = [1|3] ist, die in den Pfadlisten gespeicherten Dateien werden im
  ListView angezeigt, incl. Größe, Typ und Icon und Herkunft.
  Wenn Choice = 2 ist, werden die Dateien in den AudioListView eingefügt. Dabei
  werden Name, Länge, Größe und Herkunft angezeigt.                            }

procedure TCdrtfeMainForm.AddItemToListView(const Item: string;
                                            ListView: TListView);
var NewItem    : TListItem;
    IconIndex  : Integer;
    Size       : Int64;
    Name       : string;
    Caption    : string;
    Filetype   : string;
    SizeString : string;
    Path       : string;
    IsFolder   : Boolean;
    TrackLength: Extended;
    p          : Integer;
begin
  if (FSettings.General.Choice = cDataCD) or
     (FSettings.General.Choice = cXCD) then
  begin
    p := Pos(';', Item);
    IsFolder := p > 0;
    if IsFolder then
    begin
      Path := Copy(Item, 1, p - 1);
      Caption := Copy(Item, p + 1, Length(Item) - p);
      Name := StartUpDir;
      if FSettings.General.ShowFolderSize then
        Size := FData.GetFolderSizeFromPath(Path + Caption + '/',
                                            FSettings.General.Choice)
      else
        Size := 0;
    end else
      ExtractFileInfoFromEntry(Item, Caption, Name, Size);
    NewItem := ListView.Items.Add;             
    NewItem.Caption := Caption;
    FFileTypeInfo.GetFileInfo(Name, IconIndex, Filetype);
    NewItem.ImageIndex := IconIndex;
    if (FSettings.General.Choice = cDataCD) and (Pos('>', Item) > 0) then
      Name := FLang.GMS('g010');
    {Verhindern, daß bei Dateien mit weniger als 512 Byte 0 KiByte angezeigt
     werden.}
    if (Size > 0) and (Size <= 512) then Size := Size + 512;
    Size := Round(Size / 1024);
    SizeString := FormatFloat('#,###,##0 ' + UnitKiByte, Size);
    if IsFolder then
    begin
      if not FSettings.General.ShowFolderSize then SizeString := '';
      Name := '';
    end;
    NewItem.SubItems.Add(SizeString);
    NewItem.SubItems.Add(Filetype);
    NewItem.SubItems.Add(Name);
  end else
  if (FSettings.General.Choice = cAudioCD) or
     (FSettings.General.Choice = cVideoCD)  then
  begin
    ExtractTrackInfoFromEntry(Item, Caption, Name, Size, TrackLength);
    NewItem := ListView.Items.Add;
    NewItem.Caption := Caption;
    FFileTypeInfo.GetFileInfo(Name, IconIndex, Filetype);
    NewITem.ImageIndex := IconIndex;
    NewItem.SubItems.Add(FormatTime(TrackLength));
    Size := Round(Size / 1024);
    NewItem.SubItems.Add(FormatFloat('#,###,##0 ' + UnitKiByte, Size));
    NewItem.SubItems.Add(Name);
  end;
end;

{ ShowFolderContent ------------------------------------------------------------

  zeigt den Inhalt des selektierten Knotens im TreeView an:
  Tree: TreeView
  ListView: ListView, der den Inhalt darstellen soll
  Wichtig: ListView.Tag enthält die Anzahl der Unterordner. Nötig zur Bestimmung
           des korrekten Indexes bei selektierten Dateien.                     }

procedure TCdrtfeMainForm.ShowFolderContent(const Tree: TTreeView;
                                            ListView: TListView);
var i         : Integer;
    Temp      : string;
    Path      : string;
    FileList  : TStringList;
    SubFolders: TStringList;
begin                              
  FileList := nil;
  SubFolders := TStringList.Create;
  {Pfad des gewählten Knotens feststellen}
  Path := GetPathFromNode(Tree.Selected);
  {Referenz auf Dateiliste holen, da die Tree-Views auch aktualisiert werden,
   wenn sie nicht angezeigt werden (z.B. beim Laden einer Projekt-Datei, muß
   anhand des Namens und nicht anhand von FSettings.General.Choice entschieden
   werden.}
  if (Tree = CDETreeView) then
  begin
    FileList := FData.GetFileList(Path, cDataCD);
    FData.GetSubFolders(cDataCD, Path, SubFolders);
  end else
  if (Tree = XCDETreeView) then
  begin
    FileList := FData.GetFileList(Path, cXCD);
    FData.GetSubFolders(cXCD, Path, SubFolders);
  end;
  {Debugging: interne Pfadliste anzeigen}
  {$IFDEF DebugFileLists}
  try
    if FileList <> nil then
    begin
      with FormDebug.Memo1.Lines do
      begin
        Add('aktueller Knoten im Tree-View  : ' + Tree.Selected.Text);
        Add('entsprechender Daten-Knoten    : ' +
            FData.GetFolderName(Path, FSettings.General.Choice));
        Add('Pfad                           : ' + Path);
        Add('Einträge in der Dateiliste     : ' + IntToStr(FileList.Count));
      // Add('Unterordner                    : ' + IntToStr(Folder.ChildCount));
        Add('');
      end;
      FormDebug.Memo2.Lines.Assign(FileList);
    end;
  except
  end;
  {$ENDIF}

  {ListView füllen, es sei denn, FileList ist nil (wenn Choice <> [1|3] aber
   trotzdem der selektierte Knoten geändert wurde.}
  if FileList <> nil then
  begin
    if (Tree = CDETreeView) then
    begin
      ListView.Items.BeginUpdate;
      ListView.Items.Clear;
      {Folders}
      for i := 0 to SubFolders.Count - 1 do
      begin
        AddItemToListView(Path + ';' + SubFolders[i], ListView);
      end;
      ListView.Tag := SubFolders.Count;
      {Files}
      for i := 0 to FileList.Count - 1 do
      begin
        AddItemToListView(FileList[i], ListView);
      end;
      ListView.Items.EndUpdate;
    end else
    if (Tree = XCDETreeView) then
    begin
      ListView.Items.BeginUpdate;
      ListView.Items.Clear;
      XCDEListView2.Items.BeginUpdate;
      XCDEListView2.Items.Clear;
      {Folders}
      for i := 0 to SubFolders.Count - 1 do
      begin
        AddItemToListView(Path + ';' + SubFolders[i], ListView);
      end;
      ListView.Tag := SubFolders.Count;
      {Files}
      for i := 0 to FileList.Count - 1 do
      begin
        Temp := FileList[i];
        if Temp[Length(Temp)] = '>' then
        begin
          AddItemToListView(Temp, XCDEListView2);
        end else
        begin
          AddItemToListView(Temp, ListView);
        end;
      end;
      ListView.Items.EndUpdate;
      XCDEListView2.Items.EndUpdate;
    end;
  end;
  SubFolders.Free;
end;

{ ShowTracks -------------------------------------------------------------------

  ShowTrack aktualisiert die Anzeige der ausgwählten Audio-Tracks.             }

procedure TCdrtfeMainForm.ShowTracks;
var i: Integer;
    FileList: TStringList;
    ListView: TListView;
begin
  FileList := nil;
  ListView := nil;
  case FSettings.General.Choice of
    cAudioCD: begin
                ListView := AudioListView;
                FileList := FData.GetFileList('', cAudioCD);
              end;
    cVideoCD: begin
                ListView := VideoListView;
                FileList := FData.GetFileList('', cVideoCD);
              end;
  end;
  {Debugging: interne Pfadliste anzeigen}
  {$IFDEF DebugFileLists}
  try
    FormDebug.Memo2.Lines.Assign(FileList);
  except
  end;
  {$ENDIF}
  {möglicherweise noch aktuell selektierten Track und Sichtbarkeit der Tracks
   merken.}
  ListView.Items.BeginUpdate;
  ListView.Items.Clear;
  for i := 0 to FileList.Count - 1 do
  begin
    AddItemToListView(FileList[i], ListView);
  end;
  ListView.Items.EndUpdate;
end;

{ ShowTracksDAE ----------------------------------------------------------------

  ShowTrackDAE aktualisiert die Anzeige der auf der CD vorhandenen Tracks.     }

procedure TCdrtfeMainForm.ShowTracksDAE;
var i        : Integer;
    TrackList: TStringList;
    NewItem  : TListItem;
    Temp, Time,
    Name, Size,
    Title,
    Performer: string;
begin
  TrackList := FData.GetFileList('', cDAE);
  {Debugging: interne Pfadliste anzeigen}
  {$IFDEF DebugFileLists}
  try
    FormDebug.Memo2.Lines.Add('DAETrackList');
    FormDebug.Memo2.Lines.Assign(TrackList);
  except
  end;
  {$ENDIF}
  {möglicherweise noch aktuell selektierten Track und Sichtbarkeit der Tracks
   merken.}
  DAEListView.Items.BeginUpdate;
  DAEListView.Items.Clear;
  for i := 0 to TrackList.Count - 1 do
  begin
    NewItem := DAEListView.Items.Add;
    NewItem.ImageIndex := FImageLists.IconCDA;
    SplitString(TrackList[i], ':', Name, Temp);
    SplitString(Temp, '*', Time, Temp);
    SplitString(Temp, '|', Size, Temp);
    SplitString(Temp, '|', Title, Performer);
    if not((Performer = '') and (Title = '')) then
      Name := Name + '  ' + Performer + ' - ' + Title;
    NewItem.Caption := Name;
    NewItem.SubItems.Add(Time);
    NewItem.SubItems.Add(Size);
  end;
  DAEListView.Items.EndUpdate;
end;


{ Hauptfenster: sonstiges ---------------------------------------------------- }

{ SaveWinPos -------------------------------------------------------------------

  speichert die aktuelle Position und Größe des Hauptfenster in FSettings.WinPos
  ab.                                                                          }

procedure TCdrtfeMainForm.SaveWinPos;
var i, j: Integer;
begin
  with FSettings.WinPos do
  begin
    {Fensterposition merken}
    if Self.WindowState = wsMaximized then
    begin
      MainMaximized := True;
    end else
    begin
      MainTop := Self.Top;
      MainLeft := Self.Left;
      MainWidth := Self.Width;
      MainHeight := Self.Height;
      MainMaximized := False;
    end;
    {ListView-Spaltenbreite}
    for i := 0 to cLVCount do
      for j := 0 to FLVArray[i].Columns.Count - 1 do
        FSettings.WinPos.LVColWidth[i, j] := FLVArray[i].Columns[j].Width;
  end;
  {FileExplorer}
  FSettings.FileExplorer.Showing := FFileExplorerShowing;
  FSettings.FileExplorer.HideLogWindow := not FLogWindowShowing;
  FSettings.FileExplorer.Path := FileBrowser.Path;
end;

{ SetWinPos --------------------------------------------------------------------

  sofern Werte vorhanden sind, wird die Größe und Posiiton des Hauptfensters
  angepaßt.                                                                    }

procedure TCdrtfeMainForm.SetWinPos;
var i, j: Integer;
begin
  {falls vorhanden, alte Größe und Position wiederherstellen}
  with FSettings.WinPos do
  begin
    if (MainWidth <> 0) and (MainHeight <> 0) then
    begin
      Self.Top := MainTop;
      Self.Left := MainLeft;
      Self.Width := MainWidth;
      Self.Height := MainHeight;
    end else
    begin
      {Falls keine Werte vorhanden, dann Fenster zentrieren. Die muß hier
       manuell geschehen, da poScreenCenter zu Fehlern beim Setzen der
       Eigenschaften führt. Deshalb muß poDefault verwendet werden.}
      if (Screen.PixelsPerInch = 96) then
      begin
        Self.Width := dWidth;
        Self.Height := dHeight;
      end else
      if (Screen.PixelsPerInch > 96) then
      begin
        Self.Width := dWidthBigFont;
        Self.Height := dHeightBigFont;
      end;
      Self.Top := (Screen.Height - Self.Height) div 2;
      Self.Left := (Screen.Width - Self.Width) div 2;
    end;
    if MainMaximized then
    begin
      //Self.Position := poDefault;
      Self.WindowState := wsMaximized;
    end;
    {ListView-Spaltenbreite}
    for i := 0 to cLVCount do
      for j := 0 to FLVArray[i].Columns.Count - 1 do
        if FSettings.WinPos.LVColWidth[i, j] > -1 then
          FLVArray[i].Columns[j].Width := FSettings.WinPos.LVColWidth[i, j];
  end;
  {FileExplorer}
  ToggleLogWindow(not FSettings.FileExplorer.HideLogWindow);
  ToggleFileExplorer(FSettings.FileExplorer.Showing);
end;

{ ActivateTab ------------------------------------------------------------------

  ActivateTab zeigt das gewünschte TabSheet an.                                }

procedure TCdrtfeMainForm.ActivateTab(const PageToActivate: Byte);
begin
  Self.PageControl1.ActivePage := Self.PageControl1.Pages[PageToActivate - 1];
  PageControl1Change(PageControl1);
end;

{ GetActivePage ----------------------------------------------------------------

  GetActivePage liefert als Ergebnis die Nummer der aktiven Registerkarte:
  Daten-CD: 1, Audio-CD: 2, XCD: 3, CD-RW: 4, CD-Infos: 5, DAE: 6, CD Image: 7,
  (S)Vide CD: 8, DVD Video: 9.}

function TCdrtfeMainForm.GetActivePage: Byte;
begin
  Result := Self.PageControl1.ActivePage.PageIndex + 1;
end;

{ GetCurrentListView -----------------------------------------------------------

  GetCurrentListView gibt eine Referenz auf den aktuelle ListView zurück.      }

function TCdrtfeMainForm.GetCurrentListView(Sender: TObject): TListView;
begin
  case FSettings.General.Choice of
    cDataCD : Result := CDEListView;
    cXCD    : Result := (Sender as TListView);
    cAudioCD: Result := AudioListView;
    cVideoCD: Result := VideoListView;
  else
    Result := nil
  end;
end;

{ GetCurrentTreeView -----------------------------------------------------------

  GetCurrentTreeView gibt eine Referent auf den aktuellen TreeView zurück.     }

function TCdrtfeMainForm.GetCurrentTreeView: TTreeView;
begin
  case FSettings.General.Choice of
    cDataCD: Result := CDETreeView;
    cXCD   : Result := XCDETreeView;
  else
    Result := nil;
  end;
end;

{ UpateGauges ------------------------------------------------------------------

  UpdateGauges aktualisiert in Abhängigkeit des aktives TabSheets die
  Anzeige für Gesamtgröße der ausgewählten Dateien bzw. Gesamtspielzeit.       }

procedure TCdrtfeMainForm.UpdateGauges;
var FileCount, FolderCount, TrackCount: Integer;
    CDSize: Int64;
    CDTime: Extended;
    Temp: string;
begin
  FData.GetProjectInfo(FileCount, FolderCount, CDSize, CDTime, TrackCount,
                       FSettings.General.Choice);

  if FSettings.General.Choice = cDataCD then
    CDSize := CDSize + FData.GetProjectPrevSessSize;

  case FSettings.General.Choice of
    cDataCD,
    cXCD    : Temp := Format(FLang.GMS('m112'),
                             [FormatFloat('#,##0', FolderCount),
                              FormatFloat('#,##0', FileCount),
                              SizeToString(CDSize)]);

    cAudioCD: Temp := Format(FLang.GMS('m119'),
                             [FormatFloat('#,##0', TrackCount),
                              FormatTime(CDTime)]);
    cVideoCD: Temp := Format(FLang.GMS('m122'),
                             [FormatFloat('#,##0', TrackCount),
                              SizeToString(CDSize)]);
    {vielleicht noch Angaben bei cDAE: Anzahl Tracks/ gewählt}
  else
    Temp := '';
  end;
  StatusBar.Panels[0].Text := Temp;

  {SpaceMeter}
  UpdateSpaceMeter(Round(CDSize/(1024*1024)), Round(CDTime));

  {TaskBarEntry}
  if FSettings.General.FileInfoTitle then
  begin
    Temp := '';
    case FSettings.General.Choice of
      cDataCD,
      cXCD    : Temp := '[' + IntToStr(FileCount) + ' ' +
                              SizeToString(CDSize) + ']';
      cAudioCD: Temp := '[' + IntToStr(TrackCount) +  ' ' +
                              FormatTime(CDTime) + ']';
    end;
    UpdateTaskBarEntry(Temp);
  end;

  {$IFDEF DebugUpdateGauges}
  with FormDebug.Memo3.Lines do
  begin
    if FSettings.General.Choice in [cDataCD, cXCD] then
    begin
      Add('Dateien      : ' + IntToStr(FileCount));
      Add('Ordner       : ' + IntToStr(FolderCount));
      Add('Gesamtgröße  : ' + SizeToString(CDSize));
      Add('MaxLevel     : ' +
          IntToStr(FData.GetProjectMaxLevel(FSettings.General.Choice)));
      if FSettings.General.Choice = cXCD then
      begin
        Add('Form2        : ' + IntToStr(FData.GetForm2FileCount));
        Add('Form2, klein : ' + IntToStr(FData.GetSmallForm2FileCount));
      end;
    end;
    if FSettings.General.Choice in [cAudioCD, cVideoCD] then
    begin
      Add('Tracks       : ' + IntToStr(TrackCount));
      Add('Spielzeit    : ' + FormatTime(CDTime));
      Add('Gesamtgröße  : ' + SizeToString(CDSize));
    end;
    Add('');
  end;
  {$ENDIF}
end;

{ UpdateSpaceMeter -------------------------------------------------------------

  SpaceMeter aktualisieren.                                                    }

procedure TCdrtfeMainForm.UpdateSpaceMeter(Size, Time: Integer);
begin
  if FSettings.General.SpaceMeter then
  begin
    SpaceMeter.DiskType := TSpaceMeterDiskType(
                    FSettings.General.TabSheetSMType[FSettings.General.Choice]);
    case FSettings.General.Choice of
      cDataCD : begin
                  SpaceMeter.SpaceMeterMode := SMM_DataCD;
                  SpaceMeter.DiskSize := Size;
                end;
      cAudioCD: begin
                  SpaceMeter.SpaceMeterMode := SMM_AudioCD;
                  SpaceMeter.DiskSize := Time;
                end;
      cXCD    : begin
                  SpaceMeter.SpaceMeterMode := SMM_XCD;
                  SpaceMeter.DiskSize := Size;
                end;
    else
      SpaceMeter.SpaceMeterMode := SMM_NoDisk;
      SpaceMeter.DiskSize := 0;
    end;
    StatusBar.Panels[1].Text := SpaceMeter.RemainingSpaceString;
  end else
  begin
    SpaceMeter.SpaceMeterMode := SMM_NoDisk;
    SpaceMeter.DiskSize := 0;
  end;
end;

{ UpdateTaskBarEntry -----------------------------------------------------------

  zeigt, wenn gewünscht, die Anzahl von Datein im TaskBar-Eintrag an.          }

procedure TCdrtfeMainForm.UpdateTaskBarEntry(s: string);
{J+}
const Title: string = '';
{J-}
begin
  if not FSettings.Environment.ProcessRunning then
  begin
    if Title = '' then Title := Application.Title;
    if s <> '' then s := s + ' ';
    Application.Title := s + Title;
  end;
end;

{ UpdateOptionPanel ------------------------------------------------------------

  UpdateOptionPanel aktualisiert die Anzeige der aktivierten Optionen auf dem
  jeweiligen Panel.                                                            }

procedure TCdrtfeMainForm.UpdateOptionPanel;
var Temp: string;

  {lokale Prozedure zum Verändern der Labels}
  procedure SetLabel(L: TLabel; Status: Boolean);
  begin
    {$IFNDEF AllowToggle}
    L.Enabled := Status;
    {$ELSE}
    if Status then
    begin
      L.Font.Color := clWindowText
    end else
    begin
      L.Font.Color := clGrayText;
    end;
    {$ENDIF}
  end;

begin
  if FSettings.General.Choice = cDataCD then
  begin
    with FSettings.DataCD do
    begin
      SetLabel(LabelDataCDSingle, not Multi);
      SetLabel(LabelDataCDMulti, Multi);
      SetLabel(LabelDataCDOTF, OnTheFly);
      SetLabel(LabelDataCDTAO, TAO);
      SetLabel(LabelDataCDDAO, DAO);
      SetLabel(LabelDataCDRAW, RAW);
      Temp := LabelDataCDJoliet.Caption;
      if Pos('(103)', Temp) > 0 then
      begin
        Delete(Temp, 7, 6);
      end;
      if JolietLong then
      begin
        Temp := Temp + ' (103)';
      end;
      LabelDataCDJoliet.Caption := Temp;
      SetLabel(LabelDataCDJoliet, Joliet);
      SetLabel(LabelDataCDRockRidge, RockRidge);
      SetLabel(LabelDataCDUDF, UDF);
      Temp := LabelDataCDISOLevel.Caption;
      if Temp[Length(Temp)] in ['1', '2', '3', '4'] then
      begin
        Delete(Temp, Length(Temp) - 1, 2);
      end;
      if ISOLevel then
      begin
        Temp := Temp + ' ' + IntToStr(IsoLevelNr);
        SetLabel(LabelDataCDISOLevel, True);
      end else
      begin
        SetLabel(LabelDataCDISOLevel, False);
      end;
      LabelDataCDISOLevel.Caption := Temp;
      SetLabel(LabelDataCDBoot, Boot);
      if (DAO or RAW) and Overburn then
      begin
        SetLabel(LabelDataCDOverburn, Overburn);
      end else
      begin
        SetLabel(LabelDataCDOverburn, False);
      end;
      LabelDataCDOverburn.Visible := not TAO;
    end;
    {$IFDEF DebugMaxFileNameLength}
    LabelDataCDBoot.Caption := 'boot ' +
                               IntToStr(FSettings.GetMaxFileNameLength);
    {$ENDIF}
  end;
  if FSettings.General.Choice = cAudioCD then
  begin
    with FSettings.AudioCD do
    begin
      SetLabel(LabelAudioCDSingle, not Multi and Fix);
      SetLabel(LabelAudioCDMulti, Multi and Fix);
      if (DAO or RAW) and Overburn then
      begin
        SetLabel(LabelAudioCDOverburn, Overburn);
      end else
      begin
        SetLabel(LabelAudioCDOverburn, False);
      end;
      if (DAO or RAW) and CDText then
      begin
        SetLabel(LabelAudioCDText, CDText);
      end else
      begin
        SetLabel(LabelAudioCDText, False);
      end;
      LabelAudioCDOverburn.Visible := not TAO;
      LabelAudioCDText.Visible := not TAO;
      SetLabel(LabelAudioCDTAO, TAO);
      SetLabel(LabelAudioCDDAO, DAO);
      SetLabel(LabelAudioCDRAW, RAW);
      SetLabel(LabelAudioCDPreemp, Preemp);
      SetLabel(LabelAudioCDUseInfo, UseInfo);
    end;
  end;
  if FSettings.General.Choice = cXCD then
  begin
    with FSettings.XCD do
    begin
      SetLabel(LabelXCDSingle, Single);
      SetLabel(LabelXCDIsoLevel1, IsoLevel1);
      SetLabel(LabelXCDIsoLevel2, IsoLevel2);
      SetLabel(LabelXCDKeepExt, KeepExt);
      SetLabel(LabelXCDOverburn, Overburn);
      SetLabel(LabelXCDCreateInfoFile, CreateInfoFile);
      LabelXCDCreateInfoFile.Visible := not (IsoLevel1 or IsoLevel2);
    end;
  end;
  if FSettings.General.Choice = cDAE then
  begin
    with FSettings.DAE do
    begin
      SetLabel(LabelDAEBulk, Bulk);
      SetLabel(LabelDAEParanoia, Paranoia);
      SetLabel(LabelDAEInfoFiles, not NoInfoFile);
      SetLabel(LabelDAECDDB, UseCDDB);
      SetLabel(LabelDAEMp3, Mp3);
      SetLabel(LabelDAEOgg, Ogg);
      SetLabel(LabelDAEFlac, Flac);
      SetLabel(LabelDAECustom, Custom);
      SetLabel(LabelDAECopy, DoCopy);
    end;
  end;
  if Fsettings.General.Choice = cVideoCD then
  begin
    with FSettings.VideoCD do
    begin
      SetLabel(LabelVideoCDVCD1, VCD1);
      SetLabel(LabelVideoCDVCD2, VCD2);
      SetLabel(LabelVideoCDSVCD, SVCD);
      SetLabel(LabelVideoCDOverburn, Overburn);
    end;
  end;
end;

{ SpecialTab -------------------------------------------------------------------

  direkter Wechsel zum FileExplorer und zurück.                                }

procedure TCdrtfeMainForm.SpecialTab;
begin
  if FFileExplorerShowing then
  begin
    if not (FileBrowser.TreeViewHasFocus or FileBrowser.ListViewHasFocus) then
      FileBrowser.TreeViewSetFocus
    else
    begin
      case FSettings.General.Choice of
        cDataCD : CDETreeView.SetFocus;
        cAudioCD: AudioListView.SetFocus;
        cXCD    : XCDETreeView.SetFocus;
        cVideoCD: VideoListView.SetFocus;
      end;
    end;
  end;
end;

{ SetFileBrowserParent ---------------------------------------------------------

  setzt beim Panel, das den Filebrowser enthält den Parent entsprechend des
  aktiven Tabsheets.                                                           }

procedure TCdrtfeMainForm.SetFileBrowserParent;
var ActivePage: Integer;
begin
  if FFileExplorerShowing then
  begin
    ActivePage := GetActivePage;
    case ActivePage of
      cDataCD,
      cAudioCD,
      cXCD,
      cVideoCD: PanelBrowser.Parent := PageControl1.Pages[ActivePage - 1];
    else
      PanelBrowser.Parent := PageControl1.Pages[0];
    end;
  end;
end;

{ SetPanelSize ----------------------------------------------------------------

  setzt bei den Panels auf den Tabsheets die Höhe in Abhängigkeit der Größe
  des FileExplorers .                                                          }

procedure TCdrtfeMainForm.SetPanelSize(const Status: Boolean;
                                       const FileExplorerHeight: Integer);
var i         : Integer;
    Panel     : TPanel;
    PanelArray: array[1..4] of TPanel;
begin
  PanelArray[1] := PanelTabSheet1;
  PanelArray[2] := PanelTabSheet2;
  PanelArray[3] := PanelTabSheet3;
  PanelArray[4] := PanelTabSheet8;
  for i := 1 to 4 do
  begin
    Panel := PanelArray[i];
    if Status then
    begin
      Panel.Top := FileExplorerHeight;
      Panel.Height := TabSheet1.Height - FileExplorerHeight;
    end else
    begin
      Panel.Top := 0;
      Panel.Height := TabSheet1.Height;
    end;
  end;
end;

{ ToggleFileExplorer -----------------------------------------------------------

  Der FileExlorer wird je nach übergebenem Wert ein- bzw. abgeschaltet.        }

procedure TCdrtfeMainForm.ToggleFileExplorer(const Status: Boolean);
var FileExplorerHeight: Integer;
    TabSheet          : TTabSheet;
begin
  TabSheet := PageControl1.Pages[GetActivePage - 1];
  {FileExplorer zeigen}
  if Status and not FFileExplorerShowing then
  begin
    FSettings.FileExplorer.Height := Round(TabSheet.Height * 0.45);
    FileExplorerHeight := FSettings.FileExplorer.Height + 4;
    FFileExplorerShowing := True;
    MainMenuToggleFileExplorer.Checked := True;
    FileBrowser.Path := FSettings.FileExplorer.Path;
    SetPanelSize(Status, FileExplorerHeight);
    SetFileBrowserParent;
    PanelBrowser.Width := TabSheet.Width - 5 - 36; //41;
    PanelBrowser.Height := FSettings.FileExplorer.Height;
    PanelBrowser.Visible  := True;
  end else
  {FileExplorer ausblenden}
  if not Status and FFileExplorerShowing then
  begin
    FileExplorerHeight := FSettings.FileExplorer.Height + 4;
    FFileExplorerShowing := False;
    MainMenuToggleFileExplorer.Checked := False;
    SetPanelSize(Status, FileExplorerHeight);
    PanelBrowser.Visible := False;
  end;
  FormResize(Self);
end;

{ ToggleOutputWindow -----------------------------------------------------------

  Das Ausgabefenster zeigen oder beenden.                                      }

procedure TCdrtfeMainForm.ToggleOutputWindow(const Status: Boolean);
var FormOutput: TFormOutput;
begin
  FormOutput := TFormOutput.Create(nil);
  try
    FormOutput.Lang := FLang;
    FormOutput.Settings := FSettings;
    TLogWin.Inst.SetMemo2(FormOutput.Memo1);
    FormOutput.ShowModal;
  finally
    TLogWin.Inst.UnsetMemo2;
    FormOutput.Release;
  end;
end;

{ ToggleLogWindow --------------------------------------------------------------

  Das Memo mit den Log-Infos ein- bzw. ausblenden.                             }

procedure TCdrtfeMainForm.ToggleLogWindow(const Status: Boolean);
var MemoHeight: Integer;
begin
  MemoHeight := Memo1.Height;
  {LogWindow zeigen}
  if Status and not FLogWindowShowing then
  begin
    FLogWindowShowing := True;
    Memo1.Visible := True;
    Memo1.Enabled := True;
    Panel1.Enabled := True;
    MainMenuToggleLogWindow.Checked := True;
    {PageControl verkleinern}
    PageControl1.Height  := PageControl1.Height - MemoHeight - 8;
  end else
  {LogWindow ausblenden}
  if not Status and FLogWindowShowing then
  begin
    FLogWindowShowing := False;
    Memo1.Visible := False;
    Memo1.Enabled := False;
    Panel1.Enabled := False;
    MainMenuToggleLogWindow.Checked := False;
    PageControl1.Height  := PageControl1.Height + MemoHeight + 8;
  end;
  FormResize(Self);
end;

{ ToggleOptions ----------------------------------------------------------------

  Beim Klick auf ein Label, das den Zustand einer Option darstellt, soll die
  Option umgeschaltet werden.                                                  }

{$IFDEF AllowToggle}
procedure TCdrtfeMainForm.ToggleOptions(Sender: TObject);
var L: TLabel;
begin
  {Damit die Einstellungen der Checkboxen auf dem Hauptformular nicht verloren
   gehen, ist ein SetSettings nötig.}
  SetSettings;
  L := Sender as TLabel;
  {Data-CD}
  with FSettings.DataCD do
  begin
    if (L = LabelDataCDSingle) or (L = LabelDataCDMulti) then
    begin
      Multi := not Multi;
      if Multi and ForceMSRR then RockRidge := True;
    end;
    if L = LabelDataCDOTF then
    begin
      OnTheFly := not OnTheFly and
                 (FSettings.FileFlags.ShOk or not FSettings.FileFlags.ShNeeded);
    end;
    if (L = LabelDataCDTAO) or (L = LabelDataCDDAO) or (L = LabelDataCDRAW) then
    begin
      TAO := L = LabelDataCDTAO;
      DAO := L = LabelDataCDDAO;
      RAW := L = LabelDataCDRAW;
    end;
    if L = LabelDataCDJoliet then
    begin
      if not Joliet then Joliet := True else
      if Joliet and not JolietLong then JolietLong := True else
      if Joliet and JolietLong then
      begin
        Joliet := False;
        JolietLong := False;
      end;
    end;
    if L = LabelDataCDRockRidge then
    begin
      RockRidge := not RockRidge;
      if not RockRidge and ForceMSRR then Multi := False;
    end;
    if L = LabelDataCDUDF then
    begin
      UDF := not UDF;
    end;
    if L = LabelDataCDISOLevel then
    begin
      if not ISOLevel then
      begin
        ISOLevel := True;
        ISOLevelNr := 1;
      end else
      if ISOLevel then
      begin
        ISOLevelNr := ISOLevelNr + 1;
        if ISOLevelNr = 5 then
        begin
          ISOLevelNr := 0;
          ISOLevel := False;
        end;
      end;
    end;
    if L = LabelDataCDBoot then
    begin
      FSettings.General.TempBoot := not Boot;
      if FSettings.General.TempBoot then ButtonDataCDOptionsFSClick(nil) else
        Boot := not Boot;
    end;
    if L = LabelDataCDOverburn then
    begin
      Overburn := not Overburn;
    end;
  end;
  {Audio-CD}
  with FSettings.AudioCD do
  begin
    if (L = LabelAudioCDSingle) or (L = LabelAudioCDMulti) then
    begin
      if Fix then Multi := not Multi;
    end;
    if L = LabelAudioCDOverburn then
    begin
      Overburn := not Overburn;
    end;
    if (L = LabelAudioCDTAO) or
       (L = LabelAudioCDDAO) or
       (L = LabelAudioCDRAW) then
    begin
      TAO := L = LabelAudioCDTAO;
      DAO := L = LabelAudioCDDAO;
      RAW := L = LabelAudioCDRAW;
    end;
    if L = LabelAudioCDPreemp then
    begin
      Preemp := not Preemp;
    end;
    if L = LabelAudioCDUseInfo then
    begin
      UseInfo := not UseInfo;
    end;
    if L = LabelAudioCDText then
    begin
      CDText := not CDText;
    end;
  end;
  {XCD}
  with FSettings.XCD do
  begin
    if L = LabelXCDSingle then
    begin
      Single := not Single;
    end;
    if L = LabelXCDIsoLevel1 then
    begin
      IsoLevel1 := not IsoLevel1;
      if IsoLevel1 then
      begin
        IsoLevel2 := False;
        CreateInfoFile := False;
      end
    end;
    if L = LabelXCDIsoLevel2 then
    begin
      IsoLevel2 := not IsoLevel2;
      if IsoLevel2 then
      begin
        IsoLevel1 := False;
        CreateInfoFile := False;
      end;
    end;
    if L = LabelXCDKeepExt then
    begin
      KeepExt := not KeepExt;
    end;
    if L = LabelXCDOverburn then
    begin
      Overburn := not Overburn;
    end;
    if L = LabelXCDCreateInfoFile then
    begin
      CreateInfoFile := not CreateInfoFile;
      if CreateInfoFile then
      begin
        IsoLevel1 := False;
        IsoLevel2 := False;
      end;
    end;
  end;
  {DAE}
  with FSettings.DAE do
  begin
    if L = LabelDAEBulk then
    begin
      Bulk := not Bulk;
    end;
    if L = LabelDAEParanoia then
    begin
      Paranoia := not Paranoia;
    end;
    if L = LabelDAEInfoFiles then
    begin
      NoInfoFile := not NoInfoFile;
    end;
    if L = LabelDAECDDB then
    begin
      UseCDDB := not UseCDDB;
    end;
    if L = LabelDAEMp3 then
    begin
      Mp3 := not Mp3 and FSettings.FileFlags.LameOk and
             (FSettings.FileFlags.ShOk or not FSettings.FileFlags.ShNeeded);
      if Mp3 then
      begin
        Ogg := False;
        Flac := False;
        Custom := False;
      end;
    end;
    if L = LabelDAEOgg then
    begin
      Ogg := not Ogg and FSettings.FileFlags.OggencOk and
             (FSettings.FileFlags.ShOk or not FSettings.FileFlags.ShNeeded);
      if Ogg then
      begin
        Mp3 := False;
        Flac := False;
        Custom := False;
      end;
    end;
    if L = LabelDAEFlac then
    begin
      Flac := not Flac and FSettings.FileFlags.FlacOk and
              (FSettings.FileFlags.ShOk or not FSettings.FileFlags.ShNeeded);
      if Flac then
      begin
        Mp3 := False;
        Ogg := False;
        Custom := False;
      end;
    end;
    if L = LabelDAECustom then
    begin
      Custom := not Custom and
                FileExists(CustomCmd) and
                (FSettings.FileFlags.ShOk or not FSettings.FileFlags.ShNeeded);
      if Custom then
      begin
        Mp3 := False;
        Ogg := False;
        Flac := False;
      end;
    end;
    if L = LabelDAECopy then
    begin
      DoCopy := not DoCopy;
    end;
  end;
  {Video-CD}
  with FSettings.VideoCD do
  begin
    if L = LabelVideoCDOverburn then
    begin
      Overburn := not Overburn;
    end;
    if (L = LabelVideoCDVCD1) or
       (L = LabelVideoCDVCD2) or
       (L = LabelVideoCDSVCD) then
    begin
      VCD1 := L = LabelVideoCDVCD1;
      VCD2 := L = LabelVideoCDVCD2;
      SVCD := L = LabelVideoCDSVCD;
    end;
  end;
  {Änderungen übernehmen}
  GetSettings;
  UpdateOptionPanel;
end;
{$ENDIF}

{ CheckControlsSpeed -----------------------------------------------------------

  CheckControlsSpeed sorgt dafür, daß jeweils die richtige Speedliste den
  Laufwerken zugeordnet wird.                                                  }

procedure TCdrtfeMainForm.CheckControlsSpeeds;
var RWFlag: string;
begin
  if FSettings.General.DetectSpeeds then
  begin
    {Speedlist in Anhängigkeit des Laufwerks wählen}
    case FSettings.General.Choice of
      cDataCD,
      cAudioCD,
      cXCD,
      cVideoCD,
      cDVDVideo,
      cCDRW     : RWFlag := '[W]';
      cDAE,
      cCDInfos  : RWFlag := '[R]';
      cCDImage  : if RadioButtonImageRead.Checked then RWFlag := '[R]' else
                                                       RWFlag := '[W]';
    end;
    ComboBoxSpeed.Items.Clear;
    ComboBoxSpeed.Items.CommaText :=
      FDevices.CDSpeedList.Values[ComboBoxDrives.Items[ComboBoxDrives.ItemIndex]
      + RWFlag];
  end;
  {falls möglich, die für das Tabsheet gespeicherte Geschwindigkeit setzen}
  if FSettings.General.TabSheetSpeed[FSettings.General.Choice] <
     ComboBoxSpeed.Items.Count then
    ComboBoxSpeed.ItemIndex :=
      FSettings.General.TabSheetSpeed[FSettings.General.Choice];
end;

{ CheckControls ----------------------------------------------------------------

  CheckControls sorgt dafür, daß bei den Controls keine inkonsistenten
  Einstellungen vorkommen.                                                     }

procedure TCdrtfeMainForm.CheckControls;

  {lokale Prozeduren nur der Übersicht wegen.}
  procedure SetDrives(DeviceList: TStringList);
  var i: Integer;
  begin
    case FSettings.General.Choice of
      cDataCD,
      cAudioCD,
      cXCD,
      cCDRW,
      cVideoCD,
      cDVDVideo: begin
                   GroupBoxDrive.Caption := FLang.GMS('c002');
                   StaticTextSpeed.Caption := FLang.GMS('c001');
                   SpeedButtonFixCD.Visible := True;
                 end;
      cCDInfos,
      cDAE     : begin
                   GroupBoxDrive.Caption := FLang.GMS('c003');
                   StaticTextSpeed.Caption := FLang.GMS('c004');
                   SpeedButtonFixCD.Visible := False;
                 end;
    end;
    ComboBoxDrives.Items.Clear;
    for i := 0 to (DeviceList.Count - 1) do
    begin
      ComboBoxDrives.Items.Add(DeviceList.Names[i]);
    end;
    i := FSettings.General.Choice;
    if ComboBoxDrives.Items.Count > FSettings.General.TabSheetDrive[i] then
    begin
      ComboBoxDrives.ItemIndex := FSettings.General.TabSheetDrive[i];
    end else
    begin
      ComboBoxDrives.ItemIndex := 0;
      FSettings.General.TabSheetDrive[i] := 0;
    end;
  end;

  {TabSheet3: XCD }
  procedure CheckControlsXCD;
  var i: Integer;
  begin
    if not FSettings.FileFlags.M2CDMOk then
    begin
      for i := 0 to PanelXCD.ControlCount - 1 do
      begin
        PanelXCD.Controls[i].Enabled := False;
      end;
      for i := 0 to TabSheet3.ControlCount - 1 do
      begin
        if TabSheet3.Controls[i] is TSpeedButton then
        begin
          TabSheet3.Controls[i].Visible := False;
        end else
        begin
          TabSheet3.Controls[i].Enabled := False;
        end;
      end;
    end;
  end;

  {TabSheet5: CD-Infos}
  procedure CheckControlsCDInfos;
  begin
    RadioButtonMInfo.Enabled := FSettings.Cdrecord.HaveMediaInfo;
  end;

  { TabSheet6: DAE }
  procedure CheckControlsDAE;
  var i: Integer;
  begin
    if not FSettings.FileFlags.Cdda2wavOk then
    begin
      for i := 0 to PanelDAE.ControlCount - 1 do
      begin
        PanelDAE.Controls[i].Enabled := False;
      end;
    end;
  end;

  { TabSheet7: Image schreiben/erstellen }
  procedure CheckControlsImage;
  var i: Integer;
      CUEImage: Boolean;
  begin
    {Laufwerksliste anpassen}
    if RadioButtonImageRead.Checked then
    begin
      SetDrives(FDevices.CDDevices);
      GroupBoxDrive.Caption := FLang.GMS('c003');
      StaticTextSpeed.Caption := FLang.GMS('c004');
      SpeedButtonFixCD.Visible := False;
    end else
    if RadioButtonImageWrite.Checked then
    begin
      SetDrives(FDevices.CDWriter);
      GroupBoxDrive.Caption := FLang.GMS('c002');
      StaticTextSpeed.Caption := FLang.GMS('c001');
      SpeedButtonFixCD.Visible := True;
    end;
    {Image erstellen}
    for i := 0 to GroupBoxReadCD.ControlCount - 1 do
    begin
      GroupBoxReadCD.Controls[i].Enabled :=
        RadioButtonImageRead.Checked and FSettings.FileFlags.ReadcdOk;
    end;
    CheckBoxReadCDWriteCopy.Enabled :=
      RadioButtonImageRead.Checked and FSettings.FileFlags.ReadcdOk;
    {Sektoren}
    if RadioButtonImageRead.Checked then
    begin
      EditReadCDStartSec.Enabled := CheckBoxReadCDRange.Checked;
      EditReadCDEndSec.Enabled := CheckBoxReadCDRange.Checked;
      StaticTextReadCDStartSec.Enabled := CheckBoxReadCDRange.Checked;
      StaticTextReadCDEndSec.Enabled := CheckBoxReadCDRange.Checked;
    end;
    {Image schreiben: Controls hängen auch vom Typ des Images ab, Prüfung aber
     nur vornehmen, wenn cdrdao oder cdrecord ab 2.01a24 vorhanden ist .}
    CUEImage := False; 
    if FSettings.FileFlags.CdrdaoOk or FSettings.Cdrecord.CanWriteCueImage then
    begin
      GroupBoxImage.Caption := FLang.GMS('c005');
      CUEImage := LowerCase(ExtractFileExt(EditImageIsoPath.text)) = cExtCue;
    end else
    begin
      GroupBoxImage.Caption := FLang.GMS('c006');
    end;
    if not (CUEImage and RadioButtonImageWrite.Checked) then
    begin
      {Normalfall: ISO-Image}
      for i := 0 to PanelImageWriteRawOptions.ControlCount - 1 do
      begin
        PanelImageWriteRawOptions.Controls[i].Enabled :=
          RadioButtonImageWrite.Checked;
      end;
      for i := 0 to GroupBoxImage.ControlCount - 1 do
      begin
        GroupBoxImage.Controls[i].Enabled := RadioButtonImageWrite.Checked;
      end;
      {Schreibmodus}
      if RadioButtonImageWrite.Checked then
      begin
        if RadioButtonImageTAO.Checked then
        begin
          CheckBoxImageOverburn.Enabled := False;
        end else
        begin
          CheckBoxImageOverburn.Enabled := True;
        end;
        if RadioButtonImageRAW.Checked then
        begin
          RadioButtonImageRaw96r.Enabled := True;
          RadioButtonImageRaw96p.Enabled := True;
          RadioButtonImageRaw16.Enabled := True;
          CheckBoxImageClone.Enabled := True;
        end else
        begin
          RadioButtonImageRaw96r.Enabled := False;
          RadioButtonImageRaw96p.Enabled := False;
          RadioButtonImageRaw16.Enabled := False;
          CheckBoxImageClone.Enabled := False;
        end;
      end;
    end else
    begin
      {Sonderfall: CUE-Image; Schreibmodus festgelegt, da cdrdao verwendet wird}
      for i := 0 to GroupBoxImage.ControlCount - 1 do
      begin
        GroupBoxImage.Controls[i].Enabled := RadioButtonImageWrite.Checked;
      end;
      RadioButtonImageTAO.Enabled := False;
      RadioButtonImageDAO.Enabled := False;
      RadioButtonImageRAW.Enabled := False;
      for i := 0 to PanelImageWriteRawOptions.ControlCount - 1 do
      begin
        PanelImageWriteRawOptions.Controls[i].Enabled := False;
      end;
      CheckBoxImageOverburn.Enabled := True;
      CheckBoxImageClone.Enabled := False;
      CheckBoxISOVerify.Enabled := False;
    end;
    {Workaround for odd RadioButton behaviour}
    if FImageTabFirstWrite and Self.Active and
       RadioButtonImageWrite.Checked then
    begin
      FImageTabFirstWrite := False;
      ImageTabInitRadioButtons;
    end;
  end;

  {TabSheet8: Video-CD }
  procedure CheckControlsVideoCD;
  var i: Integer;
  begin
    if not FSettings.FileFlags.VCDImOk then
    begin
      for i := 0 to PanelVideoCD.ControlCount - 1 do
      begin
        PanelVideoCD.Controls[i].Enabled := False;
      end;
      for i := 0 to TabSheet8.ControlCount - 1 do
      begin
        if TabSheet8.Controls[i] is TSpeedButton then
        begin
          TabSheet8.Controls[i].Visible := False;
        end else
        begin
          TabSheet8.Controls[i].Enabled := False;
        end;
      end;
    end;
  end;

begin
  FCheckingControls := True;
  case FSettings.General.Choice of
    cDataCD  : SetDrives(FDevices.CDWriter);
    cAudioCD : SetDrives(FDevices.CDWriter);
    cXCD     : begin
                 CheckControlsXCD;
                 SetDrives(FDevices.CDWriter);
               end;
    cCDRW    : SetDrives(FDevices.CDWriter);
    cCDInfos : begin
                 CheckControlsCDInfos;
                 SetDrives(FDevices.CDDevices);
               end;
    cDAE     : begin
                 CheckControlsDAE;
                 SetDrives(FDevices.CDDevices);
               end;
    cCDImage : CheckControlsImage;
    cVideoCD : begin
                 CheckControlsVideoCD;
                 SetDrives(FDevices.CDWriter);
               end;
    cDVDVideo: SetDrives(FDevices.CDWriter);
  end;
  CheckControlsSpeeds;
  FCheckingControls := False;  
end;

{ SetGlobalWriter --------------------------------------------------------------

  SetGlobalWriter sorgt dafür, daß bei allen Projekten das aktuelle Laufwerk
  eingetellt wird (sofern es sich um einen Brenner handelt).                   }

procedure TCdrtfeMainForm.SetGlobalWriter;
var ActivePage: Byte;
    CurrDrive : Byte;
    i         : Byte;
begin
  ActivePage := GetActivePage;
  CurrDrive := FSettings.General.TabSheetDrive[ActivePage];
  if (ActivePage <> cCDInfos) and (ActivePage <> cDAE) then
  begin
    for i := 1 to TabSheetCount do
      FSettings.General.TabSheetDrive[i] := CurrDrive;
  end;
end;

{ SetButtons -------------------------------------------------------------------

  SetButtons wird benötig, um die Buttons zu deaktivieren, wenn cdrtfe die
  externen Programme ausführt.
  Zusätzlich wird hier das Flag für laufende Prozesse gesetzt und gegebenenfalls
  der Bildschirmschoner deaktiviert.                                           }

procedure TCdrtfeMainForm.SetButtons(const Status: TOnOff);

const cCompCount = 22;
      cCompInverted = 2;
      {$J+}
      Title: string = '';
      {$J-}

var CompArray: array[1..cCompCount] of TComponent;

  procedure SetComponentArray;
  begin
    CompArray[1] := ToolButtonAbort;   // inverted
    CompArray[2] := MainMenuAbort;     // inverted
    CompArray[3] := ButtonStart;
    CompArray[4] := ButtonCancel;
    CompArray[5] := ButtonSettings;
    CompArray[6] := SpeedButtonFixCD;
    CompArray[7] := ToolButtonLoad;
    CompArray[8] := ToolButtonSave;
    CompArray[9] := ToolButtonSettings;
    CompArray[10] := ToolButtonStart;
    CompArray[11] := ToolButtonClose;
    CompArray[12] := MainMenuLoadProject;
    CompArray[13] := MainMenuSaveProject;
    CompArray[14] := MainMenuLoadFileList;
    CompArray[15] := MainMenuSaveFileList;
    CompArray[16] := MainMenuReloadDefaults;
    CompArray[17] := MainMenuReset;
    CompArray[18] := MainMenuStart;
    CompArray[19] := MainMenuErase;
    CompArray[20] := MainMenuFixate;
    CompArray[21] := MainMenuInfoDev;
    CompArray[22] := MainMenuInfoDisk;
  end;

  procedure SwitchComponents(const Value: Boolean);
  var i: Integer;
      v: Boolean;
  begin
    for i := 1 to cCompCount do
    begin
      if i <= cCompInverted then v := not Value else v := Value;
      if CompArray[i] is TControl then (CompArray[i] as TControl).Enabled := v;
      if CompArray[i] is TMenuItem then (CompArray[i] as TMenuItem).Enabled := v;
    end;
  end;

begin
  SetComponentArray;
  if Status = oOff then
  begin
    FSettings.Environment.ProcessRunning := True;
    SwitchComponents(False);
    ButtonAbort.Visible := True;
    if FSettings.General.DisableScrSvr then DeactivateScreenSaver;
    if Title = '' then Title := Application.Title;
    Application.Title := FLang.GMS('g009') + ' ' + Title;
    Self.Update; {damit die Änderngen sofort wirksam werden}
  end else
  begin
    // TLogWin.Inst.ProgressBarDoMarquee(False);
    {$IFDEF Win7Comp}
    TLogWin.Inst.TaskBarProgressIndicatorHide;
    {$ENDIF}
    FSettings.Environment.ProcessRunning := False;
    SwitchComponents(True);
    ButtonAbort.Visible := False;
    if FSettings.General.DisableScrSvr then ActivateScreenSaver;
    Application.Title := Title;
  end;
end;

{ CheckExitCode ----------------------------------------------------------------

  CheckExitCode prüft, ob ein Fehler aufgetreten ist und gibt einen Hinweis
  aus.                                                                         }

{$IFDEF ShowCmdError}
procedure TCdrtfeMainForm.CheckExitCode;
begin
  if FExitCode = 142 then
    {ProDVD-Lizenz-Fehler}
    ShowMsgDlg(FLang.GMS('e002'), FLang.GMS('g001'), MB_cdrtfeError);
  if FExitCode <> 0 then
  begin
    {sonstiger Fehler}
    ShowMsgDlg(FLang.GMS('e001'), FLang.GMS('g001'), MB_cdrtfeError);
    if not FLogWindowShowing then ToggleLogWindow(True);
  end;
  FExitCode := 0;
end;
{$ENDIF}

{ ToggleStayOnTopState ---------------------------------------------------------

  StayOnTop-Status umschalten.                                                 }

procedure TCdrtfeMainForm.ToggleStayOnTopState;
begin
  StayOnTopState := not StayOnTopState;
  WindowStayOnTop(Self.Handle, StayOnTopState);
end;

{ Initialisierungen -----------------------------------------------------------}

{ InitMainform -----------------------------------------------------------------

  Diese Prozdedur initialisiert das Hauptfenster. Die Grafiken für die Speed-
  buttons werden geladen, die ImageListen an die Tree- und ListViews zugewiesen
  und Drag-and-Drop wird zugelassen.                                           }

procedure TCdrtfeMainForm.InitMainform;
var GlyphArray    : TGlyphArray;

  {lokale Prozedur zum Registrieren der Label-OnClick-Eventhandler}
  {$IFDEF AllowToggle}
  procedure RegisterLabelEvents;
  var i: Integer;
      j: Integer;
      Panel: TPanel;
  begin
    for i := 0 to Self.ComponentCount - 1 do
    begin
      if Self.Components[i] is TPanel then
      begin
        Panel := Self.Components[i] as TPanel;
        if (Panel = PanelDataCDOptions) or
           (Panel = PanelAudioCDOptions) or
           (Panel = PanelXCDOptions) or
           (Panel = PanelVideoCDOptions) or
           (Panel = PanelDAEOptions) then
        begin
         {$IFDEF MouseOverLabelHighlight}
          Panel.OnMouseMove := PanelMouseMove;
         {$ENDIF}
          for j := 0 to Panel.ControlCount - 1 do
          begin
            if Panel.Controls[j] is TLabel then
            begin
              (Panel.Controls[j] as TLabel).OnClick := LabelClick;
              {$IFDEF MouseOverLabelCursor}
              (Panel.Controls[j] as TLabel).Cursor:=crHandPoint;
              {$ENDIF}
              {$IFDEF MouseOverLabelHighlight}
              (Panel.Controls[j] as TLabel).OnMouseMove := LabelMouseMove;
              {$ENDIF}
            end;
          end;
        end;
      end;
    end;
  end;
  {$ENDIF}

  {Prozedure zum Initialisieren des Glyph-Arrays.}
  procedure InitGlyphArray(var Glyphs: TGlyphArray);
  begin
    Glyphs[1]  := CDESpeedButton1.Glyph;
    Glyphs[2]  := CDESpeedButton2.Glyph;
    Glyphs[3]  := CDESpeedButton3.Glyph;
    Glyphs[4]  := CDESpeedButton4.Glyph;
    Glyphs[5]  := CDESpeedButton5.Glyph;
    Glyphs[6]  := Sheet1SpeedButtonCheckFS.Glyph;
    Glyphs[7]  := AudioSpeedButton2.Glyph;
    Glyphs[8]  := AudioSpeedButton3.Glyph;
    Glyphs[9]  := AudioSpeedButton1.Glyph;
    Glyphs[10] := AudioSpeedButton4.Glyph;
    Glyphs[11] := XCDESpeedButton1.Glyph;
    Glyphs[12] := XCDESpeedButton2.Glyph;
    Glyphs[13] := XCDESpeedButton3.Glyph;
    Glyphs[14] := XCDESpeedButton4.Glyph;
    Glyphs[15] := XCDESpeedButton5.Glyph;
    Glyphs[16] := XCDESpeedButton6.Glyph;
    Glyphs[17] := XCDESpeedButton7.Glyph;
    Glyphs[18] := VideoSpeedButton2.Glyph;
    Glyphs[19] := VideoSpeedButton3.Glyph;
    Glyphs[20] := VideoSpeedButton1.Glyph;
    Glyphs[21] := VideoSpeedButton4.Glyph;
  end;

  {ListView-Array initialisieren}
  procedure InitLVArray;
  begin
    FLVArray[0] := CDEListView;
    FLVArray[1] := AudioListView;
    FLVArray[2] := XCDEListView1;
    FLVArray[3] := XCDEListView2;
    FLVArray[4] := DAEListView;
    FLVArray[5] := VideoListView;
  end;

  procedure InitFileBrowser;
  begin
    PanelBrowser.Top := 8; //PageControl1.Top + 27;
    PanelBrowser.Left := 8; // PageControl1.Left + 12;
    PanelBrowser.Width := PageControl1.Width - 12 - 36; //41;
    PanelBrowser.Height := FSettings.FileExplorer.Height;
    PanelBrowser.Color := clBackground;
    PanelBrowser.Anchors := [akLeft, akTop, akRight];
    FileBrowser := TFrameFileBrowser.Create(Self);
    FileBrowser.Parent := PanelBrowser;
    FileBrowser.TreeViewWidth := CDETreeView.Width;
    FileBrowser.OnFFBSelected := FileBrowserSelected;
    FileBrowser.LabelCaption := FLang.GMS('g016');
    FileBrowser.ColCaptionName := CDEListView.Columns[0].Caption;
    FileBrowser.ColCaptionSize := CDEListView.Columns[2].Caption;
    FileBrowser.ColCaptionType := CDEListView.Columns[1].Caption;
    FileBrowser.ColCaptionModified := FLang.GMS('g015');
    FileBrowser.Init;
    FileBrowser.Show;
    PanelTabSheet1.ParentBackground := True;
    PanelTabSheet2.ParentBackground := True;
    PanelTabSheet3.ParentBackground := True;
    PanelTabSheet8.ParentBackground := True;
  end;

  procedure InitMainMenu;
  begin
    MainMenu1.Images := FImageLists.ToolButtonImages;
    MainMenuClose.ImageIndex := 4;
    MainMenuLoadProject.ImageIndex := 0;
    MainMenuSaveProject.ImageIndex := 1;
    MainMenuSettings.ImageIndex := 2;
    MainMenuStart.ImageIndex := 3;
    MainMenuAbort.ImageIndex := 5;
  end;

  procedure InitToolButtonHints;
  begin
    ToolButtonLoad.Hint := ReplaceString(MainMenuLoadProject.Caption, '&', '');
    ToolButtonSave.Hint := ReplaceString(MainMenuSaveProject.Caption, '&', '');
    ToolButtonSettings.Hint := ReplaceString(MainMenuSettings.Caption, '&', '');
    ToolButtonStart.Hint := ReplaceString(MainMenuStart.Caption, '&', '');
    ToolButtonAbort.Hint := ReplaceString(MainMenuAbort.Caption, '&', '');
    ToolButtonClose.Hint := ReplaceString(MainMenuClose.Caption, '&', '');
  end;

begin
  //SetDoubleBuffered(True);
  Application.Title := LowerCase(Application.Title);
  {Drag'n'Drop für dieses Fenster zulassen}
  DragAcceptFiles(Self.Handle, true);
  {Constraints für minimale Fenstergröße}
  if (Screen.PixelsPerInch <= 96) then
  begin
    Self.Constraints.MinWidth := dWidth;
    Self.Constraints.MinHeight := dHeight;
  end else
  begin
    Self.Constraints.MinWidth := dWidthBigFont;
    Self.Constraints.MinHeight := dHeightBigFont;
  end;
  {Bitmaps für die Glyphs laden}
  InitGlyphArray(GlyphArray);
  FImageLists.LoadGlyphs(GlyphArray);
  {Den Tree- und ListViews die Image-Listen zuweisen}
  CDEListView.LargeImages := FImageLists.LargeImages;
  CDEListView.SmallImages := FImageLists.SmallImages;
  CDETreeView.Images := FImageLists.IconImages;
  AudioListView.SmallImages := FImageLists.SmallImages;
  XCDEListView1.LargeImages := FImageLists.LargeImages;
  XCDEListView1.SmallImages := FImageLists.SmallImages;
  XCDEListView2.LargeImages := FImageLists.LargeImages;
  XCDEListView2.SmallImages := FImageLists.SmallImages;
  XCDETreeView.Images := FImageLists.IconImages;
  DAEListView.SmallImages := FImageLists.IconImages;
  DAEListView.LargeImages := FImageLists.IconImages;
  VideoListView.SmallImages := FImageLists.SmallImages;
  {ToolbarImages}
  Toolbar1.Images := FImageLists.ToolButtonImages;
  Toolbar1.DisabledImages := FImageLists.ToolButtonImagesD;
  InitToolButtonHints;
  {OnClick-Event für Option-Labels zuweisen}
  {$IFDEF AllowToggle}
  RegisterLabelEvents;
  {$ENDIF}
  {Array mit den ListViews}
  InitLVArray;
  {FileBroser}
  InitFileBrowser;
  {LogWindow}
  FLogWindowShowing := True;
  MainMenuToggleLogWindow.Checked := True;
  {Device-Events}
  DeviceChangeNotifier.OnDiskInserted := Self.DeviceArrival;
  DeviceChangeNotifier.OnDiskRemoved := Self.DeviceRemoval;
  {Mainmenu-Icons}
  InitMainMenu;
end;

{ InitSpaceMeter ---------------------------------------------------------------

  initialiert die Anzeige für den genutzten Speicher auf einer Disk.           }

procedure TCdrtfeMainForm.InitSpaceMeter;
begin
  SpaceMeter := TSpaceMeter.Create(Self);
  SpaceMeter.Font := Self.Font;
  SpaceMeter.Captions := FLang.GMS('g014');
  SpaceMeter.Init(Self, StatusBar.Top - 34, 8,
                 {545}{Memo1.Width}PageControl1.Width, 30,
                  [akLeft, akRight, akBottom]);
  SpaceMeter.OnSpaceMeterTypeChange := SpaceMeterTypeChange;
end;

{ InitTreeView -----------------------------------------------------------------

  einen bestimmten Tree-View initialisieren.                                   }

procedure TCdrtfeMainForm.InitTreeView(Tree: TTreeView; const Choice: Byte);
var i: Byte;
begin
  {hier muß FSettings.General.Choice temporär gesetzt werden, um sicherzu-
   stellen, daß AddItemToListView funktioniert.}
  i := FSettings.General.Choice;
  FSettings.General.Choice := Choice;
  {TreeView-Tool-Tips abschalten}
  SetWindowLong(Tree.Handle, GWL_Style,
                GetWindowLong(Tree.Handle, GWL_Style) or TVS_NoTooltips);
  {alle Elemente löschen}
  Tree.Items.Clear;
  {Datenstruktur in den Tree-View übertragen}
  FData.ExportStructureToTreeView(Choice, Tree);
  Tree.Items[0].ImageIndex := FImageLists.IconCD;
  Tree.Items[0].SelectedIndex := FImageLists.IconCD;
  {verhindert einen Heisen-Bug beim Verschieben von Dateien: wenn keine
   Ordner selektiert sind, dann werden fälschlicherweise im XCD-List-View die
   im CD-List-View bewegten Dateien angezeigt. Diese Anweisung stellt sicher,
   daß auch direkt nach dem Start, die Wurzelknoten selektiert sind.}
  SelectRootIfNoneSelected(Tree);
  FSettings.General.Choice := i;
end;

{ InitTreeViews ----------------------------------------------------------------

  InitTreeViews initialisiert alle Tree-Views.                                 }

procedure TCdrtfeMainForm.InitTreeViews;
begin
  InitTreeView(CDETreeView, cDataCD);
  InitTreeView(XCDETreeView, cXCD);
end;

{ ImageTabInitRadioButtons -----------------------------------------------------

  Workaround for odd behaviour when changing to radio buttons via Tab.         }

procedure TCdrtfeMainForm.ImageTabInitRadioButtons;
var TAO, DAO, RAW: Boolean;
    Ok           : Boolean;
    OldControl   : TWinControl;
begin
  Ok := RadioButtonImageTAO.Enabled and RadioButtonImageDAO.Enabled and
        RadioButtonImageRAW.Enabled;
  if Ok and Self.Active and (PageControl1.ActivePage = TabSheet7) and
     RadioButtonImageWrite.Checked then
  begin
    OldControl := ActiveControl;
    TAO := RadioButtonImageTAO.Checked;
    DAO := RadioButtonImageDAO.Checked;
    RAW := RadioButtonImageRAW.Checked;
    RadioButtonImageTAO.SetFocus;
    RadioButtonImageDAO.SetFocus;
    RadioButtonImageRAW.SetFocus;
    RadioButtonImageTAO.Checked := TAO;
    RadioButtonImageDAO.Checked := DAO;
    RadioButtonImageRAW.Checked := RAW;
    FImageTabFirstShow := False;
    if OldControl <> nil then OldControl.SetFocus;
  end;
end;


{ Eventverarbeitung ---------------------------------------------------------- }

{ eigene Events -------------------------------------------------------------- }

{ DeviceArrival/DeviceRemoval ------------------------------------------------ }

procedure TCdrtfeMainForm.DeviceArrival(Drive: string);
begin
  // TLogWin.Inst.Add('Arrival: ' + Drive);
  if Self.FSettings.General.DetectSpeeds then
  begin
    Self.UpdatePanels('<>', Self.FLang.GMS('m124'));
    Self.FDevices.UpdateSpeedLists(Drive);
    Self.CheckControlsSpeeds;
    Self.UpdatePanels('<>', '');
  end;
end;

procedure TCdrtfeMainForm.DeviceRemoval(Drive: string);
begin
  // TLogWin.Inst.Add('Removal: ' + Drive);
end;

{ FileBrowserSelected ----------------------------------------------------------

  wird ausgelöst, wenn im FileBrowser eine Auswahl getroffen wurde.            }

procedure TCdrtfeMainForm.FileBrowserSelected(Sender: TObject);
begin
  case FSettings.General.Choice of
    cDataCD,
    cAudioCD,
    cDVDVideo,
    cCDImage,
    cVideoCD : CDEListViewDragDrop(Sender, Sender, 0, 0);
    cXCD     : XCDEListView1DragDrop(Sender, Sender, 0, 0);
  end;
end;

{ LangChange -------------------------------------------------------------------

  Reaktionen auf das LangChange-Event.                                         }

procedure TCdrtfeMainForm.LangChange;

  procedure SetLangFileBrowser;
  begin
    FileBrowser.LabelCaption := FLang.GMS('g016');
    FileBrowser.ColCaptionName := CDEListView.Columns[0].Caption;
    FileBrowser.ColCaptionSize := CDEListView.Columns[2].Caption;
    FileBrowser.ColCaptionType := CDEListView.Columns[1].Caption;
    FileBrowser.ColCaptionModified := FLang.GMS('g015');
    FileBrowser.UpdateTranslation;
  end;

begin
  with FLang do
  begin
    SizeToStringSetUnits(GMS('g005'), GMS('g006'), GMS('g007'), GMS('g008'));
    SetButtonCaptions(GMS('rs01'), GMS('rs02'), GMS('rs03'), GMS('rs04'));
  end;
  FLang.SetFormLang(Self);
  SetLangFileBrowser;
  CheckControls;
  UpdateGauges;
  FormResize(Self);
  SetHelpFile;
end;

{ MessageShow ------------------------------------------------------------------

  MessageShow zeigt den übergebenen String an.
  Dieser Mechanismus wird genutzt, damit andere Forms oder Klassen im Memo des
  Hauptfensters Text anzeigen können, ohne frm_main.pas einzubinden und direkt
  auf die Form1.Controls zuzugreifen.
  Wahscheinlich gibt es eine bessere oder elegantere Methode. ;-)              }

procedure TCdrtfeMainForm.MessageShow(const s: string);
begin
  TLogWin.Inst.Add(s);
end;

{ UpdatePanels -----------------------------------------------------------------

  UpdatePanels zeigt in den beiden Panels des Status-Bars die Strings s1 und s2
  an. Wenn der String den Inhalt '<>' haben sollte, wird der Panel-Text nicht
  geändert.                                                                    }

procedure TCdrtfeMainForm.UpdatePanels(const s1, s2: string);
begin
  if s1 <> '<>' then StatusBar.Panels[0].Text := s1;
  if s2 <> '<>' then StatusBar.Panels[1].Text := s2;
end;

{ GetProgressBar ---------------------------------------------------------------

  liefert den entsprechenden ProgresBar.                                       }

function TCdrtfeMainForm.GetProgressBar(const PB: Integer): TProgressBar;
begin
  case PB of
    1: Result := ProgressBar;       // lower ProgressBar
    2: Result := ProgressBarTotal;  // upper ProgressBar
  else
    Result := nil;
  end;
end;

{ ProgressBarDoMarquee ---------------------------------------------------------

  ProgressBar in den Marquee-Modus versetzen.                                  }

procedure TCdrtfeMainForm.ProgressBarDoMarquee(const PB: Integer;
                                               const Active: Boolean);
var Bar: TProgressBar;
begin
  Bar := GetProgressBar(PB);
  if Bar <> nil then SetProgressBarMarquee(Bar, Active);
end;

{ ProgressBarHide --------------------------------------------------------------

  ProgressBarHide macht den Progress-Bar unsichtbar.                           }

procedure TCdrtfeMainForm.ProgressBarHide(const PB: Integer);
var Bar: TProgressBar;
begin
  Bar := GetProgressBar(PB);
  if Bar <> nil then Bar.Visible := False;
end;

{ ProgressBarShow --------------------------------------------------------------

  ProgressBarReset setzt ProgressBar.Position auf Null, ProgressBar.Max auf
  Max und ProgressBar.Visible auf True.                                        }

procedure TCdrtfeMainForm.ProgressBarShow(const PB, Max: Integer);
var Bar: TProgressBar;
begin
  Bar := GetProgressBar(PB);
  if Bar <> nil then
  begin
    Bar.Position := 0;
    Bar.Max := Max;
    Bar.Visible := True;
  end;
end;

{ ProgressBarUpdate ------------------------------------------------------------

  ProgressBarReset setzt StatusBar.Position auf FSettings.Shared.
  ProgressBarPosition.                                                         }

procedure TCdrtfeMainForm.ProgressBarUpdate(const PB, Position: Integer);
var Bar: TProgressBar;
begin
  Bar := GetProgressBar(PB);
  if Bar <> nil then Bar.Position := Position;
end;

{ SpaceMeterTypeChange ---------------------------------------------------------

  Speichert den neues Disk-Type des SpaceMeters.                               }

procedure TCdrtfeMainForm.SpaceMeterTypeChange;
begin
  FSettings.General.TabSheetSMType[FSettings.General.Choice] :=
                                                   Integer(SpaceMeter.DiskType);
  StatusBar.Panels[1].Text := SpaceMeter.RemainingSpaceString;
end;


{ Form-Events ---------------------------------------------------------------- }

{ FormCreate -------------------------------------------------------------------

  Diese Prozedur wird beim Erzeugen des Fensters abgearbeitet. Hier werden not-
  wendige Initialisierungen vorgenommen.                                       }

procedure TCdrtfeMainForm.FormCreate(Sender: TObject);
var DummyHandle: HWND;
    TempChoice : Byte;
begin
  {Fix für Win7-Vista-Alt-Bug}
  TVistaAltFix.Create(Self);
  FImageTabFirstShow   := True;
  FImageTabFirstWrite  := True;
  FCheckingControls    := False;
  FFileExplorerShowing := False;
  FOutputWindowShowing := False;
  InitActions;
  {$IFDEF WriteLogfile} AddLogCode(1051); {$ENDIF}
  SetFont(Self);
  FInstanceTermination := False;
  {Ein paar Objekte brauchen wir, egal ob es sich um die erste oder zweite
   Instanz handelt.}
  {Objekt mit Sprachinformationen}
  FLang := TLang.Create;
  with FLang do
  begin
    OnLangChange := LangChange;
    {Einheiten übersetzen}
    SizeToStringSetUnits(GMS('g005'), GMS('g006'), GMS('g007'), GMS('g008'));
    {Buttons der Messagedialoge übersetzen}
    SetButtonCaptions(GMS('rs01'), GMS('rs02'), GMS('rs03'), GMS('rs04'));
    MainMenuSetLang.Enabled := LangFileFound;
    MainMenuLang.Enabled := LangFileFound;
    CreateLangSubMenu(MainMenuLang);
    {Spracheinstellungen setzen}
    SetFormLang(Self);
  end;
  {Hilfe-Datei setzten}
  SetHelpFile;
  {Objekt mit den Laufwerksinfos}
  FDevices := TDevices.Create;
  {Objekt für Einstellungen}
  FSettings := TSettings.Create;
  FSettings.Lang := FLang;
  FSettings.OnUpdatePanels := UpdatePanels;
  FSettings.OnProgressBarHide := ProgressBarHide;
  FSettings.OnProgressBarShow := ProgressBarShow;
  FSettings.OnProgressBarUpdate := ProgressBarUpdate;
  {Datenobjekt}
  FData := TProjectData.Create;
  FData.Lang := FLang;
  FData.OnUpdatePanels := UpdatePanels;
  FData.OnProgressBarHide := ProgressBarHide;
  FData.OnProgressBarShow := ProgressBarShow;
  FData.OnProgressBarUpdate := ProgressBarUpdate;
  FData.OnProjectError := HandleError;
  {Diese wichtigen drei Objekte global verfügbar machen.}
  TCdrtfeData.Instance.SetObjects(FLang, FSettings, FData);
  {Ausgabefenster global verfügbar machen.}
  TLogWin.Inst.SetMemo(Memo1);
  TLogWin.Inst.OnUpdatePanels := UpdatePanels;
  TLogWin.Inst.OnProgressBarDoMarquee := ProgressBarDoMarquee;
  TLogWin.Inst.OnProgressBarHide := ProgressBarHide;
  TLogWin.Inst.OnProgressBarShow := ProgressBarShow;
  TLogWin.Inst.OnProgressBarUpdate := ProgressBarUpdate;
  {Kommandzeile auswerten}
  FCmdLineParser := TCmdLineParser.Create;
  FCmdLineParser.Settings := FSettings;
  FCmdLineParser.Data := FData;
  FCmdLineParser.FormCaption := Self.Caption;
  FCmdLineParser.ParseCommandLine;
  {jetzt auf eine bereits laufende Instanz prüfen}
  if IsFirstInstance(DummyHandle, 'TCdrtfeMainForm', Self.Caption) then
  begin {die aktuelle Instanz ist die erste}
    {Image-Listen erzeugen}
    FImageLists := TImageLists.Create(Self);
    {Hautpfenster initialisieren}
    InitMainForm;
    {Tree-Views initialisieren}
    InitTreeViews;
    {OLE-Drop-Target initialisieren}
    InitDropTargets;
    {SpaceMeter initialisieren}
    InitSpaceMeter;
    {FileTypeInfo: Cache für Dateiinfos}
    FFileTypeInfo := TFileTypeInfo.Create;
    {prüfen, ob alle Dateien da sind}
    if CheckFiles(FSettings, FLang) then
    begin
      {Wenn die entrpechenden Programme vorhanden sind, können MP3-, Ogg-, Ape-
       und FLAC-Dateien verwendet werden.}
      FData.AcceptMP3 := FSettings.FileFlags.MPG123Ok;
      FData.AcceptOgg := FSettings.FileFlags.OggdecOk;
      FData.AcceptFLAC := FSettings.FileFlags.FLACOk;
      FData.AcceptApe := FSettings.FileFlags.MonkeyOk;
      {Einstellungen laden: Ini}
      FSettings.LoadFromFile(cIniFile);
      if FSettings.General.PortableMode then      
        SendMessage(FindWindow('TFormSplashScreen', 'FormSplashScreen'),
          WM_SplashScreen, wmwpSetPortable, 0);
      {Datenverzeichnis anlegen (WinNT/2k/XP)}
      if FSettings.General.PortableMode then OverrideProgDataDir(True);
      ProgDataDirCreate;
      {Device-Scan}
      with FDevices do
      begin
        UseRSCSI := FSettings.Drives.UseRSCSI;
        RSCSIHost := FSettings.Drives.RSCSIString;
        RemoteDrives := FSettings.Drives.RemoteDrives;
        LocalDrives := FSettings.Drives.LocalDrives;
        AssignManually := FSettings.Drives.AssignManually;
        ForcedInterface := FSettings.Drives.SCSIInterface;
        DetectDrives;
        if (CDWriter.Count = 1) and (CDWriter[0] = '') then
        begin
          TLogWin.Inst.Add(FLang.GMS('g003') + CRLF + FLang.GMS('minit05'));
        end;
      end;
      {Falls vorhanden, d2fgui.exe und dat2file.exe hinzufügen}
      TempChoice := FSettings.General.Choice;
      FSettings.General.Choice := cXCD;
      if FileExists(StartUpDir + cM2F2ExtractBin) then
      begin
        AddToPathlist(StartUpDir + cM2F2ExtractBin);
      end;
      if FileExists(StartUpDir + cDat2FileBin) then
      begin
        AddToPathlist(StartUpDir + cDat2FileBin);
      end;
      if FileExists(StartUpDir + cD2FGuiBin) then
      begin
        AddToPathlist(StartUpDir + cD2FGuiBin);
      end;
      AddToPathlistSort(False);
      FSettings.General.Choice := TempChoice;
      {Einstellungen in GUI übernehmen}
      GetSettings;
      {Tree-Views erneut initialisieren}
      InitTreeViews;
      {Objekt zum Ausführen der Aktion}
      FAction := TCDAction.Create;
      FAction.Data := FData;
      FAction.Devices := FDevices;
      FAction.Settings := FSettings;
      FAction.Lang := FLang;
      FAction.ProgressBar := Self.ProgressBar;
      FAction.StatusBar := Self.StatusBar;
      FAction.FormHandle := Self.Handle;
      FAction.OnMessageShow := MessageShow;
      FAction.OnUpdatePanels := UpdatePanels;
      FAction.Init;
    end else
    begin
      FDevices.SetDummyDevices;
    end;
    {falls der Aufruf mit /hide erfolgte, Hauptfenster verstecken}
    if FSettings.CmdLineFlags.Hide then
    begin
      Application.ShowMainForm := False;
      {Wir haben jetzt verhindert, daß das Fenster angezeigt wird, also werden
       FormShow und FormActivate nich ausgelöst. Also die Eventhandler manuell
       auslösen.}
      FormShow(Self);
      FormActivate(Self);
    end;
  end else
  begin {es gibt eine weitere Instanz}
    {verhindern, daß diese Instanz angezeigt wird}
    Application.ShowMainForm:= False;
    {Kommandozeile auswerten:
     Da eine zweite Instanz sowieso keine Projekt-Dateien laden soll, kann die
     Kommandozeile auch gleich hier ausgeführt werden. Durch 'ShowMainForm :=
     False' wird jedes auch noch so kurzes Auftauchen eines zweiten Fensters
     verhindert.}
    FCmdLineParser.ExecuteCommandLine;
    {Instanz beenden}
    FInstanceTermination := True;
    Application.Terminate;
  end;
end;

{ FormDestroy ------------------------------------------------------------------

  Hier werden die in FormCreate erzeugten Objekte wieder freigegeben.          }

procedure TCdrtfeMainForm.FormDestroy(Sender: TObject);
begin
  {$IFDEF WriteLogfile} AddLogCode(1052); {$ENDIF}
  if not FInstanceTermination then FreeDropTargets;
  FLang.Free;
  FImageLists.Free;
  FSettings.Free;
  FData.Free;
  FFileTypeInfo.Free;
  FAction.Free;
  FCmdLineParser.Free;
  FDevices.Free;
  {ListView-Bug: Wenn ein List-View beim Beenden automatisch zerstört wird, er-
   zeugt dies einen unbekannten Win32 Fehler in TWinControl.DestroyWindowHandle.
   Dieses Verhalten kann verhindert werden, indem man in FormDestroy den List-
   View explizit freigibt. Möglicherweise hat dies Nebenwirkungen, daher ist
   dieses Verhalten per Kompilerdirektive steuerbar.}
  {$IFDEF ManualFreeListView}
  CDEListView.Free;
  AudioListView.Free;
  XCDEListView1.Free;
  XCDEListView2.Free;
  DAEListView.Free;
  VideoListView.Free;
  {$ENDIF}
  SpaceMeter.Free;
end;

{ FormShow ---------------------------------------------------------------------

  Hier werden Dinge erledigt, die vor dem ersten Anzeigen des Fensters nötig
  sind, aber in FormCreate noch nicht ausgeführt werden können.                }

procedure TCdrtfeMainForm.FormShow(Sender: TObject);
var i: Byte;
    OldChoice: Byte;
begin
  {$IFDEF WriteLogfile} AddLogCode(1053); {$ENDIF}
  {einmal jedes Tab aktivieren, sonst funktioniert FormResize nicht richtig.
   Außerdem wird damit gewährleistet, daß FSettings.General.Choice initialisiert
   ist.}
  for i := 1 to PageControl1.PageCount do ActivateTab(i);
  ActivateTab(cDataCD);
  {Das Laden der Projekt-Datei kann noch nicht in der OnCreate-Prozedur
   erfolgen -> Access Violation. Beim Laden eines Projektes wird der Zugriff auf
   Form1 benötigt. Deshalb für die erste Instanz erst hier der Aufruf von
   ExecutCommandLine. Zu einer doppelten Ausführung in der zweiten Instanz kommt
   es nicht, da dort FormShow nie erreicht wird. Und falls doch, ist es auch
   egal, da das Objekt ParsedCmdLine geleert wurde.}
  FCmdLineParser.ExecuteCommandLine;
  {Fehlerbehandlung: Project-File nicht gefunden}
  if FSettings.General.LastProject <> '' then
  begin
    if FCmdLineParser.LastError = CP_ProjectFileNotFound then
    begin
      TLogWin.Inst.Add(Format(FLang.GMS('epref01'),
                              [FSettings.General.LastProject]));
    end else
    begin
      GetSettings;
      CheckControls;
      UpdateOptionPanel;
      OldChoice := FSettings.General.Choice;
      for i := 1 to 3 do
      begin
        FSettings.General.Choice := i;
        AddToPathlistSort(True);
        ActivateTab(i);
        UpdateGauges;
      end;
      FSettings.General.Choice := OldChoice;
      ActivateTab(OldChoice);
    end;
  end;
  SetWinPos;
  {Gegebenenfalls Startmeldungen anzeigen}
  if (Memo1.Lines.Count > 0) and not FLogWindowShowing then
    ToggleLogWindow(True);
  {$IFDEF ShowStartupTime}
  TC.StopTimeCount;
  TLogWin.Inst.Add('StartupTime: ' + TC.TimeAsString);
  {$ENDIF}
end;

{ FormActivate -----------------------------------------------------------------

  Der automatische Brennvorgang wird erst hier ausgelöst, damit das Fenster
  auch ganz sicher zu sehen ist.                                               }

procedure TCdrtfeMainForm.FormActivate(Sender: TObject);
begin
  {$IFDEF WriteLogfile} AddLogCode(1054); {$ENDIF}
  if FSettings.CmdLineFlags.ExecuteProject then
  begin
    SetSettings;
    if InputOk then
    begin
      {Fenster falls gewünscht minimieren}
      if FSettings.CmdLineFlags.Minimize then Application.Minimize;
      {Taskbareintrag verschwinden lassen}
      if FSettings.CmdLineFlags.Hide then
      begin
        ShowWindow(GetWindow(Handle,GW_OWNER), SW_HIDE);
      end;
      {Aktion ausführen}
      FAction.Action := FSettings.General.Choice;
      FAction.StartAction;
    end else
    begin
      {im Fehlerfalle cdrtfe anzeigen}
      Application.ShowMainForm := True;
      Application.Restore;
    end;
  end;
  {temporäres Verzeichnis erfragen, damit cdrtfe auch von einem read-only-Medium
   gestartet werden kann.}
  if FSettings.General.AskForTempDir then OverrideProgDataDir(False);
end;

{ FormResize -------------------------------------------------------------------

  Größenänderung des Hauptfensters, ursprünglich Mod by Oli. Sonderbehandlung
  für die Speedbuttons auf TabSheet3 (XCD).                                    }

procedure TCdrtfeMainForm.FormResize(Sender: TObject);
const cMinTaskHeight = 195;
var TSHeight                 : Integer;
    CanShowFileExplorer      : Boolean;
    ShouldNotShowFileExplorer: Boolean;
    FileExplorerHeight       : Integer;
begin
  if not (csDestroying in ComponentState) then
  begin
    {Resize bei kleiner Schriftart}
    if (Screen.PixelsPerInch <= 96) and not Application.Terminated then
    begin
      {TabSheet3}
      {Höhe des aktuellen TabSheets}
      TSHeight := PanelTabSheet3.Height; // PageControl1.ActivePage.Height;
      PanelXCD.Top := TSHeight - 101;
      PanelXCDView.Height := PanelXCD.Top + PanelXCDOptions.Height - 8;
      PanelXCDView.Width := XCDESpeedButton1.Left - 15;
      XCDETreeView.Height := PanelXCD.Top - 15;
      XCDEListView1.Height := (PanelXCDViewRight.Height -
                               SplitterXCDHorizontal.Height) div 2;
      XCDESpeedButton4.Top := XCDEListView2.Top + 24 + 8;
      XCDESpeedButton5.Top := XCDEListView2.Top + 56 + 8;
    end else
    {Resize mit großer Schriftart}
    if (Screen.PixelsPerInch > 96) and not Application.Terminated then
    begin
      {TabSheet3}
      {Höhe des aktuellen TabSheets}
      TSHeight := PanelTabSheet3.Height; //PageControl1.ActivePage.Height;
      PanelXCD.Top := TSHeight - 127;
      PanelXCDView.Height := PanelXCD.Top + PanelXCDOptions.Height - 8;
      PanelXCDView.Width := XCDESpeedButton1.Left - 15;
      XCDETreeView.Height := PanelXCD.Top - 15;
      XCDEListView1.Height := (PanelXCDViewRight.Height -
                               SplitterXCDHorizontal.Height) div 2;
      XCDESpeedButton4.Top := XCDEListView2.Top + 24 + 8;
      XCDESpeedButton5.Top := XCDEListView2.Top + 56 + 8;
    end;
    {FileExplorer anpassen}
    FSettings.FileExplorer.Height := Round(TabSheet1.Height * 0.45);
    FileExplorerHeight := FSettings.FileExplorer.Height + 4;
    if FFileExplorerShowing then
    begin
      PanelBrowser.Height := FSettings.FileExplorer.Height;
      SetPanelSize(True, FileExplorerHeight);
    end;
    {In Abhängigkeit der Fensterhöhe FileExplorer zulassen oder nicht}
    CanShowFileExplorer :=
      ((PanelTabSheet1.Height - FileExplorerHeight) >= cMinTaskHeight);
    if not FInstanceTermination then
      MainMenuToggleFileExplorer.Enabled := FFileExplorerShowing or
                                            CanShowFileExplorer;
    {gegebenenfalls FileExplorer automatisch ausblenden oder anpassen}
    ShouldNotShowFileExplorer := FFileExplorerShowing and
      not (CanShowFileExplorer or (PanelTabSheet1.Height >= cMinTaskHeight));
    if ShouldNotShowFileExplorer then
    begin
      ToggleFileExplorer(False);
    end;
  end;
end;

{ FormCloseQuery ---------------------------------------------------------------

  prüft, ob noch ein Prozess läuft. Falls ja, wird der User darauf hingewiese. }

procedure TCdrtfeMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if FSettings.Environment.ProcessRunning then
    CanClose := ShowMsgDlg(FLang.GMS('eburn18'), FLang.GMS('g003'),
                           MB_cdrtfeWarningYN) = ID_YES;
end;

{ FormClose --------------------------------------------------------------------

  In FormClose werden die Einstellungen gespeichert, sofern die automatische
  Speicheung beim Beenden aktiviert ist.                                       }

procedure TCdrtfeMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  {$IFDEF WriteLogfile} AddLogCode(1055); {$ENDIF}
  {Einstellungen speichern}
  SaveWinPos;
  if FSettings.General.AutoSaveOnExit then
  begin
    SetSettings;
    FSettings.SaveToFile(cIniFile);
  end;
  if FSettings.General.PortableMode then CleanRegistryPortable;
end;

procedure TCdrtfeMainForm.FormDblClick(Sender: TObject);
{$IFDEF CreateAllForms}
var FormDataCDOptions : TFormDataCDOptions;
    FormDataCDFS      : TFormDataCDFS;
    FormDataCDFSError : TFormDataCDFSError;
    FormAudioCDOptions: TFormAudioCDOptions;
    FormAudioCDTracks : TFormAudioCDTracks;
    FormXCDOptions    : TFormXCDOptions;
    FormSettings      : TFormSettings;
    FormOutput        : TFormOutput;
    FormAbout         : TFormAbout;
{$ENDIF}
{$IFDEF AddCDText}
var i: Integer;
    DummyI, TrackCount: Integer;
    DummyE: Extended;
    TextTrackData: TCDTextTrackData;
{$ENDIF}
{$IFDEF ShowCDTextInfo}
var i: Integer;
    DummyC: Int64;
    DummyI, TrackCount: Integer;
    DummyE: Extended;
    TextTrackData: TCDTextTrackData;
{$ENDIF}
begin
  {$IFDEF CreateAllForms}
  FormDataCDOptions  := TFormDataCDOptions.Create(Application);
  FormDataCDFS       := TFormDataCDFS.Create(Application);
  FormDataCDFSError  := TFormDataCDFSError.Create(Application);
  FormAudioCDOptions := TFormAudioCDOptions.Create(Application);
  FormAudioCDTracks  := TFormAudioCDTracks.Create(Application);
  FormXCDOptions     := TFormXCDOptions.Create(Application);
  FormSettings       := TFormSettings.Create(Application);
  FormOutput         := TFormOutput.Create(Application);
  FormAbout          := TFormAbout.Create(Application);
  {$ENDIF}
  {$IFDEF ExportStrings}
  ExportStringProperties;
  FLang.ExportMessageStrings;
  ShowMsgDlg('Strings exportiert.', 'Info', MB_cdrtfeInfo);
  {$ENDIF}
  {$IFDEF ExportControls}
  ExportControls;
  {$ENDIF}
  {$IFDEF ExportFontList}
  ExportFontList;
  {$ENDIF}
  {$IFDEF CreateAllForms}
  FormDataCDOptions.Free;
  FormDataCDFS.Free;
  FormDataCDFSError.Free;
  FormAudioCDOptions.Free;
  FormAudioCDTracks.Free;
  FormXCDOptions.Free;
  FormSettings.Free;
  FormOutput.Free;
  FormAbout.Free;
  {$ENDIF}
  {$IFDEF TestVerify}
  SendMessage(Self.Handle, WM_ButtonsOff, 0, 0);
  FAction.Action := cVerifyISOImage{XCD};
  FAction.StartAction;
  {$ENDIF}
  {$IFDEF AddCDText}
  FData.GetProjectInfo(DummyI, DummyI, DummyI, DummyE, TrackCount, cAudioCD);
  for i := -1 to TrackCount - 1 do
  begin
    with TextTrackData do
    begin
      Title       := 'Title ' + IntToStr(i + 1);
      Performer   := 'Performer ' + IntToStr(i + 1);
      Songwriter  := 'Songwriter ' + IntToStr(i + 1);
      Composer    := 'Composer ' + IntToStr(i + 1);
      Arranger    := 'Arranger ' + IntToStr(i + 1);
      TextMessage := 'TextMessage ' + IntToStr(i + 1);
    end;
    FData.SetCDText(i, TextTrackData);
  end;
  {$ENDIF}
  {$IFDEF ShowCDTextInfo}
  FData.GetProjectInfo(DummyI, DummyI, DummyC, DummyE, TrackCount, cAudioCD);
  for i := -1 to TrackCount - 1 do
  begin
    FData.GetCDText(i, TextTrackData);
    with TextTrackData do
    begin
      Deb('Track ' + IntToStr(i + 1) + ': ', 2);
      Deb('  Title     : ' + Title, 2);
      Deb('  Performer : ' + Performer, 2);
      Deb('  Songwriter: ' +  Songwriter, 2);
      Deb('  Composer  : ' +  Composer, 2);
      Deb('  Arranger  : ' +  Arranger, 2);
      Deb('  Message   : ' +  TextMessage, 2);
    end;
  end;
  {$ENDIF}
  {$IFDEF DebugCreateCDText}
  FData.CreateCDTextFile(ProgDataDir + '\cdtext.dat');
  {$ENDIF}
end;

{ OnKeyDown --------------------------------------------------------------------

  globale Tasten.                                                              }

procedure TCdrtfeMainForm.FormKeyDown(Sender: TObject; var Key: Word;
                             Shift: TShiftState);
begin
  case Key of
    VK_F12: ToggleStayOnTopState;
    VK_F10: if ssCtrl in Shift then begin SetGlobalWriter; Key := 0; end;
  end;
end;

{ HandleKeyboardShortcut -------------------------------------------------------

  nimmt die eigentlich Auswertung der Tastenkombination vor.                   }

procedure TCdrtfeMainForm.HandleKeyboardShortcut(const Key: Word);

  procedure HKSAddFiles;
  begin
    case FSettings.General.Choice of
      cDataCD : begin
                  UserAddFile(CDETreeView);
                  ShowFolderContent(CDETreeView, CDEListView);
                end;
      cXCD    : begin
                  UserAddFile(XCDETreeView);
                  ShowFolderContent(XCDETreeView, XCDEListView1);
                end;
      cAudioCD,
      cVideoCD: UserAddTrack;
    end;
  end;

  procedure HKSAddFolder;
  begin
    case FSettings.General.Choice of
      cDataCD: UserAddFolder(CDETreeView);
      cXCD   : UserAddFolder(XCDETreeView);
    end;
  end;

  procedure HKSDeleteAll;
  begin
    case FSettings.General.Choice of
      cDataCD : CDESpeedButton5Click(nil);
      cXCD    : XCDESpeedButton7Click(nil);
    end;
  end;

  procedure HKSTrackUp;
  begin
    case FSettings.General.Choice of
      cAudioCD : AudioSpeedButton2Click(nil);
      cVideoCD : VideoSpeedButton2Click(nil);
    end;
  end;

  procedure HKSTrackDown;
  begin
    case FSettings.General.Choice of
      cAudioCD : AudioSpeedButton3Click(nil);
      cVideoCD : VideoSpeedButton3Click(nil);
    end;
  end;

  procedure HKSToggleFileExplorer;
  begin
    if MainMenuToggleFileExplorer.Enabled then
      MainMenuToggleFileExplorerClick(nil);
  end;

  procedure HKSToggleLogWindow;
  begin
    MainMenuToggleLogWindowClick(nil);
  end;

  procedure HKSSettings;
  begin
    MainMenuSettingsClick(nil);
  end;

  procedure HKSShowOutputWindow;
  begin
    MainMenuShowOutputWindowClick(nil);
  end;

  procedure HKSSpecialTab;
  begin
    SpecialTab;
  end;

  procedure HKSToggleExplorerLog;
  begin
    if FFileExplorerShowing and not FLogWindowShowing then
    begin
      ToggleFileExplorer(False);
      ToggleLogWindow(True);
    end else
    if not FFileExplorerShowing and FLogWindowShowing then
    begin
      ToggleLogWindow(False);    
      ToggleFileExplorer(True);
    end else
    if not FFileExplorerShowing and not FLogWindowShowing then
    begin
      ToggleLogWindow(True);
    end else
    if FFileExplorerShowing and FLogWindowShowing then
    begin
      ToggleLogWindow(False);
    end;    
  end;

begin
  case Key of
    {VK_E}$45: HKSToggleFileExplorer;
    {VK_I}$49: HKSAddFolder;
    {VK_J}$4A: HKSToggleExplorerLog;
    {VK_K}$4B: HKSToggleLogWindow;
    {VK_L}$4C: HKSShowOutputWindow;
    {VK_O}$4F: HKSAddFiles;
    {VK_Q}$51: HKSSpecialTab;
    {VK_S}$53: HKSSettings;
    {VK_V}$56: begin
                 if FSettings.General.Choice = cXCD then
                 begin FSettings.General.XCDAddMovie := True; HKSAddFiles; end;
               end;
    VK_Delete: HKSDeleteAll;
    VK_UP    : HKSTrackUp;
    VK_DOWN  : HKSTrackDown;
  end;
end;


{ Button-Events -------------------------------------------------------------- }

{ Button 'Start' }

procedure TCdrtfeMainForm.ButtonStartClick(Sender: TObject);
begin
  {$IFDEF ShowExecutionTime}
  TC2.StartTimeCount;
  {$ENDIF}
  SetSettings;
  if InputOk then
  begin
    {Bei Daten-CD nochmals einen Dateisystemchek.}
    if FSettings.General.Choice = cDataCD then CheckDataCDFS(True);
    FAction.Reset;
    {Bei CD-Infos muß das LogWindow angezeigt werden}
    if (FSettings.General.Choice = cCDInfos) and not FLogWindowShowing then
      ToggleLogWindow(True);
    {Aktion ausführen}
    FAction.Action := FSettings.General.Choice;
    FAction.StartAction;
  end;
end;

{ Button 'Beenden' }

procedure TCdrtfeMainForm.ButtonCancelClick(Sender: TObject);
begin
  Self.Close;
  //Application.Terminate;
end;

{ Data-CD: Options file system }

procedure TCdrtfeMainForm.ButtonDataCDOptionsFSClick(Sender: TObject);
var FormDataCDFS: TFormDataCDFS;
begin
  FormDataCDFS := TFormDataCDFS.Create(nil);
  try
    FormDataCDFS.Settings := FSettings;
    FormDataCDFS.Lang := FLang;
    FormDataCDFS.ShowModal;
  finally
    FormDataCDFS.Release;
  end;
  UpdateOptionPanel;
end;

{ Data-CD: Options CD }

procedure TCdrtfeMainForm.ButtonDataCDOptionsClick(Sender: TObject);
var FormDataCDOptions: TFormDataCDOptions;
begin
  FormDataCDOptions := TFormDataCDOptions.Create(nil);
  try
    FormDataCDOptions.Settings := FSettings;
    FormDataCDOptions.Lang := FLang;
    FormDataCDOptions.ShowModal;
  finally
    FormDataCDOptions.Release;
  end;
  UpdateOptionPanel;
end;

{ Audio-CD: Options }

procedure TCdrtfeMainForm.ButtonAudioCDOptionsClick(Sender: TObject);
var FormAudioCDOptions: TFormAudioCDOptions;
begin
  FormAudioCDOptions := TFormAudioCDOptions.Create(nil);
  try
    FormAudioCDOptions.Settings := FSettings;
    FormAudioCDOptions.Lang := FLang;
    FormAudioCDOptions.ShowModal;
  finally
    FormAudioCDOptions.Release;
  end;
  UpdateOptionPanel;
end;

{ Audio-CD: Track Options}

procedure TCdrtfeMainForm.ButtonAudioCDTracksClick(Sender: TObject);
var FormAudioCDTracks: TFormAudioCDTracks;
begin
  FormAudioCDTracks := TFormAudioCDTracks.Create(nil);
  try
    FormAudioCDTracks.Data := FData;
    FormAudioCDTracks.Settings := FSettings;
    FormAudioCDTracks.Lang := FLang;
    FormAudioCDTracks.ShowModal;
  finally
    FormAudioCDTracks.Release;
  end;
end;

{ XCD: Options }

procedure TCdrtfeMainForm.ButtonXCDOptionsClick(Sender: TObject);
var FormXCDOptions: TFormXCDOptions;
begin
  FormXCDOptions := TFormXCDOptions.Create(nil);
  try
    FormXCDOptions.Settings := FSettings;
    FormXCDOptions.Lang := FLang;
    FormXCDOptions.ShowModal;
  finally
    FormXCDOptions.Release;
  end;
  UpdateOptionPanel;
end;

{ DAE: Select path }

procedure TCdrtfeMainForm.ButtonDAESelectPathClick(Sender: TObject);
var Dir: string;
begin
  Dir := ChooseDir(Flang.GMS('g002'), GetCachedFolderName(DIDDAEFolder),
                   Self.Handle);
  if Dir <> '' then
  begin
    EditDAEPath.Text := Dir;
    CacheFolderName(DIDDAEFolder, Dir);
  end;
end;

{ DAE: Read TOC }

procedure TCdrtfeMainForm.ButtonDAEReadTocClick(Sender: TObject);
begin
  SetSettings;
  FAction.Action := cDAEReadTOC;
  FAction.StartAction;
  ShowTracksDAE;
end;

{ DAE: Options }

procedure TCdrtfeMainForm.ButtonDAEOptionsClick(Sender: TObject);
var FormDAEOptions: TFormDAEOptions;
begin
  FormDAEOptions := TFormDAEOptions.Create(nil);
  try
    FormDAEOptions.Settings := FSettings;
    FormDAEOptions.Lang := FLang;
    FormDAEOptions.ShowModal;
  finally
    FormDAEOptions.Release;
  end;
  UpdateOptionPanel;
end;

{ Image: Select path }

procedure TCdrtfeMainForm.ButtonReadCDSelectPathClick(Sender: TObject);
var DialogID: TDialogID;
begin
  DialogID := DIDSaveImage;
  SaveDialog1 := TSaveDialog.Create(Self);
  SaveDialog1.Title := FLang.GMS('m102');
  SaveDialog1.DefaultExt := 'iso';
  SaveDialog1.Filter := FLang.GMS('f002');
  SaveDialog1.Options := [ofOverwritePrompt,ofHideReadOnly];
  SaveDialog1.InitialDir := GetCachedFolderName(DialogID);
  if SaveDialog1.Execute then
  begin
    EditReadCDIsoPath.Text := SaveDialog1.FileName;
    CacheFolderName(DialogID, SaveDialog1.FileName);
  end;
  SaveDialog1.Free;
end;

{ Image: Select ISO-/CUE-Image }

procedure TCdrtfeMainForm.ButtonImageSelectPathClick(Sender: TObject);
var DialogID: TDialogID;
begin
  DialogID := DIDCDImage;
  OpenDialog1 := TOpenDialog.Create(Self);
  OpenDialog1.Title := FLang.GMS('m101');
  OpenDialog1.InitialDir := GetCachedFolderName(DialogID);
  if (FSettings.FileFlags.CdrdaoOk or FSettings.Cdrecord.CanWriteCueImage) then
  begin
    OpenDialog1.Filter := FLang.GMS('f001');
  end else
  begin
    OpenDialog1.Filter := FLang.GMS('f002');
  end;
  if OpenDialog1.Execute then
  begin
    EditImageIsoPath.Text := (OpenDialog1.Files[0]);
    CacheFolderName(DialogID, OpenDialog1.FileName);
  end;
  OpenDialog1.Free;
  CheckControls;
end;

{ DVD Video: Select source dir }

procedure TCdrtfeMainForm.ButtonDVDVideoSelectPathClick(Sender: TObject);
var Dir: string;
begin
  Dir := ChooseDir(Flang.GMS('g002'), GetCachedFolderName(DIDVideoDVDFolder),
                   Self.Handle);
  if Dir <> '' then
  begin
    if IsValidDVDSource(Dir) then                  // temporary Hack
      EditDVDVideoSourcePath.Text := Dir;
    CacheFolderName(DIDVideoDVDFolder, Dir);
  end;
end;

{ DVD Video: Options }

procedure TCdrtfeMainForm.ButtonDVDVideoOptionsClick(Sender: TObject);
var FormDataCDOptions: TFormDataCDOptions;
begin
  FormDataCDOptions := TFormDataCDOptions.Create(nil);
  try
    FormDataCDOptions.Settings := FSettings;
    FormDataCDOptions.Lang := FLang;
    FormDataCDOptions.DVDOptions := True;
    FormDataCDOptions.ShowModal;
  finally
    FormDataCDOptions.Release;
  end;
end;

{ Video CD: Options }

procedure TCdrtfeMainForm.ButtonVideoCDOptionsClick(Sender: TObject);
var FormVideoCDOptions: TFormVideoCDOptions;
begin
  FormVideoCDOptions := TFormVideoCDOptions.Create(nil);
  try
    FormVideoCDOptions.Settings := FSettings;
    FormVideoCDOptions.Lang := FLang;
    FormVideoCDOptions.ShowModal;
  finally
    FormVideoCDOptions.Release;
  end;
  UpdateOptionPanel;
end;

{ cdrtfe Settings }

procedure TCdrtfeMainForm.ButtonSettingsClick(Sender: TObject);
begin
  MainMenuSettingsClick(nil);
end;

{ Abort action }

procedure TCdrtfeMainForm.ButtonAbortClick(Sender: TObject);
begin
  FAction.AbortAction;
end;


{ Menu-Events ---------------------------------------------------------------- }

{ Datei/Schließen }

procedure TCdrtfeMainForm.MainMenuCloseClick(Sender: TObject);
begin
  Self.Close; //Application.Terminate;
end;

{ Projekt/Projekt laden }

procedure TCdrtfeMainForm.MainMenuLoadProjectClick(Sender: TObject);
begin
  LoadProject(False);
end;

{ Projekt/Projekt speichern }

procedure TCdrtfeMainForm.MainMenuSaveProjectClick(Sender: TObject);
begin
  SaveProject(False);
end;

{ Projekt/Dateiliste laden }

procedure TCdrtfeMainForm.MainMenuLoadFileListClick(Sender: TObject);
begin
  LoadProject(True);
end;

{ Projekt/Dateiliste speichern }

procedure TCdrtfeMainForm.MainMenuSaveFileListClick(Sender: TObject);
begin
  SaveProject(True);
end;

{ Pojekt/Standardeinstellungen }

procedure TCdrtfeMainForm.MainMenuReloadDefaultsClick(Sender: TObject);
var Temp: Byte;
begin
  Temp := FSettings.General.Choice;
  {Einstellungen laden: Ini}
  FSettings.LoadFromFile(cIniFile);
  {Einstellungen in GUI übernehmen}
  GetSettings;
  FSettings.General.Choice := Temp;
  CheckControls;
  UpdateOptionPanel;
end;

{ Projekt/Reset cdrtfe }

procedure TCdrtfeMainForm.MainMenuResetClick(Sender: TObject);
var i   : Integer;
    Tree: TTreeView;
    List: TListView;
begin
  Tree := nil;
  List := nil;
  {Settings zurücksetzen}
  MainMenuReloadDefaultsClick(Sender);
  {Projectdaten löschen}
  for i := cDataCD to cDVDVideo do
  begin
    case i of
      cDataCD,
      cXCD    : begin
                  case i of
                    cDataCD: begin
                               Tree := CDETreeView;
                               List := CDEListView;
                             end;
                    cXCD   : begin
                               Tree := XCDETreeView;
                               List := XCDEListView1;
                             end;
                  end;
                  Tree.Selected := Tree.Items[0];
                  FData.DeleteAll(i);
                  InitTreeView(Tree, i);
                  SelectRootIfNoneSelected(Tree);
                  ShowFolderContent(Tree, List);
                end;
      cAudioCD,
      cVideoCD: begin
                  case i of
                    cAudioCD: List := AudioListView;
                    cVideoCD: List := VideoListView;
                  end;
                  FData.DeleteAll(i);
                  List.Items.Clear;
                end;
    end;
  end;
  UpdateGauges;
end;

{ Aktionen/Start }

procedure TCdrtfeMainForm.MainMenuStartClick(Sender: TObject);
begin
  ButtonStartClick(nil);
end;

{ Aktionen/Abbrechen }

procedure TCdrtfeMainForm.MainMenuAbortClick(Sender: TObject);
begin
  FAction.AbortAction;
end;

{ Aktionen/Fixieren }

procedure TCdrtfeMainForm.MainMenuFixateClick(Sender: TObject);
begin
  SpeedButtonFixCDClick(nil);
end;

{ Aktionen/schnelles Löschen }

procedure TCdrtfeMainForm.MainMenuEraseFastClick(Sender: TObject);
begin
  DoMenuEraseDisk(True);
end;

{ Aktionen/komplettes Löschen }

procedure TCdrtfeMainForm.MainMenuEraseFullClick(Sender: TObject);
begin
  DoMenuEraseDisk(False);
end;


procedure TCdrtfeMainForm.MainMenuShowInfoClick(Sender: TObject);
begin
  DoMenuShowInfo((Sender as TMenuItem).Tag);
end;

{ Ansicht/Dateiexplorer }

procedure TCdrtfeMainForm.MainMenuToggleFileExplorerClick(Sender: TObject);
begin
  if FFileExplorerShowing then
  begin
    ToggleFileExplorer(False);
  end else
  begin
    ToggleFileExplorer(True);
  end;
end;

{ Ansicht/Ausgabefenster }

procedure TCdrtfeMainForm.MainMenuToggleLogWindowClick(Sender: TObject);
begin
  if FLogWindowShowing then
  begin
    ToggleLogWindow(False);
  end else
  begin
    ToggleLogWindow(True);
  end;
end;

procedure TCdrtfeMainForm.MainMenuShowOutputWindowClick(Sender: TObject);
begin
  if FOutputWindowShowing then
  begin
    ToggleOutputWindow(False);
  end else
  begin
    ToggleOutputWindow(True);
  end;
end;

{ Extras/Sprache ändern }

procedure TCdrtfeMainForm.MainMenuSetLangClick(Sender: TObject);
begin
  FLang.SelectLanguage;
end;

{ Extras/Einstellungen }

procedure TCdrtfeMainForm.MainMenuSettingsClick(Sender: TObject);
var FormSettings: TFormSettings;
begin
  SetSettings;
  SaveWinPos;
  FormSettings := TFormSettings.Create(nil);
  try
    FormSettings.Settings := FSettings;
    FormSettings.Lang := FLang;
    FormSettings.FormHandle := Self.Handle;
    FormSettings.OnMessageShow := Self.MessageShow;
    FormSettings.ShowModal;
  finally
    FormSettings.Release;
  end;
  GetSettings;
end;

{ Extras/cdrtfe.ini }

procedure TCdrtfeMainForm.MainMenuCdrtfeIniClick(Sender: TObject);
begin
  if FileExists(FSettings.General.IniFile) then
    ShlExecute('', FSettings.General.IniFile);
end;

{ ?/Info }

procedure TCdrtfeMainForm.MainMenuHelpClick(Sender: TObject);
begin
  Application.HelpContext(1000);
end;

procedure TCdrtfeMainForm.MainMenuAboutClick(Sender: TObject);
var AboutBox: TFormAbout;
begin
  AboutBox := TFormAbout.Create(nil);
  try
    AboutBox.Lang := Flang;
    AboutBox.Portable := FSettings.General.PortableMode;
    AboutBox.ShowModal;
  finally
    AboutBox.Release;
  end;
end;

{ Hilfsfunktionen für Menü-Events -------------------------------------------- }

{ DoMenuErase ------------------------------------------------------------------

  setzt Einstellungen für das Löschen von Disks, wenn die Aktion aus dem Haupt-
  mneü heraus aufgerufen wurde.                                                }

procedure TCdrtfeMainForm.DoMenuEraseDisk(const FastErase: Boolean);
begin
  SetSettings;
  FSettings.CDRW.Device := FDevices.CDWriter.Values[
                             FDevices.CDWriter.Names[
                               FSettings.General.TabSheetDrive[
                                 FSettings.General.Choice]]];
  FSettings.CDRW.Fast         := FastErase;
  FSettings.CDRW.All          := not FastErase;
  FSettings.CDRW.OpenSession  := False;
  FSettings.CDRW.BlankSession := False;
  FAction.Action := cCDRW;
  FAction.StartAction;
end;

{ DoMenuShowInfo ---------------------------------------------------------------

  setzt die Einstellungen für das Anzeigen der Geräte-/Diskinfos.              }

procedure TCdrtfeMainForm.DoMenuShowInfo(const ID: Integer);
begin
  SetSettings;
  FSettings.CDInfo.Device := FDevices.CDWriter.Values[
                               FDevices.CDWriter.Names[
                                 FSettings.General.TabSheetDrive[
                                   FSettings.General.Choice]]];
  with FSettings.CDInfo do
  begin
    Scanbus  := False;
    Prcap    := False;
    Toc      := False;
    Atip     := False;
    MSInfo   := False;
    MInfo    := False;
    CapInfo  := False;
    MetaInfo := False;
    case ID of
      0: Scanbus  := True;
      1: Prcap    := True;
      2: Toc      := True;
      3: Atip     := True;
      4: MsInfo   := True;
      5: MInfo    := True;
      6: CapInfo  := True;
      7: MetaInfo := True;
    end;
  end;
  FAction.Action := cCDInfos;
  FAction.StartAction;
  if not FLogWindowShowing then ToggleLogWindow(True);  
end;


{ PageControl-Events --------------------------------------------------------- }

{ PageControl1Change -----------------------------------------------------------

  Bei jedem Wechsel der aktiven Registerkarte müssen die Controls entsprechend
  (de-)aktiviert werden. Außerdem muß Choice aktualisiert werden.              }

procedure TCdrtfeMainForm.PageControl1Change(Sender: TObject);
begin
  FSettings.General.Choice := GetActivePage;
  CheckControls;
  UpdateGauges;
  UpdateOptionPanel;
  SetFileBrowserParent;
  {Workaround for odd RadioButton behaviour}
  if FImageTabFirstShow and Self.Active and
     (PageControl1.ActivePage = TabSheet7) then
  begin
    ImageTabInitRadioButtons;
  end;
end;


{ TreeView-Events --------------------------------------------------------------

  Die TreeView-Events gelten sowohl für CDETreeView als auch für XCDETreeView. }

{ TreeView: OnChange -----------------------------------------------------------

  OnChange: der selektierte Knoten hat sich geändert. Die mit dem Knoten
  verknüpfte Pfadliste wird im ListView angezeigt. Vorher werden noch die
  Dateilisten des alten Knotens neu sortiert, sofern dort Dateien umbenannt
  wurden. Ebenso wird falls nötig der TreeView neu sortiert.                   }

procedure TCdrtfeMainForm.TreeViewChange(Sender: TObject; Node: TTreeNode);
begin
  UserSort(False);
  if (Sender as TTreeView) = CDETreeView then
  begin
    ShowFolderContent(CDETreeView, CDEListView);
  end else
  if (Sender as TTreeView) = XCDETreeView then
  begin
    ShowFolderContent(XCDETreeView, XCDEListView1);
  end;
end;

{ TreeView: OnExpanding --------------------------------------------------------

  TreeViewExpanding wird ausgeführt, wenn ein Knoten des Tree-Views expandiert
  wird. Dieses Event wird dazu benutzt, um die Knoten mit den korrekten Icons
  zu versehen. Immer, wenn ein Knoten expandiert wird, erhalten die direkt
  untergeordneten Knoten die Icon-Indizes.                                     }

procedure TCdrtfeMainForm.TreeViewExpanding(Sender: TObject; Node: TTreeNode;
                                   var AllowExpansion: Boolean);
var TempNode: TTreeNode;
begin
  TempNode := Node.GetFirstChild;
  while TempNode <> nil do
  begin
    with FImageLists do
    begin
      {zu langsam:
      if TempNode.AbsoluteIndex = 0 then }
      {überflüssig, da der Wurzelknoten hier nie als Child erreicht werden kann
      if TempNode = (Sender as TTreeView).Items[0] then
      begin
        TempNode.ImageIndex := IconCD;
        TempNode.SelectedIndex := IconCD;
      end else }
      begin
        TempNode.ImageIndex := IconFolder;
        TempNode.SelectedIndex := IconFolderSelected;
      end;
    end;
    TempNode := Node.GetNextChild(TempNode);
  end;
end;

{ TreeView: OnMouseDown---------------------------------------------------------

  OnMouseDown sorgt dafür, daß auch bei einem Rechtsklick das Item selektiert
  wird.                                                                        }

procedure TCdrtfeMainForm.TreeViewMouseDown(Sender: TObject; Button: TMouseButton;
                                   Shift: TShiftState; X, Y: Integer);
var Node: TTreeNode;
begin
  if Button = mbRight then
  begin
    Node := (Sender as TTreeView).GetNodeAt(x, y);
    if Node <> nil then
    begin
      (Sender as TTreeView).Selected := Node;
    end;
  end;
end;

{ TreeView: OnDragOver ---------------------------------------------------------

  Ein Objekt wird auf den Tree-View gezogen. Drop nur zulassen, wenn es aus
  dem Tree-View selbst oder aus einem List-View stammt.                        }

procedure TCdrtfeMainForm.TreeViewDragOver(Sender, Source: TObject; X, Y: Integer;
                                  State: TDragState; var Accept: Boolean);
var Tree     : TTreeView;
    Node     : TTreeNode;
    DoRepaint: Boolean;
begin
  DoRepaint := False;
  Tree := (Sender as TTreeView);
  if (Source is TTreeView) or (Source is TListView) or
     (Source is TShellTreeView) or (Source is TShellListView) then
  begin
    Accept := True;
    {da THETreeView nicht mehr benutzt wird, muß hier gescrollt werden}
    if (Y > Tree.Height - 20) and (Y < Tree.Height) then
    begin
      PostMessage(Tree.Handle, WM_VSCROLL, MakeLong(SB_LINEDOWN, 0), 0);
      DoRepaint := True;
    end;
    if (Y < 20) and (Tree.TopItem <> Tree.Items[0]) then
    begin
      PostMessage(Tree.Handle, WM_VSCROLL, MakeLong(SB_LINEUP, 0), 0);
      DoRepaint := True;
    end;
    {automatisches Expandieren}
    Node := Tree.GetNodeAt(X, Y);
    if Node <> nil then
      if Node.HasChildren and not Node.Expanded and (State = dsDragMove) then
      begin
        ExpandNodeDelayed(Node, False);
      end;
  end else
  begin
    Accept := False;
  end;
  if DoRepaint then Tree.Repaint;
end;

{ TreeView: OnDragDrop ---------------------------------------------------------

  Ein Objekt wird auf den Tree-View fallengelassen.                            }

procedure TCdrtfeMainForm.TreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
var SourceNode: TTreeNode;
    DestNode: TTreeNode;
begin
  DestNode := nil;
  SourceNode := nil;
  case FSettings.General.Choice of
    cDataCD: begin
               DestNode := CDETreeView.GetNodeAt(X, Y);
               SourceNode := CDETreeView.Selected;
             end;
    cXCD   : begin
               DestNode := XCDETreeView.GetNodeAt(X, Y);
               SourceNode := XCDETreeView.Selected;
             end;
  end;
  {Datei: ListView -> TreeView}
  if Source is TListView then
  begin
    if (DestNode <> nil) and (DestNode <> SourceNode) then
    begin
      UserMoveFile(SourceNode, DestNode, TListView(Source));
    end;
  end;
  {Ordner: TreeView -> TreeView}
  if Source is TTreeView then
  begin
    if (DestNode <> nil) and (DestNode <> SourceNode) then
    begin
      UserMoveFolder(SourceNode, DestNode);
    end;
  end;
  {FileExplorer -> TreeView}
  if (Source is TShellTreeView) or (Source is TShellListView) then
  begin
    if DestNode <> nil then DestNode.Selected := True;
    CDEListViewDragDrop(Sender, Source, 0 ,0);
  end;
end;

{ TreeView: OnKeyDown ----------------------------------------------------------

  Tastatur-Events.                                                             }

procedure TCdrtfeMainForm.TreeViewKeyDown(Sender: TObject; var Key: Word;
                                 Shift: TShiftState);
var Tree: TTreeView;
begin
  Tree := Sender as TTreeView;
  case Key of
    VK_DELETE: if not Tree.IsEditing and (Tree.Selected <> Tree.Items[0]) then
               begin
                 UserDeleteFolder(Tree);
               end;
    VK_F2    : UserRenameFolderByKey(Tree);
    VK_F5    : UserSort(True);
    Ord('V') : if Shift = [ssCtrl] then
               begin
                 AddFromClipboard;
               end;
  end;
end;

{ TreeView: OnEdited -----------------------------------------------------------

  Der Text eines Knotens wurde geändert. Wenn es sich nicht um die Wurzel des
  Tree-Views handelte, müssen alle Knoten auf gleicher Ebene sortiert
  werden.                                                                      }

procedure TCdrtfeMainForm.TreeViewEdited(Sender: TObject; Node: TTreeNode;
                                         var S: String);
var Temp: string;
    Path: string;
    ErrorCode: Byte;
begin
  if Node.Parent <> nil then {Folder}
  begin
    Path := GetPathFromNode(Node);
    FData.RenameFolder(Path, S, FSettings.DataCD.GetMaxFileNameLength,
                       FSettings.General.Choice);
    ErrorCode := FData.LastError;
    if ErrorCode = PD_NoError then
    begin
      {Änderungen im GUI nachvollziehen}
      Node.Text := S;
      {Flags für die spätere Sortierng (onChange oder F5) setzen}
      with FData do
      begin
        case FSettings.General.Choice of
          cDataCD: begin
                     DataCDFoldersToSort := True;
                     DataCDFoldersToSortParent := GetPathFromNode(Node.Parent);
                   end;
          cXCD   : begin
                     XCDFoldersToSort := True;
                     XCDFoldersToSortParent := GetPathFromNode(Node.Parent);
                   end;
        end;
      end;
    end else
    begin
      Temp := S;
      S := Node.Text;
      Node.Text := S;
      if ErrorCode = PD_FolderNotUnique then
      begin
        {Fehlermeldung nur ausgeben, wenn der neue Name sich wirklich vom
         alten unterscheidet.}
        if Temp <> Node.Text then
        begin
          ShowMsgDlg(Format(FLang.GMS('e111'), [Temp]), FLang.GMS('g001'),
                     MB_cdrtfeError);
        end;
      end else
      if ErrorCode = PD_InvalidName then
      begin
        ShowMsgDlg(FLang.GMS('e110'), FLang.GMS('g001'), MB_cdrtfeError);
      end else
      if ErrorCode = PD_NameTooLong then
      begin
        ShowMsgDlg(FLang.GMS('e501'), FLang.GMS('g001'), MB_cdrtfeError);
      end else
      if ErrorCode = PD_PreviousSession then
      begin
        ShowMsgDlg(FLang.GMS('e117'), FLang.GMS('g001'), MB_cdrtfeError);
      end;
    end;
  end else {CD-Label}
  begin
    FData.SetCDLabel(S, FSettings.General.Choice);
    {Fehlerbehandlung}
    ErrorCode := FData.LastError;
    if ErrorCode = PD_NoError then
    begin
      {Änderung im GUI nachvollziehen}
      Node.Text := S;
    end else
    begin
      if Length(S) > 32 then
      begin
        S := Copy(S, 1, 32);
        Node.Text := S;
        ShowMsgDlg(Format(FLang.GMS('m502'), [32]),
                   FLang.GMS('g004'), MB_cdrtfeWarning);
      end;
      if Length(S) = 0 then
      begin
        Temp := S;
        S := Node.Text;
        Node.Text := S;
      end;
    end;
  end;
end;


{ ListView-Events ------------------------------------------------------------ }

{ ListView: DoubleClick --------------------------------------------------------

  Maus-Event: Doppelklick öffnet Track.                                        }

procedure TCdrtfeMainForm.ListViewDblClick(Sender: TObject);
begin
  if FSettings.General.AllowDblClick or
     ItemIsFolder((Sender as TListView).Selected) then
    UserOpenFile(GetCurrentListView(Sender));
end;

{ ListView: OnKeyDown ----------------------------------------------------------

  Tastatur-Events.                                                             }

procedure TCdrtfeMainForm.ListViewKeyDown(Sender: TObject; var Key: Word;
                                 Shift: TShiftState);
var List: TListView;
    Tree: TTreeView;
begin
  List := Sender as TListView;
  case Key of
    VK_DELETE : if not List.IsEditing then
                begin
                  case FSettings.General.Choice of
                    cDataCD: UserDeleteFile(CDETreeView, CDEListView);
                    cXCD   : UserDeleteFile(XCDETreeView, List);
                  end;
                end;
    VK_BACK   : if not List.IsEditing then
                begin
                  Tree := GetCurrentTreeView;
                  if Tree.Selected.Parent <> nil then
                    Tree.Selected.Parent.Selected := True;
                end;
    VK_RETURN : ListViewDblCLick(Sender);
    Ord('A')  : if Shift = [ssCtrl] then
                begin
                  ListViewSelectAll(List);
                end;
    Ord('V')  : if Shift = [ssCtrl] then
                begin
                  AddFromClipboard;
                end;                
    VK_F2     : if FSettings.General.Choice = cDataCD then
                begin
                  {nur bei Daten-CDs dürfen Dateien umbenannt werden}
                  UserRenameFile(CDEListView);
                end;
    VK_F5     : UserSort(True);
   end;
end;

{ ListView: OnEdited -----------------------------------------------------------

  Ein Dateiname wurde geändert.                                                }

procedure TCdrtfeMainForm.ListViewEdited(Sender: TObject; Item: TListItem;
                                var S: String);
var Temp     : string;
    Path     : string;
    Offset   : Integer;
    Node     : TTreeNode;
    ErrorCode: Byte;
begin
  Offset := (Sender as TListView).Tag;
  {File or folder entry?}
  if not ItemIsFolder(Item) then
  begin
    Path := GetPathFromNode(CDETreeView.Selected);
    FData.RenameFileByIndex(Item.Index - Offset, Path, S,
                            FSettings.DataCD.GetMaxFileNameLength,
                            FSettings.General.Choice);
    ErrorCode := FData.LastError;
    if ErrorCode = PD_NoError then
    begin
      {Änderungen im GUI nachvollziehen}
      Item.Caption := S;
      {Flags für die spätere Sortierng (onChange oder F5) setzen}
      with FData do
      begin
        case FSettings.General.Choice of
          cDataCD: begin
                     DataCDFilesToSort := True;
                     DataCDFilesToSortFolder := Path;
                   end;
          cXCD   : ;
        end;
      end;
    end else
    begin
      Temp := S;
      S := Item.Caption;
      Item.Caption := S;
      if ErrorCode = PD_FileNotUnique then
      begin
        {Fehlermeldung nur ausgeben, wenn der neue Name sich wirklich vom
         alten unterscheidet.}
        if Temp <> Item.Caption then
        begin
          ShowMsgDlg(Format(FLang.GMS('e112'), [Temp]), FLang.GMS('g001'),
                     MB_cdrtfeError);
        end;
      end else
      if ErrorCode = PD_InvalidName then
      begin
        ShowMsgDlg(FLang.GMS('e110'), FLang.GMS('g001'), MB_cdrtfeError);
      end else
      if ErrorCode = PD_NameTooLong then
      begin
        ShowMsgDlg(FLang.GMS('e501'), FLang.GMS('g001'), MB_cdrtfeError);
      end else
      if ErrorCode = PD_PreviousSession then
      begin
        ShowMsgDlg(FLang.GMS('e117'), FLang.GMS('g001'), MB_cdrtfeError);
      end;
    end;
  end else
  begin
    Path := GetPathFromNode(CDETreeView.Selected) + Item.Caption + '/';
    Node := GetNodeFromPath(CDETreeView.Items[0], Path);
    TreeViewEdited(CDETreeView, Node, S);
  end;
end;

{ ListViewDragDrop -------------------------------------------------------------

  entgegenmehmen von Dateien und Ordnern vom FileExplorer.                     }

procedure TCdrtfeMainForm.CDEListViewDragDrop(Sender, Source: TObject; X, Y: Integer);
var Tree       : TShellTreeView;
    List       : TShellListView;
    Folder     : TShellFolder;
    FileName   : string;
    i          : Integer;
    FolderAdded: Boolean;
begin
  if (Source is TShellTreeView) then
  begin
    Tree := Source as TShellTreeView;
    Folder := Tree.SelectedFolder;
    AddToPathlist(Folder.PathName);
    AddToPathListSort(True);
  end else
  if (Source is TShellListView) then
  begin
    FolderAdded := False;
    List := Source as TShellListView;
    for i := 0 to List.Items.Count - 1 do
    begin
      if List.Items[i].Selected then
      begin
        FileName := List.Folders[i].PathName;
        AddToPathlist(FileName);
        {Flag setzen, wenn Order hinzugefügt wurde}
        if not FolderAdded then
        begin
          if DirectoryExists(FileName) then FolderAdded := True;
        end;
      end;
    end;
    AddToPathListSort(FolderAdded);
  end;
end;

{ ListViewDragOver -------------------------------------------------------------

  entgegenmehmen von Dateien und Ordnern vom FileExplorer.                     }

procedure TCdrtfeMainForm.CDEListViewDragOver(Sender, Source: TObject; X, Y: Integer;
                                     State: TDragState; var Accept: Boolean);
begin
  Accept := (Source is TShellListView) or (Source is TShellTreeView);
end;

{ XCDEListView1: OnDragDrop ----------------------------------------------------

  verschieben von Dateien von Datei-List zur Movie-Liste und umgekehrt. Gilt nur
  für XCD.                                                                     }

procedure TCdrtfeMainForm.XCDEListView1DragDrop(Sender, Source: TObject; X, Y: Integer);
var Path: string;
    i: Integer;
begin
  Path := GetPathFromNode(XCDETreeView.Selected);
  if (Source is TShellListView) or (Source is TShellTreeView) then
  begin
    CDEListViewDragDrop(Sender, Source, X, Y);
  end else
  if {Form1 -> Form2}
     ((Source as TListView) = XCDEListView1) and
     ((Sender as TListView) = XCDEListView2) or
     {Form2 -> Form1}
     ((Source as TListView) = XCDEListView2) and
     ((Sender as TListView) = XCDEListView1) then
  begin
    for i := (Source as TListView).Items.Count - 1 downto 0 do
    begin
      if (Source as TListView).Items[i].Selected and
         not (ItemIsFolder((Source as TListView).Items[i])) then
      begin
        FData.ChangeForm2Status((Source as TListView).Items[i].Caption, Path);
      end;
    end;
    FData.SortFileList(Path, cXCD);
    ShowFolderContent(XCDETreeView, XCDEListView1);
  end;
end;

{ XCDEListView1: OnDragOver ----------------------------------------------------

  es sollen nur Dateien akzeptiert werden. Keine Ordner. Nur XCD.              }

procedure TCdrtfeMainForm.XCDEListView1DragOver(Sender, Source: TObject; X, Y: Integer;
                                       State: TDragState; var Accept: Boolean);
begin
  Accept := (Source is TShellListView) or (Source is TShellTreeView) or
            (Source is TListView);
end;

{ XCDEListView1: OnEditing -----------------------------------------------------

  Der Mode2CDMaker unterstütz zur Zeit die Änderung vo Dateinamen nicht. Daher
  dürfen die Dateinamen nicht geändert werden.                                 }

procedure TCdrtfeMainForm.XCDEListView1Editing(Sender: TObject; Item: TListItem;
                                      var AllowEdit: Boolean);
begin
  AllowEdit := False;
end;

{ AudioListView: OnEditing -----------------------------------------------------

  Bei Audio-CD spielt der Dateiname keine Rolle, also kein Editieren.          }

procedure TCdrtfeMainForm.AudioListViewEditing(Sender: TObject; Item: TListItem;
                                      var AllowEdit: Boolean);
begin
  AllowEdit := False;
end;

{ AudioListView: KeyDown -------------------------------------------------------

  Tastatur-Events: Hinzufügen, Löschen und Bewegen von Tracks.                 }

procedure TCdrtfeMainForm.AudioListViewKeyDown(Sender: TObject; var Key: Word;
                                      Shift: TShiftState);
begin
  case Key of
    VK_DELETE  : if not AudioListView.IsEditing then
                 begin
                   UserDeleteFile(nil, AudioListView);
                 end;
    Ord('A')   : if Shift = [ssCtrl] then
                 begin
                   ListViewSelectAll(AudioListView);
                 end;
    Ord('V')   : if Shift = [ssCtrl] then
                 begin
                   AddFromClipboard;
                 end;                 
    VK_ADD     : UserMoveTrack(AudioListView, dDown);
    VK_SUBTRACT: UserMoveTrack(AudioListView, dUp);
    VK_RETURN  : ListViewDblCLick(Sender);
  end;
end;

{ DAEListView: OnEditing -------------------------------------------------------

  Bei Audio-CD spielt der Dateiname keine Rolle, also kein Editieren.          }

procedure TCdrtfeMainForm.DAEListViewEditing(Sender: TObject; Item: TListItem;
                                    var AllowEdit: Boolean);
begin
  AllowEdit := False;
end;

{ DAEListView: KeyDown ---------------------------------------------------------

  Tastatur-Events: Alle Tracks markieren.                                      }

procedure TCdrtfeMainForm.DAEListViewKeyDown(Sender: TObject; var Key: Word;
                                    Shift: TShiftState);
begin
  case Key of
    Ord('A')   : if Shift = [ssCtrl] then
                 begin
                   ListViewSelectAll(DAEListView);
                 end;
  end;
end;

{ VideoListView: OnEditing -----------------------------------------------------

  Bei Video-CD spielt der Dateiname keine Rolle, also kein Editieren.          }

procedure TCdrtfeMainForm.VideoListViewEditing(Sender: TObject; Item: TListItem;
                                      var AllowEdit: Boolean);
begin
  AllowEdit := False;
end;

{ VideoListView: OnKeyDown -----------------------------------------------------

  Tastatur-Events: Löschen und Bewegen von Tracks.                             }

procedure TCdrtfeMainForm.VideoListViewKeyDown(Sender: TObject; var Key: Word;
                                      Shift: TShiftState);
begin
  case Key of
    VK_DELETE  : if not VideoListView.IsEditing then
                 begin
                   UserDeleteFile(nil, VideoListView);
                 end;
    Ord('A')   : if Shift = [ssCtrl] then
                 begin
                   ListViewSelectAll(VideoListView);
                 end;
    Ord('V')   : if Shift = [ssCtrl] then
                 begin
                   AddFromClipboard;
                 end;                                  
    VK_ADD     : UserMoveTrack(VideoListView, dDown);
    VK_SUBTRACT: UserMoveTrack(VideoListView, dUp);
    VK_RETURN  : ListViewDblCLick(Sender);
  end;
end;


{ SpeedButton-Events --------------------------------------------------------- }

{ Data-CD: Add file }

procedure TCdrtfeMainForm.CDESpeedButton1Click(Sender: TObject);
begin
  UserAddFile(CDETreeView);
  ShowFolderContent(CDETreeView, CDEListView);
end;

{ Data-CD: Add folder }

procedure TCdrtfeMainForm.CDESpeedButton2Click(Sender: TObject);
begin
  UserAddFolder(CDETreeView);
end;

{ Data-CD: Delete file }

procedure TCdrtfeMainForm.CDESpeedButton3Click(Sender: TObject);
begin
  UserDeleteFile(CDETreeView, CDEListView);
end;

{ Data-CD: Delete folder }

procedure TCdrtfeMainForm.CDESpeedButton4Click(Sender: TObject);
begin
  UserDeleteFolder(CDETreeView);
end;

{ Data-CD: Delete all }

procedure TCdrtfeMainForm.CDESpeedButton5Click(Sender: TObject);
begin
  UserDeleteAll(CDETreeView);
  {mit einem neuen Projekt sollen auch die alten Ausnahmen gelöscht werden}
  FData.IgnoreNameLengthErrors := False;
  FData.ErrorListIgnore.Clear;
  FSettings.DataCD.MsInfo := '';  
end;

{ Data-CD: Check filesystem }

procedure TCdrtfeMainForm.Sheet1SpeedButtonCheckFSClick(Sender: TObject);
var Node: TTreeNode;
    Path: string;
begin
  FData.IgnoreNameLengthErrors := False;
  FData.ErrorListIgnore.Clear;
  {aktuellen Knoten merken, Wurzel selektieren}
  Path := GetPathFromNode(CDETreeView.Selected);
  CDETreeView.Selected := CDETreeView.Items[0];
  {gesamtes Dateisystem prüfen}
  CheckDataCDFS(True);
  {alten Knoten wieder selektieren}
  Node := GetNodeFromPath(CDETreeView.Items[0], Path);
  if Node <> nil then
  begin
    CDETreeView.Selected := Node;
    Node.Expand(False);
  end else
  begin
    CDETreeView.Selected := CDETreeView.Items[0];
  end;
  ShowFolderContent(CDETreeView, CDEListView);
end;

{ XCD: Add file}

procedure TCdrtfeMainForm.XCDESpeedButton1Click(Sender: TObject);
begin
  UserAddFile(XCDETreeView);
  ShowFolderContent(XCDETreeView, XCDEListView1);
end;

{ XCD: Add folder}

procedure TCdrtfeMainForm.XCDESpeedButton2Click(Sender: TObject);
begin
  UserAddFolder(XCDETreeView);
end;

{ XCD: Delete file }

procedure TCdrtfeMainForm.XCDESpeedButton3Click(Sender: TObject);
begin
  UserDeleteFile(XCDETreeView, XCDEListView1);
end;

{ XCD: Add movie }

procedure TCdrtfeMainForm.XCDESpeedButton4Click(Sender: TObject);
begin
  FSettings.General.XCDAddMovie := True;
  UserAddFile(XCDETreeView);
  ShowFolderContent(XCDETreeView, XCDEListView1);
end;

{ XCD: Delete movie }

procedure TCdrtfeMainForm.XCDESpeedButton5Click(Sender: TObject);
begin
  UserDeleteFile(XCDETreeView, XCDEListView2);
end;

{ XCD: Delete folder }

procedure TCdrtfeMainForm.XCDESpeedButton6Click(Sender: TObject);
begin
  UserDeleteFolder(XCDETreeView);
end;

{ XCD: Delete all }

procedure TCdrtfeMainForm.XCDESpeedButton7Click(Sender: TObject);
begin
  UserDeleteAll(XCDETreeView);
end;

{ Audio-CD: Add track }

procedure TCdrtfeMainForm.AudioSpeedButton1Click(Sender: TObject);
begin
  UserAddTrack;
end;

{ Audio-CD: Move track up }

procedure TCdrtfeMainForm.AudioSpeedButton2Click(Sender: TObject);
begin
  if AudioListView.Items.Count > 0 then
  begin
    UserMoveTrack(AudioListView, dUp);
  end;
end;

{ Audio-CD: Move track down }

procedure TCdrtfeMainForm.AudioSpeedButton3Click(Sender: TObject);
begin
  if AudioListView.Items.Count > 0 then
  begin
    UserMoveTrack(AudioListView, dDown);
  end;
end;

{ Audio-CD: Delete track}

procedure TCdrtfeMainForm.AudioSpeedButton4Click(Sender: TObject);
begin
  UserDeleteFile(nil, AudioListView);
end;

{ Video-CD: Add track }

procedure TCdrtfeMainForm.VideoSpeedButton1Click(Sender: TObject);
begin
  UserAddTrack;
end;

{ Video-CD: Move track up }

procedure TCdrtfeMainForm.VideoSpeedButton2Click(Sender: TObject);
begin
  if VideoListView.Items.Count > 0 then
  begin
    UserMoveTrack(VideoListView, dUp);
  end;
end;

{ Video-CD: Move track down }

procedure TCdrtfeMainForm.VideoSpeedButton3Click(Sender: TObject);
begin
  if VideoListView.Items.Count > 0 then
  begin
    UserMoveTrack(VideoListView, dDown);
  end;
end;

{ Video-CD: Delete track}

procedure TCdrtfeMainForm.VideoSpeedButton4Click(Sender: TObject);
begin
  UserDeleteFile(nil, VideoListView);
end;

{ Fix CD }

procedure TCdrtfeMainForm.SpeedButtonFixCDClick(Sender: TObject);
begin
  SetSettings;
  FSettings.Cdrecord.FixDevice := FDevices.CDWriter.Values[
                                    FDevices.CDWriter.Names[
                                      FSettings.General.TabSheetDrive[
                                        FSettings.General.Choice]]];
  FAction.Action := cFixCD;
  FAction.StartAction;
end;


{ Kontextmenü-Events ----------------------------------------------------------}

{ Tree- und ListView-Kontextmenü -----------------------------------------------

  Allgemeines Kontextmenü, das sowohl für die Tree- als auch für die ListViews
  verwendet wird.                                                              }

{ OnPopUp ----------------------------------------------------------------------

  In Abhängigkeit der aufrufenden Komponente und der dort gewählten Einträge
  werden die Menü-Einträge aus- bzw. eingeblendet. Dieser Eventhandler ruft
  die Eventhandler der mittlerweile entfernten Kontextmenüs auf.               }  

procedure TCdrtfeMainForm.TreeListViewPopupMenuPopup(Sender: TObject);
var ListView: TListView;

  procedure SetPopupMenuItemsByTags(Comp: TComponent);
  var PopupTag : Integer;
      i        : Integer;
      PopupMenu: TPopupMenu;
      List     : TListView;
      Tree     : TTreeView;
  begin
    PopupTag := 0;
    PopupMenu := (Sender as TPopupMenu);
    if Comp is TTreeView then
    begin
      Tree := Comp as TTreeView;
      if (Tree = CDETreeView) or (Tree = XCDETreeView) then  PopupTag := 1;
    end else
    if Comp is TListView then
    begin
      List := Comp as TListView;
      if (List = CDEListView) or (List = XCDEListView1) or
         (List = XCDEListView2) then
      begin
        PopupTag := 2;
      end else
      if (List = AudioListView) or (List = VideoListView) then
      begin
        PopupTag := 3;
      end;
    end;
    for i := 0 to PopupMenu.Items.Count - 1 do
      PopupMenu.Items[i].Visible := (PopupMenu.Items[i].Tag = PopupTag) or
                                    (PopupMenu.Items[i].Tag = 0);
  end;

begin
  TreeListViewPopupPaste.Enabled := Clipboard.HasFormat(CF_HDROP);
  SetPopupMenuItemsByTags((Sender as TPopupMenu).PopupComponent);
  if (Sender as TPopupMenu).PopupComponent is TTreeView then
  begin
    CDETreeViewPopupMenuPopup(Sender);
  end else
  if (Sender as TPopupMenu).PopupComponent is TListView then
  begin
    ListView := (Sender as TPopupMenu).PopupComponent as TListView;
    if (ListView = AudioListView) or (ListView = VideoListView) then
    begin
      AudioListViewPopupMenuPopup(Sender);
    end else
    if (ListView = CDEListView) or (ListView = XCDEListView1) or
       (ListView = XCDEListView2) then
    begin
      CDEListViewPopupMenuPopup(Sender);
    end;
  end;
end;

{ Paste }

procedure TCdrtfeMainForm.TreeListViewPopupPasteClick(Sender: TObject);
begin
  AddFromClipboard;
end;

{ Kontextmenü der Tree-Views ---------------------------------------------------

  Das Tree-View-Kontextmenü wird sowohl für den CDETreeeView als auch für den
  XCDETreeView verwendet.                                                      }

{ OnPopUp-----------------------------------------------------------------------

  Allgemeines Event, wenn das Popup-Menü aufgrufen wurde. In Abhängigkeit des
  selektierten Knotens werden die nicht gewünschten Einträge des Menüs
  ausgeblenden.                                                                }

procedure TCdrtfeMainForm.CDETreeViewPopupMenuPopup(Sender: TObject);
var Node: TTreeNode;
    Root: TTreeNode;
    Temp: Boolean;
begin
  case FSettings.General.Choice of
    cDataCD: begin
               Node := CDETreeView.Selected;
               Root := CDETreeView.Items[0];
             end;
    cXCD   : begin
               Node := XCDETreeView.Selected;
               Root := XCDETreeView.Items[0];
             end;
  else
    Node := nil;
    Root := nil;
  end;
  if Node = Root then
  begin
    CDETreeViewPopupSetCDLabel.Visible := True;
    CDETreeViewPopupN1.Visible := True;
    CDETreeViewPopupAddFolder.Visible := True;
    CDETreeViewPopupAddFile.Visible := True;
    CDETreeViewPopupN2.Visible := True;
    CDETreeViewPopupDeleteFolder.Visible := False;
    CDETreeViewPopupRenameFolder.Visible := False;
    CDETreeViewPopupN3.Visible := False;
    CDETreeViewPopupNewFolder.Visible := True;
  end else
  begin
    CDETreeViewPopupSetCDLabel.Visible := False;
    CDETreeViewPopupN1.Visible := False;
    CDETreeViewPopupAddFolder.Visible := True;
    CDETreeViewPopupAddFile.Visible := True;
    CDETreeViewPopupN2.Visible := True;
    CDETreeViewPopupDeleteFolder.Visible := True;
    CDETreeViewPopupRenameFolder.Visible := True;
    CDETreeViewPopupN3.Visible := True;
    CDETreeViewPopupNewFolder.Visible := True;
  end;
  {Darf alte Session importiert werden?}
  Temp := FSettings.DataCD.Multi and FSettings.DataCD.ContinueCD and
          (FSettings.General.Choice = cDataCD) and
          FData.ProjectIsEmpty(cDataCD);
  CDETreeViewPopupN4.Visible := Temp;
  CDETreeViewPopupImport.Visible := Temp;
end;

{ Data-CD, XCD: Set CD label }

procedure TCdrtfeMainForm.CDETreeViewPopupSetCDLabelClick(Sender: TObject);
begin
  case FSettings.General.Choice of
    cDataCD: UserSetCDLabel(CDETreeView);
    cXCD   : UserSetCDLabel(XCDETreeView);
  end;
end;

{ Data-CD, XCD: Add folder }

procedure TCdrtfeMainForm.CDETreeViewPopupAddFolderClick(Sender: TObject);
begin
  case FSettings.General.Choice of
    cDataCD: begin
               UserAddFolder(CDETreeView);
             end;
    cXCD   : begin
               UserAddFolder(XCDETreeView);
             end;
  end;
end;

{ Data-CD, XCD: Add file }

procedure TCdrtfeMainForm.CDETreeViewPopupAddFileClick(Sender: TObject);
begin
  case FSettings.General.Choice of
    cDataCD: begin
               UserAddFile(CDETreeView);
               ShowFolderContent(CDETreeView, CDEListView);
             end;
    cXCD   : begin
               UserAddFile(XCDETreeView);
               ShowFolderContent(XCDETreeView, XCDEListView1);
             end;
  end;
end;

{ Data-CD, XCD: Delete folder }

procedure TCdrtfeMainForm.CDETreeViewPopupDeleteFolderClick(Sender: TObject);
begin
  case FSettings.General.Choice of
    cDataCD: begin
               UserDeleteFolder(CDETreeView);
             end;
    cXCD   : begin
               UserDeleteFolder(XCDETreeView);
             end;
  end;
end;

{ Data-CD, XCD: Rename folder }

procedure TCdrtfeMainForm.CDETreeViewPopupRenameFolderClick(Sender: TObject);
begin
  case FSettings.General.Choice of
    cDataCD: begin
               UserRenameFolderByKey(CDETreeView);
             end;
    cXCD   : begin
               UserRenameFolderByKey(XCDETreeView);
             end;
  end;
end;

{ Data-CD, XCD: Create new folder }

procedure TCdrtfeMainForm.CDETreeViewPopupNewFolderClick(Sender: TObject);
begin
  UserNewFolder(GetCurrentTreeView);
end;

{ Data-CD: Multisession-CD importieren}

procedure TCdrtfeMainForm.CDETreeViewPopupImportClick(Sender: TObject);
begin
  UserImportCD;
end;

{ Kontextmenü der List-Views ---------------------------------------------------

  Das List-View-Kontextmenü wird sowohl für den CDEListView als auch für den
  XCDEListView verwendet.
  Das Audio-List-View-Kontextmenü wird sowohl für der AudioListView als auch für
  VideoListView verwendet.                                                     }

{ OnPopup ----------------------------------------------------------------------

  in Abhängigkeit des List-Views, und der Anzahl der selektierten Dateien werden
  Menü-Einträge ein- bzw. ausgeblendet.                                        }

procedure TCdrtfeMainForm.CDEListViewPopupMenuPopup(Sender: TObject);
var ListView   : TListView;
    OpenVisible: Boolean;
begin
  ListView := (Sender as TPopupMenu).PopupComponent as TListView;
  if ListView.SelCount = 0 then
  begin
    CDEListViewPopupAddFile.Visible := True;
    CDEListViewPopupAddFolder.Visible := True;
    CDEListViewPopupN1.Visible := False;
    CDEListViewPopupRenameFile.Visible := False;
    CDEListViewPopupDeleteFile.Visible := False;
    CDEListViewPopupN5.Visible := True;
    CDEListViewPopupNewFolder.Visible := True;
  end else
  if ListView.SelCount = 1 then
  begin
    CDEListViewPopupAddFile.Visible := True;
    CDEListViewPopupAddFolder.Visible := True;
    CDEListViewPopupN1.Visible := True;
    CDEListViewPopupRenameFile.Visible := True;
    CDEListViewPopupDeleteFile.Visible := True;
    CDEListViewPopupN5.Visible := True;
    CDEListViewPopupNewFolder.Visible := True;    
  end else
  begin
    CDEListViewPopupAddFile.Visible := True;
    CDEListViewPopupAddFolder.Visible := True;    
    CDEListViewPopupN1.Visible := True;
    CDEListViewPopupRenameFile.Visible := False;
    CDEListViewPopupDeleteFile.Visible := True;
    CDEListViewPopupN5.Visible := True;
    CDEListViewPopupNewFolder.Visible := True;      
  end;
  if ListView = XCDEListView2 then
  begin
    CDEListViewPopupAddFile.Visible := False;
    CDEListViewPopupAddMovie.Visible := True;
    CDEListViewPopupRenameFile.Visible := False;
  end else
  if ListView = XCDEListView1 then
  begin
    CDEListViewPopupRenameFile.Visible := False;
  end else
  begin
    CDEListViewPopupAddMovie.Visible := False;
  end;
  OpenVisible := (ListView.SelCount > 0) and FSettings.General.AllowFileOpen;
  CDEListViewPopupN6.Visible := OpenVisible;
  CDEListViewPopupOpen.Visible := OpenVisible;
  CDEListViewPopupOpen.Default := FSettings.General.AllowDblClick;
end;

{ Data-CD, XCD: Add file }

procedure TCdrtfeMainForm.CDEListViewPopupAddFileClick(Sender: TObject);
begin
  case FSettings.General.Choice of
    cDataCD: begin
               UserAddFile(CDETreeView);
               ShowFolderContent(CDETreeView, CDEListView);
             end;
    cXCD   : begin
               UserAddFile(XCDETreeView);
               ShowFolderContent(XCDETreeView, XCDEListView1);
             end;
  end;
end;

{ Data-CD, XCD: Add folder }

procedure TCdrtfeMainForm.CDEListViewPopupAddFolderClick(Sender: TObject);
begin
  CDETreeViewPopupAddFolderClick(Sender);
end;

{ XCD: Add file as Form2 file }

procedure TCdrtfeMainForm.CDEListViewPopupAddMovieClick(Sender: TObject);
begin
  FSettings.General.XCDAddMovie := True;
  UserAddFile(XCDETreeView);
  ShowFolderContent(XCDETreeView, XCDEListView1);
end;

{ Data-CD: Rename file }

procedure TCdrtfeMainForm.CDEListViewPopupRenameFileClick(Sender: TObject);
begin
  case FSettings.General.Choice of
    cDataCD: begin
               UserRenameFile(CDEListView);
             end;
    cXCD   : {wird zur Zeit von Mode2CDMaker nicht unterstützt};
  end;
end;

{ Data-CD, XCD: Delete file }

procedure TCdrtfeMainForm.CDEListViewPopupDeleteFileClick(Sender: TObject);
begin
  case FSettings.General.Choice of
    cDataCD: UserDeleteFile(CDETreeView, CDEListView);
    cXCD   : UserDeleteFile(XCDETreeView, GetPopupComp(Sender) as TListView);
  end;
end;

{ Data-CD, XCD, New folder }

procedure TCdrtfeMainForm.CDEListViewPopupNewFolderClick(Sender: TObject);
begin
  UserNewFolder(GetCurrentTreeView);
end;

{ Data-CD, XCD: Open file }

procedure TCdrtfeMainForm.CDEListViewPopupOpenClick(Sender: TObject);
begin 
  UserOpenFile(GetCurrentListView(GetPopupComp(Sender)));
end;

{ OnPopup ----------------------------------------------------------------------

  in Abhängigkeit der Anzahl der Tracks werden die Menü-Einträge ein- bzw.
  ausgeblendet.                                                                }

procedure TCdrtfeMainForm.AudioListViewPopupMenuPopup(Sender: TObject);
var ListView   : TListView;
    PlayVisible: Boolean;
begin
  ListView := GetCurrentListView(Sender);
  if (ListView.Items.Count < 2) or (ListView = VideoListView) then
  begin
    AudioListViewPopupN3.Visible := False;
    AudioListViewPopupSort.Visible := False;
  end else
  begin
    AudioListViewPopupN3.Visible := True;
    AudioListViewPopupSort.Visible := True;
  end;
  if ListView.SelCount = 0 then
  begin
    AudioListViewPopupAddTrack.Visible := True;
    AudioListViewPopupDeleteTrack.Visible := False;
    AudioListViewPopupN1.Visible := False;
    AudioListViewPopupMoveUp.Visible := False;
    AudioListViewPopupMoveDown.Visible := False;
    AudioListViewPopupN2.Visible := False;
    AudioListViewPopupPlay.Visible := False;
  end else
  begin
    AudioListViewPopupAddTrack.Visible := True;
    AudioListViewPopupDeleteTrack.Visible := True;
    AudioListViewPopupN1.Visible := True;
    if ListView.Selected.Index = 0 then
    begin
      AudioListViewPopupMoveUp.Visible := False;
      AudioListViewPopupMoveDown.Visible := True;
    end else
    if ListView.Selected.Index = ListView.Items.Count - 1 then
    begin
      AudioListViewPopupMoveUp.Visible := True;
      AudioListViewPopupMoveDown.Visible := False;
    end else
    begin
      AudioListViewPopupMoveUp.Visible := True;
      AudioListViewPopupMoveDown.Visible := True;
    end;
    with FSettings do
      PlayVisible := General.AllowFileOpen and
                     ((General.UseMPlayer and FileFlags.MPlayerOk) or
                      not General.UseMPlayer);
    AudioListViewPopupN2.Visible := PlayVisible;
    AudioListViewPopupPlay.Visible := PlayVisible;
    AudioListViewPopupPlay.Default := FSettings.General.AllowDblClick;
  end;
end;

{ Audio-/Video-CD: Add track }

procedure TCdrtfeMainForm.AudioListViewPopupAddTrackClick(Sender: TObject);
begin
  UserAddTrack;
end;

{ Audio-/Video-CD: Delete track }

procedure TCdrtfeMainForm.AudioListViewPopupDeleteTrackClick(Sender: TObject);
begin
  case FSettings.General.Choice of
    cAudioCD: UserDeleteFile(nil, AudioListView);
    cVideoCD: UserDeleteFile(nil, VideoListView);
  end;                                 
end;

{ Audio-CD: Move track up }

procedure TCdrtfeMainForm.AudioListViewPopupMoveUpClick(Sender: TObject);
var ListView: TListView;
begin
  ListView := GetCurrentListView(Sender);
  if ListView.Items.Count > 0 then
  begin
    UserMoveTrack(ListView, dUp);
  end;
end;

{ Audio-CD: Move track down }

procedure TCdrtfeMainForm.AudioListViewPopupMoveDownClick(Sender: TObject);
var ListView: TListView;
begin
  ListView := GetCurrentListView(Sender);
  if ListView.Items.Count > 0 then
  begin
    UserMoveTrack(ListView, dDown);
  end;
end;

{ Audio-CD: Play track}

procedure TCdrtfeMainForm.AudioListViewPopupPlayClick(Sender: TObject);
begin
  UserOpenFile(GetCurrentListView(GetPopupComp(Sender)));
end;

{ Audio-CD: Sort tracks}

procedure TCdrtfeMainForm.AudioListViewPopupSortClick(Sender: TObject);
var ListView: TListView;
begin
  ListView := GetCurrentListView(Sender);
  if ListView.Items.Count > 0 then
  begin
    UserSortTracks(ListView);
  end;
end;

{ Kontextmenü, sonstiges  ------------------------------------------------------

  Dieses Kontextmenü wird für sonstige Zwecke verwendet, die nicht zu einer
  bestimmten Aufgabe oder Option passen.                                       }

{ OnPopup ----------------------------------------------------------------------

  in Abhängigkeit des List-Views, und der Anzahl der selektierten Dateien werden
  Menü-Einträge ein- bzw. ausgeblendet.                                        }

procedure TCdrtfeMainForm.MiscPopupMenuPopup(Sender: TObject);
begin
  if ((Sender as TPopupMenu).PopupComponent = CheckBoxDataCDVerify) or
     ((Sender as TPopupMenu).PopupComponent = CheckBoxXCDVerify) or
     ((Sender as TPopupMenu).PopupComponent = CheckBoxDVDVideoVerify) or
     ((Sender as TPopupMenu).PopupComponent = CheckBoxISOVerify) then
  begin
    MiscPopupVerify.Visible := True;
    MiscPopupClearOutput.Visible := False;
    MiscPopupSaveOutput.Visible := False;
    MiscPopupEject.Visible := False;
    MiscPopupLoad.Visible := False;
  end else
  if ((Sender as TPopupMenu).PopupComponent = Memo1) then
  begin
    MiscPopupVerify.Visible := False;
    MiscPopupClearOutput.Visible := True;
    MiscPopupSaveOutput.Visible := True;
    MiscPopupEject.Visible := False;
    MiscPopupLoad.Visible := False;
  end else
  if ((Sender as TPopupMenu).PopupComponent = ComboBoxDrives) then
  begin
    MiscPopupVerify.Visible := False;
    MiscPopupClearOutput.Visible := False;
    MiscPopupSaveOutput.Visible := False;    
    MiscPopupEject.Visible := True;
    MiscPopupLoad.Visible := True;
  end;
end;

{ Verify }

procedure TCdrtfeMainForm.MiscPopupVerifyClick(Sender: TObject);
var OTF: Boolean;
    XCDPath: string;
begin
  {$IFDEF ShowExecutionTime}
  TC2.StartTimeCount;
  {$ENDIF}
  {Um sicherzustellen, daß nicht über einen fehlenden Namen für das Image ge-
   meckert wird, täuschen wir einfach otf vor bzw. setzten einfach einen Image-
   Namen ein (XCD).}
  OTF := FSettings.DataCD.OnTheFly;
  FSettings.DataCD.OnTheFly := True;
  XCDPath := FSettings.XCD.IsoPath;
  FSettings.XCD.IsoPath := 'dummy';
  {Auf 'Image-only' und 'dummy' wird nicht mehr geprüft, da sonst möglicherweise
   ein selbst erstelltes und später geschriebenes Image nicht verifiziert werden
   kann.}
  if (FSettings.General.Choice = cDataCD) and InputOk {and
     not (FSettings.DataCD.ImageOnly or FSettings.Cdrecord.Dummy)} then
  begin
    FAction.Action := cVerify;
    FAction.Reload := False;
    FAction.StartAction;
  end else
  if (FSettings.General.Choice = cXCD) and InputOk then
  begin
    FAction.Action := cVerifyXCD;
    FAction.Reload := False;
    FAction.StartAction;
  end;
  if (FSettings.General.Choice = cDVDVideo) and InputOk then
  begin
    FAction.Action := cVerifyDVDVideo;
    FAction.Reload := False;
    FAction.StartAction;
  end;
  if (FSettings.General.Choice = cCDImage) and InputOk and
     (LowerCase(ExtractFileExt(FSettings.Image.IsoPath)) = cExtISO) then
  begin
    FAction.Action := cVerifyISOImage;
    FAction.Reload := False;
    FAction.StartAction;
  end;
  {Alten Wert wiederherstellen.}
  FSettings.DataCD.OnTheFly := OTF;
  FSettings.XCD.IsoPath := XCDPath;
end;

{ Clear output }

procedure TCdrtfeMainForm.MiscPopupClearOutputClick(Sender: TObject);
begin
  TLogWin.Inst.Clear;
end;

{ Save log }

procedure TCdrtfeMainForm.MiscPopupSaveOutputClick(Sender: TObject);
var DialogID: TDialogID;
begin
  DialogID := DIDSaveLog;
  SaveDialog1 := TSaveDialog.Create(Self);
  SaveDialog1.DefaultExt := 'txt';
  SaveDialog1.Filter := '(*.txt)|*.txt';
  SaveDialog1.InitialDir := GetCachedFolderName(DialogID);
  SaveDialog1.Options := [ofOverwritePrompt,ofHideReadOnly];
  if SaveDialog1.Execute then
  begin
    TLogWin.Inst.SaveLog(SaveDialog1.FileName);
    CacheFolderName(DialogID, SaveDialog1.FileName);
  end;
  SaveDialog1.Free;
end;

{ Load/Eject Disk }

procedure TCdrtfeMainForm.MiscPopupEjectClick(Sender: TObject);
begin
  EjectDisk(FDevices.CDDevices.Values[ComboBoxDrives.Items[
                                       ComboBoxDrives.ItemIndex]]);
end;

procedure TCdrtfeMainForm.MiscPopupLoadClick(Sender: TObject);
begin
  LoadDisk(FDevices.CDDevices.Values[ComboBoxDrives.Items[
                                      ComboBoxDrives.ItemIndex]]);
end;


{ CheckBox-Events ------------------------------------------------------------ }

{ OnClick ----------------------------------------------------------------------

  Nach einen Klick auf eine Check-Box muß sichergestellt sein, daß die Controls
  in einem konsistenten Zustand sind.

  Diese Prozedur wird auch für das OnClick-Event der Radio-Buttuns verwendet.  }

procedure TCdrtfeMainForm.CheckBoxClick(Sender: TObject);
begin
  if not FCheckingControls then CheckControls;
end;


{ Edit-Events ---------------------------------------------------------------- }

{ OnKeyPress -------------------------------------------------------------------

  allgemein: nach Enter soll zum nächsten Control gewechselt werden.           }

procedure TCdrtfeMainForm.EditKeyPress(Sender: TObject; var Key: Char);
var C: TControl;
begin
  C := Sender as TControl;
  if Key = EnterKey then
  begin
    Key := NoKey;
    if C = EditDAEPath then
    begin
      PageControl1.SetFocus;
    end else
    if C = EditReadCDIsoPath then
    begin
      ButtonReadCDSelectPath.SetFocus;
    end else
    if C = EditReadCDRetries then
    begin
      CheckBoxReadCDRange.SetFocus;
    end else
    if C = EditReadCDStartSec then
    begin
      EditReadCDEndSec.SetFocus;
    end else
    if C = EditReadCDEndSec then
    begin
      PageControl1.SetFocus;
    end else
    if C = EditImageIsoPath then
    begin
      ButtonImageSelectPath.SetFocus;
    end else
    if C = ComboBoxDrives then
    begin
      ComboBoxSpeed.SetFocus;
    end else
    if C = ComboBoxSpeed then
    begin
      ButtonStart.SetFocus;
    end else
    if C = EditDVDVideoSourcePath then
    begin
      EditDVDVideoVolID.SetFocus;
    end else
    if C = EditDVDVideoVolID then
    begin
      ButtonStart.SetFocus;
    end;
  end;
end;

{ OnExit -----------------------------------------------------------------------

  Wenn das EditImageIsoPath verlassen wird, müssen in Abhänigkeit der Datei-
  endung des Images die Controls angepaßt werden.                              }

procedure TCdrtfeMainForm.EditExit(Sender: TObject);
begin
  if (Sender as TEdit) = EditImageIsoPath then
  begin
    CheckControls;
  end else
  if (Sender as TEdit) = EditReadCDRetries then
  begin
    {Quick'n'Dirty: nur Zahlen akzeptieren}
    if StrToIntDef(EditReadCDRetries.Text, -1) = -1 then
      EditReadCDRetries.Text := '';
  end;
end;

{ OnChange ---------------------------------------------------------------------

  Labels dürfen max. 32 Zeichen lang sein.                                     }

procedure TCdrtfeMainForm.EditChange(Sender: TObject);
begin
  if (Sender as TEdit) = EditDVDVideoVolID then
  begin
    if not CDLabelIsValid(EditDVDVideoVolID.Text) then
    begin
      EditDVDVideoVolID.Text := Copy(EditDVDVideoVolID.Text, 1, 32);
      EditDVDVideoVolID.SelStart := 32;
      ShowMsgDlg(Format(FLang.GMS('m502'), [32]),
                 FLang.GMS('g004'), MB_cdrtfeWarning);
    end;
  end;
end;

{ OnDblClick -------------------------------------------------------------------

  Bei Doppelklick auf das Edit für das DVD-Video-Label soll der Name übernommen
  werden.                                                                      }

procedure TCdrtfeMainForm.EditDblClick(Sender: TObject);
var Temp: string;
begin
  Temp := EditDVDVideoSourcePath.Text;
  Delete(Temp, 1, LastDelimiter('\', Temp));
  EditDVDVideoVolID.Text := Temp;
end;


{ ComboBox-Events ------------------------------------------------------------ }

{ OnChange ---------------------------------------------------------------------

  Die ausgewählten Laufwerke sollen für jedes Tab-Sheet getrennt gespeichert
  werden. Ebenso die Geschwindigkeit.                                          }

procedure TCdrtfeMainForm.ComboBoxChange(Sender: TObject);
begin
  if (Sender as TComboBox) = ComboBoxDrives then
  begin
    FSettings.General.TabSheetDrive[FSettings.General.Choice] :=
      ComboBoxDrives.ItemIndex;
    CheckControlsSpeeds;
  end else
  if (Sender as TComboBox) = ComboBoxSpeed then
  begin
    FSettings.General.TabSheetSpeed[FSettings.General.Choice] :=
      ComboBoxSpeed.ItemIndex;
  end;
end;


{ Label-Events --------------------------------------------------------------- }

{ OnClick ----------------------------------------------------------------------

  Beim Klick auf ein Label, das den Zustand einer Option darstellt, soll die
  Option (de-)aktiviert werden. Das Umschalten erfolgt in einer eigenen
  Prozedur.                                                                    }
                                                             
{$IFDEF AllowToggle}
procedure TCdrtfeMainForm.LabelClick(Sender: TObject);
begin
  ToggleOptions(Sender);
end;
{$ENDIF}

{ MouseOver --------------------------------------------------------------------

  Die Labels sollen anzeigen können, daß sie klickbar sind, wenn der Mauszeiger
  auf ihnen ist.                                                               }

{$IFDEF MouseOverLabelHighlight}
procedure TCdrtfeMainForm.LabelMouseMove(Sender: TObject; Shift: TShiftState;
                                         X, Y: Integer);
begin
  (Sender as TLabel).Color := clInactiveCaptionText;
end;
{$ENDIF}


{ Panel-Events --------------------------------------------------------------- }

{ MouseOver --------------------------------------------------------------------

  Setzt die Markierung eines Labels zurück, wenn es verlassen wird.            }

{$IFDEF MouseOverLabelHighlight}
procedure TCdrtfeMainForm.PanelMouseMove(Sender: TObject; Shift: TShiftState;
                                         X, Y: Integer);
var Panel: TPanel;
    i: Integer;
begin
  Panel := Sender as TPanel;
  for i := 0 to Panel.ControlCount - 1 do
  begin
    if Panel.Controls[i] is TLabel then
    begin
      (Panel.Controls[i] as TLabel).Color := clBtnFace;
    end;
  end;
end;
{$ENDIF}


{ Timer-Events --------------------------------------------------------------- }

{ OnTimer ----------------------------------------------------------------------

  Wird ausgeführt, wenn die 1.5 Sekunden Verzögerung für ein TreeNode-Expand
  vertrichen ist.                                                              }

procedure TCdrtfeMainForm.TimerNodeExpandTimer(Sender: TObject);
begin
  ExpandNodeDelayed(nil, True);
end;


{ Memo-Events ---------------------------------------------------------------- }

{ OnKeyDown --------------------------------------------------------------------

  gesamten Text markieren.                                                     }

procedure TCdrtfeMainForm.Memo1KeyDown(Sender: TObject; var Key: Word;
                              Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = Ord('A')) then
  begin
    (Sender as TMemo).SelectAll;
  end;
end;


{ Actions -------------------------------------------------------------------- }

{ InitActions ------------------------------------------------------------------

  initialisiert die Actions. Action werden benötigt, da im OnKeyDown-Event des
  Hauptfensters immer ein Beep erzeugt wird, bei Actions jedoch nicht.         }

procedure TCdrtfeMainForm.InitActions;
begin
  {ActionList erstellen}
  ActionList := TActionList.Create(Self);
  {Actions erstellen - Dateien/Tracks hinzufügen}
  ActionUserAddFile := TAction.Create(ActionList);
  ActionUserAddFile.ShortCut := ShortCut($4F{VK_O}, [ssAlt]);
  ActionUserAddFile.OnExecute := ActionUserAddFileExecute;
  ActionUserAddFile.ActionList := ActionList;
  {Actions erstellen - Form2-Dateien hinzufügen}
  ActionUserAddFileForm2 := TAction.Create(ActionList);
  ActionUserAddFileForm2.ShortCut := ShortCut($56{VK_V}, [ssAlt]);
  ActionUserAddFileForm2.OnExecute := ActionUserAddFileForm2Execute;
  ActionUserAddFileForm2.ActionList := ActionList;
  {Actions erstellen - Ordner hinzufügen}
  ActionUserAddFolder := TAction.Create(ActionList);
  ActionUserAddFolder.ShortCut := ShortCut($49{VK_I}, [ssAlt]);
  ActionUserAddFolder.OnExecute := ActionUserAddFolderExecute;
  ActionUserAddFolder.ActionList := ActionList;
  {Actions erstellen - Alles löschen}
  ActionUserDeleteAll := TAction.Create(ActionList);
  ActionUserDeleteAll.ShortCut := ShortCut(VK_Delete, [ssAlt]);
  ActionUserDeleteAll.OnExecute := ActionUserDeleteAllExecute;
  ActionUserDeleteAll.ActionList := ActionList;
  {Actions erstellen - Track nach oben bewegen}
  ActionUserTrackUp := TAction.Create(ActionList);
  ActionUserTrackUp.ShortCut := ShortCut(VK_UP, [ssAlt]);
  ActionUserTrackUp.OnExecute := ActionUserTrackUpExecute;
  ActionUserTrackUp.ActionList := ActionList;
  {Actions erstellen - Track nach unten bewegen}
  ActionUserTrackDown := TAction.Create(ActionList);
  ActionUserTrackDown.ShortCut := ShortCut(VK_Down, [ssAlt]);
  ActionUserTrackDown.OnExecute := ActionUserTrackDownExecute;
  ActionUserTrackDown.ActionList := ActionList;
  {Actions erstellen - FileExplorer aufrufen}
  ActionUserToggleFileExplorer := TAction.Create(ActionList);
  ActionUserToggleFileExplorer.ShortCut := ShortCut($45{VK_E}, [ssAlt]);
  ActionUserToggleFileExplorer.OnExecute := ActionUserToggleFileExplorerExecute;
  ActionUserToggleFileExplorer.ActionList := ActionList;
  {Actions erstellen - Einstellungsdialog aufrufen}
  ActionUserSettings := TAction.Create(ActionList);
  ActionUserSettings.ShortCut := ShortCut($53{VK_S}, [ssAlt]);
  ActionUserSettings.OnExecute := ActionUserSettingsExecute;
  ActionUserSettings.ActionList := ActionList;
  {Actions erstellen - Logfenster öffnen}
  ActionUserShowOutputWindow := TAction.Create(ActionList);
  ActionUserShowOutputWindow.ShortCut := ShortCut($4C{VK_L}, [ssAlt]);
  ActionUserShowOutputWindow.OnExecute := ActionUserShowOutputWindowExecute;
  ActionUserShowOutputWindow.ActionList := ActionList;
  {Actions erstellen - SpecialTab Componentswitch}
  ActionUserSpecialTab := TAction.Create(ActionList);
  ActionUserSpecialTab.ShortCut := ShortCut($51{VK_Q}, [ssAlt]);
  ActionUserSpecialTab.OnExecute := ActionUserSpecialTabExecute;
  ActionUserSpecialTab.ActionList := ActionList;
  {Actions erstellen - LogWindow ein- bzw. ausblenden}
  ActionUserToggleLogWindow := TAction.Create(ActionList);
  ActionUserToggleLogWindow.ShortCut :=  ShortCut($4B{VK_K}, [ssAlt]);
  ActionUserToggleLogWindow.OnExecute := ActionUserToggleLogWindowExecute;
  ActionUserToggleLogWindow.ActionList := ActionList;
  {Actions erstellen - LogWindow und Explorer aus- und einblenden}
  ActionUserToggleExplorerLog := TAction.Create(ActionList);
  ActionUserToggleExplorerLog.ShortCut :=  ShortCut($4A{VK_J}, [ssAlt]);
  ActionUserToggleExplorerLog.OnExecute := ActionUserToggleExplorerLogExecute;
  ActionUserToggleExplorerLog.ActionList := ActionList;
end;

procedure TCdrtfeMainForm.ActionUserAddFileExecute(Sender: TObject);
begin
  HandleKeyboardShortcut($4F);
end;

procedure TCdrtfeMainForm.ActionUserAddFileForm2Execute(Sender: TObject);
begin
  HandleKeyboardShortcut($56);
end;

procedure TCdrtfeMainForm.ActionUserAddFolderExecute(Sender: TObject);
begin
  HandleKeyboardShortcut($49);
end;

procedure TCdrtfeMainForm.ActionUserDeleteAllExecute(Sender: TObject);
begin
  HandleKeyboardShortcut(VK_DELETE);
end;

procedure TCdrtfeMainForm.ActionUserTrackUpExecute(Sender: TObject);
begin
  HandleKeyboardShortcut(VK_UP);
end;

procedure TCdrtfeMainForm.ActionUserTrackDownExecute(Sender: TObject);
begin
  HandleKeyboardShortcut(VK_DOWN);
end;

procedure TCdrtfeMainForm.ActionUserToggleFileExplorerExecute(Sender: TObject);
begin
  HandleKeyboardShortcut($45);
end;

procedure TCdrtfeMainForm.ActionUserSettingsExecute(Sender: TObject);
begin
  HandleKeyboardShortcut($53);
end;

procedure TCdrtfeMainForm.ActionUserShowOutputWindowExecute(Sender: TObject);
begin
  HandleKeyboardShortcut($4C);
end;

procedure TCdrtfeMainForm.ActionUserSpecialTabExecute(Sender: TObject);
begin
  HandleKeyboardShortcut($51);
end;

procedure TCdrtfeMainForm.ActionUserToggleLogWindowExecute(Sender: TObject);
begin
  HandleKeyboardShortcut($4B);
end;

procedure TCdrtfeMainForm.ActionUserToggleExplorerLogExecute(Sender: TObject);
begin
  HandleKeyboardShortcut($4A);
end;
                              
{ Hilfsfunktionen ------------------------------------------------------------ }

{ ExpandNodeDelayed ------------------------------------------------------------

  sorgt für das verzögerte Öffnen der TreeNodes.                               }

procedure TCdrtfeMainForm.ExpandNodeDelayed(Node: TTreeNode; const TimerEvent: Boolean);
const {$J+} NodeToExpand: TTreeNode = nil; {$J-}
var MousePos: TPoint;
    Control : TWinControl;
begin
  if TimerEvent then
  begin
    {Die Wartezeit ist vorbei.}
    TimerNodeExpand.Enabled := False;
    GetCursorPos(MousePos);
    Control := FindVCLWindow(MousePos);
    if (Control <> nil) and (Control is TTreeView) then
    begin
      MousePos := (Control as TTreeView).ScreenToClient(MousePos);
      Node := (Control as TTreeView).GetNodeAt(MousePos.x, MousePos.y);
//      Memo1.Lines.Add('NodeToExpand: ' + NodeToExpand.Text);
//      if Node <> nil then Memo1.Lines.Add('Node        : ' + Node.Text);
      if Node = NodeToExpand then
      begin
        NodeToExpand.Expand(False);
        DropFileTargetCDETreeView.ShowImage := False;
        DropFileTargetXCDETreeView.ShowImage := False;
        NodeToExpand.TreeView.Repaint;
        DropFileTargetCDETreeView.ShowImage := True;
        DropFileTargetXCDETreeView.ShowImage := True;
      end;
    end;
    NodeToExpand := nil;
  end else
  begin
    {Beginn der Wartezeit.}
    NodeToExpand := Node;
    TimerNodeExpand.Enabled := True;
  end;
end;

{ SetHelpFile ------------------------------------------------------------------

  Pfad zur Hilfe-Datei abhängig von der gewählten Sprache setzen.              }

procedure TCdrtfeMainForm.SetHelpFile;
{$IFDEF Delphi2005Up}
var HelpFileName: string;
    HelpPath    : string;
{$ENDIF}
begin
  {Helpsystem - chm-support erst ab Delphi 2005?}
  {$IFDEF Delphi2005Up}
  HelpPath := StartUpDir + cHelpDir;
  if FLang.CurrentLangName <> '' then
  begin
    HelpFileName := cHelpFile + LowerCase(FLang.CurrentLangName) + cExtChm;
    if not FileExists(HelpPath + HelpFileName) then
      HelpFileName := cHelpFile + 'english' + cExtChm;
  end else
  begin
    HelpFileName := cHelpFile + 'german' + cExtChm;
  end;
  Application.HelpFile := HelpPath + HelpFileName;
  {$ENDIF}
end;

{$IFDEF TestVersion}{$MESSAGE Hint 'Kompilation als Testversion!'}{$ENDIF}

initialization
  SetDLLDirectory('');
  {$IFDEF DoMemCheck}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  DeviceChangeNotifier := TDeviceChangeNotifier.Create(nil);
  {$IFDEF ShowDebugWindow}
  FormDebug := TFormDebug.Create(nil);
  FormDebug.Top := 0;
  FormDebug.Left := 0;
  FormDebug.Show;
  {$ENDIF}
  {$IFDEF WriteLogfile}
  AddLogCode(1050);
  {$ENDIF}
  {$IFDEF ShowTime}
  TC  := TTimeCount.Create;
  TC2 := TTimeCount.Create;
  {$ENDIF}
  {$IFDEF ShowStartupTime}
  TC.StartTimeCount;
  {$ENDIF}

finalization
  {$IFDEF ShowDebugWindow}
  FormDebug.Free;
  {$ENDIF}
  {$IFDEF WriteLogfile}
  AddLogCode(1056);
  {$ENDIF}
  DeviceChangeNotifier.Free;
  {$IFDEF ShowTime}
  TC.Free;
  TC2.Free;  
  {$ENDIF}

end.
