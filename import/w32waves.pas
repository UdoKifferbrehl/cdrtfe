{ Unit for accessing Windows PCM wave file informations
  By Ulli Conrad <uconrad@gmx.net>

  Modified by Oliver Valencia, Nov. 2002, Feb. & May 2005

  This Unit (W32Waves.pas) is not explicitly published under the terms of the
  GNU General Public License. However, the original author (Ulli Conrad) has
  agreed to the distribution of this unit within the cdrtfe project.

}

unit W32Waves;

{$I directives.inc}

interface

uses SysUtils, Windows, MMSystem, Dialogs;

type PWaveInformation = ^TWaveInformation;
     TWaveInformation = record
                          WaveFormat   : Word;     {Wave format identifier}
                          Channels     : Word;     {Mono=1, Stereo=2}
                          SampleRate   : Longint;  {Sample rate in Hertz}
                          BitsPerSample: Word;     {Resolution, e.g. 16 Bit}
                          SamplesNumber: Longint;  {Number of samples}
                          Length       : Extended; {Sample length in seconds}
                          ValidWave    : Bool;     {could the file be read?}
                        end;

{Constants for wave format identifier}
const WAVE_FORMAT_PCM                 = $0001;   {Windows PCM}
      WAVE_FORMAT_G723_ADPCM          = $0014;   {Antex ADPCM}
      WAVE_FORMAT_ANTEX_ADPCME        = $0033;   {Antex ADPCME}
      WAVE_FORMAT_G721_ADPCM          = $0040;   {Antex ADPCM}
      WAVE_FORMAT_APTX                = $0025;   {Audio Processing Technology}
      WAVE_FORMAT_AUDIOFILE_AF36      = $0024;   {Audiofile, Inc.}
      WAVE_FORMAT_AUDIOFILE_AF10      = $0026;   {Audiofile, Inc. }
      WAVE_FORMAT_CONTROL_RES_VQLPC   = $0034;   {Control Resources Limited}
      WAVE_FORMAT_CONTROL_RES_CR10    = $0037;   {Control Resources Limited}
      WAVE_FORMAT_CREATIVE_ADPCM      = $0200;   {Creative ADPCM}
      WAVE_FORMAT_DOLBY_AC2           = $0030;   {Dolby Laboratories}
      WAVE_FORMAT_DSPGROUP_TRUESPEECH = $0022;   {DSP Group, Inc}
      WAVE_FORMAT_DIGISTD             = $0015;   {DSP Solutions, Inc.}
      WAVE_FORMAT_DIGIFIX             = $0016;   {DSP Solutions, Inc.}
      WAVE_FORMAT_DIGIREAL            = $0035;   {DSP Solutions, Inc.}
      WAVE_FORMAT_DIGIADPCM           = $0036;   {DSP Solutions ADPCM}
      WAVE_FORMAT_ECHOSC1             = $0023;   {Echo Speech Corporation}
      WAVE_FORMAT_FM_TOWNS_SND        = $0300;   {Fujitsu Corp.}
      WAVE_FORMAT_IBM_CVSD            = $0005;   {IBM Corporation}
      WAVE_FORMAT_OLIGSM              = $1000;   {Ing C. Olivetti & C., S.p.A.}
      WAVE_FORMAT_OLIADPCM            = $1001;   {Ing C. Olivetti & C., S.p.A.}
      WAVE_FORMAT_OLICELP             = $1002;   {Ing C. Olivetti & C., S.p.A.}
      WAVE_FORMAT_OLISBC              = $1003;   {Ing C. Olivetti & C., S.p.A.}
      WAVE_FORMAT_OLIOPR              = $1004;   {Ing C. Olivetti & C., S.p.A.}
      WAVE_FORMAT_IMA_ADPCM           = $0011;   {Intel ADPCM}
      WAVE_FORMAT_DVI_ADPCM           = $0011;   {Intel ADPCM}
      WAVE_FORMAT_UNKNOWN             = $0000;
      WAVE_FORMAT_ADPCM               = $0002;   {Microsoft ADPCM}
      WAVE_FORMAT_ALAW                = $0006;   {Microsoft Corporation}
      WAVE_FORMAT_MULAW               = $0007;   {Microsoft Corporation}
      WAVE_FORMAT_GSM610              = $0031;   {Microsoft Corporation}
      WAVE_FORMAT_MPEG                = $0050;   {Microsoft Corporation}
      WAVE_FORMAT_NMS_VBXADPCM        = $0038;   {Natural MicroSystems ADPCM}
      WAVE_FORMAT_OKI_ADPCM           = $0010;   {OKI ADPCM}
      WAVE_FORMAT_SIERRA_ADPCM        = $0013;   {Sierra ADPCM}
      WAVE_FORMAT_SONARC              = $0021;   {Speech Compression}
      WAVE_FORMAT_MEDIASPACE_ADPCM    = $0012;   {Videologic ADPCM}
      WAVE_FORMAT_YAMAHA_ADPCM        = $0020;   {Yamaha ADPCM}

