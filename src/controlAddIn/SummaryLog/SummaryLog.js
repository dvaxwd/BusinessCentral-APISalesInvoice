Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('controlReady', [], false)

// ***** This function is main function to render summary area. *****
async function LoadSummaryData(ResultArray, failReasonArray, lastUpdate) {
    const controlAddIn = document.getElementById("controlAddIn");
    controlAddIn.innerHTML = `
        <div class="d-flex flex-row-reverse px-3 mb-2" id="filterArea"></div>
        <div class="row d-flex justify-content-evenly h-auto" id="cardArea"></div>
        <div class="row d-flex justify-content-evenly h-auto">
            <div class="col-6" id="chartArea"></div>
            <div class="col-5 px-0 py-3">
                <div class="row mb-2">
                    <p class="h6">
                        <em class="font-weight-bold">Top Failure Reasons</em>
                    </p>
                </div>
                <div class="row px-4" id="failCardArea">
                </div>
            </div>
        </div>
        <div class="row m-2 p-2 rounded shadow" id="mapArea" style="height: 480px;"></div>
        <div class="row h-100" id="linkPageArea">
        <div class="row d-flex mt-4 mb-4 align-items-center" id="invoiceArea">
            <div class="col-auto ms-2">
                <h6>
                    <em class="font-weight-bold">View and Fix Sales Invoice</em>
                </h6>
            </div>
            <div class="col-auto px-0">
                <i class="bi bi-tools fs-4"></i>  
            </div>
        </div>
        <div class="row d-flex justify-content-center mx-1 h-100" >
            <div class="col-11 px-0 py-0 rounded shadow overflow-y-auto" id="invoiceTableArea" style="height: 360px;"></div>
        </div>  

    `;
    const filterArea = document.getElementById("filterArea");
    const cardArea = document.getElementById("cardArea");
    const chartArea = document.getElementById("chartArea");
    const failCardArea = document.getElementById("failCardArea");

    await FilterManagement(filterArea);
    await LoadSummaryCard(cardArea, ResultArray, FormatDateFormular(lastUpdate));
    await LoadPieChart(chartArea, ResultArray);
    await LoadFailReasonCard(failCardArea, failReasonArray);
}

// ***** This function is used to generate summary card and inject into target area *****
async function LoadSummaryCard(targetElement, ResultArray, lastUpdate) {
    try {
        const data = JSON.parse(ResultArray);
        if (Array.isArray(data)) {
            targetElement.innerHTML = ``;
            const obj = data[0];
            Object.keys(obj).forEach((key) => {
                switch (key) {
                    case 'totalInvoice':
                        CreateCard(targetElement, 'Total Invoice', obj[key], 'primary', lastUpdate);
                        break;
                    case 'successInvoice':
                        CreateCard(targetElement, 'Success Invoice', obj[key], 'success', lastUpdate);
                        break;
                    case 'failInvoice':
                        CreateCard(targetElement, 'Fail Invoice', obj[key], 'danger', lastUpdate);
                        break;
                }
            })
        }
    } catch (error) {
        targetElement.innerHTML = ``;
        const message = document.createElement("p");
        message.textContent = `Loading data`;
        targetElement.appendChild(message);
    }
}

// ***** This function is used to create card *****
async function CreateCard(targetElement,header, amount, style , lastUpdate) {
    const card = document.createElement("div");
    card.className = `card col-auto m-2 px-0 h-auto shadow border border-${style}`;

    const cardHeader = document.createElement("div");
    cardHeader.className = `card-header px-3 bg-${style}`;

    const em = document.createElement("em");
    em.className = "text-start text-white fw-semibold";
    em.textContent = header;

    cardHeader.appendChild(em);

    const cardBody = document.createElement("div");
    cardBody.className = "card-body px-4";

    const cardTitle = document.createElement("h3");
    cardTitle.className = "card-title text-end"
    cardTitle.textContent = amount;

    const cardText = document.createElement("p");
    cardText.className = "card-text text-center";

    const small = document.createElement("small");
    small.className = "text-body-secondary text-center"
    small.textContent = lastUpdate;

    cardText.appendChild(small);
    cardBody.appendChild(cardTitle);
    cardBody.appendChild(cardText);
    card.appendChild(cardHeader);
    card.appendChild(cardBody);

    targetElement.appendChild(card);
}

