{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  frm_debug.pas: Debugfenster

  Copyright (c) 2004 Oliver Valencia

  letzte Änderung  27.06.2004

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

}

unit frm_debug;

{$I directives.inc}

{$IFNDEF ShowDebugWindow}
interface
implementation
{$ELSE}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFormDebug = class(TForm)
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure Deb(const s: string; const Memo: Byte);

var
  FormDebug: TFormDebug;

implementation

{$R *.DFM}

procedure TFormDebug.Button1Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;
  Memo3.Lines.Clear;
end;

procedure Deb(const s: string; const Memo: Byte);
begin
  case Memo of
    1: FormDebug.Memo1.Lines.Add(s);
    2: FormDebug.Memo2.Lines.Add(s);
    3: FormDebug.Memo3.Lines.Add(s);
  end;
end;

{$ENDIF}

end.
