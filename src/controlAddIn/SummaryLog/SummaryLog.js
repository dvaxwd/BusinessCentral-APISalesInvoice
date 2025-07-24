Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('controlReady', [], false)

// ***** This function is main function to render summary area. *****
async function LoadSummaryData(ResultArray) {
    console.log('Load Summary Data');
    console.log(ResultArray);
    document.getElementById("controlAddIn").innerHTML = `
        <div id="filterArea">
        
        </div>
        <div class="row d-flex justify-content-evenly h-auto" id="cardArea">
            <h1>In Inner HTML</h1>
        </div>
    `;
    const cardArea = document.getElementById("cardArea");
    await LoadSummaryCard(cardArea, ResultArray);
}

// // ***** This function is used to generate summary card and inject into target area *****
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
    cardHeader.className = `card-header px-3 text-start text-white fw-semibold bg-${style}`;
    cardHeader.textContent = header;

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