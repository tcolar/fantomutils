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

	** Will throw ArgErr if not parseable.
	new make(Str data)
	{
		RegexMatcher matcher := ParserFormat.NcsaCombined.matcher(data)
		if(matcher.matches)
		{
			host = matcher.group(1)
			identd = matcher.group(2)
			user = matcher.group(3)
			timestamp = DateTime.fromLocale(matcher.group(4), ParserFormat.NcsaDatetime, TimeZone.cur(), false)
						?: throw ArgErr("Failed parsing date input: ${matcher.group(4)}")
			method = matcher.group(5)
			path = matcher.group(6)
			proto = matcher.group(7)
			status = Int.fromStr(matcher.group(8))
			size = Int.fromStr(matcher.group(9))
			referer = matcher.group(10)
			agent = matcher.group(11)
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
