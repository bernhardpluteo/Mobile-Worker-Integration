pageextension 50210 EmployeeListMWExt extends SUM_SP_EmployeeList
{
    actions
    {
        addlast(RegistrerEmployee)
        {
            action("Create as MW User")
            {
                Caption = 'Create as Mobile Worker User';
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                Image = UserSetup;

                trigger OnAction()
                var
                    Employee: Record SUM_SP_Employee;
                    MWIntegrationMngt: Codeunit "Mobile Worker Integration Mngt";
                    ProgressWindow: Dialog;
                begin
                    CurrPage.SetSelectionFilter(Employee);
                    ProgressWindow.Open('Creating as Mobile Worker Customer... \ #1#########', Employee.Name);
                    if Employee.FindSet() then
                        repeat
                            ProgressWindow.Update(1, Employee.Name);
                            MWIntegrationMngt.CreateUser(Employee);
                        until Employee.Next() < 1;
                    ProgressWindow.Close();
                end;
            }
        }
    }
}
