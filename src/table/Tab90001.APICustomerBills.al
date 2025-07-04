table 90001 "NDC-API Customer Bills"
{
    Caption = 'API Customer Bills';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Transaction ID"; Guid)
        {
            DataClassification = ToBeClassified;
            TableRelation = "NDC-Transaction DateTime"."Transaction ID";
            Caption = 'Transaction ID';
        }
        field(2; lineNo; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; InvoiceNo; Code[20])
        {
            Caption = 'Invoice No';
            DataClassification = ToBeClassified;
        }
        field(4; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = ToBeClassified;
        }
        field(5; "Shop Name"; Text[250])
        {
            Caption = 'Shop Name';
            DataClassification = ToBeClassified;
        }
        field(6; "Terminal No"; Code[10])
        {
            Caption = 'Terminal No';
            DataClassification = ToBeClassified;
        }
        field(7; "Bill Date"; Date)
        {
            Caption = 'Bill Date';
            DataClassification = ToBeClassified;
        }
        field(8; Period; Time)
        {
            Caption = 'Period';
            DataClassification = ToBeClassified;
        }
        field(9; Mode; Code[20])
        {
            Caption = 'Mode';
            DataClassification = ToBeClassified;
        }
        field(10; "Bill Time"; Time)
        {
            Caption = 'Bill Time';
            DataClassification = ToBeClassified;
        }
        field(11; "Bill No"; Code[20])
        {
            Caption = 'Bill No';
            DataClassification = ToBeClassified;
        }
        field(12; "Table No"; Code[20])
        {
            Caption = 'Table No';
            DataClassification = ToBeClassified;
        }
        field(13; "Member Name"; Text[100])
        {
            Caption = 'Member Name';
            DataClassification = ToBeClassified;
        }
        field(14; "Cust Count"; Decimal)
        {
            Caption = 'Customer Count';
            DataClassification = ToBeClassified;
        }
        field(15; "Member Code"; code[20])
        {
            Caption = 'Member Code';
            DataClassification = ToBeClassified;
        }
        field(28; "DateTime"; DateTime)
        {
            Caption = 'Date Time';
            DataClassification = ToBeClassified;
        }
        Field(29; "Created"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Total Amount"; decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(31; "Total Amount Inc.Vat"; decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(32; "Total Vat Amount"; decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(33; "Total Discount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(34; "Total Line Discount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(35; "Total Inv. Discount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Transaction ID", lineNo)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        TransactionDateTime: Record "NDC-Transaction DateTime";

    trigger OnInsert()
    var

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