USING TankLib;
USING Siemens.Simatic.S71500.MotionControl.Native;
USING Siemens.Simatic.Motion;
NAMESPACE Siemens.Simatic.StateMachine

    CLASS PUBLIC FeedingMachine
        VAR
            //聚合轴，原料罐及状态接口
            _feedAxis : REF_TO PosAxis;        
            _tank : REF_TO Tank;
            state : IState;
            //组合各种状态对象
            offInst : OffState;
            fillTankInst: FillTankState;      
            fillSinkInst: FillSinkState;
            readyInst : ReadyState;
            runInst : RunState;
            stopInst : StopState;
            errorInst : ErrorState;
        END_VAR

        //切换状态对象
        METHOD PUBLIC SetState
            VAR_INPUT
             stateInst : IState;       
             tank : REF_TO Tank; 
             feedAxis : REF_TO PosAxis;   
            END_VAR
            THIS.state := stateInst;
            THIS._tank := tank;
            THIS._feedAxis := feedAxis;            
        END_METHOD
        
        //触发状态改变
        METHOD PUBLIC Excute 
            THIS.state.HandleState(REF(THIS), THIS._tank, THIS._feedAxis);
        END_METHOD

        //获取当前状态
        METHOD PUBLIC GetCurrentState : STRING
            GetCurrentState := THIS.state.GetState();
        END_METHOD

        //获取各个状态类对象
        METHOD PUBLIC GetOffState : IState
            GetOffState := offInst;
        END_METHOD

        METHOD PUBLIC GetFillTankState : IState
            GetFillTankState := fillTankInst;
        END_METHOD

        METHOD PUBLIC GetFillSinkState : IState
            GetFillSinkState := fillSinkInst;
        END_METHOD

        METHOD PUBLIC GetReadyState : IState
            GetReadyState := readyInst;
        END_METHOD

        METHOD PUBLIC GetRunState : IState
            GetRunState := runInst;
        END_METHOD
        
        METHOD PUBLIC GetStopState : IState
            GetStopState := stopInst;
        END_METHOD

        METHOD PUBLIC GetErrorState : IState
            GetErrorState := errorInst;
        END_METHOD

    END_CLASS

END_NAMESPACE