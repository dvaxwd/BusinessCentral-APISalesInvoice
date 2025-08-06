table 90007 "NDC-SalesInvoicesPostLog"
{
    DataClassification = CustomerContent;
    Caption = 'Sales Invoices Post Log';
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Invoice No."; Code[20])
        {
            Caption = 'Invoice No';
        }
        field(3; "Customer No."; code[20])
        {
            Caption = 'Sell-to Customer No.';
        }
        field(4; "Customer Name"; Text[250])
        {
            Caption = 'Sell-to Customer Name';
        }
        field(5; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
        }
        field(6; "Location Name"; Text[100])
        {
            Caption = 'Location Name';
        }
        field(7; Amount; Decimal){
            Caption = 'Amount';
        }
        field(8; "Post Status"; Enum "NDC-PostStatus")
        {
            Caption = 'Post Status';
        }
        field(9; "Error Message"; Text[1000])
        {
            Caption = 'Error Message';
        }
        field(10; "Post Attempt DateTime"; DateTime)
        {
            Caption = 'Post Attempt Date/Time';
        }
        field(11; "Transaction ID"; Guid)
        {
            Caption = 'Transaction ID';
        }field(12; "Log Code"; Code[10]){
            caption = 'Log Code';
            trigger Onvalidate()
                var
                    LogCode: Record "NDC-LogCode";
                begin

                end;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

}