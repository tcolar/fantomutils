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
		verifyEq(line.agent, "Java/1.6.0_21-ea")
		verifyEq(line.host, "89.216.33.172")
		verifyEq(line.identd, "-")
		verifyEq(line.user, "-")
		verifyEq(line.method, "GET")
		verifyEq(line.path, "/fantomide/plugin/6.8/net-colar-netbeans-fan.nbm")
		verifyEq(line.proto, "HTTP/1.1")
		verifyEq(line.referer, "-")
		verifyEq(line.size, 2482259)
		verifyEq(line.status, 200)
		// Note: Olsen format : -0400 means GMT+4 -> weird
		verifyEq(line.timestamp.toStr, "2010-06-08T01:43:17-04:00 GMT+4")
		echo(line)
	}

	Void testQueries()
	{
		task := LogTask
		{
			type = TaskType.COUNT_UNIQUE
			limiterValue = 50
			target = TaskTarget.URL
			slices = [TaskGranularity.DAY:TaskSpan.CUR_MONTH]
		}
	}
}