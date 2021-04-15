#SingleInstance, Force

IniRead, Start, %A_ScriptDir%\Hotkeys.ini, Hotkeys, Start
IniRead, Stop, %A_ScriptDir%\Hotkeys.ini, Hotkeys, Stop

Hotkey,~%Start%,StartHK
Hotkey,~%Stop%,StopHK

Gui, -MaximizeBox -MinimizeBox

global toggle = false
global timer

Gui, Add, Edit, x0 y0 w70 h20 -VScroll -WantReturn Number Limit5 +Center vskillTimerQ,
Gui, Add, Button, x69 y-1 w32 h22 gOK, OK
Gui, Show, w100 h20, Skill Q
return

GuiClose:
ExitApp

OK:
	GuiControlGet, skillTimerQ
	timer := skillTimerQ
	if (timer < 1000) {
		MsgBox Timer must be between 1000 and 30000
		return
	}
	if (timer > 30000) {
		MsgBox Timer must be between 1000 and 30000
		return
	}
	WinHide, Skill Q

StartHK:
	toggle := true
	runTimerQ()
	return

StopHK:
	toggle := false
	return
	
runTimerQ() {
	if (WinActive("ahk_class POEWindowClass")) {
		while (toggle) {
			Send, Q
			Sleep, %timer%
		}
	}
}