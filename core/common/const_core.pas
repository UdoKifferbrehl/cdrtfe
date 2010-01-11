{ $Id: const_core.pas,v 1.1 2010/01/11 06:37:38 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  const_core.pas: Konstanten-Deklaration

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte �nderung  06.01.2010

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt. 

}

unit const_core;

{$I directives.inc}

interface

const {die GUID f�r cdrtfe}
      CdrtfeClassID    : string = '{23ADD0C0-5A56-11D7-B55C-00E07D907FE2}';

      {ListViews, z�hlt von Nulll an!}
      cLVCount       = 5;
      cLVMaxColCount = 3;

      {Default-Werte f�r Gr��e und Breite}
      dWidth         = 753;
      dHeight        = 532; //494;
      dWidthBigFont  = 923;
      dHeightBigFont = 648; //610;

type {Richtungsangaben beim Verschieben von Tracks}
     TDirection = (dUp, dDown);

     {Zustandd ein/aus}
     TOnOff     = (oOn, oOff);

implementation

end.