// ***** This function is used to manage filter *****
async function FilterManagement(targetElement) {
    targetElement.innerHTML = ``;
    
    CreateMonthDropdown(targetElement);
    CreateYearDropdown(targetElement);
}

// ***** This function is used to create year dropdown element *****
function CreateYearDropdown(targetElement){
    const dropDown = document.createElement("div");
    dropDown.className = "dropDown mx-3";

    const toggle = document.createElement("button");
    toggle.className = "btn btn-sm dropdown-toggle px-3 border border-black";
    toggle.type = "button";
    toggle.id = "yearDropdown";
    toggle.setAttribute("data-bs-toggle", "dropdown");
    toggle.setAttribute("aria-expanded", "false");
    toggle.textContent = "Years";

    const menu = document.createElement("ul");
    menu.className = "dropdown-menu dropdown-menu-light";
    menu.setAttribute("aria-labelledby", "monthDropdown");

    const years = new Date().getFullYear();
    for(let i = years - 5; i <= years; i++){
        const li = document.createElement("li");
        const option = document.createElement("a");
        option.className = "dropdown-item";
        option.href = "#";
        option.dataset.value = i;
        option.textContent = i;
        option.addEventListener("click", function (e) {
            e.preventDefault();
            toggle.textContent = option.textContent;
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnYearSelected', [i]);
        });
        li.appendChild(option);
        menu.appendChild(li);
    }
    dropDown.appendChild(toggle);
    dropDown.appendChild(menu);

    targetElement.appendChild(dropDown);
}

// ***** This function is used to create month dropdown element *****
function CreateMonthDropdown(targetElement){
    const dropDown = document.createElement("div");
    dropDown.className = "dropdown";

    const toggle = document.createElement("button");
    toggle.className = "btn btn-sm dropdown-toggle px-3 border border-black";
    toggle.type = "button";
    toggle.id = "monthDropdown";
    toggle.setAttribute("data-bs-toggle", "dropdown");
    toggle.setAttribute("aria-expanded", "false");
    toggle.textContent = "Months";

    const menu = document.createElement("ul");
    menu.className = "dropdown-menu dropdown-menu-light";
    menu.setAttribute("aria-labelledby", "monthDropdown");

    const months = ['01','02','03','04','05','06','07','08','09','10','11','12'];
    months.forEach((month, index) => {
        const li = document.createElement("li");
        const option = document.createElement("a");
        option.className = "dropdown-item";
        option.href = "#";
        option.dataset.value = month;
        option.textContent = new Date(0, index).toLocaleString('default', { month: 'long' });
        option.addEventListener("click", function (e) {
            e.preventDefault();
            toggle.textContent = option.textContent;
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnMonthSelected', [month]);
        });
        li.appendChild(option);
        menu.appendChild(li);
    });
    dropDown.appendChild(toggle);
    dropDown.appendChild(menu);

    targetElement.appendChild(dropDown);
}

// ***** This function is used to generate summary card and inject into target area after get apply filter *****
async function LoadSummaryApplyFilter(ResultArray, lastUpdate){
    const cardArea = document.getElementById("cardArea");
    LoadSummaryCard(cardArea, ResultArray, FormatDateFormular(lastUpdate));
}

