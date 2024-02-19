USING TankLib;
USING Siemens.Simatic.S71500.MotionControl.Native;
USING Siemens.Simatic.Motion;

NAMESPACE Siemens.Simatic.StateMachine

    CLASS PUBLIC OffState IMPLEMENTS IState
        VAR 
            _feedAxis : REF_TO PosAxis;        
            _tank: REF_TO Tank; 
        END_VAR

        //执行动作逻辑
        METHOD PUBLIC ExcuteJob
            _tank^.Close();
            _feedAxis^.ResetCmds();
            _feedAxis^.DisableAxis(stopMode := 1);
        END_METHOD

        //处理状态
        METHOD PUBLIC HandleState
            VAR_INPUT
                context : REF_TO FeedingMachine;
                tank : REF_TO Tank;
                feedAxis : REF_TO PosAxis;
            END_VAR
            VAR_EXTERNAL
                powerOn :BOOL;
                powerOff : BOOL;
            END_VAR

            THIS._tank := tank;
            THIS._feedAxis := feedAxis;
        
            //执行Action
            THIS.ExcuteJob();
        
            //等待可跳转信号
            IF powerOn AND NOT(powerOff) THEN
                //切换到FillSink状态对象
                context^.SetState(context^.GetFillTankState(),_tank,_feedAxis);  
            END_IF;    
        END_METHOD
        
        //获取状态
        METHOD PUBLIC GetState : STRING
            GetState:='OFF';
        END_METHOD

    END_CLASS
   
END_NAMESPACE