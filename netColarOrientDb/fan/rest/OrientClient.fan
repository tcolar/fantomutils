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
  const Str authHeader
  Str? database // current database
  
  Str:DocumentFields cachedEntities := [:]
  
  static const Log log := Log.get("netColarOrient")
  
  **
  ** Construct with lobby URI and authentication credentials.
  **
  new make(Uri server, Str username, Str password)
  {
    this.server = server.plusSlash
    this.username = username
    this.authHeader = "Basic " + "$username:$password".toBuf.toBase64
  }
  
  This connect(Str database)
  {
    log.info("Connecting to db: $database")
    this.database = database
    req := makeReq(server.plusName("connect", true).plusName(database), "GET").writeReq.readRes  
    
    if(req.resCode != 200)
    {
      err := Err("Connection failed: "+req.resBuf.readAllStr)
      log.err("error", err)
      throw err
    }
    return this
  }
  
  This disconnect()
  {    
    log.info("Disconnecting from db: $database")
    makeReq(server.plusName("disconnect"), "GET").writeReq.readRes
    database = null
    return this
  }
  
  ** Get server infos
  Obj? serverInfos(Str adminName, Str adminPassword)
  {
    log.info("Retrieving server infos")
    WebClient c := makeReq(server.plusName("server"), "GET")
    c.reqHeaders["Authorization"] = "Basic " + "$adminName:$adminPassword".toBuf.toBase64
    c.writeReq.readRes
    if(c.resCode != 200)
    {
      err := Err("Server infos failed: "+c.resBuf.readAllStr)
      log.err("error", err)
      throw err
    }
    return JsonInStream(c.resIn).readJson
  }

  Str createClass(Type type)
  {
    req := makeReq(server.plusName("class", true).plusName(database,true).plusName(type.name), "POST")
    req.postStr("")
    return req.resIn.readAllBuf.readAllStr    
  }
    
  Str writeDocument(Str jsonDoc)
  {
    req := makeReq(server.plusName("document", true).plusName(database), "POST")
    req.postStr(jsonDoc)
    return req.resIn.readAllBuf.readAllStr
  }
    
  private WebClient makeReq(Uri path, Str method)
  {
    uri := server + path
    c := WebClient(uri)
    c.reqMethod = method
    c.reqHeaders["Content-Type"]  = "application/json; charset=utf-8"
    c.reqHeaders["Remote-User"] = username
    c.reqHeaders["Authorization"] = authHeader
    c.reqHeaders["Cache-Control"] = "no-cache"
    return c
  }    

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
    
    // TODO: check if it exists first ?
    createClass(type)
    return this;
  }
  
  ** Write an OrientDocument object
  ** This might make several requests if the object is composed (of sub OrientDocument objects)
  This writeDocumentObj(Obj obj)
  {
    //"""{"@class":"donkey","name":"client9"}"""
    json := jsonizeObj(obj)
    
    echo(json)
    echo(writeDocument(json))
    return this    
  }
  
  Str jsonizeObj(Obj obj)
  {
    objName := obj.typeof.name
    if(! cachedEntities.containsKey(objName))
      throw Err("No Entity found with name '$objName', maybe you forgot to call registerEntity ?")   
                         
    buf := StrBuf().add("{\"@class\":\"$objName\", ")
              
    fields := cachedEntities[objName]
    fields.fieldNames.each |Str name| 
    {
        field := obj.trap(name)
        if (field.typeof.hasFacet(OrientDocument#))
        {
          buf.add("\"$name\":").add("\"#7.1\", ")//.add(jsonizeObj(field))  
        } 
        else
        {
          //buf.
          buf.add("\"$name\":").add(JsonOutStream.writeJsonToStr(field)).add(", ")  
        }       
    }  
    buf.add("}")
    
    return buf.toStr    
  }
}
