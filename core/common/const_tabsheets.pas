{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  const_tabsheets.pas: Konstanten-Deklaration f�r TabSheets

  Copyright (c) 2004-2012 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte �nderung  07.01.2012

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.

}

unit const_tabsheets;

{$I directives.inc}

interface

const TabSheetCount = 9;

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
      cVerifyDVDVideo = 26;
      cVerifyISOImage = 27;
      cNoAction       = 0;

      {f�r TSettings.General.TabFrmSettings}
      cCdrtfe    = 1;
      cCdrtfe2   = 2;
      cDrives    = 3;
      cCdrecord  = 4;
      cCdrecord2 = 5;
      cCdrdao    = 6;
      cCDAudio   = 7;
      cCygwin    = 8;

      {f�r TSettings.General.TabFrmDAE}
      cTabDAE    = 1;
      cTabCDDB   = 2;

      {f�r TSetting.General.TabFrmDCDFS}
      cTabFSGen     = 1;
      cTabFSISO     = 2;
      cTabFSSpecial = 3;

implementation

end.
