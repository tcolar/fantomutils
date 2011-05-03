// History:
//   May 2, 2011 thibaut Creation
//
using inet
using email

**
** MsgConsumer
** Intercept a message and create a MailMessage from It
**
class MsgConsumer : SmtpDataConsumer
{
  private TcpSocket? socket
  private Str[] lines := [,]
  
  override Void onStart(TcpSocket socket)
  {
    this.socket = socket
  }
  
  override Void onEnd()
  {
    // do the message
    msg := SmtpMessage
    {
      smtpHostIp = socket.remoteAddr.numeric
      mail := Email()
    }
  }
  
  override Void inData(Buf buf)  {}
  
  override Void outData(Buf buf) {}
}