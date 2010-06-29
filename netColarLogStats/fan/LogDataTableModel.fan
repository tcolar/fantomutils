// Artistic License 2.0
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
  Str keyHeader := ""
  Str valHeader := ""

  // TODO: Javascript deserialization of maps is not implemented yet, using custom object
  internal LogDataPoint[] data := [,]

  override Int numRows() { data.size }
  override Int numCols() { 2 }
  override Str header(Int col) { col==0 ? keyHeader : valHeader }
  override Str text(Int col, Int row){ col==0 ? data[row].formatedKey : data[row].val.toStr }

  ** Return the highest value found in the data points
  once Int dataMaxVal()
  {
	data.reduce(0) |Int v, LogDataPoint p -> Int| {return p.val > v ? p.val : v}
  }

  ** return the total of all the point values added together
  once Int dataTotal()
  {
	data.reduce(0) |Int v, LogDataPoint p -> Int| {return v + p.val}
  }

}

** Single data point, with custom lightweight serialization
@Js
@Serializable { simple = true }
class LogDataPoint
{
	** The full "key"
	Str key
	** The key formnated for display
	Str formatedKey
	** value
	Int val

	new make(Str key, Str formatedKey, Int val)
	{
		this.key=key; this.formatedKey=formatedKey; this.val=val
	}

	** Simple de-serialization
	static LogDataPoint fromStr(Str s) { a := s.split(';'); return LogDataPoint(a[0], a[1], a[2].toInt)}

	** Simple serialization
	override Str toStr()
	{
		k :=key.replace(";",",");
		fk := formatedKey.replace(";",",");
		return "$k;$fk;$val"
	}
}

**
** This helper is for setting the LogDataTableModel from various sources
** It's not compiled to javascript so can access SQL etc...
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
		if(model.keyHeader.isEmpty) model.keyHeader = row.col(keyCol).name
		if(model.valHeader.isEmpty) model.valHeader = row.col(valCol).name
		key := row.get(row.col(keyCol)).toStr
		val := row.get(row.col(valCol))
		formatedKey := keyTextFormater==null ? key : keyTextFormater.call(key)

		model.data.add(LogDataPoint(key, formatedKey, val))
	}
	return model
  }
}
