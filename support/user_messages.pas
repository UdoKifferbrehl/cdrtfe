{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  user_messages.pas: Deklaration von User-Messages

  Copyright (c) 2004-2005 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  20.02.2005

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

}

unit user_messages;

{$I directives.inc}

interface

uses Messages;

const WM_CDRTFE           = WM_APP;
      {Definition von Window Messages, mod by oli: 0-3}
      WM_UPDATEGAUGES     = WM_CDRTFE +  0;
      WM_ACTIVATEDATATAB  = WM_CDRTFE +  1;
      WM_ACTIVATEAUDIOTAB = WM_CDRTFE +  2;
      WM_ACTIVATEXCDTAB   = WM_CDRTFE +  3;
      WM_Execute          = WM_CDRTFE +  4;
      WM_TTerminated      = WM_CDRTFE +  5;
      WM_ExitAfterExec    = WM_CDRTFE +  6;
      WM_WriteLog         = WM_CDRTFE +  7;
      WM_CheckDataFS      = WM_CDRTFE +  8;
      WM_VTerminated      = WM_CDRTFE +  9;
      WM_ButtonsOff       = WM_CDRTFE + 10;
      WM_ButtonsOn        = WM_CDRTFE + 11;
      WM_Minimize         = WM_CDRTFE + 12;
      WM_FTerminated      = WM_CDRTFE + 13;
      WM_ITerminated      = WM_CDRTFE + 14;
      WM_ACTIVATEVCDTAB   = WM_CDRTFE + 15;
      {$IFDEF Experiment}
      WM_Experiment       = WM_CDRTFE + 20;
      {$ENDIF}

implementation

end.
