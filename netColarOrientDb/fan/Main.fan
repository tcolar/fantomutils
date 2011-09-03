// History:
//   Sep 2, 2011 thibaut Creation
//

**
** Main
**
class Main
{
  **
  ** Main method
  **
  Void main()
  {
    // Created Test DB
    // vi /config/orientdb-server-config.xml 
    // Then added a new "storage" in the xml:
    //   <storage name="test" path="local:../datbases/test" userName="admin"
    //   userPassword="admin" loaded-at-startup="true"/> 
    c := OrientClient(`http://localhost:2480`, "admin", "admin")
    c.connect("test")

    c.registerEntityTypes(this.typeof.pod)
    
    bill := Bill("item1", 100)
    
    client := Client("client6", bill)

    c.writeDocumentObj(client)
    
    c.disconnect
  }
  
}

@OrientDocument
class Client
{
  Str name
  Bill bill
  new make(Str name, Bill bill) 
  {
    this.name = name
    this.bill = bill
  }
}

@OrientDocument
class Bill
{
  Str item
  Int price
  new make(Str item, Int price)
  {
    this.item = item
    this.price = price
  }
}