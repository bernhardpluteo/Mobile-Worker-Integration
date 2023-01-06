pageextension 50152 "Job List MW Extension" extends "Job List"
{
    actions
    {
        addlast(processing)
        {
            action("Create Jon in Mobile Worker")
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
                    MobileWorker.CreateJobAsOrder(Rec);
                end;
            }
            action("Pull Hours for Jobs")
            {
                ApplicationArea = All;
                Image = Action;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    MobileWorker: Codeunit "Mobile Worker Integration Mngt";
                    MobileWorkerJob: Codeunit "Mobile Worker Integ. Job Queue";
                begin
                    MobileWorkerJob.GetApprovedHours();
                end;
            }
        }
    }
}
