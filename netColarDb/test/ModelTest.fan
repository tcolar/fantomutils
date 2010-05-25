// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   May 24, 2010 thibautc Creation
//

**
** ModelTest
**
@TableModel{name = "MODEL_TEST"}
class Model : DBModel
{
  @FieldModel {name="KEY"; isPKey=true; size=40}
  Str key

  Int val
}

class ModelTest : Test
{
  
}