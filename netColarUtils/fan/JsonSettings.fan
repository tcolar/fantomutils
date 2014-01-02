// History:
//  Jan 12 13 tcolar Creation
//

using util

**
** JsonSettings
**
** Allows for Easy, documented settings files
**
** Settings will be saved in property file like file but with comments and values in Json format
**
** All fields in the saved object with the Facet "Setting" will be saved (Json format)
** Fields with the Setting Facet can NOT be nullable.
** If a field has a default value it will be displayed as well (as a comment in saved file)
**
final class JsonSettings
{
  ** Line comment char (default: #)
  Str commentChar := "#"

  ** Comments to show at the top of the file
  ** commentChar  will be prepanded to each line
  Str[] headComments := ["This is a setting files. The format is key = value",
  "where the value is formatted in JSON format."]

  new make(|This| f) { f(this) }

  ** Load the settings from a stream/file and inject them into a new object of given type
  ** the type must have an it constructor => new make(|This| f) {f(this)}
  ** Might throw an Err if parsing fails
  Obj? read(Type type, InStream in)
  {
    [Field:Obj?] fieldMap := [:]

    while(true)
    {
      consumeWs(in)
      c := in.peek
      if(c == null) break // done
      else if(c?.toChar == commentChar) in.readLine // skip comment line
      else
      {
        name := readProp(in)
        if( ! name.isEmpty)
        {
          consumeWs(in)
          field := type.field(name, false)
          if(field != null)
          {
            val := JsonUtils.load(in, field.type, false)
            if(field.isConst)
              val = val.toImmutable
            fieldMap[field] = val
          }
          else
          {
            // read and drop it
            JsonInStream(in).readJson
          }
        }
      }
    }
    return type.make([Field.makeSetFunc(fieldMap)])
  }

  Str readProp(InStream in)
  {
    Str name := ""
    while(true)
    {
      c := in.readChar
      if(c!=null && c.isSpace) continue
      else if(c!= null && (c.isAlphaNum || c=='_')) name += c.toChar
      else if(c == '=') break
      else throw Err("Unexpected character '${c?.toChar}' after $name")
    }
    return name
  }

  ** consume white space, returns next (non-ws) char
  Str consumeWs(InStream in)
  {
    Str ws := ""
    while(true)
    {
      c := in.peekChar
      if(c == null) return ws
      if(c.isSpace || c == '\n' || c == '\r')
        ws += in.readChar.toChar
      else break
    }
    return ws
  }

  ** Try to save the file "in place" so that if use reordered or added comments
  ** we leave those alone.
  ** Will remove props that are no longer present and add new ones with default vals.
  ** If the file does not exist yet, then it just calls save()
  Void update(Obj o, File f)
  {
    if( ! f.exists)
    {
      save(o, f.out)
      return
    }

    fields := getSettingFields(o)

    in := f.in
    content := StrBuf()
    Str[] updated := [,]
    while(true)
    {
      content.add(consumeWs(in))
      c := in.peekChar
      if(c == null) break
      else if(c.toChar == commentChar)
      {
        content.add(in.readLine+consumeWs(in))
        if(in.peekChar != null) content.add("\n")
      }
      else
      {
        prop := readProp(in)
        if(! prop.isEmpty)
        {
          // read current value but discard it
          spacing := consumeWs(in)
          JsonInStream(in).readJson
          // If the setting no longer exists, drop it
          field := fields.find {it.name == prop}
          if(field != null)
          {
            // write the updated setting
            updated.add(prop)
            content.add("$prop =$spacing")
            buf := StrBuf()
            JsonUtils.save(buf.out, field.get(o), false)
            content.add(buf.toStr + "\n")
          }
        }
      }
    }
    in.close

    // Save the file
    out := f.out
    try
    {
      out.printLine(content)
      // add any new settings at end of file
      fields.each
      {
        if( ! updated.contains(it.name))
        {
          getFieldText(o, it).each |line| {out.printLine(line)}
        }
      }
      out.flush
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

  ** Add any new setting to the end of the file but leave rest alone
  private Void addMissingSettings(Obj o, File f)
  {
    fields := getSettingFields(o)
    regex := Regex.fromStr(Str<|\W*(\w+)\W*=.*|>)
    names := [,]
    f.readAllLines.each
    {
      matcher := regex.matcher(it)
      if(matcher.matches)
        names.add(matcher.group(1))
    }

    fields.each
    {
      if( ! names.contains(it.name))
        f.out(true).printLine.printLine(getFieldText(o, it).join("\n")).close
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
      buf := StrBuf()
      JsonUtils.save(buf.out, val, false)
      lines.add("$field.name = $buf")
    }
    return lines
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
  static Obj? load(File file, Type type)
  {
    JsonSettings settings := JsonSettings {}
    Obj? obj
    if(! file.exists)
      settings.save(type.make([Field.makeSetFunc([:])]), file.out)
    try
    {
      obj = settings.read(type, file.in)
      // add any missing settings at end of file
      settings.addMissingSettings(obj, file)
    }
    catch (Err e)
    {
      echo("ERROR: Cannot load $file\n $e")
      e.trace
    }
    if(obj == null)
    {
      obj = type.make
    }
    return obj
  }

}