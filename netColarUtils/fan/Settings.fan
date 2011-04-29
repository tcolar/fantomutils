//
// History:
//   Apr 29, 2011 thibaut Creation
//

**
** Settings
** Allows for Easy, documented settings files
** 
** All fields with the Facet "Setting" will be saved (using serialization: writeObj/ReadObj)
** Note: It even works with "Complex" serialized obects, although it is less user friendly (better to stic to "simples")
**
abstract class Settings
{
  ** Line comment char (default: #)
  virtual Str commentChar := "#"

  **   ** Comments to show at the top of the file
  ** commentChar  will be prepanded to each line
  virtual Str[] headComments := [,]

  ** Comments to show at the bottom of the file
  ** commentChar will be prepanded to each line
  virtual Str[] tailComments := [,]  
    
  ** Load the settings from a stream/file
  Void read(InStream in)
  {
    in.eachLine |Str line| 
    {
      if( ! line.isEmpty && ! line.startsWith(commentChar))
      {
        idx := line.index("=")
        if(idx > 0)
        {
          key := line[0 ..< idx].trim
          Obj val := ""
          if( idx < line.size )
          {
            val = line[idx + 1 .. -1].trim.in.readObj
          }  
          field := Type.of(this).field(key, false)
          if(field!=null)
            field.set(this, val)  
          else
            echo("Unknow field: ${key}. Ignoring it.")      
        }
      }
    }
  } 

  ** Try to update the file "in place"
  ** Not touching existing comment lines
  ** If the file does not exist then it just calls save()
  ** 
  Void update(File f)
  {
    if( ! f.exists)
    {
      save(f.out)
      return
    }
    
    Str[] lines := f.readAllLines 
    getSettingFields.each |field| 
    {
      key := field.name
      regex := Regex(Str<|^\W*|> + key + Str<|\W*=.*|>)
      setting := field.facet(Setting#) as Setting
      index := lines.findIndex |line -> Bool| { return regex.matches(line) }
      if( index != null )
      {
        // replace just this line with the new value
        val := serializeOneLine(field.get(this))
        lines[index] = "$key = $val"
      }
      else
      {
        // Missing/New item -> adding at the end
        lines.add("")
        lines.addAll(getFieldText(field))
      }
    }
    
    // Save the file
    out := f.out
    try
    {
      lines.each |line| { out.printLine(line) }
      out.sync
    }
    catch(Err e) {e.trace}
    finally
    {
      out.close
    }
  }
    
  ** Save the settings (complete overwrite)
  ** Closes the stream when done
  Void save(OutStream out)
  {
    now := DateTime.now
    try
    {
      headComments.each |str| 
      {
        out.printLine("${commentChar}${commentChar} $str")
      }
      out.printLine
      getSettingFields.each |field| 
      {
        getFieldText(field).each |line| 
        {
          out.printLine(line)
        }
        out.printLine
      }
      tailComments.each |str| 
      {
        out.printLine("${commentChar}${commentChar} $str")
      }
      out.sync
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
  
  ** Get the settings line for a field
  private Str[] getFieldText(Field field)
  {
    lines := Str[,]
    setting := field.facet(Setting#) as Setting
    setting.help.each |str| 
    {
      lines.add("$commentChar $str")
    }
    if( ! (setting.defaultVal is Str) || ! (setting.defaultVal as Str).isEmpty )
    {
      defVal := serializeOneLine(setting.defaultVal)
      lines.add("$commentChar Default value : $defVal")        
    }
    val := serializeOneLine(field.get(this))
    lines.add("$field.name = $val")
    return lines
  }
  
  ** Serialize the object as one line
  ** It might look a bit funny ... but it's useable
  private Str serializeOneLine(Obj obj)
  {
    return Buf().writeObj(obj).flip.readAllLines.join(";")
  }
  
  ** Get all the fields with a Setting facet
  private Field[] getSettingFields()
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
  ** Will be shown in comments as well
  const Obj defaultVal := ""  
}