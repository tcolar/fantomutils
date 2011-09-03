// History:
//   Apr 6, 2011 thibaut Creation
//
using util
using concurrent
using inet

**
** Smtp server passthrough / relay
** "Intercepts" the data for processing. 
** 
class SmtpInterceptor : AbstractMain
{ 
  @Opt { help = "Listening to port (25)"; aliases=["p"] }
  Int port := 25
  
  @Opt { help = "Foward to Smtp port (8025)"; aliases=["f"] }
  Int forward := 8025
  
  @Opt { help = "Host To forward to"; aliases=["h"] }
  Str host := "127.0.0.1"
 
  //TODO: Use property file
  Type[] consumers := [LogConsumer#]
   
  override Int run()
  {
    itc := SmtpInterceptorService
    {
      listenPort = port
      forwardHost = host
      forwardPort = forward
      it.consumers = this.consumers
    }
    try
    {
      itc.start
      //Actor.sleep(Duration.maxVal)
      echo("Interceptor started on $port [to $host : $forward]")
      return 0
    }
    catch(Err e)
    {
      echo("Startup failed")
      e.trace
      return -1
    }
  }
}

**
** SmtpInterceptor Service
** Pass-through an SMTP request while interecpting the data
** Mostly used for testing / debugging or to "proxy"
**
const class SmtpInterceptorService : Service
{
  const Int listenPort := 25
  const Int forwardPort
  const Str forwardHost
  const Type[] consumers := [,]
 
  internal const ActorPool listenerPool    := ActorPool()
  internal const AtomicRef tcpListenerRef  := AtomicRef()
  internal const ActorPool processorPool   := ActorPool()
 
  ** "This" constructor
  new make(|This|? f := null) { if (f != null) f(this) }

  override Void onStart()
  {
    if (listenerPool.isStopped) throw Err("Service is already stopped, use to new instance to restart")
      Actor(listenerPool, |->| { listen }).send(null)
  }

  override Void onStop()
  {
    try listenerPool.stop;   catch (Err e) e.trace
      try closeTcpListener;    catch (Err e) e.trace
      try processorPool.stop;  catch (Err e) e.trace
    }

  private Void closeTcpListener()
  {
    Unsafe unsafe := tcpListenerRef.val
    TcpListener listener := unsafe.val
    listener.close
  }

  internal Void listen()
  {
    // loop until we successfully bind to port
    listener := TcpListener()
    tcpListenerRef.val = Unsafe(listener)
    while (true)
    {
      try
      {
        listener.bind(null, listenPort)
        break
      }
      catch (Err e)
      {
        echo("Service cannot bind to port ${listenPort}")
        Actor.sleep(10sec)
      }
    }
    echo("Service started on port ${listenPort}")

    // loop until stopped accepting incoming TCP connections
    while (!listenerPool.isStopped && !listener.isClosed)
    {
      try
      {
        socket := listener.accept
        SmtpInterceptorActor(this).send(Unsafe(socket))
      }
      catch (Err e)
      {
        if (!listenerPool.isStopped && !listener.isClosed)
          e.trace
      }
    }

    // socket should be closed by onStop, but do it again to be really sure
    try { listener.close } catch {}
      echo("Service stopped on port ${listenPort}")
  }
}

** Handle one SMTP transaction.
const class SmtpInterceptorActor : Actor
{
  const SmtpInterceptorService service
	
  new make(SmtpInterceptorService service) : super(service.processorPool)
  {
    this.service = service
  }

  **
  ** Proces a SMTP socket.
  **
  override Obj? receive(Obj? msg)
  {    
    TcpSocket src := ((Unsafe)msg).val

    TcpSocket dest := TcpSocket();
    dest.options.receiveTimeout = 30min
    
    // If we can't reach the forward server, then don't attempt to do anyhting.
    try
    {      
      dest.connect(IpAddr(service.forwardHost), service.forwardPort)
    }
    catch(Err e)
    {
      echo("Destination could not be reached($service.forwardHost : $service.forwardPort). Dropping request.")
      try {src.close} catch {}
        return null
    }
    
    try
    {
      src.options.receiveTimeout = 30min
      process(src, dest)
    }
    catch (Err e) { e.trace }
      finally { try { src.close } catch {} }
      
      return null
  }
 
  **
  ** Process a single SMTP request
  **
  Void process(TcpSocket src, TcpSocket dest)
  {
    bufSize := 1000
    buf:= Buf(bufSize)
    
    // create local consumers instances
    SmtpDataConsumer[] consumers := [,]
    service.consumers.each |type| 
    {
      if(type.fits(SmtpDataConsumer#))
      {
        consumers.add(type.make())
      }
    }

    consumers.each {it.onStart(src)}

    if(src.isConnected && dest.isConnected)
    {
      ActorPool pool := ActorPool()
      in := SmtpPipeActor(pool)
      f1 := in.send(Unsafe(["in":src.in, "out":dest.out, "cons":consumers, "direction":"in"]))
      out := SmtpPipeActor(pool)
      f2 := out.send(Unsafe(["in":dest.in, "out":src.out, "cons":consumers, "direction":"out"]))
      while(!f1.isDone && !f2.isDone)
      {
        sleep(100ms)
      }    
      echo("closed")
      // if either connection dropped, we need to terminate both
      pool.kill  
    }

    consumers.each {it.onEnd()}
  }	
}

** Read from one stream and pipe into another
** Pass the data to the consumers
const class SmtpPipeActor : Actor
{
  const Int bufSize := 10000
  
  new make(ActorPool pool) : super(pool) {} 
  	
  override Obj? receive(Obj? msg)
  {	
    Map map := (msg as Unsafe).val
    InStream in := map["in"]
    OutStream out := map["out"]
    SmtpDataConsumer[] consumers := map["cons"]
    Bool goingIn := map["direction"].equals("in")
    
    try
    { 
      Buf buf := Buf(bufSize)
      while(true)
      {
        // pipe from src to dest
        read := in.readBuf(buf, bufSize)
        if(read != null && read > 0)
        {
          data := buf[0..<read]
          out.writeBuf(data).flush
          data.seek(0)
          consumers.each 
          {
            try
            {
              if(goingIn)
                it.inData(data)
              else
                it.outData(data)
            }
            catch(Err e) {e.trace}
            }
          buf.clear
          sleep(10ms)
        }
      }
    }
    catch(Err e) 
    {
      // done
    }
    
    try{in.close} catch(Err e) {}
      try{out.close} catch(Err e) {}
    
      echo("Done")
    
    return null
  }
}

**
** Implementation will receive "copy" of the data intercepted by interceptor
** Can consume it in any way
** 
mixin SmtpDataConsumer
{
  ** Called once socket connected 
  ** socket : client(in) socket: to get infos, do NOT read/write from it.
  abstract Void onStart(TcpSocket socket)
  ** Called(0-n times) as data is received from client and passed to server(data copy)
  abstract Void inData(Buf buf)
  ** Called(0-n times) as data is received from server and passed to client(data copy)
  abstract Void outData(Buf buf)
  ** Called once communication is completed
  abstract Void onEnd(/*SmtpInterceptorStatus status*/)
}

/*enum class SmtpInterceptorStatus
{
OK, ERROR
}*/

