tableextension 90004 "NDC-Location" extends "Location"{
    fields{
        field(7701; "NDC-Latitude"; Code[50]){
            Caption = 'Latitude';
            DataClassification = ToBeClassified;
        }field(7702; "NDC-Longitude"; Code[50]){
            Caption = 'Longitude';
            DataClassification = ToBeClassified;
        }
    }
}