{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  const_locations.pas: Konstanten-Deklaration, Dateinamen und Ordner

  Copyright (c) 2004-2015 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  05.12.2015

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt. 

}

unit const_locations;

{$I directives.inc}

interface

const {Dateinamen - Kommandozeilenprogramme}
      {$J+}
      cCdrecordBin     : string = '\cdrecord';
      cMkisofsBin      : string = '\mkisofs';
      cCdda2wavBin     : string = '\cdda2wav';
      cReadcdBin       : string = '\readcd';
      cISOInfoBin      : string = '\isoinfo';
      cShBin           : string = '\sh';
      cMode2CDMakerBin : string = '\mode2cdmaker';
      cVCDImagerBin    : string = '\vcdimager';
      cCdrdaoBin       : string = '\cdrdao';
      cMPG123Bin       : string = '\mpg123';
      cLameBin         : string = '\lame';
      cOggdecBin       : string = '\oggdec';
      cOggencBin       : string = '\oggenc';
      cFLACBin         : string = '\flac';
      cMonkeyBin       : string = '\mac';
      cWavegainBin     : string = '\wavegain';      
      cRrencBin        : string = '\rrenc';
      cRrdecBin        : string = '\rrdec';
      {$J-}

      {Dateinamen - Tools/DLLs}
      cCdrtfeShlExDll  : string = '\cdrtfeShlEx.dll';
      cCdrtfeShlExDll64: string = '\cdrtfeShlEx64.dll';
//    cCdrtfeResDll    : string = '\cdrtferes.dll';
      cCdrtfeHelper    : string = '\cdrtfeHelper.exe';
      {$J+}
      cM2F2ExtractBin  : string = '\m2f2extract.exe';
      cDat2FileBin     : string = '\dat2file.exe';
      cD2FGuiBin       : string = '\d2fgui.exe';
      cCygwin1Dll      : string = 'cygwin1.dll';
      cCygPathPref     : string = '\cygpathprefix.exe';
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
      cIniCygwin       : string = '\cygwin.ini';
      cHelpFile        : string = '\cdrtfe_';
      cDefaultIsoName  : string = '\image';
      cDummyFile       : string = '\cdrtfe.del';
      cMkisofsRCFile   : string = '.mkisofsrc';
      cLangFileName    : string = '\cdrtfe_lang.ini';

      {Ordnernamen}
      cDataDir         : string = '\cdrtfe';
      cIconDir         : string = '\icons';
      cDummyDir        : string = '\dummy';
      cToolDir         : string = '\tools';
      cCdrtoolsDir     : string = '\cdrtools';
      cSoundDir        : string = '\sound';
      cXCDDir          : string = '\xcd';
      cVCDImagerDir    : string = '\vcdimager';
      cCygwinDir       : string = '\cygwin';
      cCdrdaoDir       : string = '\cdrdao';
      cSiconvDir       : string = '\siconv';
      cLangDir         : string = '\translations';
      cHelpDir         : string = '\help';
      cHelperDir       : string = '\helper';

      {Umgebungsvariablen}
      cCDRSEC          : string = 'CDR_SECURITY';
      cMKISOFSRC       : string = 'MKISOFSRC';
      cComSpec         : string = 'ComSpec';

implementation

end.
