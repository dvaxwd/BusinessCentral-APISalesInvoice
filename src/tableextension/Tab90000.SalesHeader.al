tableextension 90000 "NDC-Sales Header" extends "Sales Header"
{
    fields
    {
        field(90000; "NDC-Bill No."; Code[20])
        {
            Caption = 'Bill No.';
            DataClassification = ToBeClassified;
        }
        field(90001; "NDC-Ref. Guid"; guid)
        {
            Caption = 'Ref. Guid';
            DataClassification = ToBeClassified;
        }
    }
}
