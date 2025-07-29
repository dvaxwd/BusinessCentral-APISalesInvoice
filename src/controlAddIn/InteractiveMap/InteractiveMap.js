Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('controlReady', [], false);

async function showMap(ResultArray) {
    const data = JSON.parse(ResultArray);
    let map;

    const container = document.getElementById("controlAddIn");
    if (!container.querySelector('#map')) {
        container.innerHTML = `<div id="map" style="width:100%; height:100%;"></div>`;
    }

    if (!map) {
        map = L.map('map').setView(['13.736717', '100.523186'], 13);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; OpenStreetMap contributors'
        }).addTo(map);

        const markerBounds = [];
        data.forEach(item => {
            const popupContent = `
                <div style="text-align: center;">
                    <strong>${item.retailName}</strong>
                </div>
                Amounts : ${item.totalAmount}<br>
                Total invoices : ${item.totalInvoice}<br>
                Success invoices : ${item.successInvoice}<br>
                Fail invoices : ${item.failInvoice}
            `;

            L.marker([item['latitude'], item['longitude']])
                .addTo(map)
                .bindTooltip(popupContent, { permanent: false, direction: 'top' });

            markerBounds.push([item['latitude'], item['longitude']])
        });

        if(markerBounds.length > 0){
            map.fitBounds(markerBounds);
        }
    }else{
        map = L.map('map').setView(['13.736717', '100.523186'], 13);
        map.eachLayer(function (layer) {
            if (layer instanceof L.Marker) {
                map.removeLayer(layer);
            }
        });
    }
}
