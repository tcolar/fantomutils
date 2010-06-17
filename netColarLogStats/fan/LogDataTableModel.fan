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
@Js
class LogDataTableModel : TableModel
{
  Str title := ""
  // If null, then will be based on DB table column names
  Str? keyHeader := ""
  Str? valHeader := ""
  ** This can be set to use a cutsom formatter on the key display
  ** This is what is displayed as the horizontal scale on a graph
  |Str->Str|? keyTextFormater

  internal Str:Int data := [:] {ordered = true}

  new make(Row[] rows, Str keyCol, Str valCol)
  {
	rows.each |Row row|
	{
		keyHeader = keyHeader ?: row.col(keyCol).name
		valHeader = valHeader ?: row.col(valCol).name
		Str key := row.get(row.col(keyCol)).toStr
		Int val := row.get(row.col(valCol))
		data.set(key, val)
	}
  }

  override Int numRows() { data.size }
  override Int numCols() { 2 }
  override Str header(Int col) { col==0 ? keyHeader : valHeader }
  override Str text(Int col, Int row){ col==0 ? data.keys.get(row).toStr : data.vals.get(row).toStr }

  Int getValue(Str key) {data[key]}

  Str getFormatedKeyText(Str key) {keyTextFormater==null ? key : keyTextFormater.call(key)}
}