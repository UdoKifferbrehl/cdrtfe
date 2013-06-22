cdrtfe - cdrtools/Mode2CDMaker/VCDImager Frontend
=================================================

  Copyright (c) 2010-2013 Oliver Valencia
  Copyright (c) 2008-2009 Oliver Valencia, Fabrice Tiercelin
  Copyright (c) 2004-2008 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche


General notes on compiling cdrtfe
=================================

- cdrtfe should compile using Delphi 7 to Delphi 2007, tested with
  Delphi 7 Personal and Turbo Delphi Explorer 2006.

- cdrtfe is not unicode capable. So it will not compile on newer
  versions of Delphi (Delphi 2009 to Delphi XE4). If it compiles anyway,
  it will not work correctly.

- You may need to adjust the output path for the compiled executable
  (project options).

- cdrtfe should be compiled with a detailed map file as this file is
  needed for a better exception handlling (you will get detailed
  information where in the source code the exception occurred). Using
  MakeJclDbg.exe from the JCL the map file can be converted to a much 
  smaller jdbg file.


External third party components
===============================

- cdrtfe makes use of several external third party components (for a
  complete list see info.txt):
  * JCL/JVCL
  * Vampyre Imaging Library
  * Drag and Drop Component Suite 5.2
  * Mustangpeak Common Library, Mustangpeak EasyListview,
    Mustangpeak VirutalShellTools 
  * Virtual Treeview component

- These libraries and components are completely independent of the 
  cdrtfe project. They are copyrighted by their respective authors.

- Depending on the settings in the file directives.inc you may not need
  all of these components.

- Except for some smaller components these external third party 
  components are not included in the cdrtfe source archive. You may
  download them from the cdrtfe download section at sourceforge
  (http://sourceforge.net/projects/cdrtfe/files/other). These archives
  only include those parts of the libraries and components that are 
  really necessary for a successful compilation of cdrtfe.

- Extract these archives into the appropriate folder in the subfolder
  imports.


DelphiShellControls / VirtualShellTools
=======================================

- cdrtfe can be either compiled using the DelphiShellControls or the
  VirtualShellTools.

- By default the DelphiShellControls are used. You can change this in
  the file directives.inc:
  Change the line
    {$DEFINE xUseVirtualShellTools}
  to
    {$DEFINE UseVirtualShellTools}

- To use the DelphiShellControls copy the files ShellConsts.pas and
  ShellCtrls.pas into the folder imports\ShellControls. These files
  are not provided by any cdrtfe download as they are part of Delphi,
  you can find them in the Delphi Demo folder. Before using the
  DelphiShellControls you may want to apply the patch ShellCtrls.patch.

- When using the VirtualShellTools and depending on your Delphi version,
  you may get an compile error that the unit GraphUtil.dcu could not
  be found. In this case remove the reference to GraphUtil in 
  VirtualTrees.pas, Line 4011:
  Change
    VTAccessibilityFactory, GraphUtil;  // accessibility helper class
  to
    VTAccessibilityFactory{, GraphUtil};  // accessibility helper class

