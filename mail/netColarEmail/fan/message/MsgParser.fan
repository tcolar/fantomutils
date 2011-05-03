// Artistic License 2.0. Thibaut Colar.
//
// History:
//   1-Mar-2011 thibautc Creation
//

using email

**
** MsgParser : Parse a Mail message (text data) into a MailMsg object
** TODO: see: http://imapwiki.org/ImapTest/Examples
** See RFC 5322
**
class MsgParser
{
  ** escaped soublequote
  ** If found within a quoted string(content, qcontent), this is just a (non-ending) quote
  const Str escStr := Str<|\"|>
  ** Comments: anywhere except within quoted string (can be nested)
  const Regex comment := Regex<|(.*)|>
  ** Folding whitespace (CR + LF + one or more whitespaces)
  //const Regex FoldingWS := Regex<|\r\n\s+|> 
  ** alphaText, US ACSII chars except secialChars
  ** Note '-' needs to be first or last to be traited as a litteral
  const Regex atext := Regex<|[a-zA-Z0-9#$%&*+/=?^_`{}|~-]|>
  ** "sepcial" chars
  ** Note: ']' needs to be first to be interpreted as a litteral
  ** TODO: should \ be doubled ??
  const Regex specials := Regex<|[](){}[:;,."@\\]|>
  ** ASCII text except '\' and '"'
  const Regex qtext := Regex<|[\u21\u23-\u5B\u5D-\u7E]|>
  
  /*
  Overall syntax:
  message         =   (fields / obs-fields)
                       [CRLF body]

   body            =   (*(*998text CRLF) *998text) / obs-body

   text            =   %d1-9 /            ; Characters excluding CR
                       %d11 /             ;  and LF
                       %d12 /
                       %d14-127
  
  CFWS : comment OR FoldingWs
  ctext: us ascii except '(', ')' , '\'
  ccontent : ctext / quoted-pair / comment
  atom            =   [CFWS] 1*atext [CFWS]
  dot-atom-text   =   1*atext *("." 1*atext)
  dot-atom        =   [CFWS] dot-atom-text [CFWS]  
  
   qcontent        =   qtext / quoted-pair
   quoted-string   =   [CFWS]
                       DQUOTE *([FWS] qcontent) [FWS] DQUOTE
                       [CFWS]
   word            =   atom / quoted-string
   phrase          =   1*word / obs-phrase
   unstructured    =   (*([FWS] VCHAR) *WSP) / obs-unstruct    
  
                      address         =   mailbox / group

   mailbox         =   name-addr / addr-spec
   name-addr       =   [display-name] angle-addr
   angle-addr      =   [CFWS] "<" addr-spec ">" [CFWS] /
                       obs-angle-addr
   group           =   display-name ":" [group-list] ";" [CFWS]
   display-name    =   phrase
   mailbox-list    =   (mailbox *("," mailbox)) / obs-mbox-list
   address-list    =   (address *("," address)) / obs-addr-list
   group-list      =   mailbox-list / CFWS / obs-group-list    

  Because the list of mailboxes can be empty, using the group construct
   is also a simple way to communicate to recipients that the message
   was sent to one or more named sets of recipients, without actually
   providing the individual mailbox address for any of those recipients.
   
   addr-spec       =   local-part "@" domain
   local-part      =   dot-atom / quoted-string / obs-local-part
   domain          =   dot-atom / domain-literal / obs-domain
   domain-literal  =   [CFWS] "[" *([FWS] dtext) [FWS] "]" [CFWS]
   dtext           =   %d33-90 /          ; Printable US-ASCII
                       %d94-126 /         ;  characters not including
                       obs-dtext          ;  "[", "]", or "\"               
   */                     
  MailMessage decode(InStream in)
  {
    msg := MailMessage()
    msg.headers = decodeHeaders(in)
    msg.email = decodeBody(in)
    return msg
    
    // TODO
    // Unfolding to be done first
    /*
    Since a comment is allowed to
   contain FWS, folding is permitted within the comment.  Also note that
   since quoted-pair is allowed in a comment, the parentheses and
   backslash characters may appear in a comment, so long as they appear
   as a quoted-pair
 
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
  
  ** If a line ends with whitespace (space or tab) it's a "folded" line
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
      if(char == ' ')
        buf.add(' ')
      else if(char == '\t')
        buf.add('\t')
      else
        break;
    }
    return buf.toStr 
  }
}