//
// History:
//   Oct 10, 2012 tcolar Creation
//
using util

// TODO: Support consts by using with() costructors

**
** JsonUtils
** Utilities to save/load objects in JSON format
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
  ** Target type needs to have a no parameters constructor
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
    //throw Err("Don't know how to Deserialize $obj as $type")
  }
  
  internal static Obj? deserializeMap(Obj obj, Type type)
  {
    if(! obj.typeof.fits(Map#))
    {
      throw Err("Cannot deserialize $obj into non-map $type")
    }  
    
    map := (Map) obj
    
    if(type.fits(Map#))
    {  
      // actually a map
      instance := Map.make(type)
      
      map.each |v, k|
      {        
        instance[deserialize(k, type.params["K"])] = deserialize(v, type.params["V"])            
      }
      return instance
    }  
    else
    {  
      // otherwise must have been a serializable
      instance := type.make    
    
      map.each |v, k|
      {
        field := type.field(k, false)
        if(field != null)
        {
          item := deserialize(v, field.type)
          field.set(instance, item)
        }      
      }
      return instance
    } 
    return null  
  }

  internal static Obj? deserializeList(Obj obj, Type type)
  {
    list := (List) obj
    
    if(! type.fits(List#))
    {
      throw Err("Cannot deserialize $obj into non-list $type")
    }  
    
    of := type.params["V"]
    instance := List.make(of, 10)   
    
    list.each
    {
      instance.add(deserialize(it, of))            
    }
    
    return instance
  }
}