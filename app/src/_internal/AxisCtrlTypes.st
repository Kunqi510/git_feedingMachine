NAMESPACE Siemens.Simatic.Motion

    TYPE
        AxisData : STRUCT
            cmd : AxisCmd;
            enabled : BOOL;
            homed : BOOL;
            error : BOOL;
            errorID : WORD;
            actSpeed : LREAL;
            actVelocity : LREAL;
            actPosition : LREAL;
        END_STRUCT;
    END_TYPE

    TYPE
        AxisCmd : INT (
            NONE := 0, 
            ENABLE := 1, 
            DISABLE := 2,
            RESET := 3, 
            HOME := 4,
            STOP := 5, 
            JOG := 6, 
            POS_RELATIVE := 7, 
            POS_ABSOLUTE := 8) := NONE;
    END_TYPE

END_NAMESPACE