{ $Id: cl_projectdata_dvdvideo.pas,v 1.1 2010/05/18 17:01:59 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_projectdata_dvdvideo.pas: Datentypen zur Speicherung der Pfadlisten

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  18.05.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_projectdata_dvdvideo.pas implementiert das Objekt, in dem die zu dem
  Projekt DVDVideo hinzugefügten Dateien und Verzeichnisse gespeichert werden.
  Als Grundlage wird eine Baumstruktur verwendet, die von cl_tree.pas zur
  Verfügung gestellt wird.


  TDVDVideo: wie TCD, zusätzlich

    Properties   SourcePath: string

    Methoden     Create

}

unit cl_projectdata_dvdvideo;

{$I directives.inc}

interface

uses Classes, SysUtils, const_core, cl_projectdata_datacd;

type TDVDVideo = class(TCD)
     private
       FSourcePath: string;
       procedure SetSourcePath(Path: string);
     public
       constructor Create;
       property SourcePath: string read FSourcePath write SetSourcePath;
     end;

implementation

// uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}

{ TDVDVideo ------------------------------------------------------------------ }

{ TDVDVideo - private }

procedure TDVDVideo.SetSourcePath(Path: string);
var SearchRec  : TSearchRec;
begin
  FSourcePath := Path;
  DeleteAll;
  {Jetzt muß der Inhalt des Quellordners zum Wurzelverzeichnis hinzugefügt
   werden.}
  if FSourcePath[Length(FSourcePath)] <> '\' then
  begin
    FSourcePath := FSourcePath + '\';
  end;
  if FindFirst(FSourcePath + '*.*',
               faDirectory or faAnyFile, SearchRec) = 0 then
  begin
    repeat
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
      begin
        AddFile(FSourcePath + SearchRec.Name, '');
        {$IFDEF DebugDVDVideoLists}
        Deb(SearchRec.Name, 1);
        {$ENDIF}
      end;
    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
  end;
end;

{ TDVDVideo - public }

constructor TDVDVideo.Create;
begin
  inherited Create;
  FSourcePath := '';
end;

end.
