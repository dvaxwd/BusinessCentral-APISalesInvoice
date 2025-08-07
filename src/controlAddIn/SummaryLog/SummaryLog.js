Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlReady', [], false)

// ***** This is the main function responsible for rendering the dashboard. *****
async function LoadDashboard(dataArray, failReasonArray, lastUpdate){
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
        <div class="row d-flex justify-content-center px-2" id="linechartArea"></div>
        <div class="row m-2 p-2 rounded shadow" id="mapArea" style="height: 480px;"></div>
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
        <div class="row d-flex justify-content-center mx-1 mb-2 h-auto" >
            <div class="col-11 px-0 py-0 rounded shadow overflow-y-auto" id="invoiceTableArea" style="height: 360px;"></div>
        </div>
        <div class="row d-flex justify-content-end px-5 pt-5 pb-0 h-100" id="footer">
            <div class="col-auto px-0 py-0 align-items-end">
                <span class="rounded-circle shadow px-2 py-2" onclick="ScrolBack()" style="cursor: pointer;">
                    <i class="bi bi-chevron-double-up fs-2 font-weight-bold"></i>
                </span>
            </div>
        </div>
    `;
    const filterArea = document.getElementById("filterArea");
    const cardArea = document.getElementById("cardArea");
    const chartArea = document.getElementById("chartArea");
    const failCardArea = document.getElementById("failCardArea");

    await FilterManagement(filterArea);
    await LoadSummaryCard(cardArea, dataArray, FormatDateFormular(lastUpdate));
    await LoadPieChart(chartArea, dataArray);
    await LoadFailReasonCard(failCardArea, failReasonArray);
}

// ***** This group of functions controls the dropdown filter *****
async function FilterManagement(targetElement){
    targetElement.innerHTML = ``;
    CreateMonthDropdown(targetElement);
    CreateYearDropdown(targetElement);
}
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

// ***** This group of functions controls the summary card *****
async function LoadSummaryCard(targetElement, dataArray, lastUpdate){
    try {
        const data = JSON.parse(dataArray);
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
async function CreateCard(targetElement,header, amount, style , lastUpdate){
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
async function LoadSummaryApplyFilter(dataArray, lastUpdate){
    const cardArea = document.getElementById("cardArea");
    LoadSummaryCard(cardArea, dataArray, FormatDateFormular(lastUpdate));
}

// ***** This group of functions is used to control doughnut chart *****
async function LoadPieChart(targetElement, dataArray){
    const canvas = document.createElement("canvas");
    canvas.className = "p-3"
    canvas.id = "pieChartCanvas";
    canvas.style.maxWidth = "100%";
    canvas.style.maxHeight = "300px";
    targetElement.innerHTML = '';
    targetElement.appendChild(canvas);

    const invoiceRatio = CalInvoiceRatio(dataArray);
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
                createNotFoundFilterElement(chartArea);
            }else{
                LoadPieChart(chartArea,dataArray);
            }
        }
    }catch(error){
        console.log(error);
    }
}

// ***** This group of functions is used to control the Top Failure Reason card *****
async function LoadFailReasonCard(targetElement, dataArray){
    try {
        const data = JSON.parse(dataArray);
        if(Array.isArray(data)){
            if(data.length > 0){
                data.sort((a,b) => b.count - a.count);
                if(data.length > 5){
                    data.splice(5);
                }
                targetElement.innerHTML = ``;
                data.forEach(item => {
                    if (item.count > 0) {
                        const button = document.createElement("button");
                        button.className = "btn btn-outline-dark shadow position-relative mb-2";
                        button.type = "button";
                        button.textContent = item.description;
                        button.addEventListener("click", (e) => {
                            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnTopFailureClick', [item.code], false)
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
                    }
                });
            }
        }
    }catch(error){
        console.log(error);   
    }
}
async function LoadFailReasonCardApplyfilter(dataArray){
    try{
        const target = document.getElementById("failCardArea");
        const data = JSON.parse(dataArray);
        if(Array.isArray(data)){
            const ishavefail = data.some(item => item.count > 0);
            if(ishavefail){
                LoadFailReasonCard(target, dataArray);
            }else{
                LoadEmptyFailReasonCard(target);
            }
        }
    }catch(error){
        console.log(error);
    }
}
async function LoadEmptyFailReasonCard(targetElement){
    targetElement.innerHTML = ``;
    for(let i = 0; i <= 4; i++){
        const button = document.createElement("button");
        button.className = "btn btn-outline-dark shadow position-relative mb-2 disabled placeholder-glow";
        button.type = button;

        const span = document.createElement("span");
        span.className = "placeholder col-12";

        button.appendChild(span);
        targetElement.appendChild(button);
    }
}

// ***** This group of function is used to control line chart *****
async function LoadLineChart(dataArray){
    try{
        const data = JSON.parse(dataArray);
        const targetElement = document.getElementById("linechartArea");
        const canvas = document.createElement("canvas");
        canvas.className = "p-3";
        canvas.id = "lineChartCanvas";
        canvas.style.maxWidth = "100%";
        canvas.style.maxHeight = "200px";
        targetElement.innerHTML = '';
        targetElement.appendChild(canvas);

        const ctx = canvas.getContext("2d");
        new Chart(ctx, {
            type: "line",
            data: {
                labels: ['Jan.','Feb.','Mar.','Apr.','May.','Jun.','Jul.','Aug.','Sep.','Oct.','Nov.','Dec.'],
                datasets: [
                    {
                        label: 'Total Invoice',
                        data: data.map(item => item.totalInvoice),
                        fill: false,
                        backgroundColor: 'rgb(13, 110, 253)',
                        borderColor: 'rgb(13,110,253)',
                        tension: 0.1
                    },
                    {
                        label: 'Success Invoice',
                        data: data.map(item => item.successInvoice),
                        fill: false,
                        backgroundColor: 'rgb(25, 135, 84)',
                        borderColor: 'rgb(25, 135, 84)',
                        tension: 0.1
                    },
                    {
                        label: 'Fail Invoice',
                        data: data.map(item => item.failInvoice),
                        fill: false,
                        backgroundColor: 'rgb(220, 53, 69)',
                        borderColor: 'rgb(220, 53, 69)',
                        tension: 0.1
                    }
                ]
            }
        })
    }catch(error){
        console.log(error)
    }
}

// ***** This group of functions is used to control the map *****
async function LoadMap(dataArray){
    const data = JSON.parse(dataArray);
    let map;

    const container = document.getElementById("mapArea");
    if (!container.querySelector('#map')) {
        container.innerHTML = `<div id="map" style="width:100%; height:100%;"></div>`;
    }

    if(!map){
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
async function LoadMapApplyFilter(dataArray){
    const targetElement = document.getElementById("mapArea");
    targetElement.innerHTML = ``;
    LoadMap(dataArray);
}

// ***** This group of functions is used to control the invoice table *****
async function LoadInvoiceTable(dataArray){
    try{
        const targetElement = document.getElementById("invoiceTableArea");
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
async function LoadInvoiceTableApplyFilter(dataArray){
    try{
        const target = document.getElementById("invoiceTableArea");
        const data = JSON.parse(dataArray);
        if(Array.isArray(data)){
            if(data.length > 0){
                LoadInvoiceTable(dataArray);
            }else{
                await createNotFoundFilterElement(target);
            }
        }
    }catch(error){
        console.log(error);
    }
}
async function LoadInvoiveTableFilterReason(dataArray){
    try{
        const data = JSON.parse(dataArray);
        if(Array.isArray(data)){
            LoadInvoiceTable(dataArray);
        }
    }catch(error){
        console.log(error)   
    }
}

// ***** This group of functions is used to render DOM elements when data is empty *****
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

// ***** This group of functions includes utility and logic components *****
function CalInvoiceRatio(dataArray){
    try{
        let successInvoice, failInvoice ;
        const data = JSON.parse(dataArray)
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
function FormatDateFormular(lastUpdate) {
    try {
        const data = JSON.parse(lastUpdate);
        const obj = data[0];
        let updated = obj.lastUpdate;
        const match = updated.match(/^(\d+)([DWMY])/);

        if (updated === "today") return "Updated today";
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
        return updated;
    } catch (error) {
        console.log(error);
        return '';
    }
}
function ScrolBack(){
    const target = document.getElementById("filterArea");
    const yearDropdown = document.getElementById("yearDropdown");
    const monthDropdown = document.getElementById("monthDropdown");
    if (target) {
        yearDropdown.textContent = "Years";
        monthDropdown.textContent = "Months";
        target.scrollIntoView({ behavior: "smooth" });
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ClearFilter',[0, 0],false)                   
    }
}

