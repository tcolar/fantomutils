// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 8, 2010 thibautc Creation
//

**
** Main
**
class Main
{
    **
    ** Main method
    **
    static Void main()
    {
		cpt := 0
		d := DateTime.now
        File(`/tmp/colar.log`).in.eachLine |Str line|
		{
			try
				p := ParsedLine(line)
			catch
				echo("Failed parsing: $line")
			cpt++
		}
		time := DateTime.now - d
		output := cpt == 0 ? 0 : cpt / (time.ticks / 1_000_000_000)
		echo("Parsed $cpt lines in $time -> $output lines / sec")
    }
    
}