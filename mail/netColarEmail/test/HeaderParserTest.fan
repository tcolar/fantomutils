    // Copyright : Teachscape
//
// History:
//   May 14, 2011 thibaut Creation
//

**
** HeaderParserTest
** Test Headers parsing
**
class HeaderParserTest : Test
{
  Void testHeaders()
  {
    m := MsgParser()
    p := HeadersParser(m)
    verify(p.isDtext('\u0022'))
    verify(p.isDtext('\u0077'))
    verifyFalse(p.isDtext('\u0015'))
    verifyFalse(p.isDtext('\u005B'))
    
    // domain-literal  =   [CFWS] "[" *([FWS] dtext) [FWS] "]" [CFWS]
    in := "  [ 1.2.3.245] z".in
    verifyEq(p.readDomainLiteral(in).text, "  [ 1.2.3.245] ")
    verifyEq(in.peekChar, 'z')
    
    // domain          =   dot-atom / domain-literal / obs-domain
    in = "  [ 1.2.3.245] z".in
    verifyEq(p.readDomain(in).text, "  [ 1.2.3.245] ")
    verifyEq(in.peekChar, 'z')

    in = "somserver.potato.co.uk~".in
    verifyEq(p.readDomain(in).text, "somserver.potato.co.uk")
    verifyEq(in.peekChar, '~')
    
    // addr-spec       =   local-part "@" domain
    in = "tom@foo.bar.com~".in
    verifyEq(p.readAddrSpec(in).text, "tom@foo.bar.com")
    verifyEq(in.peekChar, '~')

    in = "tom_jerry-mouse&acc@foo_bar.bar-bar.com~".in
    verifyEq(p.readAddrSpec(in).text, "tom_jerry-mouse&acc@foo_bar.bar-bar.com")
    verifyEq(in.peekChar, '~')

    in = "tom_jerry-mouse&acc@[123.234.012.123]~".in
    verifyEq(p.readAddrSpec(in).text, "tom_jerry-mouse&acc@[123.234.012.123]")
    verifyEq(in.peekChar, '~')
    
    //CFWS] "<" addr-spec ">" [CFWS] / obs-angle-addr
    in = "\t<tom_jerry-mouse&acc@[123.234.012.123]> ~".in
    verifyEq(p.readAngleAddr(in).text, "\t<tom_jerry-mouse&acc@[123.234.012.123]> ")
    verifyEq(in.peekChar, '~')
    
    //name-addr       =   [display-name] angle-addr
    in = "John Doe\t<tom_jerry-mouse&acc@[123.234.012.123]> ~".in
    verifyEq(p.readNameAddr(in).text, "John Doe\t<tom_jerry-mouse&acc@[123.234.012.123]> ")
    verifyEq(in.peekChar, '~')
    
    in = 
"Thu,
         13
           Feb
             1989
         23:32
                  -0330 (Newfoundland Time)".in
    verifyEq((p.readDateTime(in) as DateTimeMailNode)->val, DateTime.fromIso("1989-02-13T23:32:00-03:30"))
    /*in = "john@doe.com  , jerry-doe@blah.co.uk  , toto@[1.2.3.4], Dude(The) <el@duderino.com> ~".in 
    Mailbox[] boxes := p.readMailboxList(in)   
    verifyEq(in.peekChar, '~')
    verifyEq(boxes.size, 4)
    verifyEq(boxes[0].mb, "john@doe.com  ")
    verifyEq(boxes[1].mb, " jerry-doe@blah.co.uk  ")
    verifyEq(boxes[2].mb, " toto@[1.2.3.4]")
    verifyEq(boxes[3].mb, " Dude(The) <el@duderino.com> ")*/
}
}
