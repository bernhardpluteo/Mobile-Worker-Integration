table 50200 "Mobile Worker Log Entry"
{
    Caption = 'Mobile Worker Log Entry';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(5; "Type"; Enum "MW Log Entry Type")
        {
            Caption = 'Type';
            DataClassification = ToBeClassified;
        }
        field(6; Status; Enum "MW Log Entry Status")
        {
            Caption = 'Status';
            DataClassification = ToBeClassified;
        }
        field(8; "Request Status"; Integer)
        {
            Caption = 'Request Status';
            DataClassification = ToBeClassified;
        }
        field(10; "Request Body"; Text[2048])
        {
            Caption = 'Request Body';
            DataClassification = ToBeClassified;
        }
        field(11; "Response Body"; Text[2048])
        {
            Caption = 'Response Body';
            DataClassification = ToBeClassified;
        }
        field(20; "Reason Phrase"; Text[1024])
        {
            Caption = 'Reason ';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
