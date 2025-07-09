codeunit 90000 "NDC-GenerateInvoiceAPI"
{
    procedure ProcessToCreateInv(TransectionRec: Record "NDC-Transaction DateTime")
    var
        CusBillRec: Record "NDC-API Customer Bills";
        BranchMap: Record "NDC-Branch Api Mapping";
        SH: Record "Sales Header";
        SalesCalcDiscByType: Codeunit "Sales - Calc Discount By Type";

        APISetup: Record "NDC-API Global Setup";
        SalesBatchPostMgt: Codeunit "Sales Batch Post Mgt.";
        SHtoPost: Record "Sales Header";
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

                ItemRequireLot.Reset();
                ItemRequireLot.SetRange("No.", InvDetail."Item No.");
                if ItemRequireLot.FindSet() then begin
                    repeat
                        if ItemRequireLot."Item Tracking Code" <> '' then begin
                            AssignLotNo(SIL);
                        end;
                    until ItemRequireLot.Next() = 0;
                end;


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

    procedure AssignLotNo(SaleInL: Record "Sales Line")
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ResrvEntry: Record "Reservation Entry";
        EntrySummary: Record "Entry Summary" temporary;

        QtyToAssign: Decimal;
        QtyFromThisLot: Decimal;
        LastReservEntryNo: Integer;
    begin
        QtyToAssign := SaleInL."Quantity (Base)";
        EntrySummary.DeleteAll();
        // ***** Filter Item Ledger Entry: หาล็อตที่ยังเหลือในสต๊อก ไปใส่ใน Entry Summary เพื่อหา lot ที่ใช้ได้*****
        ItemLedgEntry.SetCurrentKey("Item No.", "Open", "Location Code", "Lot No.");
        ItemLedgEntry.SetRange("Item No.", SaleInL."No.");
        ItemLedgEntry.SetRange("Open", true);
        ItemLedgEntry.SetRange("Location Code", SaleInL."Location Code");
        ItemLedgEntry.SetFilter("Lot No.", '<>%1', '');
        if ItemLedgEntry.FindSet() then begin
            repeat
                EntrySummary.Init();
                EntrySummary."Entry No." := ItemLedgEntry."Entry No.";
                EntrySummary."Lot No." := ItemLedgEntry."Lot No.";
                EntrySummary."Total Quantity" := ItemLedgEntry.Quantity;
                EntrySummary."Expiration Date" := ItemLedgEntry."Expiration Date";
                EntrySummary."Total Available Quantity" := ItemLedgEntry."Remaining Quantity";
                EntrySummary.Insert();
            until ItemLedgEntry.Next() = 0;
        end else begin
            Log('AssignLotNo Warning', 'No available lots found for Item ' + SaleInL."No.");
        end;

        // ***** Find Last Entry No. *****
        if ResrvEntry.FindLast() then
            LastReservEntryNo := ResrvEntry."Entry No."
        else
            LastReservEntryNo := 0;

        // ***** Loop EntrySummary ที่เก็บ lot ที่สามารถใช้ได้ เพื่อทำการ Insert ข้อมูลไปยัง Reservation Entry *****
        if EntrySummary.FindSet() then begin
            repeat
                if QtyToAssign <= 0 then break;

                // ****** Assign จำนวนที่จะหยิบจาก Lot ปัจจุบัน *****
                if EntrySummary."Total Available Quantity" >= QtyToAssign then begin
                    QtyFromThisLot := QtyToAssign
                end else begin
                    QtyFromThisLot := EntrySummary."Total Available Quantity";
                end;

                // ***** ถ้าหยิบจาก Lot ปัจจุบัน *****
                if QtyFromThisLot > 0 then begin
                    LastReservEntryNo += 1;

                    // --- ขา Demand (ฝั่ง Sales Line / -ve Qty) ---
                    ResrvEntry.Init();
                    ResrvEntry."Entry No." := LastReservEntryNo;
                    ResrvEntry.Positive := false;
                    ResrvEntry."Item No." := SaleInL."No.";
                    ResrvEntry."Variant Code" := SaleInL."Variant Code";
                    ResrvEntry."Location Code" := SaleInL."Location Code";
                    ResrvEntry.Validate("Quantity (Base)", -QtyFromThisLot);
                    ResrvEntry."Source Type" := DATABASE::"Sales Line";
                    ResrvEntry."Source Subtype" := SaleInL."Document Type".AsInteger();
                    ResrvEntry."Source ID" := SaleInL."Document No.";
                    ResrvEntry."Source Ref. No." := SaleInL."Line No.";
                    ResrvEntry.Validate("Lot No.", EntrySummary."Lot No.");
                    ResrvEntry."Reservation Status" := ResrvEntry."Reservation Status"::Reservation;
                    ResrvEntry."Creation Date" := WorkDate();
                    ResrvEntry."Shipment Date" := SaleInL."Shipment Date";
                    ResrvEntry.Insert(true);

                    // --- ขา Supply (ฝั่ง ILE / +ve Qty) ---
                    ResrvEntry.Init();
                    ResrvEntry."Entry No." := LastReservEntryNo; // ต้องใช้เลขเดียวกัน
                    ResrvEntry.Positive := true;
                    ResrvEntry."Item No." := SaleInL."No.";
                    ResrvEntry."Variant Code" := SaleInL."Variant Code";
                    ResrvEntry."Location Code" := SaleInL."Location Code";
                    ResrvEntry.Validate("Quantity (Base)", QtyFromThisLot);
                    ResrvEntry."Source Type" := DATABASE::"Item Ledger Entry";
                    ResrvEntry."Source ID" := '';
                    ResrvEntry."Source Ref. No." := EntrySummary."Entry No."; // ชี้ไปที่ ILE
                    ResrvEntry.Validate("Lot No.", EntrySummary."Lot No.");
                    ResrvEntry."Expiration Date" := EntrySummary."Expiration Date";
                    ResrvEntry."Reservation Status" := ResrvEntry."Reservation Status"::Reservation;
                    ResrvEntry."Creation Date" := WorkDate();
                    ResrvEntry.Insert(true);
                end;

                QtyToAssign -= QtyFromThisLot;
            until EntrySummary.Next() = 0;
        end;
    end;

    local procedure Log(Tag: Text[50]; Message: Text[250])
    var
        APILog: Record "NDC-API Log";
    begin
        APILog.Init();
        APILog."LOGTimestamp" := CurrentDateTime();
        APILog.Tag := Tag;
        APILog.Message := Message;
        APILog.Insert();
        Commit();
    end;
}
