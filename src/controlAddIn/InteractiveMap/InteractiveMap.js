Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('controlReady', [], false);

// ฟังก์ชันหลักที่ถูกเรียกจาก AL
async function showMap(ResultArray) {
    const data = JSON.parse(ResultArray);
    const obj = data[0];
    const lat = obj['Latitude'];
    const lng = obj['Longitude'];
    let map;
    const container = document.getElementById("controlAddIn");
    if (!container.querySelector('#map')) {
        container.innerHTML = `<div id="map" style="width:100%; height:100%;"></div>`;
    }

    if(!map){
        map = L.map('map').setView([lat, lng], 13);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; OpenStreetMap contributors'
        }).addTo(map);

        L.marker([lat, lng]).addTo(map)
            .bindPopup(`Location: กรุงเทพมหานคร`)
            .openPopup();
    }else{
        map.setView([lat, lng], 13);

        map.eachLayer(function (layer) {
            if (layer instanceof L.Marker) {
                map.removeLayer(layer);
            }
        });
    }
}
