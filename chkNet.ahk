#SingleInstance Force
#NoEnv

updateDismiss 		:= false
updateTimer			:= -60000
appFile				:= "app.bin"

githubchkNetFile	:= "https://raw.githubusercontent.com/snowy42/AHK-CheckCon/main/chkNet.ahk"
githubAppFile		:= "https://raw.githubusercontent.com/snowy42/AHK-CheckCon/main/app.bin"
githubRepos			:= "https://github.com/snowy42/AHK-CheckCon"
kcProxy				:= "http://kcproxy-civic.kingborough.local:8080"

startVer 			:= checkVersion(githubRepos,kcProxy)

SetTimer checkForUpdates, % updateTimer

#Include Settings.txt
#Include app.bin

checkForUpdates:
	if not (updateDismiss) {
		if not (checkVersion(githubRepos,kcProxy) = startVer){
			Msgbox, % 64+4+262144,% "New Update",% "A new version of chkNet is available, would you like to update now?"
			ifMsgBox Yes
				GoSub RunUpdate
			Else
				updateDismiss := true
		}
	}
	SetTimer checkForUpdates, % updateTimer
return

RunUpdate:

	While FileExist(appFile)
		FileDelete, % appFile
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", githubAppFile, true)
	whr.SetProxy(2,kcproxy, "")
	whr.Send()
	whr.WaitForResponse()
	FileAppend, % whr.ResponseText, % appFile
	sleep 500
	
	ScriptFile := A_ScriptFullPath
	While FileExist(ScriptFile)
		FileDelete, % ScriptFile
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", githubchkNetFile, true)
	whr.SetProxy(2,kcproxy, "")
	whr.Send()
	whr.WaitForResponse()
	FileAppend, % whr.ResponseText, % ScriptFile
	sleep 500
	Msgbox, chkNet successfully updated!`n`nThe script will now restart.
	reload
return

checkVersion(repository, proxy:=false){
	global 	server
		,	ping_Attempts
		,	ping_Timeout
		,	ping_PacketSize
	if (isNetActive(server, ping_Attempts, ping_Timeout, ping_PacketSize)){
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		whr.Open("GET",repository, true)
		(proxy)?whr.SetProxy(2,proxy, "")
		whr.Send()
		whr.WaitForResponse()

		Return SubStr(v := whr.ResponseText, St:=InStr(v,"Commits on main")-49,InStr(St,"<")+1)
		whr.Close()
	}
}
