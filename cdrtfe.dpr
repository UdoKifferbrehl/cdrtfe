{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cdrtfe.dpr: Hauptprogramm

  Copyright (c) 2004-2015 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  27.11.2015

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

program cdrtfe;

{$I directives.inc}

{$SetPEOptFlags $0140} // enable DEP and ASLR

uses
  Forms,
  f_logfile in 'lib\misc\f_logfile.pas',
  frm_main in 'forms\frm_main.pas' {CdrtfeMainForm},
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
  frm_dae_options in 'forms\frm_dae_options.pas' {FormDAEOptions},
  frm_splash_screen in 'forms\frm_splash_screen.pas' {FormSplashScreen},
  cl_lang in 'core\classes\cl_lang.pas',
  cl_abstractbase in 'core\classes\cl_abstractbase.pas',
  cl_settings in 'core\classes\cl_settings.pas',
  cl_settings_general in 'core\classes\cl_settings_general.pas',
  cl_settings_winpos in 'core\classes\cl_settings_winpos.pas',
  cl_settings_fileexplorer in 'core\classes\cl_settings_fileexplorer.pas',
  cl_settings_cmdlineflags in 'core\classes\cl_settings_cmdlineflags.pas',
  cl_settings_fileflags in 'core\classes\cl_settings_fileflags.pas',
  cl_settings_environment in 'core\classes\cl_settings_environment.pas',
  cl_settings_drives in 'core\classes\cl_settings_drives.pas',
  cl_settings_hacks in 'core\classes\cl_settings_hacks.pas',
  cl_settings_cdrdao in 'core\classes\cl_settings_cdrdao.pas',
  cl_settings_cdrecord in 'core\classes\cl_settings_cdrecord.pas',
  cl_settings_datacd in 'core\classes\cl_settings_datacd.pas',
  cl_settings_audiocd in 'core\classes\cl_settings_audiocd.pas',
  cl_settings_xcd in 'core\classes\cl_settings_xcd.pas',
  cl_settings_cdrw in 'core\classes\cl_settings_cdrw.pas',
  cl_settings_cdinfo in 'core\classes\cl_settings_cdinfo.pas',
  cl_settings_dae in 'core\classes\cl_settings_dae.pas',
  cl_settings_image in 'core\classes\cl_settings_image.pas',
  cl_settings_readcd in 'core\classes\cl_settings_readcd.pas',
  cl_settings_videocd in 'core\classes\cl_settings_videocd.pas',
  cl_settings_dvdvideo in 'core\classes\cl_settings_dvdvideo.pas',
  cl_projectdata in 'core\classes\cl_projectdata.pas',
  cl_projectdata_datacd in 'core\classes\cl_projectdata_datacd.pas',
  cl_projectdata_xcd in 'core\classes\cl_projectdata_xcd.pas',
  cl_projectdata_dvdvideo in 'core\classes\cl_projectdata_dvdvideo.pas',
  cl_projectdata_audiocd in 'core\classes\cl_projectdata_audiocd.pas',
  cl_projectdata_videocd in 'core\classes\cl_projectdata_videocd.pas',
  cl_projectdata_dae in 'core\classes\cl_projectdata_dae.pas',
  cl_abstractbaseaction in 'core\classes\cl_abstractbaseaction.pas',
  cl_action in 'core\classes\cl_action.pas',
  cl_action_cdinfo in 'core\classes\cl_action_cdinfo.pas',
  cl_action_fixate in 'core\classes\cl_action_fixate.pas',
  cl_action_erase in 'core\classes\cl_action_erase.pas',
  cl_action_daereadtoc in 'core\classes\cl_action_daereadtoc.pas',
  cl_action_daegrabtracks in 'core\classes\cl_action_daegrabtracks.pas',
  cl_action_image in 'core\classes\cl_action_image.pas',
  cl_action_audiocd in 'core\classes\cl_action_audiocd.pas',
  cl_action_videocd in 'core\classes\cl_action_videocd.pas',
  cl_action_dvdvideo in 'core\classes\cl_action_dvdvideo.pas',
  cl_action_datacd in 'core\classes\cl_action_datacd.pas',
  cl_action_xcd in 'core\classes\cl_action_xcd.pas',
  cl_cdrtfedata in 'core\common\cl_cdrtfedata.pas',
  cl_cmdlineparser in 'core\common\cl_cmdlineparser.pas',
  cl_devices in 'core\common\cl_devices.pas',
  cl_imagelists in 'core\common\cl_imagelists.pas',
  cl_logwindow in 'core\common\cl_logwindow.pas',
  const_core in 'core\common\const_core.pas',
  const_glyphs in 'core\common\const_glyphs.pas',
  const_locations in 'core\common\const_locations.pas',
  const_tabsheets in 'core\common\const_tabsheets.pas',
  f_locations in 'core\common\f_locations.pas',
  userevents in 'core\common\userevents.pas',
  usermessages in 'core\common\usermessages.pas',
  cl_actionthread in 'core\exec\cl_actionthread.pas',
  cl_verifythread in 'core\exec\cl_verifythread.pas',
  f_getdosoutput in 'core\exec\f_getdosoutput.pas',
  cl_cueinfo in 'core\funcs\cl_cueinfo.pas',
  cl_diskinfo in 'core\funcs\cl_diskinfo.pas',
  cl_sessionimport in 'core\funcs\cl_sessionimport.pas',
  f_cdtext in 'core\funcs\f_cdtext.pas',
  f_checkproject in 'core\funcs\f_checkproject.pas',
  f_init in 'core\funcs\f_init.pas',
  f_foldernamecache in 'core\funcs\f_foldernamecache.pas',
  f_cygwin in 'core\misc\f_cygwin.pas',
  f_dischelper in 'core\misc\f_dischelper.pas',
  f_helper in 'core\misc\f_helper.pas',
  f_shellext in 'core\misc\f_shellext.pas',
  c_frametopbanner in 'frames\c_frametopbanner.pas' {FrameTopBanner: TFrame},
  const_common in 'lib\const_common.pas',
  cl_tree in 'lib\datastructures\cl_tree.pas',
  cl_devicechange in 'lib\devices\cl_devicechange.pas',
  cl_deviceenum in 'lib\devices\cl_deviceenum.pas',
  c_filebrowser in 'lib\files\c_filebrowser.pas',
  cl_filetypeinfo in 'lib\files\cl_filetypeinfo.pas',
  cl_peheader in 'lib\files\cl_peheader.pas',
  dlg_folderbrowse in 'lib\files\dlg_folderbrowse.pas',
  f_filesystem in 'lib\files\f_filesystem.pas',
  cl_timecount in 'lib\misc\cl_timecount.pas',
  f_commandline in 'lib\misc\f_commandline.pas',
  f_compprop in 'lib\misc\f_compprop.pas',
  f_crc in 'lib\misc\f_crc.pas',
  f_crc_tab in 'lib\misc\f_crc_tab.pas',
  f_treelistfuncs in 'lib\misc\f_treelistfuncs.pas',
  f_window in 'lib\misc\f_window.pas',
  cl_apeinfo in 'lib\multimedia\cl_apeinfo.pas',
  cl_flacinfo in 'lib\multimedia\cl_flacinfo.pas',
  cl_mpeginfo in 'lib\multimedia\cl_mpeginfo.pas',
  cl_mpegvinfo in 'lib\multimedia\cl_mpegvinfo.pas',
  f_wavefiles in 'lib\multimedia\f_wavefiles.pas',
  cl_dosthread in 'lib\process\cl_dosthread.pas',
  f_instance in 'lib\process\f_instance.pas',
  f_process in 'lib\process\f_process.pas',
  f_stringlist in 'lib\strings\f_stringlist.pas',
  f_strings in 'lib\strings\f_strings.pas',
  f_environment in 'lib\system\f_environment.pas',
  f_largeint in 'lib\system\f_largeint.pas',
  f_screensaversup in 'lib\system\f_screensaversup.pas',
  f_wininfo in 'lib\system\f_wininfo.pas',
  f_system in 'lib\system\f_system.pas',
  cl_exceptionlog in 'import\exceptionlog\cl_exceptionlog.pas',
  frm_exceptdlg in 'import\exceptionlog\frm_exceptdlg.pas',
  c_spacemeter in 'import\spacemeter\c_spacemeter.pas',
  QProgBar in 'import\spacemeter\QProgBar.pas',
  w32waves in 'import\w32waves.pas',
  atl_oggvorbis in 'import\atl_oggvorbis.pas',
  frm_maoutput in 'forms\frm_maoutput.pas' {FormMAOutput};

{ verwendete externe Komponenten/Units:
  -------------------------------------
  W32Waves           : by Ulli Conrad
  atl_oggvorbis.pas  : Copyright (c) 2001 by Jurgen Faul.
  DropTarget.pas,
  DropSource.pas     : © 1997-2005 Angus Johnson & Anders Melander
  JCL                : Project JEDI, http://jvcl.sourceforge.net/
  QProgBar.pas       : Copyright © 2004 by Olivier Touzot "QnnO"
  Vampyre Imaging Lib: © 2004-2007 Marek Mauder
}

{$R *.RES}

begin
  {$IFDEF WriteLogfile} AddLog('Application.Initialize', 0); {$ENDIF}
  FormSplashScreen := TFormSplashScreen.Create(Application) ;
  if not IsAlreadyRunning then FormSplashScreen.ShowEx;
  Application.Initialize;
  FormSplashScreen.UpdateEx;
  {$IFDEF WriteLogfile} AddLog('Application.CdrtfeMainForm' + CRLF, 0); {$ENDIF}
    Application.CreateForm(TCdrtfeMainForm, CdrtfeMainForm);
  FormSplashScreen.HideEx;
  FormSplashScreen.Free;
  {$IFDEF WriteLogfile} AddLog('Application.Run' + CRLF, 0); {$ENDIF}
  Application.Run;
end.