async function LoadPieChart(targetElement, ResultArray) {
    const canvas = document.createElement("canvas");
    canvas.className = "p-3"
    canvas.id = "pieChartCanvas";
    canvas.style.maxWidth = "100%";
    canvas.style.maxHeight = "300px";
    targetElement.innerHTML = '';
    targetElement.appendChild(canvas);

    const invoiceRatio = CalInvoiceRatio(ResultArray);
    const ctx = canvas.getContext('2d');
    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: ['Success', 'Fail'],
            datasets: [{
                data: [invoiceRatio[0], invoiceRatio[1]],
                backgroundColor: [
                    'rgb(25, 135, 84)',
                    'rgb(220, 53, 69)',
                ],
                borderColor: '#fff',
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        font: {
                            weight: 'bold',
                            color: '#000000'
                        }
                    }
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return `${context.label}: ${context.parsed.toFixed(2)}%`;
                        }
                    }
                }
            }
        }
    });
}

async function LoadPieChartApplyFilter(dataArray){
    try {
        const chartArea = document.getElementById("chartArea");
        const data = JSON.parse(dataArray);
        if(Array.isArray(data)){
            const obj = data[0];
            if((obj['successInvoice'] === 0) && (obj['failInvoice'] === 0)){
                console.log('not found : ', obj)
                createNotFoundFilterElement(chartArea);
            }else{
                console.log('found : ', obj)
                LoadPieChart(chartArea,dataArray);
            }
        }
    }catch(error){
        console.log(error);
    }
}

function CalInvoiceRatio(ResultArray){
    try{
        let successInvoice, failInvoice ;
        const data = JSON.parse(ResultArray)
        if(Array.isArray(data)){
            const obj = data[0];
            Object.keys(obj).forEach((key) => {
                switch (key) {
                    case 'successInvoice':
                        successInvoice = obj[key]*100/obj['totalInvoice']
                        break;
                    case 'failInvoice':
                        failInvoice = obj[key]*100/obj['totalInvoice']
                        break;
                }
            })
        }
        return[successInvoice,failInvoice] 
    }catch(error){
        console.log(error);
    }
}

async function createNotFoundFilterElement(targetElement){
    targetElement.innerHTML = ``;

    const spinnerRow = document.createElement("div");
    spinnerRow.className = "row d-flex justify-content-center mt-5 mb-3 pt-5";

    const spinnerGrow = document.createElement("div");
    spinnerGrow.className = "spinner-grow spinner-grow-sm text-primary";
    spinnerGrow.role = "status";
    spinnerGrow.style = "width: 1.5rem; height: 1.5rem;";

    const spanVisual = document.createElement("span");
    spanVisual.className = "visually-hidden";

    spinnerGrow.appendChild(spanVisual);
    spinnerRow.appendChild(spinnerGrow);

    const message = document.createElement("div");
    message.className = "row d-flex justify-content-center mb-1";
    message.textContent = 'No Invoice';

    const tips = document.createElement("div");
    tips.className = "row d-flex justify-content-center";

    const small = document.createElement("small");
    small.className = "text-center";
    small.textContent = 'Try adjusting filters to see more results.';

    tips.appendChild(small);

    targetElement.appendChild(spinnerRow);
    targetElement.appendChild(message);
    targetElement.appendChild(tips);
}

async function LoadFailReasonCard(targetElement, dataArray){
    try {
        const data = JSON.parse(dataArray);
        if(Array.isArray(data)){
            if(data.length > 0){
                data.sort((a,b) => b.count - a.count);
                targetElement.innerHTML = ``;
                data.forEach(item => {
                    const button = document.createElement("button");
                    button.className = "btn btn-outline-dark shadow position-relative mb-2";
                    button.type = button;
                    button.textContent = item.reason;
                    button.addEventListener("click", (e) => {
                        const target = document.getElementById("invoiceArea");
                        if (target) {
                            target.scrollIntoView({ behavior: "smooth" });
                        }
                    })
                    const span = document.createElement("span");
                    span.className = "position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger";
                    span.textContent = item.count;

                    button.appendChild(span);
                    targetElement.appendChild(button);
                });
            }
        }
    }catch(error){
        console.log(error);   
    }
}

