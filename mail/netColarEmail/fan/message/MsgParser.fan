// Artistic License 2.0. Thibaut Colar.
//
// History:
//   1-Mar-2011 thibautc Creation
//

using email

**
** MsgParser : Parse a Mail message (data) into a MailMsg object
** See RFC 5322
**
class MsgParser
{
  
  ** read a whole message  
  MailMessage readMessage(InStream in)
  {
    msg := MailMessage()
    {
        headers = HeadersParser(this).readHeaders(in)
        email = readBody(in)
    }
    return msg
  }
  
  ** Decode the email body
  Email readBody(InStream in)
  {
    email := Email()
    // TODO
    return email
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
  
  Str readWsp(InStream in)
  {
    return in.readStrToken(null) |char|
    {
      return ! isWsp(char)
    } ?: ""
  }

  ** space or tab or \r\n
  Str readFoldingWs(InStream in)
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
      
    return result ?: ""
  }
  
  ** %d33-39 / %d42-91 / %d93-126 /obs-ctext
  ** Not dealing with the obs-ctext for now (obsolete))
  Str readCtext(InStream in)
  {
    //TODO: obs-ctext
    return in.readStrToken(null) |char|
    {
      if ((char >= '\u0021' && char <= '\u0027') ||
            (char >= '\u002A' && char <= '\u005B')||
          (char >= '\u005D' && char <= '\u007E'))      
      {
        return false
      }
      return true  
    } ?: ""
  }

  ** Quoted pair. Ex:   \t  
  Str readQuotedPair(InStream in)
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
    return result ?: ""
  }
    
  ** ctext / quoted-pair / comment
  Str readCcontent(InStream in)
  {
    Str found := readCtext(in)
    if(! found.isEmpty) return found
      found = readQuotedPair(in)
    if(! found.isEmpty) return found
      found = readComment(in)
    if(! found.isEmpty) return found
      return ""
  }
  
  ** Read aText -> See isAtext()  
  Str readAtext(InStream in)
  {
    return in.readStrToken(null) |char|
    {
      return ! isAtext(char)
    } ?: ""
  }
  
  ** dot-atom        =   [CFWS] dot-atom-text [CFWS]
  Str readDotAtom(InStream in)
  {
    buf := StrBuf()
    found := false
    buf.add(readCfws(in))
    cc := readDotAtomText(in)
    if(cc.isEmpty)
    {
      unread(in, buf.toStr)
      return ""
    }
    else
    {
      return buf.add(cc).add(readCfws(in)).toStr
    }
  }

  ** dot-atom-text   =   1*atext *("." 1*atext)
  Str readDotAtomText(InStream in)
  {
    cc := readAtext(in)
    if(cc.isEmpty)
    {
      unread(in, cc)
      return ""
    }
    else
    {
      buf := StrBuf().add(cc)
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
            buf.add(".").add(cc2)  
          }
        }
        else
        {
          break
        }
      }
      return buf.toStr
    }    
  }    
  
  ** [CFWS] 1*atext [CFWS]
  Str readAtom(InStream in)
  {
    buf := StrBuf()
    found := false
    while(true)
    {
      buf.add(readCfws(in))
      cc := readAtext(in)
      if(cc.isEmpty)
        break
      //else
      found = true
      buf.add(cc)
    }

    if(found)
      buf.add(readCfws(in))
    else
      unread(in, buf.toStr)

    return found ? buf.toStr : ""  
  }    
                  
                                                        
  ** "(" *([FWS] ccontent) [FWS] ")"
  Str readComment(InStream in)
  {
    buf := StrBuf()
    if(in.peekChar != '(')
      return ""
      
    buf.add("(")
    in.readChar

    found := false    
    while(true)
    {
      buf.add(readFoldingWs(in))
      cc := readCcontent(in)
      if(cc.isEmpty)
        break
      //else
      found = true
      buf.add(cc)
    } 
    
    if(found)
    {
      buf.add(readFoldingWs(in))
      if(in.peekChar != ')')
      {
        found = false
      }
      else
      {
        in.readChar
        buf.add(")")
      }
    }
    
    if(!found)
      unread(in, buf.toStr)
      
    return found ? buf.toStr : ""  
  }
      
  ** (1*([FWS] comment) [FWS]) / FWS
  Str readCfws(InStream in)
  {
    found := false
    buf := StrBuf()
    while(true)
    {
      buf.add(readFoldingWs(in))
      cc := readComment(in)
      if(cc.isEmpty)
        break
      //else
      found = true
      buf.add(cc)
    }
    
    if(found)
      buf.add(readFoldingWs(in))
    else
      unread(in, buf.toStr)
    
    // or FWS          
    return found ? buf.toStr : readFoldingWs(in) 
  }
  
  ** word            =   atom / quoted-string
  Str readWord(InStream in)
  {
    atom := readAtom(in)
    return atom.isEmpty ? readQuotedString(in) : atom
  }
  
  ** phrase          =   1*word / obs-phrase
  ** Not dealing with obs-phrase yet
  Str readPhrase(InStream in)
  {
    // TODO: obs-phrase
    return readWord(in)
  } 

  **    quoted-string   =   [CFWS] DQUOTE *([FWS] qcontent) [FWS] DQUOTE [CFWS]
  Str readQuotedString(InStream in)
  {
    buf := StrBuf().add(readCfws(in))
    c := in.peekChar
    if(c != '"')
    {
      unread(in, buf.toStr)
      return ""
    }
    // else
    in.readChar
    buf.add("\"")
    while(true)
    {
      fws := readFoldingWs(in)
      cc := readQcontent(in)
      if(cc.isEmpty)
      {
        unread(in, fws)
        break 
      }
      else
      {
        buf.add(fws).add(cc)  
      }
    }
    c = in.peekChar
    if(c != '"')
    {
      unread(in, buf.toStr)
      return ""
    } 
    // else
    in.readChar
    buf.add("\"")
    buf.add(readCfws(in))
    return buf.toStr
  }  

  ** qcontent        =   qtext / quoted-pair
  Str readQcontent(InStream in)
  {
    t := readQtext(in)
    return t.isEmpty ? readQuotedPair(in) : t
  }
  ** qtext           =   %d33 / %d35-91 /%d93-126 /obs-qtext
  ** Not dealing with obs-qtext for now
  Str readQtext(InStream in)
  {
    // TODO: obs-qtext
    return in.readStrToken(null) |char|
    {
      return ! isQtext(char)
    } ?: ""    
  } 
    
  ** unstructured    =   (*([FWS] VCHAR) *WSP) / obs-unstruct
  ** Not dealing with obs-unstruct yet
  Str readUnstructured(InStream in)
  {
    // TODO: obs-unstruct
    found := false
    buf := StrBuf()
    while(true)
    {
      buf.add(readFoldingWs(in))
      char := in.peekChar
      if( char==null || ! isVchar(char))
        break        
      //else
      found = true
      buf.add(in.readChar.toChar)
    }
    
    if(found)
      buf.add(readWsp(in))
    else
      unread(in, buf.toStr)
    
    return found ? buf.toStr : "" 
  }
  
  Void unread(InStream in, Str str)
  {
    str.eachr |char| {in.unreadChar(char)}
  }
}