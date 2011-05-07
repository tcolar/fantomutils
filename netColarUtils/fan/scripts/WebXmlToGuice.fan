// History:
//   May 6, 2011 thibaut colar Creation
//
using xml

**
** WebXmlToGuice
** 
class WebXmlToGuice
{
  Void usage()
  {
    echo(
"""Takes a standard J2EE web.xml file and generates(Outputs) Guice Servlet 
   modules calls that can be added to a ServletModule.configureServlets() method
   
   Usage:
   Install Fantom: http://wiki.colar.net/fantom_-_quick_install
   No need to compile as it's just a standalone script.
   Execute : fan WebXmlToGuice.fan /somewhere/web.xml"""      
    )
  }
  
  Int main(Str[] args)
  {
    if(args.isEmpty || ["-h", "--help"].contains(args[0])) 
    {
      usage
      return -1
    }
    
    guiceIt(args[0].toUri)
    
    return 0
  }
  
  Void guiceIt(Uri path)
  {
    // mapping of servlet name & url path(s)
    servletMappings := Str:Str[] [:]
    // mapping of filter name & url path(s)
    filterMappings := Str:Str[] [:]
    
    data := File(path).readAllBuf.in 
    root := XParser(data).parseDoc.root
    
    // first pass to look for mappings
    root.elems.each |xelem| 
    {
      switch(xelem.name)
      {
        case "servlet-mapping":
          addMapping(servletMappings, xelem, "servlet-name")  
        case "filter-mapping":
          addMapping(filterMappings, xelem, "filter-name")  
      }
    }
    
    // second pass ... find servlets and filters and output guice type calls
    root.elems.each |xelem| 
    {
      switch(xelem.name)
      {
        case "servlet":
          process(xelem, servletMappings, false)
        case "filter":
          process(xelem, filterMappings, true)  
      }
    }    
  }
  
  ** Read a mapping xml elements and add it's name-to-paths mapping to the map 
  Void addMapping(Str:Str[] map, XElem xelem, Str nameAttr)
  {
    paths := Str[,]
    nm := xelem.elem(nameAttr).text.val.trim
    xelem.elems.each |mapping| 
    {
      if(mapping.name.equals("url-pattern"))
        paths.add(mapping.text.val.trim)
    }
    map.set(nm, paths)
  }
  
  Void process(XElem xelem, Str:Str[] mappings, Bool isFilter)
  {
    Str:Str params := [:]
    xelem.elems.each |part| 
    {
        if(part.name.equals("init-param"))
        {
            params.set(part.elem("param-name").text.val.trim, part.elem("param-value").text.val.trim)
        }            
    }
    buf := StrBuf()
    nm := xelem.elem(isFilter ? "filter-name" : "servlet-name").text.val.trim
    paramsNm := nm + "Params"
    if( ! params.isEmpty)
    {
      buf.add("\nMap<String, String> $paramsNm = new HashMap<String, String>();\n");
      params.each |val, key| 
      {
        buf.add("${paramsNm}.put(\"$key\", \"$val\");\n")
      }
    }
    buf.add(isFilter ? "filter(" : "serve(")
    mappings[nm]?.each |path| 
    {
      if(buf[-1] != '(') 
        buf.add(", ")
      buf.add("\"$path\"")
    }
    clazz := xelem.elem(isFilter ? "filter-class" : "servlet-class").text.val.trim
    buf.add(isFilter ? ").through(" : ").with(")
    buf.add(clazz.split('.').last).add(".class")
    if( ! params.isEmpty)
        buf.add(", $paramsNm")
    buf.add(");")
    echo(buf.toStr)
  }
}   