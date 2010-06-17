// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 14, 2010 thibautc Creation
//
using fwt
using sql

**
** Data to be rendered by a LogDataRenderer
** It will be compiled into javascript
** And can be pasewd to the browser as a serailized object
** So it needs to be kept to the minimum
**
@Js
@Serializable
class LogDataTableModel : TableModel
{
  Str title := ""
  // If null, then will be based on DB table column names
  Str? keyHeader := ""
  Str? valHeader := ""
  internal Str:Str formatedKeys  := [:]
  internal Str:Int data := [:] {ordered = true}

  override Int numRows() { data.size }
  override Int numCols() { 2 }
  override Str header(Int col) { col==0 ? keyHeader : valHeader }
  override Str text(Int col, Int row){ col==0 ? data.keys.get(row).toStr : data.vals.get(row).toStr }
}

**
** This helper id for setting the LogDataTableModel from various sources
** It's not cvompiled to javascript so can access SQL etc...
**
class LogDataTableModelHelper
{

  ** Set the model data from a set of SQL rows
  ** KeyFormater can be set to use a custom formatter on the key display
  ** This is what is displayed as the horizontal scale on a graph
  static LogDataTableModel injectRows(LogDataTableModel model, Row[] rows, Str keyCol, Str valCol, |Str->Str|? keyTextFormater := null)
  {
	rows.each |Row row|
	{
		if(model.keyHeader == null ) model.keyHeader = row.col(keyCol).name
		if(model.valHeader == null ) model.valHeader = row.col(valCol).name
		key := row.get(row.col(keyCol)).toStr
		val := row.get(row.col(valCol))
		model.data.set(key, val)
		formatedKey := keyTextFormater==null ? key : keyTextFormater.call(key)
		model.formatedKeys.set(key, formatedKey)
	}
	return model
  }
}
