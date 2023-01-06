codeunit 50151 "Mobile Worker Integ. Job Queue"
{
    trigger OnRun()
    var
        myInt: Integer;
    begin
        GetApprovedHours();
    end;

    procedure GetApprovedHours()
    var
        Job: Record Job;
        JobHours: Record "Job Hours";
        TextBuilder: TextBuilder;
        myText: Text;
        MobileWorkerIntegrationMngt: Codeunit "Mobile Worker Integration Mngt";
    begin
        TextBuilder.Append('filter=orderKey in (');
        Job.SetFilter("Extended Job Status", '%1|%2', Enum::"Extended Job Status"::Created, Enum::"Extended Job Status"::"Hours Logged");
        if not Job.IsEmpty and Job.FindSet() then
            repeat
                TextBuilder.Append(StrSubstNo('''' + Job."No." + ''','));
            until Job.Next() < 1;
        TextBuilder.Remove(TextBuilder.Length, 1);
        TextBuilder.Append(') and isApproved eq true');
        myText := TextBuilder.ToText();
        BreakdownJSONResponse(MobileWorkerIntegrationMngt.GetApprovedHoursRequest(myText));

    end;

    local procedure BreakdownJSONResponse(ResponseText: Text)
    var
        JSONObject: JsonObject;
        JSONTokenTask: JsonToken;
        JSONTokenTaskEvent: JsonToken;
        JSONArrayTasks: JsonArray;
        JSONArrayTaskEvents: JsonArray;
        JSONToken: JsonToken;
        myText: Text;
        JSONObject2: JsonObject;
        Object: JsonObject;
        Job: Record Job;
        JobHours: Record "Job Hours";
        Change: Boolean;
        JobNo: Code[20];
        UserId: Code[20];
    begin
        JSONArrayTasks.ReadFrom(ResponseText);
        foreach JSONTokenTask in JSONArrayTasks do begin
            JSONObject := JSONTokenTask.AsObject();
            JSONObject.Get('orderKey', JSONToken);
            JobNo := JSONToken.AsValue().AsCode();
            JobHours.SetRange("Job No.", JobNo);
            JSONObject.Get('userId', JSONToken);
            UserId := JSONToken.AsValue().AsCode();
            JSONObject.Get('taskEvents', JSONTokenTaskEvent);
            JSONArrayTaskEvents := JSONTokenTaskEvent.AsArray();
            foreach JSONTokenTaskEvent in JSONArrayTaskEvents do begin
                JSONObject := JSONTokenTaskEvent.AsObject();
                JSONObject.Get('taskEventId', JSONToken);
                JobHours.SetRange("Mobile Worker Task Event Id", Format(JSONToken.AsValue().AsInteger()));
                if not JobHours.IsEmpty and JobHours.FindSet() then begin
                    JSONObject.Get('quantity', JSONToken);
                    if JobHours.Quantity <> JSONToken.AsValue().AsDecimal() then begin
                        JobHours.Validate(Quantity, JSONToken.AsValue().AsDecimal());
                        Change := true;
                    end;
                    JSONObject.Get('description', JSONToken);
                    if not JSONToken.AsValue().IsNull then
                        if JobHours.Description <> JSONToken.AsValue().AsText() then begin
                            JobHours.Validate(Description, JSONToken.AsValue().AsText());
                            Change := true;
                        end;
                    JSONObject.Get('start', JSONToken);
                    if JobHours.Start <> JSONToken.AsValue().AsDateTime() then begin
                        JobHours.Validate(Start, JSONToken.AsValue().AsDateTime());
                        Change := true;
                    end;
                    JSONObject.Get('end', JSONToken);
                    if JobHours."End" <> JSONToken.AsValue().AsDateTime() then begin
                        JobHours.Validate("End", JSONToken.AsValue().AsDateTime());
                        Change := true;
                    end;
                    if Change then
                        JobHours.Modify(true);
                end else begin
                    JobHours.Init();
                    JobHours.Validate("Job No.", JobNo);
                    GetNextLineNo(JobHours);
                    GetEmployee(JobHours, UserId);
                    JSONObject.Get('description', JSONToken);
                    if not JSONToken.AsValue().IsNull then
                        JobHours.Validate(Description, JSONToken.AsValue().AsText());
                    JSONObject.Get('taskEventTypeId', JSONToken);
                    GetHourType(JobHours, JSONToken.AsValue().AsCode());
                    JSONObject.Get('start', JSONToken);
                    JobHours.Validate(Start, JSONToken.AsValue().AsDateTime());
                    JSONObject.Get('end', JSONToken);
                    JobHours.Validate("End", JSONToken.AsValue().AsDateTime());
                    JSONObject.Get('quantity', JSONToken);
                    JobHours.Validate(Quantity, JSONToken.AsValue().AsDecimal());
                    JSONObject.Get('taskEventId', JSONToken);
                    JobHours.Validate("Mobile Worker Task Event Id", JSONToken.AsValue().AsCode());
                    if JobHours.Insert(true) then begin
                        Message(JobNo);
                        if Job.Get(JobNo) then begin
                            Job.Validate(Status, Enum::"Extended Job Status"::"Hours Logged");
                            Message('Hours');
                            Job.Modify(true);
                        end;
                    end;
                end;
            end;
        end;
    end;

    local procedure GetNextLineNo(var JobHours: Record "Job Hours")
    var
        JobHours2: Record "Job Hours";
    begin
        JobHours2.SetRange("Job No.", JobHours."Job No.");
        if not JobHours2.IsEmpty and JobHours2.FindLast() then
            JobHours.Validate("Line No.", JobHours2."Line No." + 10000)
        else
            JobHours.Validate("Line No.", 10000);
    end;

    local procedure GetEmployee(var JobHours: Record "Job Hours"; UserID: Code[20])
    var
        Employee: Record SUM_SP_Employee;
    begin
        Employee.SetRange("Mobile Worker UserID", UserID);
        if not Employee.IsEmpty and Employee.FindFirst() then
            JobHours.Validate("Employee No.", Employee."No.");
    end;

    local procedure GetHourType(var JobHours: Record "Job Hours"; TypeID: Code[20])
    var
        HoursTypeSetup: Record "Hour Type Mobile Worker Setup";
    begin
        HoursTypeSetup.SetRange("Mobile Worker Id", TypeID);
        if not HoursTypeSetup.IsEmpty and HoursTypeSetup.FindFirst() then begin
            JobHours.Validate("Hour Type", HoursTypeSetup."Hour Type");
        end;
    end;
}
