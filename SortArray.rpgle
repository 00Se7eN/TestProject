// ============================================================================================
// Sort Array
// --------------------------------------------------------------------------------------------
    BEGSR   SortArray;

            ProcessArray    =   'Y';
        DOW ProcessArray    =   'Y';
            ProcessArray    =   'N';

                TmpCount        =   *Zeros;
            DOW TmpCount + 1    <   Count;
                TmpCount        =   Tmpcount + 1;

                IF  MenuOptnsArray(TmpCount).OptID      >   MenuOptnsArray(TmpCount+1).OptID;
                    TmpOption                           =   MenuOptnsArray(TmpCount).Option;
                    TmpOptID                            =   MenuOptnsArray(TmpCount).OptID;
                    TmpOptDesc                          =   MenuOptnsArray(TmpCount).OptDesc;
                    TmpOptPgm                           =   MenuOptnsArray(TmpCount).OptPgm;

                    MenuOptnsArray(TmpCount).Option     =   MenuOptnsArray(TmpCount+1).Option;
                    MenuOptnsArray(TmpCount).OptID      =   MenuOptnsArray(TmpCount+1).OptID;
                    MenuOptnsArray(TmpCount).OptDesc    =   MenuOptnsArray(TmpCount+1).OptDesc;
                    MenuOptnsArray(TmpCount).OptPgm     =   MenuOptnsArray(TmpCount+1).OptPgm;

                    MenuOptnsArray(TmpCount+1).Option   =   TmpOption;
                    MenuOptnsArray(TmpCount+1).OptID    =   TmpOptID;
                    MenuOptnsArray(TmpCount+1).OptDesc  =   TmpOptDesc;
                    MenuOptnsArray(TmpCount+1).OptPgm   =   TmpOptPgm;

                    ProcessArray    =   'Y';
                ENDIF;

            ENDDO;

        ENDDO;

    ENDSR;
// ============================================================================================