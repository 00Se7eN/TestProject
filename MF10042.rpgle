**FREE
// ============================================================================================
    CTL-OPT DFTACTGRP(*NO)  ACTGRP(*CALLER)  DEBUG(*YES)  BNDDIR('MFBNDDIR');
// ============================================================================================
// Program ID       :  MF10042
// Description      :  Work with Customers (Controller)
// Author           :  Vinayak Mahajan
// Date written     :  July 22, 2016
// Based On Pgm     :  None
// Reviewer         :
// Date Reviewed    :
// ============================================================================================
// Internal Standalone Fields
// --------------------------------------------------------------------------------------------
    DCL-S   Text            CHAR(50);
    DCL-S   TmpCustName2    CHAR(30);
    DCL-S   LangCode        CHAR(3);
    DCL-S   ErrorMsg        CHAR(78);
    DCL-S   StrLength       ZONED(2:0);
    DCL-S   TmpMnuName2     CHAR(10);
    DCL-S   TmpMnuDesc2     CHAR(50);
    DCl-S   Environment     CHAR(10);
// ============================================================================================
// External Date Structures
// --------------------------------------------------------------------------------------------
    DCL-DS  UsrProfileDS    LIKEDS(UserProfile);
    END-DS;
// ============================================================================================
// Switches
// --------------------------------------------------------------------------------------------
    DCL-S   ValidScr01  CHAR(1);
    DCL-S   FKeyPressed CHAR(1);
    DCl-S   ExitProgram CHAR(1);
// ============================================================================================
// Prototypes
// --------------------------------------------------------------------------------------------
    /COPY   MFGSRC,MF18001PR;
    /COPY   MFGSRC,MF18002PR;
    /COPY   MFGSRC,MF18003PR;
// ============================================================================================
// Parameters for Various Programs
// --------------------------------------------------------------------------------------------

// Parameters for MF10043 - Work with Customers (View)

    DCL-PR      MF10043         EXTPGM;
    DCL-PARM    CompName        CHAR(50);
    DCL-PARM    UserID          CHAR(10);
    DCL-PARM    PosName         CHAR(30);
    DCL-PARM    Count           ZONED(5:0);
    DCL-PARM    CustomersArray  LIKEDS(Customers_t) DIM(999);
    DCL-PARM    TmpDSLRD        ZONED(4:0);
    DCL-PARM    F3Pressed       CHAR(1);
    DCL-PARM    F5Pressed       CHAR(1);
    DCL-PARM    F6Pressed       CHAR(1);
    DCL-PARM    F13Pressed      CHAR(1);
    DCL-PARM    Message         CHAR(130);
    DCL-PARM    ErrorID         ZONED(5:0);
    END-PR;

// Parameters for MF10044 - Maintain Customers (Controller)

    DCL-PR      MF10044     EXTPGM;
    DCL-PARM    Mode        CHAR(10);
    DCL-PARM    CustomerDS  LIKEDS(Customer);
    END-PR;
// ============================================================================================
//                  MAIN PROCESSING
// --------------------------------------------------------------------------------------------

    EXSR    InitFirstTime;
    EXSR    InitAlways;
    EXSR    Main;
    EXSR    ExitAlways;
    EXSR    ExitLastTime;

// ============================================================================================
// Main
// --------------------------------------------------------------------------------------------
    BEGSR   Main;
    
            ExitProgram =   'N';
        DOW ExitProgram =   'N';

            EXSR    ProcScr01;

        ENDDO;

    ENDSR;
// ============================================================================================
// Process Screen 01
// --------------------------------------------------------------------------------------------
    BEGSR   ProcScr01;

            ValidScr01  =   'N';
        DOW ValidScr01  =   'N';

            EXSR    CallView;
            EXSR    VldtScr01;

        ENDDO;

    ENDSR;
// ============================================================================================
// Validate Screen 01
// --------------------------------------------------------------------------------------------
    BEGSR   VldtScr01;

        Message     =   *Blanks;
        ErrorID     =   *Zeros;
        ValidScr01  =   'Y';

        EXSR    CheckFKeys;

        IF  F3Pressed   =   'Y';
            ExitProgram =   'Y';
            LEAVESR;
        ENDIF;

        IF  PosName     <>  *Blanks AND
            FKeyPressed =   'N';
            EXSR    ProcPosName;
            ValidScr01  =   'N';
            LEAVESR;
        ENDIF;

        IF  FKeyPressed =   'Y';
            EXSR    TakeAction01;
            ValidScr01  =   'N';
            LEAVESR;
        ENDIF;

        EXSR    ProcRequest;

    ENDSR;
