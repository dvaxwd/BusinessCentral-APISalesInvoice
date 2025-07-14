page 90011 "NDC-SalesInvoicesPostLog"
{
    Caption = 'Sales Invoices Post Log';
    ApplicationArea = All;
    SourceTable = "NDC-SalesInvoicesPostLog";
    PageType = List;
    UsageCategory = Administration;
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(SILPostLog)
            {
                field("EntryNo."; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                    ApplicationArea = All;
                }
                field("InvoiceNo."; Rec."Invoice No.")
                {
                    Caption = 'Invoice No.';
                    ApplicationArea = All;
                    DrillDownPageId = "Sales Invoice";
                }
                field("CustomerNo."; Rec."Customer No.")
                {
                    Caption = 'Sell-to Customer No.';
                    ApplicationArea = All;
                }
                field(CustomerName; Rec."Customer Name")
                {
                    Caption = 'Sell-to Customer Name';
                    ApplicationArea = All;
                }
                field(LocationCode; Rec."Location Code")
                {
                    Caption = 'Location Code';
                    ApplicationArea = All;
                }
                field(LocationName; Rec."Location Name")
                {
                    Caption = 'Location Name';
                    ApplicationArea = All;
                }
                field(PostStatus; Rec."Post Status")
                {
                    Caption = 'Post Status';
                    ApplicationArea = All;
                    StyleExpr = PostStatusStyleText;
                }
                field(ErrorMessage; Rec."Error Message")
                {
                    Caption = 'Reason for Posting Failure';
                    ApplicationArea = All;
                }
                field(PostAttemptDateTime; Rec."Post Attempt DateTime")
                {
                    Caption = 'Post Attemp Date/Time';
                    ApplicationArea = All;
                }
                field(TransactionID; Rec."Transaction ID")
                {
                    Caption = 'Transaction ID';
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        case Rec."Post Status" of
            "NDC-PostStatus"::Fail:
                PostStatusStyleText := 'Attention';  // แดง
            "NDC-PostStatus"::Success:
                PostStatusStyleText := 'Favorable';  // เขียว
            else
                PostStatusStyleText := '';
        end;
    end;

    local procedure GetPostStatusStyle(): Text
    begin
        case Rec."Post Status" of
            "NDC-PostStatus"::Fail:
                exit('Attention');     // สีแดง
            "NDC-PostStatus"::Success:
                exit('Favorable');     // สีเขียว
            else
                exit('');
        end;
    end;

    var
        PostStatusStyleText: Text;
}