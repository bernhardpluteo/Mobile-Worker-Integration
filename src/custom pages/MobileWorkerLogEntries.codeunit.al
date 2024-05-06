page 50200 "Mobile Worker Log Entries"
{
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Mobile Worker Log Entries';
    PageType = List;
    SourceTable = "Mobile Worker Log Entry";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec."Request Status")
                {
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field("Response Body"; Rec."Response Body")
                {
                    ToolTip = 'Specifies the value of the Response Body field.';
                }
                field("Request Body"; Rec."Request Body")
                {
                    ToolTip = 'Specifies the value of the Request Body field.';
                }
            }
        }
    }
}
