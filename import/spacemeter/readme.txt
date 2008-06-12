                           __________________
 
                              TQProgressBar
                           __________________


   TQProgressBar (v 1.1) is a Delphi visual component, designed and tested using
   Delphi 6 PE. It comes under the form of a Delphi unit.
   It is under copyright © 2004 by Olivier Touzot "QnnO", and several contributors.
   It can be found on the web at http://mapage.noos.fr/qnno/delphi_en.htm

 
   -1-  Licence & history.
   -2-  Instaling as a component.
   -3-  Properties and functions.
   -4-  Known problems


                           __________________
 
                              1. Licence
                           __________________


    //  This unit is freeware, but under copyrights that remain mine for my
    //  parts of the code, and original writters for their parts of the code.
    //  This is mainly the case with :
    //  -> The polynomial expression of the MakeCylinder(); function, provided
    //     by Matthieu Contensou, (with lots of help too, on many other 
    //     subjects (see below)).
    //     (http://www25.brinkster.com/waypointfrance/cpulog/index.asp)
    //  -> The RGBtoHLS(); and HLStoRGB(); procedures, which come from a
    //     Microsoft knowledge base article (Q29240), at :
    //     http://support.microsoft.com/default.aspx?scid=kb;en-us;29240
    //  -> The GetColorBetween(); function, which computes the main gradient,
    //     found at efg's colors page, and which author is saddly unknown :
    //     http://homepages.borland.com/efg2lab/Library/UseNet/2001/0821.txt
    //     http://homepages.borland.com/efg2lab/Library/Delphi/Graphics/Color.htm
    //  -> The GetGradientAr2(); new version, by Bernd Kirchhoff, which now
    //     correctly handles white and black colors in bars.
    //     (http://home.germany.net/100-445474/)

    //  This unit can be freely used in any application, freeware, shareware
    //  or commercial. However, I would apreciate your sending me an email if
    //  you decide to use it. Of course, you use it under your own and single
    //  responsability. Neither me, nor contributors, could be held responsible
    //  for any problem resulting from the use of this unit.  ;-)

    //  It can also be freely distributed, provided all the above (and current)
    //  lines remain within it unchanged, and the readme.txt file is distributed
    //  with it too.

    //  Many thanks go to Matthieu Contensou, who spent a lot of time (and
    //  patience ... ) trying to explain me the subtleties of the RGB -> YUV
    //  and return conversions.
    //  He gave the idea of using the HLS space too, which is now used in this
    //  component (instead of the YUV translation).


    { History :                                                          }
    { v 1.1 : 2004-05-12 (!)  Correction of the "extreme colors" bug in  }
    {         the GetGradientAr2(); function by Bernd Kirchhoff, allowing}
    {         the use of pure white or black colors in the bars. Thanks  }
    {         and congratulations (he made the work under cbuilder 4.0 !)}
    { v 1.0 : 2004-05-11 First release ;                                 }



                           __________________
 
                              2. Install
                           __________________



Directly using TQProgressBar, or installing it as a component :
--------------------------------------------------------------

  TQProgressBar coming under the form of a unit, it can be simply used 
  by creating bars at run-time, setting the necessary properties :
  
  uses {...}, QProgBar.pas;
  //...
  var aPBar : TQProgressBar;
  //...
  aPBar := TQProgressBar.Create(Nil);
  aPBar.Parent := handle_of_the_control_you_want_the_bar_to_appear_upon;
  aPBar. ...


  Otherwise, to manipulate bars into Delphi's IDE, you'll have to install 
  it like any other component :


