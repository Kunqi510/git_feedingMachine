USING TankLib;
USING Siemens.Simatic.S71500.MotionControl.Native;
USING Siemens.Simatic.Motion; 
NAMESPACE Siemens.Simatic.StateMachine

    CLASS PUBLIC StopState IMPLEMENTS IState
        VAR
            _feedAxis : REF_TO PosAxis;        
            _tank : REF_TO Tank; 
        END_VAR
         
        //执行动作逻辑
        METHOD PUBLIC ExcuteJob
            _feedAxis^.StopAxis(deceleration := -1.0, jerk := -3.0);
        END_METHOD

        //处理状态
        METHOD PUBLIC HandleState
            VAR_INPUT
                context : REF_TO FeedingMachine;
                tank : REF_TO Tank;
                feedAxis : REF_TO PosAxis;
            END_VAR
            VAR_EXTERNAL
                axisStart : BOOL;
                axisStop : BOOL;
                powerOff : BOOL;
                tankEmptySensor : BOOL;
                errorID : WORD;
            END_VAR           
            THIS._tank:=tank;
            THIS._feedAxis:=feedAxis;

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
            IF axisStart AND NOT axisStop THEN
                //切换到FillSinkState状态对象
                context^.SetState(context^.GetFillSinkState(),_tank,_feedAxis);
            END_IF;
                        
        END_METHOD
        
        //获取状态
        METHOD PUBLIC GetState : STRING
            GetState:='Stoped';
        END_METHOD

    END_CLASS

END_NAMESPACE