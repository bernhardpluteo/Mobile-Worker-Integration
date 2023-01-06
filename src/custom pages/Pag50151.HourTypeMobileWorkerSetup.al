page 50151 "Hour Type Mobile Worker Setup"
{
    ApplicationArea = All;
    Caption = 'Hour Type Mobile Worker Setup';
    PageType = ListPart;
    SourceTable = "Hour Type Mobile Worker Setup";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Hour Type"; Rec."Hour Type")
                {
                    ToolTip = 'Specifies the value of the Hour Type field.';
                }
                field("Mobile Worker Id"; Rec."Mobile Worker Id")
                {
                    ToolTip = 'Specifies the value of the Mobile Worker Id field.';
                }
            }
        }
    }
}
