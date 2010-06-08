// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 8, 2010 thibautc Creation
//

**
** ParserFormat
**
class ParserFormat
{
	** http://publib.boulder.ibm.com/tividd/td/ITWSA/ITWSA_info45/en_US/HTML/guide/c-logs.html
	**										   IP/Host	identd	user   Timestamp    Method   Path  Proto   status size referer agent
	static const Regex NcsaCombined := Regex<|^(\s+)\S+(\s+)\S+(\s+)\S+(\[[^\]]+\])\S+"(\s+)\S+(\s+)\S+(\s+)"\S+(\d+)\S+(\d+)\S+"(.*)"\S+"(.*)"$|>
}