pageextension 50211 "Job Hours MW Ext" extends "Job Hours Overview List"
{
    actions
    {
        addlast(Processing)
        {
            group("Mobile Worker")
            {
                action("Pull Mobile Worker Hours")
                {
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    Image = HumanResources;
                    trigger OnAction()
                    var
                        MobileWorkerJob: Codeunit "Mobile Worker Integ. Job Queue";
                    begin
                        MobileWorkerJob.GetApprovedHours();
                    end;
                }
            }
        }
    }
}
