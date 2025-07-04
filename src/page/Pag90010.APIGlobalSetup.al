page 90010 "NDC-API Global Setup"
{
    ApplicationArea = All;
    Caption = 'API Global Setup';
    PageType = Card;
    SourceTable = "NDC-API Global Setup";
    DeleteAllowed = false;
    InsertAllowed = false;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Auto Post Sales Invoice"; Rec."Auto Post Sales Invoice")
                {
                    ToolTip = 'Specifies the value of the Auto Post Sales Invoice field.', Comment = '%';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            OnOpenPageOnBeforeRecInsert(Rec);
            Rec.Insert();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnOpenPageOnBeforeRecInsert(var APISetup: Record "NDC-API Global Setup")
    begin
    end;
}
