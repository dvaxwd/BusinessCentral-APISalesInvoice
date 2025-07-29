pageextension 90001 "NDC-LocationCard" extends "Location Card"{
    layout
    {
        addlast(AddressDetails){
            field("NDC-Latitude"; Rec."NDC-Latitude"){
                Caption = 'Latitude';
                ApplicationArea = All;
            }
        }addlast(AddressDetails){
            field("NDC-Longitude"; Rec."NDC-Longitude"){
                Caption = 'Longitude';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }
}