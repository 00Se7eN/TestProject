// ============================================================================================
// Remove Blanks
// --------------------------------------------------------------------------------------------
    BEGSR   RemoveBlanks;

            ProcessArray    =   'Y';
        DOW ProcessArray    =   'Y';
            ProcessArray    =   'N';

                TmpCount    =   *Zeros;
            DOW TmpCount    <   Count;
                TmpCount    =   Tmpcount + 1;

                IF  MenuOptnsArray(TmpCount).OptID  =   *Zeros;

                    SELECT;
                        WHEN    TmpCount    <   Count;
                                MenuOptnsArray(TmpCount).OptID      =   MenuOptnsArray(TmpCount+1).OptID;
                                MenuOptnsArray(TmpCount).OptDesc    =   MenuOptnsArray(TmpCount+1).OptDesc;
                                MenuOptnsArray(TmpCount+1).OptID    =   *Zeros;
                                MenuOptnsArray(TmpCount+1).OptDesc  =   *Blanks;
                                ProcessArray    =   'Y';

                        WHEN    TmpCount        =   Count;
                                ProcessArray    =   'Y';
                    ENDSL;

                ENDIF;

            ENDDO;

            IF  ProcessArray    =   'Y';
                Count           =   Count - 1;
            ENDIF;

        ENDDO;

    ENDSR;
// ============================================================================================