//
// History:
//   Apr 29, 2011 thibaut Creation
//

**
** Settings
** Allows for Easy, documented settings files
**
abstract class Settings
{
  ** Comments to show at the top of the file
  virtual Str[] headComments := [,]
  
  ** Load the settings from a stream/file
  Void read(InStream in)
  {
    
  } 

  ** If out=null, save where it was read from
  ** Closes the stream when done
  Void save(OutStream? out := null)
  {
    now := DateTime.now
    try
    {
    headComments.each |str| 
    {
      out.printLine("## $str")
    }
    out.printLine
    getSettingFields.each |field| 
    {
      setting := field.facet(Setting#) as Setting
      setting.help.each |str| 
      {
        out.printLine("# $str")
      }
      if( ! setting.defaultVal.isEmpty)
      {
        out.printLine("# Default value : $setting.defaultVal")        
      }
    }
    }
    catch(Err e)
    {
      throw(e)
    }
    finally
    {
      out.close
    }
  }
  
  internal Field[] getSettingFields()
  {
    Type.of(this).fields.findAll |f| { f.hasFacet(Setting#) }
  }      
}

** Facet for a specific setting
facet class Setting
{
  ** Help/comments about this Setting (lines of text) will show as comments
  const Str[] help := [,]

  ** Default value (empty string for none)
  const Str defaultVal := ""  
}