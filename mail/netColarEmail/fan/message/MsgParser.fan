// Artistic License 2.0. Thibaut Colar.
//
// History:
//   1-Mar-2011 thibautc Creation
//

using email

**
** MsgParser : Parse a Mail message (data) into a parse tree (to be used to build a MailMsg)
** See RFC 5322
**
class MsgParser
{
  internal const MailNode emptyNode := MailNode(MailNodes.EMPTY, [,])  
  
  ** Read a whole message (root node)  
  MailNode readMessage(InStream in)
  {
    headers := HeadersParser(this).readHeaders(in)
    body := readBody(in)
    return MailNode(MailNodes.T_MSGROOT, [headers, body])
  }
  
  ** Read the email body
  ** body            =   (*(*998text CRLF) *998text) / obs-body
  MailNode readBody(InStream in)
  {
    // TODO obs-body
    // TODO: MIME support
    body := StrBuf()
    
    while(true)
    {
      line := in.readStrToken(null) |char|
      {
        return ! isBodyChar(char)
      }
    
      if(line == null)
        break
      //else
      body.add(line)
      
      if(in.peekChar == '\r')
      {
        in.readChar
        if(in.peekChar == '\n')
        {
            in.readChar
            body.add("\r\n")  
        }
        else
        {
          unread(in, "\r")
          break
        }
      }
      else
      {
        break
      }
    }
    
    return MailNode.makeLeaf(MailNodes.T_BODY, body.toStr)  
  }
  
  // #####################  RFC 5322 Grammar stuff  ############################
  
  const Int[] aChars := ['!','#','$','%','&','\'', '*', '+', '-', '/',
    '=', '?', '^', '_', '`', '{', '}', '|']
  
  ** 0-9 a-z A-Z and aChars                                   
  Bool isAtext(Int c)
  {
    return  (c >= '0' && c <='9' ) ||
      (c >= 'a' && c <='z' ) ||
      (c >= 'A' && c <='Z' ) ||
      aChars.contains(c)      

  }    
  
  ** %d33 / %d35-91 /%d93-126
  Bool isQtext(Int c)
  {
    return  (c=='!' || 
        (c>='\u0023' && c<='\u005B')||
        (c>='\u005D' && c<='\u007E'))
  }
  
  ** white space: space or tab
  Bool isWsp(Int char)
  {
    return char == ' ' || char == '\t';
  }
  
  ** Printable characters
  Bool isVchar(Int char)
  {
    return (char >= '\u0021' && char <= '\u007E')
  }
  
  ** text            =   %d1-9 / %d11 / %d12 / %d14-127
  Bool isBodyChar(Int c)
  {
    return  c!='\u0000' && c!='\u000A' && c!='\u000D' && c<= '\u007E'
  }
  
  MailNode readWsp(InStream in)
  {
    return MailNode.makeLeaf(MailNodes.WSP, in.readStrToken(null) |char|
      {
        return ! isWsp(char)
      } ?: "")
  }

  ** space or tab or \r\n
  MailNode readFoldingWs(InStream in)
  {
    Bool afterCr // cariage Return
    result := in.readStrToken(null) |char|
    {
      if (char == '\n' && afterCr)
      {
        afterCr = false
        return false
      }
      if (isWsp(char)) 
      {
        afterCr = false        
        return false
      }
      if (char == '\r')
      {
        afterCr = true
        return false
      }
      return true 
    } 
    // if last was a \r without a \n then back one ... spec says that should never happen
    if(afterCr)
    {
      result = result[0..-2]
      in.unreadChar('\r')
    }
      
    return MailNode.makeLeaf(MailNodes.R_FWS, result ?: "")
  }
  
