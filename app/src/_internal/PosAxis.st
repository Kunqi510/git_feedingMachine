USING Siemens.Simatic.S71500.MotionControl.Native;
NAMESPACE Siemens.Simatic.Motion

    CLASS PUBLIC PosAxis EXTENDS SpeedAxis

        VAR PROTECTED
            _axisAsPos : REF_TO TO_PositioningAxis;
            _mcHome : MC_HOME;
            _mcMoveRel : MC_MOVERELATIVE;
            _mcMoveAbs : MC_MOVEABSOLUTE;
        END_VAR

        METHOD PUBLIC OVERRIDE Attach : BOOL 
            VAR_INPUT
                axisDB : DB_ANY;
            END_VAR
            _axisDB := axisDB;
            Attach := THIS.RefToAxisIsValid();
            SUPER.CallMcBlocksSpeedAxis();
            THIS.CallMcBlocksPosAxis();
        END_METHOD

        METHOD PUBLIC OVERRIDE ResetCmds
            SUPER.ResetCmds();
            _mcHome.Execute := FALSE;
            _mcMoveRel.Execute := FALSE;
            _mcMoveAbs.Execute := FALSE;
        END_METHOD

        METHOD PUBLIC HomeAxis
            VAR_INPUT
                position : LREAL;
                homingMode : INT;
            END_VAR
            _mcHome.Mode := homingMode;
            _mcHome.Position := position;
            _mcHome.Execute := TRUE;
            _axisData.cmd := AxisCmd#HOME;
        END_METHOD

        METHOD PUBLIC PosRelative
            VAR_INPUT
                distance : LREAL;
                velocity : LREAL;
                acceleration : LREAL;
                deceleration : LREAL;
                jerk : LREAL;
            END_VAR
            _mcMoveRel.Execute := TRUE;
            _mcMoveRel.Distance := distance;
            _mcMoveRel.velocity := velocity;
            _mcMoveRel.Acceleration := acceleration;
            _mcMoveRel.Deceleration := deceleration;
            _axisData.cmd := AxisCmd#POS_RELATIVE;
        END_METHOD

        METHOD PUBLIC PosAbsolute
            VAR_INPUT
                position : LREAL;
                velocity : LREAL;
                acceleration : LREAL;
                deceleration : LREAL;
                jerk : LREAL;
                direction : INT;
            END_VAR
            _mcMoveAbs.Execute := TRUE;
            _mcMoveAbs.Position := position;
            _mcMoveAbs.velocity := velocity;
            _mcMoveAbs.Acceleration := acceleration;
            _mcMoveAbs.Deceleration := deceleration;
            _mcMoveAbs.Jerk := -1;
            IF direction > 0 THEN
                _mcMoveAbs.Direction := direction;
            ELSE
                _mcMoveAbs.Direction := 1;
            END_IF;
            _axisData.cmd := AxisCmd#POS_ABSOLUTE;
        END_METHOD

        METHOD PUBLIC OVERRIDE GetAxisStatus : AxisData
            _axisData.enabled := _mcPower.Status;
            _axisData.homed := _axisAsPos^.StatusWord.%X5;
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
            ELSIF _mcHome.Error THEN
                _axisData.error := TRUE;
                _axisData.errorID := _mcHome.ErrorId;
            ELSIF _mcMoveRel.Error THEN 
                _axisData.error := TRUE;
                _axisData.errorID := _mcMoveRel.ErrorId;
            ELSIF _mcMoveAbs.Error THEN
                _axisData.error := TRUE;
                _axisData.errorID := _mcMoveAbs.ErrorId;
            ELSE
                _axisData.error := FALSE;
                _axisData.errorID := WORD#16#0000;
            END_IF;
            _axisData.actVelocity := _axisAsPos^.ActualVelocity;
            _axisData.actPosition := _axisAsPos^.ActualPosition;
            GetAxisStatus := _axisData;
        END_METHOD

        METHOD PROTECTED CallMcBlocksPosAxis
            _axisAsPos := AsPositioningAxisRef(_axisDB);
            _axisAsAxis := _axisAsPos;
            IF _axisAsPos <> NULL THEN
                _mcHome(Axis := _axisAsAxis^);
                _mcMoveRel(Axis := _axisAsPos^);
                _mcMoveAbs(Axis := _axisAsPos^);
                IF _mcHome.Done THEN
                    _axisData.cmd := AxisCmd#NONE;
                    _mcHome.Execute := FALSE;
                END_IF;

                IF _mcMoveRel.Done OR _mcMoveRel.CommandAborted THEN
                    _mcMoveRel.Execute := FALSE;
                END_IF;

                IF _mcMoveAbs.Done OR _mcMoveAbs.CommandAborted THEN
                    _mcMoveAbs.Execute := FALSE;
                END_IF;
            ELSE
                RETURN;
            END_IF;
        END_METHOD

        METHOD PROTECTED OVERRIDE RefToAxisIsValid : BOOL
            _axisAsPos := AsPositioningAxisRef(_axisDB);
            RefToAxisIsValid := _axisAsPos <> NULL;
        END_METHOD

    END_CLASS

END_NAMESPACE