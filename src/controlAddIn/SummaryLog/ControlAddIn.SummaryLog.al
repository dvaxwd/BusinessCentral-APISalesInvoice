controladdin "NDC-SummaryLog"{
    RequestedHeight = 700;
    RequestedWidth = 300;
    VerticalStretch = true;
    HorizontalStretch = true;

    Scripts = 'SummaryLog.js',
             'https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js';
    StyleSheets = 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css';
    StartupScript = 'SummaryLog.js';
    

    event controlReady()    

    procedure LoadSummaryData(ResultArray: Text)
}