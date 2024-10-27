; Using Keyboard Numpad as a Mouse -- by deguix
; http://www.autohotkey.com
; This script makes mousing with your keyboard almost as easy
; as using a real mouse (maybe even easier for some tasks).
; It supports up to five mouse buttons and the turning of the
; mouse wheel.  It also features customizable movement speed,
; acceleration, and "axis inversion".

/*
o----------------------------------------------------------------------------------------o
|Using Keyboard Numpad as a Mouse                                                        |
(----------------------------------------------------------------------------------------)
| ver. 1.0 by deguix  / A Script file for AutoHotkey 1.0.22+                             |
|                    --------------------------------------------------------------------|
|                                                                                        |
| This script is an example of use of AutoHotkey. It uses the remapping of numpad keys   |
| of a keyboard to transform it into a mouse. Some features are the acceleration which   |
| enables you to increase the mouse movement when holding a key for a long time, and the |
| rotation which makes the numpad mouse to "turn". I.e. NumpadDown as NumpadUp and       |
| vice-versa. See the list of keys used below:                                           |
|                                                                                        |
|----------------------------------------------------------------------------------------|
| Keys                  | Description                                                    |
|----------------------------------------------------------------------------------------|
| ScrollLock (toggle on)| Activates numpad mouse mode.                                   |
|-----------------------|----------------------------------------------------------------|
| Numpad0               | Left mouse button click.                                       |
| Numpad5               | Middle mouse button click.                                     |
| NumpadDot             | Right mouse button click.                                      |
| NumpadDiv/NumpadMult  | X1/X2 mouse button click. (Win 2k+)                            |
| NumpadSub/NumpadAdd   | Moves up/down the mouse wheel.                                 |
|                       |                                                                |
|-----------------------|----------------------------------------------------------------|
| NumLock (toggled off) | Activates mouse movement mode.                                 |
|-----------------------|----------------------------------------------------------------|
| NumpadEnd/Down/PgDn/  | Mouse movement.                                                |
| /Left/Right/Home/Up/  |                                                                |
| /PgUp                 |                                                                |
|                       |                                                                |
|-----------------------|----------------------------------------------------------------|
| ctrl+                 |                                                                |
| NumpadEnd/Down/PgDn/  | Mouse movement on lattice.                                     |
| /Left/Right/Home/Up/  |                                                                |
| /PgUp                 |                                                                |
|                       |                                                                |
|-----------------------|----------------------------------------------------------------|
| NumLock (toggled on)  | Activates mouse speed adj. mode.                               |
|-----------------------|----------------------------------------------------------------|
| Numpad7/Numpad1       | Inc./dec. acceleration per button press.                       |
| Numpad8/Numpad2       | Inc./dec. initial speed per button press.                      |
| Numpad9/Numpad3       | Inc./dec. maximum speed per button press.                      |
| !Numpad7/^Numpad1     | Inc./dec. wheel acceleration per button press*.                |
| !Numpad8/^Numpad2     | Inc./dec. wheel initial speed per button press*.               |
| !Numpad9/^Numpad3     | Inc./dec. wheel maximum speed per button press*.               |
| Numpad4/Numpad6       | Inc./dec. rotation angle to right in degrees. (i.e. 180° =     |
|                       | = inversed controls).                                          |
|----------------------------------------------------------------------------------------|
| * = These options are affected by the mouse wheel speed    |
| adjusted on Control Panel. If you don't have a mouse with  |
| wheel, the default is 3 +/- lines per option button press. |
o------------------------------------------------------------o
| Change log                                                 |
|------------------------------------------------------------|
| 1.01 by mslonik       | Added saving of config param into  |
|                       | file (NumpadMouse.ini):            |
|                       |    MouseSpeed                      |
|                       |    MouseAccelerationSpeed          |
|                       |    MouseMaxSpeed                   |
|                       |    MouseWheelSpeed                 |
|                       |    MouseWheelAccelerationSpeed     |
|                       |    MouseWheelMaxSpeed              |
|                       |    MouseRotationAngle              |
|                       | Added tooltips for ScrollLock and  |
|                       | NumLock                            |
|------------------------------------------------------------|
| 1.02 by mslonik       | Added menu info about app.         |
|------------------------------------------------------------|
| 1.03 by mslonik       | Added X2 (NumPadMul) to center     |
|                       | cursor within active window area.  |
|                       | Optimized saving of parameters     |
o------------------------------------------------------------o
| 2.01 by e-zz 		    | Added support for:				 |
|						|	 lattice movement 				 |
| 						|    arrow combo key                 |
| 						|	 mouse leaping    				 |
o------------------------------------------------------------o
| 2.02 by e-zz 		    | Fix DPI problem for monitors		 |
o------------------------------------------------------------o
*/

;START OF CONFIG SECTION
#SingleInstance force
#MaxHotkeysPerInterval 500

; Using the keyboard hook to implement the Numpad hotkeys prevents them from interfering with the generation of ANSI characters such
; as ŕ.  This is because AutoHotkey generates such characters by holding down ALT and sending a series of Numpad keystrokes.
; Hook hotkeys are smart enough to ignore such keystrokes.
#UseHook

Menu, Tray, Icon, ddores.dll, 106 	; this line will turn the H icon into a small keyboard-mouse looking thing

ApplicationName := "NumpadMouse"
Gosub, INIREAD        ; Jumps to the specified label and continues execution until Return is encountered
Gosub, TRAYMENU       ; Jumps to the specified label and continues execution until Return is encountered

;END OF CONFIG SECTION


