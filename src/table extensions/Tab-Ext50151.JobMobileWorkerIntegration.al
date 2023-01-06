tableextension 50151 "Job Mobile Worker Integration" extends Job
{
    fields
    {
        field(50150; "Mobile Worker Customer ID"; Code[20])
        {
            Caption = 'Mobile Worker Customer ID';
            DataClassification = ToBeClassified;
        }
        field(50151; "Mobile Worker Supervisor ID"; Code[20])
        {
            Caption = 'Mobile Worker Supervisor ID';
            DataClassification = ToBeClassified;
        }
        field(50152; "Mobile Worker Order ID"; Code[20])
        {
            Caption = 'Mobile Worker Order ID';
            DataClassification = ToBeClassified;
        }
        field(50153; "Mobile Worker Project ID"; Code[20])
        {
            Caption = 'Mobile Worker Project ID';
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
            Rec.Validate("Mobile Worker Supervisor ID", Employee."Mobile Worker UserID");
        if Project.Get(Rec."Project No.") then
            Rec.Validate("Mobile Worker Project ID", Project."Mobile Worker Project ID");
    end;

    trigger OnBeforeModify()
    var
        Customer: Record Customer;
        Employee: Record SUM_SP_Employee;
        Project: Record Project;
    begin
        if Rec."Sell-to Customer No." <> xRec."Sell-to Customer No." then
            if Customer.Get(Rec."Sell-to Customer No.") then
                Rec.Validate("Mobile Worker Customer ID", Customer."Mobile Worker Customer ID");
        if Project.Get(Rec."Project No.") then
            Rec.Validate("Mobile Worker Project ID", Project."Mobile Worker Project ID");
        if Employee.Get(Rec."Supervisor No.") then
            Rec.Validate("Mobile Worker Supervisor ID", Employee."Mobile Worker UserID");
    end;

    trigger OnAfterModify()
    var
        JSONObject: JsonObject;
        Change: Boolean;
        MobileWorkerIntegrationMngt: Codeunit "Mobile Worker Integration Mngt";
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
            if Rec."Starting Date" <> xRec."Starting Date" then begin
                JsonObject.Add('orderStartDate', Rec."Starting Date");
                Change := true;
            end;
            if Rec."Ending Date" <> xRec."Ending Date" then begin
                JsonObject.Add('orderEndDate', Rec."Ending Date");
                Change := true;
            end;
            if Rec."Delivery Date" <> xRec."Delivery Date" then begin
                JsonObject.Add('deliveryDate', Rec."Delivery Date");
                Change := true;
            end;
            if Change then
                MobileWorkerIntegrationMngt.UpdateOrder(Rec."Mobile Worker Order ID", JSONObject);
        end else
            MobileWorkerIntegrationMngt.CreateJobAsOrder(Rec);
    end;
}
