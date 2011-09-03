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
  const Str rawText
  const MailNodes kind
  const MailNode[] children
  
  ** Make the node from a list of children
  ** Node text will be set to concatenation of all chidren text  
  new make(MailNodes kind, MailNode[] children)
  {
    raw := ""
    txt := ""
    kids := [,]
    Bool isEmpty := true
    children.each |child|
    {
      if(! child.isEmpty)
      {
        // Only keep meaninful nodes
        if(child.kind.name.startsWith("T_"))
        {
            kids.add(child)
        }  
        // text does need keep comments, folding white space and junk like that
        if( ! child.kind.name.startsWith("R_"))
        {
            txt += child.text
        }  
        
        raw += child.text
        isEmpty = false
      }
    }
    if(isEmpty)
    {
      this.kind = MailNodes.EMPTY
    }
    else
    {
      this.kind = kind      
    }
    
    this.children = kids
    this.text = txt
    this.rawText = raw
  }

  ** A leaf node (text only, no children)
  new makeLeaf(MailNodes kind, Str text)
  {
    this.text = text
    this.rawText = kind.name.startsWith("R_") ? "" : text
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

** secialized node for a datetime
const class DateTimeMailNode : MailNode
{
  const DateTime val
  
  new make(Str text, DateTime dateTime) : super.makeLeaf(MailNodes.T_DATETIME, text)
  {
    val = dateTime
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
  // top level nodes (keepers)
  T_MSGROOT,
  T_BODY,
  T_HEADERS,
  T_HEADER,
  T_HEADERNAME,
  T_MAILBOX,
  T_MAILBOXLIST,
  T_ADDRESS,
  T_GROUP,
  T_ADDRESSLIST,
  T_BCC,
  T_MSGID,
  T_KEYWORDS,
  T_MSGIDS,
  T_NAMEADDR,
  T_DATETIME,
  T_UNSTRUCTURED,
  T_ADDRSPEC,
  T_DISPLAYNAME,
  T_ANGLEADDR,
  
  // removed from clean Text
  R_COMMENT, 
  R_FWS, // folding white space  
  R_CFWS, // comment of fws
  
  // Low level nodes (details))
  EMPTY, // Special Value for when the match failed.
  
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
  QUOTEDSTRING,
  VCHAR,
  DTEXT,
  DOMAINLITERAL,
  DOMAIN,
  LOCALPART,
  IDRIGHT,
  IDLEFT,
  NOFOLDLITERAL,
  
  // Leafs
  AT, // @
  BRACKET, // []
  ANGLE, // <>
  DOT, // .
  COMMA, //,
  PAR, // ()
  QUOTE, // "
  COLON // :
}
