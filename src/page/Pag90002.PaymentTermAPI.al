page 90002 "NDC-Payment Term API"
{
    PageType = API;
    Caption = 'Payment Term API';
    APIPublisher = 'newdawn';
    APIGroup = 'API';
    APIVersion = 'v1.0';
    EntityName = 'paymenttermapi';
    EntitySetName = 'paymenttermapi';
    SourceTable = "NDC-Payment Term";
    DelayedInsert = true;
    AutoSplitKey = true;
    // ApplicationArea = all;
    // UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(BillNo; rec."Bill No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify payment method.';
                }
                field(PaymentCode; rec."Payment Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify payment amount.';
                }
                field(PaymentDescription; rec."Payment Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify payment amount.';
                }
                field(Amount; rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify payment amount.';
                }
            }
        }
    }
}