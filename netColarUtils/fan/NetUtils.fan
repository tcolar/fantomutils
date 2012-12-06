// History:
//   12 6 12 - Thibaut Colar Creation

using inet

**
** NetUtils: Networking utilities
**
class NetUtils
{
  ** Try to find an ounbound local port starting at "StartAt"
  ** If startAt binding fails., then keep trying every (gap) port number
  ** Up to maxTries tries
  ** Returns first available port or null if none where found to be available
  static Int? findAvailPort(Int startAt := 8080, Int gap := 2, Int maxTries := 20)
  {
    listener := TcpListener()
    return (0 ..< maxTries).toList.eachWhile |i|
    {
      port := startAt + (i * gap)
      try
      {
        listener.bind(null, port)

        if(listener.isBound)
        {
          listener.close
        }
        return port
      }
      catch (Err e)
      {
        // Keep trying
      }
      return null
    }
  }
}