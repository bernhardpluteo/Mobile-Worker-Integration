pageextension 50204 "Hour Setup ListPart Ext." extends "Job Hour Setup"
{
    layout
    {
        addafter("Additional Pay Slip Line")
        {
            field("Mobile Worker ID"; Rec."Mobile Worker ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Mobile Worker Id field.';
            }
        }
    }
}
