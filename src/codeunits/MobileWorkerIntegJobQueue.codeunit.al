codeunit 50201 "Mobile Worker Integ. Job Queue"
{
    procedure GetApprovedHours()
    var
        Job: Record Job;
        JobHours: Record "General Job Hours";
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
        JobHours: Record "General Job Hours";
        TimeBank: Record "Time Bank Entries";
        Change: Boolean;
        JobNo: Code[20];
        UserId: Code[20];
        ApproverId: Code[20];
    begin
        if noT JSONArrayTasks.ReadFrom(ResponseText) then
            Error('No Approved Hours on Job');
        foreach JSONTokenTask in JSONArrayTasks do begin
            JSONObject := JSONTokenTask.AsObject();
            JSONObject.Get('orderKey', JSONToken);
            JobNo := JSONToken.AsValue().AsCode();
            JobHours.SetRange("Job No.", JobNo);
            JSONObject.Get('userId', JSONToken);
            UserId := JSONToken.AsValue().AsCode();
            JSONObject.Get('approvedByUserId', JSONToken);
            ApproverId := JSONToken.AsValue().AsCode();
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
                    JSONObject.Get('isHours', JSONToken);
                    if JSONToken.AsValue().AsBoolean() then begin
                        JobHours.Init();
                        JobHours.Validate("Job No.", JobNo);
                        GetNextLineNo(JobHours);
                        GetEmployee(JobHours, UserId);
                        GetApprover(JobHours, ApproverId);
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
                        CheckDifferentDayOvertime(JobHours);
                        if JobHours.Insert(true) then begin
                            if Job.Get(JobNo) then begin
                                Job.Validate("Extended Job Status", Enum::"Extended Job Status"::"Hours Logged");
                                Job.Modify(true);
                            end;
                        end;
                    end;
                    JSONObject.Get('isEvent', JSONToken);
                    if JSONToken.AsValue().AsBoolean() then begin
                        TimeBank.Init();
                        TimeBank.Validate("Job No.", JobNo);
                        GetEmployee(TimeBank, UserId);
                        JSONObject.Get('description', JSONToken);
                        if not JSONToken.AsValue().IsNull then
                            TimeBank.Validate(Description, JSONToken.AsValue().AsText());
                        JSONObject.Get('start', JSONToken);
                        TimeBank.Validate(Start, JSONToken.AsValue().AsDateTime());
                        JSONObject.Get('end', JSONToken);
                        TimeBank.Validate("End", JSONToken.AsValue().AsDateTime());
                        JSONObject.Get('quantity', JSONToken);
                        TimeBank.Validate(Quantity, JSONToken.AsValue().AsDecimal());
                        JSONObject.Get('taskEventId', JSONToken);
                        TimeBank.Validate("Mobile Worker Task Event Id", JSONToken.AsValue().AsCode());
                        TimeBank.Insert(true);
                    end;
                end;
            end;
        end;
    end;

    local procedure GetNextLineNo(var JobHours: Record "General Job Hours")
    var
        JobHours2: Record "General Job Hours";
    begin
        JobHours2.SetRange("Job No.", JobHours."Job No.");
        if not JobHours2.IsEmpty and JobHours2.FindLast() then
            JobHours.Validate("Line No.", JobHours2."Line No." + 10000)
        else
            JobHours.Validate("Line No.", 10000);
    end;

    local procedure GetEmployee(var JobHours: Record "General Job Hours"; UserID: Code[20])
    var
        Employee: Record SUM_SP_Employee;
    begin
        Employee.SetRange("Mobile Worker User ID", UserID);
        if not Employee.IsEmpty and Employee.FindFirst() then
            JobHours.Validate("Employee No.", Employee."No.");
    end;

    local procedure GetEmployee(var TimeBank: Record "Time Bank Entries"; UserID: Code[20])
    var
        Employee: Record SUM_SP_Employee;
    begin
        Employee.SetRange("Mobile Worker User ID", UserID);
        if not Employee.IsEmpty and Employee.FindFirst() then
            TimeBank.Validate("Employee No.", Employee."No.");
    end;

    local procedure GetHourType(var JobHours: Record "General Job Hours"; TypeID: Code[20])
    var
        HoursTypeSetup: Record "Job Hour Setup";
    begin
        HoursTypeSetup.SetRange("Mobile Worker Id", TypeID);
        if not HoursTypeSetup.IsEmpty and HoursTypeSetup.FindFirst() then begin
            JobHours.Validate("Hour Type", HoursTypeSetup."Hour Type");
        end;
    end;

    local procedure GetApprover(var JobHours: Record "General Job Hours"; ApproverID: Code[20])
    var
        Employee: Record SUM_SP_Employee;
    begin
        Employee.SetRange("Mobile Worker User ID", ApproverID);
        if not Employee.IsEmpty and Employee.FindFirst() then
            JobHours.Validate("Approver No.", Employee."No.");
    end;

    local procedure CheckDifferentDayOvertime(var JobHours: Record "General Job Hours")
    var
        myInt: Integer;
    begin
        if JobHours."Start Date" <> JobHours."End Date" then begin
            if InsertSecondEntry(JobHours) then
                CheckStartDaySplitQuantity(JobHours);
        end;
    end;

    procedure CheckStartDaySplitQuantity(var JobHoursEntry: Record "General Job Hours")
    var
        myInteger: Integer;
        myDecimal: Decimal;
        ZeroTime: Time;
    begin
        ZeroTime := 235900T;
        myInteger := ZeroTime - JobHoursEntry."Start Time";
        myDecimal := (((myInteger / 1000) + 60) / 60) / 60;
        JobHoursEntry.Validate(Quantity, myDecimal);
        JobHoursEntry.Validate("End", CreateDateTime(JobHoursEntry."Start Date", 0T));
    end;

    local procedure CheckEndDaySplitQuantity(JobHoursEntry: Record "General Job Hours"): Decimal
    var
        myInteger: Integer;
        myDecimal: Decimal;
        ZeroTime: Time;
    begin
        ZeroTime := 000100T;
        myInteger := JobHoursEntry."End Time" - ZeroTime;
        myDecimal := (((myInteger / 1000) + 60) / 60) / 60;
        exit(myDecimal);
    end;

    local procedure InsertSecondEntry(JobHoursEntry: Record "General Job Hours"): Boolean
    var
        JobHoursEntry2: Record "General Job Hours";
    begin
        JobHoursEntry2.Init();
        JobHoursEntry2.Validate("Employee No.", JobHoursEntry."Employee No.");
        JobHoursEntry2.Validate(Description, JobHoursEntry.Description);
        JobHoursEntry2.Validate("Approver No.", JobHoursEntry."Approver No.");
        JobHoursEntry2.Validate("Project No.", JobHoursEntry."Project No.");
        JobHoursEntry2.Validate("Hour Type", JobHoursEntry."Hour Type");
        JobHoursEntry2.Validate("Job No.", JobHoursEntry."Job No.");
        JobHoursEntry2.Validate("Line No.", JobHoursEntry."Line No." + 10000);
        JobHoursEntry2.Validate("Mobile Worker Task Event Id", JobHoursEntry."Mobile Worker Task Event Id");
        JobHoursEntry2.Validate("End", JobHoursEntry."End");
        JobHoursEntry2.Validate(Start, CreateDateTime(JobHoursEntry."End Date", 0T));
        JobHoursEntry2.Validate(Quantity, CheckEndDaySplitQuantity(JobHoursEntry2));
        if JobHoursEntry2.Insert(true) then
            exit(true);
    end;
}
