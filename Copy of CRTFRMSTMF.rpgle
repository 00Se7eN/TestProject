**FREE
// ===================================================================================================================================
    CTL-OPT DFTACTGRP(*NO) ACTGRP(*NEW) DEBUG(*YES) OPTION(*NODEBUGIO);
// ===================================================================================================================================
// Program ID    : CRTFRMSTMF
// Description   : Create From Stream File
// Author        : Brian Garland
// Date written  : June 24, 2016
// ===================================================================================================================================
// Modification History
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Files
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Arrays
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Internal Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-DS  OptCtlBlk   QUALIFIED;
            Type        INT(10)     INZ(0);
            DBCS        CHAR(1)     INZ('0');
            Prompt      CHAR(1)     INZ('1');
            Syntax      CHAR(1)     INZ('0');
            MsgKey      CHAR(4)     INZ(*Loval);
            Reserved    CHAR(9)     INZ(*Loval);
    END-DS;
    
    DCL-DS  ErrorCode   QUALIFIED;
            Provided    INT(10)     INZ(272);
            Available   INT(10)     INZ(0);
            MsgID       CHAR(7);
            Reserved    CHAR(1);
            MsgData     CHAR(256);
    END-DS;

    DCL-DS  ObjectDS;
            Object      CHAR(10);
            Library     CHAR(10);
    END-DS;
    
    DCL-DS  STMFDS;
            STMFLen     INT(5);
            STMF        CHAR(5000);
    END-DS;
    
    DCL-DS  ParmsDS;
            ParmsLen    INT(5);
            Parms       CHAR(2000);
    END-DS;

    DCL-DS  CommandsDS;
            *N          CHAR(10)    INZ('CRTCMD');
            *N          CHAR(10)    INZ('CRTBNDCL');
            *N          CHAR(10)    INZ('CRTCLMOD');
            *N          CHAR(10)    INZ('CRTDSPF');
            *N          CHAR(10)    INZ('CRTPRTF');
            *N          CHAR(10)    INZ('CRTLF');
            *N          CHAR(10)    INZ('CRTPF');
            *N          CHAR(10)    INZ('CRTPNLGRP');
            *N          CHAR(10)    INZ('CRTSRVPGM');
            Commands    CHAR(10)    DIM(9) POS(1);
    END-DS;
    
    DCL-DS  ObjTypesDS;
            *N          CHAR(10)    INZ('CMD');
            *N          CHAR(10)    INZ('PGM');
            *N          CHAR(10)    INZ('MODULE');
            *N          CHAR(10)    INZ('FILE');
            *N          CHAR(10)    INZ('FILE');
            *N          CHAR(10)    INZ('FILE');
            *N          CHAR(10)    INZ('FILE');
            *N          CHAR(10)    INZ('PNLGRP');
            *N          CHAR(10)    INZ('SRVPGM');
            ObjTypes    CHAR(10)    DIM(9) POS(1);
    END-DS;
// ===================================================================================================================================
// External Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// System Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-DS  *N          PSDS;
            #ErrorCode  CHAR(7)     POS(40);
            #ErrorText  CHAR(80)    POS(91);
    END-DS;
// ===================================================================================================================================
// Internal Standalone Fields
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-S CmdStr        CHAR(2500);
    DCL-S Index         INT(10);
    DCL-S MsgKey        CHAR(4);
    DCL-S UpdatedStr    CHAR(2500);
    DCL-S UpdatedStrLen INT(10);
// ===================================================================================================================================
// Constants
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Switches
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Prototypes
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Parameters for Various Programs 
// -----------------------------------------------------------------------------------------------------------------------------------

// Parameters for Execute Command API

    DCL-PR  QCMDEXC EXTPGM;
            CmdStr  CHAR(32767)     OPTIONS(*VARSIZE);
            CmdLen  PACKED(15:5)    CONST;
    END-PR;