// ============================================================================================
// Process Position to Name
// --------------------------------------------------------------------------------------------
    BEGSR   ProcPosName;

        StrLength   =   *Zeros;
        StrLength   =   %len(%trimr(PosName));

            TmpCount    =   *Zeros;
        DOW TmpCount    <   Count;

            TmpCount    =   TmpCount + 1;

            TmpCustName     =   *Blanks;
            TmpCustName2    =   *Blanks;
            TmpCustName     =   CustomersArray(TmpCount).Name;
            TmpCustName2    =   %subst(TmpCustName:1:StrLength);

            IF  TmpCustName2    =   PosName;
                TmpDSLRD        =   TmpCount;
                Message         =   *Blanks;
                PosName         =   *Blanks;
                LEAVESR;
            ENDIF;

        ENDDO;

        ErrorID =   00009;
        EXSR    GetErrorMsg;

    ENDSR;
// ============================================================================================
// Take Action 01
// --------------------------------------------------------------------------------------------
    BEGSR   TakeAction01;

        SELECT;
            WHEN    F5Pressed   =   'Y';
            EXSR    ProcRefresh;
                    F5Pressed   =   'N';

            WHEN    F6Pressed   =   'Y';
            EXSR    ProcAdd;
                    F6Pressed   =   'N';

            WHEN    F13Pressed  =   'Y';
            EXSR    ProcRepeat;
                    F13Pressed  =   'N';
        ENDSL;

    ENDSR;
// ============================================================================================
// Process Refresh
// --------------------------------------------------------------------------------------------
    BEGSR   ProcRefresh;

        PosName =   *Blanks;
        EXSR    BuildArray;

    ENDSR;
// ============================================================================================
// Process Add
// --------------------------------------------------------------------------------------------
    BEGSR   ProcAdd;

        Mode    =   'Add';
        CLEAR   CustomerDS;

        EXSR    CallMaintain;
        EXSR    BuildArray;

    ENDSR;
// ============================================================================================
// Process Repeat
// --------------------------------------------------------------------------------------------
    BEGSR   ProcRepeat;

            TmpCount        =   *Zeros;
        DOW TmpCount + 1    <=   Count;

            TmpCount    =   TmpCount + 1;

            IF  CustomersArray(TmpCount).Option     <>  0;
                CustomersArray(TmpCount + 1).Option =   CustomersArray(TmpCount).Option;
            ENDIF;

        ENDDO;

    ENDSR;
// ============================================================================================
// Process Request
// --------------------------------------------------------------------------------------------
    BEGSR   ProcRequest;

            TmpCount    =   *Zeros;
        DOW TmpCount    <   Count;

            TmpCount    =   TmpCount + 1;

            IF  CustomersArray(TmpCount).Option <>  0;

                SELECT;
                    WHEN    CustomersArray(TmpCount).Option =   2;
                            Mode    =   'Change';

                    WHEN    CustomersArray(TmpCount).Option =   3;
                            Mode    =   'Copy';

                    WHEN    CustomersArray(TmpCount).Option =   4;
                            Mode    =   'Delete';

                    WHEN    CustomersArray(TmpCount).Option =   5;
                            Mode    =   'Display';
                ENDSL;

                EXSR    LoadCustomerDS;
                EXSR    CallMaintain;
                CustomersArray(TmpCount).Option =   0;

            ENDIF;

        ENDDO;

        EXSR    BuildArray;

    ENDSR;
