// Artistic License 2.0. Thibaut Colar.
//
// History:
//   1-Mar-2011 thibautc Creation
//

**
** Test and test data for parsing email messages according to RFC 5322
**
class MsgParserTest : Test
{
  MsgParser m := MsgParser()
  
  Void testIsMethods()
  {    
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
  }
  
  Void testReaders()
  {
    in := "@,^&*(((".in
    verifyEq(m.readAtext(in), "")    
    verifyEq(in.peekChar, '@')
    in = Str<|0123?$_abcDEF578 *+.|>.in
    verifyEq(m.readAtext(in), Str<|0123?$_abcDEF578|>)
    verifyEq(in.peekChar, ' ')
    
    in = " \t z".in
    verifyEq(m.readWsp(in), " \t ")
    in = "zz".in
    verifyEq(m.readWsp(in), "")
    
    in = " \t\r\n \r\n\t \rz".in
    verifyEq(m.readFoldingWs(in)," \t\r\n \r\n\t ")
    verifyEq(in.peekChar, '\r')
    in = "\\tz".in
    verifyEq(m.readQuotedPair(in),"\\t")
    verifyEq(in.peekChar, 'z')
    in = "\\".in
    verifyEq(m.readQuotedPair(in),"")
    verifyEq(in.peekChar, '\\')
    
    // ctext: %d33-39 / %d42-91 / %d93-126 /obs-ctext
    in = "\u0021\u0027\u002A\u005B\u005D\u007E\u0001".in
    verifyEq(m.readCtext(in),"\u0021\u0027\u002A\u005B\u005D\u007E")
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

    //m.readCcontent(in)
  }
  
// ************  Test Data (From RFC 5322) *************************************  
  const Str msg := 
Str<|
     From: John Doe <jdoe@machine.example>
     To: Mary Smith <mary@example.net>
     Subject: Saying Hello
     Date: Fri, 21 Nov 1997 09:55:06 -0600
     Message-ID: <1234@local.machine.example>
     
     This is a message just to say hello.
     So, "Hello".|>

  const Str msgReply := 
Str<|
     From: Mary Smith <mary@example.net>
     To: John Doe <jdoe@machine.example>
     Reply-To: "Mary Smith: Personal Account" <smith@home.example>
     Subject: Re: Saying Hello
     Date: Fri, 21 Nov 1997 10:01:10 -0600
     Message-ID: <3456@example.net>
     In-Reply-To: <1234@local.machine.example>
     References: <1234@local.machine.example>
     
     This is a reply to your hello.|>  

  const Str msgFwd := 
Str<|
     Resent-From: Mary Smith <mary@example.net>
     Resent-To: Jane Brown <j-brown@other.example>
     Resent-Date: Mon, 24 Nov 1997 14:22:01 -0800
     Resent-Message-ID: <78910@example.net>
     From: John Doe <jdoe@machine.example>
     To: Mary Smith <mary@example.net>
     Subject: Saying Hello
     Date: Fri, 21 Nov 1997 09:55:06 -0600
     Message-ID: <1234@local.machine.example>
     
     This is a message just to say hello.
     So, "Hello".|> 

  const Str msgTrace := 
Str<|
     Received: from x.y.test
        by example.net
        via TCP
        with ESMTP
        id ABC12345
        for <mary@example.net>;  21 Nov 1997 10:05:43 -0600
     Received: from node.example by x.y.test; 21 Nov 1997 10:01:22 -0600
     From: John Doe <jdoe@node.example>
     To: Mary Smith <mary@example.net>
     Subject: Saying Hello
     Date: Fri, 21 Nov 1997 09:55:06 -0600
     Message-ID: <1234@local.node.example>
     
     This is a message just to say hello.
     So, "Hello".|>

    const Str msgComments := 
Str<|
     From: Pete(A nice \) chap) <pete(his account)@silly.test(his host)>
     To:A Group(Some people)
          :Chris Jones <c@(Chris's host.)public.example>,
              joe@example.org,
       John <jdoe@one.test> (my dear friend); (the end of the group)
     Cc:(Empty list)(start)Hidden recipients  :(nobody(that I know))  ;
     Date: Thu,
           13
             Feb
               1969
           23:32
                    -0330 (Newfoundland Time)
     Message-ID:              <testabcd.1234@silly.test>
     
     Testing.|>
}