// History:
//   May 7, 2011 thibaut Creation
//

**
** HeadersParser
** Parse the Mail headers (RFC 5322)
** Used by MsgParser
**
class HeadersParser
{
  MsgParser parser
  
  new make(MsgParser parser)
  {
    // The parser has some low-level read methods of the base grammar
    this.parser = parser
  }
  
  ** Read all the headers (Until a blank line)
  ** Does consume the empty line at the end of the headers  -> Ready to start reading the body
  MailNode readHeaders(InStream in)
  {
    MailNode[] headers := [,]
    while(true)
    {
      header := readHeader(in)
      if(header.isEmpty)
        break
      //else
      headers.add(header)
    }
    return MailNode(MailNodes.T_HEADERS, headers)
  }
  
  ** Read a single header
  ** Return an empty node if all headers already read (empty line)
  ** Note: Does consume the empty line -> Ready to start reading the body
  MailNode readHeader(InStream in)
  {
    line := parser.readUnfoldedLine(in)
    if(line.isEmpty)
      return parser.emptyNode
      
    col := line.index(":")
    if(col != null)
    {
      name := line[0 ..< col].trim
      val := line.size >= col ? line[col+1 .. -1] : ""
      
      nameNode := MailNode.makeLeaf(MailNodes.T_HEADERNAME, name)
      
      colNode := MailNode.makeLeaf(MailNodes.COLON, ":")
      
      MailNode? valNode 
      try
      {
        switch(name.lower)
        {
          //TODO: parse trace
          
          case "date":
          case "resent-date":
            valNode = readDateTime(val.in)
          case "from":
          case "resent-from":
            valNode = readMailboxList(val.in)
          case "sender":
          case "resent-sender":
            valNode = readMailbox(val.in)
          case "reply-to":
          case "to":
          case "cc":  
          case"resent-to":
          case"resent-cc":      
            valNode = readAddressList(val.in)
          case "bcc":
          case "resent-bcc":
            valNode = readBcc(val.in)
          case "message-id":
        case "resent-message-id":
            valNode = readMsgId(val.in)
          case "in-reply-to":
          case "references":
            valNode = readMsgIds(val.in)
          case "subject":
          case "comments":
            valNode = parser.readUnstructured(val.in)
          case "keywords":
            valNode = readKeywords(val.in)
          default:
            // other "optional" header
            valNode = parser.readUnstructured(val.in)
        }
      }catch(Err e) 
      {
        echo("Invalid header : $line")
        e.trace
        return parser.emptyNode
      }
      
      nds := [nameNode, colNode, valNode]
      return MailNode(MailNodes.T_HEADER, nds)
    }
    //else
    echo("Invalid header : $line")
    return parser.emptyNode
  }
 
  MailNode readDateTime(InStream in)
  {
    // TODO: OBS-YEAR
    
    // Drop CFWS
    buf := StrBuf()
    while(true)
    {
      
      parser.readCfws(in)
      c := in.readChar
      if(c == null) 
        break 
      else     
        buf.add(c.toChar)  
    }  
    date := buf.toStr.split('\n').join("")
    echo(date)
    // parse according to RFC 5322
    // Full
    dt := DateTime.fromLocale(date, "WWW,DMMMYYYYhh:mm:ssz", TimeZone.cur, false)
    if(dt == null)
      // No seconds
    dt = DateTime.fromLocale(date, "WWW,DMMMYYYYhh:mmz", TimeZone.cur, false)
    if(dt == null)
      // No day of week
    DateTime.fromLocale(date, "DMMMYYYYhh:mm:ssz", TimeZone.cur, false)
    if(dt == null)    
      // Neither
    DateTime.fromLocale(date, "DMMMYYYYhh:mmz", TimeZone.cur, false)
    echo("dt: $dt")
    if(dt == null)
      return parser.emptyNode
    else
      return DateTimeMailNode(buf.toStr, dt)   
  }

