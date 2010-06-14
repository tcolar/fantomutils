// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 8, 2010 thibautc Creation
//

**
** ParsedLine
** Data holder for a parsed log line data
**
const class ParsedLine
{
	const Str host := Str.defVal
	const Str identd := Str.defVal
	const Str user := Str.defVal
	const DateTime timestamp := DateTime.defVal
	const Str method := Str.defVal
	const Str path := Str.defVal
	const Str proto := Str.defVal
	const Int status := Int.defVal
	const Int size := Int.defVal
	const Str referer := Str.defVal
	const Str agent := Str.defVal

	** Will throw ArgErr if not parseable.
	new make(Str data)
	{
		RegexMatcher matcher := ParserFormat.NcsaCombined.matcher(data)
		if(matcher.matches)
		{
			host = matcher.group(1)
			identd = matcher.group(2)
			user = matcher.group(3)
			// Note: Olsen format : tz offset of -0400 really means GMT+4 -> weird
			timestamp = DateTime.fromLocale(matcher.group(4), ParserFormat.NcsaDatetime, TimeZone.cur(), false)
						?: throw ArgErr("Failed parsing date input: ${matcher.group(4)}")
			method = matcher.group(5)
			path = matcher.group(6)
			proto = matcher.group(7)
			status = Int.fromStr(matcher.group(8))
			size = Int.fromStr(matcher.group(9), 10, false) ?: 0
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
