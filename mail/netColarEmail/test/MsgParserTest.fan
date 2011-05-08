// Artistic License 2.0. Thibaut Colar.
//
// History:
//   1-Mar-2011 thibautc Creation
//

**
** Test and test data for parsing email messages according to RFC 5322
** Test the parser level functions
** More high-level parsing tests in FullMsgParserTest
**
class MsgParserTest : Test
{
  
  Void testIsMethods()
  {    
    MsgParser m := MsgParser("".in)
    
    verifyFalse(m.isAtext('@'))
    verify(m.isAtext('`'))
    verify(m.isAtext('3'))
    verify(m.isAtext('a'))
    verify(m.isAtext('k'))
    verify(m.isAtext('Z'))
    verify(m.isAtext('D'))    
    
    verifyFalse(m.isVchar('\n'))
    verify(m.isVchar('a'))
    verify(m.isVchar('\u007E'))
    verify(m.isVchar('\u0052'))
    verifyFalse(m.isVchar('\u0002'))
    
    verify(m.isWsp(' '))
    verifyFalse(m.isWsp('a'))
    verify(m.isWsp('\t'))
    verifyFalse(m.isWsp('6'))   

    verify(m.isQtext(';'))
    verifyFalse(m.isQtext('"'))
    verify(m.isQtext('\u0077'))
    verifyFalse(m.isQtext('\u005C'))   
  }
  