  **  address-list    =   (address *("," address)) / obs-addr-list
  MailNode readAddressList(InStream in)
  {
    // TODO: obs-mbox-list
    address := readAddress(in)
    if(address.isEmpty)
    {
      return parser.emptyNode
    }
    // else
    addresses := [address]
    while(true)
    {
      if(in.peekChar != ',')
        break
      // else
      in.readChar
      address = readAddress(in)
      if(address.isEmpty)
      {
        parser.unread(in, ",")
        break;
      }
      // else
      addresses.add(address)      
    }
    return MailNode(MailNodes.T_ADDRESSLIST, addresses)
    
  }
    
  **   address         =   mailbox / group
  MailNode readAddress(InStream in)
  {
    node := readMailbox(in)
    if(!node.isEmpty)
      return MailNode(MailNodes.T_ADDRESS, [node])
    node = readGroup(in)
    if(!node.isEmpty)
      return MailNode(MailNodes.T_ADDRESS, [node])
    return parser.emptyNode
  }
  
  ** group           =   display-name ":" [group-list] ";" [CFWS]
  MailNode readGroup(InStream in)
  {
    nodes := [,]
    node := readDisplayName(in)
    nodes.add(node)
    if(node.isEmpty)
      return parser.emptyNode
    if(in.peekChar != ':')
    {
      parser.unreadNodes(in, nodes)
      return parser.emptyNode
    }
    in.readChar
    nodes.add(MailNode.makeLeaf(MailNodes.COLON, ":"))
    groups := readGroupList(in)
    if(in.peekChar != ';')
    {
      parser.unreadNodes(in, nodes)
      return parser.emptyNode
    }
    return MailNode(MailNodes.T_GROUP, nodes)    
  }
  
  **   group-list      =   mailbox-list / CFWS / obs-group-list
  MailNode readGroupList(InStream in)
  {
    // TODO: obs-group-list
    return readMailboxList(in)
  }

  ** 
  ** // TODO: Message ID - section 3.6.4
  ** (mailbox *("," mailbox)) / obs-mbox-list
  MailNode readMailboxList(InStream in)
  {
    // TODO: obs-mbox-list
    mb := readMailbox(in)
    if(mb.isEmpty)
    {
      return parser.emptyNode
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
      if(mb.isEmpty)
      {
        parser.unread(in, ",")
        break;
      }
      // else
      boxes.add(mb)      
    }
    return MailNode(MailNodes.T_MAILBOXLIST, boxes)
  }

  ** mailbox = name-addr / addr-spec
  MailNode readMailbox(InStream in)
  {
    found := readNameAddr(in)
    if( ! found.isEmpty )
      return MailNode(MailNodes.T_MAILBOX, [found])
    found = readAddrSpec(in)
    if( ! found.isEmpty )
      return MailNode(MailNodes.T_MAILBOX, [found])
    return parser.emptyNode
  }
  
  **bcc             =   "Bcc:" [address-list / CFWS] CRLF
  MailNode readBcc(InStream in)
  {
    found := readAddressList(in)
    if( ! found.isEmpty )
      return MailNode(MailNodes.T_BCC, [found])
    found = parser.readCfws(in)
    if( ! found.isEmpty )
      return MailNode(MailNodes.T_BCC, [found])
    return parser.emptyNode
  }
   
  
  ** name-addr       =   [display-name] angle-addr
  MailNode readNameAddr(InStream in)
  {
    dn := readDisplayName(in)
    aa := readAngleAddr(in)
    if(aa.isEmpty)
    {
      parser.unread(in, dn.text)
      return parser.emptyNode
    }
    return MailNode(MailNodes.T_NAMEADDR, [dn, aa])
  }
    
