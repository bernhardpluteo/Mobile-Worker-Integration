pageextension 50155 "Human Resources Setup MW Cust" extends "Human Resources Setup"
{
    layout
    {
        addafter(Numbering)
        {
            part("Type Hours Mobile Worker Setup"; "Hour Type Mobile Worker Setup")
            {
                ApplicationArea = All;

            }
        }
    }
}
