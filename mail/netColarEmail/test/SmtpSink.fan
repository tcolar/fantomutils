// History:
//   May 2, 2011 thibaut Creation
//
using inet
using concurrent

**
** SmtpSink
** Dummy/test server that just accpets everything and SAVES NOTHING
** 
**
const class SmtpSink
{
  const Int port
  
  const ActorPool pool:= ActorPool()
  
  new make(Int port)
  {
    this.port = port
  }
  
  Void start()
  {
    Actor(pool, |->| { listen }).send(null)
  }  
  
  Void stop()
  {
    pool.stop
    pool.kill
  }
  
  Void listen()
  {
    listener := TcpListener()
    while(true)
    {
      try
      {
        listener.bind(null, port)
      }
      catch (Err e)
      {
        echo("Service cannot bind to port ${port}")
        Actor.sleep(10sec)
      }
      while (!pool.isStopped && !listener.isClosed)
      {
        try
        {
          socket := listener.accept
          SinkActor().send(Unsafe(socket))
        }
        catch (Err e)
        {
          if (!pool.isStopped && !listener.isClosed)
            e.trace
        }
      }

      try { listener.close } catch {}
      }
  }
}

** Eat up smtp data and reply OK to "all"
const class SinkActor : Actor
{
  new make() : super(ActorPool()) {}
  
  override Obj? receive(Obj? msg)
  {  
    echo("sink start")  
    TcpSocket src := ((Unsafe)msg).val
    in := src.in
    out := src.out
    out.printLine("220 dummy.colar.net. SinkActor 3000").flush
    buf := Buf(5000)
    inData := false
    done := false
    while( ! done)
    {
      sleep(50ms)
      in.readBuf(buf, 5000)
      lines := buf.flip.readAllLines
      buf = buf[buf.pos .. -1]
      lines.each |line| 
      {
        if(inData)
        {
          if(line.equals("."))
          {
            out.printLine("250 Got your message AND TRASHED IT.").flush
            inData = false
          }
          // otherwise keep reading data
        }
        else if(line.startsWith("DATA"))
        {
          out.printLine("354 Go ahead.").flush        
          inData = true
        }
        else if (line.startsWith("QUIT"))
        {
          out.printLine("221 Bye!").flush 
          done = true;              
        }
        else
        {  
          out.printLine("250 OK").flush
        }
      }
    }
    out.close
    in.close
    return null
  } 
}