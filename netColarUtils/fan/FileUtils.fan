// History:
//   11 13 12 Creation

**
** FileUtils
**
class FileUtils
{
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
}
