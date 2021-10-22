#NoEnv
#SingleInstance, Force
#MaxHotkeysPerInterval 500


FileEncoding , UTF-8
SendMode Input

;________________________________________Check ahkscript_______________________________________________
If (A_AhkVersion <= "1.1.33")
{
	msgbox, You need AutoHotkey v1.1.33 or later to run this script. `n`nPlease go to http://ahkscript.org/download and download a recent version.
	ExitApp
}

global toggle = false
global switch = false

global autoToggle = false
global autologoutToggle = false
global autoSteelSkin = false

global deckCount
global chanceCount
global prophCount
global coorCount
global timer 	
global flasks
global mapFound = false
global coorY
global coorX

;___________________Get Hotkey value from file _____________________
IniRead, GuiToggle, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, GuiToggle
IniRead, Logout, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, Logout
IniRead, AutoLogout, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, AutoLogout
IniRead, SteelSkin, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, SteelSkin
IniRead, YourHideout, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, YourHideout

;___________________Init Hotkey_____________________
Hotkey,%GuiToggle%,winToggle
Hotkey,%Logout%,logout
Hotkey,%AutoLogout%,autoLogout
Hotkey,%SteelSkin%,steelSkin
Hotkey,%YourHideout%,yourHideout


;________________ Set ahk icon______________
I_Icon = %A_ScriptDir%\data\icon.ico
IfExist, %I_Icon%
Menu, Tray, Icon, %I_Icon%

;___________________GUI________________________
guiToggle:= false

;__________________GUI-Background__________________
I_Background_01 = %A_ScriptDir%\data\bd_01.png
IfExist, %I_Background_01%
	Gui,Add,Picture,x0 y0 w1280 h250,%I_Background_01%
;__________________GUI-LeagueIcon__________________
I_LeagueIcon_01 = %A_ScriptDir%\data\LeagueIcon.jpg
Gui,Add,Picture,x765 y10 w176 h235,%I_LeagueIcon_01%

;__________________GUI-Font_____________________
Gui, Font, cWhite Bold s8

;__________________GUI-Flask_____________________
Gui,Add,Text,x20 y20 w220 h70 BackgroundTrans,Flask
Gui,Add,Button,x30 y40 w40 h40 gFlask1,1
Gui,Add,Button,x70 y40 w40 h40 gFlask2,2
Gui,Add,Button,x110 y40 w40 h40 gFlask3,3
Gui,Add,Button,x150 y40 w40 h40 gFlask4,4
Gui,Add,Button,x190 y40 w40 h40 gFlask5,5

;__________________GUI-Skills_____________________
Gui,Add,Text,x20 y90 w220 h70 BackgroundTrans,Skills
Gui,Add,Button,x30 y110 w40 h40 gSkillQ,Q
Gui,Add,Button,x70 y110 w40 h40 gSkillW,W
Gui,Add,Button,x110 y110 w40 h40 gSkillE,E
Gui,Add,Button,x150 y110 w40 h40 gSkillR,R
Gui,Add,Button,x190 y110 w40 h40 gSkillT,T

;__________________GUI-Hotkeys_____________________
Gui,Add,Text,x250 y30 w60 h30 BackgroundTrans,Start Flask:
Gui,Add,Hotkey,x340 y30 w120 h21,Hotkeys

;__________________GUI-Hotkeys-Commands_____________________
Gui,Add,Text,x500 y30 w80 h30 BackgroundTrans, YourHideout:
IniRead, YourHideout, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, YourHideout
Gui,Add,Hotkey,x600 y30 w120 h21 vyourHideout , %YourHideout%

;__________________GUI-GuiToggle_____________________
Gui,Add,Text,x250 y60 w100 h13 BackgroundTrans,Open/Hide GUI
IniRead, GuiToggle, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, GuiToggle
Gui, Add, Hotkey,x350 y60 w60 h20 vGuiToggle, %GuiToggle%

;__________________GUI-Logout_____________________
Gui,Add,Text,x250 y90 w100 h13 BackgroundTrans, Logout:
IniRead, Logout, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, Logout
Gui,Add, Hotkey, x350 y90 w60 h21 vlogout , %Logout%

;__________________GUI-AutoLogout_____________________
Gui,Add,Text,x250 y120 w100 h13 BackgroundTrans, AutoLogout:
IniRead, AutoLogout, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, AutoLogout
Gui,Add, Hotkey, x350 y120 w60 h21 vautoLogout , %AutoLogout%

