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
  
  new make(MailNodes kind, Str text, MailNode[] children)
  {
    this.text = text
    this.kind = kind
    this.children = children
    if(text.isEmpty)
    {
      this.kind = MailNodes.EMPTY
    }
  }
  
  Bool isEmpty()
  {
    return kind == MailNodes.EMPTY
  }  
}

** enum of token types
enum class MailNodes
{
  EMPTY, // Special Value for when the match failed.
  COMMENT, 
  FWS // folding white space  
}