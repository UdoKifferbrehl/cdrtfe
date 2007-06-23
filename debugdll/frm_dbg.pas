{ cdrtfedbg: cdrtools/Mode2CDMaker/VCDImager Frontend, Debug-DLL

  frm_dbg.pas: Debug-Fenster

  Copyright (c) 2007 Oliver Valencia

  letzte Änderung  23.06.2007

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

}

unit frm_dbg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls;

type
  TFormDebug = class(TForm)
    PageControl1: TPageControl;
    TabSheet1   : TTabSheet;
    MemoLog     : TMemo;
    ButtonSaveLog: TButton;
    SaveDialog1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure ButtonSaveLogClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}


{ FormCreate -------------------------------------------------------------------

  Position festlegen.                                                          }

procedure TFormDebug.FormCreate(Sender: TObject);
begin
  Top  := 0;
  Left := 0;
end;

{ ButtonSaveLogClick -----------------------------------------------------------

  Inhalt des Memos speichern.                                                  }

procedure TFormDebug.ButtonSaveLogClick(Sender: TObject);
begin
  SaveDialog1 := TSaveDialog.Create(Self);
  SaveDialog1.FileName := 'cdrtfelog.txt';
  SaveDialog1.DefaultExt := 'txt';
  SaveDialog1.Filter := '(*.txt)|*.txt';
  SaveDialog1.Options := [ofOverwritePrompt,ofHideReadOnly];
  if SaveDialog1.Execute then
  begin
    MemoLog.Lines.SaveToFile(SaveDialog1.FileName);
  end;
  SaveDialog1.Free;
end;

end.
