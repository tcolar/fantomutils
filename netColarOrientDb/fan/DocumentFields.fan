// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Sep 2, 2011 thibaut Creation
//

**
** Cached / reflected DocumentFields
**
const class DocumentFields
{
  const Str[] fieldNames
  const Str? versionField
  const Str? idField
  
  new make(Type type)
  {
    names := Str[,]
    Str? id := null
    Str? version := null
    
    type.fields.each
    {
      names.add(it.name)
    }
    
    this.fieldNames = names
    this.versionField = version
    this.idField = id
  }
}