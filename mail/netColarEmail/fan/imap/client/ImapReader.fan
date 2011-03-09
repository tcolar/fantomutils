// Artistic License 2.0. Thibaut Colar.
//
// History:
//   8-Mar-2011 thibautc Creation
//
using concurrent
using inet

**
** ImapReader: 
** Actor that reads data sent from the imap server
**
const class ImapReader : Actor
{
  new make() : super(ActorPool()) 
  {    
  }
  
  override Obj? receive(Obj? msg)
  {
    socket := msg->val as TcpSocket
    in := socket.in
    while(socket.isConnected)
    {
      str := in.readLine
      if(str != null)
        echo("Received: $str")
    }       
    return null
  }
}