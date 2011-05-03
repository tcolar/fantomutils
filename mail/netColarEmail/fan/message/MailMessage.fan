// Artistic License 2.0. Thibaut Colar.
//
// History:
//   1-Mar-2011 thibautc Creation
//
using email

**
** MailMessage
**
class MailMessage
{
  MailHeader[] headers 
  
  Email email
  
  new make(|This|? itBlock := null)
  {
    if (itBlock != null) 
      itBlock(this)
  }
  
  //const Buf Body
  
  // TODO: Mime/encoding
}

** One mail header
class MailHeader
{
  Str name
  Str value
  
  new make(Str name, Str value)
  {
    this.name = name
    this.value = value
    // TODO: Parse the kind (enum?) like To etc... 
  }
}

** An extension of MailMessage with some smtp info.
class SmtpMessage : MailMessage
{
  // When received from a remote host (smtp) - socket host
  Str smtpHostIp  

  Str[] rawData
    
  new make(|This|? itBlock := null) : super()
  {
    if (itBlock != null) 
      itBlock(this)
  }  
}
