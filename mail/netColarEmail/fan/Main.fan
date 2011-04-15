// Artistic License 2.0. Thibaut Colar.
//
// History:
//   8-Mar-2011 thibautc Creation
//
using concurrent

** early testing rig
class Main
{
  // TODO: Once I have an imap server implementation, use that for testing ?
  Void main()
  {
    SmtpInterceptor i := SmtpInterceptor()
    i.port = 8900
    i.forward = 25
    i.host = "mail.colar.net"
    i.run
    Actor.sleep(1day)
    /*props := File(`/tmp/imap.props`).readProps
    host := props.get("host")
    user := props.get("user")
    pass := props.get("pass")
    
    echo("start")
    server := ImapClient.make(host)
    server.debug = true
    server.connect
    server.login(user, pass)    
    Actor.sleep(1sec)
    server.send("CAPABILITY")
    Actor.sleep(1sec)
    server.send(Str<|list "" *|>)
    Actor.sleep(1sec)
    server.send("status inbox (MESSAGES)")
    Actor.sleep(1sec)
    server.send("select inbox")
    Actor.sleep(1sec)
    server.logout
    Actor.sleep(3sec)
    server.disconnect
    echo("done")*/
  }   
  
}