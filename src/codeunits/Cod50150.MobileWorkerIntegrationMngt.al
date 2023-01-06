codeunit 50150 "Mobile Worker Integration Mngt"
{

    trigger OnRun()
    var
        myInt: Integer;
    begin

    end;

    local procedure CheckIfExists(var APISetup: Record "Custom API Setup"): Boolean
    begin
        if APISetup.Get('Mobile Worker') then
            exit(true)
        else
            exit(false)
    end;

    procedure CreateCustomer(Customer: Record Customer)
    var
        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;

        JSONObjectText: Text;
        ResponseText: Text;

        APISetup: Record "Custom API Setup";

        Url: Text;
        Header: Text;
        HeaderValue: Text;
    begin
        if CheckIfExists(APISetup) then
            APISetup.GetAPIHeaderCredentials(Url, Header, HeaderValue)
        else
            exit;

        CreateCustomerJSON(Customer).WriteTo(JSONObjectText);
        HttpContent.WriteFrom(JSONObjectText);

        HttpContent.GetHeaders(ContentHeader);
        ContentHeader.Clear();
        ContentHeader.Add('Content-Type', 'application/json');

        HttpRequestMessage.Content := HttpContent;

        HttpRequestMessage.SetRequestUri(StrSubstNo('%1/Customers', Url));
        HttpRequestMessage.Method := 'POST';

        HttpRequestMessage.GetHeaders(RequestHeader);
        RequestHeader.Clear();
        RequestHeader := HttpClient.DefaultRequestHeaders();
        RequestHeader.Add(Header, HeaderValue);

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);

        CreateMobileWorkerLogEntry(Enum::"MW Log Entry Type"::"Create Customer", JSONObjectText, HttpResponseMessage);
        if HttpResponseMessage.IsSuccessStatusCode then begin
            HttpResponseMessage.Content.ReadAs(ResponseText);
            GetMobileWorkerCustomerID(Customer, ResponseText);
        end;
    end;

    local procedure GetMobileWorkerCustomerID(Customer: Record Customer; ResponseText: Text)
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        if JsonObject.ReadFrom(ResponseText) then begin
            if JsonObject.Get('customerId', JsonToken) then begin
                Customer.Validate("Mobile Worker Customer ID", JsonToken.AsValue().AsCode());
                Customer.Modify();
            end;
        end else begin
            Error('Unable to read JSON Object.');
        end;
    end;

    local procedure CreateCustomerJSON(Customer: Record Customer): JsonObject
    var
        JSONObject: JsonObject;
    begin
        JSONObject.Add('customerKey', Customer."No.");
        JSONObject.Add('name', Customer.Name);
        JSONObject.Add('phone', Customer."Phone No.");
        JSONObject.Add('mobilePhone', Customer."Mobile Phone No.");
        JSONObject.Add('email', Customer."E-Mail");
        JSONObject.Add('contactPerson', Customer.Contact);
        JSONObject.Add('city', Customer.City);
        JSONObject.Add('street', Customer.Address + ' ' + Customer."Address 2");
        JSONObject.Add('postCode', Customer."Post Code");
        JSONObject.Add('countryCode', Customer."Country/Region Code");
        JSONObject.Add('isActive', true);
        exit(JSONObject);
    end;

    procedure UpdateCustomer(CustomerID: Code[20]; JsonObject: JsonObject)
    var
        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;

        JSONObjectText: Text;
        ResponseText: Text;

        APISetup: Record "Custom API Setup";

        Url: Text;
        Header: Text;
        HeaderValue: Text;
    begin
        if CheckIfExists(APISetup) then
            APISetup.GetAPIHeaderCredentials(Url, Header, HeaderValue)
        else
            exit;

        JsonObject.WriteTo(JSONObjectText);
        HttpContent.WriteFrom(JSONObjectText);

        HttpContent.GetHeaders(ContentHeader);
        ContentHeader.Clear();
        ContentHeader.Add('Content-Type', 'application/json');

        HttpRequestMessage.Content := HttpContent;

        HttpRequestMessage.SetRequestUri(StrSubstNo('%1/Customers/%2', Url, CustomerID));
        HttpRequestMessage.Method := 'PATCH';

        HttpRequestMessage.GetHeaders(RequestHeader);
        RequestHeader.Clear();
        RequestHeader := HttpClient.DefaultRequestHeaders();
        RequestHeader.Add(Header, HeaderValue);

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        CreateMobileWorkerLogEntry(Enum::"MW Log Entry Type"::"Update Customer", JSONObjectText, HttpResponseMessage);
    end;

    procedure CreateProject(Project: Record Project)
    var
        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;

        JSONObjectText: Text;
        ResponseText: Text;

        APISetup: Record "Custom API Setup";

        Url: Text;
        Header: Text;
        HeaderValue: Text;
    begin
        if CheckIfExists(APISetup) then
            APISetup.GetAPIHeaderCredentials(Url, Header, HeaderValue)
        else
            exit;

        CreateProjectJSON(Project).WriteTo(JSONObjectText);
        HttpContent.WriteFrom(JSONObjectText);

        HttpContent.GetHeaders(ContentHeader);
        ContentHeader.Clear();
        ContentHeader.Add('Content-Type', 'application/json');

        HttpRequestMessage.Content := HttpContent;

        HttpRequestMessage.SetRequestUri(StrSubstNo('%1/Projects', Url));
        HttpRequestMessage.Method := 'POST';

        HttpRequestMessage.GetHeaders(RequestHeader);
        RequestHeader.Clear();
        RequestHeader := HttpClient.DefaultRequestHeaders();
        RequestHeader.Add(Header, HeaderValue);

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        CreateMobileWorkerLogEntry(Enum::"MW Log Entry Type"::"Create Project", JSONObjectText, HttpResponseMessage);
        if HttpResponseMessage.IsSuccessStatusCode then begin
            HttpResponseMessage.Content.ReadAs(ResponseText);
            GetMobileWorkerProjectID(Project, ResponseText);
        end;
    end;

    local procedure CreateProjectJSON(Project: Record Project): JsonObject
    var
        JsonObject: JsonObject;
    begin
        JsonObject.Add('projectExtId', Project."No.");
        JsonObject.Add('projectKey', Project."No.");
        JsonObject.Add('name', Project.Name);
        JsonObject.Add('description', Project.Description);
        JsonObject.Add('customerId', Project."Mobile Worker Customer ID");
        JsonObject.Add('start', Project."Start Date");
        JsonObject.Add('end', Project."Finish Date");
        exit(JsonObject);
    end;

    local procedure GetMobileWorkerProjectID(Project: Record Project; ResponseText: Text)
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        if JsonObject.ReadFrom(ResponseText) then begin
            if JsonObject.Get('projectId', JsonToken) then begin
                Project.Validate("Mobile Worker Project ID", JsonToken.AsValue().AsCode());
                Project.Modify();
            end;
        end else begin
            Error('Unable to read JSON Object.');
        end;
    end;

    procedure UpdateProject(ProjectID: Code[20]; JsonObject: JsonObject)
    var
        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;

        JSONObjectText: Text;
        ResponseText: Text;

        APISetup: Record "Custom API Setup";

        Url: Text;
        Header: Text;
        HeaderValue: Text;
    begin

        if CheckIfExists(APISetup) then
            APISetup.GetAPIHeaderCredentials(Url, Header, HeaderValue)
        else
            exit;

        JsonObject.WriteTo(JSONObjectText);
        HttpContent.WriteFrom(JSONObjectText);

        HttpContent.GetHeaders(ContentHeader);
        ContentHeader.Clear();
        ContentHeader.Add('Content-Type', 'application/json');

        HttpRequestMessage.Content := HttpContent;

        HttpRequestMessage.SetRequestUri(StrSubstNo('%1/Projects/%2', Url, ProjectID));
        HttpRequestMessage.Method := 'PATCH';

        HttpRequestMessage.GetHeaders(RequestHeader);
        RequestHeader.Clear();
        RequestHeader := HttpClient.DefaultRequestHeaders();
        RequestHeader.Add(Header, HeaderValue);

        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            CreateMobileWorkerLogEntry(Enum::"MW Log Entry Type"::"Update Project", JSONObjectText, HttpResponseMessage);
    end;

    procedure CreateJobAsOrder(Job: Record Job)
    var
        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;

        JSONObjectText: Text;
        ResponseText: Text;

        APISetup: Record "Custom API Setup";

        Url: Text;
        Header: Text;
        HeaderValue: Text;
    begin
        if CheckIfExists(APISetup) then
            APISetup.GetAPIHeaderCredentials(Url, Header, HeaderValue)
        else
            exit;

        CreateOrderJSON(Job).WriteTo(JSONObjectText);
        HttpContent.WriteFrom(JSONObjectText);

        HttpContent.GetHeaders(ContentHeader);
        ContentHeader.Clear();
        ContentHeader.Add('Content-Type', 'application/json');

        HttpRequestMessage.Content := HttpContent;

        HttpRequestMessage.SetRequestUri(StrSubstNo('%1/Orders', Url));
        HttpRequestMessage.Method := 'POST';

        HttpRequestMessage.GetHeaders(RequestHeader);
        RequestHeader.Clear();
        RequestHeader := HttpClient.DefaultRequestHeaders();
        RequestHeader.Add(Header, HeaderValue);

        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            HttpResponseMessage.Content.ReadAs(ResponseText);
            GetOrderID(Job, ResponseText);
        end else begin

        end
    end;

    local procedure CreateOrderJSON(Job: Record Job): JsonObject
    var
        JsonObject: JsonObject;
    begin
        JsonObject.Add('orderKey', Job."No.");
        JsonObject.Add('name', Job.Description);
        JsonObject.Add('description', Job."Extended Description");
        JsonObject.Add('supervisorId', Job."Mobile Worker Supervisor ID");
        JsonObject.Add('location', Job.Location);
        JsonObject.Add('projectId', Job."Mobile Worker Project ID");
        JsonObject.Add('customerId', Job."Mobile Worker Customer ID");
        JsonObject.Add('orderStartDate', Job."Starting Date");
        JsonObject.Add('orderEndDate', Job."Ending Date");
        JsonObject.Add('deliveryDate', Job."Delivery Date");
        exit(JsonObject);
    end;

    local procedure GetOrderID(Job: Record Job; ResponseText: Text)
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        if JsonObject.ReadFrom(ResponseText) then begin
            if JsonObject.Get('orderId', JsonToken) then begin
                Job.Validate("Mobile Worker Order ID", JsonToken.AsValue().AsCode());
                Job.Validate("Extended Job Status", Enum::"Extended Job Status"::Created);
                Job.Modify();
            end;
        end else begin
            Error('Unable to read JSON Object.');
        end;
    end;

    procedure UpdateOrder(OrderID: Code[20]; JsonObject: JsonObject)
    var
        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;

        JSONObjectText: Text;
        ResponseText: Text;

        APISetup: Record "Custom API Setup";

        Url: Text;
        Header: Text;
        HeaderValue: Text;
    begin
        if CheckIfExists(APISetup) then
            APISetup.GetAPIHeaderCredentials(Url, Header, HeaderValue)
        else
            exit;

        JsonObject.WriteTo(JSONObjectText);
        HttpContent.WriteFrom(JSONObjectText);

        HttpContent.GetHeaders(ContentHeader);
        ContentHeader.Clear();
        ContentHeader.Add('Content-Type', 'application/json');

        HttpRequestMessage.Content := HttpContent;

        HttpRequestMessage.SetRequestUri(StrSubstNo('%1/Orders/%2', Url, OrderID));
        HttpRequestMessage.Method := 'PATCH';

        HttpRequestMessage.GetHeaders(RequestHeader);
        RequestHeader.Clear();
        RequestHeader := HttpClient.DefaultRequestHeaders();
        RequestHeader.Add(Header, HeaderValue);

        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            HttpResponseMessage.Content.ReadAs(ResponseText);
        end else begin
            Message(Format(HttpResponseMessage.HttpStatusCode) + ':' + HttpResponseMessage.ReasonPhrase);
        end;
    end;

    procedure GetApprovedHoursRequest(QuaryFilter: Text): Text
    var
        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;

        JSONObjectText: Text;
        ResponseText: Text;

        APISetup: Record "Custom API Setup";

        Url: Text;
        Header: Text;
        HeaderValue: Text;
    begin
        if CheckIfExists(APISetup) then
            APISetup.GetAPIHeaderCredentials(Url, Header, HeaderValue)
        else
            exit;

        HttpContent.GetHeaders(ContentHeader);
        ContentHeader.Clear();
        ContentHeader.Add('Content-Type', 'application/json');

        HttpRequestMessage.Content := HttpContent;

        HttpRequestMessage.SetRequestUri(StrSubstNo('%1/Tasks', Url));
        HttpRequestMessage.Method := 'GET';

        HttpRequestMessage.GetHeaders(RequestHeader);
        RequestHeader.Clear();
        RequestHeader := HttpClient.DefaultRequestHeaders();
        RequestHeader.Add(Header, HeaderValue);

        if HttpClient.Get(StrSubstNo('%1/Tasks', Url, QuaryFilter), HttpResponseMessage) then begin
            HttpResponseMessage.Content.ReadAs(ResponseText);
            exit(ResponseText);
        end else
            Error(HttpResponseMessage.ReasonPhrase);
    end;

    // local procedure CreateMobileWorkerLogEntry(Type: Enum "MW Log Entry Type"; RequestBody: Text; var HttpResponseMsg: HttpResponseMessage)
    // var
    //     MobileWorkerLogEntry: Record "Mobile Worker Log Entry";
    //     ResponseBody: Text;
    // begin
    //     // HttpRequestMsg.Content.ReadAs(RequestBody);
    //     HttpResponseMsg.Content.ReadAs(ResponseBody);
    //     MobileWorkerLogEntry.Init();
    //     MobileWorkerLogEntry.Validate(Type, Type);
    //     MobileWorkerLogEntry.Validate(Status, HttpResponseMsg.HttpStatusCode);
    //     MobileWorkerLogEntry.Validate("Request Body", CopyStr(RequestBody, 1, 2042));
    //     MobileWorkerLogEntry.Validate("Response Body", CopyStr(ResponseBody, 1, 2042));
    //     MobileWorkerLogEntry.Validate("Reason Phrase", HttpResponseMsg.ReasonPhrase);
    //     MobileWorkerLogEntry.Insert();
    // end;

    local procedure CreateMobileWorkerLogEntry(Type: Enum "MW Log Entry Type"; RequestBody: Text; var HttpResponseMsg: HttpResponseMessage)
    var
        MobileWorkerLogEntry: Record "Mobile Worker Log Entry";
        // RequestBody: Text;
        ResponseBody: Text;
    begin
        HttpResponseMsg.Content.ReadAs(ResponseBody);
        MobileWorkerLogEntry.Init();
        MobileWorkerLogEntry.Validate(Type, Type);
        MobileWorkerLogEntry.Validate("Request Status", HttpResponseMsg.HttpStatusCode);
        MobileWorkerLogEntry.Validate("Request Body", CopyStr(RequestBody, 1, 2042));
        MobileWorkerLogEntry.Validate("Response Body", CopyStr(ResponseBody, 1, 2042));
        MobileWorkerLogEntry.Validate("Reason Phrase", HttpResponseMsg.ReasonPhrase);
        MobileWorkerLogEntry.Insert();
    end;


    local procedure Authentication(RequestHeader: HttpHeaders)
    begin
        RequestHeader.Add('mw-api-key', '941d14cd-97bd-4a1e-a814-9752a30e712a');
    end;
}
