#SingleInstance, Force

global toggle = false
global switch = false
global autoToggle = false
global deckCount
global chanceCount
global prophCount
global coorCount
global timer
global flasks
global mapFound = false
global coorY
global coorX

IniRead, Start, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, Start
IniRead, Stop, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, Stop
IniRead, Currency, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, Currency
IniRead, Proph, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, Proph
IniRead, GuiToggle, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, GuiToggle
IniRead, Inv, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, Inv
IniRead, End, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, End

;___________________Hotkey_____________________
Hotkey,%Start%,StartHK
Hotkey,%Stop%,StopHK
Hotkey,%GuiToggle%,GuiToggleHK
Hotkey,%End%,EndHK

;________________ Set ahk icon______________
I_Icon = %A_ScriptDir%\data\icon.ico
IfExist, %I_Icon%
Menu, Tray, Icon, %I_Icon%

;___________________GUI________________________

guiToggle:= false

;__________________Background__________________
I_Background_01 = %A_ScriptDir%\data\bd_01.png

IfExist, %I_Background_01%
	Gui,Add,Picture,x0 y0 w1280 h250,%I_Background_01%

Gui,Add,Picture,x465 y10 w176 h235,C:\Users\szyna\Documents\AHK\AHK-Studio\Projects\data\egs-pathofexile-grindinggeargames-s2-1200x1600-32f2178d2f78.jpg

;__________________Font_____________________
Gui, Font, cWhite Bold s8
Gui,Add,Text,x20 y20 w220 h70 BackgroundTrans,Flask
Gui,Add,Button,x30 y40 w40 h40 gFlask1,1
Gui,Add,Button,x70 y40 w40 h40 gFlask2,2
Gui,Add,Button,x110 y40 w40 h40 gFlask3,3
Gui,Add,Button,x150 y40 w40 h40 gFlask4,4
Gui,Add,Button,x190 y40 w40 h40 gFlask5,5

Gui,Add,Text,x20 y90 w220 h70 BackgroundTrans,Skills
Gui,Add,Button,x30 y110 w40 h40 gSkillQ,Q
Gui,Add,Button,x70 y110 w40 h40 gSkillW,W
Gui,Add,Button,x110 y110 w40 h40 gSkillE,E
Gui,Add,Button,x150 y110 w40 h40 gSkillR,R
Gui,Add,Button,x190 y110 w40 h40 gSkillT,T

Gui,Add,Text,x270 y30 w60 h30 BackgroundTrans,Start Flask:

Gui,Add,Hotkey,x340 y30 w120 h21,Hotkeys
Gui,Add,Text,x270 y60 w21 h13 BackgroundTrans,Text
Gui,Add,Hotkey,x340 y60 w120 h21,Hotkey

Gui,Add,Text,x270 y90 w21 h13 BackgroundTrans,Text Red
Gui,Add,Button,x20 y170 w50 h30 gHelp,Help

Gui, Font, cBlack  
Gui,Add,Edit,x80 y170 w150 h30 -VScroll +ReadOnly vLogs, Sleeping...
Gui, Font, cWhite Bold 

Gui,Add,Button,x250 y170 w50 h30 vHK gHK,HK

Gui,Add,Text,x60 y210 w150 h13 BackgroundTrans ,Created by Pawel Szynal
Gui, Show,% "x" A_ScreenWidth - 1200 " y" A_ScreenHeight - 400 " w" 650 " h" 250, PoE-AHK v1.1

; Gui, Add, Text, x1 y0 w52 h20 , Flasks
; Gui, Add, Text, x1 y20 w52 h20 , Timer
; Gui, Add, Text, x1 y40 w52 h20 , State
; Gui, Add, Text, x1 y60 w52 h20 , Lvling

; Gui, Add, Edit, x53 y0 w69 h20 -VScroll vFlasks,
; Gui, Add, Edit, x53 y20 w69 h20 -VScroll vTimer,s

; Gui, Add, CheckBox, x30 y58 w25 h20 vQuick,

; Gui, Add, Button, x62 y60 w40 h22 gSpam, Spam

return

Gui, Color, 
return

GuiClose:
ExitApp

Flask1:
	Run %A_ScriptDir%\timers\Flask_1.ahk
	return
Flask2:
	Run %A_ScriptDir%\timers\Flask_2.ahk
	return
Flask3:
	Run %A_ScriptDir%\timers\Flask_3.ahk
	return
Flask4:
	Run %A_ScriptDir%\timers\Flask_4.ahk
	return
Flask5:
	Run %A_ScriptDir%\timers\Flask_5.ahk
	return
SkillQ:
	Run %A_ScriptDir%\timers\Skill_Q.ahk
	return
SkillW:
	Run %A_ScriptDir%\timers\Skill_W.ahk
	return
SkillE:
	Run %A_ScriptDir%\timers\Skill_E.ahk
	return
SkillR:
	Run %A_ScriptDir%\timers\Skill_R.ahk
	return
SkillT:
	Run %A_ScriptDir%\timers\Skill_T.ahk
	return
Spam:
	Run %A_ScriptDir%\timers\Spam_C.ahk
	return

