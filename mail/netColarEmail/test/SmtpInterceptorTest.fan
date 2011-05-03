// Copyright : Teachscape
//
// History:
//   May 2, 2011 thibaut Creation
//
using email
using concurrent

**
** SmtpInterceptorTest
** Test the interceptor and some consumers
**
class SmtpInterceptorTest : Test
{
  Int intPort := 8912
  Int sinkPort := 8925
  
  Void test1()
  {
    sink := SmtpSink(sinkPort)
    sink.start
    
    int := SmtpInterceptor()
    int.port =  intPort
    int.host = "localhost"
    int.forward = sinkPort
    int.consumers = [LogConsumer#]
    
    int.run
    
    sendEmail
    
    sink.stop    
  }

  
  Void sendEmail()
  {
    email := Email
    {
      from = "tbo@colar.net"
      to = ["tcolar@colar.net"]
      subject = "Test email"
      body = TextPart{text = "Hello world!"}
    }
    
    s := SmtpClient
    {
      it.host = "localhost"
      it.port = this.intPort
    }
    s.open
    s.send(email)
    s.close
  }
}
