**FREE
// ===================================================================================================================================
    CTL-OPT NOMAIN BNDDIR('TESTBND') DEBUG(*YES) OPTION(*NODEBUGIO);
// ===================================================================================================================================
// Program ID       :   SRVPGM
// Description      :   Service Program
// Author           :   Vinayak Mahajan
// Date written     :   September 02, 2016
// Based On Pgm     :   None
// Reviewer         :
// Date Reviewed    :
// ===================================================================================================================================
// Prototypes
// -----------------------------------------------------------------------------------------------------------------------------------
    /COPY /QOpenSys/QIBM/UserData/OPS/Orion/serverworkspace/vi/vinayakmahajan/OrionContent/TestProject/SRVPGMPR.sqlrpgle
// ===================================================================================================================================
// Procedures
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// TIME_GetErrorMessage(): Get Error Message
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC    TIME_GetErrorMessage EXPORT;

        DCL-PI      TIME_GetErrorMessage;
            ErrMsgDS   EXTNAME(ERRMSG)  QUALIFIED;
        END-PI;

        EXEC SQL
    SELECT ERROR_MESSAGE INTO :ErrMsgDS.ERRORMSG FROM ERRMSG WHERE
    ERROR_ID = :ErrMsgDS.ERRORID AND LANGUAGE_CODE =              
    :ErrMsgDS.LANGCODE;

        RETURN;

    END-PROC;
// ===================================================================================================================================