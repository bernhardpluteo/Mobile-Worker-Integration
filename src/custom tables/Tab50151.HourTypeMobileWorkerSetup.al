table 50151 "Hour Type Mobile Worker Setup"
{
    Caption = 'Hour Type Mobile Worker Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Hour Type"; Enum "Hour Type")
        {
            Caption = 'Hour Type';
            DataClassification = ToBeClassified;
        }
        field(2; "Mobile Worker Id"; Code[20])
        {
            Caption = 'Mobile Worker Id';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Hour Type")
        {
            Clustered = true;
        }
    }
}
