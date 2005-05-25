{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  constant.pas: Konstanten-Deklaration

  Copyright (c) 2004-2005 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte �nderung  30.04.2005

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt. 

}

unit constant;

{$I directives.inc}

interface

const {die GUID f�r cdrtfe}
      CdrtfeClassID    : string = '{23ADD0C0-5A56-11D7-B55C-00E07D907FE2}';

      {Default-Werte f�r Gr��e und Breite}
      dWidth         = 753;
      dHeight        = 494;
      dWidthBigFont  = 923;
      dHeightBigFont = 610;

      {f�r KeyPress-Events}
      EnterKey = #13;
      NoKey    = #00;

      {f�r feoutput.pas}
      CR       = #13;
      LF       = #10;
      CRLF     = #13#10;
      BckSp    = #8;

      {f�r das Abschalten der TreeView-Tooltips}
      TVS_NoTooltips = $80;

      {f�r TSettings.General.Choice und TAction}
      cDataCD         = 1;
      cAudioCD        = 2;
      cXCD            = 3;
      cCDRW           = 4;
      cCDInfos        = 5;
      cDAE            = 6;
      cCDImage        = 7;
      cVideoCD        = 8;
      cDVDVideo       = 9;

      {f�r TAction und TVerifyThread}
      cDAEReadTOC     = 20;
      cFixCD          = 21;
      cVerify         = 22;
      cVerifyXCD      = 23;
      cFindDuplicates = 24;
      cCreateInfoFile = 25;
      cNoAction       = 0;

      {f�r TSettings.General.TabFrmSettings}
      cCdrtfe    = 1;
      cCdrecord  = 2;
      cCdrecord2 = 3;
      cCdrdao    = 4;

      {Standard-Puffergr��e}
      cBufSize = $800;

      {Programmnamen}
      cCdrecordBin     : string = '\cdrecord';
      cMkisofsBin      : string = '\mkisofs';
      cCdda2wavBin     : string = '\cdda2wav';
      cReadcdBin       : string = '\readcd';
      cShBin           : string = '\sh';
      cMode2CDMakerBin : string = '\mode2cdmaker';
      cVCDImagerBin    : string = '\vcdimager';
      cCdrdaoBin       : string = '\cdrdao';
      cMadplayBin      : string = '\madplay';

      {Dateinamen}
      cCdrtfeShlExDll  : string = '\cdrtfeShlEx.dll';
      cPathListFile    : string = '\pathlist.txt';
      cCDTextFile      : string = '\cdtext.dat';
      cShCmdFile       : string = '\cmd.cdr';
      cXCDInfoFile     : string = '\xcd.crc';
      cXCDParamFile    : string = '\xcd.txt';
      cIniFile         : string = '\cdrtfe.ini';
      cM2F2ExtractBin  : string = '\m2f2extract.exe';
      cDat2FileBin     : string = '\dat2file.exe';
      cD2FGuiBin       : string = '\d2fgui.exe';
      cCygwin1Dll      : string = 'cygwin1.dll';

      {Dateiendungen}
      cExtExe          : string = '.exe';
      cExtBin          : string = '.bin';
      cExtCue          : string = '.cue';
      cExtToc          : string = '.toc';
      cExtIso          : string = '.iso';                        

      {Orndernamen}
      cDataDir         : string = '\cdrtfe';

      {Umgebungsvariablen}
      cCDRSEC          : string = 'CDR_SECURITY';
      cComSpec         : string = 'ComSpec';

type {Richtungsangaben beim Verschieben von Tracks}
     TDirection = (dUp, dDown);
     TOnOff     = (oOn, oOff);

implementation

end.
