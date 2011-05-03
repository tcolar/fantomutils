using inet

**
** LogConsumer
**
class LogConsumer : SmtpDataConsumer
{
  ** Where to log to (info level)
  ** If null -> console out
  Log? log

  private DateTime? startTime
  private Str? addr
    
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
  
  override Void inData(Buf buf) 
  {
    buf.readAllLines.each 
    {
      if(log == null)
        echo(">> $it")
      else
        log.info(">> $it")
    }
  }
  
  override Void outData(Buf buf) 
  {
    buf.readAllLines.each 
    {
      if(log == null)
        echo("<< $it")
      else
        log.info("<< $it")
    }
  }
}