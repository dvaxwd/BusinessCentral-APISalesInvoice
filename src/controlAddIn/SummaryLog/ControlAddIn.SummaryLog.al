controladdin "NDC-SummaryLog"{
    RequestedHeight = 1440;
    RequestedWidth = 300;
    VerticalStretch = true;
    HorizontalStretch = true;

    Scripts = 'SummaryLog.js',
             'https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js',
             'https://cdn.jsdelivr.net/npm/chart.js',
             'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js';
    StyleSheets = 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css',
                'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css', 
                'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css';
    StartupScript = 'SummaryLog.js';
    

    event controlReady()
    event OnYearSelected(YearText: Text)
    event OnMonthSelected(MonthText: Text)
    event OpenInvoice(InvoicceNo: Text);

    procedure LoadSummaryData(ResultArray: Text; failSummary: Text; lastUpdate: Text)
    procedure LoadSummaryApplyFilter(ResultArray: Text; lastUpdated: Text)
    procedure LoadPieChartApplyFilter(ResultArray: Text)
    procedure LoadFailReasonCardApplyfilter(ResultArray: Text)
    procedure showMap(ResultArray: Text);
    procedure LoadInvoiceTable(ResultArray: Text)
}