Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('controlReady', [], false)

// ***** This function is main function to render summary area. *****
async function LoadSummaryData(ResultArray) {
    console.log('Load Summary Data');
    console.log(ResultArray);
    document.getElementById("controlAddIn").innerHTML = `
        <div class="d-flex flex-row-reverse px-3 mb-2" id="filterArea"></div>
        <div class="row d-flex justify-content-evenly h-auto" id="cardArea"></div>
    `;
    const filterArea = document.getElementById("filterArea");
    const cardArea = document.getElementById("cardArea");

    await FilterManagement(filterArea);
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

// ***** This function is used to manage filter *****
async function FilterManagement(targetElement) {
    targetElement.innerHTML = ``;

    const dropDown = document.createElement("div");
    dropDown.className = "dropdown";

    const toggle = document.createElement("button");
    toggle.className = "btn btn-sm dropdown-toggle px-3 border border-black";
    toggle.type = "button";
    toggle.id = "monthDropdown"; // สำหรับ aria-labelledby
    toggle.setAttribute("data-bs-toggle", "dropdown");
    toggle.setAttribute("aria-expanded", "false");
    toggle.textContent = "Month";

    // สร้าง ul สำหรับเมนู dropdown
    const menu = document.createElement("ul");
    menu.className = "dropdown-menu dropdown-menu-light";
    menu.setAttribute("aria-labelledby", "monthDropdown");

    const months = ['01','02','03','04','05','06','07','08','09','10','11','12'];
    months.forEach((month, index) => {
        const li = document.createElement("li");
        const option = document.createElement("a");
        option.className = "dropdown-item";
        option.href = "#"; // จำเป็นสำหรับ Bootstrap
        option.dataset.value = month;
        option.textContent = new Date(0, index).toLocaleString('default', { month: 'long' });
        option.addEventListener("click", function (e) {
            e.preventDefault();
            toggle.textContent = option.textContent; // เปลี่ยนชื่อปุ่มเป็นเดือนที่เลือก
            console.log("Selected month:", month);    // แสดงใน console
            // หากต้องการส่งค่ากลับ AL:
            // Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnMonthSelected', [month]);
        });
        li.appendChild(option);
        menu.appendChild(li);
    });
    dropDown.appendChild(toggle);
    dropDown.appendChild(menu);

    targetElement.appendChild(dropDown);
}