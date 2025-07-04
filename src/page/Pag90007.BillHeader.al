page 90007 "NDC-BillHeader"
{
    ApplicationArea = All;
    Caption = 'BillHeader';
    PageType = ListPart;
    SourceTable = "NDC-API Customer Bills";
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
                field(lineNo; Rec.lineNo)
                {
                    ToolTip = 'Specifies the value of the lineNo field.', Comment = '%';
                }
                field(InvoiceNo; Rec.InvoiceNo)
                {
                    ToolTip = 'Specifies the value of the Invoice No field.', Comment = '%';
                }
                field("Bill No"; Rec."Bill No")
                {
                    ToolTip = 'Specifies the value of the Bill No field.', Comment = '%';
                }
                field("Bill Time"; Rec."Bill Time")
                {
                    ToolTip = 'Specifies the value of the Bill Time field.', Comment = '%';
                }
                field("Ent Date"; Rec."Bill Date")
                {
                    ToolTip = 'Specifies the value of the Bill Date field.', Comment = '%';
                }
                field("Member Code"; Rec."Member Code")
                {
                    ToolTip = 'Specifies the value of the Member Code field.', Comment = '%';
                }
                field("Member Name"; Rec."Member Name")
                {
                    ToolTip = 'Specifies the value of the Member Name field.', Comment = '%';
                }
                field(Mode; Rec.Mode)
                {
                    ToolTip = 'Specifies the value of the Mode field.', Comment = '%';
                }
                field("Shop Code"; Rec."Shop Code")
                {
                    ToolTip = 'Specifies the value of the Shop Code field.', Comment = '%';
                }
                field("Shop Name"; Rec."Shop Name")
                {
                    ToolTip = 'Specifies the value of the Shop Name field.', Comment = '%';
                }
                field("Table No"; Rec."Table No")
                {
                    ToolTip = 'Specifies the value of the Table No field.', Comment = '%';
                }
                field("Terminal No"; Rec."Terminal No")
                {
                    ToolTip = 'Specifies the value of the Terminal No field.', Comment = '%';
                }

                field("Total Amount"; Rec."Total Amount")
                {
                    ToolTip = 'Specifies the value of the Total Amount field.', Comment = '%';
                }
                field("Total Amount Inc.Vat"; Rec."Total Amount Inc.Vat")
                {
                    ToolTip = 'Specifies the value of the Total Amount Inc.Vat field.', Comment = '%';
                }
                field("Total Discount"; Rec."Total Discount")
                {
                    ToolTip = 'Specifies the value of the Total Discount field.', Comment = '%';
                }
                field("Total Inv. Discount"; Rec."Total Inv. Discount")
                {
                    ToolTip = 'Specifies the value of the Total Inv. Discount field.', Comment = '%';
                }
                field("Total Line Discount"; Rec."Total Line Discount")
                {
                    ToolTip = 'Specifies the value of the Total Line Discount field.', Comment = '%';
                }
                field("Total Vat Amount"; Rec."Total Vat Amount")
                {
                    ToolTip = 'Specifies the value of the Total Vat Amount field.', Comment = '%';
                }
            }
        }
    }
}
