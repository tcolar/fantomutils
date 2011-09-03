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

  Str ceateClass(Type type)
  {
    req := makeReq(server.plusName("class", true).plusName(database,true).plusName("donkey"), "POST")
    json := 
    """{"name":"client9"}"""
    req.postStr(json)
    return req.resIn.readAllBuf.readAllStr    
  }
    
  Str writeDocument(Obj obj)
  {
    //log.info("Disconnecting from db: $database")
    name := obj.typeof.name
    json := JsonOutStream.writeJsonToStr(obj)
    json = 
    """{"@class":"donkey","name":"client9"}"""
    req := makeReq(server.plusName("document", true).plusName(database), "POST")
    req.postStr(json)
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
      if(it.hasFacet(DocumentFields#))
      {
        registerEntityType(it)
      }
    }
    return this
  }  
  
  ** Register a single entity type
  ** Type must be annotated with OrientDocument facet
  ** Results are cahed to avoid doing reflection every time
  This registerEntityType(Type type)
  {
    if( ! type.hasFacet(DocumentFields#))
    {
      throw Err("Type $type does not have DocumentFields Facet.")
    }
    name := type.name
    if(cachedEntities.hasKey(name))
    {
      throw Err("Duplicated Entity name: $name !")      
    }
    // TODO : id duplicate Type simpleName, balk !
    return this;
  }  
}
