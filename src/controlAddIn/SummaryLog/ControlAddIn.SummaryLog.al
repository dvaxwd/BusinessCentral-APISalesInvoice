controladdin "NDC-SummaryLog"{
    RequestedHeight = 480;
    RequestedWidth = 300;
    VerticalStretch = true;
    HorizontalStretch = true;

    Scripts = 'SummaryLog.js',
             'https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js',
             'https://cdn.jsdelivr.net/npm/chart.js';
    StyleSheets = 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css';
    StartupScript = 'SummaryLog.js';
    

    event controlReady()
    event OnYearSelected(YearText: Text)
    event OnMonthSelected(MonthText: Text)

    procedure LoadSummaryData(ResultArray: Text)
    procedure LoadSummaryApplyFilter(ResultArray: Text)
    procedure LoadPieChartApplyFilter(ResultArray: Text)
}