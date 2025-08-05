table 90008 "NDC-LogCode"{
    fields{
        field(1; No; Integer){
            DataClassification = ToBeClassified;
        }
        field(2; Type; Enum "NDC-PostStatus"){
            DataClassification = ToBeClassified;
        }
        field(3; "Code"; code[10]){
            DataClassification = ToBeClassified;
        }
        field(4; Description; Text[250]){
            DataClassification = ToBeClassified;
        }
    }keys{
        key(PK; No, Type, Code){
            Clustered = true;
        }
    }
}