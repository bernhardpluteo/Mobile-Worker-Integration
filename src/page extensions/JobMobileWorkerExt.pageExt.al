pageextension 50203 "Job Mobile Worker Ext" extends "Job Card"
{
    layout
    {
        addafter(Project)
        {
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
            field("Mobile Worker Order ID"; Rec."Mobile Worker Order ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Mobile Worker Order ID field.';
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

    trigger OnAfterGetCurrRecord()
    begin
        if Rec."Extended Job Status" = Enum::"Extended Job Status"::Error then
            ErrorMsg := true
        else
            ErrorMsg := false;
    end;

    var
        ErrorMsg: Boolean;
}
