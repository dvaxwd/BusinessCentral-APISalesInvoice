table 90002 "NDC-Invoice Detail"
{
    Caption = 'Invoice Detail';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Transaction ID"; Guid)
        {
            DataClassification = ToBeClassified;
            TableRelation = "NDC-Transaction DateTime"."Transaction ID";
            Caption = 'Transaction ID';
        }
        field(2; lineno; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Bill No"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Bill No';
        }
        field(4; "Detail Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Description; text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(7; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Unit Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Line Discount Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Vat %"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Vat Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Amount Inc. VAT"; Decimal)
        {
            DataClassification = ToBeClassified;
        }field(14; "Serial No."; Code[50]){
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Transaction ID", "lineno")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;
}