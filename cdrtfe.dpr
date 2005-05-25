{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  cdrtfe.dpr: Hauptprogramm

  Copyright (c) 2004-2005 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  06.04.2005

  This program is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free Software
  Foundation; either version 2 of the License, or (at your option) any later
  version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

  
  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License, wie von der Free Software Foundation ver-
  öffentlicht, weitergeben und/oder modifizieren, entweder gemäß Version 2 der
  Lizenz oder (nach Ihrer Option) jeder späteren Version.

  Die Veröffentlichung dieses Programms erfolgt in der Hoffnung, daß es Ihnen
  von Nutzen sein wird, aber OHNE IRGENDEINE GARANTIE, sogar ohne die implizite
  Garantie der MARKTREIFE oder der VERWENDBARKEIT FÜR EINEN BESTIMMTEN ZWECK.
  Details finden Sie in der GNU General Public License.

}

program cdrtfe;

{$I directives.inc}

uses
  Forms,
  frm_main in 'forms\frm_main.pas' {Form1},
  frm_datacd_fs in 'forms\frm_datacd_fs.pas' {FormDataCDFS},
  frm_datacd_options in 'forms\frm_datacd_options.pas' {FormDataCDOptions},
  frm_settings in 'forms\frm_settings.pas' {FormSettings},
  frm_output in 'forms\frm_output.pas' {FormOutput},
  frm_datacd_fs_error in 'forms\frm_datacd_fs_error.pas' {FormDataCDFSError},
  frm_about in 'forms\frm_about.pas' {FormAbout},
  frm_debug in 'forms\frm_debug.pas' {FormDebug},
  frm_audiocd_options in 'forms\frm_audiocd_options.pas' {FormAudioCDOptions},
  frm_xcd_options in 'forms\frm_xcd_options.pas' {FormXCDOptions},
  frm_audiocd_tracks in 'forms\frm_audiocd_tracks.pas' {FormAudioCDTracks},
  frm_videocd_options in 'forms\frm_videocd_options.pas' {FormVideoCDOptions},
  cl_lang in 'classes\cl_lang.pas',
  cl_settings in 'classes\cl_settings.pas',
  cl_cd in 'classes\cl_cd.pas',
  cl_projectdata in 'classes\cl_projectdata.pas',
  cl_verifythread in 'classes\cl_verifythread.pas',
  cl_cmdlineparser in 'classes\cl_cmdlineparser.pas',
  cl_action in 'classes\cl_action.pas',
  cl_actionthread in 'classes\cl_actionthread.pas',
  cl_devices in 'classes\cl_devices.pas',
  f_cdtext in 'funcs\f_cdtext.pas',
  f_checkproject in 'funcs\f_checkproject.pas',
  f_init in 'funcs\f_init.pas',
  f_shellext in 'funcs\f_shellext.pas',
  f_helper in 'funcs\f_helper.pas',
  cl_tree in 'support\cl_tree.pas',
  cl_mpeginfo in 'support\cl_mpeginfo.pas',  
  f_misc in 'support\f_misc.pas',
  f_cygwin in 'support\f_cygwin.pas',
  f_strings in 'support\f_strings.pas',
  f_crc in 'support\f_crc.pas',
  f_crc_tab in 'support\f_crc_tab.pas',
  constant in 'support\constant.pas',
  user_messages in 'support\user_messages.pas',
  W32Waves in 'import\w32waves.pas',
  cl_filetypeinfo in 'system\cl_filetypeinfo.pas',
  cl_imagelists in 'system\cl_imagelists.pas',
  cl_peheader in 'system\cl_peheader.pas',
  f_largeint in 'system\f_largeint.pas',
  f_wininfo in 'system\f_wininfo.pas',
  f_environment in 'system\f_environment.pas',
  f_process in 'system\f_process.pas',
  f_filesystem in 'system\f_filesystem.pas';

{ verwendete externe Komponenten/Units:
  -------------------------------------
  W32Waves:          by Ulli Conrad
}

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
