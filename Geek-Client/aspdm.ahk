#NoEnv
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include %A_ScriptDir%\Lib
#Include API.ahk
#Include JSON.ahk
#Include Package.ahk
#Include ExecScript.ahk

MyAPI := new API("http://api-php.aspdm.2fh.co/")
Packages := MyAPI.GetPackageList()


Gui, Main:New
Gui, Add, ListView, w600 h250 gPackageList, Name|Author|Version|Branch|Package Name
for PackageName, Metadata in Packages
	LV_Add("", Metadata.Name, Metadata.Author, Metadata.Version, Metadata.AHKBranch, PackageName)
Loop, 5
	LV_ModifyCol(A_Index, "AutoHdr")
Gui, Show
return

Escape::
MainGuiClose:
ExitApp
return

PackageList:
if (A_GuiEvent == "DoubleClick")
{
	LV_GetText(PackageName, A_EventInfo, 5)
	GoSub, MakePackageWindow
}
return

MakePackageWindow:
PackageMetadata := MyAPI.GetPackageMetadata(PackageName)
Description := PackageMetadata.Remove("Description")
Gui, Package:New, +OwnerMain
Gui, Add, ListView, w600 h250 gPackageDetailList, Key|Value
Gui, Add, Edit, ReadOnly w600 h250, % Description ? Description : "No description"
for k,v in PackageMetadata
	if !IsObject(v)
		LV_Add("", k, v)
Loop, 2
	LV_ModifyCol(A_Index, "AutoHdr")
Gui, Show
return

PackageGuiClose:
Gui, Destroy
return

PackageDetailList:
return

/*
	;--- Download extract and run gdip example without temporary files ---
	MyPackage := new Package()
	MyPackage.LoadUrl("http://aspdm.2fh.co/dl_file.php?f=gdip.ahkp")
	;MyPackage.LoadFile(".\gdip.ahkp")
	Tree := MyPackage.ExtractTree()
	Gdip := MyPackage.ExtractFile(Tree["Lib", "Gdip_All.ahk"])
	Script := MyPackage.ExtractFile(Tree["Gdip.Tutorial.9-Create.a.progress.bar.on.standard.gui.ahk"])
	Exec := ExecScript(Gdip "`n" Script)
	return
*/