  Void testReaders()
  {
    MsgParser? m
    in := "@,^&*(((".in
    m = MsgParser(in)
    verifyEq(m.readAtext, "")    
    verifyEq(in.peekChar, '@')
    in = Str<|0123?$_abcDEF578 *+.|>.in
    m = MsgParser(in)
    verifyEq(m.readAtext, Str<|0123?$_abcDEF578|>)
    verifyEq(in.peekChar, ' ')
    
    in = " \t z".in
    m = MsgParser(in)
    verifyEq(m.readWsp, " \t ")
    in = "zz".in
    m = MsgParser(in)
    verifyEq(m.readWsp, "")
    
    in = " \t\r\n \r\n\t \rz".in
    m = MsgParser(in)
    verifyEq(m.readFoldingWs," \t\r\n \r\n\t ")
    verifyEq(in.peekChar, '\r')
    in = "\\tz".in
    m = MsgParser(in)
    verifyEq(m.readQuotedPair,"\\t")
    verifyEq(in.peekChar, 'z')
    in = "\\".in
    m = MsgParser(in)
    verifyEq(m.readQuotedPair,"")
    verifyEq(in.peekChar, '\\')
    
    // ctext: %d33-39 / %d42-91 / %d93-126 /obs-ctext
    in = "\u0021\u0027\u002A\u005B\u005D\u007E\u0001".in
    m = MsgParser(in)
    verifyEq(m.readCtext,"\u0021\u0027\u002A\u005B\u005D\u007E")
    verifyEq(in.peekChar, '\u0001')

    in = 
"this
  is
 \t \t still
   the
 \t same
 \t\t  line
 Not any more".in
    m = MsgParser(in)
    verifyEq(m.readUnfoldedLine, "this is\t \t still  the\t same\t\t  line")
    verifyEq(m.readUnfoldedLine, "Not any more")

    // (1*([FWS] comment) [FWS]) / FWS
    in = "\t\r\n (blah)\r\n  (foo(\r\n bar)\t )Z".in
    m = MsgParser(in)
    verifyEq(m.readCfws, "\t\r\n (blah)\r\n  (foo(\r\n bar)\t )")
    verifyEq(in.peekChar, 'Z')
    in = "\t\r\n  x".in
    m = MsgParser(in)
    verifyEq(m.readCfws, "\t\r\n  ")
    verifyEq(in.peekChar, 'x')
    
    //  ** ccontent : ctext / quoted-pair / comment
    in = "abcdefg\u0001".in
    m = MsgParser(in)
    verifyEq(m.readCcontent, "abcdefg")
    verifyEq(in.peekChar, '\u0001')
    in = "\\xz".in
    m = MsgParser(in)
    verifyEq(m.readCcontent, "\\x")
    verifyEq(in.peekChar, 'z')
    in = "(abcdefg\r\n xx)z".in
    m = MsgParser(in)
    verifyEq(m.readCcontent, "(abcdefg\r\n xx)")
    verifyEq(in.peekChar, 'z')
    in = "\u0001".in
    m = MsgParser(in)
    verifyEq(m.readCcontent, "")
    verifyEq(in.peekChar, '\u0001')
    
    // ** "(" *([FWS] ccontent) [FWS] ")"
    in = "(blah\r\n \\?\r\nabcdef\r\n (blah)\r\n )z".in
    m = MsgParser(in)
    verifyEq(m.readComment, "(blah\r\n \\?\r\nabcdef\r\n (blah)\r\n )")
    verifyEq(in.peekChar, 'z')
    in = "(\r\n  (blah)\r\n\tz".in
    m = MsgParser(in)
    verifyEq(m.readComment, "")
    verifyEq(in.peekChar, '(')
    
    //  ** [CFWS] 1*atext [CFWS]
    in = "\t\r\n (blah)\r\n abcdefg\t\r\n (blah)\r\n123456789\u0001".in
    m = MsgParser(in)
    verifyEq(m.readAtom, "\t\r\n (blah)\r\n abcdefg\t\r\n (blah)\r\n123456789")
    verifyEq(in.peekChar, '\u0001')
    
    // dot-atom-text   =   1*atext *("." 1*atext)
    in = "0123?*_abcDEF578 ".in
    m = MsgParser(in)
    verifyEq(m.readDotAtomText, "0123?*_abcDEF578")
    verifyEq(in.peekChar, ' ')
    in = "0123?*_abcDEF578.".in
    m = MsgParser(in)
    verifyEq(m.readDotAtomText, "0123?*_abcDEF578")
    verifyEq(in.peekChar, '.')
    in = "0123?*_abcDEF578.az_{5.d34x ".in
    m = MsgParser(in)
    verifyEq(m.readDotAtomText, "0123?*_abcDEF578.az_{5.d34x")
    verifyEq(in.peekChar, ' ')
    in = " x".in
    m = MsgParser(in)
    verifyEq(m.readDotAtomText, "")
    verifyEq(in.peekChar, ' ')
    
    // dot-atom        =   [CFWS] dot-atom-text [CFWS]
    in = "0123?*_abcDEF578.".in
    m = MsgParser(in)
    verifyEq(m.readDotAtom, "0123?*_abcDEF578")
    verifyEq(in.peekChar, '.')
    in = "\r\n  0123?*_abc.DEF578\r\n\t ,66".in
    m = MsgParser(in)
    verifyEq(m.readDotAtom, "\r\n  0123?*_abc.DEF578\r\n\t ")
    verifyEq(in.peekChar, ',')
    
    // qcontent        =   qtext / quoted-pair
    in = "\\t.".in
    m = MsgParser(in)
    verifyEq(m.readQcontent, "\\t")
    verifyEq(in.peekChar, '.')
    in = "fdsfdsfsd#!\u0064\u0022".in
    m = MsgParser(in)
    verifyEq(m.readQcontent, "fdsfdsfsd#!\u0064")
    verifyEq(in.peekChar, '\u0022')
    
    //quoted-string   =   [CFWS] DQUOTE *([FWS] qcontent) [FWS] DQUOTE [CFWS]
    in = "\"\"z".in
    m = MsgParser(in)
    verifyEq(m.readQuotedString, "\"\"")
    verifyEq(in.peekChar, 'z')
    in = " \r\n\t \"\r\n\t dsfdsf131243\"(comment\r\n )\r\n z".in
    m = MsgParser(in)
    verifyEq(m.readQuotedString, " \r\n\t \"\r\n\t dsfdsf131243\"(comment\r\n )\r\n ")
    verifyEq(in.peekChar, 'z')

    // unstructured    =   (*([FWS] VCHAR) *WSP) / obs-unstruct
    in = " \r\n\t945qbdsff\t\r\n\t 9598409\u0055 abcdf \t \u0007".in
    m = MsgParser(in)
    verifyEq(m.readUnstructured, " \r\n\t945qbdsff\t\r\n\t 9598409\u0055 abcdf \t ")
    verifyEq(in.peekChar, '\u0007')
  }
  
}