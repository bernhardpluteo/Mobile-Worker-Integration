pageextension 50156 "Employee Card Mobile Worker Ex" extends SUM_SP_EmployeeCard
{
    layout
    {
        addafter("External Id")
        {
            field("Mobile Worker UserID"; Rec."Mobile Worker UserID")
            {
                ApplicationArea = All;
            }
        }
    }
}
