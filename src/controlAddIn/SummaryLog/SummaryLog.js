Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('controlReady', [], false)

// ***** This function is main function to render summary area. *****
async function LoadSummaryData(ResultArray, failReasonArray) {
    const controlAddIn = document.getElementById("controlAddIn");
    controlAddIn.innerHTML = `
        <div class="d-flex flex-row-reverse px-3 mb-2" id="filterArea"></div>
        <div class="row d-flex justify-content-evenly h-auto" id="cardArea"></div>
        <div class="row d-flex justify-content-evenly h-100">
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
    `;
    const filterArea = document.getElementById("filterArea");
    const cardArea = document.getElementById("cardArea");
    const chartArea = document.getElementById("chartArea");
    const failCardArea = document.getElementById("failCardArea");

    await FilterManagement(filterArea);
    await LoadSummaryCard(cardArea, ResultArray);
    await LoadPieChart(chartArea, ResultArray);
    await LoadFailReasonCard(failCardArea, failReasonArray);
}

// ***** This function is used to generate summary card and inject into target area *****
async function LoadSummaryCard(targetElement, ResultArray) {
    try {
        const data = JSON.parse(ResultArray);
        if (Array.isArray(data)) {
            targetElement.innerHTML = ``;
            const obj = data[0];
            Object.keys(obj).forEach((key) => {
                switch (key) {
                    case 'totalInvoice':
                        CreateCard(targetElement, 'Total Invoice', obj[key], 'primary');
                        break;
                    case 'successInvoice':
                        CreateCard(targetElement, 'Success Invoice', obj[key], 'success');
                        break;
                    case 'failInvoice':
                        CreateCard(targetElement, 'Fail Invoice', obj[key], 'danger');
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
async function CreateCard(targetElement,header, amount, style) {
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
    small.textContent = `Last updated today`;

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
async function LoadSummaryApplyFilter(ResultArray){
    const cardArea = document.getElementById("cardArea");
    LoadSummaryCard(cardArea, ResultArray);
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
                console.log(typeof(data));
                data.sort((a,b) => b.count - a.count);
                targetElement.innerHTML = ``;
                data.forEach(item => {
                    const button = document.createElement("button");
                    button.className = "btn btn-outline-dark shadow position-relative mb-2";
                    button.type = button;
                    button.textContent = item.reason;

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
