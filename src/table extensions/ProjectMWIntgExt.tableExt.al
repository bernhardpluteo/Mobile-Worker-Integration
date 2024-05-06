tableextension 50203 "Project MW Intg. Ext" extends Project
{
    fields
    {
        field(50150; "Mobile Worker Project ID"; Code[20])
        {
            Caption = 'Mobile Worker Project ID';
            DataClassification = ToBeClassified;
        }
        field(50151; "Mobile Worker Customer ID"; Code[20])
        {
            Caption = 'Moble Worker Customer ID';
            DataClassification = ToBeClassified;
        }
        field(50152; "Mobile Worker Supervisor ID"; Code[20])
        {
            Caption = 'Mobile Worker Supervisor ID';
            DataClassification = ToBeClassified;
        }
        field(50155; "MW Global Dimension 1 ID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50156; "MW Global Dimension 2 ID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }

    trigger OnModify()
    var
        Customer: Record Customer;
        Employee: Record SUM_SP_Employee;
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionValue: Record "Dimension Value";
    begin
        GeneralLedgerSetup.Get();
        if Rec."Customer No." <> xRec."Customer No." then
            if Customer.Get(Rec."Customer No.") then
                Rec.Validate("Mobile Worker Customer ID", Customer."Mobile Worker Customer ID");
        if Rec."Supervisor No." <> xRec."Supervisor No." then
            if Employee.Get(Rec."Supervisor No.") then
                Rec.Validate("Mobile Worker Supervisor ID", Employee."Mobile Worker User ID");
        if Rec."Global Dimension 1 Code" <> xRec."Global Dimension 1 Code" then
            if DimensionValue.Get(GeneralLedgerSetup."Global Dimension 1 Code", Rec."Global Dimension 1 Code") then
                Rec.Validate("MW Global Dimension 1 ID", DimensionValue."Mobile Worker ID");
        if Rec."Global Dimension 2 Code" <> xRec."Global Dimension 2 Code" then
            if DimensionValue.Get(GeneralLedgerSetup."Global Dimension 2 Code", Rec."Global Dimension 2 Code") then
                Rec.Validate("MW Global Dimension 2 ID", DimensionValue."Mobile Worker ID");
    end;

    trigger OnAfterModify()
    var
        MobileWorkerIntegrationMngt: Codeunit "Mobile Worker Integration Mngt";
        JSONObject: JsonObject;
        Change: Boolean;
    begin
        if Rec."Mobile Worker Project ID" <> '' then begin
            if xRec."No." <> Rec."No." then begin
                JSONObject.Add('projectKey', Rec."No.");
                Change := true;
            end;
            if xRec.Name <> Rec.Name then begin
                JSONObject.Add('name', Rec.Name);
                Change := true;
            end;
            if xRec.Description <> Rec.Description then begin
                JSONObject.Add('description', Rec.Description);
                Change := true;
            end;
            if xRec."Mobile Worker Customer ID" <> Rec."Mobile Worker Customer ID" then begin
                JSONObject.Add('customerId', Rec."Mobile Worker Customer ID");
                Change := true;
            end;
            if xRec."Mobile Worker Supervisor ID" <> Rec."Mobile Worker Supervisor ID" then begin
                JSONObject.Add('supervisorId', Rec."Mobile Worker Supervisor ID");
                Change := true;
            end;
            if xRec."Start Date" <> Rec."Start Date" then begin
                JSONObject.Add('start', Rec."Start Date");
                Change := true;
            end;
            if xRec."Expected Completion Date" <> Rec."Expected Completion Date" then begin
                JSONObject.Add('end', Rec."Expected Completion Date");
                Change := true;
            end;
            if xRec."MW Global Dimension 1 ID" <> Rec."MW Global Dimension 1 ID" then begin
                JSONObject.Add('departmentId', Rec."MW Global Dimension 1 ID");
                Change := true;
            end;
            if Change then
                MobileWorkerIntegrationMngt.UpdateProject(Rec."Mobile Worker Project ID", JSONObject);
        end else
            if Rec.Name <> '' then
                MobileWorkerIntegrationMngt.CreateProject(Rec);
    end;
}
