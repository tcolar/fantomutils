// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 8, 2010 thibautc Creation
//

**
** ParsedLine
**
class ParsedLine
{
	Str host := Str.defVal
	Str identd := Str.defVal
	Str user := Str.defVal
	DateTime timestamp := DateTime.defVal
	Str method := Str.defVal
	Str path := Str.defVal
	Str proto := Str.defVal
	Int status := Int.defVal
	Int size := Int.defVal
	Str referer := Str.defVal
	Str agent := Str.defVal

	new make(Str data)
	{
		RegexMatcher matcher := ParserFormat.NcsaCombined.matcher(data)
		if(matcher.matches)
		{
			host = matcher.group(1)
			identd = matcher.group(2)
			timestamp = DateTime.fromHttpStr(matcher.group(3),false) ?: throw ArgErr("Failed parsing date input: $matcher.group(3)")
			method = matcher.group(4)
			path = matcher.group(5)
			proto = matcher.group(6)
			status = Int.fromStr(matcher.group(7))
			size = Int.fromStr(matcher.group(8))
			referer = matcher.group(9)
			agent = matcher.group(10)
		}
		else
		{
			throw ArgErr("Failed parsing input: $data")
		}
	}

	override Str toStr()
	{
		"""Time: $timestamp; Host: $host; Identd: $identd; user: $user; Status: $status; Size: $size
		   Path: $path; Method: $method; Proto: $proto
		   Agent: $agent; Referer: $referer
		   """
	}
}
