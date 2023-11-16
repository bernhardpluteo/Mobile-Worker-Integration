pageextension 50206 "Sales Order MW Ingt Ext " extends "Sales Order"
{
    layout
    {
        addafter(Project)
        {
            field("Mobile Worker Order ID"; Rec."Mobile Worker Order ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Mobile Worker Order ID field.';
            }
            field("Mobile Worker Project ID"; Rec."Mobile Worker Project ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Mobile Worker Project ID field.';
                Visible = false;
            }
        }
        addafter("Sell-to Customer Name")
        {
            field("Mobile Worker Customer ID"; Rec."Mobile Worker Customer ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Mobile Worker Customer ID field.';
                Visible = false;
            }
        }
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
                    MobileWorkerIntegrationMngt.CreateSalesOrderAsOrder(Rec);
                    CurrPage.Update();
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

    var
        ErrorMsg: Boolean;
}
