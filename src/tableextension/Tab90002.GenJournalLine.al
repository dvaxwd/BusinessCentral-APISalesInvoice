tableextension 90002 "NDC-Gen. Journal Line" extends "Gen. Journal Line"
{
    fields
    {
        field(90000; "NDC-Bill No."; Code[20])
        {
            Caption = 'Bill No.';
            DataClassification = ToBeClassified;
        }
    }
}
