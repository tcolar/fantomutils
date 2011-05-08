// Artistic License 2.0. Thibaut Colar.
//
// History:
//   25-Feb-2011 thibautc Creation
//

**
** Test for MaildirScanner
**
class MaildirTest : Test
{
  const File dataFolder := File(`./test/data/maildir/`)

  Void testScanner()
  {
    scanner := MaildirBoxScanner { folderSepIsDot = true }
    
    boxes := scanner.scan([,], dataFolder)
    verifyEq(4, boxes.size)
    
    verifyBox(boxes[0], "")
    verifyBox(boxes[1], "archives/2004")
    verifyBox(boxes[2], "Drafts")
    verifyBox(boxes[3], "Sent")
    
    verifyCount(boxes[0], 2, 1 , 0)
    verifyCount(boxes[1], 2, 0 , 0)
    verifyCount(boxes[2], 1, 0 , 0)
    verifyCount(boxes[3], 2, 0 , 0)
  }
  
  ** check mailbox path
  Void verifyBox(MaildirBox box, Str path)
  {
    verifyEq(box.path.join("/"), path)
  }
  
  ** check message count
  Void verifyCount(MaildirBox box, Int cur, Int newOnes, Int tmp)
  {
    verifyEq(box.curCount, cur)
    verifyEq(box.newCount, newOnes)
    verifyEq(box.tmpCount, tmp)
  }
}
