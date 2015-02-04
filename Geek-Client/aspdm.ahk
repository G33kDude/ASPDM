#NoEnv

#Include Lib\Package.ahk

; --- Download extract and run gdip example without temporary files ---
MyPackage := new Package()
MyPackage.LoadUrl("http://aspdm.2fh.co/dl_file.php?f=gdip.ahkp")
;MyPackage.LoadFile(".\gdip.ahkp")
MyPackage.ExtractTreeObj(Tree)
Gdip := MyPackage.ExtractFile(Tree["Lib", "Gdip_All.ahk"])
Script := MyPackage.ExtractFile(Tree["Gdip.Tutorial.9-Create.a.progress.bar.on.standard.gui.ahk"])
Exec := ExecScript(Gdip "`n" Script)
return

; Modified from https://github.com/cocobelgica/AutoHotkey-Util/blob/master/ExecScript.ahk
ExecScript(Script, Params="")
{
	Name := "AHK_CQT_" A_TickCount
	Pipe := []
	Loop, 2
	{
		Pipe[A_Index] := DllCall("CreateNamedPipe"
		, "Str", "\\.\pipe\" name
		, "UInt", 2, "UInt", 0
		, "UInt", 255, "UInt", 0
		, "UInt", 0, "UPtr", 0
		, "UPtr", 0, "UPtr")
	}
	Call = "%A_AhkPath%" /CP65001 "\\.\pipe\%Name%"
	Shell := ComObjCreate("WScript.Shell")
	Exec := Shell.Exec(Call " " Params)
	DllCall("ConnectNamedPipe", "UPtr", Pipe[1], "UPtr", 0)
	DllCall("CloseHandle", "UPtr", Pipe[1])
	DllCall("ConnectNamedPipe", "UPtr", Pipe[2], "UPtr", 0)
	FileOpen(Pipe[2], "h", "UTF-8").Write(Script)
	DllCall("CloseHandle", "UPtr", Pipe[2])
	return Exec
}

/*
	Http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	Http.Open("GET", "http://api-php.aspdm.2fh.co/list.php?full", false)
	Http.Send()
	
	Libraries := Json_ToObj(http.ResponseText)
	Array_Gui(Libraries)
	
	Gui, Add, ListView, w640 h480 gMyListView, Name|Author|Version|Branch|Package
	for Package, Library in Libraries
		LV_Add("", Library.Name, Library.Author, Library.Version, Library.AHKBranch, Package)
	Loop, 5
		LV_ModifyCol(A_Index, "AutoHdr")
	Gui, Show
	return
	
	Escape::
	GuiClose:
	ExitApp
	return
	
	MyListView:
	if (A_GuiEvent == "DoubleClick")
	{
		LV_GetText(Package, A_EventInfo, 5)
		Run, % Libraries[Package].ForumUrl
	}
	return
*/