async function showMap(ResultArray) {
    const data = JSON.parse(ResultArray);
    let map;

    const container = document.getElementById("mapArea");
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

async function LoadInvoiceTable(dataArray){
    const targetElement = document.getElementById("invoiceTableArea");
    try {
       const data = JSON.parse(dataArray);
        if(Array.isArray(data)){
            const accordion = document.createElement("div");
            accordion.className = "accordion";
            accordion.id = "invoiceAccordion";

            targetElement.innerHTML = ``;
            data.forEach(item => {
                const acdItem = document.createElement("div");
                acdItem.className = "accordion-item";

                const acdHeader = document.createElement("h2");
                acdHeader.className = "accordion-header";

                const acdButton = document.createElement("button");
                acdButton.className = "accordion-button";
                acdButton.type = "button";
                acdButton.setAttribute("data-bs-toggle","collapse");
                acdButton.setAttribute("data-bs-target",`#collapse-${item.invoiceNo}`);
                acdButton.setAttribute("aria-expanded","true");
                acdButton.setAttribute("aria-controls",`collapse-${item.invoiceNo}`)
                acdButton.textContent = `${item.invoiceNo} | ${item.retailName}`;                

                acdHeader.appendChild(acdButton);

                const acdCollapse = document.createElement("div");
                acdCollapse.className = "accordion-collapse collapse";
                acdCollapse.id = `collapse-${item.invoiceNo}`
                acdCollapse.setAttribute("data-bs-parent","#invoiceAccordion")

                const acdBody = document.createElement("div");
                acdBody.className = "accordion-body row d-flex justify-content-center mx-0 px-3";

                const leftCol = document.createElement("div");
                leftCol.className = "col-10 mx-0";

                const em = document.createElement("em");
                em.className = "font-weight-bold";
                em.textContent = item.errorMessage;

                const small = document.createElement("small");
                small.appendChild(em);

                leftCol.appendChild(small);

                const rightCol = document.createElement("div");
                rightCol.className = "col-2 d-flex justify-content-end mx-0";

                const icon = document.createElement('i');
                icon.className = "bi bi-box-arrow-up-right text-primary fs-6";
                icon.style.cursor = "pointer";
                icon.addEventListener("click", function (e) {
                    e.preventDefault();
                    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OpenInvoice', [item.invoiceNo]);
                });

                rightCol.appendChild(icon);

                acdBody.appendChild(leftCol);
                acdBody.appendChild(rightCol);

                acdCollapse.appendChild(acdBody);

                acdItem.appendChild(acdHeader);
                acdItem.appendChild(acdCollapse);

                accordion.appendChild(acdItem);
            });
            targetElement.appendChild(accordion);
        }
    }catch(error){
        console.log(error);
    }
}

function FormatDateFormular(lastUpdate) {
    try {
        const data = JSON.parse(lastUpdate);
        const obj = data[0];
        let updated = obj.lastUpdate;

        if (updated === "today") return "Updated today";

        // regex match ตัวเลขตามด้วยตัวอักษร D/W/M/Y
        const match = updated.match(/^(\d+)([DWMY])/);

        if (match) {
            const number = parseInt(match[1]);
            const unit = match[2];

            if (number === 1) {
                switch (unit) {
                    case 'D': return 'Updated yesterday';
                    case 'W': return 'Updated last week';
                    case 'M': return 'Updated month';
                    case 'Y': return 'Updated year';
                }
            } else {
                switch (unit) {
                    case 'D': return `Updated ${number} days ago`;
                    case 'W': return `Updated ${number} weeks ago`;
                    case 'M': return `Updated ${number} months ago`;
                    case 'Y': return `Updated ${number} years ago`;
                }
            }
        }

        return updated; // fallback ถ้าไม่ตรง pattern
    } catch (error) {
        console.log(error);
        return '';
    }
}

