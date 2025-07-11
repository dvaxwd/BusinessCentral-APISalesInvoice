page 90011 "NDC-SalesInvoicesPostLog"{
    Caption = 'Sales Invoices Post Log';
    ApplicationArea = All;
    SourceTable = "NDC-SalesInvoicesPostLog";
    PageType = List;
    UsageCategory = Administration;
    Editable = false;
    layout{
        area(Content){
            repeater(SILPostLog){
                field("EntryNo."; Rec."Entry No."){
                    Caption = 'Entry No.';
                    ApplicationArea = All;
                }field("InvoiceNo."; Rec."Invoice No."){
                    Caption = 'Invoice No.';
                    ApplicationArea = All;
                    DrillDownPageId = "Sales Invoice";
                }field("CustomerNo."; Rec."Customer No."){
                    Caption = 'Sell-to Customer No.';
                    ApplicationArea = All;
                }field(CustomerName; Rec."Customer Name"){
                    Caption = 'Sell-to Customer Name';
                    ApplicationArea = All;
                }field(LocationCode; Rec."Location Code"){
                    Caption = 'Location Code';
                    ApplicationArea = All;
                }field(LocationName; Rec."Location Name"){
                    Caption = 'Location Name';
                    ApplicationArea = All;
                }field(PostStatus; Rec."Post Status"){
                    Caption = 'Post Status';
                    ApplicationArea = All;
                }field(ErrorMessage; Rec."Error Message"){
                    Caption = 'Reason for Posting Failure';
                    ApplicationArea = All;
                }field(PostAttemptDateTime; Rec."Post Attempt DateTime"){
                    Caption = 'Post Attemp Date/Time';
                    ApplicationArea = All;
                }field(TransactionID; Rec."Transaction ID"){
                    Caption = 'Transaction ID';
                    ApplicationArea = All;
                }
            }
        }
    }
}