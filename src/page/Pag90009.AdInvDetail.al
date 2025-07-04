page 90009 "NDC-AdInvDetail"
{
    ApplicationArea = All;
    Caption = 'AdInvDetail';
    PageType = ListPart;
    SourceTable = "NDC-Invoice Detail";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Bill No"; Rec."Bill No")
                {
                    ToolTip = 'Specifies the value of the Bill No field.', Comment = '%';
                }
                field("Detail Line No."; Rec."Detail Line No.")
                {
                    ToolTip = 'Specifies the value of the Detail Line No. field.', Comment = '%';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.', Comment = '%';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the value of the Unit Price field.', Comment = '%';
                }
                field("Line Discount Amount"; Rec."Line Discount Amount")
                {
                    ToolTip = 'Specifies the value of the Line Discount Amount field.', Comment = '%';
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
                field("Vat %"; Rec."Vat %")
                {
                    ToolTip = 'Specifies the value of the Vat % field.', Comment = '%';
                }
                field("Vat Amount"; Rec."Vat Amount")
                {
                    ToolTip = 'Specifies the value of the Vat Amount field.', Comment = '%';
                }
                field("Amount Inc. VAT"; Rec."Amount Inc. VAT")
                {
                    ToolTip = 'Specifies the value of the Amount Inc. VAT field.', Comment = '%';
                }

            }
        }
    }
}
