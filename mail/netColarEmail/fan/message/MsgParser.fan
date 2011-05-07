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
  ** Decode a whole message  
  MailMessage decode(InStream in)
  {
    msg := MailMessage()
    msg.headers = decodeHeaders(in)
    msg.email = decodeBody(in)
    return msg
    
    /*
    Runs of FWS, comment, or CFWS that occur between lexical tokens in a
    structured header field are semantically interpreted as a single
    space character
 
    Line 790: Datetime parsing -> use Fantom parser ??
    */
  }
  
  ** Decode all the headers (Until a blank line)
  MailHeader[] decodeHeaders(InStream in)
  {
    // TODO: deal with comments, quoted string and the other anoyances (RFC section 3,4, especially 3.6)
    MailHeader[] headers := [,]

    line := readUnfoldedLine(in)
    while(!line.isEmpty)
    {
      header := decodeHeader(line)
      if(header != null)
      {
        headers.add(header)
      }
      line = readUnfoldedLine(in)
    }
    return headers
  }
  
  ** Decode a single hear line into a Header object
  MailHeader? decodeHeader(Str header)
  {
    col := header.index(":")
    if(col != null)
    {
      name := header[0 ..< col].trim
      val := header.size >= col ? header[col+1 .. -1].trim : ""
      return MailHeader(name, val)
    }
    else
    {
      echo("Invalid header : $header")
    }
    return null
  }
  
  ** Decode the email body
  Email decodeBody(InStream in)
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
        break;
     
      buf.add(line)
      
      char := in.peekChar
      if( ! (char==' ' || char=='\t'))
        break;
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
    } 
  }

  Str readFoldingWs(InStream in)
  {
    // space or tab or \r\n
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
      
    return result
  }
  
  Str readCtext(InStream in)
  {
    // %d33-39 / %d42-91 / %d93-126 /obs-ctext
    // Not dealing with the obs-ctext for now (obsolete))
    return in.readStrToken(null) |char|
    {
      if ((char >= '\u0021' && char <= '\u0027') ||
          (char >= '\u002A' && char <= '\u005B')||
        (char >= '\u005D' && char <= '\u007E'))      
      {
        return false
      }
      return true  
    } 
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
    return result
  }
    
  Str readCcontent(InStream in)
  {
    // ctext / quoted-pair / comment
    Str found := readCtext(in)
    if(! found.isEmpty) return found
      found = readQuotedPair(in)
    //if(found != null && ! found.isEmpty) return found
    //  found = readComment(in)
    if(! found.isEmpty) return found
      return ""
  }
    
  Str readAtext(InStream in)
  {
    return in.readStrToken(null) |char|
    {
      return ! isAtext(char)
    } 
  }

  
  //Str readDotAtom(InStream in) { readStuff(in, #peekDotAtom) }
  
  /*Int peekDotAtom(InStream in)
  {
    //dot-atom-text   =   1*atext *("." 1*atext)
    //dot-atom        =   [CFWS] dot-atom-text [CFWS]
    Int skipped := skipChars(in, peekCfws(in))
    cc := peekAtext(in)
    if(cc == 0)
    {
      unreadChars(in, skipped)
      return 0
    }
    // else
    skipped += skipChars(in, cc)
    while(true)
    {
      c := in.peekChar
      if(c == '.')
      {
        skipChars(in, 1)
        at := peekAtext(in)
        if(at > 0)
        {
          skipped += at + 1 // the +1 is for the '.''
        }
        else
        {
          unreadChars(in, 1) // the dot that was skipped
          break
        }
      }
      else
        break
    }
    skipped += skipChars(in, peekCfws(in))
    unreadChars(in, skipped)
    return skipped      
  }
       
  Str readAtom(InStream in) { readStuff(in, #peekAtom) }
  
  Int peekAtom(InStream in)
  {
    // [CFWS] 1*atext [CFWS]
    Int skipped := skipChars(in, peekCfws(in))
    cc := 0
    found := false
    while(true)
    {
      skipped += skipChars(in, peekAtext(in))
      cc = peekAtext(in)
      skipped += cc
      if(cc == 0)
        break
      else
        found = true
    }
    if(found) 
      skipped += skipChars(in, peekCfws(in))
    
    unreadChars(in, skipped)

    return found ? skipped : 0; 
  }    
                  
  Int peekComment(InStream in)
  {
    //"(" *([FWS] ccontent) [FWS] ")"
    if(in.peekChar != '(')
      return 0
    skipped := skipChars(in,1)
    cc := 0
    while(true)
    {
      skipped += skipChars(in, peekFoldingWs(in))
      cc = peekCcontent(in)
      skipped += cc
      if(cc == 0)
        break
    } 
    skipped += skipChars(in, peekFoldingWs(in))
    last := in.peekChar
    unreadChars(in, skipped)
    return (last == ')') ? skipped + 1  : 0 
  }
      
  Str readComment(InStream in){ readStuff(in, #peekComment) }
  
  Int peekCfws(InStream in)
  {
    // (1*([FWS] comment) [FWS]) / FWS
    skipped := 0
    cc := 0
    found := false
    while(true)
    {
      skipped += skipChars(in, peekFoldingWs(in))
      cc = peekCcontent(in)
      skipped += cc
      if(cc == 0)
        break
      else
        found = true
    }
    if(found)
      skipped += skipChars(in,peekFoldingWs(in))
    
    unreadChars(in, skipped)
    
    return found ? skipped : peekFoldingWs(in); 
  }
  
  Str readCfws(InStream in){ readStuff(in, #peekCfws) }
*/
}