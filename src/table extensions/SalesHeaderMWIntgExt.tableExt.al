tableextension 50207 "Sales Header MW Intg Ext" extends "Sales Header"
{
    fields
    {
        field(50200; "Mobile Worker Customer ID"; Code[20])
        {
            Caption = 'Mobile Worker Customer ID';
            DataClassification = ToBeClassified;
        }
        field(50201; "Mobile Worker Supervisor ID"; Code[20])
        {
            Caption = 'Mobile Worker Supervisor ID';
            DataClassification = ToBeClassified;
        }
        field(50202; "Mobile Worker Order ID"; Code[20])
        {
            Caption = 'Mobile Worker Order ID';
            DataClassification = ToBeClassified;
        }
        field(50203; "Mobile Worker Project ID"; Code[20])
        {
            Caption = 'Mobile Worker Project ID';
            DataClassification = ToBeClassified;
        }
        field(50204; "Mobile Worker Error Message"; Text[200])
        {
            Caption = 'Mobile Worker Error Message';
            DataClassification = ToBeClassified;
        }
    }

    trigger OnInsert()
    var
        Customer: Record Customer;
        Employee: Record SUM_SP_Employee;
        Project: Record Project;
    begin
        if Customer.Get(Rec."Sell-to Customer No.") then
            Rec.Validate("Mobile Worker Customer ID", Customer."Mobile Worker Customer ID");
        if Employee.Get(Rec."Supervisor No.") then
            Rec.Validate("Mobile Worker Supervisor ID", Employee."Mobile Worker User ID");
        if Project.Get(Rec."Project No.") then
            Rec.Validate("Mobile Worker Project ID", Project."Mobile Worker Project ID");
    end;

    trigger OnModify()
    var
        Customer: Record Customer;
        Employee: Record SUM_SP_Employee;
        Project: Record Project;
    begin
        if (Rec."Mobile Worker Customer ID" = '') OR (Rec."Sell-to Customer No." <> xRec."Sell-to Customer No.") then
            if Customer.Get(Rec."Sell-to Customer No.") then
                Rec.Validate("Mobile Worker Customer ID", Customer."Mobile Worker Customer ID");

        if (Rec."Mobile Worker Project ID" = '') OR (Rec."Project No." <> xRec."Project No.") then
            if Project.Get(Rec."Project No.") then
                Rec.Validate("Mobile Worker Project ID", Project."Mobile Worker Project ID");

        if (Rec."Mobile Worker Supervisor ID" = '') OR (Rec."Supervisor No." <> xRec."Supervisor No.") then
            if Employee.Get(Rec."Supervisor No.") then
                Rec.Validate("Mobile Worker Supervisor ID", Employee."Mobile Worker User ID");
    end;

    trigger OnAfterModify()
    var
        MobileWorkerIntegrationMngt: Codeunit "Mobile Worker Integration Mngt";
        JSONObject: JsonObject;
        Change: Boolean;
    begin
        if Rec."Mobile Worker Order ID" <> '' then begin
            if Rec.Description <> xRec.Description then begin
                JsonObject.Add('name', Rec.Description);
                Change := true;
            end;
            if Rec."Extended Description" <> xRec."Extended Description" then begin
                JsonObject.Add('description', Rec."Extended Description");
                Change := true;
            end;
            if Rec.Location <> xRec.Location then begin
                JsonObject.Add('location', Rec.Location);
                Change := true;
            end;
            if Rec."Start Date" <> xRec."Start Date" then begin
                JsonObject.Add('orderStartDate', Rec."Start Date");
                Change := true;
            end;
            if Rec."End Date" <> xRec."End Date" then begin
                JsonObject.Add('orderEndDate', Rec."Start Date");
                Change := true;
            end;
            if not (Rec."Mobile Worker Supervisor ID" = '') then
                if Rec."Mobile Worker Supervisor ID" <> xRec."Mobile Worker Supervisor ID" then begin
                    JSONObject.Add('supervisorId', Rec."Mobile Worker Supervisor ID");
                    Change := true;
                end;
            if Rec."Mobile Worker Project ID" <> xRec."Mobile Worker Project ID" then begin
                JSONObject.Add('projectId', Rec."Mobile Worker Project ID");
                Change := true;
            end;
            if Rec."Mobile Worker Customer ID" <> xRec."Mobile Worker Customer ID" then begin
                JSONObject.Add('customerId', Rec."Mobile Worker Customer ID");
                Change := true;
            end;
            if Change then
                MobileWorkerIntegrationMngt.UpdateOrder(Rec."Mobile Worker Order ID", JSONObject);
        end else
            if (Rec.Description <> '') and (Rec."Sell-to Customer No." <> '') and (Rec."Project No." <> '') then
                MobileWorkerIntegrationMngt.CreateSalesOrderAsOrder(Rec);
    end;
}
