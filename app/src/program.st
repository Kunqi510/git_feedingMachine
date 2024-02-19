USING Siemens.Simatic.Motion; 
USING Siemens.Simatic.S71500.MotionControl.Native;
USING Siemens.Simatic.StateMachine;
USING TankLib;
TYPE
    MachineState:(OFFState, FillTankState, FillSinkState, ReadyState, RunState, StopState, ErrorState) := OFFState;       
END_TYPE

PROGRAM MyProgram
    /*引入外部全局变量 */
    VAR_EXTERNAL
        powerOn : BOOL;
        powerOff : BOOL;
        axisStart: BOOL;
        axisStop : BOOL; 
        sinkFullSensor : BOOL;       
        sinkEmptySensor : BOOL;
        tankFullSensor : BOOL;
        tankEmptySensor : BOOL;
        tankInValve : BOOL;
        tankOutValve : BOOL;
        errorID : WORD;
        resetError : BOOL;
        tiax_TOs_Initialized : BOOL;
        machineState : MachineState;
        currentState : STRING;
        axisVelocity : LREAL;
        axisPos : LREAL; 
    END_VAR
    /*定义静态变量 */
    VAR
        //TO及对应组件对象/接口
        _feedAxis : PosAxis;
        _tank : Tank;
        _valveIn : Valve;
        _valveOut : Valve;
        // 状态机：上料机
        _feedingMachine : FeedingMachine;
        //状态机初始化状态：OFF
        initState : OffState;
        _posAxisDB : DB_ANY := UINT#1;
        _enabled : BOOL;
    END_VAR

    //Code Here:
    IF NOT tiax_TOs_Initialized THEN //初始化轴，将TIA DB_ANY 转换为itfAxis
            tiax_TOs_Initialized := TRUE;
            _feedingMachine.SetState(initState,REF(_tank),REF(_feedAxis));//状态机设定初始状态-OFF

   END_IF;
    _tank.Init(_valveIn,_valveOut); //初始化原料罐   
    _feedAxis.Attach(_posAxisDB); // 轴初始化
    errorID := _feedAxis.GetAxisStatus().errorID;
    /* 断电或原料罐空罐 */ 
    // IF powerOff OR tankEmptySensor THEN
    //     _feedAxis.ResetCmds();
    //     _feedAxis.DisableAxis(stopMode := 1);
    //     IF NOT _feedAxis.GetAxisStatus().enabled THEN
    //         machineState := MachineState#OFFState;
    //     END_IF; 
    // END_IF;

    /*面对对象写法：状态模式-状态机 */
    _feedingMachine.Excute(); //触发状态机状态转换  
    currentState:=_feedingMachine.GetCurrentState(); //获取状态机当前状态
    /*面对过程写法：CASE OF */
    // CASE machineState OF // Case+IF-ELSE 判断状态，执行步骤
    //     MachineState#OFFState:
    //         currentState:='OFF';
    //         _tank.Close();
    //         _feedAxis.DisableAxis(stopMode := 1);
    //         IF powerOn AND NOT(powerOff) THEN 
    //             machineState:=MachineState#FillTankState;
    //         END_IF;
    //     MachineState#FillTankState:
    //         currentState:='Filling Tank';           
    //         _tank.Filling();           
    //         _feedAxis.DisableAxis(stopMode := 1);
    //         IF tankFullSensor THEN
    //             machineState:=MachineState#FillSinkState;
    //         END_IF;
    //     MachineState#FillSinkState:
    //         currentState:='Filling Sink';
    //         _tank.Feeding();     
    //         _feedAxis.DisableAxis(stopMode := 1);  
    //         IF sinkFullSensor THEN
    //             machineState:=MachineState#ReadyState;
    //         END_IF;
    //     MachineState#ReadyState:
    //         currentState:='Ready'; 
    //         _tank.close();
    //         IF axisStart THEN
    //             _feedAxis.EnableAxis(startmode := 1);       
    //             _feedAxis.HomeAxis(position := 0.0, homingMode := 0);
    //             IF _feedAxis.GetAxisStatus().Error THEN
    //                 machineState := MachineState#ErrorState;
    //             _enabled := _feedAxis.GetAxisStatus().enabled;
    //             ELSIF NOT(sinkEmptySensor) AND _feedAxis.GetAxisStatus().enabled AND _feedAxis.GetAxisStatus().homed THEN
    //                 machineState:=MachineState#RunState;                                
    //             END_IF;                 
    //         END_IF;     
    //     MachineState#ErrorState:
    //         currentState:='Error';
    //         IF resetError THEN
    //             _feedAxis.ResetAxis();
    //             IF powerOff THEN
    //                 machineState:=MachineState#OFFState;
    //             ELSIF NOT _feedAxis.GetAxisStatus().error THEN
    //                 errorID := WORD#0;
    //                 machineState:=MachineState#StopState;
    //             END_IF;
    //         END_IF; 
    //     MachineState#RunState:
    //         currentState:='Running';
    //         _feedAxis.PosAbsolute(position := 5000.0,velocity := 50.0,acceleration := -1.0,deceleration := -1.0);
    //         IF _feedAxis.GetAxisStatus().Error THEN
    //             machineState:=MachineState#ErrorState;                               
    //         END_IF;         
    //         IF axisStop OR sinkEmptySensor THEN
    //             machineState:=MachineState#StopState;
    //         END_IF;
    //     MachineState#StopState:
    //         currentState:='Stoped';
    //         _feedAxis.StopAxis(deceleration := -1.0, jerk := -1.0);
    //         IF _feedAxis.GetAxisStatus().Error THEN
    //             machineState:=MachineState#ErrorState;                               
    //         END_IF;        
    //         IF axisStart AND NOT axisStop THEN
    //             machineState:=MachineState#FillSinkState;
    //         END_IF;
    // END_CASE;

    /* 阀门输出 */
    _valveIn.WriteCyclic(outputSignal=>tankInValve);
    _valveOut.WriteCyclic(outputSignal=>tankOutValve);

    axisVelocity := _feedAxis.GetAxisStatus().actVelocity;
    axisPos := _feedAxis.GetAxisStatus().actPosition;

END_PROGRAM































// PROGRAM MyProgram
//     VAR
//        ivalve:IValve;
//        v1:Valve;
//        v2: AlwaysOFFValve;
//        output:BOOL;
//     END_VAR
//     ivalve:=v1;//实现阀门对象
//     ivalve.Open(); //打开阀门
//     ivalve.WriteCyclic(output);//阀门输出为True
//     ;
//     ivalve:=v2;//实现常闭阀门对象
//     ivalve.Open(); //调用相同方法-打开阀门
//     ivalve.WriteCyclic(output);//输出结果相反：为False
//     ;
// END_PROGRAM    