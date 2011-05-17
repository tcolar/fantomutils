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
    MsgParser m := MsgParser()
    
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
    m := MsgParser()
    in := "@,^&*(((".in
    verifyEq(m.readAtext(in).text, "")    
    verifyEq(in.peekChar, '@')
    in = Str<|0123?$_abcDEF578 *+.|>.in
    verifyEq(m.readAtext(in).text, Str<|0123?$_abcDEF578|>)
    verifyEq(in.peekChar, ' ')
    
    in = " \t z".in
    verifyEq(m.readWsp(in).text, " \t ")
    in = "zz".in
    verifyEq(m.readWsp(in).text, "")
    
    in = " \t\r\n \r\n\t \rz".in
    verifyEq(m.readFoldingWs(in).text," \t\r\n \r\n\t ")
    verifyEq(in.peekChar, '\r')
    in = "\\tz".in
    verifyEq(m.readQuotedPair(in).text,"\\t")
    verifyEq(in.peekChar, 'z')
    in = "\\".in
    verifyEq(m.readQuotedPair(in).text,"")
    verifyEq(in.peekChar, '\\')
    
    // ctext: %d33-39 / %d42-91 / %d93-126 /obs-ctext
    in = "\u0021\u0027\u002A\u005B\u005D\u007E\u0001".in
    verifyEq(m.readCtext(in).text,"\u0021\u0027\u002A\u005B\u005D\u007E")
    verifyEq(in.peekChar, '\u0001')

    in = 
"this
  is
 \t \t still
   the
 \t same
 \t\t  line
 Not any more".in
    verifyEq(m.readUnfoldedLine(in), "this is\t \t still  the\t same\t\t  line")
    verifyEq(m.readUnfoldedLine(in), "Not any more")

    // (1*([FWS] comment) [FWS]) / FWS
    in = "\t\r\n (blah)\r\n  (foo(\r\n bar)\t )Z".in
    verifyEq(m.readCfws(in).text, "\t\r\n (blah)\r\n  (foo(\r\n bar)\t )")
    verifyEq(in.peekChar, 'Z')
    in = "\t\r\n  x".in
    verifyEq(m.readCfws(in).text, "\t\r\n  ")
    verifyEq(in.peekChar, 'x')
    
    //  ** ccontent : ctext / quoted-pair / comment
    in = "abcdefg\u0001".in
    verifyEq(m.readCcontent(in).text, "abcdefg")
    verifyEq(in.peekChar, '\u0001')
    in = "\\xz".in
    verifyEq(m.readCcontent(in).text, "\\x")
    verifyEq(in.peekChar, 'z')
    in = "(abcdefg\r\n xx)z".in
    verifyEq(m.readCcontent(in).text, "(abcdefg\r\n xx)")
    verifyEq(in.peekChar, 'z')
    in = "\u0001".in
    verifyEq(m.readCcontent(in).text, "")
    verifyEq(in.peekChar, '\u0001')
    
    // ** "(" *([FWS] ccontent) [FWS] ")"
    in = "(blah\r\n \\?\r\nabcdef\r\n (blah)\r\n )z".in
    verifyEq(m.readComment(in).text, "(blah\r\n \\?\r\nabcdef\r\n (blah)\r\n )")
    verifyEq(in.peekChar, 'z')
    in = "(\r\n  (blah)\r\n\tz".in
    verifyEq(m.readComment(in).text, "")
    verifyEq(in.peekChar, '(')
    
    //  ** [CFWS] 1*atext [CFWS]
    in = "\t\r\n (blah)\r\n abcdefg\t\r\n (blah)\r\n123456789\u0001".in
    verifyEq(m.readAtom(in).text, "\t\r\n (blah)\r\n abcdefg\t\r\n (blah)\r\n123456789")
    verifyEq(in.peekChar, '\u0001')
    
    // dot-atom-text   =   1*atext *("." 1*atext)
    in = "0123?*_abcDEF578 ".in
    verifyEq(m.readDotAtomText(in).text, "0123?*_abcDEF578")
    verifyEq(in.peekChar, ' ')
    in = "0123?*_abcDEF578.".in
    verifyEq(m.readDotAtomText(in).text, "0123?*_abcDEF578")
    verifyEq(in.peekChar, '.')
    in = "0123?*_abcDEF578.az_{5.d34x ".in
    verifyEq(m.readDotAtomText(in).text, "0123?*_abcDEF578.az_{5.d34x")
    verifyEq(in.peekChar, ' ')
    in = " x".in
    verifyEq(m.readDotAtomText(in).text, "")
    verifyEq(in.peekChar, ' ')
    
    // dot-atom        =   [CFWS] dot-atom-text [CFWS]
    in = "0123?*_abcDEF578.".in
    verifyEq(m.readDotAtom(in).text, "0123?*_abcDEF578")
    verifyEq(in.peekChar, '.')
    in = "\r\n  0123?*_abc.DEF578\r\n\t ,66".in
    verifyEq(m.readDotAtom(in).text, "\r\n  0123?*_abc.DEF578\r\n\t ")
    verifyEq(in.peekChar, ',')
    
    // qcontent        =   qtext / quoted-pair
    in = "\\t.".in
    verifyEq(m.readQcontent(in).text, "\\t")
    verifyEq(in.peekChar, '.')
    in = "fdsfdsfsd#!\u0064\u0022".in
    verifyEq(m.readQcontent(in).text, "fdsfdsfsd#!\u0064")
    verifyEq(in.peekChar, '\u0022')
    
    //quoted-string   =   [CFWS] DQUOTE *([FWS] qcontent) [FWS] DQUOTE [CFWS]
    in = "\"\"z".in
    verifyEq(m.readQuotedString(in).text, "\"\"")
    verifyEq(in.peekChar, 'z')
    in = " \r\n\t \"\r\n\t dsfdsf131243\"(comment\r\n )\r\n z".in
    verifyEq(m.readQuotedString(in).text, " \r\n\t \"\r\n\t dsfdsf131243\"(comment\r\n )\r\n ")
    verifyEq(in.peekChar, 'z')

    // unstructured    =   (*([FWS] VCHAR) *WSP) / obs-unstruct
    in = " \r\n\t945qbdsff\t\r\n\t 9598409\u0055 abcdf \t \u0007".in
    verifyEq(m.readUnstructured(in).text, " \r\n\t945qbdsff\t\r\n\t 9598409\u0055 abcdf \t ")
    verifyEq(in.peekChar, '\u0007')
  }
  
}