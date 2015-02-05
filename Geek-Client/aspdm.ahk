#NoEnv
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include %A_ScriptDir%\Lib
#Include JSON.ahk
#Include Package.ahk
#Include ExecScript.ahk

; --- Download extract and run gdip example without temporary files ---
MyPackage := new Package()
MyPackage.LoadUrl("http://aspdm.2fh.co/dl_file.php?f=gdip.ahkp")
;MyPackage.LoadFile(".\gdip.ahkp")
Tree := MyPackage.ExtractTree()
Gdip := MyPackage.ExtractFile(Tree["Lib", "Gdip_All.ahk"])
Script := MyPackage.ExtractFile(Tree["Gdip.Tutorial.9-Create.a.progress.bar.on.standard.gui.ahk"])
Exec := ExecScript(Gdip "`n" Script)
return

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