Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('controlReady', [], false);

// ฟังก์ชันหลักที่ถูกเรียกจาก AL
async function showMap(ResultArray) {
    console.log(ResultArray);
    const data = JSON.parse(ResultArray);
    const obj = data[0];
    const lat = obj['latitude'];
    const lng = obj['longitude'];
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

        data.forEach(item => {
            L.marker([item['latitude'], item['longitude']]).addTo(map)
                .bindPopup(`${item['retailName']}`)
                .openPopup();
        });
        // L.marker([lat, lng]).addTo(map)
        //     .bindPopup(`${obj['retailName']}`)
        //     .openPopup();
    }else{
        map.setView([lat, lng], 13);

        map.eachLayer(function (layer) {
            if (layer instanceof L.Marker) {
                map.removeLayer(layer);
            }
        });
    }
}
