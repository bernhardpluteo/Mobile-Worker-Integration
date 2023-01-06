tableextension 50152 "Employee Mobile Worker" extends SUM_SP_Employee
{
    fields
    {
        field(50150; "Mobile Worker UserID"; Code[20])
        {
            Caption = 'Mobile Worker UserID';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                Employee: Record SUM_SP_Employee;
            begin
                Employee.SetRange("Mobile Worker UserID", Rec."Mobile Worker UserID");
                if not Employee.IsEmpty and Employee.FindSet() then
                    Error(StrSubstNo('Employee: %1 already has UserID: %2 assigned to them', Employee."No.", UserID));
            end;
        }
    }
}
