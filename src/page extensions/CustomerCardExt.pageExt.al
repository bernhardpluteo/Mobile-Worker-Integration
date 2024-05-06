pageextension 50200 "Customer Card Ext" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field("Mobile Worker Customer ID"; Rec."Mobile Worker Customer ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Global Dimension 1 Code field.';
            }
        }
    }
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
                        MWIntegrationMngt: Codeunit "Mobile Worker Integration Mngt";
                    begin
                        MWIntegrationMngt.CreateCustomer(Rec);
                    end;
                }
            }
        }
    }
}
