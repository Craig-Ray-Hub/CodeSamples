%macro Template;
*****************************************************************************************************
Macro: Templage.sas
Purpose: Standard PROC TEMPLATE for Insight SAS Output
Date:  1/20/2022
*****************************************************************************************************;
  proc template ;
    define style Styles.InsightStylePC;
    parent = Styles.Journal; 

    style body from document /
      leftmargin=1in
      rightmargin=.8in
      bottommargin=1in 
      topmargin=1in 
    ;

    style fonts from fonts /
      'TitleFont'=("Calibri,Helvetica,Helv",10pt,Bold)
      'TitleFont2'=("Calibri,Helvetica,Helv",10pt,Bold)
      'StrongFont'=("Calibri, Helvetica, Helv",10pt,Bold)
      'EmphasisFont'=("Calibri,Helvetica,Helv",10pt,Italic)
      'headingFont'=("Lucida Sans,Helvetica, Helv",9pt,Bold) 
      'docFont'=("Calibri, Helvetica, Helv",9pt)
      'footFont'=("Calibri, Helvetica, Helv",8pt); 

    replace Output from Container /
      frame = void 
      rules = none
      borderbottomwidth=1pt
      borderbottomcolor = black
      borderbottomstyle=solid
      cellpadding = 1pt 
      cellspacing = 1pt 
     ;

    Style Table /
      frame =VOID 
      rules = none
      borderbottomwidth=2.25pt
      borderbottomcolor = #6C7066
      borderbottomstyle=solid
    ;  
    style HeadersAndFooters  /
      font_face = "Lucida Sans"
      font_weight = bold
      font_size = 8.5pt 
      just=center
      bordertopstyle=solid
      bordertopcolor=#B12732
      bordertopwidth=1pt
      borderbottomstyle=solid
      borderbottomcolor=#B12732
      borderbottomwidth=1pt 
    ;

    style RowHeader  /
      font_face = "Calibri"
      font_size = 9pt 
      just=left
      cellpadding = 2pt 
      cellspacing = 1pt 
      bordertopstyle=none
      borderbottomstyle=none
    ;

    style Continued from Continued /
      pretext=""
      cellpadding = 0pt 
      cellspacing = 0pt 
    ;

    style usertext from headersandfooters /
      fontweight = bold
      just=center
      fontsize= 8.5pt
      bordertopstyle=solid
      bordertopcolor=#B12732
      bordertopwidth=1pt
      borderbottomstyle=solid
      borderbottomcolor=#B12732
      borderbottomwidth=1pt ;
    end;
  run; 
%mend Template;
