page 90006 "NDC-Admin Bill Transection"
{
    ApplicationArea = All;
    Caption = 'Admin Bill Transection';
    PageType = List;
    SourceTable = "NDC-Transaction DateTime";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Transaction ID"; Rec."Transaction ID")
                {
                    ToolTip = 'Specifies the value of the Transaction ID field.', Comment = '%';
                }
                field("Transection Date"; Rec."Transection Date")
                {
                    ApplicationArea = all;
                }
                field("Transection Time"; Rec."Transection Time")
                {
                    ApplicationArea = all;
                }
                field("Bill Count"; Rec."Bill Count")
                {
                    ToolTip = 'Specifies the value of the Bill Count field.', Comment = '%';
                }
            }
            part(Bill; "NDC-BillHeader")
            {
                ApplicationArea = All;
                SubPageLink = "Transaction ID" = field("Transaction ID");
                UpdatePropagation = Both;
            }
            part(detail; "NDC-AdInvDetail")
            {
                ApplicationArea = All;
                SubPageLink = "Transaction ID" = field("Transaction ID");
                UpdatePropagation = Both;
            }
            part(pay; "NDC-Ad Payment API")
            {
                ApplicationArea = All;
                SubPageLink = "Transaction ID" = field("Transaction ID");
                UpdatePropagation = Both;
            }
        }
    }
}
