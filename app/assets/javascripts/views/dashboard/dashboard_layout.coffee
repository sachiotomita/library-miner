class Miner.Views.DashboardLayout extends Marionette.LayoutView
  template: HandlebarsTemplates['dashboard_layout']

  regions: {
    crawlStatusRegion: "#crawl-status"
    analyzeStatusRegion: "#analyze-status"
  }

  initCrawlStatus: ->
    @crawlStatus = new Miner.Models.CrawlStatus()
    @crawlStatusView = new Miner.Views.CrawlStatusView(model: @crawlStatus)
    @crawlStatusRegion.show(@crawlStatusView)

    @crawlStatus.fetch(reset: true)

  initAnalyzeStatus: ->
    @analyzeStatus = new Miner.Models.AnalyzeStatus()
    @analyzeStatusView = new Miner.Views.AnalyzeStatusView(model: @analyzeStatus)
    @analyzeStatusRegion.show(@analyzeStatusView)

    @analyzeStatus.fetch(reset: true)


  onRender: ->
    @initCrawlStatus()
    @initAnalyzeStatus()

