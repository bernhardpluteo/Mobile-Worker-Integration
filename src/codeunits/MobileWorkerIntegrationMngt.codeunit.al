codeunit 50200 "Mobile Worker Integration Mngt"
{
    local procedure CheckIfExists(var APISetup: Record "Custom API Setup"): Boolean
    begin
        if APISetup.Get('Mobile Worker') then
            exit(true)
        else
            exit(false)
    end;

    procedure CreateUser(Employee: Record SUM_SP_Employee)
    var
        APISetup: Record "Custom API Setup";

        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;

        JSONObjectText: Text;
        JSONObject: JsonObject;
        ResponseText: Text;

        Url: Text;
        Header: Text;
        HeaderValue: Text;
    begin
        if not CheckIfUserExists(Employee) then begin
            if CheckIfExists(APISetup) then
                APISetup.GetAPIHeaderCredentials(Url, Header, HeaderValue)
            else
                exit;

            CreateEmployeeJSON(Employee).WriteTo(JSONObjectText);
            HttpContent.WriteFrom(JSONObjectText);

            HttpContent.GetHeaders(ContentHeader);
            ContentHeader.Clear();
            ContentHeader.Add('Content-Type', 'application/json');

            HttpRequestMessage.Content := HttpContent;

            HttpRequestMessage.SetRequestUri(StrSubstNo('%1/Users', Url));
            HttpRequestMessage.Method := 'POST';

            HttpRequestMessage.GetHeaders(RequestHeader);
            RequestHeader.Clear();
            RequestHeader := HttpClient.DefaultRequestHeaders();
            RequestHeader.Add(Header, HeaderValue);

            HttpClient.Send(HttpRequestMessage, HttpResponseMessage);

            CreateMobileWorkerLogEntry(Enum::"MW Log Entry Type"::"Create User", JSONObjectText, HttpResponseMessage);
            if HttpResponseMessage.IsSuccessStatusCode then begin
                HttpResponseMessage.Content.ReadAs(ResponseText);
                if JSONObject.ReadFrom(ResponseText) then
                    GetMobileWorkerUserID(Employee, JSONObject)
                else
                    Error('Mobile Worker: User: Unable to read JSON Object.');
            end;
        end;
    end;

    local procedure CheckIfUserExists(Employee: Record SUM_SP_Employee): Boolean
    var
        APISetup: Record "Custom API Setup";

        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;

        JSONObject: JsonObject;
        JSONToken: JsonToken;
        JSONArray: JsonArray;

        ResponseText: Text;

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
        HttpRequestMessage.Content := HttpContent;

        HttpRequestMessage.SetRequestUri(StrSubstNo('%1/Users?$filter=email in (''%2'')', Url, Employee."E-Mail"));
        HttpRequestMessage.Method := 'GET';

        HttpRequestMessage.GetHeaders(RequestHeader);
        RequestHeader.Clear();
        RequestHeader := HttpClient.DefaultRequestHeaders();
        RequestHeader.Add(Header, HeaderValue);

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);

        if HttpResponseMessage.IsSuccessStatusCode then begin
            HttpResponseMessage.Content.ReadAs(ResponseText);
            JSONArray.ReadFrom(ResponseText);
            if JSONArray.Get(0, JSONToken) then begin
                JSONObject := JSONToken.AsObject();
                GetMobileWorkerUserID(Employee, JSONObject);
                exit(true);
            end else
                exit(false);
        end;

    end;

    local procedure GetMobileWorkerUserID(Employee: Record SUM_SP_Employee; JsonObject: JsonObject)
    var
        JsonToken: JsonToken;
    begin
        if JsonObject.Get('userId', JsonToken) then begin
            Employee.Validate("Mobile Worker User ID", JsonToken.AsValue().AsCode());
            if JsonObject.Get('status', JsonToken) then
                Employee.Validate("Mobile Worker Status", JsonToken.AsValue().AsText());
            Employee.Modify();
        end;
    end;

    local procedure CreateEmployeeJSON(Employee: Record SUM_SP_Employee): JsonObject
    var
        JSONObject: JsonObject;
    begin
        JSONObject.Add('userExtId', Format(Employee."No."));
        JSONObject.Add('email', Employee."E-Mail");
        JSONObject.Add('userName', Employee."E-Mail");
        JSONObject.Add('firstName', Employee."First Name");
        JSONObject.Add('lastName', Employee."Last Name");
        JSONObject.Add('homePhoneNumber', Employee."Phone No.");
        JSONObject.Add('workMobilePhoneNumber', Employee."Mobile Phone No.");
        JSONObject.Add('dateOfBirth', Employee."Birth Date");
        JSONObject.Add('departmentId', Employee."Moblie Worker Department Id");
        exit(JSONObject);
    end;

    procedure CreateCustomer(Customer: Record Customer)
    var
        APISetup: Record "Custom API Setup";

        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;

        JSONObjectText: Text;
        ResponseText: Text;

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
        end else
            Error('Unable to read JSON Object.');
    end;

    local procedure CreateCustomerJSON(Customer: Record Customer): JsonObject
    var
        JSONObject: JsonObject;
    begin
        JSONObject.Add('customerKey', Customer."No.");
        JSONObject.Add('customerExtId', Customer."No.");
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
        APISetup: Record "Custom API Setup";

        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;

        JSONObjectText: Text;

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

    procedure CreateDepartment(DimensionsValue: Record "Dimension Value")
    var
        APISetup: Record "Custom API Setup";

        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;

        JSONObjectText: Text;

        Url: Text;
        Header: Text;
        HeaderValue: Text;
    begin
        if CheckIfExists(APISetup) then
            APISetup.GetAPIHeaderCredentials(Url, Header, HeaderValue)
        else
            exit;

        CreateDepartmentJSON(DimensionsValue).WriteTo(JSONObjectText);
        HttpContent.WriteFrom(JSONObjectText);

        HttpContent.GetHeaders(ContentHeader);
        ContentHeader.Clear();
        ContentHeader.Add('Content-Type', 'application/json');

        HttpRequestMessage.Content := HttpContent;

        HttpRequestMessage.SetRequestUri(StrSubstNo('%1/Departments', Url));
        HttpRequestMessage.Method := 'POST';

        HttpRequestMessage.GetHeaders(RequestHeader);
        RequestHeader.Clear();
        RequestHeader := HttpClient.DefaultRequestHeaders();
        RequestHeader.Add(Header, HeaderValue);

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);

        CreateMobileWorkerLogEntry(Enum::"MW Log Entry Type"::"Create Department", JSONObjectText, HttpResponseMessage);
        if HttpResponseMessage.IsSuccessStatusCode then begin
            HttpResponseMessage.Content.ReadAs(ResponseText);
            GetMobileWorkerDepartmentID(DimensionsValue, ResponseText);
        end;
    end;

    local procedure GetMobileWorkerDepartmentID(DimensionValue: Record "Dimension Value"; ResponseText: Text)
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        if JsonObject.ReadFrom(ResponseText) then begin
            if JsonObject.Get('departmentId', JsonToken) then begin
                DimensionValue.Validate("Mobile Worker Related Entity", Enum::"MW Related Entity"::Department);
                DimensionValue.Validate("Mobile Worker ID", JsonToken.AsValue().AsCode());
                DimensionValue.Modify();
            end;
        end else
            Error('Unable to read JSON Object.');
    end;

    local procedure CreateDepartmentJSON(DimensionValue: Record "Dimension Value"): JsonObject
    var
        JSONObject: JsonObject;
    begin
        JSONObject.Add('departmentExtId', DimensionValue.Code);
        JSONObject.Add('departmentKey', DimensionValue.Code);
        JSONObject.Add('name', DimensionValue.Name);
        exit(JSONObject);
    end;

    procedure CreateCostCenterGroup(DimensionsValue: Record "Dimension Value")
    var
        APISetup: Record "Custom API Setup";

        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;

        JSONObjectText: Text;

        Url: Text;
        Header: Text;
        HeaderValue: Text;
    begin
        if CheckIfExists(APISetup) then
            APISetup.GetAPIHeaderCredentials(Url, Header, HeaderValue)
        else
            exit;

        CreateCostCenterGroupJSON(DimensionsValue).WriteTo(JSONObjectText);
        HttpContent.WriteFrom(JSONObjectText);

        HttpContent.GetHeaders(ContentHeader);
        ContentHeader.Clear();
        ContentHeader.Add('Content-Type', 'application/json');

        HttpRequestMessage.Content := HttpContent;

        HttpRequestMessage.SetRequestUri(StrSubstNo('%1/CostCenterGroups', Url));
        HttpRequestMessage.Method := 'POST';

        HttpRequestMessage.GetHeaders(RequestHeader);
        RequestHeader.Clear();
        RequestHeader := HttpClient.DefaultRequestHeaders();
        RequestHeader.Add(Header, HeaderValue);

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);

        CreateMobileWorkerLogEntry(Enum::"MW Log Entry Type"::"Create Cost Center Group", JSONObjectText, HttpResponseMessage);
        if HttpResponseMessage.IsSuccessStatusCode then begin
            HttpResponseMessage.Content.ReadAs(ResponseText);
            GetMobileWorkerCostCenterGrouptID(DimensionsValue, ResponseText);
        end;
    end;

    local procedure CreateCostCenterGroupJSON(DimensionValue: Record "Dimension Value"): JsonObject
    var
        JSONObject: JsonObject;
    begin
        JSONObject.Add('costCenterGroupExtId', DimensionValue.Code);
        JSONObject.Add('name', DimensionValue.Name);
        exit(JSONObject);
    end;

    local procedure GetMobileWorkerCostCenterGrouptID(DimensionValue: Record "Dimension Value"; ResponseText: Text)
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        if JsonObject.ReadFrom(ResponseText) then begin
            if JsonObject.Get('costCenterGroupId', JsonToken) then begin
                DimensionValue.Validate("Mobile Worker Related Entity", Enum::"MW Related Entity"::"Cost Center Group");
                DimensionValue.Validate("Mobile Worker ID", JsonToken.AsValue().AsCode());
                DimensionValue.Modify();
            end;
        end else
            Error('Unable to read JSON Object.');
    end;

    procedure CreateCostCenter(DimensionsValue: Record "Dimension Value"; CostCenterGroupDimensionValue: Record "Dimension Value")
    var
        APISetup: Record "Custom API Setup";

        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;

        JSONObjectText: Text;

        Url: Text;
        Header: Text;
        HeaderValue: Text;
    begin
        if CheckIfExists(APISetup) then
            APISetup.GetAPIHeaderCredentials(Url, Header, HeaderValue)
        else
            exit;

        CreateCostCenterJSON(DimensionsValue, CostCenterGroupDimensionValue).WriteTo(JSONObjectText);
        HttpContent.WriteFrom(JSONObjectText);

        HttpContent.GetHeaders(ContentHeader);
        ContentHeader.Clear();
        ContentHeader.Add('Content-Type', 'application/json');

        HttpRequestMessage.Content := HttpContent;

        HttpRequestMessage.SetRequestUri(StrSubstNo('%1/CostCenters', Url));
        HttpRequestMessage.Method := 'POST';

        HttpRequestMessage.GetHeaders(RequestHeader);
        RequestHeader.Clear();
        RequestHeader := HttpClient.DefaultRequestHeaders();
        RequestHeader.Add(Header, HeaderValue);

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);

        CreateMobileWorkerLogEntry(Enum::"MW Log Entry Type"::"Create Cost Center", JSONObjectText, HttpResponseMessage);
        if HttpResponseMessage.IsSuccessStatusCode then begin
            HttpResponseMessage.Content.ReadAs(ResponseText);
            GetMobileWorkerCostCentertID(DimensionsValue, ResponseText);
        end;
    end;

    local procedure CreateCostCenterJSON(DimensionValue: Record "Dimension Value"; CostCenterGroupDimensionValue: Record "Dimension Value"): JsonObject
    var
        JSONObject: JsonObject;
    begin
        JSONObject.Add('name', DimensionValue.Name);
        JSONObject.Add('costCenterKey', DimensionValue.Code);
        JSONObject.Add('costCenterExtId', DimensionValue.Code);
        JSONObject.Add('groupId', CostCenterGroupDimensionValue."Mobile Worker ID");
        exit(JSONObject);
    end;

    local procedure GetMobileWorkerCostCentertID(DimensionValue: Record "Dimension Value"; ResponseText: Text)
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        if JsonObject.ReadFrom(ResponseText) then begin
            if JsonObject.Get('costCenterId', JsonToken) then begin
                DimensionValue.Validate("Mobile Worker Related Entity", Enum::"MW Related Entity"::"Cost Center");
                DimensionValue.Validate("Mobile Worker ID", JsonToken.AsValue().AsCode());
                DimensionValue.Modify();
            end;
        end else
            Error('Unable to read JSON Object.');
    end;

    procedure CreateProject(Project: Record Project)
    var
        APISetup: Record "Custom API Setup";

        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;

        JSONObjectText: Text;
        ResponseText: Text;

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
        JsonObject.Add('end', Project."Expected Completion Date");
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
        end else
            Error('Unable to read JSON Object.');
    end;

    procedure UpdateProject(ProjectID: Code[20]; JsonObject: JsonObject)
    var
        APISetup: Record "Custom API Setup";

        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;

        JSONObjectText: Text;

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
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
    begin
        HttpResponseMessage := CreateOrderRequest(CreateOrderJSON(Job));

        if HttpResponseMessage.IsSuccessStatusCode then begin
            HttpResponseMessage.Content.ReadAs(ResponseText);
            GetOrderID(Job, ResponseText);
        end else begin
            HttpResponseMessage.Content.ReadAs(ResponseText);
            SetMobileWorkerError(Job, ResponseText);
        end;
    end;

    procedure CreateSalesOrderAsOrder(var SalesHeader: Record "Sales Header")
    var
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
    begin

        HttpResponseMessage := CreateOrderRequest(CreateOrderJSON(SalesHeader));

        if HttpResponseMessage.IsSuccessStatusCode then begin
            HttpResponseMessage.Content.ReadAs(ResponseText);
            GetOrderID(SalesHeader, ResponseText);
        end else begin
            HttpResponseMessage.Content.ReadAs(ResponseText);
            SetMobileWorkerError(SalesHeader, ResponseText);
        end;
    end;

    local procedure CreateOrderRequest(JsonObject: JsonObject): HttpResponseMessage
    var
        APISetup: Record "Custom API Setup";

        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;

        JSONObjectText: Text;

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

        HttpRequestMessage.SetRequestUri(StrSubstNo('%1/Orders', Url));
        HttpRequestMessage.Method := 'POST';

        HttpRequestMessage.GetHeaders(RequestHeader);
        RequestHeader.Clear();
        RequestHeader := HttpClient.DefaultRequestHeaders();
        RequestHeader.Add(Header, HeaderValue);

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        CreateMobileWorkerLogEntry(Enum::"MW Log Entry Type"::"Create Order", JSONObjectText, HttpResponseMessage);
        exit(HttpResponseMessage);
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
        JsonObject.Add('departmentId', GetMobileWorkerDepartmentId(Job));
        exit(JsonObject);
    end;

    local procedure CreateOrderJSON(SalesHeader: Record "Sales Header"): JsonObject
    var
        JsonObject: JsonObject;
    begin
        JsonObject.Add('orderKey', SalesHeader."No.");
        JsonObject.Add('name', SalesHeader.Description);
        JsonObject.Add('description', SalesHeader."Extended Description");
        JsonObject.Add('supervisorId', SalesHeader."Mobile Worker Supervisor ID");
        JsonObject.Add('location', SalesHeader.Location);
        JsonObject.Add('projectId', SalesHeader."Mobile Worker Project ID");
        JsonObject.Add('customerId', SalesHeader."Mobile Worker Customer ID");
        JsonObject.Add('orderStartDate', SalesHeader."Start Date");
        JsonObject.Add('orderEndDate', SalesHeader."End Date");
        JsonObject.Add('deliveryDate', SalesHeader."Delivery Date");
        JsonObject.Add('departmentId', GetMobileWorkerDepartmentId(SalesHeader));
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
        end else
            Error('Unable to read JSON Object.');
    end;

    local procedure GetOrderID(var SalesHeader: Record "Sales Header"; ResponseText: Text)
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        if JsonObject.ReadFrom(ResponseText) then begin
            if JsonObject.Get('orderId', JsonToken) then begin
                SalesHeader.Validate("Mobile Worker Order ID", JsonToken.AsValue().AsCode());
                SalesHeader.Validate("Extended Job Status", Enum::"Extended Job Status"::Created);
                SalesHeader.Modify(false);
            end;
        end else
            Error('Unable to read JSON Object.');
    end;

    local procedure SetMobileWorkerError(Job: Record Job; ResponseText: Text)
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        JsonArray: JsonArray;
    begin
        if JsonObject.ReadFrom(ResponseText) then
            if JsonObject.Get('errors', JsonToken) then begin
                JsonArray := JsonToken.AsArray();
                if JsonArray.Get(0, JsonToken) then begin
                    JsonObject := JsonToken.AsObject();
                    if JsonObject.Get('message', JsonToken) then begin
                        Job.Validate("Extended Job Status", Enum::"Extended Job Status"::Error);
                        Job.Validate("Mobile Worker Error Message", JsonToken.AsValue().AsText());
                        Job.Modify();
                    end;
                end;
            end;
    end;

    local procedure SetMobileWorkerError(SalesHeader: Record "Sales Header"; ResponseText: Text)
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        JsonArray: JsonArray;
    begin
        if JsonObject.ReadFrom(ResponseText) then
            if JsonObject.Get('errors', JsonToken) then begin
                JsonArray := JsonToken.AsArray();
                if JsonArray.Get(0, JsonToken) then begin
                    JsonObject := JsonToken.AsObject();
                    if JsonObject.Get('message', JsonToken) then begin
                        SalesHeader.Validate("Extended Job Status", Enum::"Extended Job Status"::Error);
                        SalesHeader.Validate("Mobile Worker Error Message", JsonToken.AsValue().AsText());
                        SalesHeader.Modify(false);
                    end;
                end;
            end;
    end;

    procedure UpdateOrder(OrderID: Code[20]; JsonObject: JsonObject)
    var
        APISetup: Record "Custom API Setup";

        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;

        JSONObjectText: Text;
        ResponseText: Text;

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

        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            HttpResponseMessage.Content.ReadAs(ResponseText)
        else
            Message(Format(HttpResponseMessage.HttpStatusCode) + ':' + HttpResponseMessage.ReasonPhrase);
    end;

    procedure GetApprovedHoursRequest(QueryFilter: Text): Text
    var
        APISetup: Record "Custom API Setup";

        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;

        ResponseText: Text;

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

        RequestHeader.Clear();
        RequestHeader := HttpClient.DefaultRequestHeaders();
        RequestHeader.Add(Header, HeaderValue);

        if HttpClient.Get(StrSubstNo('%1/Tasks?$%2', Url, QueryFilter), HttpResponseMessage) then begin
            HttpResponseMessage.Content.ReadAs(ResponseText);
            exit(ResponseText);
        end else
            Error(HttpResponseMessage.ReasonPhrase);
    end;

    local procedure GetMobileWorkerDepartmentId(Job: Record Job): Code[20]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionValue: Record "Dimension Value";
    begin
        GeneralLedgerSetup.Get();
        if DimensionValue.Get(GeneralLedgerSetup."Global Dimension 1 Code", Job."Global Dimension 1 Code") then
            exit(DimensionValue."Mobile Worker ID");
    end;

    local procedure GetMobileWorkerDepartmentId(SalesHeader: Record "Sales Header"): Code[20]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionValue: Record "Dimension Value";
    begin
        GeneralLedgerSetup.Get();
        if DimensionValue.Get(GeneralLedgerSetup."Global Dimension 1 Code", SalesHeader."Shortcut Dimension 1 Code") then
            exit(DimensionValue."Mobile Worker ID");
    end;


    local procedure CreateMobileWorkerLogEntry(Type: Enum "MW Log Entry Type"; RequestBody: Text; var HttpResponseMsg: HttpResponseMessage)
    var
        MobileWorkerLogEntry: Record "Mobile Worker Log Entry";
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', true, true)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header")
    begin
        if not (SalesHeader."Mobile Worker Order ID" = '') AND (SalesHeader.Invoice) then begin
            CloseMWOrder(SalesHeader."Mobile Worker Order ID");
        end;
    end;

    local procedure CloseMWOrder(MWOrderID: Code[20])
    var
        APISetup: Record "Custom API Setup";

        RequestHeader: HttpHeaders;
        ContentHeader: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;

        JsonObject: JsonObject;
        JSONObjectText: Text;

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

        HttpRequestMessage.SetRequestUri(StrSubstNo('%1/CloseOrders/%2', Url, MWOrderID));
        HttpRequestMessage.Method := 'POST';

        HttpRequestMessage.GetHeaders(RequestHeader);
        RequestHeader.Clear();
        RequestHeader := HttpClient.DefaultRequestHeaders();
        RequestHeader.Add(Header, HeaderValue);

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        CreateMobileWorkerLogEntry(Enum::"MW Log Entry Type"::"Update Order", JSONObjectText, HttpResponseMessage);
    end;
}
