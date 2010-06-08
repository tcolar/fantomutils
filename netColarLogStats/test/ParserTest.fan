// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 8, 2010 thibautc Creation
//

**
** ParserTest
**
class ParserTest : Test
{
	Void testParser()
	{
		Str data := Str<|89.216.33.172 - - [08/Jun/2010:01:43:17 -0400] "GET /fantomide/plugin/6.8/net-colar-netbeans-fan.nbm HTTP/1.1" 200 2482259 "-" "Java/1.6.0_21-ea"|>
		ParsedLine? line := ParsedLine(data)
		verifyNotNull(line, "Line matched")
		echo(line)
	}
}