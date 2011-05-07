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
  const Uri dataFolder := `./test/data/maildir/`

  Void testScanner()
  {
    /*scanner := MaildirBoxScanner { folderSepIsDot = true }
    dir := File(dataFolder);
    
    boxes := scanner.scan([,], dir)
    
    verifyEq(5, boxes.size)
    
    verifyBox(boxes[0], "")
    verifyBox(boxes[1], "archives")
    verifyBox(boxes[2], "archives/2004")
    verifyBox(boxes[3], "Sent")
    verifyBox(boxes[4], "Drafts")
    
    verifyCount(boxes[0], 2, 1 , 0)
    verifyCount(boxes[1], 0, 0 , 0)
    verifyCount(boxes[2], 2, 0 , 0)
    verifyCount(boxes[3], 2, 0 , 0)
    verifyCount(boxes[4], 1, 0 , 0)*/
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