;This is needed or key presses would faulty send their natural actions. Like NumpadDiv would send sometimes "/" to the screen.       
#InstallKeybdHook

Temp = 0
Temp2 = 0

RestoreDPI:=DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr") ; enable per-monitor DPI awareness and save current value to restore it when done - thanks to lexikos for this

SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory: the directory containing the script.

; MsgBox, The current working directory is: %A_WorkingDir%, while the script directory is: %A_ScriptDir%.

MouseRotationAnglePart = %MouseRotationAngle%
;Divide by 45ş because MouseMove only supports whole numbers and changing the mouse rotation to a number lesser than 45ş
;could make strange movements.
;For example: 22.5ş when pressing NumpadUp: First it would move upwards until the speed to the side reaches 1.
MouseRotationAnglePart /= 45

MouseCurrentAccelerationSpeed = 0
MouseCurrentSpeed = %MouseSpeed%

MouseWheelCurrentAccelerationSpeed = 0
MouseWheelCurrentSpeed = %MouseSpeed%

SetKeyDelay, -1
SetMouseDelay, -1

Hotkey, *Numpad0, ButtonLeftClick
Hotkey, *NumpadIns, ButtonLeftClickIns
Hotkey, *Numpad5, ButtonMiddleClick
Hotkey, *NumpadClear, ButtonMiddleClickClear
Hotkey, *NumpadDot, ButtonRightClick
Hotkey, *NumpadDel, ButtonRightClickDel
Hotkey, *NumpadDiv, ButtonX1Click
Hotkey, *NumpadMult, ButtonX2Click

Hotkey, *NumpadSub, ButtonWheelUp
Hotkey, *NumpadAdd, ButtonWheelDown
Hotkey, #NumpadSub, ButtonWheelLeft
Hotkey, #NumpadAdd, ButtonWheelRight

Hotkey, *NumpadUp, ButtonUp
Hotkey, *NumpadDown, ButtonDown
Hotkey, *NumpadLeft, ButtonLeft
Hotkey, *NumpadRight, ButtonRight
Hotkey, *NumpadHome, ButtonUpLeft
Hotkey, *NumpadEnd, ButtonUpRight
Hotkey, *NumpadPgUp, ButtonDownLeft
Hotkey, *NumpadPgDn, ButtonDownRight

Hotkey, ^NumpadUp, ButtonUpGrid
Hotkey, ^NumpadDown, ButtonDownGrid
Hotkey, ^NumpadLeft, ButtonLeftGrid
Hotkey, ^NumpadRight, ButtonRightGrid
Hotkey, ^NumpadHome, ButtonUpLeftGrid
Hotkey, ^NumpadEnd, ButtonUpRightGrid
Hotkey, ^NumpadPgUp, ButtonDownLeftGrid
Hotkey, ^NumpadPgDn, ButtonDownRightGrid

Hotkey, Numpad8, ButtonSpeedUp
Hotkey, Numpad2, ButtonSpeedDown
Hotkey, Numpad7, ButtonAccelerationSpeedUp
Hotkey, Numpad1, ButtonAccelerationSpeedDown
Hotkey, Numpad9, ButtonMaxSpeedUp
Hotkey, Numpad3, ButtonMaxSpeedDown

Hotkey, Numpad6, ButtonRotationAngleUp
Hotkey, Numpad4, ButtonRotationAngleDown

Hotkey, !Numpad8, ButtonWheelSpeedUp
Hotkey, !Numpad2, ButtonWheelSpeedDown
Hotkey, !Numpad7, ButtonWheelAccelerationSpeedUp
Hotkey, !Numpad1, ButtonWheelAccelerationSpeedDown
Hotkey, !Numpad9, ButtonWheelMaxSpeedUp
Hotkey, !Numpad3, ButtonWheelMaxSpeedDown

Gosub, ~ScrollLock  ; Initialize based on current ScrollLock state.
return

;Key activation support

~^NumpadDiv:: reload
return 

~^+NumpadDiv:: exitapp 
return 

