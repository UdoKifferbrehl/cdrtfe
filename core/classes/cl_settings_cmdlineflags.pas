{ $Id: cl_settings_cmdlineflags.pas,v 1.1 2010/05/16 15:25:38 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_cmdlineflags.pas: Objekt für Kommandozeilenflags

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  15.05.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_cmdlineflags.pas implemtiert ein Objekt für die Kommandozeilen-
  flags.


  TCmdlineFlags

    Properties   ExecuteProject    : Boolean
                 ExitAfterExecution: Boolean
                 Hide              : Boolean
                 Minimize          : Boolean
                 WriteLogFile      : Boolean

    Methoden     Init

}

unit cl_settings_cmdlineflags;

interface

uses cl_abstractbase;

type TCmdlineFlags = class(TCdrtfeData)
     private
       FExecuteProject    : Boolean;
       FExitAfterExecution: Boolean;
       FHide              : Boolean;
       FMinimize          : Boolean;
       FWriteLogFile      : Boolean;
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       property ExecuteProject    : Boolean read FExecuteProject write FExecuteProject;
       property ExitAfterExecution: Boolean read FExitAfterExecution write FExitAfterExecution;
       property Hide              : Boolean read FHide write FHide;
       property Minimize          : Boolean read FMinimize write FMinimize;
       property WriteLogFile      : Boolean read FWriteLogFile write FWriteLogFile;
     end;

implementation

{ TCmdlineFlags -------------------------------------------------------------- }

{ TCmdlineFlags - private }

{ TCmdlineFlags - public }

constructor TCmdlineFlags.Create;
begin
  inherited Create;
  Init;
end;

destructor TCmdlineFlags.Destroy;
begin
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TCmdlineFLags.Init;
begin
  FExecuteProject     := False;
  FExitAfterExecution := False;
  FHide               := False;
  FMinimize           := False;
  FWriteLogFile       := False;
end;

end.
