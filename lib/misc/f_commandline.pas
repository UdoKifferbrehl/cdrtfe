{ $Id: f_commandline.pas,v 1.1 2010/01/11 06:37:39 kerberos002 Exp $

  f_commandline.pas: Aufrufparameter auswerten

  Copyright (c) 2008      Oliver Valencia

  letzte �nderung  02.10.2008

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.  

  f_commandline.pas stellt Funktionen zur Verf�gung:
    * Startparameter


  exportierte Funktionen/Prozeduren:

    CheckCommandLineSwitch(const Switch: string): Boolean

}

unit f_commandline;

{$I directives.inc}

interface

uses SysUtils;

function CheckCommandLineSwitch(const Switch: string): Boolean;

implementation

{ CheckCommandLineSwitch -------------------------------------------------------

  True, wenn /Switch als Startparameter �bergeben wurde.                       }

function CheckCommandLineSwitch(const Switch: string): Boolean;
var i: Integer;
begin
  i := 1;
  repeat
    Result := LowerCase(Switch) = LowerCase(ParamStr(i));
    Inc(i);
  until Result or (i > ParamCount)
end;

end.
