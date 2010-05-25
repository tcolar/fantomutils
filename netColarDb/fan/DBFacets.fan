// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   May 24, 2010 thibautc Creation
//

**
** DBFacets
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

facet class FieldModel
{
  ** Field name, If null base on Field name
  const Str? name

  ** Specify the field size - Only used for filed some filed types, lsuch as string / varchar
  const Int? size

  ** Min/Max values, only makes sense for Number fields
  const Num? minVal
  const Num? maxVal

  ** Whether to indedx this field**
  const Bool indexIt := false

  ** Whether this is the primary key, usually an automatic key called 'ID' is auto-generated
  const Bool isPKey := false
}