// History:
//   May 13, 2011 thibaut Creation
//

**
** MailNode
** Parsed Mail nodes (see parsers)
**
const class MailNode
{
  const Str text
  const MailNodes kind
  const MailNode[] children
  
  ** Make the node from a list of children
  ** Node text will be set to concatenation of all chidren text  
  new make(MailNodes kind, MailNode[] children)
  {
    str := ""
    items := [,]
    children.each |child|
    {
      if(! child.isEmpty)
      {
        items.add(child)
        str += child.text
      }
    }
    this.text = str
    this.children = items
    if(this.children.isEmpty)
    {
      this.kind = MailNodes.EMPTY
    }
    else
    {
      this.kind = kind      
    }
    
  }

  ** A leaf node (text only, no children)
  new makeLeaf(MailNodes kind, Str text)
  {
    this.text = text
    this.children = [,]
    if(text.isEmpty)
    {
      this.kind = MailNodes.EMPTY
    }
    else
    {
      this.kind = kind      
    }
  }
  
  Bool isEmpty()
  {
    return kind == MailNodes.EMPTY
  }    
}

** Parse tree utilities
class MailNodeUtils
{
  ** Recursively print a node tree
  static Void print(MailNode node, Str indent := "")
  {
    echo("${indent}-ND: $node.kind -> $node.text")
    indent += " "
    node.children.each |nd| 
    {
      print(nd, indent)
    }
  }
}

** enum of Mail node types
enum class MailNodes
{
  EMPTY, // Special Value for when the match failed.
  
  MSGROOT,
  BODY,
  HEADERS,
  HEADER,
  HEADERNAME,
  MAILBOX,
  MAILBOXLIST,
  
  COMMENT, 
  FWS, // folding white space  
  CFWS, // comment of fws
  QTEXT,
  QCONTENT,
  PHRASE,
  WORD,
  ATEXT,
  CTEXT,
  WSP, // white space
  CCONTENT,
  DOTATOM,
  DOTATOMTEXT,
  QUOTEDPAIR,
  ATOM,
  COMMENTS,
  QUOTEDSTRING,
  VCHAR,
  UNSTRUCTURED,
  DTEXT,
  DOMAINLITERAL,
  DOMAIN,
  LOCALPART,
  ADDRSPEC,
  DISPLAYNAME,
  ANGLEADDR,
  NAMEADDR,
  
  // Leafs
  AT, // @
  BRACKET, // []
  ANGLE, // <>
  DOT, // .
  COMMA, //,
  PAR, // ()
  QUOTE // "
}