TQProgressBar installation as component :
-----------------------------------------

  -1- Where will it go ?

      If you look at the Register(); procedure into the source code,
      you''l find the following lines :

      Procedure Register;
      Begin  
        RegisterComponents('Samples', [TQProgressBar]);
      End;

      The 'Sample' string indicates where the component icone will go.
      In the present case, it will appear upon the 'Sample' palette. 
      You can change this destination if you want.


  -2- Installing (D6PE):
  
      The three files provided 
        QProgBar.pas     (the source)
        QProgBar.dcu     (the Delphi Compiled Unit)
        QProgBar.dcr     (the component ressources file = the icon)
      must have been unzipped in a directory known by the IDE,
      for example, your '.\delphiN\lib' one.

      If you want to install it elsewhere, make sure to add the path
      of this directory in Delphi's PAth list.


      -> Open Delphi's IDE. Once openned, use the 'close everything' to
         close openned files (if, for example, a project is openned.)

      -> Select 'Install Component' from the 'Component' menu;
         The dialog now openning proposes two tabs : You can choose to
         install the component in an existing package, or in a new one.
         If you choose to create a new package, you simply will have to
         give it a name.

      -> Fill the 'unit name' field, using the button to select QProgBar.pas,
         the file you've just unzipped in your .lib directory.

      -> In the 'packet' window that has appeared, use the 'compile' button.
         Delphi should display a message saying that the 'sample' palette (or any
         other you choosed) has been updated to reflect changes.

      -> You're done, and can start using it like any other visual component, 
         changing its properties, aso. 


  -2- Uninstalling (D6PE):

      -> This a bit quicker than installing, but the path is almost the same :

      -> Use 'instal packet' menu, to have the installed packages dialog appear.

      -> Select the one you installed QProgBar into ;

      -> use the 'modify' button. Answer 'Yes' to the warning screen about the 
         window change ;

      -> In the dialog bow that you now know, select anything linked to QProgBar,
         and use the 'remove button to remove it.

      -> Don't forget to compile, when done. That's all.


TQProgressBar public properties and methodes :
----------------------------------------------

  public
    constructor Create (AOwner : TComponent);
      // Use it, if you want to add progressbars from within code.
    
    destructor  Destroy;
      // Bars you instanciated using Create() have to be destroyed.
      // The freeing job is made by their owner if you passed one,  
      // but has to be made by you (using "myBar.Free"), if you passed
      // none, like in : "myBar := TQProgressBar.Create(Nil);"
    
    procedure   LockInits;
      // When called, internal computings are suspended, waiting for a
      // a call to it's peer procedure : UnlockInits.
      // It should be called before changing anything in a bar's layout,
      // when you make more than one change in a row (like for example 
      // changing width and height, or start and finalColor and other
      // properties) : Tells QprogBar to NOT refresh at that momemt, and
      // to wait for a call to ".UnlockInits" before refreshing.
      // Saves cpu time.
    
    procedure   UnlockInits;
      // Pending procedure of above. Once called, launches the internal
      // computation process. Each call to LockInits MUST be followed
      // by a call to UnlockInits;
    

  published
    property orientation     : TQBarOrientation;
      // TQBarOrientation = (boHorizontal,boVertical);
      // Default : boHorizontal;
    
    property barKind         : TQBarKind;
      // TQBarKind = (bkFlat,bkCylinder);
      // Default : bkFlat;
    
    property barLook         : TQBarLook;
      // TQBarLook = (blMetal,blGlass);
      // blMetal takes the original color luminence into account 
      // when computing each pixel; blGlass don't. blGlass only
      // works on the 'basic color' part of the color of each pixel.
      // Default : blMetal;

    property shaped          : Boolean;
      // Decides wether the bar has a surrounding line or not.
      // Default : True;
    
    property shapeColor      : TColor;
      // The color of that surrounding line;
      // Default : RGB (0, 60, 116); (Dark blue);

    property roundCorner     : Boolean;
      // If True, the bar's external shape will appear with smoothly
      // rounded corners, otherwise, it will be a rectangle.
      // Default : True;
      
    property backgroundColor : TColor;
      // Default : clWhite;
  
    property startColor      : TColor;
      // Left color of a two-colors horizontal bar, or bottom color,
      // for vertical bars.
      // Default : clLime;
      
    property finalColor      : TColor;
      // Right color of a two-colors horizontal bar, or Top color,
      // for vertical bars.
      // Default : clLime; (default bar is thus monocolor)

    property barColor        : TColor;
      // Allows to define a single color bar in one shot :
      // Using "myBar.barColor   := clLime;" is equivalent to :
      //       "myBar.startColor := clLime; myBar.finalColor := clLime;"

    property showInactivePos : Boolean;
      // Inactive position are the positions not yet reached.
      // If True, they'll be drawn in the inactiveColor ; 
      // If False, only the background appears there.
      // Inactive positions share appearance properties and behaviour,
      // (like : by blocks or not, full blocks, barKind, aso.) with
      // active positions. Only the color differs.
      // Default : False;

    property inactivePosColor: TColor;
      // Base color of inactive positions.
      // Default : clGray;
          
    property invertInactPos  : Boolean;
      // If True, the luminance of inactive positions color array
      // is inverted. Notice that : the result is most often really
      // dark. There's still some work to do there. Applies only on
      // bkCylinder bars;
      // Default : False;
    
    property blockSize       : Integer;
    property spaceSize       : Integer;
      // TQProgressBars can appear under the form of a continuous area,
      // or like "blocks" separated by not-drawn spaces (where the
      // background appears).
      
      // blockSize defines the size of blocks, wheareas 
      // spaceSize defines the size of none drawn parts between two blocks.
      // Both represent a pixels quantity.
      
      // blockSize and spaceSize are ignored if one of them is set to zero,
      // or set to a value greater than the internal available draw space.
      
      // Default : 0;
    
    property showFullBlock   : Boolean;
      // If both blockSize and spaceSize have been defined, the bar will
      // show an alternance of blocks and spaces. 
      // In this case, if showFullBlock is set to True, each new block is
      // drawn only when the position sent corresponds to the end of a block.
      // If set to False, blocks are filled little by little.
      // Default : False;
    
    property maximum         : Integer;
      // This is the maximum value you may send to the bar.
      // It will be used to normalize positions sent compared to the size
      // of the bar's drawspace.
      // Default : 100;
         
    property position        : Integer;
      // The position to be drawn on the bar. This should be the only thing 
      // changing, once setup is complete.
      // Default : 0 at run time, 50 at design time.
    
    property hideOnTerminate : Boolean;
      // If True, the bar will hide itself a tenth of a second after it will
      // receive a position equal to self.maximum;
      // In such a case, it will be up to you to show it again, if you use it
      // again. ( {...}myBar.Show. )
      // Default : False;
         
    property caption         : String;
      // The bar may display a basic caption.
      // This caption's appearance depends on the bar canvas' font property.
      // It is neither XORed nor anything like that : I couldn't succeed at it.
      // Moreover, despite a caption appears correctly within horizontal bars,
      // it certainly will give poor results within vertical bars, as long as
      // the caption stays horizontal...
      // Default : ''; //no caption
      
    property captionAlign    : TAlignment;
      // vertical alignment is allways almost centered; This one is 
      // horizontal alignment, and can be taLeftJustify, taCenter, taRightJustify;
      // captionAlign has no default value. If not specified, the caption will 
      // be drawn at position (0,0); // upper left corner.
      
    property AutoCaption     : Boolean;   
    property AutoHint        : Boolean;
      // Both caption and hint can be set to display automatically the value 
      // of self.position ;
      // If True, Hint value is refreshed each time you send a new position,
      // and caption value is updated within the paint methode.
      
      // For hint to show when your user moves it's mouse over your bar, your
      // application must have at least the showHint property of its main Form
      // set to True;
      
      // Default : False, for both.
      
    property ShowPosAsPct    : Boolean;
      // If True, Both Hint and caption will show the last received position as a percentage
      // of maximum, followed by the string ' %'.
      // Default False;
      
    property font            : TFont;
      // To be used if you want to change the bar font's properties (color, bold, aso.)
      // created in the bar constructor, and freed in its destructor.
      
      // Don't use myBar.Font.Assign(someFont), because that change won't ever be taken
      // into account : The caption is drawn using the canvas' font, not the bar one.
      // The bar's one is basically an intermediate between your's and the canvas'one.


                           -----------------------------------


