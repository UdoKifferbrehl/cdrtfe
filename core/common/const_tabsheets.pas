{ $Id: const_tabsheets.pas,v 1.3 2010/05/20 14:38:10 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  const_tabsheets.pas: Konstanten-Deklaration für TabSheets

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  20.05.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

}

unit const_tabsheets;

{$I directives.inc}

interface

const TabSheetCount = 9;

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
      cVerifyISOImage = 27;
      cNoAction       = 0;

      {für TSettings.General.TabFrmSettings}
      cCdrtfe    = 1;
      cCdrtfe2   = 2;
      cCdrecord  = 3;
      cCdrecord2 = 4;
      cCdrdao    = 5;
      cCDAudio   = 6;
      cCygwin    = 7;

      {für TSettings.General.TabFrmDAE}
      cTabDAE    = 1;
      cTabCDDB   = 2;

      {für TSetting.General.TabFrmDCDFS}
      cTabFSGen     = 1;
      cTabFSISO     = 2;
      cTabFSSpecial = 3;

implementation

end.
