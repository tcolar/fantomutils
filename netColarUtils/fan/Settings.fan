//
// History:
//   Apr 29, 2011 thibaut Creation
//

**
** Settings
** Allows for Easy, documented settings files
**
** All fields with the Facet "Setting" will be saved (using serialization: writeObj/ReadObj)
** Fields with the Setting Facet can NOT be nullable.
** If there is a default value it will be displayed as well (as a comment in saved file)
** Note: It even works with "Complex" serialized obects, although it is less user friendly (better to stick to "simples")
**
final class SettingUtils
{
  ** Line comment char (default: #)
  Str commentChar := "#"

  ** Comments to show at the top of the file
  ** commentChar  will be prepanded to each line
  Str[] headComments := [,]

  ** Comments to show at the bottom of the file
  ** commentChar will be prepanded to each line
  Str[] tailComments := [,]

  new make(|This| f) { f(this) }
  new makeDefault() {}

  ** Load the settings from a stream/file nd inject the into a new object of given type
  ** the type muts have an it constructor ! new make(|This| f) {f(this)}
  Obj? read(Type type, InStream in)
  {
    [Field:Obj?] fieldMap := [:]
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
          field := type.field(key, false)
          if(field!=null)
          {
            if(field.isConst)
              val = val.toImmutable
            fieldMap[field] = val
          }
          else
            echo("Unknow field: ${key}. Ignoring it.")
        }
      }
    }
    return type.make([Field.makeSetFunc(fieldMap)])
  }

  ** Try to save the file "in place"
  ** Not touching existing comment lines
  ** If the file does not exist then it just calls save()
  Void update(Obj o, File f)
  {
    if( ! f.exists)
    {
      save(o, f.out)
      return
    }

    Str[] lines := f.readAllLines
    getSettingFields(o).each |field|
    {
      key := field.name
      regex := Regex.fromStr(Str<|^\W*|> + key + Str<|\W*=.*|>)
      setting := field.facet(Setting#) as Setting
      index := lines.findIndex |line -> Bool| { return regex.matches(line) }
      if( index != null )
      {
        // replace just this line with the new value
        val := serializeOneLine(field.get(o))
        lines[index] = "$key = $val"
      }
      else
      {
        // Missing/New item -> adding at the end
        lines.add("")
        lines.addAll(getFieldText(o, field))
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
  Void save(Obj o, OutStream out)
  {
    now := DateTime.now
    try
    {
      headComments.each |str|
      {
        out.printLine("${commentChar}${commentChar} $str")
      }
      out.printLine
      getSettingFields(o).each |field|
      {
        getFieldText(o, field).each |line|
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
  private Str[] getFieldText(Obj o, Field field)
  {
    lines := Str[,]
    setting := field.facet(Setting#) as Setting
    setting.help.each |str|
    {
      lines.add("$commentChar $str")
    }
    val := field.get(o)
    if(val != null)
    {
      lines.add("$field.name = " + serializeOneLine(field.get(o)))
    }
    return lines
  }

  ** Serialize the object as one line
  ** It might look a bit funny ... but it's useable
  private Str serializeOneLine(Obj obj)
  {
    Str result := ""
    lines := Buf().writeObj(obj).flip.readAllLines
    lines.each |line|
    {
      last := result.isEmpty ? null : result[-1]
      if(! (last==null || line.startsWith("{") || line.startsWith("}") || last == '}' || last == '{' || last==';'))
        result += ";"
      result += line
    }
    return result
  }

  ** Get all the fields with a Setting facet
  private Field[] getSettingFields(Obj o)
  {
    fields := Type.of(o).fields.findAll |f| { f.hasFacet(Setting#) }
    fields.each |field|
    {
      if(field.type.isNullable)
        throw Err("Setting Facet can only be used on non nullable fields. Nullable : $field.qname")
    }
    return fields
  }

 ** Load settings from a file into given type
  static Obj? load(File file, Type type, Bool createIfMissing := true)
  {
    SettingUtils settings := SettingUtils()
    Obj? obj
    if(! file.exists)
      settings.save(type.make, file.out)
    try
    {
      obj = settings.read(type, file.in)
      // always update as to merge possible new settings
      settings.update(obj, file)
    }
    catch (Err e)
      echo("ERROR: Cannot load $file\n $e")
    if(obj == null)
    {
      obj = type.make
    }
    return obj
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