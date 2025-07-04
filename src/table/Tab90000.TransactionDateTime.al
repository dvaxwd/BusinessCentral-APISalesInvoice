table 90000 "NDC-Transaction DateTime"
{
    Caption = 'Transaction DateTime';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Transaction ID"; Guid)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "API DateTime"; DateTime)
        {
            Caption = 'API Date Time';
            DataClassification = ToBeClassified;
        }
        field(3; "Bill Count"; Integer)
        {
            Caption = 'Bill Count';
            DataClassification = ToBeClassified;
        }
        field(4; "Transection Date"; Date)
        {
            Caption = 'Transection Date';
            DataClassification = ToBeClassified;
        }
        field(5; "Transection Time"; Time)
        {
            Caption = 'Transection Time';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Transaction ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Transaction ID" := CreateGuid();
        "API DateTime" := CurrentDateTime;
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        CusBill: Record "NDC-API Customer Bills";
        InvDetail: Record "NDC-Invoice Detail";
        Payment: Record "NDC-Payment Term";
        SH: Record "Sales Header";

    begin
        CusBill.Reset();
        CusBill.setrange("Transaction ID", rec."Transaction ID");
        CusBill.DeleteAll();

        InvDetail.Reset();
        InvDetail.setrange("Transaction ID", rec."Transaction ID");
        InvDetail.DeleteAll();

        Payment.Reset();
        Payment.setrange("Transaction ID", rec."Transaction ID");
        Payment.DeleteAll();

    end;

    trigger OnRename()
    begin

    end;
}