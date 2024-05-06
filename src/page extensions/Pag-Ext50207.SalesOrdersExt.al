pageextension 50207 SalesOrdersExt extends "Sales Order List"
{
    layout
    {
        addafter(Status)
        {
            field("Extended Job Status"; Rec."Extended Job Status")
            {
                ApplicationArea = All;
                StyleExpr = StyleExpr;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        case Rec."Extended Job Status" of
            Enum::"Extended Job Status"::Error:
                StyleExpr := 'Unfavorable';
            Enum::"Extended Job Status"::"Hours Logged":
                StyleExpr := 'Favorable';
            Enum::"Extended Job Status"::"Ready to Invoice":
                StyleExpr := 'Favorable';
            Enum::"Extended Job Status"::"Paid":
                StyleExpr := 'StrongAccent';
            Enum::"Extended Job Status"::"Overdue":
                StyleExpr := 'Attention';
            else
                StyleExpr := 'None';
        end;
    end;

    var
        StyleExpr: Text;
}
