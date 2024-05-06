permissionset 50200 "Mobile Worker Intg."
{
    Assignable = true;
    Permissions = tabledata "Mobile Worker Log Entry" = RIMD,
        table "Mobile Worker Log Entry" = X,
        codeunit "Mobile Worker Integ. Job Queue" = X,
        codeunit "Mobile Worker Integration Mngt" = X,
        page "Mobile Worker Log Entries" = X,
        page "MW - Cost Center Group Selecti" = X;
}