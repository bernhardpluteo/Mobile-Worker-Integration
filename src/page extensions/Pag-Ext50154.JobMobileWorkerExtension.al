pageextension 50154 "Job Mobile Worker Extension" extends "Job Card"
{
    layout
    {
        addafter("Project No.")
        {
            field("Mobile Worker Project ID"; Rec."Mobile Worker Project ID")
            {
                ApplicationArea = All;
            }
        }
        addafter("Sell-to Customer Name")
        {
            field("Mobile Worker Customer ID"; Rec."Mobile Worker Customer ID")
            {
                ApplicationArea = All;
            }
        }
        addafter("No.")
        {
            field("Mobile Worker Order ID"; Rec."Mobile Worker Order ID")
            {
                ApplicationArea = All;
            }
        }
    }
}
