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
using gfx

**
** ServerService
**
class ServerService : AbstractMain
{
  @Opt { help = "http port" }
  Int port := 8480

  override Int run()
  {
    pipeline := PipelineMod
    {
      // pipeline steps
      steps =
      [
        RouteMod
        {
          routes =
          [
            "index": ShowIndex(),
            "pod":   ServerMod(),
          ]
        }
      ]
    }

    // run WispService
    return runServices([ WispService { it.port = this.port; root = pipeline } ])
	}
}

const class ServerMod : WebMod
{
  override Void onGet()
  {
      File file := ("fan://" + req.uri[1..-1]).toUri.get
      if (!file.exists) { res.sendErr(404); return }
      FileWeblet(file).onService
  }

  override Void onPost()
  {
    super.onPost
  }
}

const class ShowIndex : WebMod
{
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
  /*LogDataTableModel model1 := LogDataTableModel
					{
						it.title="Dummy"
						formatedKeys = ["jan":"jan", "feb":"feb","mar":"mar","april":"april"]
						data = ["jan":1256, "feb":756, "mar":3456, "april":1728]
					}
WebUtil.jsMain(out, HistogramRenderer(model1, Size(300, 200)))*/
      WebUtil.jsMain(out, "netColarLogStats::TestWindow")
    out.headEnd
    out.body
    out.h2.w("hello").h2End
    out.bodyEnd
    out.htmlEnd
  }

}

@Js
class TestWindow : Window
{
  ** Dummy test data
  LogDataTableModel model1 := LogDataTableModel
					{
						it.title="Dummy"
						formatedKeys = ["jan":"jan", "feb":"feb","mar":"mar","april":"april"]
						data = ["jan":1256, "feb":756, "mar":3456, "april":1728]
					}

  new make() : super(null, null)
  {
    content = GridPane
	{
		GridPane
		{
            numCols = 3 //-> causes Uncaught sys::IndexErr: 1 sys.js:2705
			HistogramRenderer(model1, Size(300, 200)),
			LineGraphRenderer(model1, Size(300, 200)),
			PieGraphRenderer(model1, Size(300, 200)),
		},
	}
  }

  Void main()
  {
    open
  }
}