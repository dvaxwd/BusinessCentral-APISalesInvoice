table 90003 "NDC-Payment Term"
{
    Caption = 'Payment Term';
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
            Caption = 'Invoice No';
        }
        field(4; "Payment Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Payment Code';
        }
        field(5; "Payment Description"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Payment Description';
        }
        field(6; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Amount';
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