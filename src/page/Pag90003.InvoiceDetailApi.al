page 90003 "NDC-InvoiceDetailApi"
{
    APIGroup = 'API';
    APIPublisher = 'newdawn';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'invoiceDetailApi';
    EntityName = 'billdetail';
    EntitySetName = 'billdetail';
    PageType = API;
    SourceTable = "NDC-Invoice Detail";
    DelayedInsert = true;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(BillNo; Rec."Bill No")
                {
                    Caption = 'Bill No';
                }
                field(detailLineNo; Rec."Detail Line No.")
                {
                    Caption = 'Detail Line No.';
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price';
                }
                field(lineDiscountAmount; Rec."Line Discount Amount")
                {
                    Caption = 'Line Discount Amount';
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount';
                }
                field(vatPer; Rec."Vat %")
                {
                    Caption = 'Vat %';
                }
                field(vatAmount; Rec."Vat Amount")
                {
                    Caption = 'Vat Amount';
                }
                field(amountIncVAT; Rec."Amount Inc. VAT")
                {
                    Caption = 'Amount Inc. VAT';
                }
            }
        }
    }
}
