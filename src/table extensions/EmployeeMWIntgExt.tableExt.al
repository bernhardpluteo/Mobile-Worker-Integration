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
    }
    var
        EmployeeErrLbl: Label 'Employee: %1 already has UserID: %2 assigned to them';
}
