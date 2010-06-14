// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 14, 2010 thibautc Creation
//
using fwt
using gfx

**
** Mixin to be used for Log data rendering implementations (graphs etc...)
**
mixin LogDataRenderer
{
	abstract Canvas render(LogDataTableModel data, Size sz)
}