~^NumpadMult:: 
MouseClick WheelRight,,, 6, 0
return 
; WheelRight
~ScrollLock::
; Wait for it to be released because otherwise the hook state gets reset
; while the key is down, which causes the up-event to get suppressed,
; which in turn prevents toggling of the ScrollLock state/light:
KeyWait, ScrollLock
GetKeyState, ScrollLockState, ScrollLock, T
If ScrollLockState 
{
	ToolTip, NumPadMouse activated
	SetTimer, RemoveToolTip, 1000
	
	Hotkey, *Numpad0, On
	Hotkey, *NumpadIns, On
	Hotkey, *Numpad5, On
	Hotkey, *NumpadDot, On
	Hotkey, *NumpadDel, On
	Hotkey, *NumpadDiv, On
	Hotkey, *NumpadMult, On

	Hotkey, *NumpadSub, On
	Hotkey, *NumpadAdd, On

	Hotkey, *NumpadUp, On
	Hotkey, *NumpadDown, On
	Hotkey, *NumpadLeft, On
	Hotkey, *NumpadRight, On
	Hotkey, *NumpadHome, On
	Hotkey, *NumpadEnd, On
	Hotkey, *NumpadPgUp, On
	Hotkey, *NumpadPgDn, On

	Hotkey, Numpad8, On
	Hotkey, Numpad2, On
	Hotkey, Numpad7, On
	Hotkey, Numpad1, On
	Hotkey, Numpad9, On
	Hotkey, Numpad3, On

	Hotkey, Numpad6, On
	Hotkey, Numpad4, On

	Hotkey, !Numpad8, On
	Hotkey, !Numpad2, On
	Hotkey, !Numpad7, On
	Hotkey, !Numpad1, On
	Hotkey, !Numpad9, On
	Hotkey, !Numpad3, On
}
else
{
	ToolTip, NumPadMouse deactivated
	SetTimer, RemoveToolTip, 1000
	
	Hotkey, *Numpad0, Off
	Hotkey, *NumpadIns, Off
	Hotkey, *Numpad5, Off
	Hotkey, *NumpadDot, Off
	Hotkey, *NumpadDel, Off
	Hotkey, *NumpadDiv, Off
	Hotkey, *NumpadMult, Off

	Hotkey, *NumpadSub, Off
	Hotkey, *NumpadAdd, Off

	Hotkey, *NumpadUp, Off
	Hotkey, *NumpadDown, Off
	Hotkey, *NumpadLeft, Off
	Hotkey, *NumpadRight, Off
	Hotkey, *NumpadHome, Off
	Hotkey, *NumpadEnd, Off
	Hotkey, *NumpadPgUp, Off
	Hotkey, *NumpadPgDn, Off

	Hotkey, Numpad8, Off
	Hotkey, Numpad2, Off
	Hotkey, Numpad7, Off
	Hotkey, Numpad1, Off
	Hotkey, Numpad9, Off
	Hotkey, Numpad3, Off

	Hotkey, Numpad6, Off
	Hotkey, Numpad4, Off

	Hotkey, !Numpad8, Off
	Hotkey, !Numpad2, Off
	Hotkey, !Numpad7, Off
	Hotkey, !Numpad1, Off
	Hotkey, !Numpad9, Off
	Hotkey, !Numpad3, Off
}
return


~NumLock:: ; NumLock key support
KeyWait, NumLock
NumLockState := GetKeyState("NumLock", "T")

;~ GetKeyState, ScrollLockState, ScrollLock, T
if (NumLockState)
{
	ToolTip, NumPadMouse configuration mode ACTIVATED
	SetTimer, RemoveToolTip, 1000
}
else
{
	ToolTip, NumPadMouse configuration mode DEACTIVATED and configuration SAVED
	SetTimer, RemoveToolTip, 1000
	IniWrite, %MouseSpeed%, %ApplicationName%.ini, MouseSpeed, MouseSpeed
	IniWrite, %MouseAccelerationSpeed%, %ApplicationName%.ini, MouseSpeed, MouseAccelerationSpeed
	IniWrite, %MouseMaxSpeed%, %ApplicationName%.ini, MouseSpeed, MouseMaxSpeed
	
	IniWrite, %MouseWheelSpeed%, %ApplicationName%.ini, MouseWheel, MouseWheelSpeed
	IniWrite, %MouseWheelAccelerationSpeed%, %ApplicationName%.ini, MouseWheel, MouseWheelAccelerationSpeed
	IniWrite, %MouseWheelMaxSpeed%, %ApplicationName%.ini, MouseWheel, MouseWheelMaxSpeed

	IniWrite, %MouseRotationAngle%, %ApplicationName%.ini, MouseRotationAngle, MouseRotationAngle
}	
return

;Mouse click support

ButtonLeftClick:
GetKeyState, already_down_state, LButton
If already_down_state = D
	return
Button2 = Numpad0
ButtonClick = Left
Goto ButtonClickStart
ButtonLeftClickIns:
GetKeyState, already_down_state, LButton
If already_down_state = D
	return
Button2 = NumpadIns
ButtonClick = Left
Goto ButtonClickStart

ButtonMiddleClick:
GetKeyState, already_down_state, MButton
If already_down_state = D
	return
Button2 = Numpad5
ButtonClick = Middle
Goto ButtonClickStart
ButtonMiddleClickClear:
GetKeyState, already_down_state, MButton
If already_down_state = D
	return
Button2 = NumpadClear
ButtonClick = Middle
Goto ButtonClickStart

ButtonRightClick:
GetKeyState, already_down_state, RButton
If already_down_state = D
	return
Button2 = NumpadDot
ButtonClick = Right
Goto ButtonClickStart
ButtonRightClickDel:
GetKeyState, already_down_state, RButton
If already_down_state = D
	return
Button2 = NumpadDel
ButtonClick = Right
Goto ButtonClickStart

ButtonX1Click:
GetKeyState, already_down_state, XButton1
If already_down_state = D
	return
Button2 = NumpadDiv
ButtonClick = X1
Goto ButtonClickStart

ButtonX2Click:
GetKeyState, already_down_state, XButton2
If already_down_state = D
	return
Button2 = NumpadMult
ButtonClick = X2
Goto MouseLeap

ButtonClickStart: 
MouseClick, %ButtonClick%,,, 1, 0, D
SetTimer, ButtonClickEnd, 10
return

ButtonClickEnd:
GetKeyState, kclickstate, %Button2%, P
if kclickstate = D
	return
; key released, so turn off repeated timer
SetTimer, ButtonClickEnd, Off
MouseClick, %ButtonClick%,,, 1, 0, U
; now release the mouse button  
return

MouseLeap:
WinGetActiveStats, Title, Width, Height, X, Y
; MouseMove, X + Width/2, Y + Height/2,0 ; not working well on multi-monitors
DllCall("SetCursorPos", "int",  X + Width/2, "int", Y + Height/2)
ToolTip, % "X: " . X " Y: " . Y " Width: " . Width " Height: " . Height " Pos x: " . X + Width/2 " Pos y: " Y + Height/2
SetTimer, RemoveToolTip, 1000
return

