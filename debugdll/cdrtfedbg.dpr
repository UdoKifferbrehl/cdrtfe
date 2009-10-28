{ cdrtfedbg: cdrtools/Mode2CDMaker/VCDImager Frontend, Debug-DLL

  cdrtfedbg.dpr: Debug-DLL

  Copyright (c) 2007-2009 Oliver Valencia

  letzte Änderung  23.09.2009

  This program is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free Software
  Foundation; either version 2 of the License, or (at your option) any later
  version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. See the file license.txt and the GNU General Public
  License for more details.


  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License, wie von der Free Software Foundation ver-
  öffentlicht, weitergeben und/oder modifizieren, entweder gemäß Version 2 der
  Lizenz oder (nach Ihrer Option) jeder späteren Version.

  Die Veröffentlichung dieses Programms erfolgt in der Hoffnung, daß es Ihnen
  von Nutzen sein wird, aber OHNE IRGENDEINE GARANTIE, sogar ohne die implizite
  Garantie der MARKTREIFE oder der VERWENDBARKEIT FÜR EINEN BESTIMMTEN ZWECK.
  Details finden Sie in der Datei license.txt und in der GNU General Public
  License.

}

library cdrtfedbg;

uses
  Forms,
  Windows,
  frm_dbg in 'frm_dbg.pas' {FormDebug},
  f_dllfuncs in 'f_dllfuncs.pas',
  f_log in 'f_log.pas',
  f_logstrings in 'f_logstrings.pas',
  f_timer in 'f_timer.pas';

{$R *.RES}

exports
  SetLogFile,
  SetAutoSave,
  InitDebugForm,
  ShowDebugForm,
  FreeDebugForm,  
  AddLogStr,
  AddLogPreDef;

begin
end.
