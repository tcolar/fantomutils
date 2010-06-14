// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 14, 2010 thibautc Creation
//
using fwt
using sql

**
** LogDataTableModel
** Data to be rendered by a LogDataRenderer
**
class LogDataTableModel : TableModel
{
  Str:Int data := [:] {ordered = true}
  // If null, then will be based on DB table column names
	Str? keyHeader
	Str? valHeader

  new make(Row[] rows, Str keyCol, Str valCol, |Str->Str|? keyFormater := null)
  {
	rows.each |Row row|
	{
		keyHeader = keyHeader ?: row.col(keyCol).name
		valHeader = valHeader ?: row.col(valCol).name
		Str key := row.get(row.col(keyCol)).toStr
		if(keyFormater!=null) key = keyFormater.call(key)
		Int val := row.get(row.col(valCol))
		data.set(key, val)
	}
  }

  override Int numRows() { data.size }
  override Int numCols() { 2 }
  override Str header(Int col) { col==0 ? keyHeader : valHeader }
  override Str text(Int col, Int row){ col==0 ? data.keys.get(row).toStr : data.vals.get(row).toStr }
  Int getValue(Str key) {data[key]}
}