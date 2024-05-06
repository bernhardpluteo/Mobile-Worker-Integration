codeunit 50201 "Mobile Worker Integ. Job Queue"
{
    trigger OnRun()
    begin
        GetApprovedHours();
    end;

    procedure GetApprovedHours()
    var
        Job: Record Job;
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        MobileWorkerIntegrationMngt: Codeunit "Mobile Worker Integration Mngt";
        TextBuilder: TextBuilder;
        ProgressDialog: Dialog;
        Parms: Text;
    begin
        Job.SetFilter("Extended Job Status", '%1|%2', Enum::"Extended Job Status"::Created, Enum::"Extended Job Status"::"Hours Logged");
        if not Job.IsEmpty and Job.FindSet() then
            repeat
                BreakdownJSONResponse(MobileWorkerIntegrationMngt.GetApprovedHoursRequest('filter=orderKey in (''' + Job."No." + ''') and isApproved eq true'));
            until Job.Next() < 1;
        SalesHeader.SetRange("Document Type", Enum::"Sales Document Type"::Order);
        SalesHeader.SetFilter("Extended Job Status", '%1|%2', Enum::"Extended Job Status"::Created, Enum::"Extended Job Status"::"Hours Logged");
        if not SalesHeader.IsEmpty and SalesHeader.FindSet() then
            repeat
                BreakdownJSONResponse(MobileWorkerIntegrationMngt.GetApprovedHoursRequest('filter=orderKey in (''' + SalesHeader."No." + ''') and isApproved eq true'));
            until SalesHeader.Next() < 1;
        if SalesInvHeader.FindSet() then
            repeat
                BreakdownJSONResponse(MobileWorkerIntegrationMngt.GetApprovedHoursRequest('filter=orderKey in (''' + SalesInvHeader."Order No." + ''') and isApproved eq true'));
            until SalesInvHeader.Next() < 1;
    end;

    local procedure BreakdownJSONResponse(ResponseText: Text)
    var
        JobHours: Record "General Job Hours";
        JSONObject: JsonObject;
        JSONTokenTask: JsonToken;
        JSONTokenTaskEvent: JsonToken;
        JSONArrayTasks: JsonArray;
        JSONArrayTaskEvents: JsonArray;
        JSONToken: JsonToken;
        SourceType: Enum "Job Source Type";
        Change: Boolean;
        OrderKey: Code[20];
        UserId: Code[20];
        ApproverId: Code[20];
        VehicleId: Integer;
        ProgressDialog: Dialog;
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if JSONArrayTasks.ReadFrom(ResponseText) then begin
            ProgressDialog.Open('#1######### \#2########\#3################');
            foreach JSONTokenTask in JSONArrayTasks do begin

                JSONObject := JSONTokenTask.AsObject();
                JSONObject.Get('orderKey', JSONToken);
                OrderKey := JSONToken.AsValue().AsCode();
                CheckSourceType(OrderKey, SourceType);
                JobHours.SetRange("Source Type", SourceType);
                JobHours.SetRange("Source No.", OrderKey);
                JSONObject.Get('userId', JSONToken);
                UserId := JSONToken.AsValue().AsCode();
                JSONObject.Get('approvedByUserId', JSONToken);
                ApproverId := JSONToken.AsValue().AsCode();
                if JSONObject.Get('costCenterId', JSONToken) then
                    if not JSONToken.AsValue().IsNull then
                        VehicleId := JSONToken.AsValue().AsInteger();
                JSONObject.Get('taskEvents', JSONTokenTaskEvent);
                JSONArrayTaskEvents := JSONTokenTaskEvent.AsArray();
                foreach JSONTokenTaskEvent in JSONArrayTaskEvents do begin
                    JSONObject := JSONTokenTaskEvent.AsObject();
                    JSONObject.Get('taskEventId', JSONToken);
                    ProgressDialog.Update(1, OrderKey);
                    ProgressDialog.Update(2, Format(JSONToken.AsValue().AsInteger()));
                    JobHours.SetRange("Mobile Worker Task Event Id", Format(JSONToken.AsValue().AsInteger()));
                    if JobHours.FindFirst() then begin
                        JSONObject.Get('quantity', JSONToken);
                        if JobHours.Quantity <> JSONToken.AsValue().AsDecimal() then begin
                            JobHours.Validate(Quantity, JSONToken.AsValue().AsDecimal());
                            Change := true;
                        end;
                        JSONObject.Get('description', JSONToken);
                        if not (JSONToken.AsValue().IsNull) then
                            if not (JSONToken.AsValue().AsText() = '') then
                                if JobHours.Description <> JSONToken.AsValue().AsText() then begin
                                    ProgressDialog.Update(3, JSONToken.AsValue().AsText());
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
                        JobHours.Validate("Source Type", SourceType);
                        if JobHours."Source Type" = Enum::"Job Source Type"::"Sales Order" then begin
                            if SalesHeader.Get(Enum::"Sales Document Type"::Order, OrderKey) then
                                JobHours.Validate("Source No.", OrderKey)
                            else begin
                                SalesInvHeader.SetRange("Order No.", OrderKey);
                                if SalesInvHeader.FindFirst() then begin
                                    JobHours."Source No." := OrderKey;
                                    JobHours.Validate("Project No.", SalesInvHeader."Project No.");
                                    JobHours.Validate("Shortcut Dimension 3 Code", SalesInvHeader."Project No.");
                                end;
                            end;
                        end else
                            if JobHours."Source Type" = Enum::"Job Source Type"::Job then
                                JobHours.Validate("Source No.", OrderKey);
                        GetNextLineNo(JobHours);
                        GetEmployee(JobHours, UserId);
                        GetApprover(JobHours, ApproverId);
                        GetGlobalDimensionOne(JobHours);
                        GetGlobalDimensionTwo(JobHours, VehicleId);
                        JSONObject.Get('description', JSONToken);
                        if not JSONToken.AsValue().IsNull then begin
                            ProgressDialog.Update(3, JSONToken.AsValue().AsText());
                            JobHours.Validate(Description, JSONToken.AsValue().AsText());
                        end;
                        JSONObject.Get('taskEventTypeId', JSONToken);
                        if CheckHourType(JobHours, JSONToken.AsValue().AsCode()) then begin
                            JSONObject.Get('start', JSONToken);
                            JobHours.Validate(Start, JSONToken.AsValue().AsDateTime());
                            JSONObject.Get('end', JSONToken);
                            JobHours.Validate("End", JSONToken.AsValue().AsDateTime());
                            JSONObject.Get('quantity', JSONToken);
                            JobHours.Validate(Quantity, JSONToken.AsValue().AsDecimal());
                            JSONObject.Get('taskEventId', JSONToken);
                            JobHours.Validate("Mobile Worker Task Event Id", JSONToken.AsValue().AsCode());
                            CheckDifferentDayOvertime(JobHours);
                            if JobHours.Insert(true) then
                                SetStatus(SourceType, OrderKey);
                        end;
                    end;
                end;
            end;
            ProgressDialog.Close();
        end;
    end;

    local procedure CheckSourceType(OrderKey: Code[20]; var SourceType: Enum "Job Source Type")
    var
        Job: Record Job;
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if Job.Get(OrderKey) then
            SourceType := Enum::"Job Source Type"::Job
        else
            if SalesHeader.Get(Enum::"Sales Document Type"::Order, OrderKey) then
                SourceType := Enum::"Job Source Type"::"Sales Order"
            else begin
                SalesInvHeader.SetRange("Order No.", OrderKey);
                if SalesInvHeader.FindFirst() then
                    SourceType := Enum::"Job Source Type"::"Sales Order"
                else
                    SourceType := Enum::"Job Source Type"::" ";
            end;
    end;

    local procedure SetStatus(SourceType: Enum "Job Source Type"; OrderKey: Code[20])
    var
        Job: Record Job;
        SalesHeader: Record "Sales Header";
    begin
        case SourceType of
            Enum::"Job Source Type"::Job:
                if Job.Get(OrderKey) then begin
                    Job.Validate("Extended Job Status", Enum::"Extended Job Status"::"Hours Logged");
                    Job.Modify(true);
                end;
            Enum::"Job Source Type"::"Sales Order":
                if SalesHeader.Get(Enum::"Sales Document Type"::Order, OrderKey) then begin
                    SalesHeader.Validate("Extended Job Status", Enum::"Extended Job Status"::"Hours Logged");
                    SalesHeader.Modify(true);
                end;
        end;
    end;

    local procedure GetNextLineNo(var JobHours: Record "General Job Hours")
    var
        JobHours2: Record "General Job Hours";
    begin
        JobHours2.SetRange("Source Type", JobHours."Source Type");
        JobHours2.SetRange("Source No.", JobHours."Source No.");
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

    local procedure CheckHourType(var JobHours: Record "General Job Hours"; TypeID: Code[20]): Boolean
    var
        HoursTypeSetup: Record "Job Hour Type Setup";
    begin
        HoursTypeSetup.SetRange("Mobile Worker Id", TypeID);
        if not HoursTypeSetup.IsEmpty and HoursTypeSetup.FindFirst() then begin
            JobHours.Validate("Hour Type", HoursTypeSetup."Hour Type");
            exit(true);
        end else
            exit(false);
    end;

    local procedure GetGlobalDimensionOne(var JobHours: Record "General Job Hours")
    var
        Job: Record Job;
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if JobHours."Source Type" = Enum::"Job Source Type"::Job then begin
            Job.Get(JobHours."Source No.");
            JobHours.Validate("Global Dimension 1 Code", Job."Global Dimension 1 Code");
        end else
            if JobHours."Source Type" = Enum::"Job Source Type"::"Sales Order" then begin
                if SalesHeader.Get(Enum::"Sales Document Type"::Order, JobHours."Source No.") then
                    JobHours.Validate("Global Dimension 1 Code", SalesHeader."Shortcut Dimension 1 Code")
                else begin
                    SalesInvHeader.SetRange("Order No.", JobHours."Source No.");
                    if SalesInvHeader.FindFirst() then
                        JobHours.Validate("Global Dimension 1 Code", SalesInvHeader."Shortcut Dimension 1 Code");
                end;
            end;
    end;

    local procedure GetGlobalDimensionTwo(var JobHours: Record "General Job Hours"; VehicleId: Integer)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionValue: Record "Dimension Value";
    begin
        GeneralLedgerSetup.Get();
        DimensionValue.SetRange("Dimension Code", GeneralLedgerSetup."Global Dimension 2 Code");
        DimensionValue.SetRange("Mobile Worker ID", Format(VehicleId));
        if not DimensionValue.IsEmpty and DimensionValue.FindFirst() then
            JobHours.Validate("Global Dimension 2 Code", DimensionValue.Code);
    end;

    local procedure ShortcutDimension3(var JobHours: Record "General Job Hours")
    var
        Job: Record Job;
        SalesHeader: Record "Sales Header";
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionSetEntry: Record "Dimension Set Entry";
        DefaultDimension: Record "Default Dimension";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        GeneralLedgerSetup.Get();
        if JobHours."Source Type" = Enum::"Job Source Type"::Job then begin
            Job.Get(JobHours."Source No.");
            DefaultDimension.Get(Job.RecordId.TableNo, Job."No.", GeneralLedgerSetup."Shortcut Dimension 3 Code");
            JobHours.Validate("Shortcut Dimension 3 Code", DefaultDimension."Dimension Value Code");

        end else
            if JobHours."Source Type" = Enum::"Job Source Type"::"Sales Order" then begin
                if SalesHeader.Get(Enum::"Sales Document Type"::Order, JobHours."Source No.") then begin
                    DimensionSetEntry.Get(SalesHeader."Dimension Set ID", GeneralLedgerSetup."Shortcut Dimension 3 Code");
                    JobHours.Validate("Shortcut Dimension 3 Code", DimensionSetEntry."Dimension Value Code");
                end else begin
                    SalesInvHeader.SetRange("Order No.", JobHours."Source No.");
                    if SalesInvHeader.FindFirst() then begin
                        DimensionSetEntry.Get(SalesInvHeader."Dimension Set ID", GeneralLedgerSetup."Shortcut Dimension 3 Code");
                        JobHours.Validate("Shortcut Dimension 3 Code", DimensionSetEntry."Dimension Value Code");
                    end;
                end;
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
    begin
        if JobHours."Start Date" <> JobHours."End Date" then
            if InsertSecondEntry(JobHours) then
                CheckStartDaySplitQuantity(JobHours);
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
        // JobHoursEntry2.Init();
        JobHoursEntry2.TransferFields(JobHoursEntry, true);
        JobHoursEntry2.Validate("Line No.", JobHoursEntry."Line No." + 10000);
        JobHoursEntry2.Validate(Start, CreateDateTime(JobHoursEntry."End Date", 0T));
        JobHoursEntry2.Validate(Quantity, CheckEndDaySplitQuantity(JobHoursEntry2));
        // JobHoursEntry2.Validate("Employee No.", JobHoursEntry."Employee No.");
        // JobHoursEntry2.Validate(Description, JobHoursEntry.Description);
        // JobHoursEntry2.Validate("Approver No.", JobHoursEntry."Approver No.");
        // JobHoursEntry2.Validate("Project No.", JobHoursEntry."Project No.");
        // JobHoursEntry2.Validate("Hour Type", JobHoursEntry."Hour Type");
        // JobHoursEntry2.Validate("Source Type", JobHoursEntry."Source Type");
        // JobHoursEntry2."Source No." := JobHoursEntry."Source No.";
        // JobHoursEntry2.SourceId := JobHoursEntry.SourceId;
        // JobHoursEntry2.Validate("Line No.", JobHoursEntry."Line No." + 10000);
        // JobHoursEntry2.Validate("Mobile Worker Task Event Id", JobHoursEntry."Mobile Worker Task Event Id");
        // JobHoursEntry2.Validate("End", JobHoursEntry."End");
        // JobHoursEntry2.Validate(Start, CreateDateTime(JobHoursEntry."End Date", 0T));
        // JobHoursEntry2.Validate(Quantity, CheckEndDaySplitQuantity(JobHoursEntry2));
        // JobHoursEntry2.Validate("Global Dimension 1 Code", JobHoursEntry."Global Dimension 1 Code");
        // JobHoursEntry2.Validate("Global Dimension 2 Code", JobHoursEntry."Global Dimension 2 Code");
        // JobHoursEntry2.Validate("Shortcut Dimension 3 Code", JobHoursEntry."Shortcut Dimension 3 Code");
        if JobHoursEntry2.Insert(true) then
            exit(true);
    end;

    // local procedure CheckSupervisorBonus(JobHoursEntry: Record "General Job Hours")
    // var
    //     SUM_SP_Settings: Record SUM_SP_Settings;
    //     Job: Record Job;
    //     SalesHeader: Record "Sales Header";
    // begin
    //     SUM_SP_Settings.Get();
    //     if SUM_SP_Settings.CheckSupervisorBonus() then
    //         case JobHoursEntry."Source Type" of
    //             Enum::"Job Source Type"::Job:
    //                 if Job.Get(JobHoursEntry."Source No.") then
    //                     if Job."Team Supervisor No." = JobHoursEntry."Employee No." then
    //                         CreateSupervisorBonusJobEntry(JobHoursEntry);
    //             Enum::"Job Source Type"::"Sales Order":
    //                 if SalesHeader.Get(Enum::"Sales Document Type"::Order, JobHoursEntry."Source No.") then
    //                     if SalesHeader."Team Supervisor No." = JobHoursEntry."Employee No." then
    //                         CreateSupervisorBonusJobEntry(JobHoursEntry);
    //         end;
    // end;

    // local procedure CreateSupervisorBonusJobEntry(JobHoursEntry: Record "General Job Hours")
    // var
    //     SupervisorBonusJobHourEntry: Record "General Job Hours";
    // begin
    //     SupervisorBonusJobHourEntry.Init();
    //     SupervisorBonusJobHourEntry.TransferFields(JobHoursEntry);
    //     GetNextLineNo(SupervisorBonusJobHourEntry);
    //     SupervisorBonusJobHourEntry."Hour Type" := Enum::"Hour Type"::"Supervisor Hours";
    //     SupervisorBonusJobHourEntry.Insert();
    // end;
}