;__________________GUI-AutoSteelSkin_____________________
Gui,Add,Text,x250 y150 w100 h13 BackgroundTrans, SteelSkin:
IniRead, SteelSkin, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, SteelSkin
Gui,Add, Hotkey, x350 y150 w60 h21 vsteelSkin , %SteelSkin%

Gui,Add,Button,x20 y170 w50 h30 gHelp,Help

Gui, Font, cBlack  
Gui,Add,Edit,x80 y170 w150 h30 -VScroll +ReadOnly vLogs, Sleeping...
Gui, Font, cWhite Bold 

Gui,Add,Button,x250 y170 w50 h30 vHK gSave,Save

Gui,Add,Text,x60 y210 w150 h13 BackgroundTrans ,Created by Pawel Szynal

Gui,Add,Text,x250 y210 w150 h13 BackgroundTrans, Steam Client:
Gui,Add, Text,x250 y230 w150 h13 BackgroundTrans, Dx11 (x64) Client:
Gui,Add, Checkbox, x380 y210 w13 h13 Checked%steam%
Gui,Add, Checkbox, x380 y230 w13 h13 Checked%highBits%

Gui, Show,% "x" A_ScreenWidth - 1200 " y" A_ScreenHeight - 600 " w" 950 " h" 250, PoE-AHK v1.1

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
		ToolTip, TEST
		} else {
		switch := false
		RemoveToolTip:
		ToolTip
		return
	}
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
	autoSteelSkin := false
	stopFlasks()
	return

winToggle:
		Gui, Show,% "x" A_ScreenWidth - 1200 " y" A_ScreenHeight - 600 " w" 950 " h" 250, PoE-AHK v1.1
		guiToggle := false
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


yourHideout:
	Send {Enter}
	Send /hideout
	Send {Enter}
return	

logout:
	Send {Enter}
	Send /exit
return	

steelSkin:
	autoSteelSkin := !autoSteelSkin
	msgbox, steelSkin =  %autoSteelSkin%
	while (autoSteelSkin)	{
		Send, e
		Random, rand, 5001, 5021e
		sleep, %rand%
	}
msgbox, steelSkin = %autoSteelSkin%  
return	

autoLogout:
		autologoutToggle := !autologoutToggle
		
		if (autologoutToggle == true){
				msgbox, AutoLogout run
		}

		while (	autologoutToggle == true)										
			{
				PixelGetColor, Color, 104, 984			
				if (Color == 0x1B1586)					
					{
						Random, rand, 100, 200
						sleep, %rand%	
						continue						
					}
				else
					{
						return				
					}
			}	
		msgbox, AutoLogout = false 
return									


f2::
	MouseGetPos, MouseX, MouseY 
	PixelGetColor, color, %MouseX%, %MouseY%
	MsgBox The color at the current cursor position in %MouseX%, %MouseY% is %color%.
return	

Shift::
	if (WinActive("ahk_class POEWindowClass")) {
		Send {q}
		Send {MButton}
		Random, rand, 200, 500
		Sleep %rand%
		Send {r}
		Sleep %rand%
	}	
return	

	
	stopFlasks() {
		toggle := favwlse
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

	Save:
	Gui, Submit, NoHide
	IfExist, %A_ScriptDir%\save\Hotkeys.ini
		FileDelete, %A_ScriptDir%\save\Hotkeys.ini
	
	GuiControlGet, GuiToggle
	saveGuiToggle := GuiToggle
	IniWrite, %saveGuiToggle%, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, GuiToggle
	
	GuiControlGet, Logout
	saveLogout := Logout
	IniWrite, %saveLogout%, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, Logout

	GuiControlGet, AutoLogout
	saveAutoLogout := AutoLogout
	IniWrite, %saveAutoLogout%, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, AutoLogout

	GuiControlGet, SteelSkin
	saveSteelSkin := SteelSkin
	IniWrite, %saveSteelSkin%, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, SteelSkin

	GuiControlGet, YourHideout
	saveYourHideout := YourHideout
	IniWrite, %saveYourHideout%, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, YourHideout

	MsgBox The new settings have been saved. Remember to restart the program.
	return

;______________________________________________________________________________________

