{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  userevents.pas: Event-Deklaration

  Copyright (c) 2006-2009 Oliver Valencia

  letzte Änderung  08.11.2009

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt. 

}

unit userevents;

{$I directives.inc}

interface

type TMessageShowEvent = procedure(const s: string) of object;
     TProgressBarHideEvent = procedure(const PB: Integer) of object;
     TProgressBarShowEvent = procedure(const PB, Max: Integer) of object;
     TProgressBarUpdateEvent = procedure(const PB, Position: Integer) of object;
     TProjectErrorEvent = procedure (const ErrorCode: Byte; const Name: string) of object;
     TUpdatePanelsEvent = procedure(const s1, s2: string) of object;
 
implementation

end.
