codeunit 90000 "NDC-GenerateInvoiceAPI"
{
    var
        LotRealTimeBalance: Dictionary of [code[50], Decimal];
        FailPostDict: Dictionary of [Code[20], Text[250]];

    procedure ProcessToCreateInv(TransectionRec: Record "NDC-Transaction DateTime")
    var
        CusBillRec: Record "NDC-API Customer Bills";
        BranchMap: Record "NDC-Branch Api Mapping";
        SH: Record "Sales Header";
        SalesCalcDiscByType: Codeunit "Sales - Calc Discount By Type";

        APISetup: Record "NDC-API Global Setup";
        SalesBatchPostMgt: Codeunit "Sales Batch Post Mgt.";
        SHtoPost: Record "Sales Header";
        SHtoPostCopy: Record "Sales Header";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";

        PostingDateReq, VATDateReq : Date;
        ReplacePostingDate: Boolean;
        ReplaceDocumentDate, ReplaceVATDateReq : Boolean;
        CalcInvDisc: Boolean;
        PrintDoc: Boolean;
        PrintDocVisible: Boolean;
        VATDateEnabled: Boolean;

        SILForLot: Record "Sales Line";
        ItemRequireLot: Record "Item";
    begin
        Clear(FailPostDict);
        CusBillRec.Reset();
        CusBillRec.setrange("Transaction ID", TransectionRec."Transaction ID");
        if CusBillRec.FindSet() then begin
            repeat
                BranchMap.Reset();
                BranchMap.setrange("Branch Code", CusBillRec."Shop Code");
                if BranchMap.FindSet() then begin
                end;

                SH.Init();
                SH."Document Type" := sh."Document Type"::Invoice;
                SH."No." := CusBillRec."Bill No";
                SH."NDC-Bill No." := CusBillRec."Bill No";
                SH."NDC-Ref. Guid" := CusBillRec."Transaction ID";
                SH.Insert(true);

                if CusBillRec."Member Code" <> '' then begin
                    SH.Validate("Sell-to Customer No.", CusBillRec."Member Code");
                    SH.Validate("Sell-to Customer Name", CusBillRec."Member Name");
                end else begin
                    SH.Validate("Sell-to Customer No.", BranchMap."Customer Code");
                end;
                SH.Validate("Posting Date", CusBillRec."Bill Date");
                if BranchMap."Location Code" <> '' then begin
                    SH.validate("Location Code", BranchMap."Location Code");
                end;
                if BranchMap."Shortcut Dimension 1 Code" <> '' then begin
                    SH.Validate("Shortcut Dimension 1 Code", BranchMap."Shortcut Dimension 1 Code");
                end;
                if BranchMap."Shortcut Dimension 2 Code" <> '' then begin
                    SH.Validate("Shortcut Dimension 2 Code", BranchMap."Shortcut Dimension 2 Code");
                end;
                SH.Modify();

                CreateSIL(CusBillRec, SH);

                if CusBillrec."Total Inv. Discount" <> 0 then begin
                    clear(SalesCalcDiscByType);
                    SalesCalcDiscByType.ApplyInvDiscBasedOnAmt(CusBillrec."Total Inv. Discount", SH);
                end;
                CreatePayment(CusBillRec);

            until CusBillRec.Next() = 0;
        end;
        APISetup.Get();
        if APISetup."Auto Post Sales Invoice" then begin
            SHtoPostCopy.Reset();
            SHtoPostCopy.SetRange("NDC-Ref. Guid", TransectionRec."Transaction ID");
            if SHtoPostCopy.FindSet() then begin
                repeat
                    InsertLog(SHtoPostCopy);
                until SHtoPostCopy.Next() = 0;
            end;
            
            SalesReceivablesSetup.Get();
            CalcInvDisc := SalesReceivablesSetup."Calc. Inv. Discount";
            ReplacePostingDate := false;
            ReplaceDocumentDate := false;
            ReplaceVATDateReq := false;
            PrintDoc := false;
            PrintDocVisible := SalesReceivablesSetup."Post & Print with Job Queue";
            clear(SalesBatchPostMgt);
            
            SHtoPost.Reset();
            SHtoPost.setrange("NDC-Ref. Guid", TransectionRec."Transaction ID");
            if SHtoPost.FindSet() then begin
                SalesBatchPostMgt.SetParameter(Enum::"Batch Posting Parameter Type"::Print, PrintDoc);
                SalesBatchPostMgt.SetParameter(Enum::"Batch Posting Parameter Type"::"Replace VAT Date", ReplaceVATDateReq);
                SalesBatchPostMgt.SetParameter(Enum::"Batch Posting Parameter Type"::"VAT Date", VATDateReq);
                SalesBatchPostMgt.RunBatch(SHtoPost, ReplacePostingDate, PostingDateReq, ReplaceDocumentDate, CalcInvDisc, false, true);
            end;
        end;
    end;

    procedure CreateSIL(CusBill: Record "NDC-API Customer Bills"; SIH: record "Sales Header")
    var
        InvDetail: Record "NDC-Invoice Detail";
        ItemRec: Record Item;
        SLine: Integer;
        SIL: Record "Sales Line";
        BOMComponent: Record "BOM Component";
        ItemRequireLot: Record Item;
        // ***** Variable for support Lot controll & Serial controll *****
        // ItemRequireControll: Record Item;
        // ITC: Record "Item Tracking Code";
    begin
        clear(SLine);
        InvDetail.Reset();
        InvDetail.setrange("Transaction ID", CusBill."Transaction ID");
        InvDetail.setrange("Bill No", CusBill."Bill No");
        if InvDetail.FindSet() then begin
            repeat
                clear(SIL);
                Sline += 10000;
                SIL.Init();
                sil."Document Type" := SIH."Document Type";
                SIL."Document No." := SIH."No.";
                SIL."Line No." := Sline;
                sil.Insert(true);

                sil.validate(Type, sil.Type::Item);
                SIL.validate("No.", InvDetail."Item No.");
                sil.Validate(Quantity, InvDetail.Quantity);
                if InvDetail."Unit Price" <> 0 then begin
                    sil.Validate("Unit Price", InvDetail."Unit Price");
                end;
                if InvDetail."Line Discount Amount" <> 0 then begin
                    sil.Validate("Line Discount Amount", InvDetail."Line Discount Amount");
                end;
                if CusBill."Total Inv. Discount" <> 0 then begin
                    SIL."Allow Invoice Disc." := true;
                end;
                SIL.modify();
                BOMComponent.Reset();
                BOMComponent.SetRange("Parent Item No.", InvDetail."Item No.");
                if BOMComponent.FindSet() then begin
                    CreateAsmOrder(CusBill, SIL);
                end;

                // ***** Now Usage Support Lot Controll *****
                ItemRequireLot.Reset();
                ItemRequireLot.SetRange("No.", InvDetail."Item No.");
                if ItemRequireLot.FindSet() then begin
                    repeat
                        if ItemRequireLot."Item Tracking Code" <> '' then begin
                            AssignLotNo(SIL, SIH);
                        end;
                    until ItemRequireLot.Next() = 0;
                end;

                // ***** Support Lot Control & Serial Control *****
                // ItemRequireControll.Reset();
                // ItemRequireControll.SetRange("No.",InvDetail."Item No.");
                // if ItemRequireControll.FindFirst() then begin
                //     if ItemRequireControll."Item Tracking Code" <> '' then begin
                //         ITC.Reset();
                //         ITC.SetRange(Code,ItemRequireControll."Item Tracking Code");
                //         if ITC.FindFirst() then begin
                //             if ITC."Lot Sales Inbound Tracking" then
                //                 AssignLotNo(SIL,SIH);
                //             if ITC."SN Sales Inbound Tracking" then
                //                 AssignSerialNo(SIH,SIL,'Serial No.');
                //         end;
                //     end;
                // end;
            until InvDetail.Next() = 0;
        end;

    end;

    procedure CreateAsmOrder(Cusbill: Record "NDC-API Customer Bills"; SaleInL: Record "Sales Line")
    var
        AsmH: Record "Assembly Header";
        AssemblyLineMgt: Codeunit "Assembly Line Management";
    begin
        Clear(AssemblyLineMgt);

        AsmH.Init();
        AsmH."Document Type" := AsmH."Document Type"::Order;
        AsmH.Insert(true);
        AsmH.Validate("Item No.", SaleInL."No.");
        AsmH.Validate("Location Code", SaleInL."Location Code");
        AsmH.Validate("Posting Date", Cusbill."Bill Date");
        AsmH.Validate(Quantity, SaleInL.Quantity);
        AsmH."NDC-Bill No." := Cusbill."Bill No";
        AsmH."NDC-Bill Line No." := SaleInL."Line No.";
        AsmH.Modify();

        AssemblyLineMgt.UpdateAssemblyLines(AsmH, AsmH, 0, true, AsmH.FieldNo(Quantity), 0);
    end;

    procedure CreatePayment(CusBill: Record "NDC-API Customer Bills")
    var
        PayAPI: Record "NDC-Payment Term";
        PayMap: Record "NDC-PaymentCode Api Mapping";
        GenJNL: Record "Gen. Journal Line";
        GenJNLSearch: Record "Gen. Journal Line";
        Line: Integer;
        BranchMap: Record "NDC-Branch Api Mapping";
    begin

        BranchMap.Reset();
        BranchMap.setrange("Branch Code", CusBill."Shop Code");
        if BranchMap.FindSet() then begin
        end;
        PayAPI.Reset();
        PayAPI.setrange("Transaction ID", CusBill."Transaction ID");
        PayAPI.setrange("Bill No", CusBill."Bill No");
        if PayAPI.FindSet() then begin
            repeat

                PayMap.Reset();
                PayMap.SetRange("Payment Code", PayAPI."Payment Code");
                if PayMap.FindSet() then begin
                    GenJNLSearch.Reset();
                    GenJNLSearch.setrange("Journal Template Name", 'CASH RECE');
                    GenJNLSearch.setrange("Journal Batch Name", PayMap."Cash Receive Batch");
                    if GenJNLSearch.FindLast() then begin
                        line := GenJNLSearch."Line No." + 10000;
                    end else begin
                        line := 10000;
                    end;
                    GenJNL.Init();
                    GenJNL."Journal Template Name" := 'CASH RECE';
                    GenJNL."Journal Batch Name" := PayMap."Cash Receive Batch";
                    GenJNL."Line No." := line;
                    GenJNL.Insert();
                    GenJNL.validate("Document No.", PayAPI."Bill No");
                    GenJNL.Validate("Posting Date", CusBill."Bill Date");
                    GenJNL.Validate("Account Type", PayMap."Account Type");
                    GenJNL.validate("Account No.", PayMap."Account No.");
                    GenJNL.Validate("Bal. Account Type", PayMap."Bal. Account Type");
                    GenJNL.Validate("Bal. Account No.", PayMap."Bal. Account No.");
                    GenJNL.Validate(Amount, PayAPI.Amount);
                    if BranchMap."Shortcut Dimension 1 Code" <> '' then begin
                        GenJNL.validate("Shortcut Dimension 1 Code", BranchMap."Shortcut Dimension 1 Code");
                    end;
                    if BranchMap."Shortcut Dimension 2 Code" <> '' then begin
                        GenJNL.validate("Shortcut Dimension 2 Code", BranchMap."Shortcut Dimension 2 Code");
                    end;
                    GenJNL."NDC-Bill No." := PayAPI."Bill No";
                    GenJNL.Modify();
                end;

            until PayAPI.Next() = 0;
        end;
    end;

    // ***** This procedure is used to assign a lot number to items with lot control *****
    procedure AssignLotNo(SaleInL: Record "Sales Line"; SaleH: Record "Sales Header")
        var
            ItemLedgEntry: Record "Item Ledger Entry";
            ResrvEntry: Record "Reservation Entry";

            QtyToAssign: Decimal;
            QtyFromThisLot: Decimal;
            LotAvailableQty: Decimal;
        begin
            QtyToAssign := SaleInL."Quantity (Base)";

            // --- Filter Item Ledger Entry to find open lots and create reservations ---
            ItemLedgEntry.SetCurrentKey("Item No.", "Open", "Location Code", "Lot No.");
            ItemLedgEntry.SetRange("Item No.", SaleInL."No.");
            ItemLedgEntry.SetRange("Open", true);
            ItemLedgEntry.SetRange("Location Code", SaleInL."Location Code");
            ItemLedgEntry.SetFilter("Lot No.", '<>%1', '');
            if ItemLedgEntry.FindSet() then begin
                repeat
                    if QtyToAssign <= 0 then break;

                    // --- Check real time remain quantity in each lot ---
                    if not LotRealTimeBalance.ContainsKey(ItemLedgEntry."Lot No.") then begin
                        LotAvailableQty := ItemLedgEntry."Remaining Quantity";
                        LotRealTimeBalanceManagement(ItemLedgEntry."Lot No.",ItemLedgEntry."Remaining Quantity"); // Add lot to dict
                    end else begin
                        LotAvailableQty := LotRealTimeBalance.Get(ItemLedgEntry."Lot No.");
                    end;
                    
                    // --- No remain qunatity left for this lot --- 
                    if LotAvailableQty <= 0 then continue;

                    // --- Calculate assignable quantity ---
                    if LotAvailableQty >= QtyToAssign then begin
                        QtyFromThisLot := QtyToAssign
                    end else begin
                        QtyFromThisLot := LotAvailableQty;
                    end;

                    // --- If select form current lot ---
                    if QtyFromThisLot > 0 then begin
                        CreateReservation(ItemLedgEntry,SaleInL,QtyFromThisLot);
                        LotRealTimeBalanceManagement(ItemLedgEntry."Lot No.", QtyFromThisLot); // modify dic value
                    end;

                    QtyToAssign -= QtyFromThisLot;
                until ItemLedgEntry.Next() = 0;
                
                // --- Check if not all quantity was assigned ---
                if QtyToAssign > 0 then begin
                    FailPostDictManagement(
                        SaleInL."Document No.",
                        StrSubstNo(
                            'Lot assignment incomplete: Required = %1, Assigned = %2, Item = %3',
                            SaleInL."Quantity (Base)", SaleInL."Quantity (Base)" - QtyToAssign, SaleInL."No."));
                end;
            end else begin
                FailPostDictManagement(SaleInL."Document No.",
                    StrSubstNo(
                        'No available lot found in location: Item=%1, Location=%2',
                        SaleInL."No.",SaleInL."Location Code"));
            end;
        end;

    // ***** This procedure is used to assign a serial number to items with serial control *****
    procedure AssignSerialNo(SaleH: Record "Sales Header"; SaleInL: Record "Sales Line"; SerialNo: Code[50])
        var
            ItemLedgEntry: Record "Item Ledger Entry";
            ResvEntry: Record "Reservation Entry";

            QtyToAssign: Decimal;
            ILEMatch: Boolean;
        begin
            ILEMatch := false;
            QtyToAssign := SaleInL."Quantity (Base)";

            // --- Filter Item Ledger Entry ---
            ItemLedgEntry.SetCurrentKey("Item No.", "Open", "Location Code");
            ItemLedgEntry.SetRange("Item No.", SaleInL."No.");
            ItemLedgEntry.SetRange("Open", true);
            ItemLedgEntry.SetRange("Location Code", SaleInL."Location Code");
            if ItemLedgEntry.FindSet() then begin
                repeat
                    if QtyToAssign <= 0 then break;
                    if ItemLedgEntry."Serial No." = SerialNo then begin
                        ILEMatch := true;
                        CreateReservation(ItemLedgEntry,SaleInL,1);
                        QtyToAssign -= 1;
                    end;
                    if QtyToAssign <= 0 then exit;
                until ItemLedgEntry.Next() = 0;
                if not ILEMatch then begin
                    FailPostDictManagement(SaleH."No.",
                        StrSubstNo('No Serial Match in location : Item=%1, SerialNo=%2, Location=%3 ',
                        SaleInL."No.",SerialNo,SaleInL."Location Code"));
                end;
            end else begin
                FailPostDictManagement(SaleH."No.",
                    StrSubstNo('No available stock found in location : Item=%1, Location=%2',
                    SaleInL."No.",SaleInL."Location Code"));
            end;
        end;
    
    // ***** This procedure is used to create reservation.Demand side and supply side *****
    local procedure CreateReservation(ItemLedgEntry: Record "Item Ledger Entry"; SaleInL: Record "Sales Line"; Quantity: Decimal)
        var
            Resrv: Record "Reservation Entry";
            LastEntryNo: Integer;
        begin
            LastEntryNo := LastResvEntryNo();

            // --- Demand Side(Sales Line || Negative Qty) ---
            Resrv.Init();
            Resrv."Entry No." := LastEntryNo;
            Resrv.Positive := false;
            Resrv."Item No." := SaleInL."No.";
            Resrv."Variant Code" := SaleInL."Variant Code";
            Resrv."Location Code" := SaleInL."Location Code";
            Resrv.Validate("Quantity (Base)",-Quantity);
            Resrv."Source Type" := Database::"Sales Line";
            Resrv."Source Subtype" := SaleInL."Document Type".AsInteger();
            Resrv."Source ID" := SaleInL."Document No.";
            Resrv."Source Ref. No." := SaleInL."Line No.";
            Resrv."Reservation Status" := Resrv."Reservation Status"::Reservation;
            Resrv."Creation Date" := WorkDate();
            Resrv."Shipment Date" := SaleInL."Shipment Date";
            if ItemLedgEntry."Lot No." <> '' then
                Resrv.Validate("Lot No.", ItemLedgEntry."Lot No.");
            Resrv.Insert(true);

            // --- Supply Side(Item Ledger Entry || Positive Qty) ---
            Resrv.Init();
            Resrv."Entry No." := LastEntryNo;
            Resrv.Positive := true;
            Resrv."Item No." := SaleInL."No.";
            Resrv."Variant Code" := SaleInL."Variant Code";
            Resrv."Location Code" := SaleInL."Location Code";
            Resrv.Validate("Quantity (Base)",Quantity);
            Resrv."Source Type" := Database::"Item Ledger Entry";
            Resrv."Source ID" := '';
            Resrv."Source Ref. No." := ItemLedgEntry."Entry No.";
            Resrv."Expiration Date" := ItemLedgEntry."Expiration Date";
            Resrv."Reservation Status" := Resrv."Reservation Status"::Reservation;
            Resrv."Creation Date" := WorkDate();
            if ItemLedgEntry."Lot No." <> '' then
                Resrv.Validate("Lot No.", ItemLedgEntry."Lot No.");
            Resrv.Insert(true);
        end;
    
    // ***** This procedure adds or updates an entry in the FailPostDict. *****
    local procedure FailPostDictManagement(DictKey: Code[20]; Value: Text[250])
        begin
            if not FailPostDict.ContainsKey(DictKey) then begin
                FailPostDict.Add(DictKey, Value)
            end else begin
                FailPostDict.Set(DictKey,Value);
            end;
        end;

    // ***** Thsi procedure is used to add or update an entry in LotRealTimeBalance *****
    local procedure LotRealTimeBalanceManagement(LotDictKey: code[50]; Quantity: Decimal)
        begin
            if not LotRealTimeBalance.ContainsKey(LotDictKey) then begin
                LotRealTimeBalance.Add(LotDictKey,Quantity)
            end else begin
                LotRealTimeBalance.Set(LotDictKey,LotRealTimeBalance.Get(LotDictKey)-Quantity);
            end;
        end;
    
    // ***** This procedure returns the next available Entry No. for Reservation Entry. *****
    local procedure LastResvEntryNo(): Integer
        var
            ResvEntry: Record "Reservation Entry";
        begin
            Clear(ResvEntry);
            if ResvEntry.FindLast() then
                exit(ResvEntry."Entry No." + 1)
            else
                exit(1);
        end;
    
    // ***** This procedure is used to log the result of posting a sales invoice. *****
    local procedure Log(SaleH: Record "Sales Header"; SIStatus: Enum "NDC-PostStatus"; SIErrMes: Text[250]; SIDate: DateTime)
        var
            SIPLog: Record "NDC-SalesInvoicesPostLog";
            Location: Record "Location";
        begin
            SIPLog.init();
            SIPLog."Invoice No." := SaleH."No.";
            SIPLog."Customer No." := SaleH."Sell-to Customer No.";
            SIPLog."Customer Name" := SaleH."Sell-to Customer Name";
            SIPLog."Location Code" := SaleH."Location Code";
            
            // --- Map Location Code to Location Name ---
            Location.SetRange(Code, SaleH."Location Code");
            if Location.FindFirst() then begin
                SIPLog."Location Name" := Location.Name;
            end;

            SIPLog."Post Status" := SIStatus;
            SIPLog."Error Message" := SIErrMes;
            SIPLog."Post Attempt DateTime" := SIDate;
            SIPLog."Transaction ID" := SaleH."NDC-Ref. Guid";
            SIPLog.Insert();
        end;

    // ***** This procedure is used to insert a log entry based on whether the invoice failed or succeeded. *****
    local procedure InsertLog(SaleH: Record "Sales Header")
        begin
            if FailPostDict.ContainsKey(SaleH."No.") then begin
                Log(SaleH, Enum::"NDC-PostStatus"::Fail, FailPostDict.Get(SaleH."No."), CurrentDateTime);
            end else begin
                Log(SaleH, Enum::"NDC-PostStatus"::Success, 'Posted without errors', CurrentDateTime);
            end;
        end;
}
