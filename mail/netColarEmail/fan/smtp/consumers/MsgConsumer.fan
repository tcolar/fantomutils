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
    startTime = DateTime.now
    addr = socket.remoteAddr.toStr
    echo("Starting Smtp transaction from $addr")
  }
  
  override Void onEnd()
  {
    time := DateTime.now - startTime
    echo("Processed Smtp transaction from $addr in $time")
  }
  
  override Void inData(Buf buf)  {}
  
  override Void outData(Buf buf) {}
}