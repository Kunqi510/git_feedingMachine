USING TankLib;
USING Siemens.Simatic.S71500.MotionControl.Native;
USING Siemens.Simatic.Motion;
NAMESPACE Siemens.Simatic.StateMachine

    CLASS PUBLIC ErrorState IMPLEMENTS IState
        VAR
            _feedAxis : REF_TO PosAxis;        
            _tank : REF_TO Tank;
            canGoNext : BOOL := FALSE; 
        END_VAR
        //执行动作逻辑          
        METHOD PUBLIC ExcuteJob
            VAR_EXTERNAL
                resetError : BOOL; 
            END_VAR
            IF resetError THEN
                canGoNext := TRUE;
                _feedAxis^.ResetAxis();
            END_IF;
        END_METHOD

        //处理状态
        METHOD PUBLIC HandleState
            VAR_INPUT
                context : REF_TO FeedingMachine;
                tank : REF_TO Tank;
                feedAxis : REF_TO PosAxis;
            END_VAR
            VAR_EXTERNAL
                sinkEmptySensor : BOOL;
                axisStop : BOOL;
                powerOff : BOOL;
                tankEmptySensor : BOOL;
            END_VAR
            THIS._tank := tank;
            THIS._feedAxis := feedAxis;
            
            //执行Action
            THIS.ExcuteJob();
            
            //断电或空罐
            IF powerOff THEN
                 //切换到OFFState状态对象
                context^.SetState(context^.GetOffState(),_tank,_feedAxis);
            END_IF;
            
            //等待可跳转信号
            IF canGoNext THEN
                canGoNext := FALSE;
                IF NOT _feedAxis^.GetAxisStatus().error THEN
                    //切换到StopState状态对象
                    context^.SetState(context^.GetStopState(),_tank,_feedAxis);            
                END_IF; 
            END_IF;                        
        END_METHOD
        
        //获取状态
        METHOD PUBLIC GetState : STRING
            GetState:='Error';
        END_METHOD

    END_CLASS

END_NAMESPACE