  ** [CFWS] "<" addr-spec ">" [CFWS] / obs-angle-addr
  MailNode readAngleAddr(InStream in)
  {
    // TODO: obs-angle-addr    
    nodes := [parser.readCfws(in)]
    if(in.peekChar != '<' )
    {
      parser.unreadNodes(in, nodes)
      return parser.emptyNode
    }
    //else
    in.readChar
    nodes.add(MailNode.makeLeaf(MailNodes.ANGLE, "<"))
    
    found := readAddrSpec(in)
    if(found.isEmpty)
    {
      parser.unreadNodes(in, nodes)
      return parser.emptyNode      
    }
    // else    
    nodes.add(found)
    if(in.peekChar != '>' )
    {
      parser.unreadNodes(in, nodes)
      return parser.emptyNode
    }
    //else
    in.readChar
    nodes.add(MailNode.makeLeaf(MailNodes.ANGLE, ">"))
    nodes.add(parser.readCfws(in))
    
    return MailNode(MailNodes.T_ANGLEADDR , nodes)
  }
  
  ** display-name    =   phrase
  MailNode readDisplayName(InStream in)
  {
    return MailNode(MailNodes.T_DISPLAYNAME, [parser.readPhrase(in)])
  }
    
  ** addr-spec       =   local-part "@" domain
  MailNode readAddrSpec(InStream in)
  {
    found := readLocalPart(in)
    if( found.isEmpty)
      return parser.emptyNode
    // else
    nodes := [found]
    if(in.peekChar != '@')
    {
      parser.unreadNodes(in, nodes)
      return parser.emptyNode
    }
    // else
    in.readChar
    nodes.add(MailNode.makeLeaf(MailNodes.AT, "@"))
    found = readDomain(in)
    if(found.isEmpty)
    {
      parser.unreadNodes(in, nodes)
      return parser.emptyNode
    }
    // else
    nodes.add(found)
    
    return MailNode(MailNodes.T_ADDRSPEC, nodes)
  }
      
  ** local-part      =   dot-atom / quoted-string / obs-local-part
  MailNode readLocalPart(InStream in)
  {
    // TODO: deal with obs-local-part
    found := parser.readDotAtom(in)
    if( ! found.isEmpty)
      return MailNode(MailNodes.LOCALPART, [found])
    return MailNode(MailNodes.LOCALPART, [parser.readQuotedString(in)])    
  }
  
  ** domain          =   dot-atom / domain-literal / obs-domain
  MailNode readDomain(InStream in)
  {
    // TODO: deal with obs-domain
    found := parser.readDotAtom(in)
    if( ! found.isEmpty)
      return MailNode(MailNodes.DOMAIN, [found])
    return MailNode(MailNodes.DOMAIN, [readDomainLiteral(in)])
  }
  
  ** domain-literal  =   [CFWS] "[" *([FWS] dtext) [FWS] "]" [CFWS]
  MailNode readDomainLiteral(InStream in)
  {
    nodes := [parser.readCfws(in)]
    if(in.peekChar != '[' )
    {
      parser.unreadNodes(in, nodes)
      return parser.emptyNode
    }
    //else
    in.readChar
    nodes.add(MailNode.makeLeaf(MailNodes.BRACKET, "["))
    while(true)
    {
      nodes.add(parser.readFoldingWs(in))
      cc := readDtext(in)
      if(cc.isEmpty)
        break
      nodes.add(cc)
    } 
    if(in.peekChar != ']' )
    {
      parser.unreadNodes(in, nodes)
      return parser.emptyNode
    }
    //else
    in.readChar
    nodes.add(MailNode.makeLeaf(MailNodes.BRACKET, "]"))
    nodes.add(parser.readCfws(in))
    
    return MailNode(MailNodes.DOMAINLITERAL, nodes)
  }
  
  ** Read dText -> See isDtext()  
  MailNode readDtext(InStream in)
  {
    return MailNode.makeLeaf(MailNodes.DTEXT, in.readStrToken(null) |char|
      {
        return ! isDtext(char)
      } ?: "")
  }

  
  **  dtext %d33-90 / %d94-126                                
  Bool isDtext(Int c)
  {
    return  (c >= '\u0021' && c <='\u005A') ||
      (c >= '\u005E' && c <='\u007E' )
  }    

