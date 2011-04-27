{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  const_glyphs.pas: Konstanten-Deklaration, Icons und Glyphs

  Copyright (c) 2004-2008 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  01.10.2008

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt. 

}

unit const_glyphs;

{$I directives.inc}

interface

const {Icons/Glyphs}
      cGlyphCount      = 21;
      
      IconNames        : array[1..4] of string =
                           ('icon_folder_closed',
                            'icon_folder_opened',
                            'icon_cd',
                            'icon_audiotrack');

      GlyphNames       : array[1..cGlyphCount, 1..3] of string =
                           (('btn_load_file',      'B1', ''),
                            ('btn_load_folder',    'B2', ''),
                            ('btn_del_file',       'B3', ''),
                            ('btn_del_folder',     'B4', ''),
                            ('btn_del_all',        'B5', ''),
                            ('btn_check_fs',       'B6', ''),
                            ('btn_a_up',           'B7', ''),
                            ('btn_a_down',         'B8', ''),
                            ('btn_a_load_track',   'B1', '1'),
                            ('btn_a_del_track',    'B3', '3'),
                            ('btn_x_load_file_f1', 'B1', '1'),
                            ('btn_x_load_folder',  'B2', '2'),
                            ('btn_x_del_file_f1',  'B3', '3'),
                            ('btn_x_load_file_f2', 'B1', '1'),
                            ('btn_x_del_file_f2',  'B3', '3'),
                            ('btn_x_del_folder',   'B4', '4'),
                            ('btn_x_del_all',      'B5', '5'),
                            ('btn_v_up',           'B7', '7'),
                            ('btn_v_down',         'B8', '8'),
                            ('btn_v_load_track',   'B1', '1'),
                            ('btn_v_del_track',    'B3', '3'));

      cToolButtonCount = 6;

implementation

end.
