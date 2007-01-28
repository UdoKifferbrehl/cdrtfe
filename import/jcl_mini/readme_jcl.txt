Hinweise zur Nutzung der JCL
============================

Einige Funktionen von cdrtfe bauen auf der JCL (Jedi Code Library, Project JEDI)
auf, somit kann das Programm nur kompiliert werden, wenn die JCL installiert
ist. Die JCL (Quelltexte und Installationsprogramm) kann heruntergeladen werden
von http://jcl.sourceforge.net/.

Falls eine Installation nicht erwünscht ist, kann von der cdrtfe-Download-Seite
ein Archiv mit den benötigten Teilen der JCL heruntergeladen werden, das dann in
dieses Verzeichnis (import\jcl_mini) entpackt werden muß.

In beiden Fällen gilt dann für cdrtfe als Lizenz die GPL mit der speziellen Aus-
nahme, die es gestattet, cdrtfe mit freien Programmen oder Bibliotheken, die
unter der GNU Library General Public License (GNU LGPL), Mozilla Public License
1.1 (MPL) oder Common Development and Distribution License (CDDL) veröffentlicht
wurden, zu kombinieren.

Soll nur die unveränderte GPL gelten, ist in directives.inc die entsprechende
Direktive {$DEFINE GPLonly} zu setzen. Dann sind jedoch die erweiterten, auf der
JCL basierenden Funktionen nicht nutzbar.


Notes on the use of the JCL
===========================

Some functions of cdrtfe are based on the JCL (Jedi Code Library, Project JEDI).
Thus, the JCL has to be installed in order to compile the program. You can down-
load the JCL (source code and installer) from http://jcl.sourceforge.net/.

If you don't want to install the JCL, you can get from the cdrtfe donwload page
a package which contains the needed parts of the JCL. Extract the files into
this folder (import\jcl_mini).

In both cases the GPL with the special exception (permission to combine this
program with free software programs or libraries that are released under the
GNU Library General Public License (GNU LGPL), Mozilla Public License 1.1 (MPL)
or Common Development and Distribution License (CDDL)) applies as license.

If you wish to use the unmodified GPL, you have to set the corrensponding
directive {$DEFINE GPLonly} in directives.inc. However, the functions based on
the JCL won't be available.


