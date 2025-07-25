page 90012 "NDC-FactBoxArea"{
    PageType = CardPart;
    ApplicationArea = All;
    SourceTable = Customer;

    layout
    {
        area(content)
        {
            usercontrol(SummaryLog; "NDC-SummaryLog"){
                ApplicationArea = All;
                trigger ControlReady()
                    begin
                        CurrPage.SummaryLog.LoadSummaryData(PrepareDataCount());
                    end;
            }usercontrol(InteractivMap; "NDC-InteractiveMap"){
                ApplicationArea = All;
                trigger ControlReady()
                    begin
                        CurrPage.InteractivMap.showMap(PrepareDataMap());
                    end;
            }
        }
    }

    local procedure PrepareDataCount()ResultArray: Text
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
            jsonObject.Add('totalInvoice',TotalCount);
            jsonObject.Add('successInvoice',SuccessCount);
            jsonObject.Add('failInvoice',FailCount);
            jsonArray.Add(jsonObject);
            jsonArray.WriteTo(ResultArray);
            exit(ResultArray);
        end;

    local procedure PrepareDataMap()ResultArray: Text
        var
            jsonObject: JsonObject;
            jsonArray: JsonArray;
        begin
            jsonObject.Add('Latitude','13.7563');
            jsonObject.Add('Longitude','100.5018');
            jsonArray.Add(jsonObject);
            jsonArray.WriteTo(ResultArray);
            exit(ResultArray);
        end;
}
