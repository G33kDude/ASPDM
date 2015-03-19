class API
{
	__New(BaseUrl)
	{
		this.BaseUrl := RegExReplace(BaseUrl, "/$")
	}
	
	GetPackageUrl()
	{
		return this.
	}
	
	GetPackageList()
	{
		return this.GetJson("list.php", {"full": ""})
	}
	
	GetPackageMetadata(PackageName)
	{
		return this.GetJson("info.php", {"f": PackageName})
	}
	
	GetJson(Page, Params)
	{
		return Json_ToObj(this.Get(Page, Params))
	}
	
	Get(Page, Params)
	{
		Url := this.MakeUrl(Page, Params)
		try
		{
			; Make a new object every time. It's slower but (probably) more thread safe.
			; Another solution would be to use Critical
			Http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			Http.Open("GET", Url, false), Http.Send()
			return Http.ResponseText
		}
		catch
			throw Exception("There was a problem accessing " Url)
	}
	
	MakeUrl(Page, Params)
	{
		for Name, Value in Params
			Query .= "&" UriEncode(Name) "=" UriEncode(Value)
		if Query
			return this.BaseUrl "/" Page "?" SubStr(query, 2)
		else
			return this.BaseUrl "/" Page
	}
}

; Modified by GeekDude from http://goo.gl/0a0iJq
UriEncode(Uri)
{
	VarSetCapacity(Var, StrPut(Uri, "UTF-8"), 0), StrPut(Uri, &Var, "UTF-8")
	f := A_FormatInteger
	SetFormat, IntegerFast, H
	While Code := NumGet(Var, A_Index - 1, "UChar")
		If (Code >= 0x30 && Code <= 0x39 ; 0-9
			|| Code >= 0x41 && Code <= 0x5A ; A-Z
	|| Code >= 0x61 && Code <= 0x7A) ; a-z
	Res .= Chr(Code)
	Else
		Res .= "%" . SubStr(Code + 0x100, -1)
	SetFormat, IntegerFast, %f%
	Return, Res
}