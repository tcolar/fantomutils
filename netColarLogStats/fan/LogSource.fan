// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 10, 2010 thibautc Creation
//

**
** LogSource
**
class LogSource
{
	Uri path
	DateTime timestamp := DateTime.defVal
	Str md5
	Int lastLineRead := -1
	// FileFormat : txt / gz etc.. ?
	// LogFormat : Common, combined, IIS ....
}