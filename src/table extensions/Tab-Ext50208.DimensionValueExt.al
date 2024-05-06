tableextension 50208 "Dimension Value Ext" extends "Dimension Value"
{
    fields
    {
        field(50200; "Mobile Worker Related Entity"; Enum "MW Related Entity")
        {
            Caption = 'Mobile Worker Related Entity';
            DataClassification = ToBeClassified;
        }
        field(50201; "Mobile Worker ID"; Code[20])
        {
            Caption = 'Mobile Worker ID';
            DataClassification = ToBeClassified;
        }
    }
}
