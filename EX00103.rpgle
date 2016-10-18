**FREE
// ===========================================================
    CTL-OPT DEBUG(*YES) DFTACTGRP(*NO)  ACTGRP(*CALLER);
// ===========================================================
// Program ID       :   EX00103
// Description      :   Display Hello World (WRITE/READ)
// Author           :   Ramesh Joshi
// Date written     :   March 26, 2004
// Based On Pgm     :
// Reviewer         :
// Date Reviewed    :
// ===========================================================
// Files
// -----------------------------------------------------------
    DCL-F   HelloWorldDisplayFile   WORKSTN
                                    EXTDESC('EX00101DS')
                                    EXTFILE(*ExtDesc);
// ===========================================================
// Data Structures - System
// -----------------------------------------------------------
    DCL-DS  *N      PSDS;
        #Prog       CHAR(10) POS(1);
        #JobName    CHAR(10) POS(244);
        #User       CHAR(10) POS(254);
        #JobNo      CHAR(10) POS(264);
    END-DS;
// ===========================================================
//                      MAIN PROCESSING
// -----------------------------------------------------------

    WRITE   EX001011;
    READ    EX001011;

    *InLR   =   *On;
    RETURN;

// ===========================================================