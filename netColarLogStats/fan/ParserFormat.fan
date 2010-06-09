// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 8, 2010 thibautc Creation
//

**
** ParserFormat
** Log line formats, according to:
** `http://publib.boulder.ibm.com/tividd/td/ITWSA/ITWSA_info45/en_US/HTML/guide/c-logs.html`
**
class ParserFormat
{
	** Ex: 89.216.33.172 - - [08/Jun/2010:01:43:17 -0400] "GET /fantomide/plugin/6.8/net-colar-netbeans-fan.nbm HTTP/1.1" 200 2482259 "-" "Java/1.6.0_21-ea"
	**										   IP/Host	identd	user   Timestamp    Method   Path  Proto   status size referer agent
	static const Regex NcsaCombined := Regex<|^(\S+)\s+(\S+)\s+(\S+)\s+\[([^\]]+)\]\s+"(\S+)\s+(\S+)\s+(\S+)"\s+(\d+)\s+(\d+)\s+"([^"]*)"\s+"([^"]*)"$|>
	** Ex: 08/Jun/2010:01:43:17 -0400
	static const Str NcsaDatetime := "DD/MMM/YYYY:hh:mm:ss z"
}