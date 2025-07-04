page 90000 "NDC-Transection DateTime API"
{
    PageType = API;
    Caption = 'Transection DateTime API';
    APIPublisher = 'newdawn';
    APIGroup = 'API';
    APIVersion = 'v1.0';
    EntityName = 'billtoinvoice';
    EntitySetName = 'billtoinvoice';
    SourceTable = "NDC-Transaction DateTime";
    DelayedInsert = true;
    AutoSplitKey = true;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(TransactionID; rec."Transaction ID")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(TransectionDate; Rec."Transection Date")
                {

                }
                field(TransectionTime; Rec."Transection Time")
                {

                }
                field(BillCount; Rec."Bill Count")
                {

                }
                part(cusbillapi; "NDC-customerbillapi")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Bills List';
                    EntityName = 'cusbillapi';
                    EntitySetName = 'cusbillapi';
                    SubPageLink = "Transaction ID" = FIELD("Transaction ID");
                }
                part(billdetail; "NDC-InvoiceDetailApi")
                {
                    ApplicationArea = All;
                    Caption = 'Invdetail';
                    EntityName = 'billdetail';
                    EntitySetName = 'billdetail';
                    SubPageLink = "Transaction ID" = FIELD("Transaction ID");
                }
                part(paymenttermapi; "NDC-Payment Term API")
                {
                    ApplicationArea = All;
                    Caption = 'Payment Term API';
                    EntityName = 'paymenttermapi';
                    EntitySetName = 'paymenttermapi';
                    SubPageLink = "Transaction ID" = FIELD("Transaction ID");
                }
            }
        }
    }
    var
        DeepInset: Boolean;

    trigger OnAfterGetRecord()
    var
        C_GenInv: Codeunit "NDC-GenerateInvoiceAPI";

    begin
        if DeepInset then begin
            CheckDataField();
            clear(C_GenInv);
            C_GenInv.ProcessToCreateInv(rec);
        end;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        DeepInset := true;
    end;

    procedure CheckDataField()
    var
        CusBillRec: Record "NDC-API Customer Bills";
        BranchMap: Record "NDC-Branch Api Mapping";
        PayAPI: Record "NDC-Payment Term";
        PayMap: Record "NDC-PaymentCode Api Mapping";
        InvDetail: Record "NDC-Invoice Detail";
        ItemRec: Record Item;
    begin
        CusBillRec.Reset();
        CusBillRec.setrange("Transaction ID", rec."Transaction ID");
        if CusBillRec.FindSet() then begin
            repeat
                CusBillRec.TestField("Shop Code");
                CusBillRec.TestField("Bill No");
                CusBillRec.TestField("Bill Date");
                BranchMap.Reset();
                BranchMap.setrange("Branch Code", CusBillRec."Shop Code");
                if not BranchMap.FindSet() then begin
                    Error('Please Setup Branch Mapping');
                end else begin
                    BranchMap.TestField("Location Code");
                    BranchMap.TestField("Customer Code");
                end;
                PayAPI.Reset();
                PayAPI.setrange("Transaction ID", CusBillRec."Transaction ID");
                PayAPI.SetRange("Bill No", CusBillRec."Bill No");
                if PayAPI.FindSet() then begin
                    repeat
                        PayAPI.TestField("Payment Code");
                        PayMap.Reset();
                        PayMap.SetRange("Payment Code", PayAPI."Payment Code");
                        if not PayMap.FindSet() then begin
                            Error('Please Setup Payment Mapping');
                        end else begin
                            PayMap.TestField("Cash Receive Batch");
                            PayMap.TestField("Account No.");
                            PayMap.TestField("Bal. Account No.");
                        end;
                    until PayAPI.Next() = 0;
                end;
                InvDetail.Reset();
                InvDetail.SetRange("Transaction ID", CusBillRec."Transaction ID");
                InvDetail.SetRange("Bill No", CusBillRec."Bill No");
                if InvDetail.FindSet() then begin
                    repeat
                        InvDetail.TestField("Item No.");
                        InvDetail.TestField(Quantity);
                        ItemRec.Reset();
                        ItemRec.setrange("No.", InvDetail."Item No.");
                        if not ItemRec.FindSet() then begin
                            Error('Item No. %1 does not exist');
                        end;
                    until InvDetail.Next() = 0;
                end;
            until CusBillRec.Next() = 0;
        end;
    end;
}