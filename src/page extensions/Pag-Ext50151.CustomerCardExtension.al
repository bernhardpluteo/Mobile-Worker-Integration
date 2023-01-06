pageextension 50151 "Customer Card Extension" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field("Mobile Worker Customer ID"; Rec."Mobile Worker Customer ID")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
}
