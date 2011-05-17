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
    return MailNode(MailNodes.HEADERS, headers)
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
      
      nameNode := MailNode.makeLeaf(MailNodes.HEADERNAME, name)
      
      colNode := MailNode.makeLeaf(MailNodes.COLON, ":")
      
      if(name.equalsIgnoreCase("From"))
      {
        // from  =   "From:" mailbox-list CRLF
        nds := [nameNode, colNode, readMailboxList(val.in)]
        return MailNode(MailNodes.HEADER, nds)
      }
      else
      {
        // other header
        nds := [nameNode, colNode, parser.readUnstructured(val.in)]
        return MailNode(MailNodes.HEADER, nds)        
      }

    }
    //else
    echo("Invalid header : $line")
    return parser.emptyNode
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

  address-list    =   (address *("," address)) / obs-addr-list

  group-list      =   mailbox-list / CFWS / obs-group-list
  
  resent-date     =   "Resent-Date:" date-time CRLF

  resent-from     =   "Resent-From:" mailbox-list CRLF

  resent-sender   =   "Resent-Sender:" mailbox CRLF

  resent-to       =   "Resent-To:" address-list CRLF

  resent-cc       =   "Resent-Cc:" address-list CRLF

  resent-bcc      =   "Resent-Bcc:" [address-list / CFWS] CRLF

  resent-msg-id   =   "Resent-Message-ID:" msg-id CRLF
  
  Fields may appear in messages that are otherwise unspecified in this
  document.  They MUST conform to the syntax of an optional-field.
  This is a field name, made up of the printable US-ASCII characters
  except SP and colon, followed by a colon, followed by any text that
  conforms to the unstructured syntax. 
  */

  
  ** orig-date       =   "Date:" date-time CRLF
  ** from            =   "From:" mailbox-list CRLF
  ** sender          =   "Sender:" mailbox CRLF
  ** reply-to        =   "Reply-To:" address-list CRLF
  ** to              =   "To:" address-list CRLF
  ** cc              =   "Cc:" address-list CRLF
  ** bcc             =   "Bcc:" [address-list / CFWS] CRLF
  ** subject         =   "Subject:" unstructured CRLF
  ** comments        =   "Comments:" unstructured CRLF
  ** keywords        =   "Keywords:" phrase *("," phrase) CRLF
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
    return MailNode(MailNodes.MAILBOXLIST, boxes)
  }

  ** mailbox = name-addr / addr-spec
  MailNode readMailbox(InStream in)
  {
    found := readNameAddr(in)
    if( ! found.isEmpty )
      return MailNode(MailNodes.MAILBOX, [found])
    found = readAddrSpec(in)
    if( ! found.isEmpty )
      return MailNode(MailNodes.MAILBOX, [found])
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
    return MailNode(MailNodes.NAMEADDR, [dn, aa])
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
    
    return MailNode(MailNodes.ANGLEADDR , nodes)
  }
  
  ** display-name    =   phrase
  MailNode readDisplayName(InStream in)
  {
    return MailNode(MailNodes.DISPLAYNAME, [parser.readPhrase(in)])
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
    
    return MailNode(MailNodes.ADDRSPEC, nodes)
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

}