Help:
	if (switch = false) {
		switch := true
		ToolTip, %Start% = Start Flasks`n%Stop% = Stop Flasks`n%Currency% = Right click a currency and then press F7 to use that currency on all items inside inventory`n%Proph% = Buy prophecies (leave out bottom right for this)`n%GuiToggle% = Open Stacked decks in first row`n%Inv% = Throws all items from your inventory to the ground`n%End% = Abrubtly ends script`nCtrl + Numpadx = Moves x column Inventory to stash`nCtrl + Numpad0 = Moves all Inventory to stash`nCtrl + Numpad+ = Moves all Inventory to stash VERY FAST (do not use for trades!!!)`n, 100, 150
	} else {
		switch := false
		RemoveToolTip:
		ToolTip
		return
	}
	return
	
HK:
	Run %A_ScriptDir%\Hotkeys.ahk
	return

StartHK:
	Gui, Submit, NoHide
	toggle := true
	GuiControlGet, Timer
	timer := Timer
	GuiControlGet, Flasks
	flasks := flasks
	if (timer = null) and (flasks = null) {
		GuiControlGet, Timer
		GuiControl,,Timer,Blocked
		GuiControl,+ReadOnly,Timer
		GuiControlGet, Flasks
		GuiControl,,Flasks,Blocked
		GuiControl,+ReadOnly,Flasks
	}
	if (WinActive("ahk_class POEWindowClass")) {
		if (quick = false) {
			GuiControlGet, Logs
			GuiControl,, Logs, Running...
			runFlasks()
		} else if (quick = true) {
			GuiControlGet, Logs
			GuiControl,, Logs, Running...
			runQuick()
		} else {
			MsgBox,,Error,Lvling Option Bug
		}
	}
	return
	
StopHK:
	stopFlasks()
	return

GuiToggleHK:
	if (guiToggle = false){
		Gui, Hide
		guiToggle := true
	} else {
		Gui, Show,% "x" A_ScreenWidth - 1200 " y" A_ScreenHeight - 400 " w" 650 " h" 250, PoE-AHK v1.1
		guiToggle := false
	}
	return

EndHK:
	autoToggle := false
	chanceCount := 0
	deckCount := 0
	coorCount := 0
	return
	
	runFlasks() {
		if (WinActive("ahk_class POEWindowClass")) {
		if (flasks = 1) {
			while (toggle) {
				Send, 1
				Sleep, %timer%
			}
		} else if (flasks = 12) {
			while (toggle) {
				Send, 1
				Send, 2
				Sleep, %timer%
			}
		} else if (flasks = 123) {
			while (toggle) {
				Send, 1
				Send, 2
				Send, 3
				Sleep, %timer%
			}
		} else if (flasks = 1234) {
			while (toggle) {
				Send, 1
				Send, 2
				Send, 3
				Send, 4
				Sleep, %timer%
			}
		} else if (flasks = 12345) {
			while (toggle) {
				Send, 1
				Send, 2
				Send, 3
				Send, 4
				Send, 5
				Sleep, %timer%
			}
		} else if (flasks = 2) {
			while (toggle) {
				Send, 2
				Sleep, %timer%
			}
		} else if (flasks = 23) {
			while (toggle) {
				Send, 2
				Send, 3
				Sleep, %timer%
			}
		} else if (flasks = 234) {
			while (toggle) {
				Send, 2
				Send, 3
				Send, 4
				Sleep, %timer%
			}
		} else if (flasks = 2345) {
			while (toggle) {
				Send, 2
				Send, 3
				Send, 4
				Send, 5
				Sleep, %timer%
			}
		} else if (flasks = 3) {
			while (toggle) {
				Send, 3
				Sleep, %timer%
			}
		} else if (flasks = 34) {
			while (toggle) {
				Send, 3
				Send, 4
				Sleep, %timer%
			}
		} else if (flasks = 345) {
			while (toggle) {
				Send, 3
				Send, 4
				Send, 5
				Sleep, %timer%
			}
		} else if (flasks = 4) {
			while (toggle) {
				Send, 4
				Sleep, %timer%
			}
		} else if (flasks = 45) {
			while (toggle) {
				Send, 4
				Send, 5
				Sleep, %timer%
			}
		} else if (flasks = 5) {
			while (toggle) {
				Send, 5
				Sleep, %timer%
			}
		}
	}
	}
	
	stopFlasks() {
		toggle := false
		GuiControlGet, Logs
		GuiControl,, Logs, Sleeping...
		if (Timer = Blocked) {
		GuiControlGet, Timer
		GuiControl,,Timer,
		GuiControl,-ReadOnly,Timer
		}
		if (Flasks = Blocked) {
		GuiControlGet, Flasks
		GuiControl,,Flasks,
		GuiControl,-ReadOnly,Flasks
		}
	}
	
	runQuick() {
		if (WinActive("ahk_class POEWindowClass")) {
			if (flasks = 45) {
				while (toggle) {
					Send, 4
					Sleep, %timer%
					Send, 5
					Sleep, %timer%
				}
			} else if (flasks = 345) {
				while (toggle) {
					Send, 3
					Sleep, %timer%
					Send, 4
					Sleep, %timer%
					Send, 5
					Sleep, %timer%
				}
			} else {
				MsgBox,,Error, Wrong Flasks Input`nLvling only works with 345 or 45
				return
			}
		}
	}

