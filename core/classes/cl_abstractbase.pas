{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_abstractbase.pas: abstrakte Basisklassen f�r Einstellungen

  Copyright (c) 2009-2010 Oliver Valencia

  letzte �nderung  15.05.2010

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.

  cl_abstractbase.pas implementiert abstrakte Basisklassen f�r die Speicherung
  von Daten und Einstellungen.

  TCdrtfeData ist ein Objekt f�r die Speicherung von Daten, die nur w�hrend der
  Laufzeit des Programms ben�tigt werden. Es enth�lt eine abstrakte Methode f�r
  die Initialisierung der Variablen.


  TCdrtfeData

    Methoden     Init


  TCdrtfeSettings ist ein Objekt f�r die Speicherung von Einstellungen, die in
  einer Ini- bzw. cfp-Datei gespeichert werden k�nnen. Es ist von TCdrtfeData
  abgeleitet. Es beinhaltet zwei abstrakte Methoden zum Lesen und Speichern der
  Einstellungen.


  TCdrtfeSettings

    Properties   SaveAsInifile

    Methoden     Init
                 Load(MIF: TMemIniFile)
                 Save(MIF: TMemIniFile)

}

unit cl_abstractbase;

interface

uses Inifiles;

type TCdrtfeData = class(TObject)
     private
     public
       procedure Init; virtual; abstract;
     end;

     TCdrtfeSettings = class(TCdrtfeData)
     private
     protected
       FAsInifile: Boolean;
     public
       constructor Create;
       procedure Load(MIF: TMemIniFile); virtual; abstract;
       procedure Save(MIF: TMemIniFile); virtual; abstract;
       property AsInifile: Boolean write FAsInifile;
     end;

implementation

{ TCdrtfeSettings ------------------------------------------------------------ }

{ TCdrtfeSettings - private }

{ TCdrtfeSettings - public }

constructor TCdrtfeSettings.Create;
begin
  inherited Create;
  FAsInifile := False;
end;


end.
