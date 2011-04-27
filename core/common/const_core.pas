{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  const_core.pas: Konstanten-Deklaration

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  16.08.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

}

unit const_core;

{$I directives.inc}

interface

uses Classes;

const {die GUID für cdrtfe}
      CdrtfeClassID    : string = '{23ADD0C0-5A56-11D7-B55C-00E07D907FE2}';
      CdrtfeClassID64  : string = '{23ADD0C0-5A56-11D7-B55C-00E07D907FE3}';

      {ListViews, zählt von Nulll an!}
      cLVCount       = 5;
      cLVMaxColCount = 3;

      {Default-Werte für Größe und Breite}
      dWidth         = 800; //753;
      dHeight        = 600; //532; //494;
      dWidthBigFont  = 923;
      dHeightBigFont = 648; //610;

      {Fehlercodes, Daten-Objekte}
      CD_NoError = 0;
      CD_FolderNotUnique = 1;
      CD_FileNotUnique = 2;
      CD_FileNotFound = 3;
      CD_DestFolderIsSubFolder = 4;
      CD_NameTooLong = 5;
      CD_InvalidName = 6;
      CD_InvalidWaveFile = 7;
      CD_InvalidLabel = 8;
      CD_InvalidMpegFile = 9;
      CD_InvalidMP3File = 10;
      CD_InvalidOggFile = 11;
      CD_InvalidFLACFile = 12;
      CD_NoMP3Support = 13;
      CD_NoOggSupport = 14;
      CD_NoFLACSupport = 15;
      CD_PreviousSession = 16;
      CD_InvalidApeFile = 17;
      CD_NoApeSupport = 18;

type {Richtungsangaben beim Verschieben von Tracks}
     TDirection = (dUp, dDown);

     {Zustandd ein/aus}
     TOnOff     = (oOn, oOff);

     {Zeiger auf StringList}
     TPList = ^TStringList;

implementation

end.
