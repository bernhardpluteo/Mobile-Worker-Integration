pageextension 50202 "Project Card Extension" extends "Project Card"
{
    layout
    {
        addafter(Description)
        {
            field("Mobile Worker Project ID"; Rec."Mobile Worker Project ID")
            {
                Editable = false;
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Mobile Worker Project ID field.';
            }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action("Create Mobile Worker Project")
            {
                ApplicationArea = All;
                Image = Create;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Create Mobile Worker Project';
                trigger OnAction()
                var
                    MobileWorker: Codeunit "Mobile Worker Integration Mngt";
                begin
                    MobileWorker.CreateProject(Rec);
                end;
            }
        }
    }
}
