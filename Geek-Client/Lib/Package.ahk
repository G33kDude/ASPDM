class Package
{
	__New()
	{
		this.Extracted := False
	}
	
	LoadFile(FileName)
	{
		File := FileOpen(FileName, "r")
		if !this.SetCapacity("Data", File.Length)
			throw Exception("Couldn't allocate memory for file")
		this.pData := this.GetAddress("Data")
		this.DataSize := File.RawRead(this.pData+0, File.Length)
		File.Close()
		this.VerifyHeader()
	}
	
	LoadUrl(Url)
	{
		Http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		Http.Open("GET", Url, false)
		Http.Send()
		
		this.Data := http.ResponseBody
		this.pData := NumGet(ComObjValue(this.Data)+12, "UInt")
		this.DataSize := this.Data.MaxIndex()+1
		
		this.VerifyHeader()
	}
	
	VerifyHeader()
	{
		if this.GetHeader() != "AHKPKG00"
			throw Exception("Invalid format")
	}
	
	GetHeader()
	{
		return StrGet(this.pData, 8, "UTF-8")
	}
	
	GetManifest()
	{
		return this.ExtractFile(this.pData+8)
	}
	
	Extract()
	{
		Ptr := this.pData
		
		Offset := 8
		ManifestSize := NumGet(Ptr+Offset, "UInt")
		Offset := (Offset + ManifestSize + 7) &~ 3 ; Magic - someone please explain
		
		Ptr += Offset
		this.UncompSize := NumGet(Ptr+0, "UInt"), Ptr += 4
		
		if !this.SetCapacity("UncompData", this.UncompSize)
			throw Exception("Couldn't allocate data for the uncompressed package")
		this.pUncompData := this.GetAddress("UncompData")
		
		if DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", this.pUncompData, "UInt", this.UncompSize
			, "Ptr", Ptr, "UInt", this.pData + this.DataSize - Ptr, "UInt*", FinalSize) != 0 ; Uhh, can't I omit the "!= 0"?
		throw Exception("Error decompressing package")
		
		this.Extracted := True
	}
	
	ExtractFile(Ptr)
	{
		FileSize := NumGet(Ptr+0, "UInt")
		return StrGet(Ptr+4, FileSize, "UTF-8")
	}
	
	; TODO: Flatten recursion
	ExtractTreeObj(ByRef Obj, Dir="", Ptr=0)
	{
		if !this.Extracted
			this.Extract()
		if !Ptr
			Ptr := this.pUncompData
		if !IsObject(Obj)
			Obj := {}
		Elements := NumGet(Ptr+0, "UInt"), Ptr += 4
		Loop, %Elements%
		{
			Name := Util_ReadLenStr(ptr, ptr)
			Size := NumGet(Ptr+0, "UInt"), Ptr += 4
			if (Size == 0xFFFFFFFF)
			{
				Obj.Insert(Name, {})
				if !(Ptr := this.ExtractTreeObj(Obj[Name], Dir "\" Name, Ptr))
					break
			}
			else
			{
				Obj.Insert(Name, Ptr-4)
				Ptr += (Size+3) &~ 3
			}
		}
		return Ptr
	}
	
	ExtractTree()
	{
		if !this.Extracted
			this.Extract()
		Out := {}
		Work := [[this.pUncompData, Out]]
		While Info := Work.Remove()
		{
			Ptr := Info.1, Obj := Info.2
			Elements := NumGet(Ptr+0, "UInt"), Ptr += 4
			Loop, % Elements
			{
				Name := Util_ReadLenStr(Ptr, Ptr)
				Size := NumGet(Ptr+0, "UInt"), Ptr += 4
				if (Size == 0xFFFFFFFF)
				{
					SubObj := {}
					Obj.Insert(Name, SubObj)
					Work.Insert([Ptr, SubObj])
				}
				else
				{
					Obj.Insert(Name, Ptr-4)
					Ptr += (Size+3) &~ 3
				}
			}
		}
		return Out
	}
}

Util_ReadLenStr(ptr, ByRef endPtr)
{
	len := NumGet(ptr+0, "UInt")
	endPtr := ptr + ((len+7)&~3)
	return StrGet(ptr+4, len, "UTF-8")
}