tableextension 50153 "Project Extension" extends Project
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
            Caption = 'Moble Worker Custoemr ID';
            DataClassification = ToBeClassified;
        }
    }

    trigger OnModify()
    var
        Customer: Record Customer;
    begin
        if Rec."Customer No." <> xRec."Customer No." then
            if Customer.Get(Rec."Customer No.") then
                Rec.Validate("Mobile Worker Customer ID", Customer."Mobile Worker Customer ID");
    end;

    trigger OnAfterModify()
    var
        JSONObject: JsonObject;
        Change: Boolean;
        MobileWorkerIntegrationMngt: Codeunit "Mobile Worker Integration Mngt";
    begin
        if Rec."Mobile Worker Project ID" <> '' then begin
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
            if xRec."Start Date" <> Rec."Start Date" then begin
                JSONObject.Add('start', Rec."Start Date");
                Change := true;
            end;
            if xRec."Finish Date" <> Rec."Finish Date" then begin
                JSONObject.Add('end', Rec."Finish Date");
                Change := true;
            end;
            if Change then
                MobileWorkerIntegrationMngt.UpdateProject(Rec."Mobile Worker Project ID", JSONObject);
        end else
            if Rec.Name <> '' then begin
                MobileWorkerIntegrationMngt.CreateProject(Rec);
            end;
    end;
}
