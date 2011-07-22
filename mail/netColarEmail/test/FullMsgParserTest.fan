// Copyright : Teachscape
//
// History:
//   May 8, 2011 thibaut Creation
//

**
** FullMsgParserTest
** Test parsing of full messages
**
class FullMsgParserTest : Test
{
  Void testMessages()
  {
    parser := MsgParser()
    MailNode root := parser.readMessage(msg.in)
    MailNodeUtils.print(root)
    root = parser.readMessage(msgReply.in)
    MailNodeUtils.print(root)
    root = parser.readMessage(msgFwd.in)
    MailNodeUtils.print(root)
    root = parser.readMessage(msgTrace.in)
    MailNodeUtils.print(root)
    root = parser.readMessage(msgComments.in)
    MailNodeUtils.print(root)
  }
  
  
  // ************  Test Data (From RFC 5322) *************************************  
  const Str msg := 
Str<|From: John Doe <jdoe@machine.example>
     To: Mary Smith <mary@example.net>
     Subject: Saying Hello
     Date: Fri, 21 Nov 1997 09:55:06 -0600
     Message-ID: <1234@local.machine.example>
     
     This is a message just to say hello.
     So, "Hello".|>

  const Str msgReply := 
Str<|From: Mary Smith <mary@example.net>
     To: John Doe <jdoe@machine.example>
     Reply-To: "Mary Smith: Personal Account" <smith@home.example>
     Subject: Re: Saying Hello
     Date: Fri, 21 Nov 1997 10:01:10 -0600
     Message-ID: <3456@example.net>
     In-Reply-To: <1234@local.machine.example>
     References: <1234@local.machine.example>
     
     This is a reply to your hello.|>  

  const Str msgFwd := 
Str<|Resent-From: Mary Smith <mary@example.net>
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
Str<|Received: from x.y.test
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
Str<|From: Pete(A nice \) chap) <pete(his account)@silly.test(his host)>
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
