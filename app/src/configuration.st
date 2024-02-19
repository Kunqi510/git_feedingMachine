USING Siemens.Simatic.Motion; 
CONFIGURATION FeedingMachine
    TASK Main(Priority := 1);
    PROGRAM P1 WITH Main: MyProgram;  
    
    VAR_GLOBAL
        tiax_TOs_Initialized : BOOL;
        errorID : WORD;
        resetError AT %I1.0 : BOOL;
        powerOn AT %I0.0 : BOOL;
        powerOff AT %I0.1 : BOOL;
        axisStart AT %I0.2 : BOOL;
        axisStop AT %I0.3 : BOOL; 
        sinkFullSensor AT %I0.4 : BOOL;       
        sinkEmptySensor AT %I0.5 : BOOL;
        tankFullSensor AT %I0.6 : BOOL;
        tankEmptySensor AT %I0.7 : BOOL;
        tankInValve AT %Q0.0 : BOOL;
        tankOutValve AT %Q0.1 : BOOL;
        machineState : MachineState;
        currentState : STRING;
        axisVelocity : LREAL;
        axisPos : LREAL;
    END_VAR
END_CONFIGURATION
