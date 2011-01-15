{ cdrtfedbg: cdrtools/Mode2CDMaker/VCDImager Frontend, Debug-DLL

  frm_dbg.pas: Debug-Fenster

  Copyright (c) 2007-2011 Oliver Valencia

  letzte Änderung  15.01.2011

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
    CheckBoxAutoSave: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure ButtonSaveLogClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FLogFileName: string;
    FAutoSave   : Boolean;
  public
    { Public declarations }
    property LogFileName: string read FLogFileName write FLogFileName;
    property AutoSave: Boolean read FAutoSave write FAutoSave;
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
  FAutoSave := False;
end;

{ FormShow ---------------------------------------------------------------------

  Controls in Abhängigkeit der Initialisierungen aktulaisieren.                }

procedure TFormDebug.FormShow(Sender: TObject);
begin
  CheckBoxAutoSave.Enabled := FLogFileName <> '';
  CheckBoxAutoSave.Checked := CheckBoxAutoSave.Enabled and FAutoSave;
end;

{ FormClose --------------------------------------------------------------------

  Aktionen beim Schließen des Fensters.                                        }

procedure TFormDebug.FormClose(Sender: TObject; var Action: TCloseAction);
var Text: string;
    i   : Integer;
begin
  if CheckBoxAutoSave.Checked then
  begin
    try
      MemoLog.Lines.SaveToFile(FLogFileName);
    except
      on Exception do
      begin
        Text := 'Error writing log to ' + #13#10 +
                '''' + FLogFileName + '''.' + #13#10 +
                'Click ''OK'' to select another location or ''Cancel'' to ' +
                'quit anyway.';
        i := MessageBox(Self.Handle, PChar(Text), 'Error', MB_OkCancel);
        if i = 1 then ButtonSaveLogClick(nil);        
      end;
    end;
  end;
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
  SaveDialog1.Options := [ofOverwritePrompt, ofHideReadOnly];
  if SaveDialog1.Execute then
  begin
    MemoLog.Lines.SaveToFile(SaveDialog1.FileName);
  end;
  SaveDialog1.Free;
end;

end.
