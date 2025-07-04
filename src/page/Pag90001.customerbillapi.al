page 90001 "NDC-customerbillapi"
{
    PageType = API;
    Caption = 'customerbillapi';
    SourceTable = "NDC-API Customer Bills";
    APIPublisher = 'newdawn';
    APIGroup = 'API';
    APIVersion = 'v1.0';
    EntityName = 'cusbillapi';
    EntitySetName = 'cusbillapi';
    DelayedInsert = true;
    AutoSplitKey = true;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(TransactionID; Rec."Transaction ID")
                {
                    ApplicationArea = All;
                    // ToolTip = 'Specifies the value of the AmountBeforeVAT field.';
                }
                field(InvoiceNo; Rec."InvoiceNo")
                {
                    ApplicationArea = All;
                    // ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                }
                field(BillNo; Rec."Bill No")
                {
                    ApplicationArea = All;
                    // ToolTip = 'Specifies the value of the Doc ID field.';
                }
                field(ShopCode; Rec."Shop Code")
                {
                    ApplicationArea = All;
                    // ToolTip = 'Specifies the value of the SystemCreatedBy field.';
                }
                field(ShopName; Rec."Shop Name")
                {
                    ApplicationArea = All;
                    // ToolTip = 'Specifies the value of the SystemId field.';
                }
                field(TerminalNo; Rec."Terminal No")
                {
                    ApplicationArea = All;
                    // ToolTip = 'Specifies the value of the SystemModifiedAt field.';
                }
                field(Mode; Rec."Mode")
                {
                    ApplicationArea = All;
                    // ToolTip = 'Specifies the value of the amount field.';
                }
                field(BillDate; Rec."Bill Date")
                {
                    ApplicationArea = All;
                    // ToolTip = 'Line discount Amount';
                }
                field(BillTime; Rec."Bill Time")
                {
                    ApplicationArea = All;
                    // ToolTip = 'Line discount Amount';
                }
                field(TableNo; Rec."Table No")
                {
                    ApplicationArea = All;
                    // ToolTip = 'An item no. for import to item no.';
                }
                field(MemberCode; Rec."Member Code")
                {
                    ApplicationArea = All;
                    // ToolTip = 'Specifies the value of the lineNo field.';
                }
                field(MemberName; Rec."Member Name")
                {
                    ApplicationArea = All;
                    // ToolTip = 'Specifies the value of the lineNo field.';
                }
                field(TotalLineDiscount; Rec."Total Line Discount")
                {
                    ApplicationArea = all;
                }
                field(TotalInvDiscount; Rec."Total Inv. Discount")
                {
                    ApplicationArea = all;
                }
                field(TotalDiscount; Rec."Total Discount")
                {
                    ApplicationArea = all;
                }
                field(TotalAmount; Rec."Total Amount")
                {
                    ApplicationArea = all;
                }
                field(TotalVatAmount; Rec."Total Vat Amount")
                {
                    ApplicationArea = all;
                }
                field(TotalAmountIncVat; Rec."Total Amount Inc.Vat")
                {
                    ApplicationArea = all;
                }
                field(CustCount; Rec."Cust Count")
                {
                    ApplicationArea = All;
                    // ToolTip = 'Specify volume of item.';
                }
            }
        }
    }
}
