page 50201 "MW - Cost Center Group Selecti"
{
    ApplicationArea = All;
    Caption = 'Cost Center Group Selection';
    PageType = ConfirmationDialog;
    SourceTable = "Dimension Value";

    SourceTableView = where("Mobile Worker Related Entity" = const("MW Related Entity"::"Cost Center Group"));

    layout
    {
        area(content)
        {
            label("Select Cost Center Group")
            {
                Caption = 'Select Cost Center Group';
                StyleExpr = 'Strong';
            }
            repeater("Cost Center Groups")
            {
                Caption = 'Select Cost Center Group';
                Editable = false;
                ShowCaption = true;
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of dimension value.';
                }
                field("Mobile Worker Related Entity"; Rec."Mobile Worker Related Entity")
                {
                    ToolTip = 'Specifies the value of the Mobile Worker Related Entity field.';
                }
                field("Mobile Worker ID"; Rec."Mobile Worker ID")
                {
                    ToolTip = 'Specifies the value of the Mobile Worker ID field.';
                }
            }
        }
    }
}
