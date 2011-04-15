// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Apr 14, 2011 thibaut Creation
//

**
** SmtpClient
** Sends an SMTP Message
**
const class SmtpClient
{
  const Str host
  const Int port
  
  new make(Str host, Int port:=25)
  {
    this.host = host
    this.port = port
  }
  
  Void sendMessage(MailMessage msg)
  {
    
  }
}