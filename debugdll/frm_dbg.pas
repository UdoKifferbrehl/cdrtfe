{ cdrtfedbg: cdrtools/Mode2CDMaker/VCDImager Frontend, Debug-DLL

  frm_dbg.pas: Debug-Fenster

  Copyright (c) 2007-2008 Oliver Valencia

  letzte Änderung  10.01.2008

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
    FLogFileName: string;
  public
    { Public declarations }
    property LogFileName: string read FLogFileName write FLogFileName;
  end;

implementation

{$R *.DFM}


{ FormCreate -------------------------------------------------------------------

  Position festlegen.                                                          }

procedure TFormDebug.FormCreate(Sender: TObject);
begin
  Top  := 0;
  Left := 0;
  FLogFileName := '';
end;

{ ButtonSaveLogClick -----------------------------------------------------------

  Inhalt des Memos speichern.                                                  }

procedure TFormDebug.ButtonSaveLogClick(Sender: TObject);
begin
  SaveDialog1 := TSaveDialog.Create(Self);
  if FLogFileName <> '' then
    SaveDialog1.FileName := FLogFileName
  else
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
