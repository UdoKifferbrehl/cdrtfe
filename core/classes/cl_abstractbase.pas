{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_abstractbase.pas: abstrakte Basisklassen für Einstellungen

  Copyright (c) 2009-2010 Oliver Valencia

  letzte Änderung  15.05.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_abstractbase.pas implementiert abstrakte Basisklassen für die Speicherung
  von Daten und Einstellungen.

  TCdrtfeData ist ein Objekt für die Speicherung von Daten, die nur während der
  Laufzeit des Programms benötigt werden. Es enthält eine abstrakte Methode für
  die Initialisierung der Variablen.


  TCdrtfeData

    Methoden     Init


  TCdrtfeSettings ist ein Objekt für die Speicherung von Einstellungen, die in
  einer Ini- bzw. cfp-Datei gespeichert werden können. Es ist von TCdrtfeData
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
