;==================================================== ChkNet ====================================================
timer			:= -Abs(timer)

Gui, Add, Text, % "vSetActive gOpenSettings w200 h" (textSize*2)
Gui, Show, % "x" screenPos.x " y" screenPos.y
CoordMode, Pixel, Screen

Menu, Tray, NoStandard
Menu, Tray, Add, Open Settings		, MenuHandler
Menu, Tray, Default, Open Settings
Menu, Tray, Add, Reload				, MenuHandler
Menu, Tray, Add
Menu, Tray, Add, Exit				, MenuHandler

DllCall("AllocConsole")
WinHide % "ahk_id " DllCall("GetConsoleWindow", "ptr")

SetTimer, TestNet, % timer
return

TestNet:
	if isNetActive(server, ping_Attempts, ping_Timeout, ping_PacketSize)
		editLabel(textSize, ActiveColor, BoldText, ActiveText)
	else
		editLabel(textSize, InActiveColor, BoldText, InactiveText)
	PixelGetColor, tColor, screenPos.x, screenPos.y+20, RGB
	Gui +LastFound
	WinGet, iColor, TransColor
	if (tColor != iColor) {
		Gui, Color, % tColor
		Gui +LastFound
		WinSet, TransColor, % tColor
		Gui -Caption
	}
	Gui +AlwaysOnTop +ToolWindow
	SetTimer, TestNet, % timer
return

MenuHandler:
	Switch A_ThisMenuItem
	{
		case "Open Settings":
			GoSub OpenSettings
		case "Reload":
			Reload
		case "Exit":
			ExitApp
	}
Return

OpenSettings:
	RunWait, % "notepad.exe """ A_ScriptDir "\Settings.txt"""
	Reload
return

editLabel(textSize, textColor, textBold, textString) {
	Gui, Font, % "s" textSize " c" textColor " " ((textBold)?"Bold":""),
	GuiControl, Font, SetActive
	GuiControl,,SetActive, % textString	
}

isNetActive(server, attempts, timeout, packetsize){
	pingOptions := "-n " attempts " -w " timeout " -l " packetsize
	pingString 	:= "ping " server " " pingOptions
	
	objShell := ComObjCreate("WScript.Shell")
	objExec := objShell.Exec(ComSpec " /c " pingString)
	strStdOut := ""
	While !objExec.Status
		Sleep 10
	cmdResp := objExec.StdOut.ReadAll()
	
	Return (InStr(cmdResp, "Reply from")>0)
}
