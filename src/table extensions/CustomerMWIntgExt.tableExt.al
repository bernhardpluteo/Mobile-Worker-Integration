tableextension 50200 "Customer MW Intg. Ext" extends Customer
{
    fields
    {
        field(50200; "Mobile Worker Customer ID"; Code[20])
        {
            Caption = 'Mobile Worker Customer ID';
            DataClassification = ToBeClassified;
        }
    }
    trigger OnAfterModify()
    var
        MobileWorkerIntegrationMngt: Codeunit "Mobile Worker Integration Mngt";
        JSONObject: JsonObject;
        Change: Boolean;
    begin
        if Rec."Mobile Worker Customer ID" <> '' then begin
            if xRec.Name <> Rec.Name then begin
                JSONObject.Add('name', Rec.Name);
                Change := true;
            end;
            if xRec."Phone No." <> Rec."Phone No." then begin
                JSONObject.Add('phone', Rec."Phone No.");
                Change := true;
            end;
            if xRec."Mobile Phone No." <> Rec."Mobile Phone No." then begin
                JSONObject.Add('mobilePhone', Rec."Mobile Phone No.");
                Change := true;
            end;
            if xRec."E-Mail" <> Rec."E-Mail" then begin
                JSONObject.Add('email', Rec."E-Mail");
                Change := true;
            end;
            if xRec.Contact <> Rec.Contact then begin
                JSONObject.Add('contactPerson', Rec.Contact);
                Change := true;
            end;
            if xRec.City <> Rec.City then begin
                JSONObject.Add('city', Rec.City);
                Change := true;
            end;
            if (xRec.Address <> Rec.Address) or (xRec."Address 2" <> Rec."Address 2") then begin
                JSONObject.Add('street', Rec.Address + ' ' + Rec."Address 2");
                Change := true;
            end;
            if (xRec."Post Code" <> Rec."Post Code") then begin
                JSONObject.Add('postCode', Rec."Post Code");
                Change := true;
            end;
            if (xRec."Country/Region Code" <> Rec."Country/Region Code") then begin
                JSONObject.Add('countryCode', Rec."Country/Region Code");
                Change := true;
            end;
            if Change then
                MobileWorkerIntegrationMngt.UpdateCustomer(Rec."Mobile Worker Customer ID", JSONObject);
        end else
            MobileWorkerIntegrationMngt.CreateCustomer(Rec);
    end;

}
