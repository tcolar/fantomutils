// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   May 24, 2010 thibautc Creation
//

**
** TableModel : Facet to customize a DBModel and it's mapping to a database table
**
facet class TableModel
{
  ** Table name, If null base on Model name
  const Str? name

  ** Wether to create the Table if it does not exist
  const Bool autoCreate := true

  ** Allow specifying which field is the primaryKey
  ** If null(default), the automatically generated field "ID" will be the PK
  ** If a pkey is defined, no "ID" field will be auto-generated in the database
  const Slot? primaryKey
}

**
** FieldModel : Facet to cutomize a DBModel field and it's mapping to a database column
**
facet class FieldModel
{
  ** Field name, If null base on Field name
  const Str? name

  //** Specify the field size - Only used for some field types, such as varchar
  const Int size := 80

  //** Min/Max values, only makes sense for Number fields
  // TODO const Num? minVal
  // TODO const Num? maxVal

  ** Whether to index this field in the DB**
  const Bool indexIt := false
}

** Mark a custom field to be serialized(~JSON string) when saved to the database
** (Uses a 2000 length varchar)
facet class SerializeField
{
}