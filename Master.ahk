#NoEnv
#SingleInstance, Force
#MaxHotkeysPerInterval 500


FileEncoding , UTF-8
SendMode Input

If (A_AhkVersion <= "1.1.33")
{
	msgbox, You need AutoHotkey v1.1.33 or later to run this script. `n`nPlease go to http://ahkscript.org/download and download a recent version.
	ExitApp
}

SetWorkingDir %A_ScriptDir%\LutTools
elog := A_Now . " " . A_AhkVersion . " " . macroVersion "`n"
FileAppend, %elog% , error.txt, UTF-16
FileRead, newestVersion, version.html


full_command_line := DllCall("GetCommandLine", "str")


if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}

RunWait, verify.ahk

GetTable := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Iphlpapi.dll", "Ptr"), Astr, "GetExtendedTcpTable", "Ptr")
SetEntry := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Iphlpapi.dll", "Ptr"), Astr, "SetTcpEntry", "Ptr")
EnumProcesses := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Psapi.dll", "Ptr"), Astr, "EnumProcesses", "Ptr")
preloadPsapi := DllCall("LoadLibrary", "Str", "Psapi.dll", "Ptr")
OpenProcessToken := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Advapi32.dll", "Ptr"), Astr, "OpenProcessToken", "Ptr")
LookupPrivilegeValue := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Advapi32.dll", "Ptr"), Astr, "LookupPrivilegeValue", "Ptr")
AdjustTokenPrivileges := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "Advapi32.dll", "Ptr"), Astr, "AdjustTokenPrivileges", "Ptr")

readFromFile() ;first run
sleepTime := 500
preloadCportsTimer := 0
basePreloadCportsTimer := 60000 ; 1 minute
preloadCportsCall := "cports.exe /stext TEMP"




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


; IniRead, Start, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, Start
; IniRead, Stop, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, Stop
; IniRead, Currency, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, Currency
; IniRead, Proph, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, Proph
IniRead, GuiToggle, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, GuiToggle
; IniRead, Inv, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, Inv
; IniRead, End, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, End

;___________________Hotkey_____________________
; Hotkey,%Start%,StartHK
; Hotkey,%Stop%,StopHK
Hotkey,%GuiToggle%,GuiToggleHK
; Hotkey,%End%,EndHK

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


Gui,Add,Text,x270 y60 w100 h13 BackgroundTrans,Open/Hide GUI
IniRead, GuiToggle, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, GuiToggle
Gui, Add, Hotkey,x400 y60 w60 h20 vGuiToggle, %GuiToggle%


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
		ToolTip, TEST
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

	Save:
	Gui, Submit, NoHide
	GuiControlGet, GuiToggle
	decks := GuiToggle
	IniWrite, %decks%, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, GuiToggle
	MsgBox The new settings have been saved. Remember to restart the program.
	return

;______________________________________________________________________________________

;//functions
superLogoutCommand(){
superLogoutCommand:
	Critical
	logoutCommand()
	return
}


logoutCommand(){
global executable, backupExe
logoutCommand:
	Critical
	succ := logout(executable)
	if (succ == 0) && backupExe != "" {
		newSucc := logout(backupExe)
		error("ED12",executable,backupExe)
		if (newSucc == 0) {
			error("ED13")
		}
	}
	return
}

cportsLogout(){
	global cportsCommand, lastlogout
	Critical
	start := A_TickCount
	ltime := lastlogout + 1000
	if ( ltime < A_TickCount ) {
		RunWait, %cportsCommand%
		lastlogout := A_TickCount
	}
	Sleep 10
	error("nb:" . A_TickCount - start)
	return
}

