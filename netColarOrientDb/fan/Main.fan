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
  static Void main()
  {
    // Created Test DB
    // vi /config/orientdb-server-config.xml 
    // Then added a new "storage" in the xml:
    //   <storage name="test" path="local:../datbases/test" userName="admin"
    //   userPassword="admin" loaded-at-startup="true"/> 
    c := OrientClient(`http://localhost:2480`, "admin", "admin")
    c.connect("test")
    echo(c.ceateClass(Client#))
    
    (1..10).each
    {
      Bill[] bills := [,]
      (1..5).each
      {
        bills.add(Bill("item"+it, 100 + it))
      }
      client := Client("client"+it, bills)
      echo(c.writeDocument(client))
    }    
    
    c.disconnect
  }
  
}

@Serializable
class Client
{
  Str name
  Bill[] bills
  new make(Str name, Bill[] bills) 
  {
    this.name = name
    this.bills = bills
  }
}

@Serializable
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