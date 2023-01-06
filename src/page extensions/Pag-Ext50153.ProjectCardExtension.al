pageextension 50153 "Project Card Extension" extends "Project Card"
{
    layout
    {
        addafter(Description)
        {
            field("Mobile Worker Project ID"; Rec."Mobile Worker Project ID")
            {
                Editable = false;
                ApplicationArea = All;
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
