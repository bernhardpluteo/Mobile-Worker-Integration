pageextension 50200 "Customer Card Ext" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field("Mobile Worker Customer ID"; Rec."Mobile Worker Customer ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Global Dimension 1 Code field.';
            }
        }
    }
}
