page 90012 "NDC-FactBoxArea"
{
    PageType = CardPart;
    ApplicationArea = All;
    SourceTable = Customer;

    layout
    {
        area(content)
        {
            usercontrol(SummaryLog; "NDC-SummaryLog")
            {
                ApplicationArea = All;
                trigger ControlReady()
                begin
                    CurrPage.SummaryLog.LoadSummaryData(PrepareDataCount());
                end;
            }
            usercontrol(InteractivMap; "NDC-InteractiveMap")
            {
                ApplicationArea = All;
                trigger ControlReady()
                begin
                    CurrPage.InteractivMap.showMap(PrepareDataMap());
                end;
            }
        }
    }

    local procedure PrepareDataCount() ResultArray: Text
    var
        LogRec: Record "NDC-SalesInvoicesPostLog";
        jsonArray: JsonArray;
        jsonObject: JsonObject;
        TotalCount: Integer;
        SuccessCount: Integer;
        FailCount: Integer;
    begin
        Clear(jsonArray);
        Clear(jsonObject);
        TotalCount := 0;
        SuccessCount := 0;
        FailCount := 0;

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
}
