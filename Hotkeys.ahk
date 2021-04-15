IniRead, GuiToggle, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, GuiToggle

Gui, -MaximizeBox -MinimizeBox

Gui, Add, Text, x12 y179 w130 h30 , Open decks
Gui, Add, Hotkey, x152 y179 w180 h30 vGuiToggle, %GuiToggle%
Gui, Add, Button, x12 y339 w130 h30 gSave, Save

Gui, Show, w346 h375, Hotkeys
return

GuiClose:
ExitApp

Save:
	Gui, Submit, NoHide
	GuiControlGet, GuiToggle
	decks := GuiToggle
	IniWrite, %decks%, %A_ScriptDir%\save\Hotkeys.ini, Hotkeys, GuiToggle
	ExitApp

Cancel:
	ExitApp


