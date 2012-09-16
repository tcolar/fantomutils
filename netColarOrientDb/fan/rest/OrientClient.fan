// History:
//   Sep 2, 2011 thibaut Creation
//
using web
using util

**
** OrientClient
**
class OrientClient
{
  const Uri server
  const Str username
  const Str:Str headers
  
  Str? database // current database
  
  Str:DocumentFields cachedEntities := [:]
  
  public static const Log log := Log.get("netColarOrient")
  
  **
  ** Construct with lobby URI and authentication credentials.
  **
  new make(Uri server, Str username, Str password)
  {
    this.server = server.plusSlash
    this.username = username
    
    this.headers = ["Content-Type" : "application/json; charset=utf-8",
                "Remote-User"  : username,
                "Authorization": "Basic " + "${username}:${password}".toBuf.toBase64 ,
                "Cache-Control": "no-cache"].ro

  }
  
  This connect(Str database)
  {
    log.info("Connecting to db: $database")
    RestReq(headers, ["$server","connect","$database"]).get

    this.database = database

    return this
  }
  
  This disconnect()
  {    
    log.info("Disconnecting from db: $database")
    database = null
    RestReq(headers, ["$server","disconnect"]).get
    return this
  }
  
  ** Get server infos
  Obj? serverInfos(Str adminName, Str adminPassword)
  {
    adminHeaders := [:].addAll(headers)
    adminHeaders["Authorization"] = "Basic " + "$adminName:$adminPassword".toBuf.toBase64
    log.info("Retrieving server infos")
    res := RestReq(adminHeaders, ["$server","server"]).get
    return JsonInStream(res.in).readJson
  }
  
  Bool classExists(Type type)
  {
    try
    {
        RestReq(headers, ["$server","class","$database","$type.name","1"]).get()
    }
    catch(RestErr e)
    {
      if(e.code == 500 || e.msg.contains("Invalid class"))
        return false
      throw(e)
    }  
    return true
  }
  
  Str createClass(Type type)
  {
    return RestReq(headers, ["$server","class","$database","$type.name"]).post("")   
  }
  
  Str getClassRecords(Type type, Int limit := 20)
  {
    return RestReq(headers, ["$server","class","$database","$type.name","$limit"]).get()   
  }
  
  ** Write a Json formatted document  
  Str writeDocument(Str jsonDoc)
  {
    log.info("Writing doc: $jsonDoc")
    
    return RestReq(headers, ["$server","document","$database"]).post(jsonDoc)   
  }
    
  ** Write an object annotated with OrientDocument 
  ** This might make several requests if the object is composed (of lists of other OrientDocument objects)
  This writeDocumentObj(Obj obj)
  {
    json := jsonizeObj(obj)
    
    writeDocument(json)
    
    return this    
  }

  //TODO: cluster get
  //TODO: cluster post
  //TODO: command post
  //TODO: database get
  //TODO: database post
  //TODO: doc put
  //TODO: doc delete
  //TODO: docByClass get
  //TODO: storage get
  //TODO: index get
  //TODO: index put
  //TODO: index delete
  //TODO: query get

  
      
  ** Register all entity types found in pod (annotated with OrientDocument facet)  
  This registerEntityTypes(Pod pod)
  {
    pod.types.each
    {
      if(it.hasFacet(OrientDocument#))
      {
        registerEntityType(it)
      }
    }
    return this
  }  
  
  ** Register a single entity type
  ** Type must be annotated with OrientDocument facet
  ** Results are cached to avoid doing reflection every time
  ** It will automatically create an OrientDb class for that type
  This registerEntityType(Type type)
  {
    if(database == null)
    {
      throw Err("Need to call connect() before registerEntity")
    } 
    if( ! type.hasFacet(OrientDocument#))
    {
      throw Err("Type $type does not have DocumentFields Facet.")
    }
    name := type.name
    if(cachedEntities.containsKey(name))
    {
      throw Err("Duplicated Entity name: $name !")      
    }
    cachedEntities[name] = DocumentFields(type)    
    
    log.info("Registering entity: $name")
    
    if( ! classExists(type))
        createClass(type)
          
    return this;
  }
  
  // .......... Internals
      
  ** Gets Json text version of an Object annotated with @OrientDocument
  private Str jsonizeObj(Obj obj)
  {
    objName := obj.typeof.name
    if(! cachedEntities.containsKey(objName))
      throw Err("No Entity found with name '$objName', maybe you forgot to call registerEntity ?")   
                         
    buf := StrBuf()
    buf.add("{\"@class\":\"$objName\", ")
    // Without this, it does not create it's own record for nested objects
    // -> 'd' means "own document"
    buf.add("\"@type\":\"d\", ") 
              
    fields := cachedEntities[objName]
    fields.fieldNames.each |Str name, Int cpt| 
    {
      field := obj.trap(name)
      // TODO : Allow maps too ?
      if(field is List)
      {
        buf.add("\"$name\":[ ")
        list := field as List  
          
        list.each |Obj o, Int cpt2|
        { 
          // Create the items separately and then link tem -> seems like a list whitin a doc doesn't work automatically
          id := writeDocument(jsonizeObj(o))
          buf.add("\"$id\"")
          if(cpt2 != list.size - 1)
            buf.add(",\n") 
        }    
        buf.add("]")    
      }     
      else if (field.typeof.hasFacet(OrientDocument#))
      {
        buf.add("\"$name\":").add(jsonizeObj(field))  
      } 
      else
      {
        buf.add("\"$name\":").add(JsonOutStream.writeJsonToStr(field))  
      }       
      if(cpt != fields.fieldNames.size - 1)
        buf.add(", ") 
    }  
    buf.add("}")
    
    return buf.toStr    
  }
  
  /*
  select from fellas where any() traverse(0,-1) ( @rid = [Michelle @rid] ) and @rid <> [Michelle @rid]")
  */
}
