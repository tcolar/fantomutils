// Artistic License 2.0. Thibaut Colar.
//
// History:
//   1-Mar-2011 thibautc Creation
//

**
** MailMessage :  A mail message
**
const class MailMessage
{
  new make(|This|? itBlock := null)
  {
    if (itBlock != null) 
      itBlock(this)
  }
  
  const Str:Str headers // TODO : Need to keep the order according to RFC
  //const Buf Body
  
  // TODO: Mime/encoding
}