// History:
//   11 13 12 Creation

**
** FileUtils
**
class FileUtils
{
  static const Str[] knownTextExts := ["fan", "axon", "htm", "html", "css", "js", "cs",
  "properties", "props", "md", "txt", "java", "fog", "cpp", "bat", "sh", "h", "xml",
  "json", "c", "php", "fwt", "fandoc", "log", "csv", "markdown", "rdf", "settings",
  "mustache", "sql", "patch", "dtd", "conf", "py", "go", "ruby", "ini"]

  static const Str[] knownBinExts := ["pod", "zip", "class", "png", "jpg", "jpeg", "gif",
  "obj", "dll", "exe", "jar", "ico", "rar", "tgz", "gz", "tar.gz", "bin", "debug", "pdf", "bmp",
  "7z", "pyc", "xlsx", "doc", "ppt"]

  ** Other common text chars that are not alpha numeric
  static const Str textChars := "\t {}[]~`!@#\$%^&*()-_=+:;\"'<>?,./"

  ** Create a directory along with whatever parent directories are needed
  static Void mkDirs(Uri dir)
  {
    if(!dir.isDir)
      dir= dir.plusSlash
    f := File(dir)
    if(! f.exists)
    {
      mkDirs(dir.parent)
      f.create()
    }
  }

  static Bool isTextFile(File? f, Int maxSize := 99000)
  {
    tf := _isTextFile(f, maxSize)
    /*if(tf)
      echo("*TEXT $f.osPath")
    else
      echo("~BIN~ $f.osPath")*/
    return tf
  }

  ** Try to determin is a file is text
  ** If fie size is > maxSize then wil be considered bn automatically
  static Bool _isTextFile(File? f, Int maxSize := 99000)
  {
    // sanity checks
    if(f==null || f.isDir || ! f.exists)
      return false

    // too big?
    if(f.size > maxSize) return false

    // Check known common file types for fantom projects
    if(f.ext != null)
    {
      if(knownTextExts.contains(f.ext)) return true
      if(knownBinExts.contains(f.ext)) return false
    }

    // Chek if a mime type is present and it think it's text
    if (f.mimeType != null && f.mimeType.mediaType == "text") return true

    // alright, at this point we don't know, so we will try to have a look
    in := f.in
    try
    {
      lines := 0
      txtLines := 0;
      Str? line := ""
      while((line = in.readLine(999)) != null && lines < 5)
      {
        lines++
        txtLines += isTextLine(line) ? 1 : 0
      }
      return lines != 0 && (txtLines * 100) / lines > 50
    }
    catch(Err e)
    {
      e.trace
      // if reading failed, then it's probably binary / invalid encoding
      return false
    }
    finally
    {
      in.close
    }

    return false
  }

  static Bool isTextLine(Str? line)
  {
    // if null line or line too long, probaby not a text file
    if(line.size > 500) return false
    // starts with empty line -> probably text file
    if(line.size == 0) return true
    // Still don't know then check if it looks like text
    count := 0
    line.each |char|{
      if(char.isAlphaNum || textChars.contains(char.toChar)) count++
    }
    // if at least 90% alphanum then consider text file
    return (count==0 || count * 100 / line.size < 90) ? false : true
  }
}