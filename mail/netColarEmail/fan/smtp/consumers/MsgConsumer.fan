// History:
//   May 2, 2011 thibaut Creation
//
using inet

**
** MsgConsumer
** Intercept a message and create a MailMessage from It
**
class MsgConsumer : SmtpDataConsumer
{
  override Void onStart(TcpSocket socket)
  {
  }
  
  override Void onEnd()
  {
  }
  
  override Void inData(Buf buf)  {}
  
  override Void outData(Buf buf) {}
}