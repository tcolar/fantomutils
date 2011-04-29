using [java] java.util::Hashtable
using [java] java.util::Enumeration
using [java] fanx.interop

**
** Java interop utilities
** 
class JavaUtils
{
  ** Fantom Map to Java Hashtable
  static Hashtable mapToHashtable(Map map)
	{
		return Hashtable(Interop.toJava(map))
  }
}

** Make a Java Enumeration more Fantom friendly (closures)
class EnumWrapper
{
  Enumeration e
  new make(Enumeration e)
  {
    this.e = e
  }
  
  Obj? next()
  {
    if( ! hasNext)
      return null
    return e.nextElement
  }
  
  Bool hasNext()
  {
    return e.hasMoreElements
  }
  
  Void each(|Obj->Void| f)
  {
    while(hasNext)
		{
      f.call(next)
    }
  }
}

