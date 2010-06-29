// Artistic License 2.0
// History:
//   Jun 14, 2010 thibautc Creation
//
using wisp
using web
using webmod
using util
using fwt
using gfx
using dom

**
** ServerService
**
class ServerService : AbstractMain
{
  @Opt { help = "http port" }
  Int port := 8580

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
			"data": ServeData(),
          ]
        }
      ]
    }

    // run WispService
    return runServices([ WispService { it.port = this.port; root = pipeline } ])
	}
}

** Serve pod resources
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

** Render Index page
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
      //out.includeJs(`/pod/sys/sys.js`)
      out.includeJs(`http://127.0.0.1/sys.js`)
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
      WebUtil.jsMain(out, "netColarLogStats::TestWindow")
    out.headEnd
    out.body
	out.w("Fetching data ...")
    out.bodyEnd
    out.htmlEnd
  }
}

** Send serialized log data (ajax)
const class ServeData : WebMod
{
  override Void onGet()
  {
  // test data for now
  LogDataTableModel model1 := LogDataTableModel
					{
						it.title="Stats"
						data = [
								LogDataPoint("jan","Januanry",1256),
								LogDataPoint("feb","February",756),
								LogDataPoint("mar","March",1723),
								LogDataPoint("apr","April",1526),
								LogDataPoint("may","May",532),
						]
					}
    // send the data
    res.headers["Content-Type"] = "text/text"
    out := res.out
	out.writeObj(model1)
  }
}

** Generated component of index page
@Js
class TestWindow : Window
{
  new make() : super(null, null)
  {
	LogDataTableModel? model1
	ajax := HttpReq { uri=`/data`; async = false}
	ajax.get |res| {model1 =  res.content.in.readObj}

	Win.cur.alert(model1);

    content = GridPane
	{
		GraphPane(model1, Size(500, 250)),
		GraphPane(model1, Size(500, 250)),
	}
  }

  Void main()
  {
    open
  }
}