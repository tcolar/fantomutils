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
  
  new make(MsgParser parser)
  {
    // The parser has the low-level read methods of the base grammar
    this.parser = parser
  }
  
  ** Read all the headers (Until a blank line)
  ** Does consume the empty line at the end of the headers  -> Ready to start reading the body
  MailHeader[] readHeaders(InStream in)
  {
    MailHeader[] headers := [,]
    MailHeader? header
    while( (header = readHeader(in)) != null)
    {
      headers.add(header)
    }
    return headers
  }
  
  ** Read a single header
  ** Return null, if all headers read (empty line)
  ** Does consume the empty line -> Ready to start reading the body
  MailHeader? readHeader(InStream in)
  {
    line := parser.readUnfoldedLine(in)
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
      return readFrom(val.in)
    }
    // Temp
    return HeaderFrom()
  }
  
  ** from  =   "From:" mailbox-list CRLF
  HeaderFrom readFrom(InStream in)
  {    
    return HeaderFrom()
  }
  
  ** (mailbox *("," mailbox)) / obs-mbox-list
  MailBox[] readMailboxList(InStream in)
  {
    // TODO: obs-mbox-list
    mb := readMailbox(in)
    if(mb == null)
    {
      return [,]
    }
    // else
    boxes := [mb]
    while(true)
    {
      if(in.peekChar != ',')
        break
      // else
      in.readChar
      mb = readMailbox(in)
      if(mb == null)
      {
        parser.unread(in, ",")
        break;
      }
      // else
      boxes.add(mb)      
    }
    return boxes
  }

  ** mailbox = name-addr / addr-spec
  MailBox? readMailbox(InStream in)
  {
    found := readNameAddr(in)
    if( ! found.isEmpty )
      return MailBox(found)
    found = readAddrSpec(in)
    if( ! found.isEmpty )
      return MailBox(found)
    return null
  }
  
  /*
  trace           =   [return]
  1*received

  return          =   "Return-Path:" path CRLF

  path            =   angle-addr / ([CFWS] "<" [CFWS] ">" [CFWS])

  received        =   "Received:" *received-token ";" date-time CRLF

  received-token  =   word / angle-addr / addr-spec / domain
  
  address         =   mailbox / group

  group           =   display-name ":" [group-list] ";" [CFWS]

  mailbox-list    =   (mailbox *("," mailbox)) / obs-mbox-list

  address-list    =   (address *("," address)) / obs-addr-list

  group-list      =   mailbox-list / CFWS / obs-group-list
  */

  ** name-addr       =   [display-name] angle-addr
  Str readNameAddr(InStream in)
  {
    dn := readDisplayName(in)
    aa := readAngleAddr(in)
    if(aa.isEmpty)
    {
      parser.unread(in, dn)
      return ""
    }
    return dn + aa
  }
    
  ** [CFWS] "<" addr-spec ">" [CFWS] / obs-angle-addr
  Str readAngleAddr(InStream in)
  {
    // TODO: obs-angle-addr
    
    buf := StrBuf().add(parser.readCfws(in))
    if(in.peekChar != '<' )
    {
      parser.unread(in, buf.toStr)
      return ""
    }
    //else
    in.readChar
    buf.add("<")
    
    found := readAddrSpec(in)
    if(found.isEmpty)
    {
      parser.unread(in, buf.toStr)
      return ""      
    }
    // else    
    buf.add(found)
    if(in.peekChar != '>' )
    {
      parser.unread(in, buf.toStr)
      return ""
    }
    //else
    in.readChar
    buf.add(">")
    buf.add(parser.readCfws(in))
    
    return buf.toStr
  }
  
  ** display-name    =   phrase
  Str readDisplayName(InStream in)
  {
    return parser.readPhrase(in)
  }
    
  ** addr-spec       =   local-part "@" domain
  Str readAddrSpec(InStream in)
  {
    found := readLocalPart(in)
    if( found.isEmpty)
      return ""
    // else
    buf := StrBuf().add(found)
    if(in.peekChar != '@')
    {
      parser.unread(in, buf.toStr)
      return ""
    }
    // else
    in.readChar
    buf.add("@")
    found = readDomain(in)
    if(found.isEmpty)
    {
      parser.unread(in, buf.toStr)
      return ""
    }
    // else
    buf.add(found)
    
    return buf.toStr
  }
      
  ** local-part      =   dot-atom / quoted-string / obs-local-part
  Str readLocalPart(InStream in)
  {
    // TODO: deal with obs-local-part
    found := parser.readDotAtom(in)
    if( ! found.isEmpty)
      return found
    return parser.readQuotedString(in)    
  }
  
  ** domain          =   dot-atom / domain-literal / obs-domain
  Str readDomain(InStream in)
  {
    // TODO: deal with obs-domain
    found := parser.readDotAtom(in)
    if( ! found.isEmpty)
      return found
    return readDomainLiteral(in)
  }
  
  ** domain-literal  =   [CFWS] "[" *([FWS] dtext) [FWS] "]" [CFWS]
  Str readDomainLiteral(InStream in)
  {
    buf := StrBuf().add(parser.readCfws(in))
    if(in.peekChar != '[' )
    {
      parser.unread(in, buf.toStr)
      return ""
    }
    //else
    in.readChar
    buf.add("[")
    while(true)
    {
      buf.add(parser.readFoldingWs(in))
      cc := readDtext(in)
      if(cc.isEmpty)
        break
      buf.add(cc)
    } 
    if(in.peekChar != ']' )
    {
      parser.unread(in, buf.toStr)
      return ""
    }
    //else
    in.readChar
    buf.add("]")
    buf.add(parser.readCfws(in))
    
    return buf.toStr
  }
  
  ** Read dText -> See isDtext()  
  Str readDtext(InStream in)
  {
    return in.readStrToken(null) |char|
    {
      return ! isDtext(char)
    } ?: ""
  }

  
  **  dtext %d33-90 / %d94-126                                
  Bool isDtext(Int c)
  {
    return  (c >= '\u0021' && c <='\u005A') ||
      (c >= '\u005E' && c <='\u007E' )
  }    
  
}