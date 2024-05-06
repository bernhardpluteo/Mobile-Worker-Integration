pageextension 50201 "Job List MW Ext" extends "Job List"
{
    actions
    {
        addlast(processing)
        {
            action("Create Job in Mobile Worker")
            {
                ApplicationArea = All;
                Image = Create;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Create Job in Mobile Worker';
                trigger OnAction()
                var
                    MobileWorker: Codeunit "Mobile Worker Integration Mngt";
                begin
                    if Rec."Mobile Worker Order ID" = '' then
                        if not (Rec."Global Dimension 1 Code" = '') then
                            MobileWorker.CreateJobAsOrder(Rec)
                        else
                            Error(StrSubstNo(DepartmentRequired))
                    else
                        Error(StrSubstNo(JobExistsLbl, Rec."Mobile Worker Order ID"));
                end;
            }
            action("Pull Hours for Jobs")
            {
                ApplicationArea = All;
                Image = Action;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Pull Hours for Jobs';
                trigger OnAction()
                var
                    MobileWorkerJob: Codeunit "Mobile Worker Integ. Job Queue";
                begin
                    MobileWorkerJob.GetApprovedHours();
                end;
            }
        }
    }
    var
        JobExistsLbl: Label 'Job already exists in Mobile Worker as Order %1';
        DepartmentRequired: Label 'Global Dimension 1(Department) Required on Job';
}
