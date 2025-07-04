page 90005 "NDC-Payment Mapping"
{
    ApplicationArea = All;
    Caption = 'Payment Mapping';
    PageType = List;
    SourceTable = "NDC-PaymentCode Api Mapping";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Payment Code"; Rec."Payment Code")
                {
                    ToolTip = 'Specifies the value of the Payment Code field.', Comment = '%';
                }
                field("Cash Receive Batch"; Rec."Cash Receive Batch")
                {
                    ToolTip = 'Specifies the value of the Cash Receive Batch field.', Comment = '%';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ToolTip = 'Specifies the value of the Account Type field.', Comment = '%';
                }
                field("Account No."; Rec."Account No.")
                {
                    ToolTip = 'Specifies the value of the Account No. field.', Comment = '%';
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ToolTip = 'Specifies the value of the Bal. Account Type field.', Comment = '%';
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ToolTip = 'Specifies the value of the Bal. Account No. field.', Comment = '%';
                }
            }
        }
    }
}
