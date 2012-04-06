{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  compiler.inc: Symbol-Definitionen

  Copyright (c) 2006, 2010 Oliver Valencia

  letzte Änderung  30.09.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

}

(* ---------------------------------------------------------- Delphiversionen *)

{$IFDEF VER80}
  {$DEFINE Delphi1}
{$ENDIF}

{$IFDEF VER90}
  {$DEFINE Delphi2}
{$ENDIF}

{$IFDEF VER100}
  {$DEFINE Delphi3}
{$ENDIF}

{$IFDEF VER120}
  {$DEFINE Delphi4}
{$ENDIF}

{$IFDEF VER130}
  {$DEFINE Delphi5}
{$ENDIF}

{$IFDEF VER140}
  {$DEFINE Delphi6}
{$ENDIF}

{$IFDEF VER150}
  {$DEFINE Delphi7}
{$ENDIF}

{$IFDEF VER160}
  {$DEFINE Delphi8}
{$ENDIF}

{$IFDEF VER170}
  {$DEFINE Delphi2005}
{$ENDIF}

{$IFDEF VER180}
  {$DEFINE Delphi2006}
{$ENDIF}

{$IFDEF VER185}
  {$DEFINE Delphi2007}
{$ENDIF}

{$IFDEF VER200}
  {$DEFINE Delphi2009}
{$ENDIF}

{$IFDEF VER210}
  {$DEFINE Delphi2010}
{$ENDIF}

{$IFDEF VER220}
  {$DEFINE DelphiXE}
{$ENDIF}

{$IFDEF VER230}
  {$DEFINE DelphiXE2}
{$ENDIF}

(* -------------------------------------------------------------------------- *)

{$DEFINE Delphi3Up}
{$DEFINE Delphi4Up}
{$DEFINE Delphi5Up}
{$DEFINE Delphi6Up}
{$DEFINE Delphi7Up}
{$DEFINE Delphi8Up}
{$DEFINE Delphi2005Up}
{$DEFINE Delphi2006Up}
{$DEFINE Delphi2007Up}
{$DEFINE Delphi2009Up}
{$DEFINE Delphi2010Up}
{$DEFINE DelphiXEUp}
{$DEFINE DelphiXE2Up}

{$IFDEF Delphi3}
  {$UNDEF Delphi4Up}
  {$UNDEF Delphi5Up}
  {$UNDEF Delphi6Up}
  {$UNDEF Delphi7Up}
  {$UNDEF Delphi8Up}
  {$UNDEF Delphi2005Up}
  {$UNDEF Delphi2006Up}
  {$UNDEF Delphi2007Up}
  {$UNDEF Delphi2009Up}
  {$UNDEF Delphi2010Up}
  {$UNDEF DelphiXEUp}
  {$UNDEF DelphiXE2Up}
{$ENDIF}

{$IFDEF Delphi4}
  {$UNDEF Delphi5Up}
  {$UNDEF Delphi6Up}
  {$UNDEF Delphi7Up}
  {$UNDEF Delphi8Up}
  {$UNDEF Delphi2005Up}
  {$UNDEF Delphi2006Up}
  {$UNDEF Delphi2007Up}
  {$UNDEF Delphi2009Up}
  {$UNDEF Delphi2010Up}
  {$UNDEF DelphiXEUp}
  {$UNDEF DelphiXE2Up}
{$ENDIF}

{$IFDEF Delphi5}
  {$UNDEF Delphi6Up}
  {$UNDEF Delphi7Up}
  {$UNDEF Delphi8Up}
  {$UNDEF Delphi2005Up}
  {$UNDEF Delphi2006Up}
  {$UNDEF Delphi2007Up}
  {$UNDEF Delphi2009Up}
  {$UNDEF Delphi2010Up}
  {$UNDEF DelphiXEUp}
  {$UNDEF DelphiXE2Up}
{$ENDIF}

{$IFDEF Delphi6}
  {$UNDEF Delphi7Up}
  {$UNDEF Delphi8Up}
  {$UNDEF Delphi2005Up}
  {$UNDEF Delphi2006Up}
  {$UNDEF Delphi2007Up}
  {$UNDEF Delphi2009Up}
  {$UNDEF Delphi2010Up}
  {$UNDEF DelphiXEUp}
  {$UNDEF DelphiXE2Up}
{$ENDIF}

{$IFDEF Delphi7}
  {$UNDEF Delphi8Up}
  {$UNDEF Delphi2005Up}
  {$UNDEF Delphi2006Up}
  {$UNDEF Delphi2007Up}
  {$UNDEF Delphi2009Up}
  {$UNDEF Delphi2010Up}
  {$UNDEF DelphiXEUp}
  {$UNDEF DelphiXE2Up}
{$ENDIF}

{$IFDEF Delphi8}
  {$UNDEF Delphi2005Up}
  {$UNDEF Delphi2006Up}
  {$UNDEF Delphi2007Up}
  {$UNDEF Delphi2009Up}
  {$UNDEF Delphi2010Up}
  {$UNDEF DelphiXEUp}
  {$UNDEF DelphiXE2Up}
{$ENDIF}

{$IFDEF Delphi2005}
  {$UNDEF Delphi2006Up}
  {$UNDEF Delphi2007Up}
  {$UNDEF Delphi2009Up}
  {$UNDEF Delphi2010Up}
  {$UNDEF DelphiXEUp}
  {$UNDEF DelphiXE2Up}
{$ENDIF}


{$IFDEF Delphi2006}
  {$UNDEF Delphi2007Up}
  {$UNDEF Delphi2009Up}
  {$UNDEF Delphi2010Up}
  {$UNDEF DelphiXEUp}
  {$UNDEF DelphiXE2Up}
{$ENDIF}

{$IFDEF Delphi2007}
  {$UNDEF Delphi2009Up}
  {$UNDEF Delphi2010Up}
  {$UNDEF DelphiXEUp}
  {$UNDEF DelphiXE2Up}
{$ENDIF}

{$IFDEF Delphi2009}
  {$UNDEF Delphi2010Up}
  {$UNDEF DelphiXEUp}
  {$UNDEF DelphiXE2Up}
{$ENDIF}

{$IFDEF Delphi2010}
  {$UNDEF DelphiXEUp}
  {$UNDEF DelphiXE2Up}
{$ENDIF}

{$IFDEF DelphiXE}
  {$UNDEF DelphiXE2Up}
{$ENDIF}


(* ---------------------------------------------------- Direktiven für cdrtfe *)

(* ----------------------------------------------------- Warnungen abschalten *)

{$IFDEF Delphi7Up}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_DEPRECATED OFF}
  {$WARN SYMBOL_PLATFORM OFF}
  {$WARN UNSAFE_CODE OFF}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_CAST OFF}
{$ENDIF}