  ** %d33-39 / %d42-91 / %d93-126 /obs-ctext
  ** Not dealing with the obs-ctext for now (obsolete))
  MailNode readCtext(InStream in)
  {
    //TODO: obs-ctext
    return MailNode.makeLeaf(MailNodes.CTEXT, in.readStrToken(null) |char|
      {
        if ((char >= '\u0021' && char <= '\u0027') ||
              (char >= '\u002A' && char <= '\u005B')||
            (char >= '\u005D' && char <= '\u007E'))      
        {
          return false
        }
        return true  
      } ?: "")
  }

  ** Quoted pair. Ex:   \t  
  MailNode readQuotedPair(InStream in)
  {
    Bool afterQuote
    Bool done
    result := in.readStrToken(null) |char|
    {
      if(done)
        return true
      if (char == '\\')
      {
        afterQuote = true
        return false
      }
      if(afterQuote && (isVchar(char) || isWsp(char)))
      {
        afterQuote = false
        done = true
        return false 
      }
      return true
    } 
    if(afterQuote)
    {
      result = result[0..-2]
      in.unreadChar('\\')
    }
    return MailNode.makeLeaf(MailNodes.QUOTEDPAIR, result ?: "")
  }
    
  ** ctext / quoted-pair / comment
  MailNode readCcontent(InStream in)
  {
    MailNode found := readCtext(in)
    if(! found.isEmpty) return MailNode(MailNodes.CCONTENT, [found])
      found = readQuotedPair(in)
    if(! found.isEmpty) return MailNode(MailNodes.CCONTENT, [found])
      found = readComment(in)
    if(! found.isEmpty) return MailNode(MailNodes.CCONTENT, [found])
      return emptyNode
  }
  
  ** Read aText -> See isAtext()  
  MailNode readAtext(InStream in)
  {
    return MailNode.makeLeaf(MailNodes.ATEXT, in.readStrToken(null) |char|
      {
        return ! isAtext(char)
      } ?: "")
  }
  
  ** dot-atom        =   [CFWS] dot-atom-text [CFWS]
  MailNode readDotAtom(InStream in)
  {
    nodes := [,]
    nodes.add(readCfws(in))
    cc := readDotAtomText(in)
    if(cc.isEmpty)
    {
      unreadNodes(in, nodes)
      return emptyNode
    }
    else
    {
      return MailNode(MailNodes.DOTATOM, nodes.add(cc).add(readCfws(in)))
    }
  }

  ** dot-atom-text   =   1*atext *("." 1*atext)
  MailNode readDotAtomText(InStream in)
  {
    nodes := [,]
    cc := readAtext(in)
    if(cc.isEmpty)
    {
      return emptyNode
    }
    else
    {
      nodes.add(cc)
      while(true)
      {
        c := in.peekChar
        if(c == '.')
        {
          in.readChar
          cc2 := readAtext(in)
          if(cc2.isEmpty)
          {
            unread(in, ".") 
            break 
          }
          else
          {
            nodes.add(MailNode.makeLeaf(MailNodes.DOT, ".")).add(cc2)  
          }
        }
        else
        {
          break
        }
      }
      return MailNode(MailNodes.DOTATOM, nodes)
    }    
  }    
  
  ** [CFWS] 1*atext [CFWS]
  MailNode readAtom(InStream in)
  {
    nodes := [,]
    found := false
    while(true)
    {
      nodes.add(readCfws(in))
      cc := readAtext(in)
      if(cc.isEmpty)
        break
      //else
      found = true
      nodes.add(cc)
    }

    if(found)
      nodes.add(readCfws(in))
    else
      unreadNodes(in, nodes)

    return found ? MailNode(MailNodes.ATOM, nodes) : emptyNode  
  }    
                  
                                                        
  ** "(" *([FWS] ccontent) [FWS] ")"
  MailNode readComment(InStream in)
  {
    nodes := [,]
    if(in.peekChar != '(')
      return emptyNode
      
    nodes.add(MailNode.makeLeaf(MailNodes.PAR, "("))
    in.readChar

    found := false    
    while(true)
    {
      nodes.add(readFoldingWs(in))
      cc := readCcontent(in)
      if(cc.isEmpty)
        break
      //else
      found = true
      nodes.add(cc)
    } 
    
    if(found)
    {
      nodes.add(readFoldingWs(in))
      if(in.peekChar != ')')
      {
        found = false
      }
      else
      {
        in.readChar
        nodes.add(MailNode.makeLeaf(MailNodes.PAR, ")"))
      }
    }
    
    if( ! found)
      unreadNodes(in, nodes)
      
    return found ? MailNode(MailNodes.R_COMMENT, nodes) : emptyNode  
  }
      
  ** (1*([FWS] comment) [FWS]) / FWS
  MailNode readCfws(InStream in)
  {
    found := false
    nodes := [,]
    while(true)
    {
      nodes.add(readFoldingWs(in))
      cc := readComment(in)
      if(cc.isEmpty)
        break
      //else
      found = true
      nodes.add(cc)
    }
    
    if(found)
      nodes.add(readFoldingWs(in))
    else
      unreadNodes(in, nodes)
    
    // or FWS          
    return MailNode(MailNodes.R_CFWS, found ? nodes : [readFoldingWs(in)])
  }
  
  ** word            =   atom / quoted-string
  MailNode readWord(InStream in)
  {
    atom := readAtom(in)
    return MailNode(MailNodes.WORD, atom.isEmpty ? [readQuotedString(in)] : [atom])
  }
  
  ** phrase          =   1*word / obs-phrase
  ** Not dealing with obs-phrase yet
  MailNode readPhrase(InStream in)
  {
    // TODO: obs-phrase
    return MailNode(MailNodes.PHRASE, [readWord(in)])
  } 

  **    quoted-string   =   [CFWS] DQUOTE *([FWS] qcontent) [FWS] DQUOTE [CFWS]
  MailNode readQuotedString(InStream in)
  {
    nodes := [readCfws(in)]
    c := in.peekChar
    if(c != '"')
    {
      unreadNodes(in, nodes)
      return emptyNode
    }
    // else
    in.readChar
    nodes.add(MailNode.makeLeaf(MailNodes.QUOTE, "\""))
    while(true)
    {
      fws := readFoldingWs(in)
      cc := readQcontent(in)
      if(cc.isEmpty)
      {
        unread(in, fws.text)
        break 
      }
      else
      {
        nodes.add(fws).add(cc)  
      }
    }
    c = in.peekChar
    if(c != '"')
    {
      unreadNodes(in, nodes)
      return emptyNode
    } 
    // else
    in.readChar
    nodes.add(MailNode.makeLeaf(MailNodes.QUOTE, "\""))
    nodes.add(readCfws(in))
    return MailNode(MailNodes.QUOTEDSTRING, nodes)
  }  

  ** qcontent        =   qtext / quoted-pair
  MailNode readQcontent(InStream in)
  {
    t := readQtext(in)
    return MailNode(MailNodes.QCONTENT, t.isEmpty ? [readQuotedPair(in)] : [t])
  }
  ** qtext           =   %d33 / %d35-91 /%d93-126 /obs-qtext
  ** Not dealing with obs-qtext for now
  MailNode readQtext(InStream in)
  {
    // TODO: obs-qtext
    return MailNode.makeLeaf(MailNodes.QTEXT, in.readStrToken(null) |char|
      {
        return ! isQtext(char)
      } ?: "")    
  } 
    
  ** unstructured    =   (*([FWS] VCHAR) *WSP) / obs-unstruct
  ** Not dealing with obs-unstruct yet
  MailNode readUnstructured(InStream in)
  {
    // TODO: obs-unstruct
    found := false
    nodes := [,]
    while(true)
    {
      nodes.add(readFoldingWs(in))
      char := in.peekChar
      if( char==null || ! isVchar(char))
        break        
      //else
      found = true
      nodes.add(MailNode.makeLeaf(MailNodes.VCHAR, in.readChar.toChar))
    }
    
    if(found)
      nodes.add(readWsp(in))
    else
      unreadNodes(in, nodes)
    
    return found ? MailNode(MailNodes.T_UNSTRUCTURED, nodes) : emptyNode 
  }
  
  Void unreadNodes(InStream in, MailNode[] nodes)
  {
    nodes.eachr
    {
      unread(in, it.text)
    }
  }
  
  Void unread(InStream in, Str str)
  {
    str.eachr |char| {in.unreadChar(char)}
  }
  
  ** Read a folded line as a single line
  ** If the next line starts with whitespace (space or tab), it's a "folded" line
  Str readUnfoldedLine(InStream in)
  {
    buf := StrBuf()
    while(true)
    {
      line := in.readLine
      if(line == null)
        break
     
      buf.add(line)
      
      char := in.peekChar
      if( ! (char==' ' || char=='\t'))
        break
    }
    return buf.toStr 
  }
  
}