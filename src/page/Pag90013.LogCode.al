page 90013 "NDC-LogCode"{
    Caption = 'Log Code';
    SourceTable = "NDC-LogCode";
    UsageCategory = Administration;
    ApplicationArea = All;
    AutoSplitKey = true;
    layout{
        area(Content){
            repeater(LogCode){
                field(No; Rec.No){
                    Caption = 'No.';
                    ApplicationArea = All;
                    Editable = false;
                }field("Code"; Rec.Code){
                    Caption = 'Code';
                    ApplicationArea = All;
                }field(Description; Rec.Description){
                    Caption = 'Description';
                    ApplicationArea = All;
                }
            }
        }
    }

}