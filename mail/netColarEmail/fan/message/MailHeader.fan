// History:
//   May 7, 2011 thibaut Creation
//

** One mail message header
abstract const class MailHeader
{
  const Str name
  const Str rawVal
  
  new make(Str name, Str val)
  {
    this.name = name
    rawVal = val
    // TODO: Parse the kind (enum?) like To etc... 
  }
}




const class HeaderFrom : MailHeader
{
  // mailbox-list CRLF
  new make() : super("From:","")
  {
    
  }
}

** a maibox (a.k.a email address, possibly named)
const class MailBox
{
  const Str mb
  
  new make(Str mb)
  {
    this.mb = mb
  }
}