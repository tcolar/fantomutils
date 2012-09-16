// History:
//   Sep 2, 2011 thibaut Creation
//
// Created Test DB
// vi /config/orientdb-server-config.xml 
// Then added a new "storage" in the xml:
//   <storage name="test" path="local:../datbases/test" userName="admin"
//   userPassword="admin" loaded-at-startup="true"/> 

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
    Log.get("netColarOrient").level = LogLevel.debug
    
    c := OrientClient(`http://localhost:2480`, "admin", "admin")
    c.connect("test")

    c.registerEntityTypes(this.typeof.pod)
    
    bills := [Bill("item1", 101), Bill("item2", 102)]
    
    client := Client("client7", bills)

    c.getClassRecords(Bill#, 5)

    c.writeDocumentObj(client)
    
    c.disconnect
  }
  
}

@OrientDocument
class Client
{
  Str name
  Bill[] bills
  Bill singleBill
  
  new make(Str name, Bill[] bills) 
  {
    this.name = name
    this.bills = bills
    this.singleBill = bills[0]
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