; Done leap on a lattice?
;Mouse movement support

ButtonSpeedUp:
	MouseSpeed++
	ToolTip, Mouse speed: %MouseSpeed% pixels
	SetTimer, RemoveToolTip, 1000
	IniWrite, %MouseSpeed%, %ApplicationName%.ini, MouseSpeed, MouseSpeed
return
ButtonSpeedDown:
	if (MouseSpeed > 1) {
		MouseSpeed--
	}
	if (MouseSpeed = 1) {
		ToolTip, Mouse speed: %MouseSpeed% pixel
	} else {
		ToolTip, Mouse speed: %MouseSpeed% pixels
	}
	SetTimer, RemoveToolTip, 1000
return

ButtonAccelerationSpeedUp:
	MouseAccelerationSpeed++
	ToolTip, Mouse acceleration speed: %MouseAccelerationSpeed% pixels
	SetTimer, RemoveToolTip, 1000
return
ButtonAccelerationSpeedDown:
	if (MouseAccelerationSpeed > 1) {
		MouseAccelerationSpeed--
	}
	if (MouseAccelerationSpeed = 1) {
		ToolTip, Mouse acceleration speed: %MouseAccelerationSpeed% pixel
	} else {
		ToolTip, Mouse acceleration speed: %MouseAccelerationSpeed% pixels
	}
	SetTimer, RemoveToolTip, 1000
return

ButtonMaxSpeedUp:
	MouseMaxSpeed++
	ToolTip, Mouse maximum speed: %MouseMaxSpeed% pixels
	SetTimer, RemoveToolTip, 1000
return
ButtonMaxSpeedDown:
	if (MouseMaxSpeed > 1) {
		MouseMaxSpeed--
	}
	if (MouseMaxSpeed = 1) {
		ToolTip, Mouse maximum speed: %MouseMaxSpeed% pixel
	} else {
		ToolTip, Mouse maximum speed: %MouseMaxSpeed% pixels
	}
	SetTimer, RemoveToolTip, 1000
return

ButtonRotationAngleUp:
	MouseRotationAnglePart++
	if (MouseRotationAnglePart >= 8) {
		MouseRotationAnglePart = 0
	}
	MouseRotationAngle = %MouseRotationAnglePart%
	MouseRotationAngle *= 45
	ToolTip, Mouse rotation angle: %MouseRotationAngle%°
	SetTimer, RemoveToolTip, 1000
return
ButtonRotationAngleDown:
	MouseRotationAnglePart--
	if (MouseRotationAnglePart < 0) {
		MouseRotationAnglePart = 7
	}
	MouseRotationAngle = %MouseRotationAnglePart%
	MouseRotationAngle *= 45
	ToolTip, Mouse rotation angle: %MouseRotationAngle%
	SetTimer, RemoveToolTip, 1000
return



ButtonUpGrid:
ButtonDownGrid:
ButtonLeftGrid:
ButtonRightGrid:
ButtonUpLeftGrid:
ButtonUpRightGrid:
ButtonDownLeftGrid:
ButtonDownRightGrid:

StringReplace, Button, A_ThisHotkey, ^ ; trim "*" char in A_ThisHotkey. E.g., *NumpadUp → NumpadUp
ButtonGridLongPressStart:
{
	; TODO add rotation support
	; TODO add acceleration support
	; TODO add combo support

	; Get monitor size, assign to win_width and win_height 
	Sysget, win_width, 78
	Sysget, win_height , 79
	; MsgBox, %win_height%, %win_width%
	x_grid_num = 18
	y_grid_num = 6
	x_grid_size := win_width/x_grid_num
	y_grid_size := win_height/y_grid_num
	; MsgBox, %x_grid_size%, %y_grid_size%
	If (Button = "NumpadUp") {
		MouseMove, 0, -y_grid_size,20, R
	} Else If (Button = "NumpadDown") {
		MouseMove, 0, y_grid_size, 20, R
	} Else If (Button = "NumpadLeft") {
		MouseMove, -x_grid_size, 0, 20, R
	} Else If (Button = "NumpadRight") {
		MouseMove, x_grid_size, 0, 20, R
	} Else If (Button = "NumpadHome") {
		MouseMove, -x_grid_size, -y_grid_size, 20, R
	} Else If (Button = "NumpadEnd") {
		MouseMove, -x_grid_size, y_grid_size, 20, R
	} Else If (Button = "NumpadPgUp") {
		MouseMove, x_grid_size, -y_grid_size, 20, R
	} Else If (Button = "NumpadPgDn") {
		MouseMove, x_grid_size, y_grid_size, 20, R
	}
	SetTimer, ButtonGridLongPressEnd, 200
	return
}

ButtonGridLongPressEnd:
; acc ends check on comboButton
; GetKeyState, kstate, %Button%, P

released := true	; true when all keys are released after comboButton is released
one_only := false  ; true when only one key is released after comboButton is released
; if (comboButton != "") {

;     for index, key in combinations[comboButton] {
;         if (GetKeyState(key, "P")) {
;             released := false
; 			one_only := !one_only
;         }
;     }

; 	if (one_only) {
; 		for index, key in combinations[comboButton] {
; 			if (GetKeyState(key, "P")) {
; 				button := key
; 				break
; 			}
; 		}
;     }


; } else {
	GetKeyState, kstate, %Button%, P
	released := (kstate != "D")
; }

