{ $Id: f_wavefiles.pas,v 1.1 2010/01/11 06:37:39 kerberos002 Exp $

  f_wavefiles.pas: Wave-Dateien

  Copyright (c) 2004-2008 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  02.10.2008

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_wavefiles.pas stellt Hilfs-Funktionen zur Verfügung:
    * Wave-File-Fuktionen


  exportierte Funktionen/Prozeduren:
    GetWaveLength(const Name: string): Extended
    WaveIsValid(const Name: string): Boolean

}

unit f_wavefiles;

{$I directives.inc}

interface

function GetWaveLength(const Name: string): Extended;
function WaveIsValid(const Name: string): Boolean;

implementation

uses w32waves;

{ WaveIsValid ------------------------------------------------------------------

  WaveIsValid  prüft, ob die angegebene Datei eine gültige Wave-Datei ist.     }

function WaveIsValid(const Name: string): Boolean;
var PWavInfo: PWaveInformation;
begin
  New(PWavInfo);
  GetWaveInformationFromFile(Name, PWavInfo);
  {Bedingungen: PCM-Format (WaveFormat = 1),
                stereo     (Chennels = 2),
                44.1 kHz   (SampleRate = 44100),
                16 Bit     (BitPerSample = 16)}
  with PWavInfo^ do
  begin
    if (WaveFormat = 1) and (Channels = 2) and (SampleRate = 44100) and
       (BitsPerSample = 16) and ValidWave then
    begin
      Result := True;
    end else
    begin
      Result := False;
    end;
  end;
  Dispose(PWavInfo);
end;

{ GetWaveLength ----------------------------------------------------------------

  GetWaveLength bestimmt die Länge einer Wave-Datei in Sekunden.               }

function GetWaveLength(const Name: string): Extended;
var PWavInfo: PWaveInformation;
    TotalTime: Extended; // Time in seconds
begin
  TotalTime := 0;

  New(PWavInfo);
  GetWaveInformationFromFile(Name, PWavInfo);
  {Bedingungen: PCM-Format (WaveFormat = 1),
                stereo     (Chennels = 2),
                44.1 kHz   (SampleRate = 44100),
                16 Bit     (BitPerSample = 16)}
  with PWavInfo^ do
  begin
    if (WaveFormat = 1) and (Channels = 2) and (SampleRate = 44100) and
       (BitsPerSample = 16) and ValidWave then
    begin
      TotalTime := TotalTime + Length;
    end else
    begin
      TotalTime := 0;
    end;
  end;
  Dispose(PWavInfo);
  Result := TotalTime;
end;

end.
