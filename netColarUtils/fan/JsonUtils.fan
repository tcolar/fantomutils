//
// History:
//   Oct 10, 2012 tcolar Creation
//
using util

**
** JsonUtils
** Utilities to save/load objects in JSON format
** 
** Note: Non simple Serializable objects MUST provide an it constructor
**   ie: new make(|This| f) {f(this)} 
**
class JsonUtils
{
  ** Save the object to the outstream
  ** Stream is guaranteed to be closed.
  static Void save(OutStream out, Obj? obj)
  {
    try
    {  
      JsonOutStream(out).writeJson(obj)
    }
    catch(Err e)
    {
      throw(e)
    }    
    finally
    {
      out.close
    }  
  }
  
  ** Load the object to the instream
  ** Stream is guaranteed to be closed.
  static Obj? load(InStream in, Type type)
  {
    try
    {  
      obj := JsonInStream(in).readJson
      return deserialize(obj, type)
    }
    catch(Err e)
    {
      throw e
    }
    finally
    {
      in.close
    }    
  }
  
  internal static Obj? deserialize(Obj? obj, Type type)
  {
    if(obj == null) 
      return null
      
    if(obj is List)
    {  
      return deserializeList(obj, type)
    } 
     
    if(obj is Map)
    {  
      return deserializeMap(obj, type)
    }
    
    ser  := type.facet(Serializable#, false) as Serializable
    if (ser != null)
    {  
      if(ser.simple)
      {
        return type.method("fromStr").call(obj.toStr)
      }
      else
      {
        return deserialize(obj, type)
      }  
    }
    return obj
  }
  
  internal static Obj deserializeMap(Obj obj, Type type)
  {
    map := (Map) obj
    
    if( ! type.fits(Map#))
    {  
      // A serializable that was serialized as a map object
      return deserializeMapObj(map, type)  
    }  
    else
    {
      // An actual Map
      instance := Map.make(type)
      
      map.each |v, k|
      {        
        instance[deserialize(k, type.params["K"])] = deserialize(v, type.params["V"])            
      }
      return instance
    } 
  }

  internal static Obj deserializeList(Obj obj, Type type)
  {
    list := (List) obj
    
    of := type.params["V"]
    instance := List.make(of, 10)   
    
    list.each
    {
      instance.add(deserialize(it, of))            
    }
    
    return instance
  }
  
  ** Deserialize a serializable object from it's Map Object representation
  internal static Obj deserializeMapObj(Map mapObj, Type type)
  {
    [Field:Obj?] fieldMap := [:]
    mapObj.each |v, k|
    {
      field := type.field(k, false)
      if(field != null)
      {
        fieldMap[field]= deserialize(v, field.type)
      }      
    }
    
    try        
    {
      return type.make([Field.makeSetFunc(fieldMap)])
    }    
    catch(Err e)
    {
      throw Err("$type is missing an it constructor !", e)
    }  
  }  
}