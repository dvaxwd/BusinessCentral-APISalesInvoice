controladdin "NDC-InteractiveMap"{
    RequestedWidth = 480;
    RequestedHeight = 480;
    VerticalStretch = true;
    HorizontalStretch = true;

    Scripts = 'InteractiveMap.js',
                'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js';
    StyleSheets = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css';
    StartupScript = 'InteractiveMap.js';

    event controlReady();

    procedure showMap(ResultArray: Text);
}