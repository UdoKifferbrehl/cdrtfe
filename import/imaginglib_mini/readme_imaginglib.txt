Hinweise zur Nutzung der Vampyre Imaging Library
================================================

cdrtfe verwendet zum Anzeigen von JPEG-Dateien wahlweise die Funktionen von
Delphi selbst (jpeg.pas) oder stattdessen die Funktionen der Vampyre Imaging
Library (standardmäßig ab Delphi 6).

Die Vampyre Imaging Library (Quelltexte und Installationsprogramm) kann her-
untergeladen werden von http://imaginglib.sourceforge.net.

Falls eine Installation nicht erwünscht ist, kann von der cdrtfe-Download-Seite
ein Archiv mit den benötigten Teilen der Vampyre Imaging Library heruntergeladen
werden, das dann in dieses Verzeichnis (import\imaginglib_mini) entpackt werden
muß.

Standardmäßig wird cdrtfe unter Verwendung der Vampyre Imaging Library kompi-
liert. Dies kann durch Anpassen der directive.inc geändert werden, siehe
{$DEFINE UseImagingLib}


Notes on the use of the Vampyre Imaging Library
===============================================

To display JPEG-Files cdrtfe uses either the Delphi functions (jpeg.pas) or
the functions from the Vampyre Imaging Library (default with Delphi 6 and above).

You can down-oad the Vampyre Imaging Library (source code and installer) from
http://imaginglib.sourceforge.net.

If you don't want to install the Vampyre Imaging Library, you can get a package
which contains the needed parts of the Vampyre Imaging Library from the cdrtfe
download page. Extract the files into this folder (import\imaginglib_mini).

By default cdrtfe is compiled with the Vampyre Imaging Library. You can change
this by editing directives.inc, see {$DEFINE UseImagingLib}.