if (!released) {
	Goto ButtonGridLongPressStart
}
SetTimer, ButtonGridLongPressEnd, Off
; MouseCurrentAccelerationSpeed = 0
; MouseCurrentSpeed = %MouseSpeed%
Button = 0
return


ButtonUp:
ButtonDown:
ButtonLeft:
ButtonRight:
ButtonUpLeft:
ButtonUpRight:
ButtonDownLeft:
ButtonDownRight:


StringReplace, Button, A_ThisHotkey, * ; trim "*" char in A_ThisHotkey. E.g., *NumpadUp → NumpadUp

ButtonAccelerationStart:
comboButton := ""

If Button <> 0
{
	combinations := Object()
	combinations["NumpadHome"] := ["NumpadUp", "NumpadLeft"]
	combinations["NumpadEnd"] := ["NumpadDown", "NumpadLeft"]
	combinations["NumpadPgUp"] := ["NumpadUp", "NumpadRight"]
	combinations["NumpadPgDn"] := ["NumpadDown", "NumpadRight"]
    ; Check if two other arrow keys are still being pressed
	; arrowKeys := ["NumpadUp", "NumpadDown", "NumpadLeft", "NumpadRight"]
	; reset := true
    ; for each, key in arrowKeys
    ; {
	; 	; msgbox, Button: %Button% key: %key%
    ;     if (key != Button and GetKeyState(key, "P")) {
    ;         ; Code to execute if the key is being pressed
	; 		reset := false
	; 	
    ;     }
    ; }
	; if (reset){
	; 	MouseCurrentAccelerationSpeed = 0
	; 	MouseCurrentSpeed = 0
	; }
	
	; Check if combination of arrow keys is pressed, e.g. Numpad8 and Numpad4 = Numpad7
	; In total, there are 4 combinations, check all of them
	
	for combination, keys in combinations
	{
		
		if (GetKeyState(keys[1], "P") and GetKeyState(keys[2], "P")) {
			; Button = %combination%
			comboButton := combination
			; MsgBox, %comboButton%, %MouseSpeed%, %MouseCurrentSpeed%
			break
		}
	}
}
; if (comboButton != "") {
	
; msgbox, comboButton: %comboButton%
; }

If MouseAccelerationSpeed >= 1
{
	If MouseMaxSpeed > %MouseCurrentSpeed%
	{
		Temp = 0.001
		Temp *= %MouseAccelerationSpeed%
		MouseCurrentAccelerationSpeed += %Temp%
		MouseCurrentSpeed += %MouseCurrentAccelerationSpeed%
	}
}

;MouseRotationAngle convertion to speed of button direction
{
	MouseCurrentSpeedToDirection = %MouseRotationAngle%
	MouseCurrentSpeedToDirection /= 90.0
	Temp = %MouseCurrentSpeedToDirection%

	if (Temp >= 0 && Temp < 1) {
		MouseCurrentSpeedToDirection = 1
	 	MouseCurrentSpeedToDirection -= Temp
	} else if (Temp >= 1 && Temp < 2) {
		MouseCurrentSpeedToDirection = 0
	 	MouseCurrentSpeedToDirection -= Temp - Floor(Temp)
	} else if (Temp >= 2 && Temp < 3) {
		MouseCurrentSpeedToDirection = -1
	 	MouseCurrentSpeedToDirection += Temp - Floor(Temp)
	} else if (Temp >= 3 && Temp < 4) {
		MouseCurrentSpeedToDirection = 0
	 	MouseCurrentSpeedToDirection += Temp - Floor(Temp)
	}
}
EndMouseCurrentSpeedToDirectionCalculation:

;MouseRotationAngle convertion to speed of 90 degrees to right
{
	MouseCurrentSpeedToSide = %MouseRotationAngle%
	MouseCurrentSpeedToSide /= 90.0
	Temp = %MouseCurrentSpeedToSide%
	Transform, Temp, mod, %Temp%, 4

	if (Temp >= 0 && Temp < 1) {
		MouseCurrentSpeedToSide = Temp
	} else if (Temp >= 1 && Temp < 2) {
		MouseCurrentSpeedToSide = 1
		MouseCurrentSpeedToSide -= (Temp - 1)
	} else if (Temp >= 2 && Temp < 3) {
		MouseCurrentSpeedToSide = 0
		MouseCurrentSpeedToSide -= (Temp - 2)
	} else if (Temp >= 3 && Temp < 4) {
		MouseCurrentSpeedToSide = -1
		MouseCurrentSpeedToSide += (Temp - 3)
	}
}
EndMouseCurrentSpeedToSideCalculation:

; MsgBox, %MouseCurrentSpeedToSide%, %MouseCurrentSpeedToDirection%, %MouseCurrentSpeed% 

MouseCurrentSpeedToDirection *= %MouseCurrentSpeed%
MouseCurrentSpeedToSide *= %MouseCurrentSpeed%


Temp = %MouseRotationAnglePart%
Transform, Temp, Mod, %Temp%, 2

