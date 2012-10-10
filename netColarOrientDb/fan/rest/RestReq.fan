// History:
//   Sep 7, 2011 thibaut Creation
//

using web

**
** RestReq
**
class RestReq
{
  WebClient c
  
  new make(Str:Str headers, Str[] uriParts)
  {
    uri := uriParts[0].toUri
    uriParts.each |Str part, Int cpt|
    {
      if(cpt>0)
        uri = uri.plusName(part, cpt != uriParts.size - 1)
    }
    
    c = WebClient(uri)
    
    headers.each |val, key| 
    {
        c.reqHeaders[key]  = val     
    }
  }
  
  Str get()
  {
    c.reqMethod = "GET"
    
    OrientClient.log.debug("GET $c.reqUri")
    
    c.writeReq
    
    if(c.resCode >= 300)
      throw RestErr(c)

    res := c.readRes.resIn.readAllStr
    
    OrientClient.log.debug("GET Result: $res")

    return res
  }

  Str post(Str json)
  {
    c.reqMethod = "POST"
    
    OrientClient.log.debug("POST $c.reqUri")
    
    c.postStr(json)
    
    if(c.resCode >= 300)
      throw RestErr(c)
      
    res := c.resIn.readAllStr
    
    OrientClient.log.debug("POST result: $res")
    
    return res
  }
}


** Rest call error
const class RestErr : Err
{
  const Int code
  const Str answer
  
  new make(WebClient c) : super("RestErr during $c.reqMethod to $c.reqUri")
  {
    this.code = c.resCode
    try
    {
      this.answer = c.resIn.readAllBuf.readAllStr
    }
    finally
    {
      this.answer = ""
    }  
  }
  
  override Str toStr()
  {
    return "$msg (Code: $code). $answer"
  }
}


