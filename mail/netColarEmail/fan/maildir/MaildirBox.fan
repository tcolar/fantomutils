// Artistic License 2.0. Thibaut Colar.
//
// History:
//   25-Feb-2011 thibautc Creation
//

**
** Maildir Box data object
**
const class MaildirBox
{
  ** Path of the mailbox: Example ["archives","2004","Sent"]
  ** Empty for mailbox root.
  const Str[] path := [,]
  const Uri dir := ``
  
  new make(|This|? itBlock := null)
  {
    if (itBlock != null) 
      itBlock(this)
  }  
  
  Int curCount() { msgCount(`cur/`) }
  
  Int newCount() { msgCount(`new/`) }
  
  Int tmpCount() { msgCount(`temp/`) }
  
  ** Count number of messages in a folder of this mailbox
  internal Int msgCount(Uri folder) 
  { 
    cur := File(dir) + folder

    if( ! cur.exists ) return 0
     
    return cur.listFiles.reduce(0) |obj, file, val -> Obj?| 
    {
      return val + 1
    }
  }

}