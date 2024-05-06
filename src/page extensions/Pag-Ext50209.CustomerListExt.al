pageextension 50209 CustomerListExt extends "Customer List"
{
    actions
    {
        addlast(creation)
        {
            group("Mobile Worker")
            {
                ShowAs = Standard;
                action("Create in Mobile Worker")
                {
                    ApplicationArea = All;
                    Caption = 'Create in Mobile Worker';
                    Image = NewCustomer;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        Customer: Record Customer;
                        MWIntegrationMngt: Codeunit "Mobile Worker Integration Mngt";
                        ProgressWindow: Dialog;
                    begin
                        CurrPage.SetSelectionFilter(Customer);
                        ProgressWindow.Open('Creating as Mobile Worker Customer... \ #1#########', Customer.Name);
                        if Customer.FindSet() then
                            repeat
                                ProgressWindow.Update(1, Customer.Name);
                                MWIntegrationMngt.CreateCustomer(Customer);
                            until Customer.Next() < 1;
                        ProgressWindow.Close();
                    end;
                }
            }
        }
    }
}
