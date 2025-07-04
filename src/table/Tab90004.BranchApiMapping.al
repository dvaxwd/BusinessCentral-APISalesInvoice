table 90004 "NDC-Branch Api Mapping"
{
    Caption = 'Branch Api Mapping';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Branch Code"; Code[20])
        {
            Caption = 'Branch Code';
        }
        field(2; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(3; "Customer Code"; Code[20])
        {
            Caption = 'Customer Code';
            TableRelation = Customer;
        }
        field(4; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));
        }
        field(5; "Shortcut Dimension 2 Code"; Code[20])
        {
            //Caption = 'Dimension 2 Code';
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));
        }
    }
    keys
    {
        key(PK; "Branch Code")
        {
            Clustered = true;
        }
    }
}
