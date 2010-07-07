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
using sql

**
** ServerService
** Entry point of the application, starts the server(WISP) and handles requests
**
class ServerService : AbstractMain
{
  @Opt { help = "http port" }
  Int port := 8580
  SqlService db

  new make(SqlService db)
  {
	this.db = db
  }

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
			"data": ServeData(db),
          ]
        }
      ]
    }

    // run WispService
    return runServices([ WispService { it.port = this.port; root = pipeline } ])
	}
}

** Serve fantom pod resources
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

** Render custom Index page
const class ShowIndex : WebMod
{
  override Void onGet()
  {
	main := "netColarLogStats::TestWindow"

    // write page
    res.headers["Content-Type"] = "text/html"
    out := res.out
    out.docType
    out.html
    out.head
      out.title.w("Log stats viewer").titleEnd
      //out.includeJs(`/pod/sys/sys.js`)
      out.includeJs(`http://127.0.0.1/sys.js`) // TODO: temp (has fix for http://hg.fandev.org/fan-1.0/rev/77f2fce9452d )
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
      WebUtil.jsMain(out, main)
    out.headEnd
    out.body
    out.bodyEnd
    out.htmlEnd
  }
}

** Send serialized log data (ajax)
const class ServeData : WebMod
{
	const SqlService db

	new make(SqlService db)
	{
		this.db = db
	}

  override Void onPost()
  {
	logReq := LogQueryRequest.fromStr(req.in.readAllStr)
	
	// Db need to be opened by each thread
	db.open
	LogDataTableModel model1 := LogStatQuery.fetchData(db, logReq)
	db.close
    // send the data
    res.headers["Content-Type"] = "text/text"
    out := res.out
	out.writeObj(model1)
  }
}

** Generated main component of index page
@Js
class TestWindow : Window
{
	internal const Int baseWidth := 700

  new make() : super(null, null)
  {
	view := LogHitsView()

	content = ScrollPane
    {
    InsetPane
    {
      GridPane
      {
		numCols = 2
		expandCol = 1
		valignCells = Valign.top
		hgap = 25
		BorderPane{
          insets = Insets(10)
          border = Border("2 #008 10")
          bg = Color("#9999ff")
          GridPane
          {
			Button{text="My Favorites"},
			Button{text="Live Stats"},
			Button{text="Total Hits"},
			Button{text="Top Pages"},
			Button{text="Top Referers"},
          },
        },

		view.viewPane,
	  },
      },
    }
	view.fetchData
  }

  Void main()
  {
    open
  }
}