; if (Button != "") {
; 	 MsgBox, Button: %Button%
; }
if (comboButton = "") {
	If Button = NumpadUp
	{
		if Temp = 1
		{
			MouseCurrentSpeedToSide *= 2
			MouseCurrentSpeedToDirection *= 2
		}

		MouseCurrentSpeedToDirection *= -1
		MouseMove, %MouseCurrentSpeedToSide%, %MouseCurrentSpeedToDirection%, 0, R
		; MsgBox, %MouseCurrentSpeedToSide%, %MouseCurrentSpeedToDirection%, 0, R
	}
	else if Button = NumpadDown
	{
		if Temp = 1
		{
			MouseCurrentSpeedToSide *= 2
			MouseCurrentSpeedToDirection *= 2
		}

		MouseCurrentSpeedToSide *= -1
		MouseMove, %MouseCurrentSpeedToSide%, %MouseCurrentSpeedToDirection%, 0, R
		; MsgBox, %MouseCurrentSpeedToSide%, %MouseCurrentSpeedToDirection%, 0, R
	}
	else if Button = NumpadLeft
	{
		if Temp = 1
		{
			MouseCurrentSpeedToSide *= 2
			MouseCurrentSpeedToDirection *= 2
		}

		MouseCurrentSpeedToSide *= -1
		MouseCurrentSpeedToDirection *= -1

		MouseMove, %MouseCurrentSpeedToDirection%, %MouseCurrentSpeedToSide%, 0, R
		; MsgBox, %MouseCurrentSpeedToSide%, %MouseCurrentSpeedToDirection%, 0, R
	}
	else if Button = NumpadRight
	{
		if Temp = 1
		{
			MouseCurrentSpeedToSide *= 2
			MouseCurrentSpeedToDirection *= 2
		}

		MouseMove, %MouseCurrentSpeedToDirection%, %MouseCurrentSpeedToSide%, 0, R
	; CoordMode, Mouse, Screen
	; MouseGetPos, X, Y
	; ; X += MouseCurrentSpeedToDirection*100
	; ; Y += MouseCurrentSpeedToSide*10
	; 	DllCall("SetCursorPos", "int", X, "int", Y)
		; MsgBox, %X%, %Y%
	}
}


	; if (comboButton != ""){
	; 	msgbox, comboButton: %comboButton%
	; }

if (Button = "NumpadHome" or comboButton = "NumpadHome")
{
	Temp = %MouseCurrentSpeedToDirection%
	Temp -= %MouseCurrentSpeedToSide%
	Temp *= -1
	Temp2 = %MouseCurrentSpeedToDirection%
	Temp2 += %MouseCurrentSpeedToSide%
	Temp2 *= -1
	MouseMove, %Temp%, %Temp2%, 0, R
}
else if (Button = "NumpadEnd" or comboButton = "NumpadEnd")
{
	Temp = %MouseCurrentSpeedToDirection%
	Temp += %MouseCurrentSpeedToSide%
	Temp *= -1
	Temp2 = %MouseCurrentSpeedToDirection%
	Temp2 -= %MouseCurrentSpeedToSide%
	MouseMove, %Temp%, %Temp2%, 0, R
}
else if (Button = "NumpadPgUp" or comboButton = "NumpadPgUp")
{
	Temp = %MouseCurrentSpeedToDirection%
	Temp += %MouseCurrentSpeedToSide%
	Temp2 = %MouseCurrentSpeedToDirection%
	Temp2 -= %MouseCurrentSpeedToSide%
	Temp2 *= -1
	MouseMove, %Temp%, %Temp2%, 0, R
}
else if (Button = "NumpadPgDn" or comboButton = "NumpadPgDn")
{
	Temp = %MouseCurrentSpeedToDirection%
	Temp -= %MouseCurrentSpeedToSide%
	Temp2 *= -1
	Temp2 = %MouseCurrentSpeedToDirection%
	Temp2 += %MouseCurrentSpeedToSide%
	MouseMove, %Temp%, %Temp2%, 0, R
}

SetTimer, ButtonAccelerationEnd, 10
return

ButtonAccelerationEnd:
; acc ends check on comboButton
; GetKeyState, kstate, %Button%, P

released := true	; true when all keys are released after comboButton is released
one_only := false  ; true when only one key is released after comboButton is released
if (comboButton != "") {

    for index, key in combinations[comboButton] {
        if (GetKeyState(key, "P")) {
            released := false
			one_only := !one_only
        }
    }

	if (one_only) {
		for index, key in combinations[comboButton] {
			if (GetKeyState(key, "P")) {
				button := key
				break
			}
		}
    }
} else {
	GetKeyState, kstate, %Button%, P
	released := (kstate != "D")
}

if (!released) {
	Goto ButtonAccelerationStart
}
SetTimer, ButtonAccelerationEnd, Off
MouseCurrentAccelerationSpeed = 0
MouseCurrentSpeed = %MouseSpeed%
Button = 0
return

;Mouse wheel movement support

ButtonWheelSpeedUp:
MouseWheelSpeed++
RegRead, MouseWheelSpeedMultiplier, HKCU, Control Panel\Desktop, WheelScrollLines
If MouseWheelSpeedMultiplier <= 0
	MouseWheelSpeedMultiplier = 1
MouseWheelSpeedReal = %MouseWheelSpeed%
MouseWheelSpeedReal *= %MouseWheelSpeedMultiplier%
ToolTip, Mouse wheel speed: %MouseWheelSpeedReal% lines
SetTimer, RemoveToolTip, 1000
return
ButtonWheelSpeedDown:
RegRead, MouseWheelSpeedMultiplier, HKCU, Control Panel\Desktop, WheelScrollLines
If MouseWheelSpeedMultiplier <= 0
	MouseWheelSpeedMultiplier = 1
If MouseWheelSpeedReal > %MouseWheelSpeedMultiplier%
{
	MouseWheelSpeed--
	MouseWheelSpeedReal = %MouseWheelSpeed%
	MouseWheelSpeedReal *= %MouseWheelSpeedMultiplier%
}
If MouseWheelSpeedReal = 1
	ToolTip, Mouse wheel speed: %MouseWheelSpeedReal% line
