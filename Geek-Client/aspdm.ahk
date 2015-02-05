#NoEnv
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include %A_ScriptDir%\Lib
#Include JSON.ahk
#Include Package.ahk
#Include ExecScript.ahk

Packages := GetPackages()

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
PackageMetadata := GetPackageMetadata(PackageName)
Gui, Package:New, +OwnerMain
Gui, Add, ListView, w600 h250 gPackageDetailList, Key|Value
Gui, Add, Edit, ReadOnly w600 h250, % PackageMetadata.Remove("Description")
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

GetPackages()
{
	static PackageListingAPI := "http://api-php.aspdm.2fh.co/list.php?full"
	return UrlDownloadToObj(PackageListingAPI)
}

GetPackageMetadata(PackageName)
{
	static PackageDetailsAPI := "http://api-php.aspdm.2fh.co/info.php?f="
	return UrlDownloadToObj(PackageDetailsAPI . PackageName)
}

UrlDownloadToObj(Url)
{
	return Json_ToObj(UrlDownloadToVar(Url))
}

UrlDownloadToVar(Url)
{
	try
	{
		Http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		Http.Open("GET", Url, false), Http.Send()
		return Http.ResponseText
	}
	catch
		throw Exception("There was a problem accessing " Url)
}

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