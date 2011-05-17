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
  }
}

** From header
const class HeaderFrom : MailHeader
{
  const Mailbox[] boxes
  // mailbox-list CRLF
  new make(Str rawVal, Mailbox[] boxes) : super("From:", rawVal)
  {
    this.boxes = boxes
  }
}

