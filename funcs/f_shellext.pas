{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  f_shellext.pas: ShellExtensions registrieren/l�schen

  Copyright (c) 2004-2007 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte �nderung  19.05.2005

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.  

  f_shellext.pas stellt Funktionen f�r die ShellExtensions zur Verf�gung:
    * ShellExtemsions registrieren
    * Registry-Eintr�ge wieder entfernen
    * Pr�fen: Sind sie Shellextensions registriert


  exportierte Funktionen/Prozeduren:

    RegisterShellExtensions
    ShellExtensionsRegistered: Boolean;
    UnregisterShellExtensions

}

unit f_shellext;

{$I directives.inc}

interface

uses Forms, Windows, Registry, SysUtils;

function ShellExtensionsRegistered: Boolean;
procedure RegisterShellExtensions;
procedure UnregisterShellExtensions;

implementation

uses constant;

const CMHPath: string = '\shellex\ContextMenuHandlers\'; // cdrtfeShlEx';

{ ShellExtensionsRegistered ----------------------------------------------------

  Pr�ft anhand der Registry-Eintr�ge, ob die ShellExtensions registriert sind
  (Result = True) oder nicht (Result = False).                                 } 

function ShellExtensionsRegistered: Boolean;
var Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    {$IFDEF UseRegistryKeyExists}
    {Dies ist die einfache Variante, die aber bei MemProof einen Fehler hervor-
     ruft (key handle must be closed), obwohl kein Registry-Key-Handle zum
     Schlie�en �brig bleibt. Der Fehler wird durch RegOpenKeyEx in der Funktion
     TRegistry.GetKey ausgel�st, wenn der Registry-Zweig nicht vorhanden ist.
     Wahrscheinlich ist es nur ein kosmetisches Problem.}
    Result := Reg.KeyExists('\CLSID\' + CdrtfeClassID);
    {$ELSE}
    {In der alternativen Variante wird versucht den Registry-Zweig zu �ffnen.
     Falls er nich vorhanden ist wird er erzeugt. Dann wird auf das Vorhanden-
     sein eines Wertes gepr�ft. Falls dieser nicht gefunden wird, war der
     Registry-Zweig urspr�nglich nicht vorhanden, mu� also wieder gel�scht
     werden.}
    if Reg.OpenKey('\CLSID\' + CdrtfeClassID + '\InProcServer32', True) then
    begin
      Result := Reg.ValueExists('ThreadingModel');
      if not Result then
      begin
        Reg.DeleteKey('\CLSID\' + CdrtfeClassID);
      end;
    end else
    begin
      Result := False;
    end;
    {$ENDIF}
  finally
    Reg.Free;
  end;
end;

{ RegisterShellExtensions ------------------------------------------------------

  RegisterShellExtensions tr�g alle n�tigen Informationen in die Registry ein,
  damit die ShellExtensions verwendet werden k�nnen. Im UNterschied zu fr�heren
  Versionen ist eine Aktivierung per Kommandozeile nicht mehr m�glich.         }

procedure RegisterShellExtensions;
var Reg    : TRegistry;
    DLLPath: string;
    Key    : string;
begin
  DLLPath := ExtractFilePath(Application.ExeName);
  if DLLPath[Length(DLLPath)] = '\' then Delete(DLLPath, Length(DLLPath), 1);
  DLLPath := DLLPath + cCdrtfeShlExDll;
  Reg := TRegistry.Create;
  try
    with Reg do
    begin
      {ShellExtensions registrieren}
      RootKey := HKEY_CLASSES_ROOT;
      OpenKey('\CLSID\' + CdrtfeClassID, True);
      WriteString('', 'cdrtfe Context Menu Shell Extension');
      OpenKey('\CLSID\' + CdrtfeClassID + '\InProcServer32', True);
      WriteString('', DLLPath);
      WriteString('ThreadingModel', 'Apartment');
      {Kontextmen� f�r * erweitern}
      Key := '\*' + CMHPath + CdrtfeClassID;
      OpenKey(Key, True);
      WriteString('', CdrtfeClassID);
      {Kontextmen� f�r Ordner erweitern}
      Key := '\folder' + CMHPath + CdrtfeClassID;
      OpenKey(Key, True);
      WriteString('', CdrtfeClassID);
      {cdrtfe-Programmpfad eintragen}
      RootKey := HKEY_LOCAL_MACHINE; //HKEY_CURRENT_USER;
      OpenKey('\Software\cdrtfe\Program', True);
      WriteString('Path', ParamStr(0));
    end;
  finally
    Reg.Free;
  end;
  // ShellExtensions registriert.
  // Form1.Memo1.Lines.Add(GMS('mpref01'));
end;

{ UnregisterShellExtensions ----------------------------------------------------

  UnregisterShellExtensions entfernt die zu den ShellExtensions geh�renden Ein-
  tr�ge aus der Registry und deaktiviert diese. Im Gegensatz zu zu fr�heren
  Versionen ist eine Deaktivierung per Kommandozeile nicht mehr m�glich.       }

procedure UnregisterShellExtensions;
var Reg: TRegistry;
    Key: string;
begin
  Reg := TRegistry.Create;
  try
    with Reg do
    begin
      {ShellExtensions l�schen}
      RootKey := HKEY_CLASSES_ROOT;
      DeleteKey('\CLSID\' + CdrtfeClassID + '\InProcServer32');
      DeleteKey('\CLSID\' + CdrtfeClassID);
      {Kontextmen�eintrag f�r * l�schen}
      Key := '\*' + CMHPath + CdrtfeClassID;
      DeleteKey(Key);
      {Kontextmen� f�r Ordner erweitern}
      Key := '\folder' + CMHPath + CdrtfeClassID;
      DeleteKey(Key);
      {cdrtfe-Programmpfad l�schen}
      RootKey := HKEY_LOCAL_MACHINE;
      DeleteKey('\Software\cdrtfe');
    end;
  finally
    Reg.Free;
  end;
  // Registryeintr�ge der ShellExtensions entfernt.
  // Form1.Memo1.Lines.Add(GMS('mpref02'));
end;

end.
