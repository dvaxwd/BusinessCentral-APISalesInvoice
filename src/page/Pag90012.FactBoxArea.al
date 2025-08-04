page 90012 "NDC-FactBoxArea"
{
    PageType = CardPart;
    ApplicationArea = All;
    SourceTable = "NDC-SalesInvoicesPostLog";

    layout
    {
        area(content)
        {
            usercontrol(SummaryLog; "NDC-SummaryLog")
            {
                ApplicationArea = All;
                trigger ControlReady()
                begin
                    CurrPage.SummaryLog.LoadSummaryData(PrepareDataCount(YearFilter, MonthFilter), SummaryCountFailReason(YearFilter, MonthFilter), CalLastUpdate());
                    CurrPage.SummaryLog.showMap(PrepareDataMap());
                    CurrPage.SummaryLog.LoadInvoiceTable(PrepareDataFailInvoice(YearFilter, MonthFilter));
                end;

                trigger OnYearSelected(YearText: Text)
                begin
                    Evaluate(YearFilter, YearText);
                    CurrPage.SummaryLog.LoadSummaryApplyFilter(PrepareDataCount(YearFilter, MonthFilter), CalLastUpdate());
                    CurrPage.SummaryLog.LoadPieChartApplyFilter(PrepareDataCount(YearFilter, MonthFilter));
                    CurrPage.SummaryLog.LoadFailReasonCardApplyfilter(SummaryCountFailReason(YearFilter, MonthFilter));
                    CurrPage.SummaryLog.LoadInvoiceTableApplyFilter(PrepareDataFailInvoice(YearFilter, MonthFilter));
                end;

                trigger OnMonthSelected(MonthText: Text)
                begin
                    Evaluate(MonthFilter, MonthText);
                    CurrPage.SummaryLog.LoadSummaryApplyFilter(PrepareDataCount(YearFilter, MonthFilter), CalLastUpdate());
                    CurrPage.SummaryLog.LoadPieChartApplyFilter(PrepareDataCount(YearFilter, MonthFilter));
                    CurrPage.SummaryLog.LoadFailReasonCardApplyfilter(SummaryCountFailReason(YearFilter, MonthFilter));
                    CurrPage.SummaryLog.LoadInvoiceTableApplyFilter(PrepareDataFailInvoice(YearFilter, MonthFilter));
                end;

                trigger ClearFilter(YearText: Text; MonthText: Text)
                    begin
                        Evaluate(YearFilter, YearText);
                        Evaluate(MonthFilter, MonthText);
                        CurrPage.SummaryLog.LoadSummaryApplyFilter(PrepareDataCount(YearFilter, MonthFilter), CalLastUpdate());
                        CurrPage.SummaryLog.LoadPieChartApplyFilter(PrepareDataCount(YearFilter, MonthFilter));
                        CurrPage.SummaryLog.LoadFailReasonCardApplyfilter(SummaryCountFailReason(YearFilter, MonthFilter));
                        CurrPage.SummaryLog.LoadInvoiceTableApplyFilter(PrepareDataFailInvoice(YearFilter, MonthFilter));
                    end;

                trigger OnTopFailureClick(Keyword: Text)
                    begin
                        CurrPage.SummaryLog.LoadInvoiveTableFilterReason(PrepareSaleInvoiceApplyFilter(YearFilter, MonthFilter, Keyword));
                    end;
                trigger OpenInvoice(InvoicceNo: Text)
                begin
                    OpenSaleInvoice(InvoicceNo);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        YearFilter := 0;
        MonthFilter := 0;
    end;

    var
        YearFilter: Integer;
        MonthFilter: Integer;

    local procedure PrepareDataCount(Year: Integer; Month: Integer) ResultArray: Text
    var
        LogRec: Record "NDC-SalesInvoicesPostLog";
        jsonArray: JsonArray;
        jsonObject: JsonObject;
        TotalCount: Integer;
        SuccessCount: Integer;
        FailCount: Integer;
        StartDateTime, EndDateTime : DateTime;
    begin
        Clear(jsonArray);
        Clear(jsonObject);
        TotalCount := 0;
        SuccessCount := 0;
        FailCount := 0;

        if (Year <> 0) then begin
            if (Month <> 0) then begin
                StartDateTime := CreateDateTime(DMY2DATE(1, Month, Year), 000000T);
                if Month = 12 then
                    EndDateTime := CreateDateTime(DMY2DATE(1, 1, Year + 1), 000000T)
                else
                    EndDateTime := CreateDateTime(DMY2DATE(1, Month + 1, Year), 000000T);
                LogRec.SetRange("Post Attempt DateTime", StartDateTime, EndDateTime);
            end else begin
                StartDateTime := CreateDateTime(DMY2DATE(1, 1, Year), 000000T);
                EndDateTime := CreateDateTime(DMY2DATE(1, 1, Year + 1), 000000T);
                LogRec.SetRange("Post Attempt DateTime", StartDateTime, EndDateTime);
            end;
        end else begin
            if (Month <> 0) then begin
                StartDateTime := CreateDateTime(DMY2DATE(1, Month, Date2DMY(Today(), 3)), 000000T);
                if Month = 12 then
                    EndDateTime := CreateDateTime(DMY2DATE(1, 1, Date2DMY(Today(), 3) + 1), 000000T)
                else
                    EndDateTime := CreateDateTime(DMY2DATE(1, Month + 1, Date2DMY(Today(), 3)), 000000T);
                LogRec.SetRange("Post Attempt DateTime", StartDateTime, EndDateTime - 1);
            end;
        end;
        if LogRec.FindSet() then begin
            repeat
                TotalCount += 1;
                case LogRec."Post Status" of
                    LogRec."Post Status"::Success:
                        SuccessCount += 1;
                    LogRec."Post Status"::Fail:
                        FailCount += 1;
                end;
            until LogRec.Next() = 0;
        end;
        jsonObject.Add('totalInvoice', TotalCount);
        jsonObject.Add('successInvoice', SuccessCount);
        jsonObject.Add('failInvoice', FailCount);
        jsonArray.Add(jsonObject);
        jsonArray.WriteTo(ResultArray);
        exit(ResultArray);
    end;

    local procedure PrepareDataMap() ResultArray: Text
    var
        jsonObject: JsonObject;
        jsonArray: JsonArray;

        data: Record "Location";
        AmountPerRetail: Dictionary of [Code[10], Decimal];
        CountPerRetail: Dictionary of [Code[10], List of [Integer]];
        SummaryCount: List of [Integer];
    begin
        AmountPerRetail := FindAmountPerRetail();
        CountPerRetail := SummaryCountPerRetail();

        if data.FindSet() then begin
            repeat
                Clear(jsonObject);
                Clear(SummaryCount);
                if CountPerRetail.ContainsKey(data.Code) then
                    SummaryCount := CountPerRetail.Get(data.Code);

                if (data."NDC-Latitude" <> '') and (data."NDC-Longitude" <> '') then begin
                    jsonObject.Add('retailName', data.Name);
                    if AmountPerRetail.ContainsKey(data.Code) then
                        jsonObject.Add('totalAmount', AmountPerRetail.Get(data.Code))
                    else
                        jsonObject.Add('totalAmount', 0.0);

                    if SummaryCount.Count() = 3 then begin
                        jsonObject.Add('totalInvoice', SummaryCount.Get(1));
                        jsonObject.Add('successInvoice', SummaryCount.Get(2));
                        jsonObject.Add('failInvoice', SummaryCount.Get(3));
                    end else begin
                        jsonObject.Add('totalInvoice', 0);
                        jsonObject.Add('successInvoice', 0);
                        jsonObject.Add('failInvoice', 0);
                    end;
                    jsonObject.Add('latitude', data."NDC-Latitude");
                    jsonObject.Add('longitude', data."NDC-Longitude");
                    jsonArray.Add(jsonObject);
                end;
            until data.Next() = 0;
        end;
        jsonArray.WriteTo(ResultArray);
        exit(ResultArray);
    end;

    local procedure FindAmountPerRetail() Result: Dictionary of [Code[10], Decimal]
    var
        logData: Record "NDC-SalesInvoicesPostLog";
    begin
        logData.SetRange("Post Status", logData."Post Status"::Success);
        if logData.FindSet() then begin
            repeat
                if not Result.ContainsKey(logData."Location Code") then begin
                    Result.Add(logData."Location Code", logData.Amount);
                end else begin
                    Result.Set(
                        logData."Location Code",
                        Result.Get(logData."Location Code") + logData.Amount);
                end;
            until logData.Next() = 0;
        end;
        exit(Result);
    end;

    local procedure SummaryCountPerRetail() Result: Dictionary of [Code[10], List of [Integer]]
    var
        logData: Record "NDC-SalesInvoicesPostLog";
        SummaryCount: List of [Integer];
        OP: Option a,B,C;
        test: Dictionary of [Code[10], Dictionary of [Code[10], Text[250]]];
    begin
        if logData.FindSet() then begin
            repeat
                if not Result.ContainsKey(logData."Location Code") then begin
                    Clear(SummaryCount);
                    SummaryCount.Add(0); // total
                    SummaryCount.Add(0); // success
                    SummaryCount.Add(0); // fail
                    Result.Add(logData."Location Code", SummaryCount);
                end else begin
                    SummaryCount := Result.Get(logData."Location Code");
                end;

                SummaryCount.Set(1, SummaryCount.Get(1) + 1);
                if logData."Post Status" = logData."Post Status"::Success then begin
                    SummaryCount.Set(2, SummaryCount.Get(2) + 1);
                end else begin
                    SummaryCount.Set(3, SummaryCount.Get(3) + 1);
                end;

                Result.Set(logData."Location Code", SummaryCount);
            until logData.Next() = 0;
        end;
        exit(Result);
    end;

    local procedure SummaryCountFailReason(Year: Integer; Month: Integer) Result: Text
    var
        jsonArray: JsonArray;
        jsonObject: JsonObject;
        LogRec: Record "NDC-SalesInvoicesPostLog";
        SummaryDict: Dictionary of [Text, Integer];
        TempKey: Text;
        PairKey: Text;
        PairValue: Integer;
        StartDateTime, EndDateTime : DateTime;
    begin
        LogRec.SetRange("Post Status", LogRec."Post Status"::Fail);
        Clear(jsonArray);
        Clear(jsonObject);

        if (Year <> 0) then begin
            if (Month <> 0) then begin
                StartDateTime := CreateDateTime(DMY2DATE(1, Month, Year), 000000T);
                if Month = 12 then
                    EndDateTime := CreateDateTime(DMY2DATE(1, 1, Year + 1), 000000T)
                else
                    EndDateTime := CreateDateTime(DMY2DATE(1, Month + 1, Year), 000000T);
                LogRec.SetRange("Post Attempt DateTime", StartDateTime, EndDateTime);
            end else begin
                StartDateTime := CreateDateTime(DMY2DATE(1, 1, Year), 000000T);
                EndDateTime := CreateDateTime(DMY2DATE(1, 1, Year + 1), 000000T);
                LogRec.SetRange("Post Attempt DateTime", StartDateTime, EndDateTime);
            end;
        end else begin
            if (Month <> 0) then begin
                StartDateTime := CreateDateTime(DMY2DATE(1, Month, Date2DMY(Today(), 3)), 000000T);
                if Month = 12 then
                    EndDateTime := CreateDateTime(DMY2DATE(1, 1, Date2DMY(Today(), 3) + 1), 000000T)
                else
                    EndDateTime := CreateDateTime(DMY2DATE(1, Month + 1, Date2DMY(Today(), 3)), 000000T);
                LogRec.SetRange("Post Attempt DateTime", StartDateTime, EndDateTime - 1);
            end;
        end;

        if LogRec.FindSet() then begin
            SummaryDict.Add('Lot assignment incomplete', 0);
            SummaryDict.Add('No available lot found', 0);
            SummaryDict.Add('Required serial no', 0);
            SummaryDict.Add('Over quantity', 0);
            SummaryDict.Add('Not found Serial', 0);
            repeat
                if LogRec."Error Message".Contains('Lot') then
                    SummaryDict.Set('Lot assignment incomplete', SummaryDict.Get('Lot assignment incomplete') + 1);

                if LogRec."Error Message".Contains('location') then
                    SummaryDict.Set('No available lot found', SummaryDict.Get('No available lot found') + 1);

                if LogRec."Error Message".Contains('required') then
                    SummaryDict.Set('Required serial no', SummaryDict.Get('Required serial no') + 1);

                if LogRec."Error Message".Contains('Quantity') then
                    SummaryDict.Set('Over quantity', SummaryDict.Get('Over quantity') + 1);

                if LogRec."Error Message".Contains('Not') then
                    SummaryDict.Set('Not found Serial', SummaryDict.Get('Not found Serial') + 1);
            until LogRec.Next() = 0;
        end;
        foreach PairKey in SummaryDict.Keys do begin
            Clear(jsonObject);
            PairValue := SummaryDict.Get(PairKey);
            jsonObject.Add('reason', PairKey);
            jsonObject.Add('count', PairValue);
            jsonArray.Add(jsonObject);
        end;
        jsonArray.WriteTo(Result);
    end;

    // This procedure
    local procedure PrepareDataFailInvoice(Year: Integer; Month: Integer) Result: Text
    var
        LogRec: Record "NDC-SalesInvoicesPostLog";
        JsonArray: JsonArray;
        JsonObject: JsonObject;
        StartDateTime, EndDateTime : DateTime;
    begin
        LogRec.SetRange("Post Status", LogRec."Post Status"::Fail);
        Clear(jsonArray);
        Clear(jsonObject);

        if (Year <> 0) then begin
            if (Month <> 0) then begin
                StartDateTime := CreateDateTime(DMY2DATE(1, Month, Year), 000000T);
                if Month = 12 then
                    EndDateTime := CreateDateTime(DMY2DATE(1, 1, Year + 1), 000000T)
                else
                    EndDateTime := CreateDateTime(DMY2DATE(1, Month + 1, Year), 000000T);
                LogRec.SetRange("Post Attempt DateTime", StartDateTime, EndDateTime);
            end else begin
                StartDateTime := CreateDateTime(DMY2DATE(1, 1, Year), 000000T);
                EndDateTime := CreateDateTime(DMY2DATE(1, 1, Year + 1), 000000T);
                LogRec.SetRange("Post Attempt DateTime", StartDateTime, EndDateTime);
            end;
        end else begin
            if (Month <> 0) then begin
                StartDateTime := CreateDateTime(DMY2DATE(1, Month, Date2DMY(Today(), 3)), 000000T);
                if Month = 12 then
                    EndDateTime := CreateDateTime(DMY2DATE(1, 1, Date2DMY(Today(), 3) + 1), 000000T)
                else
                    EndDateTime := CreateDateTime(DMY2DATE(1, Month + 1, Date2DMY(Today(), 3)), 000000T);
                LogRec.SetRange("Post Attempt DateTime", StartDateTime, EndDateTime - 1);
            end;
        end;

        if LogRec.FindSet() then begin
            repeat
                Clear(JsonObject);
                JsonObject.Add('invoiceNo', LogRec."Invoice No.");
                JsonObject.Add('retailName', LogRec."Location Name");
                JsonObject.Add('errorMessage', LogRec."Error Message");
                JsonArray.Add(JsonObject);
            until LogRec.Next() = 0
        end;
        JsonArray.WriteTo(Result);
    end;

    // This procedure is used to open sale invoice
    local procedure OpenSaleInvoice(InvoiceNo: Code[20])
    var
        SaleInvRec: Record "Sales Header";
    begin
        SaleInvRec.SetRange("No.", InvoiceNo);
        SaleInvRec.SetRange("Document Type", SaleInvRec."Document Type"::Invoice);
        if SaleInvRec.FindFirst() then
            PAGE.Run(PAGE::"Sales Invoice", SaleInvRec);
    end;

    // This procedure is used to
    local procedure CalLastUpdate()Result: Text;
        var
            LogRec: Record "NDC-SalesInvoicesPostLog";
            jsonObject: JsonObject;
            jsonArray: JsonArray;
            lastUpdate: Date;
            DateDiff: Integer;
            DateFomular: Text;
        begin
            if LogRec.FindLast() then begin
                lastUpdate := DT2Date(LogRec."Post Attempt DateTime");
                DateDiff := Today() - lastUpdate;

                if DateDiff = 0 then begin
                    DateFomular := 'today'
                end else begin
                    if DateDiff < 7 then
                        DateFomular := Format(DateDiff) + 'D ago'
                    else if DateDiff < 30 then
                        DateFomular := Format(DateDiff DIV 7) + 'W ago'
                    else if DateDiff < 365 then
                        DateFomular := Format(DateDiff DIV 30) + 'M ago'
                    else
                        DateFomular := Format(DateDiff DIV 365) + 'Y ago';
                end;

                jsonObject.Add('lastUpdate', DateFomular);
                jsonArray.Add(jsonObject);
                jsonArray.WriteTo(Result);
            end;
        end;

    // ***** This procedure is used to
    local procedure PrepareSaleInvoiceApplyFilter(Year: Integer; Month: Integer; Keyword: Text)Result: Text
        var
        LogRec: Record "NDC-SalesInvoicesPostLog";
        JsonArray: JsonArray;
        JsonObject: JsonObject;
        StartDateTime, EndDateTime : DateTime;
        RealMessage: Text;
    begin
        Clear(jsonArray);
        Clear(jsonObject);
        LogRec.SetRange("Post Status", LogRec."Post Status"::Fail);
        if Keyword.Contains('Lot') then
            RealMessage := 'Lot';
        if Keyword.Contains('available') then
            RealMessage := 'location';
        if Keyword.Contains('Required') then
            RealMessage := 'required';
        if Keyword.Contains('quantity') then
            RealMessage := 'Quantity';
        if Keyword.Contains('Not') then
            RealMessage := 'Not';
        if (Year <> 0) then begin
            if (Month <> 0) then begin
                StartDateTime := CreateDateTime(DMY2DATE(1, Month, Year), 000000T);
                if Month = 12 then
                    EndDateTime := CreateDateTime(DMY2DATE(1, 1, Year + 1), 000000T)
                else
                    EndDateTime := CreateDateTime(DMY2DATE(1, Month + 1, Year), 000000T);
                LogRec.SetRange("Post Attempt DateTime", StartDateTime, EndDateTime);
            end else begin
                StartDateTime := CreateDateTime(DMY2DATE(1, 1, Year), 000000T);
                EndDateTime := CreateDateTime(DMY2DATE(1, 1, Year + 1), 000000T);
                LogRec.SetRange("Post Attempt DateTime", StartDateTime, EndDateTime);
            end;
        end else begin
            if (Month <> 0) then begin
                StartDateTime := CreateDateTime(DMY2DATE(1, Month, Date2DMY(Today(), 3)), 000000T);
                if Month = 12 then
                    EndDateTime := CreateDateTime(DMY2DATE(1, 1, Date2DMY(Today(), 3) + 1), 000000T)
                else
                    EndDateTime := CreateDateTime(DMY2DATE(1, Month + 1, Date2DMY(Today(), 3)), 000000T);
                LogRec.SetRange("Post Attempt DateTime", StartDateTime, EndDateTime - 1);
            end;
        end;

        if LogRec.FindSet() then begin
            repeat
                if LogRec."Error Message".Contains(RealMessage) then begin
                    Clear(JsonObject);
                    JsonObject.Add('invoiceNo', LogRec."Invoice No.");
                    JsonObject.Add('retailName', LogRec."Location Name");
                    JsonObject.Add('errorMessage', LogRec."Error Message");
                    JsonArray.Add(JsonObject);
                end;
            until LogRec.Next() = 0
        end;
        JsonArray.WriteTo(Result);
    end;
}