else
	ToolTip, Mouse wheel speed: %MouseWheelSpeedReal% lines
SetTimer, RemoveToolTip, 1000
return

ButtonWheelAccelerationSpeedUp:
MouseWheelAccelerationSpeed++
RegRead, MouseWheelSpeedMultiplier, HKCU, Control Panel\Desktop, WheelScrollLines
If MouseWheelSpeedMultiplier <= 0
	MouseWheelSpeedMultiplier = 1
MouseWheelAccelerationSpeedReal = %MouseWheelAccelerationSpeed%
MouseWheelAccelerationSpeedReal *= %MouseWheelSpeedMultiplier%
ToolTip, Mouse wheel acceleration speed: %MouseWheelAccelerationSpeedReal% lines
SetTimer, RemoveToolTip, 1000
return
ButtonWheelAccelerationSpeedDown:
RegRead, MouseWheelSpeedMultiplier, HKCU, Control Panel\Desktop, WheelScrollLines
If MouseWheelSpeedMultiplier <= 0
	MouseWheelSpeedMultiplier = 1
If MouseWheelAccelerationSpeed > 1
{
	MouseWheelAccelerationSpeed--
	MouseWheelAccelerationSpeedReal = %MouseWheelAccelerationSpeed%
	MouseWheelAccelerationSpeedReal *= %MouseWheelSpeedMultiplier%
}
If MouseWheelAccelerationSpeedReal = 1
	ToolTip, Mouse wheel acceleration speed: %MouseWheelAccelerationSpeedReal% line
else
	ToolTip, Mouse wheel acceleration speed: %MouseWheelAccelerationSpeedReal% lines
SetTimer, RemoveToolTip, 1000
return

ButtonWheelMaxSpeedUp:
MouseWheelMaxSpeed++
RegRead, MouseWheelSpeedMultiplier, HKCU, Control Panel\Desktop, WheelScrollLines
If MouseWheelSpeedMultiplier <= 0
	MouseWheelSpeedMultiplier = 1
MouseWheelMaxSpeedReal = %MouseWheelMaxSpeed%
MouseWheelMaxSpeedReal *= %MouseWheelSpeedMultiplier%
ToolTip, Mouse wheel maximum speed: %MouseWheelMaxSpeedReal% lines
SetTimer, RemoveToolTip, 1000
return
ButtonWheelMaxSpeedDown:
RegRead, MouseWheelSpeedMultiplier, HKCU, Control Panel\Desktop, WheelScrollLines
If MouseWheelSpeedMultiplier <= 0
	MouseWheelSpeedMultiplier = 1
If MouseWheelMaxSpeed > 1
{
	MouseWheelMaxSpeed--
	MouseWheelMaxSpeedReal = %MouseWheelMaxSpeed%
	MouseWheelMaxSpeedReal *= %MouseWheelSpeedMultiplier%
}
If MouseWheelMaxSpeedReal = 1
	ToolTip, Mouse wheel maximum speed: %MouseWheelMaxSpeedReal% line
else
	ToolTip, Mouse wheel maximum speed: %MouseWheelMaxSpeedReal% lines
SetTimer, RemoveToolTip, 1000
return

ButtonWheelUp:
ButtonWheelDown:
ButtonWheelLeft:
ButtonWheelRight:
If Button <> 0
{
	If Button <> %A_ThisHotkey%
	{
		MouseWheelCurrentAccelerationSpeed = 0
		MouseWheelCurrentSpeed = %MouseWheelSpeed%
	}
}
StringReplace, Button, A_ThisHotkey, *

ButtonWheelAccelerationStart:
If MouseWheelAccelerationSpeed >= 1
{
	If MouseWheelMaxSpeed > %MouseWheelCurrentSpeed%
	{
		Temp = 0.001
		Temp *= %MouseWheelAccelerationSpeed%
		MouseWheelCurrentAccelerationSpeed += %Temp%
		MouseWheelCurrentSpeed += %MouseWheelCurrentAccelerationSpeed%
	}
}

If Button = NumpadSub
{
	MouseClick, WheelUp,,, %MouseWheelCurrentSpeed%, 0, D
	SetTimer, ButtonWheelAccelerationEnd, 100
}
else if Button = NumpadAdd
{
	MouseClick, WheelDown,,, %MouseWheelCurrentSpeed%, 0, D
	SetTimer, ButtonWheelAccelerationEnd, 100
}
else if Button = #NumpadSub
		; MouseClick, WheelLeft,,, %MouseWheelCurrentSpeed%, 0, D ; not always working 
	Loop 2 {
		Send, {WheelLeft}
	}
else if Button = #NumpadAdd
	Loop 2 {
		Send, {WheelRight}
	}

return

ButtonWheelAccelerationEnd:
GetKeyState, kstate, %Button%, P
if kstate = D
	Goto ButtonWheelAccelerationStart

MouseWheelCurrentAccelerationSpeed = 0
MouseWheelCurrentSpeed = %MouseWheelSpeed%
Button = 0
return

RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
return

;~ ---------------------- Code below added by mslonik -------------------------------------------------

