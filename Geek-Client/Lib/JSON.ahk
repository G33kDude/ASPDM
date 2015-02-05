; JSON library by Coco https://github.com/cocobelgica/AutoHotkey-JSON

Json_ToObj(Src)
{
	return JSON.parse(Src)
}

Json_FromObj(Obj)
{
	return JSON.stringify(Obj)
}

class JSON
{
	/* Function:    parse
		* Deserialize a string containing a JSON document to an AHK object.
		* Syntax:
		*     json_obj := JSON.parse( src [, jsonize:=false ] )
		* Parameter(s):
		*     src      [in] - String containing a JSON document
		*     jsonize  [in] - If true, objects {} and arrays [] are wrapped as
		*                     JSON.object and JSON.array instances respectively.
	*/
	parse(src, jsonize:=false)
	{
		;// Pre-validate JSON source before parsing
		if ((src := Trim(src, " `t`n`r")) == "") ;// trim whitespace(s)
			throw "Empty JSON source"
		first := SubStr(src, 1, 1), last := SubStr(src, 0)
		if !InStr("{[""tfn0123456789-", first) ;// valid beginning chars
			|| !InStr("}]""el0123456789", last) ;// valid ending chars
		|| (first == "{" && last != "}") ;// if starts w/ '{' must end w/ '}'
		|| (first == "[" && last != "]") ;// if starts w/ '[' must end w/ ']'
		|| (first == """" && last != """") ;// if starts w/ '"' must end w/ '"'
		|| (first == "n" && last != "l") ;// assume 'null'
		|| (InStr("tf", first) && last != "e") ;// assume 'true' OR 'false'
		|| (InStr("-0123456789", first) && !InStr("0123456789", last)) ;// number
		throw Exception("Invalid JSON format")
		
		static esc_seq := {
(Join
"""": """",
"/": "/",
"b": "`b",
"f": "`f",
"n": "`n",
"r": "`r",
"t": "`t"
)}
			i := 0, strings := []
			while (i := InStr(src, """",, i+1))
			{
				j := i
				while (j := InStr(src, """",, j+1))
				{
					str := SubStr(src, i+1, j-i-1)
					StringReplace, str, str, \\, \u005C, A
					if (SubStr(str, 0) != "\")
						break
				}
				if !j
					throw Exception("Missing close quote(s)")
				src := SubStr(src, 1, i) . SubStr(src, j+1)
				k := 0
				while (k := InStr(str, "\",, k+1))
				{
					ch := SubStr(str, k+1, 1)
					if InStr("""btnfr/", ch, 1)
						str := SubStr(str, 1, k-1) . esc_seq[ch] . SubStr(str, k+2)
					
					else if (ch == "u")
					{
						hex := "0x" . SubStr(str, k+2, 4)
						if !(A_IsUnicode || (Abs(hex) < 0x100))
							continue ;// throw Exception() ???
						str := SubStr(str, 1, k-1) . Chr(hex) . SubStr(str, k+6)
						
					}
					else
						throw Exception(Format("Invalid escape sequence: '\{}'", ch))
				}
				strings.Insert(str)
			}
			
			;// Check for missing opening/closing brace(s)
			if InStr(src, "{") || InStr(src, "}")
			{
				StringReplace, dummy, src, {, {, UseErrorLevel
				c1 := ErrorLevel
				StringReplace, dummy, src, }, }, UseErrorLevel
				c2 := ErrorLevel
				if (c1 != c2)
					throw Exception(Format("Missing {} {}ing brace(s)", Abs(c1-c2), c1 > c2 ? "clos" : "open"))
			}
			;// Check for missing opening/closing bracket(s)
			if InStr(src, "[") || InStr(src, "]")
			{
				StringReplace, dummy, src, [, [, UseErrorLevel
				c1 := ErrorLevel
				StringReplace, dummy, src, ], ], UseErrorLevel
				c2 := ErrorLevel
				if (c1 != c2)
					throw Exception(Format("Missing {} {}ing bracket(s)", Abs(c1-c2), c1 > c2 ? "clos" : "open"))
			}
			
			static t := "true", f := "false", n := "null", null := ""
			jbase := jsonize ? { "{":JSON.object, "[":JSON.array } : { "{":0, "[":0 }
			, pos := 0
			, key := "", is_key := false
			, stack := [tree := []]
			, is_arr := {(tree): 1}
			, next := first ;// """{[01234567890-tfn"
			while ((ch := SubStr(src, ++pos, 1)) != "")
			{
				if InStr(" `t`n`r", ch)
					continue
				if !InStr(next, ch)
					throw Exception(Format("Unexpected char: '{}'", ch))
				
				is_array := is_arr[obj := stack[1]]
				
				if InStr("{[", ch)
				{
					val := (proto := jbase[ch]) ? new proto : {}
					, obj[is_array? NumGet(&obj + 4*A_PtrSize)+1 : key] := val
					, ObjInsert(stack, 1, val)
					, is_arr[val] := !(is_key := ch == "{")
					, next := is_key ? """}" : """{[]0123456789-tfn"
				}
				
				else if InStr("}]", ch)
				{
					ObjRemove(stack, 1)
					, next := is_arr[stack[1]] ? "]," : "},"
				}
				
				else if InStr(",:", ch)
				{
					if (obj == tree)
						throw Exception(Format("Unexpected char: '{}' -> there is no container object.", ch))
					next := """{[0123456789-tfn", is_key := (!is_array && ch == ",")
				}
				
				else
				{
					if (ch == """")
					{
						val := ObjRemove(strings, 1)
						if is_key
						{
							key := val, next := ":"
							continue
						}
						
					}
					else
					{
						val := SubStr(src, pos, (SubStr(src, pos) ~= "[\]\},\s]|$")-1)
						, pos += StrLen(val)-1
						if InStr("tfn", ch, 1)
						{
							if !(val == %ch%)
								throw Exception(Format("Expected '{}' instead of '{}'", %ch%, val))
							val := %val%
						}
						else if (Abs(val) == "")
							throw Exception("Invalid number: " . val)
						val := val + 0
					}
					obj[is_array? NumGet(&obj + 4*A_PtrSize)+1 : key] := val
					next := is_array ? "]," : "},"
				}
			}
			return tree[1]
		}
		/* Function:    stringify
			* Serialize an object to a JSON formatted string.
			* Syntax:
			*     json_str := JSON.stringify( obj [, indent:="" ] )
			* Parameter(s):
			*     obj      [in] - The object to stringify.
			*     indent   [in] - Specify string(s) to use as indentation per level.
		*/
		stringify(obj:="", indent:="", lvl:=1)
		{
			if IsObject(obj)
			{
				if (ObjGetCapacity(obj) == "") ;// COM,Func,RegExMatch,File object
					throw Exception("Unsupported object type")
				
				is_array := 0
				for k in obj
					is_array := (k == A_Index)
				until !is_array
				
				if (Abs(indent) != "")
				{
					if (indent < 0)
						throw Exception("Indent parameter must be a postive integer")
					spaces := indent, indent := ""
					Loop % spaces
						indent .= " "
				}
				indt := ""
				Loop, % indent ? lvl : 0
					indt .= indent
				
				lvl += 1, out := "" ;// make #Warn happy
				for k, v in obj
				{
					if IsObject(k) || (k == "")
						throw Exception("Invalid JSON key")
					
					if !is_array
						out .= ( ObjGetCapacity([k], 1) ? JSON.stringify(k) : """" . k . """" ) ;// key
					.  ( indent ? ": " : ":" ) ;// token + padding
					out .= JSON.stringify(v, indent, lvl) ;// value
					.  ( indent ? ",`n" . indt : "," ) ;// token + indent
				}
				
				if (out != "")
				{
					out := Trim(out, ",`n" indent)
					if (indent != "")
						out := Format("`n{}{}`n{}", indt, out, SubStr(indt, StrLen(indent)+1))
				}
				
				return is_array ? "[" out "]" : "{" out "}"
			}
			
			;// Not a string - assume number -> integer or float
			if (ObjGetCapacity([obj], 1) == "") ;// returns an integer if 'obj' is string
				return obj
			
			;// null - not supported in AHK
			
			;// String
			; if obj is float
			; 	return obj
			static esc_seq := {
(Join
"""": "\""",
"/":  "\/",
"`b": "\b",
"`f": "\f",
"`n": "\n",
"`r": "\r",
"`t": "\t"
)}
				
				if (obj != "")
				{
					StringReplace, obj, obj, \, \\, A
					for k, v in esc_seq
						StringReplace, obj, obj, %k%, %v%, A
					
					while RegExMatch(obj, "[^\x20-\x7e]", wstr)
					{
						esc_hex := Format("\u{:04X}", Asc(wstr))
						StringReplace, obj, obj, %wstr%, %esc_hex%, A
					}
				}
				
				return """" . obj . """"
			}
			
			class object
			{
				
				__New(args*)
				{
					ObjInsert(this, "_", [])
					if ((count := NumGet(&args+4*A_PtrSize)) & 1)
						throw "Invalid number of parameters"
					Loop % count//2
						this[args[A_Index*2-1]] := args[A_Index*2]
				}
				
				__Set(key, val, args*)
				{
					ObjInsert(this._, key)
				}
				
				Insert(key, val)
				{
					return this[key] := val
				}
				/* Buggy - remaining integer keys are not adjusted
					Remove(args*) { 
						ret := ObjRemove(this, args*), i := -1
						for index, key in ObjClone(this._) {
							if ObjHasKey(this, key)
								continue
							ObjRemove(this._, index-(i+=1))
						}
						return ret
					}
				*/
				Count()
				{
					return NumGet(&(this._) + 4*A_PtrSize) ;// Round(this._.MaxIndex())
				}
				
				stringify(indent:="")
				{
					return JSON.stringify(this, indent)
				}
				
				_NewEnum()
				{
					static proto := { "Next": JSON.object.Next }
					return { base: proto, enum: this._._NewEnum(), obj: this }
				}
				
				Next(ByRef key, ByRef val:="")
				{
					if (ret := this.enum.Next(i, key))
						val := this.obj[key]
					return ret
				}
			}
			
			class array
			{
				
				__New(args*)
				{
					args.base := this.base
					return args
				}
				
				stringify(indent:="")
				{
					return JSON.stringify(this, indent)
				}
			}
		}