function GetWaveInformationFromFile(const Filename: string;
                                    const Info: PWaveInformation): Bool;

implementation

type TCommWaveFmtHeader = record
                            wFormatTag     : Word;    {Fixed, must be 1}
                            nChannels      : Word;    {Mono=1, Stereo=2}
                            nSamplesPerSec : Longint; {SampleRate in Hertz}
                            nAvgBytesPerSec: Longint;
                            nBlockAlign    : Word;
                            nBitsPerSample : Word;    {Resolution, e.g. 8 Bit}
                            cbSize         : Longint; {Size of extra}
                          end;         {information in the extended fmt Header}

function GetWaveInformationFromFile(const Filename: string;
                                    const Info:  PWaveInformation): Bool;
var hdmmio          : HMMIO;
    mmckinfoParent  : TMMCKInfo;
    mmckinfoSubchunk: TMMCKInfo;
    Fmt             : TCommWaveFmtHeader;
    {Samples         : Longint;}

begin
  Result := False;
  {Initialize first}
  FillChar(Info^, SizeOf(TWaveInformation), #0);
  hdmmio := mmioOpen(PChar(Filename), nil, MMIO_READ);
  if (hdmmio = 0) then
    exit;

  {Locate a 'RIFF' chunk with a 'WAVE' form type to make sure it's
   a WAVE file.}
  mmckinfoParent.fccType := mmioStringToFOURCC('WAVE', MMIO_TOUPPER);
  if (mmioDescend(hdmmio, PMMCKINFO(@mmckinfoParent),
                  nil, MMIO_FINDRIFF) <> 0) then
    exit;

  {Now, find the format chunk (form type 'fmt '). It should be a subchunk
   of the 'RIFF' parent chunk.}
  mmckinfoSubchunk.ckid := mmioStringToFOURCC('fmt ', 0);
  if (mmioDescend(hdmmio, @mmckinfoSubchunk, @mmckinfoParent,
                  MMIO_FINDCHUNK) <> 0) then
    exit;

  {Read the format chunk.}
  if (mmioRead(hdmmio, PChar(@fmt), Longint(sizeof(TCommWaveFmtHeader)))
     <> Longint(sizeof(TCommWaveFmtHeader))) then
    exit;

  Info^.WaveFormat := fmt.wFormatTag;
  Info^.Channels := fmt.nChannels;
  Info^.SampleRate := fmt.nSamplesPerSec;
  Info^.BitsPerSample := fmt.nBitsPerSample;

  {Ascend out of the format subchunk.}
  mmioAscend(hdmmio, @mmckinfoSubchunk, 0);

  {Find the data subchunk.}
  mmckinfoSubchunk.ckid := mmioStringToFOURCC('data', 0);
  if (mmioDescend(hdmmio, @mmckinfoSubchunk, @mmckinfoParent,
                  MMIO_FINDCHUNK) <> 0) then
    exit;

  {Get the size of the data subchunk.}
  Info^.SamplesNumber := mmckinfoSubchunk.cksize;

  {Tatsächlich wurde hier Größe des reinen (Audio-)Datenbereichs bestimmt und
   nicht die Anzahl der Samples.}

  {Original code:

   Samples := (Info^.SamplesNumber*8*Info^.Channels) div Info^.BitsPerSample;

   Problem: Length of stereo wave-files seems to be too long. }

  {Modification by Oliver Valencia, Nov. 2002:

   Samples := ((Info^.SamplesNumber * 8) div Info^.Channels)
              div Info^.BitsPerSample;
   Info^.Length := Samples/Info^.Samplerate;

   Next problem: With long wave files we have an integer overflow.}

  {Modification by Oliver Valencia, Feb. & May 2005: }
  if (Info^.Channels <> 0) and
     (Info^.BitsPerSample <> 0) and
     (Info^.Samplerate <> 0) then
  begin
    Info^.Length := 8 / (Info^.Channels * Info^.BitsPerSample * Info^.Samplerate);
    Info^.Length := Info^.Length * Info^.SamplesNumber;
  end;

  {We're done with the file, close it.}
  mmioClose(hdmmio, 0);
  Info^.ValidWave := true;
  Result := true;
end;

end.