Known problems :
----------------

  I experienced two problems until now, one has a workaround, and the other one has been 
  corrected by Bernd Kirchhoff (one day after the release, shame on me !!!).



  > The first one is a latency in the drawing of the first of a series of bars. The 
  laging one is the first one updated, if showInactivePos is set to True, and 
  whatever are it's other characteristics (size, appearence, aso).
  The problem appears only under XP (despite a high cpu speed). A workaround is to
  call Application.ProcessMEssages just after the change of the position value of the 
  first bar. Useless with others. Mystery.

  In the demo, the four vetical bars illustrate this. They should slide all together,
  but the first one lags, unless I add the Application.ProcessMessages, like this :
  
  procedure TForm1.TrackBar3Change(Sender: TObject);
  begin
    QProgressBar6.position := TrackBar3.Position;
    Application.ProcessMessages;                          // Avoids the lag.
    QProgressBar7.position := TrackBar3.Position;
    QProgressBar8.position := TrackBar3.Position;
    QProgressBar9.position := TrackBar3.Position;
  end;

  

  > The second one occured when using pure white or black colors in a two colors bar. It has
  has been corrected by Bernd Kirchhoff (http://home.germany.net/100-445474/) in version 1.1 
  (see function GetGradientAr2(); in source).
  
 
  

                           -----------------------------------

