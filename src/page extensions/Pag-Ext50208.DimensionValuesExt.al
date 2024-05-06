pageextension 50208 "Dimension Values Ext" extends "Dimension Values"
{
    PromotedActionCategories = 'New,Process,Report,Mobile Worker';
    layout
    {
        addafter(Blocked)
        {
            field("Mobile Worker Related Entity"; Rec."Mobile Worker Related Entity")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Mobile Worker ID"; Rec."Mobile Worker ID")
            {
                ApplicationArea = All;
                // Editable = false;
            }
        }
    }
    actions
    {
        addfirst(Creation)
        {
            group("Mobile Worker")
            {
                action("Create as MW Department")
                {
                    ApplicationArea = All;
                    Caption = 'Create as Department';
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Image = Departments;
                    trigger OnAction()
                    var
                        MWIntegrationMngt: Codeunit "Mobile Worker Integration Mngt";
                    begin
                        MWIntegrationMngt.CreateDepartment(Rec);
                    end;
                }
                action("Create as MW Cost Center Group")
                {
                    ApplicationArea = All;
                    Caption = 'Create as Cost Center Group';
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Image = ImplementCostChanges;
                    trigger OnAction()
                    var
                        MWIntegrationMngt: Codeunit "Mobile Worker Integration Mngt";
                    begin
                        MWIntegrationMngt.CreateCostCenterGroup(Rec);
                    end;
                }
                action("Create as MW Cost Center")
                {
                    ApplicationArea = All;
                    Caption = 'Create as Cost Center';
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Image = CostCenter;
                    trigger OnAction()
                    var
                        DimensionValue: Record "Dimension Value";
                        CostCenterGroupDimensionValue: Record "Dimension Value";
                        MWIntegrationMngt: Codeunit "Mobile Worker Integration Mngt";
                        ProgressWindow: Dialog;
                    begin
                        if Page.RunModal(Page::"MW - Cost Center Group Selecti", CostCenterGroupDimensionValue) = Action::Yes then begin
                            CurrPage.SetSelectionFilter(DimensionValue);
                            ProgressWindow.Open('Creating as Mobile Worker Cost Center... \n #1#########', DimensionValue.Name);
                            if DimensionValue.FindSet() then
                                repeat
                                    ProgressWindow.Update(1, DimensionValue.Name);
                                    MWIntegrationMngt.CreateCostCenter(DimensionValue, CostCenterGroupDimensionValue);
                                until DimensionValue.Next() < 1;
                            ProgressWindow.Close();
                        end;
                    end;
                }
            }
        }
    }
}
