table 90007 "NDC-API Log"{
    DataClassification = CustomerContent;
    Caption = 'API Log';
    fields{
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; LOGTimestamp; DateTime)
        {
            Caption = 'Timestamp';
        }
        field(3; Tag; Text[50])
        {
            Caption = 'Tag';
        }
        field(4; "Message"; Text[250])
        {
            Caption = 'Message';
        }
    }
    keys{
        key(PK; "Entry No."){
            Clustered = true;
        }
    }
}