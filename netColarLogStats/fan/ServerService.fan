// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 14, 2010 thibautc Creation
//
using wisp
using web
using webmod
using util
using fwt
using netColarDb
using sql

**
** ServerService
**
class ServerService : AbstractMain
{
  @Opt { help = "http port" }
  Int port := 8480

  override Int run()
  {
    wisp := WispService
    {
      it.port = this.port
      it.root = ServerMod()
    }
    return runServices([wisp])
  }

}

const class ServerMod : WebMod
{
  override Void onGet()
  {
    name := req.modRel.path.first
    if (name == "pod")
    {
      File file := ("fan://" + req.uri[1..-1]).toUri.get
      if (!file.exists) { res.sendErr(404); return }
      FileWeblet(file).onService
    }
    else
      ShowScript().onGet
  }

  override Void onPost()
  {
    super.onPost
  }
}

class ShowScript : Weblet
{
  new make() {}
  override Void onGet()
  {
    // write page
    res.headers["Content-Type"] = "text/html"
    out := res.out
    out.docType
    out.html
    out.head
      out.title.w("Log stats viewer").titleEnd
      out.includeJs(`/pod/sys/sys.js`)
      out.includeJs(`/pod/concurrent/concurrent.js`)
      out.includeJs(`/pod/web/web.js`)
      out.includeJs(`/pod/gfx/gfx.js`)
      out.includeJs(`/pod/dom/dom.js`)
      out.includeJs(`/pod/fwt/fwt.js`)
      out.includeJs(`/pod/netColarLogStats/netColarLogStats.js`)
      out.style.w(
       "body { font: 10pt Arial; }
        a { color: #00f; }
        ").styleEnd
      //out.script.w(js).scriptEnd
      WebUtil.jsMain(out, "netColarLogStats::LogWindow.main")
    out.headEnd
    out.body
    out.bodyEnd
    out.htmlEnd
  }

}