// ============================================================================================
// Load CustomerDS
// --------------------------------------------------------------------------------------------
    BEGSR   LoadCustomeDS;

        CLEAR   CustomerDS;

        CustomerDS.CustID       =   CustomersArray(TmpCount).CustID;
        CustomerDS.Name         =   CustomersArray(TmpCount).Name;
        CustomerDS.TeleNo       =   CustomersArray(TmpCount).TeleNo;
        CustomerDS.CellNo       =   CustomersArray(TmpCount).CellNo;
        CustomerDS.AddrLine1    =   CustomersArray(TmpCount).AddrLine1;
        CustomerDS.AddrLine2    =   CustomersArray(TmpCount).AddrLine2;
        CustomerDS.AddrLine3    =   CustomersArray(TmpCount).AddrLine3;
        CustomerDS.Pin          =   CustomersArray(TmpCount).Pin;
        CustomerDS.SalesAmt     =   CustomersArray(TmpCount).SalesAmt;
        CustomerDS.AmtRcvd      =   CustomersArray(TmpCount).AmtRcvd;

    ENDSR;
// ============================================================================================
// Check Function Keys
// --------------------------------------------------------------------------------------------
    BEGSR   CheckFKeys;

        IF  F5Pressed   =   'Y' OR
            F6Pressed   =   'Y' OR
            F13Pressed  =   'Y';
            FKeyPressed =   'Y';
        ELSE;
            FKeyPressed =   'N';
        ENDIF;

    ENDSR;
// ============================================================================================
// Call View
// --------------------------------------------------------------------------------------------
    BEGSR   CallView;

        MF10043(CompName:UserID:PosName:Count:CustomersArray:TmpDSLRD:F3Pressed:F5Pressed:F6Pressed:F13Pressed:Message:ErrorID);

    ENDSR;
// ============================================================================================
// Call Maintain
// --------------------------------------------------------------------------------------------
    BEGSR   CallMaintain;

        MF10044(Mode:CustomerDS);

    ENDSR;
// ============================================================================================
// Get Error Message
// --------------------------------------------------------------------------------------------
    BEGSR   GetErrorMsg;

        CALLP   MENU_GetErrorMessage(ErrorID:LangCode:ErrorMsg);
        Message =   ErrorMsg;

    ENDSR;
// ============================================================================================
// Init First Time Subroutine
// --------------------------------------------------------------------------------------------
    BEGSR   InitFirstTime;

    ENDSR;
// ============================================================================================
// Init Always Subroutine
// --------------------------------------------------------------------------------------------
    BEGSR   InitAlways;

        EXSR    GetEnv;
        EXSR    GetUserID;
        EXSR    GetUserProfile;
        EXSR    GetCompName;
        EXSR    BuildArray;
        TmpDSLRD    =   1;

    ENDSR;
// ============================================================================================
// Get Environment
// --------------------------------------------------------------------------------------------
    BEGSR   GetEnv;

        CALLP   COMN_GetEnvironment(Environment);

    ENDSR;
// ============================================================================================
// Get User ID
// --------------------------------------------------------------------------------------------
    BEGSR   GetUserID;

        CALLP   COMN_GetUserID(UserID);

    ENDSR;
// ============================================================================================
// Get User Profile
// --------------------------------------------------------------------------------------------
    BEGSR   GetUserProfile;

        UsrProfileDS.UserID =   UserID;
        CALLP   MENU_GetUserProfile(UsrProfileDS);
        LangCode            =   UsrProfileDS.LngCode;

    ENDSR;
// ============================================================================================
// Get Company Name
// --------------------------------------------------------------------------------------------
    BEGSR   GetCompName;

        CALLP   MENU_GetCompanyName(Environment:CompName);
        Text        =   CompName;
        EXSR    CenterText;
        Compname    =   Text;

    ENDSR;
// ============================================================================================
// Build Array
// --------------------------------------------------------------------------------------------
    BEGSR   BuildArray;

        CALLP   CUST_GetAllCustomers(Count:CustomersArray);

    ENDSR;
// ============================================================================================
// Center Text
// --------------------------------------------------------------------------------------------
    BEGSR   CenterText;

        CALLP   COMN_CenterText(Text);

    ENDSR;
// ============================================================================================
// Exit Always Subroutine
// --------------------------------------------------------------------------------------------
    BEGSR   ExitAlways;

    ENDSR;
// ============================================================================================
// Exit Last Time Subroutine
// --------------------------------------------------------------------------------------------
    BEGSR   ExitLastTime;

        *InLR   =   *On;
        RETURN;

    ENDSR;
// ============================================================================================