// Parameters for Process Command API

    DCL-PR  QCAPCMD         EXTPGM;
            CmdStr          CHAR(32767) OPTIONS(*VARSIZE);
            CmdLen          INT(10)     CONST;
            OptCtlBlk       CHAR(32767) OPTIONS(*VARSIZE);
            OptCtlBlkLen    INT(10)     CONST;
            OptCtlBlkFmt    CHAR(8)     CONST;
            ChangedStr      CHAR(32767) OPTIONS(*VARSIZE);
            ChangedLen      INT(10)     CONST;
            ReturnLen       INT(10);
            ErrorCode       CHAR(32767) OPTIONS(*VARSIZE);
    END-PR;

// Parameters for Send Program Message API

    DCL-PR  QMHSNDPM    EXTPGM;
            MsgID       CHAR(7)     CONST;
            MsgFile     CHAR(20)    CONST;
            MsgData     CHAR(32767) OPTIONS(*VARSIZE)   CONST;
            MsgDataLen  INT(10)     CONST;
            MsgType     CHAR(10)    CONST;
            CallStkEnt  CHAR(10)    CONST;
            CallStkCnt  INT(10)     CONST;
            MsgKey      CHAR(4);
            ErrorCode   CHAR(32767) OPTIONS(*VARSIZE);
    END-PR;

// Parameters for this Program

    DCL-PR  CRTFRMSTMF;
            pObj    CHAR(20);
            Cmd     CHAR(10);
            pSTMF   CHAR(5002);
            pParms  CHAR(2002);
    END-PR;
// ===================================================================================================================================
// Program Entry Parameters
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PI  CRTFRMSTMF;
            pObj    CHAR(20);
            Cmd     CHAR(10);
            pSTMF   CHAR(5002);
            pParms  CHAR(2002);
    END-PI;
// ===================================================================================================================================
//                  MAIN PROCESSING
// -----------------------------------------------------------------------------------------------------------------------------------

// Extract Values from the Compound Parameters

    ObjectDS    =   pObj;
    STMFDS      =   pSTMF;
    ParmsDS     =   pParms;

// Create Temporary Source File

    CmdStr  =   'DLTF FILE(QTEMP/QSOURCE)';
    CALLP(E)    QCMDEXC(CmdStr:%len(CmdStr));
    
    CmdStr  =   'CRTSRCPF FILE(QTEMP/QSOURCE) RCDLEN(198) MBR(' + %trimr(Object) + ')';
    CALLP(E)    QCMDEXC(CmdStr:%len(CmdStr));

// Copy the Source from the IFS to the Temporary Source File

    CmdStr  =   'CPYFRMSTMF FROMSTMF(''' + %SUBST(STMF:1:STMFLen) + ''') '
                  +        'TOMBR(''/QSYS.LIB/QTEMP.LIB/QSOURCE.FILE/' + %trim(Object) + '.MBR'') '
                  +        'MBROPT(*REPLACE)';
    CALLP(E)    QCMDEXC(CmdStr:%len(CmdStr));

// Create the Object by Executing the Chosen Create Command

    Index   =   %lookup(Cmd:Commands);
    
    CmdStr  =   %trimr(Cmd) + ' '
                  + %trimr(ObjTypes(Index)) + '(' + %trimr(Library) + '/' + %trimr(Object) + ') '
                  + 'SRCFILE(QTEMP/QSOURCE) SRCMBR(' + %trimr(Object) + ') '
                  + %subst(Parms:1:ParmsLen);
    
    CALLP   QCAPCMD(CmdStr:%size(CmdStr):OptCtlBlk:
                    %size(OptCtlBlk):'CPOP0100':UpdatedStr:
                    %size(UpdatedStr):UpdatedStrLen:ErrorCode);

// If an Error occurred then Fail the Command

    IF  ErrorCode.Available >   0;
        #ErrorText          =   %trimr(Cmd) + ' failed with Message ID ' + ErrorCode.MsgID;
        CALLP   QMHSNDPM('CPF9898':'QCPFMSG   QSYS':#ErrorText:
                         %len(%trimr(#ErrorText)):'*ESCAPE':'*':
                         2:MsgKey:ErrorCode);
    ENDIF;

// Exit

    *InLR   =   *On;
    RETURN;

// ===================================================================================================================================