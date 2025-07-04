table 90005 "NDC-PaymentCode Api Mapping"
{
    Caption = 'PaymentCode Api Mapping';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Payment Code"; Code[20])
        {
            Caption = 'Payment Code';
        }
        field(2; "Cash Receive Batch"; Code[20])
        {
            Caption = 'Cash Receive Batch';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = const('CASH RECE'));
        }
        field(3; "Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type';
        }
        field(4; "Account No."; Code[10])
        {
            Caption = 'Account No.';
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account" where("Account Type" = const(Posting),
                                                                                          Blocked = const(false))
            else
            if ("Account Type" = const(Customer)) Customer
            else
            if ("Account Type" = const(Vendor)) Vendor
            else
            if ("Account Type" = const("Bank Account")) "Bank Account"
            else
            if ("Account Type" = const("Fixed Asset")) "Fixed Asset"
            else
            if ("Account Type" = const("IC Partner")) "IC Partner"
            else
            if ("Account Type" = const("Allocation Account")) "Allocation Account"
            else
            if ("Account Type" = const(Employee)) Employee;
        }
        field(5; "Bal. Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Bal. Account Type';
        }
        field(6; "Bal. Account No."; Code[10])
        {
            Caption = 'Bal. Account No.';
            TableRelation = if ("Bal. Account Type" = const("G/L Account")) "G/L Account" where("Account Type" = const(Posting),
                                                                                          Blocked = const(false))
            else
            if ("Bal. Account Type" = const(Customer)) Customer
            else
            if ("Bal. Account Type" = const(Vendor)) Vendor
            else
            if ("Bal. Account Type" = const("Bank Account")) "Bank Account"
            else
            if ("Bal. Account Type" = const("Fixed Asset")) "Fixed Asset"
            else
            if ("Bal. Account Type" = const("IC Partner")) "IC Partner"
            else
            if ("Bal. Account Type" = const("Allocation Account")) "Allocation Account"
            else
            if ("Bal. Account Type" = const(Employee)) Employee;
        }
    }
    keys
    {
        key(PK; "Payment Code")
        {
            Clustered = true;
        }
    }
}
