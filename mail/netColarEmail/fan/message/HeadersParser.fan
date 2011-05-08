// History:
//   May 7, 2011 thibaut Creation
//

**
** HeadersParser
** Decode the Mail headers (RFC 5322)
**
class HeadersParser
{
  MsgParser parser
  InStream in
  
  new make(MsgParser parser)
  {
    in = parser.in
    // The parser has the low-level read methods of the base grammar
    this.parser = parser
  }
  
  ** Read all the headers (Until a blank line)
  ** Does consume the empty line at the end of the headers  -> Ready to start reading the body
  MailHeader[] readHeaders()
  {
    MailHeader[] headers := [,]
    MailHeader? header
    while( (header = readHeader) != null)
    {
        headers.add(header)
    }
    return headers
  }
  
  ** Read a single header
  ** Return null, if all headers read (empty line)
  ** Does consume the empty line -> Ready to start reading the body
  MailHeader? readHeader()
  {
    line := parser.readUnfoldedLine
    if(line.isEmpty)
      return null
      
    col := line.index(":")
    if(col != null)
    {
      name := line[0 ..< col].trim
      val := line.size >= col ? line[col+1 .. -1].trim : ""
      echo("$name -> $val")
      return makeHeader(name.trim, val)
    }
    //else
    echo("Invalid header : $line")
    return null
  }
 
  MailHeader makeHeader(Str name, Str val) 
  { 
    if(name.equalsIgnoreCase("From"))
    {
      return readFrom(val)
    }
    // Temp
    return HeaderFrom()
  }
  
  ** from            =   "From:" mailbox-list CRLF
  HeaderFrom readFrom(Str val)
  {
    
    return HeaderFrom()
  }
/*
  trace           =   [return]
                       1*received

   return          =   "Return-Path:" path CRLF

   path            =   angle-addr / ([CFWS] "<" [CFWS] ">" [CFWS])

   received        =   "Received:" *received-token ";" date-time CRLF

   received-token  =   word / angle-addr / addr-spec / domain
  */

}