page 90008 "NDC-Ad Payment API"
{
    ApplicationArea = All;
    Caption = 'Ad Payment API';
    PageType = ListPart;
    SourceTable = "NDC-Payment Term";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Payment Code"; Rec."Payment Code")
                {
                    ToolTip = 'Specify payment amount.';
                }
                field("Payment Description"; Rec."Payment Description")
                {
                    ToolTip = 'Specify payment amount.';
                }
                field("Bill No"; Rec."Bill No")
                {
                    ToolTip = 'Specify payment method.';
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specify payment amount.';
                }
            }
        }
    }
}