logout(executable){
	global  GetTable, SetEntry, EnumProcesses, OpenProcessToken, LookupPrivilegeValue, AdjustTokenPrivileges, loadedPsapi
	Critical
	start := A_TickCount

	poePID := Object()
	s := 4096
	Process, Exist 
	h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ErrorLevel, "Ptr")

	DllCall(OpenProcessToken, "Ptr", h, "UInt", 32, "PtrP", t)
	VarSetCapacity(ti, 16, 0)
	NumPut(1, ti, 0, "UInt")

	DllCall(LookupPrivilegeValue, "Ptr", 0, "Str", "SeDebugPrivilege", "Int64P", luid)
	NumPut(luid, ti, 4, "Int64")
	NumPut(2, ti, 12, "UInt")

	r := DllCall(AdjustTokenPrivileges, "Ptr", t, "Int", false, "Ptr", &ti, "UInt", 0, "Ptr", 0, "Ptr", 0)
	DllCall("CloseHandle", "Ptr", t)
	DllCall("CloseHandle", "Ptr", h)

	try
	{
		s := VarSetCapacity(a, s)
		c := 0
		DllCall(EnumProcesses, "Ptr", &a, "UInt", s, "UIntP", r)
		Loop, % r // 4
		{
			id := NumGet(a, A_Index * 4, "UInt")

			h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id, "Ptr")

			if !h
				continue
			VarSetCapacity(n, s, 0)
			e := DllCall("Psapi\GetModuleBaseName", "Ptr", h, "Ptr", 0, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
			if !e 
				if e := DllCall("Psapi\GetProcessImageFileName", "Ptr", h, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
					SplitPath n, n
			DllCall("CloseHandle", "Ptr", h)
			if (n && e)
				if (n == executable) {
					poePID.Insert(id)
				}
		}

		l := poePID.Length()
		if ( l = 0 ) {
			Process, wait, %executable%, 0.2
			if ( ErrorLevel > 0 ) {
				poePID.Insert(ErrorLevel)
			}
		}
		
		VarSetCapacity(dwSize, 4, 0) 
		result := DllCall(GetTable, UInt, &TcpTable, UInt, &dwSize, UInt, 0, UInt, 2, UInt, 5, UInt, 0) 
		VarSetCapacity(TcpTable, NumGet(dwSize), 0) 

		result := DllCall(GetTable, UInt, &TcpTable, UInt, &dwSize, UInt, 0, UInt, 2, UInt, 5, UInt, 0) 

		num := NumGet(&TcpTable,0,"UInt")

		IfEqual, num, 0
		{
			cportsLogout()
			error("ED11",num,l,executable)
			return False
		}

		out := 0
		Loop %num%
		{
			cutby := a_index - 1
			cutby *= 24
			ownerPID := NumGet(&TcpTable,cutby+24,"UInt")
			for index, element in poePID {
				if ( ownerPID = element )
				{
					VarSetCapacity(newEntry, 20, 0) 
					NumPut(12,&newEntry,0,"UInt")
					NumPut(NumGet(&TcpTable,cutby+8,"UInt"),&newEntry,4,"UInt")
					NumPut(NumGet(&TcpTable,cutby+12,"UInt"),&newEntry,8,"UInt")
					NumPut(NumGet(&TcpTable,cutby+16,"UInt"),&newEntry,12,"UInt")
					NumPut(NumGet(&TcpTable,cutby+20,"UInt"),&newEntry,16,"UInt")
					result := DllCall(SetEntry, UInt, &newEntry)
					IfNotEqual, result, 0
					{
						cportsLogout()
						error("TCP" . result,out,result,l,executable)
						return False
					}
					out++
				}
			}
		}
		if ( out = 0 ) {
			cportsLogout()
			error("ED10",out,l,executable)
			return False
		} else {
			error(l . ":" . A_TickCount - start,out,l,executable)
		}
	} 
	catch e
	{
		cportsLogout()
		error("ED14","catcherror",e)
		return False
	}
	
	return True
}

error(var,var2:="",var3:="",var4:="",var5:="",var6:="",var7:="") {
	GuiControl,1:, guiErr, %var%
	print := A_Now . "," . var . "," . var2 . "," . var3 . "," . var4 . "," . var5 . "," . var6 . "," . var7 . "`n"
	FileAppend, %print%, error.txt, UTF-16
	return
}

changelogGui(){
changelogGui:
	FileRead, changelog, changelog.txt
	Gui, 3:Add, Edit, w600 h200 +ReadOnly, %changelog% 
	Gui, 3:Show,, LutTools Lite Patch Notes
	return
}

preloadCports(){
	global preloadCportsTimer, basePreloadCportsTimer, preloadCportsCall
	Run, %preloadCportsCall%
	preloadCportsTimer := basePreloadCportsTimer
}

checkActiveType() {
	global verifyLogoutTimer, baseVerifyLogoutTimer, executable, processWarningFound, backupExe
	val := 0
	Process, Exist, %executable%
	if !ErrorLevel
	{
		WinGet, id, list,ahk_class POEWindowClass,, Program Manager
		Loop, %id%
		{
			this_id := id%A_Index%
			WinGet, this_name, ProcessName, ahk_id %this_id%
			backupExe := this_name
			found .= ", " . this_name
			val++
		}

		if ( val > 0 )
		{
			processWarningFound := 1
			berrmsgf .= "You are running: " . found . ""
			berrmsge .= "Your settings expect: " . executable . ""
		} else {
			processWarningFound := 0
			backupExe := "No issues detected"
		}

		GuiControl,6:, backupErrorFound, %berrmsgf%
		GuiControl,6:, backupErrorExpected, %berrmsge%
	}

	verifyLogoutTimer := baseVerifyLogoutTimer
	return
}

