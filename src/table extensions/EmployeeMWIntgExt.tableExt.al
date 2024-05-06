tableextension 50202 "Employee MW Intg. Ext" extends SUM_SP_Employee
{
    fields
    {
        field(50155; "Mobile Worker User ID"; Code[20])
        {
            Caption = 'Mobile Worker User ID';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                Employee: Record SUM_SP_Employee;
            begin
                Employee.SetRange("Mobile Worker User ID", Rec."Mobile Worker User ID");
                if not Employee.IsEmpty and Employee.FindFirst() then
                    Error(StrSubstNo(EmployeeErrLbl, Employee."No.", UserID));
            end;
        }
        field(50156; "Mobile Worker Status"; Text[30])
        {
            Caption = 'Mobile Worker Status';
            DataClassification = CustomerContent;
        }
        field(50157; "Moblie Worker Department Id"; Text[30])
        {
            DataClassification = CustomerContent;
        }
    }
    trigger OnModify()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionValue: Record "Dimension Value";
    begin
        GeneralLedgerSetup.Get();
        if Rec."Global Dimension 1 Code" <> xRec."Global Dimension 1 Code" then
            if DimensionValue.Get(GeneralLedgerSetup."Global Dimension 1 Code", Rec."Global Dimension 1 Code") then
                Rec.Validate("Moblie Worker Department Id", DimensionValue."Mobile Worker ID");
    end;

    var
        EmployeeErrLbl: Label 'Employee: %1 already has UserID: %2 assigned to them';
}
