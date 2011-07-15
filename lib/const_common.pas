{ const_common.pas: allgemeine Konstanten-Deklaration

  Copyright (c) 2004-2011 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte �nderung  11.07.2008

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt. 

}

unit const_common;

{$I directives.inc}

interface

const {f�r KeyPress-Events}
      EnterKey = #13;
      NoKey    = #00;

      {Character codes}
      CR       = #13;
      LF       = #10;
      CRLF     = #13#10;
      BckSp    = #8;

      {f�r das Abschalten der TreeView-Tooltips}
      TVS_NoTooltips = $80;

      {Standard-Puffergr��e}
      cBufSize = $40000; //$800;

      {Dateiendungen}
      cExtExe          : string = '.exe';
      cExtBin          : string = '.bin';
      cExtCue          : string = '.cue';
      cExtToc          : string = '.toc';
      cExtIso          : string = '.iso';
      cExtWav          : string = '.wav';
      cExtMP3          : string = '.mp3';
      cExtOgg          : string = '.ogg';
      cExtFlac         : string = '.flac';
      cExtApe          : string = '.ape';
      cExtM3u          : string = '.m3u';
      cExtUm2          : string = '.um2';
      cExtBMP          : string = '.bmp';
      cExtChm          : string = '.chm';

      {Win32 Error Sources}
      cCreateProcess   : string = 'CreateProcess()';

implementation

end.
