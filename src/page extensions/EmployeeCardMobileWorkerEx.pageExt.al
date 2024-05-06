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
            field("Mobile Worker Status"; Rec."Mobile Worker Status")
            {
                Editable = false;
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Mobile Worker Status field.';
            }
        }
    }
    actions
    {
        addbefore(Deductions)
        {
            action("Create as MW User")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = User;
                Caption = 'Create as Mobile Worker User';

                trigger OnAction()
                var
                    MobileWorkerIntegrationMngt: Codeunit "Mobile Worker Integration Mngt";
                begin
                    MobileWorkerIntegrationMngt.CreateUser(Rec);
                end;
            }
        }
    }
}