runUpdate(){
global
runUpdate:
	if launcherPath != ERROR
		UrlDownloadToFile, http://lutbot.com/ahk/macro.ahk, %launcherPath%
		if ErrorLevel {
			error("ED07")
		}
	UrlDownloadToFile, http://lutbot.com/ahk/verify.ahk, verify.ahk
	UrlDownloadToFile, http://lutbot.com/ahk/heavy.ahk, heavy.ahk
	UrlDownloadToFile, http://lutbot.com/ahk/lite.ahk, lite.ahk
		if ErrorLevel {
			error("update","fail",A_ScriptFullPath, macroVersion, A_AhkVersion)
			error("ED07")
		}
		else {
			error("update","pass",A_ScriptFullPath, macroVersion, A_AhkVersion)
			Run "%A_ScriptFullPath%"
		}
	Sleep 5000 ;This shouldn't ever hit.
	error("update","uhoh", A_ScriptFullPath, macroVersion, A_AhkVersion)
dontUpdate:
	Gui, 4:Destroy
	return	
showPatreon:
	Run http://patreon.com/lutcikaur
	return
showFAQ:
	Run http://lutbot.com/#/faq
	return
showDiscord:
	Run https://discord.gg/nttekWT
	return
switchHeavy:
	IniWrite, 1, settings.ini, variables, RunHeavy
	Run heavy.ahk
	ExitApp
}

loopTimers(){
	global
	Loop {
		preloadCportsTimer -= sleepTime
		verifyLogoutTimer -= sleepTime
		if ( preloadCportsTimer <= 0 )
		{
			if WinActive("ahk_class POEWindowClass")
				preloadCports()
			else
				preloadCportsTimer := basePreloadCportsTimer
		}
		if ( verifyLogoutTimer <= 0 )
		{
			if WinActive("ahk_class POEWindowClass")
				checkActiveType()
		}
		Sleep sleepTime  
	}
	return
}

options(){
optionsCommand:
	hotkeys()
	return
}

hotkeys(){
	global processWarningFound, macroVersion
	Gui, 2:Show,, Lutbot v%macroVersion% lite
	return
}

updateHotkeys() {
updateHotkeys:
	submit()
	return
}

submit(){  
	global
	Gui, 2:Submit 
	IniWrite, %guiSteam%, settings.ini, variables, PoeSteam
	IniWrite, %guihighBits%, settings.ini, variables, HighBits
	IniWrite, %guihotkeyLogout%, settings.ini, hotkeys, logout
	IniWrite, %guihotkeySuperLogout%, settings.ini, hotkeys, superLogout
	IniWrite, %guihotkeyOptions%, settings.ini, hotkeys, options

	readFromFile()
	checkActiveType()

	return    
}

readFromFile(){
	global
	;reset hotkeys
	Hotkey, IfWinActive, ahk_class POEWindowClass
	If hotkeyLogout
		Hotkey,% hotkeyLogout, logoutCommand, Off

	Hotkey, IfWinActive
	If hotkeyOptions
		Hotkey,% hotkeyOptions, optionsCommand, Off
	If hotkeySuperLogout
		Hotkey,% hotkeySuperLogout, superLogoutCommand, Off
	Hotkey, IfWinActive, ahk_class POEWindowClass

	; variables

	IniRead, steam, settings.ini, variables, PoeSteam
	IniRead, highBits, settings.ini, variables, HighBits
	IniRead, hotkeyLogout, settings.ini, hotkeys, logout, %A_Space%
	IniRead, hotkeySuperLogout, settings.ini, hotkeys, superLogout, %A_Space%
	IniRead, hotkeyOptions, settings.ini, hotkeys, options, %A_Space%

	IniRead, launcherPath, settings.ini, variables, LauncherPath

	Hotkey, IfWinActive, ahk_class POEWindowClass
	If hotkeyLogout
		Hotkey,% hotkeyLogout, logoutCommand, On

	Hotkey, IfWinActive
	If hotkeyOptions {
		Hotkey,% hotkeyOptions, optionsCommand, On
		GuiControl,1:, guiSettings, Settings:%hotkeyOptions%
	}
	else {
		Hotkey,F10, optionsCommand, On
		msgbox You dont have some hotkeys set!`nPlease hit F10 to open up your config prompt and please configure your hotkeys (Path of Exile has to be in focus).`nThe way you configure hotkeys is now in the GUI (default F10). Otherwise, you didn't put a hotkey for the options menu. You need that silly.
		GuiControl,1:, guiSettings, Settings:%hotkeyOptions%
	}
	If hotkeySuperLogout
		Hotkey,% hotkeySuperLogout, superLogoutCommand, On
	Hotkey, IfWinActive, ahk_class POEWindowClass
	; extra checks
	if steam = ERROR
		steam = 0
	if highBits = ERROR
		highBits = 0
	
	if ( steam ) {
		if ( highBits ) {
			cportsCommand := "cports.exe /close * * * * PathOfExile_x64Steam.exe"
			executable := "PathOfExile_x64Steam.exe"
		} else {
			cportsCommand := "cports.exe /close * * * * PathOfExileSteam.exe"
			executable := "PathOfExileSteam.exe"
		}
	} else {
		if ( highBits ) {
			cportsCommand := "cports.exe /close * * * * PathOfExile_x64.exe"
			executable := "PathOfExile_x64.exe"
		} else {
			cportsCommand := "cports.exe /close * * * * PathOfExile.exe"
			executable := "PathOfExile.exe"
		}
	}
}
