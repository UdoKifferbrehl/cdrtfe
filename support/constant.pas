{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  constant.pas: Konstanten-Deklaration

  Copyright (c) 2004-2006 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung 06.10.2006

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt. 

}

unit constant;

{$I directives.inc}

interface

const {die GUID für cdrtfe}
      CdrtfeClassID    : string = '{23ADD0C0-5A56-11D7-B55C-00E07D907FE2}';

      {Default-Werte für Größe und Breite}
      dWidth         = 753;
      dHeight        = 494;
      dWidthBigFont  = 923;
      dHeightBigFont = 610;

      {für KeyPress-Events}
      EnterKey = #13;
      NoKey    = #00;

      {für feoutput.pas}
      CR       = #13;
      LF       = #10;
      CRLF     = #13#10;
      BckSp    = #8;

      {für das Abschalten der TreeView-Tooltips}
      TVS_NoTooltips = $80;

      {für TSettings.General.Choice und TAction}
      cDataCD         = 1;
      cAudioCD        = 2;
      cXCD            = 3;
      cCDRW           = 4;
      cCDInfos        = 5;
      cDAE            = 6;
      cCDImage        = 7;
      cVideoCD        = 8;
      cDVDVideo       = 9;

      {für TAction und TVerifyThread}
      cDAEReadTOC     = 20;
      cFixCD          = 21;
      cVerify         = 22;
      cVerifyXCD      = 23;
      cFindDuplicates = 24;
      cCreateInfoFile = 25;
      cVerifyDVDVideo = 26;
      cNoAction       = 0;

      {für TSettings.General.TabFrmSettings}
      cCdrtfe    = 1;
      cCdrecord  = 2;
      cCdrecord2 = 3;
      cCdrdao    = 4;
      cCDAudio   = 5;

      {für TSEttings.General.TabFrmDAE}
      cTabDAE    = 1;
      cTabCDDB   = 2;                     

      {Standard-Puffergröße}
      cBufSize = $800;

      {Dateinamen - Kommandozeilenprogramme}
      {$J+}
      cCdrecordBin     : string = '\cdrecord';
      cMkisofsBin      : string = '\mkisofs';
      cCdda2wavBin     : string = '\cdda2wav';
      cReadcdBin       : string = '\readcd';
      cShBin           : string = '\sh';
      cMode2CDMakerBin : string = '\mode2cdmaker';
      cVCDImagerBin    : string = '\vcdimager';
      cCdrdaoBin       : string = '\cdrdao';
      cMadplayBin      : string = '\madplay';
      cLameBin         : string = '\lame';
      cOggdecBin       : string = '\oggdec';
      cOggencBin       : string = '\oggenc';
      cFLACBin         : string = '\flac';
      cRrencBin        : string = '\rrenc';
      cRrdecBin        : string = '\rrdec';
      {$J-}

      {Dateinamen - Tools/DLLs}
      cCdrtfeShlExDll  : string = '\cdrtfeShlEx.dll';
      cCdrtfeResDll    : string = '\cdrtferes.dll';
      {$J+}
      cM2F2ExtractBin  : string = '\m2f2extract.exe';
      cDat2FileBin     : string = '\dat2file.exe';
      cD2FGuiBin       : string = '\d2fgui.exe';
      cCygwin1Dll      : string = 'cygwin1.dll';
      {$J-}

      {Dateinamen}
      cPathListFile    : string = '\pathlist.txt';
      cCDTextFile      : string = '\cdtext.dat';
      cShCmdFile       : string = '\cmd.cdr';
      cXCDInfoFile     : string = '\xcd.crc';
      cXCDParamFile    : string = '\xcd.txt';
      cRrencInputFile  : string = '\xcd.rr';
      cRrencOutputFile : string = '\xcd';
      cRrencRRTFile    : string = '\protect.rrt';
      cRrencRRDFile    : string = '\protect.rrd';
      cIniFile         : string = '\cdrtfe.ini';
      cIniFileTools    : string = '\cdrtfe_tools.ini';
      cDefaultIsoName  : string = '\image';

      {Dateiendungen}
      cExtExe          : string = '.exe';
      cExtBin          : string = '.bin';
      cExtCue          : string = '.cue';
      cExtToc          : string = '.toc';
      cExtIso          : string = '.iso';
      cExtWav          : string = '.wav';
      cExtMP3          : string = '.mp3';
      cExtOgg          : string = '.ogg';
      cExtFlac         : string = '.flac';
      cExtM3u          : string = '.m3u';
      cExtUm2          : string = '.um2';
      cExtBMP          : string = '.bmp';

      {Ordnernamen}
      cDataDir         : string = '\cdrtfe';
      cIconDir         : string = '\icons';

      {Umgebungsvariablen}
      cCDRSEC          : string = 'CDR_SECURITY';
      cComSpec         : string = 'ComSpec';

      {Icons/Glyphs}
      cGlyphCount      = 21;
      
      IconNames        : array[1..4] of string =
                           ('icon_folder_closed',
                            'icon_folder_opened',
                            'icon_cd',
                            'icon_audiotrack');

      GlyphNames       : array[1..cGlyphCount, 1..3] of string =
                           (('btn_load_file',      'B1', ''),
                            ('btn_load_folder',    'B2', ''),
                            ('btn_del_file',       'B3', ''),
                            ('btn_del_folder',     'B4', ''),
                            ('btn_del_all',        'B5', ''),
                            ('btn_check_fs',       'B6', ''),
                            ('btn_a_up',           'B7', ''),
                            ('btn_a_down',         'B8', ''),
                            ('btn_a_load_track',   'B1', '1'),
                            ('btn_a_del_track',    'B3', '3'),
                            ('btn_x_load_file_f1', 'B1', '1'),
                            ('btn_x_load_folder',  'B2', '2'),
                            ('btn_x_del_file_f1',  'B3', '3'),
                            ('btn_x_load_file_f2', 'B1', '1'),
                            ('btn_x_del_file_f2',  'B3', '3'),
                            ('btn_x_del_folder',   'B4', '4'),
                            ('btn_x_del_all',      'B5', '5'),
                            ('btn_v_up',           'B7', '7'),
                            ('btn_v_down',         'B8', '8'),
                            ('btn_v_load_track',   'B1', '1'),
                            ('btn_v_del_track',    'B3', '3'));

type {Richtungsangaben beim Verschieben von Tracks}
     TDirection = (dUp, dDown);
     TOnOff     = (oOn, oOff);

implementation

end.
