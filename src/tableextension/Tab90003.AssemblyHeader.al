tableextension 90003 "NDC-Assembly Header" extends "Assembly Header"
{
    fields
    {
        field(90000; "NDC-Bill No."; Code[20])
        {
            Caption = 'Bill No.';
            DataClassification = ToBeClassified;
        }
        field(90001; "NDC-Bill Line No."; integer)
        {
            Caption = 'Bill Line No.';
            DataClassification = ToBeClassified;
        }
    }
}
