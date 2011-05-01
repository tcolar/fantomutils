//
// History:
//   Apr 29, 2011 thibaut Creation
//

**
** Settings
** Allows for Easy, documented settings files
** 
** All fields with the Facet "Setting" will be saved (using serialization: writeObj/ReadObj)
** Fields with rge Setting Facet can NOT be nullable.
** If there is a default value it will be displayed as well (as a comment in saved file)
** Note: It even works with "Complex" serialized obects, although it is less user friendly (better to stick to "simples")
**
abstract class Settings
{
  ** Line comment char (default: #)
  virtual Str commentChar := "#"

  ** Comments to show at the top of the file
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
    defVal := field.get(this.typeof.make)
    if( defVal != null )
    {
      lines.add("$commentChar Default value : " + serializeOneLine(defVal))        
    }
    val := field.get(this)
    if(val != null)
    {
      lines.add("$field.name = " + serializeOneLine(field.get(this)))
    }
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
    fields := Type.of(this).fields.findAll |f| { f.hasFacet(Setting#) }
    fields.each |field| 
    {
      if(field.type.isNullable)
        throw Err("Setting Facet can only be used on non nullable fields. Nullable : $field.qname")
    }
    return fields
  }      
}

** Facet for a specific setting
** NOTE: Not allowed on Nullables
facet class Setting
{
  ** Help/comments about this Setting (lines of text) will show as comments
  const Str[] help := [,]

  ** Can be used to categorize the settings when presenting them to the user in a settings UI
  ** Default:Null (none)
  ** Does NOT show in the saved settings file
  const Str? category  
}