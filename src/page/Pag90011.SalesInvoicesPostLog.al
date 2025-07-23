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
                    Style = Strong;
                    StyleExpr = PostStatusStyleText;
                }
                field(ErrorMessage; Rec."Error Message")
                {
                    Caption = 'Description';
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
    actions
    {
        area(Promoted)
        {
            group(ActionPromote)
            {
                Caption = 'Action';
                actionref(GoToSalePromote; GoToSale) { }
                actionref(GoToPostSalePromote; GoToPostSale){}
            }
        }
        area(Processing)
        {
            group(ActionProcess)
            {
                action(GoToSale)
                {
                    Caption = 'Open Sale Invoice';
                    Image = View;
                    ApplicationArea = All;
                    Enabled = Rec."Post Status" = Enum::"NDC-PostStatus"::Fail;
                    trigger OnAction()
                    var
                        SalesInvoiceRec: Record "Sales Header";
                    begin
                        SalesInvoiceRec.SetRange("No.", Rec."Invoice No.");
                        SalesInvoiceRec.SetRange("Document Type", SalesInvoiceRec."Document Type"::Invoice);
                        if SalesInvoiceRec.FindFirst() then
                            PAGE.Run(PAGE::"Sales Invoice", SalesInvoiceRec);
                    end;
                }
                action(GoToPostSale){
                    Caption = 'Open Posted Sale Invoice';
                    ApplicationArea = All;
                    Enabled = Rec."Post Status" = Enum::"NDC-PostStatus"::Success;
                    trigger OnAction()
                        var
                            PostSaleInvoice: Record "Sales Invoice Header";
                        begin
                            PostSaleInvoice.SetRange("NDC-Ref. Guid",Rec."Transaction ID");
                            PostSaleInvoice.SetRange("Pre-Assigned No.",Rec."Invoice No.");
                            if PostSaleInvoice.FindFirst() then
                                Page.Run(Page::"Posted Sales Invoice",PostSaleInvoice);
                        end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateLog();
        Poststyle();
    end;

    var
        PostStatusStyleText: Text;

    local procedure Poststyle()
    begin
        case Rec."Post Status" of
            "NDC-PostStatus"::Fail:
                PostStatusStyleText := 'Unfavorable';
            "NDC-PostStatus"::Success:
                PostStatusStyleText := 'Favorable';
            else
                PostStatusStyleText := '';
        end;
    end;

    local procedure UpdateLog()
    var
        Log: Record "NDC-SalesInvoicesPostLog";
        SaleH: Record "Sales Header";
    begin
        Log.SetRange("Post Status", Enum::"NDC-PostStatus"::Fail);
        if Log.FindSet() then
            repeat
                SaleH.Reset();
                SaleH.SetRange("No.", Log."Invoice No.");
                if SaleH.FindFirst() then begin
                    if SaleH."Sell-to Customer No." <> Log."Customer No." then begin
                        Log."Post Status" := Enum::"NDC-PostStatus"::Success;
                        Log."Error Message" := 'Sales Invoice found but customer does not match. Possibly modified or posted.';
                        Log.Modify();
                    end;
                end else begin
                    Log."Post Status" := Enum::"NDC-PostStatus"::Success;
                    Log."Error Message" := 'Sales Invoice not found. Possibly posted or deleted.';
                    Log.Modify();
                end;
            until Log.Next() = 0;
    end;
}