  ** One or more message id's
  MailNode readMsgIds(InStream in)
  {
    MailNode[] nodes := [,]
    while(true)
    {
      nd := readMsgId(in)
      if(nd.isEmpty)
        break
      nodes.add(nd)
    }
    return MailNode(MailNodes.T_MSGIDS, nodes)
  }
    
  **    msg-id          =   [CFWS] "<" id-left "@" id-right ">" [CFWS]
  MailNode readMsgId(InStream in)
  {
    nodes := [parser.readCfws(in)]
    if(in.peekChar != '<')
    {
      parser.unreadNodes(in, nodes)
      return parser.emptyNode
    }
    nodes.add(MailNode.makeLeaf(MailNodes.ANGLE, "<"))
    
    nd := readIdLeft(in)
    if(nd.isEmpty)
    {
      parser.unreadNodes(in, nodes)
      return parser.emptyNode      
    }
    nodes.add(nd)
    
    if(in.peekChar != '@')
    {
      parser.unreadNodes(in, nodes)
      return parser.emptyNode
    }
    nodes.add(MailNode.makeLeaf(MailNodes.AT, "@"))
    
    nd = readIdRight(in)
    if(nd.isEmpty)
    {
      parser.unreadNodes(in, nodes)
      return parser.emptyNode      
    }
    nodes.add(nd)

    if(in.peekChar != '>')
    {
      parser.unreadNodes(in, nodes)
      return parser.emptyNode
    }
    nodes.add(MailNode.makeLeaf(MailNodes.ANGLE, ">"))
    
    nodes.add(parser.readCfws(in))
    return MailNode(MailNodes.T_MSGID, nodes)
  }
  
  ** id-left         =   dot-atom-text / obs-id-left
  MailNode readIdLeft(InStream in)
  {
    return parser.readDotAtomText(in)
  }

  ** id-right        =   dot-atom-text / no-fold-literal / obs-id-right  
  MailNode readIdRight(InStream in)
  {
    nd := parser.readDotAtomText(in)
    if( ! nd.isEmpty)
    {
      return MailNode(MailNodes.IDRIGHT, [nd])
    }
    nd = readNoFoldLiteral(in)
    if( ! nd.isEmpty)
    {
      return MailNode(MailNodes.IDRIGHT, [nd])
    }
    return parser.emptyNode
  }

  ** "[" *dtext "]"
  MailNode readNoFoldLiteral(InStream in)
  {
    if(in.peekChar != '[')
      return parser.emptyNode
    nodes := [MailNode.makeLeaf(MailNodes.BRACKET, "[")]
    while(true)
    {
      nd := readDtext(in)
      if(nd.isEmpty)
        break
      nodes.add(nd)
    }
    if(in.peekChar != ']')
    {
      parser.unreadNodes(in, nodes)
      return parser.emptyNode
    }
    nodes.add(MailNode.makeLeaf(MailNodes.BRACKET, "]"))
    return MailNode(MailNodes.NOFOLDLITERAL, nodes)
  }
  
  ** keywords        =   "Keywords:" phrase *("," phrase) CRLF
  MailNode readKeywords(InStream in)
  {
    nd := parser.readPhrase(in)
    if(nd.isEmpty)
    {
      return parser.emptyNode 
    }
    nodes := [nd]
    while(true)
    {
      if(in.peekChar == ',')
      {
        in.readChar
        nodes.add(MailNode.makeLeaf(MailNodes.COMMA, ","))
        
        phrase := parser.readPhrase(in)
        if(phrase.isEmpty)
        {
          parser.unreadNodes(in, nodes)
          break
        }
        nodes.add(phrase)
      }
      else
      {
        break
      }
    }
    return MailNode(MailNodes.T_KEYWORDS, nodes)
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