INIREAD:
	IfNotExist, %ApplicationName%.ini ; Checks for the existence of a file or folder
{
  ini=
(
[MouseSpeed]
MouseSpeed = 2
MouseAccelerationSpeed = 24
MouseMaxSpeed = 64

[MouseWheel]
MouseWheelSpeed = 2
MouseWheelAccelerationSpeed = 3
MouseWheelMaxSpeed = 5

[MouseRotationAngle]
MouseRotationAngle = 0
)
  FileAppend, %ini%, %ApplicationName%.ini
;   ini=
; MsgBox , %A_WorkingDir% %ApplicationName%.ini not exist. Set mouse speed to  %MouseSpeed% 

}
IniRead, MouseSpeed, %ApplicationName%.ini, MouseSpeed, MouseSpeed
IniRead, MouseAccelerationSpeed, %ApplicationName%.ini, MouseSpeed, MouseAccelerationSpeed
IniRead, MouseMaxSpeed, %ApplicationName%.ini, MouseSpeed, MouseMaxSpeed

;Mouse wheel speed is also set on Control Panel. As that
;will affect the normal mouse behavior, the real speed of
;these three below are times the normal mouse wheel speed.
IniRead, MouseWheelSpeed, %ApplicationName%.ini, MouseWheel, MouseWheelSpeed
IniRead, MouseWheelAccelerationSpeed, %ApplicationName%.ini, MouseWheel, MouseWheelAccelerationSpeed
IniRead, MouseWheelMaxSpeed, %ApplicationName%.ini, MouseWheel, MouseWheelMaxSpeed

IniRead, MouseRotationAngle, %ApplicationName%.ini, MouseRotationAngle, MouseRotationAngle
return

TRAYMENU:
Menu, Tray, Add, %ApplicationName% ABOUT, ABOUT
Menu, Tray, Default, %ApplicationName% ABOUT ; Default: Changes the menu's default item to be the specified menu item and makes its font bold.
Menu, Tray, Add ; To add a menu separator line, omit all three parameters. To put your menu items on top of the standard menu items (after adding your own menu items) run Menu, Tray, NoStandard followed by Menu, Tray, Standard.
Menu, Tray, NoStandard
Menu, Tray, Standard
Menu, Tray, Tip, %ApplicationName% ; Changes the tray icon's tooltip.
return

ABOUT:
Gui, MyAbout: Margin,, 0
Gui, MyAbout: Font, Bold
Gui, MyAbout: Add, Text, , %ApplicationName% v.1.02 by deguix and mslonik
Gui, MyAbout: Font

Gui, MyAbout: Add, Text, xm+10, 
(
This script is an example of use of AutoHotkey. It uses the remapping of numpad keys of a keyboard to transform it
into a mouse. Some features are the acceleration which enables you to increase the mouse movement when holding a key
a key for a long time, and the rotation which makes the numpad mouse to "turn". I.e. NumpadDown as NumpadUp
and vice-versa. See the list of keys used below:
)

Gui, MyAbout: Font, s10, Courier New
Gui, MyAbout: Add, Text, xm+10, 
(
o--------------------------------------------------------------------------o
| Keys                  | Description                                      |
|--------------------------------------------------------------------------|
| ScrollLock (toggle on)| Activates numpad mouse mode.                     |
|-----------------------|--------------------------------------------------|
| Numpad0               | Left mouse button click.                         |
| Numpad5               | Middle mouse button click.                       |
| NumpadDot             | Right mouse button click.                        |
| NumpadDiv/NumpadMult  | X1/X2 mouse button click. (Win 2k+)              |
| NumpadSub/NumpadAdd   | Moves up/down the mouse wheel.                   |
|                       |                                                  |
|-----------------------|--------------------------------------------------|
| NumLock (toggled off) | Activates mouse movement mode.                   |
|-----------------------|--------------------------------------------------|
| NumpadEnd/Down/PgDn/  | Mouse movement.                                  |
| /Left/Right/Home/Up/  |                                                  |
| /PgUp                 |                                                  |
|                       |                                                  |
|-----------------------|--------------------------------------------------|
| NumLock (toggled on)  | Activates mouse speed adj. mode.                 |
|-----------------------|--------------------------------------------------|
| Numpad7/Numpad1       | Inc./dec. acceleration per button press.         |
| Numpad8/Numpad2       | Inc./dec. initial speed per button press.        |
| Numpad9/Numpad3       | Inc./dec. maximum speed per button press.        |
| !Numpad7/^Numpad1     | Inc./dec. wheel acceleration per button press*.  |
| !Numpad8/^Numpad2     | Inc./dec. wheel initial speed per button press*. |
| !Numpad9/^Numpad3     | Inc./dec. wheel maximum speed per button press*. |
| Numpad4/Numpad6       | Inc./dec. rotation angle to right in degrees.    |
|                       | (i.e. 180° = inversed controls).                 |
|--------------------------------------------------------------------------|
| * = These options are affected by the mouse wheel speed adjusted on      |
| Control Panel. If you don't have a mouse with wheel, the default is 3    |
|  +/- lines per option button press.                                      |
o--------------------------------------------------------------------------o
)

Gui, MyAbout: Add, Button, Default Hidden w100 gMyOK Center vOkButtonVariabl hwndOkButtonHandle, &OK
GuiControlGet, MyGuiControlGetVariable, MyAbout: Pos, %OkButtonHandle%
Gui, MyAbout: Show, Center, %ApplicationName% About
WinGetPos, , , MyAboutWindowWidth, , %ApplicationName% About
NewButtonXPosition := (MyAboutWindowWidth / 2) - (MyGuiControlGetVariableW / 2)
GuiControl, Move, %OkButtonHandle%, % "x" NewButtonXPosition
GuiControl, Show, %OkButtonHandle%
return    

MyOK:
MyAboutGuiClose: ; Launched when the window is closed by pressing its X button in the title bar
Gui, MyAbout: Destroy
return