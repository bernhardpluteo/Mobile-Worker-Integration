pageextension 50206 "Sales Order MW Ingt Ext " extends "Sales Order"
{
    layout
    {
        addafter("Extended Job Status")
        {
            field("Mobile Worker Error Message"; Rec."Mobile Worker Error Message")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Mobile Worker Error Message field.';
                Visible = ErrorMsg;
                StyleExpr = 'Unfavorable';
                Editable = false;
            }
            field("Mobile Worker Order ID"; Rec."Mobile Worker Order ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Mobile Worker Error Message field.';
                Editable = false;
                Visible = false;
            }
            field("Mobile Worker Customer ID"; Rec."Mobile Worker Customer ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Mobile Worker Error Message field.';
                Visible = false;
            }
            field("Mobile Worker Project ID"; Rec."Mobile Worker Project ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Mobile Worker Error Message field.';
                Visible = false;
            }
            field("Mobile Worker Supervisor ID"; Rec."Mobile Worker Supervisor ID")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }
    actions
    {
        addafter("Create Inventor&y Put-away/Pick")
        {
            action("Create in Mobile Worker")
            {
                ApplicationArea = All;
                ToolTip = 'Creates the Sales Order in Mobile Worker';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    MobileWorkerIntegrationMngt: Codeunit "Mobile Worker Integration Mngt";
                begin
                    if Rec."Mobile Worker Order ID" = '' then
                        if not (Rec."Shortcut Dimension 1 Code" = '') then begin
                            MobileWorkerIntegrationMngt.CreateSalesOrderAsOrder(Rec);
                            if Rec."Extended Job Status" = Enum::"Extended Job Status"::Error then
                                ErrorMsg := true
                            else
                                ErrorMsg := false;
                        end
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
    trigger OnOpenPage()
    begin
        if Rec."Extended Job Status" = Enum::"Extended Job Status"::Error then
            ErrorMsg := true
        else
            ErrorMsg := false;
    end;

    // trigger OnAfterGetCurrRecord()
    // begin
    //     if Rec."Extended Job Status" = Enum::"Extended Job Status"::Error then
    //         ErrorMsg := true
    //     else
    //         ErrorMsg := false;
    // end;

    // trigger OnAfterGetRecord()
    // begin
    //     if Rec."Extended Job Status" = Enum::"Extended Job Status"::Error then
    //         ErrorMsg := true
    //     else
    //         ErrorMsg := false;
    // end;

    var
        ErrorMsg: Boolean;
        JobExistsLbl: Label 'Job already exists in Mobile Worker as OrderId %1';
        DepartmentRequired: Label 'Global Dimension 1(Department) Required on Job';
}
