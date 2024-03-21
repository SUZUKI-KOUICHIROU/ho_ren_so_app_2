module Projects::ReportsHelper
  # タブごとのページ設定
  def report_page(tab)
    page = {
      'you-report' => 'you_reports_page',
      'report' => 'reports_page',
      'all-report' => 'all_reports_page'
    }
    page[tab]
  end
end
