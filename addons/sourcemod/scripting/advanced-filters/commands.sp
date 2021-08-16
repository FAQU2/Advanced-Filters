void RegisterCommands()
{
	RegAdminCmd("sm_chatfilters", Command_ChatFilters, ADMFLAG_ROOT, "Prints currently loaded chat filters.");
	RegAdminCmd("sm_namefilters", Command_NameFilters, ADMFLAG_ROOT, "Prints currently loaded name filters.");
	RegAdminCmd("sm_whitelist", Command_Whitelist, ADMFLAG_ROOT, "Prints currently loaded whitelist filters.");
	RegAdminCmd("sm_reloadfilters", Command_ReloadFilters, ADMFLAG_ROOT, "Re-reads all filters from their corresponding files.");
}

public Action Command_ChatFilters(int client, int args)
{
	switch (gb_UseChatFilters)
	{
		case 0: ReplyToCommand(client, "[Advanced Filters] Chat Filters are disabled.");
		case 1:
		{
			ReplyToCommand(client, "[Advanced Filters] Chat Filters:");
			PrintStringArray(client, gs_ChatFilters, sizeof(gs_ChatFilters));
		}
	}
	return Plugin_Handled;
}

public Action Command_NameFilters(int client, int args)
{
	switch (gb_UseNameFilters)
	{
		case 0: ReplyToCommand(client, "[Advanced Filters] Name Filters are disabled.");
		case 1:
		{
			ReplyToCommand(client, "[Advanced Filters] Name Filters:");
			PrintStringArray(client, gs_NameFilters, sizeof(gs_NameFilters));
		}
	}
	return Plugin_Handled;
}

public Action Command_Whitelist(int client, int args)
{
	switch (gb_UseWhitelist)
	{
		case 0: ReplyToCommand(client, "[Advanced Filters] Whitelist is disabled.");
		case 1:
		{
			ReplyToCommand(client, "[Advanced Filters] Whitelist Filters:");
			PrintStringArray(client, gs_WhitelistFilters, sizeof(gs_WhitelistFilters));
		}
	}
	return Plugin_Handled;
}

public Action Command_ReloadFilters(int client, int args)
{
	ReloadFilters();
	ReplyToCommand(client, "[Advanced Filters] Filters reloaded.");
	return Plugin_Handled;
}