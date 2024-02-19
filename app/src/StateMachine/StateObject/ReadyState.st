USING TankLib;
USING Siemens.Simatic.S71500.MotionControl.Native;
USING Siemens.Simatic.Motion; 
NAMESPACE Siemens.Simatic.StateMachine

    CLASS PUBLIC ReadyState IMPLEMENTS IState
        VAR 
            _feedAxis : REF_TO PosAxis;        
            _tank : REF_TO Tank;
            canGoNext : BOOL := FALSE; 
        END_VAR

        //执行动作逻辑
        METHOD PUBLIC ExcuteJob
            VAR_EXTERNAL
                axisStart : BOOL;
                errorID : WORD;   
            END_VAR                      
            _tank^.close();
            IF axisStart THEN
                _feedAxis^.EnableAxis(startmode := 1);       
                _feedAxis^.HomeAxis(position := 0.0, homingMode := 0);        
                canGoNext:=TRUE;      
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
                powerOff : BOOL;
                tankEmptySensor : BOOL;
                errorID : WORD;
                sinkEmptySensor:Bool;
            END_VAR

            THIS._tank := tank;
            THIS._feedAxis := feedAxis;

            //执行Action
            THIS.ExcuteJob();
            //轴控错误
            IF _feedAxis^.GetAxisStatus().Error THEN
                //切换到Error状态对象
                context^.SetState(context^.GetErrorState(),_tank,_feedAxis);;
            END_IF;

            //断电或空罐
            IF powerOff OR tankEmptySensor THEN
                 //切换到OFFState状态对象
                context^.SetState(context^.GetOffState(),_tank,_feedAxis);
            END_IF;

            //等待可跳转信号
            IF canGoNext AND NOT(sinkEmptySensor) AND _feedAxis^.GetAxisStatus().enabled AND _feedAxis^.GetAxisStatus().homed THEN
                canGoNext:=FALSE;
                //切换到RunState状态对象
                context^.SetState(context^.GetRunState(),_tank,_feedAxis);
            END_IF;
        END_METHOD
        
        //获取状态
        METHOD PUBLIC GetState : STRING
            GetState:='Ready';
        END_METHOD

    END_CLASS

END_NAMESPACE