table 90006 "NDC-API Global Setup"
{
    Caption = 'API Global Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Auto Post Sales Invoice"; Boolean)
        {
            Caption = 'Auto Post Sales Invoice';
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
