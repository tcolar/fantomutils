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
  new make() : super("From:","")
  {}
}

