Hinweise zur Nutzung von TurboPower ShellShock
==============================================

Einige Funktionen von cdrtfe bauen auf den TurboPower ShellShock-Komponenten auf,
somit kann das Programm nur kompiliert werden, wenn diese Komponenten installiert
sind. TurboPower ShellShock kann heruntergeladen werden von
http://sourceforge.net/projects/tpshellshock/.

Falls eine Installation nicht erwünscht ist, kann von der cdrtfe-Download-Seite
ein Archiv mit den benötigten Teilen von TurboPower ShellShock heruntergeladen
werden, das dann in dieses Verzeichnis (import\tpshellshock_mini) entpackt werden
muß.

In beiden Fällen gilt dann für cdrtfe als Lizenz die GPL mit der speziellen Aus-
nahme, die es gestattet, cdrtfe mit freien Programmen oder Bibliotheken, die
unter der GNU Library General Public License (GNU LGPL), Mozilla Public License
1.1 (MPL) oder Common Development and Distribution License (CDDL) veröffentlicht
wurden, zu kombinieren.

Soll nur die unveränderte GPL gelten, ist in directives.inc die entsprechende
Direktive {$DEFINE GPLonly} zu setzen. Dann sind jedoch die erweiterten, auf 
ShellShock basierenden Funktionen nicht nutzbar.


Notes on the use of TurboPower ShellShock
=========================================

Some functions of cdrtfe are based on the TurboPower ShellShock components.
Thus, these components have to be installed in order to compile the program.
You can download TurboPower ShellShock from
http://sourceforge.net/projects/tpshellshock/.

If you don't want to install these components, you can get a package which
contains the needed parts of TurboPower ShellShock from the cdrtfe download page.
Extract the files into this folder (import\tpshellshock_mini).

In both cases the GPL with the special exception (permission to combine this
program with free software programs or libraries that are released under the
GNU Library General Public License (GNU LGPL), Mozilla Public License 1.1 (MPL)
or Common Development and Distribution License (CDDL)) applies as license.

If you wish to use the unmodified GPL, you have to set the corrensponding
directive {$DEFINE GPLonly} in directives.inc. However, the functions based on
TurboPower ShellShock won't be available.


