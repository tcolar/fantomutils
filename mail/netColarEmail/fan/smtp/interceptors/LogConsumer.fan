using inet

**
** LogConsumer
**
class LogConsumer : SmtpDataConsumer
{
  DateTime? startTime
  Str? addr
  
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
  
  override Void inData(Buf buf)  {echo(">> "+buf.readAllLines)}
  
  override Void outData(Buf buf) {echo("<< "+buf.readAllLines)}
}