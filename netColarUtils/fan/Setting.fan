// History:
//  Jan 12 13 tcolar Creation
//

** Facet for a specific setting
** NOTE: Not allowed on Nullables
** Settings fields MUST be Serializable
facet class Setting
{
  ** Help/comments about this Setting (lines of text) will show as comments
  const Str[] help := [,]

  ** Can be used to categorize the settings when presenting them to the user in a settings UI
  ** Default:Null (none)
  ** Does NOT show in the saved settings file
  const Str? category
}