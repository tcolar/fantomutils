// Artistic License 2.0. Thibaut Colar.
//
// History:
//   8-Mar-2011 thibautc Creation
//
using inet

**
** ImapClient
** 
** Useful : http://www.dovecot.org/imap-client-coding-howto.html
**
class ImapClient
{
  const Int contChar := '+'
  
  const Str host
  const Int port
  
  Bool debug := false
  
  TcpSocket socket := TcpSocket()
  
  ImapState state := ImapState.NON_AUTH

  ImapReader reader := ImapReader()
  
  OutStream? out
  
  Int msgId := 0
    
  new make(Str host, Int port := 143)
  {
    this.host = host
    this.port = port
    // TODO: Once connected, need to have a reader thread started (data can come from server at all times)
    // Spec says data should be recorded / logged ?
    // 32 bits unique message UUID (must persist even between sessions)
    /*
    First,
    the next unique identifier value MUST NOT change unless new messages
    are added to the mailbox; and second, the next unique identifier
    value MUST change whenever new messages are added to the mailbox,
    even if those new messages are subsequently expunged.
 
    The unique identifier validity value is sent in a UIDVALIDITY
    response code in an OK untagged response at mailbox selection time.  
 
    A good UIDVALIDITY value to use in this case
    is a 32-bit representation of the creation date/time of
    the mailbox
  
    flags:        
    \Seen
    \Answered
    \Flagged (urgent)
    \Deleted
    \Draft
    \Recent
       
    Specifically, it is possible to fetch the
    [RFC-2822] message header, [RFC-2822] message body, a [MIME-IMB]
    body part, or a [MIME-IMB] header.
  
    states: NOT_AUTH, AUTH, SELECTED, LOGOUT
 
    Data structures are represented as a "parenthesized list"; a sequence
    of data items, delimited by space, and bounded at each end by
    parentheses.  A parenthesized list can contain other parenthesized
    lists, using multiple levels of parentheses to indicate nesting.

    The empty list is represented as () -- a parenthesized list with no
    members.
 
    NIL (no data)

    Mailbox names are 7-bit, don't allow * % # & # ... (separator '.')
    */
  }
 
  Bool connect()
  {
    try
    {
      socket.connect(IpAddr(host), port)
      out = socket.out  
          
      reader.send(Unsafe(socket))
        
      state = ImapState.AUTH
      return true  
    }
    catch(IOErr e) 
    {
      e.trace
      out = null
      state = ImapState.NON_AUTH
    }
    return false  
  }
 
  Void disconnect() 
  { 
    socket.close
    state = ImapState.NON_AUTH
  }
  
  Bool login(Str user, Str pass)
  {
    if( ! socket.isConnected)
      return false 
    send("login $user $pass")
    return true 
  }
  
  Void logout()
  {    
    if(socket.isConnected)
      send("logout")
  }

  /*internal*/ Void send(Str str)
  {
    msgId++
    msg := "A"+msgId.toStr.padl(4, '0')+" "+str
    if(debug)
      echo("Sending : $msg")

    out.print("${msg}\r\n").flush
  }
}

** Imap states
enum class ImapState
{
  NON_AUTH, AUTH, SELECTED, LOGOUT
}

/** Standard Imap Commands
enum class ImapCommands
{
  // valid in any state:
  CAPABILITY, NOOP, LOGOUT,
  // not authenticated commands:
  STARTTLS,  AUTHENTICATE, LOGIN,
  // authenticated comments:
  SELECT, EXAMINE, CREATE, DELETE, RENAME, SUBSCRIBE, UNSUBSCRIBE,
  LIST, LSUB, STATUS, APPEND,
  // selected state:
  CHECK, CLOSE, EXPUNGE, SEARCH, FETCH, STORE, COPY, UID
  // Then there are custom X** commands
}*/

/** standard responses
enum class ImapResponses
{
  OK, NO, BAD,
  PREAUTH, BYE, EXISTS, RECENT, EXPUNGE, FLAGS, INTERNAL_DATE,
  ALERT, BADCHAREST, CAPABILITY, PARSE, PERMANENTFLAGS, READ_ONLY("READ-ONLY"), 
  READ_WRITE("READ-WRITE"), TRYCREATE, UIDNEXT, UIDVALIDITY, UNSEEN,
  HEADER, SIZE, TEXT, UID,
  // List:
  NO_INFERIORS("\\Noinferiors"), NO_DELECT("Noselect"), MARKED("\\Marked"),
  UNMARKED("\\Unmarked"),
  //Body
  BODY, BODYSTRUCTURE, ENVELOPE
}*/

/** standard IMAP capabilities
enum class ImapCapabilities
{
  STARTTLS, LOGINDISABLED, AUTH_PLAIN("AUTH=PLAIN")
}*/

/** Standard Imap flags
enum class ImapFlags
{
  SEEN("\\Seen"), ANSWERED("\\Answered"), FLAG("\\Flag"), DELETED("\\Deleted"), 
  DRAFT("\\Draft"), RECENT("\\Recent")
}*/