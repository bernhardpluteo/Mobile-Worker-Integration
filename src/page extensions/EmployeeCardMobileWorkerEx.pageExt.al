pageextension 50205 "Employee Card Mobile Worker Ex" extends SUM_SP_EmployeeCard
{
    layout
    {
        addafter("External Id")
        {
            field("Mobile Worker User ID"; Rec."Mobile Worker User ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Mobile Worker Id field.';
            }
        }
    }
}
