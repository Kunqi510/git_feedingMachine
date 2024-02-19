USING Siemens.Simatic.S71500.MotionControl.Native;
NAMESPACE Siemens.Simatic.Motion

    CLASS PUBLIC SpeedAxis

        VAR PROTECTED
            _axisAsSpeed : REF_TO TO_SpeedAxis;
            _axisAsAxis : REF_TO TO_Axis;
            _mcPower : MC_POWER;
            _mcReset : MC_RESET;
            _mcJog : MC_MOVEJOG;
            _mcHalt : MC_HALT;
            _mcMoveVel : MC_MOVEVELOCITY;
            _axisData : AxisData;
            _axisDB : DB_ANY;
        END_VAR

        METHOD PUBLIC Attach : BOOL
            VAR_INPUT
                axisDB : DB_ANY;
            END_VAR
            _axisDB := axisDB;
            Attach := THIS.RefToAxisIsValid();
            THIS.CallMcBlocksSpeedAxis();
        END_METHOD

        METHOD PUBLIC ResetCmds
            _mcReset.Execute := FALSE;
            _mcHalt.Execute := FALSE;
            _mcMoveVel.Execute := FALSE;
        END_METHOD

        METHOD PUBLIC EnableAxis
            VAR_INPUT
                startMode : INT;
            END_VAR
            _mcPower.StartMode := startMode;
            _mcPower.Enable := TRUE;
            _axisData.cmd := AxisCmd#ENABLE;
        END_METHOD

        METHOD PUBLIC DisableAxis
            VAR_INPUT
                stopMode : INT;
            END_VAR
            _mcPower.StopMode := stopMode;
            _mcPower.Enable := FALSE;
            _axisData.cmd := AxisCmd#DISABLE;
        END_METHOD

        METHOD PUBLIC ResetAxis
                _mcReset.Execute := TRUE;
                _axisData.cmd := AxisCmd#RESET;
                IF _mcReset.Done THEN
                    _axisData.cmd := AxisCmd#NONE;
                    _mcHalt.Execute := FALSE;
                END_IF;
        END_METHOD

        METHOD PUBLIC StopAxis
            VAR_INPUT
                deceleration : LREAL;
                jerk : LREAL;
                abortAcceleration : BOOL;
            END_VAR
            _mcHalt.Deceleration := deceleration;
            _mcHalt.Jerk := jerk;
            _mcHalt.AbortAcceleration := abortAcceleration;
            _mcHalt.Execute := TRUE;
            _axisData.cmd := AxisCmd#STOP;
            IF _mcHalt.Done THEN
                _axisData.cmd := AxisCmd#NONE;
                _mcHalt.Execute := FALSE;
            END_IF;
        END_METHOD

        METHOD PUBLIC MoveVelocity
            VAR_INPUT
                velocity : LREAL;
                acceleration : LREAL;
                deceleration : LREAL;
                jerk : LREAL;
                direction : INT;
                maintainCurrentVel : BOOL;
            END_VAR
            _mcMoveVel.velocity := velocity;
            _mcMoveVel.Acceleration := acceleration;
            _mcMoveVel.Deceleration := deceleration;
            _mcMoveVel.Jerk := jerk;
            _mcMoveVel.direction := direction;
            _mcMoveVel.Current := maintainCurrentVel;
            _mcMoveVel.Execute := TRUE;
            IF _mcMoveVel.CommandAborted THEN
                _axisData.cmd := AxisCmd#NONE;
                _mcMoveVel.Execute := FALSE;
            END_IF;
        END_METHOD

        METHOD PUBLIC GetAxisStatus : AxisData
            _axisData.enabled := _mcPower.Status;
            IF _mcPower.Error THEN
                _axisData.error := TRUE;
                _axisData.errorID := _mcPower.ErrorId;
            ELSIF _mcReset.Error THEN
                _axisData.error := TRUE;
                _axisData.errorID := _mcReset.ErrorId;
            ELSIF _mcHalt.Error THEN
                _axisData.error := TRUE;
                _axisData.errorID := _mcHalt.ErrorId;
            ELSIF _mcMoveVel.Error THEN
                _axisData.error := TRUE;
                _axisData.errorID := _mcMoveVel.ErrorId;
            ELSE
                _axisData.error := FALSE;
                _axisData.errorID := WORD#16#0000;
            END_IF;
            _axisData.actSpeed := _axisAsSpeed^.ActualSpeed;
            GetAxisStatus := _axisData;
        END_METHOD

        METHOD PROTECTED CallMcBlocksSpeedAxis
            IF NOT THIS.RefToAxisIsValid() THEN
                RETURN;
            ELSE
                _axisAsSpeed := AsSpeedAxisRef(_axisDB);
                _axisAsAxis := AsAxisRef(_axisDB);
                _mcPower(Axis := _axisAsAxis^);
                _mcReset(Axis := _axisAsAxis^);
                _mcHalt(Axis := _axisAsSpeed^);
                _mcJog(Axis := _axisAsSpeed^);
                _mcMoveVel(Axis := _axisAsSpeed^);
            END_IF;
        END_METHOD

        METHOD PROTECTED RefToAxisIsValid : BOOL
                _axisAsSpeed := AsSpeedAxisRef(_axisDB);
                RefToAxisIsValid := _axisAsSpeed <> NULL;
        END_METHOD
        
    END_CLASS

END_NAMESPACE