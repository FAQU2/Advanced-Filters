void RegisterCommands()
{
	RegAdminCmd("sm_chatfilters", Command_ChatFilters, ADMFLAG_ROOT, "Prints currently loaded chat filters.");
	RegAdminCmd("sm_namefilters", Command_NameFilters, ADMFLAG_ROOT, "Prints currently loaded name filters.");
	RegAdminCmd("sm_whitelistip", Command_WhitelistIp, ADMFLAG_ROOT, "Prints currently loaded whitelisted IP addresses.");
	RegAdminCmd("sm_whitelisturl", Command_WhitelistURL, ADMFLAG_ROOT, "Prints currently loaded whitelisted URLs.");
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

public Action Command_WhitelistIp(int client, int args)
{
	switch (gb_UseWhitelistIp)
	{
		case 0: ReplyToCommand(client, "[Advanced Filters] IP Whitelist is disabled.");
		case 1:
		{
			ReplyToCommand(client, "[Advanced Filters] Whitelisted IP addresses:");
			PrintStringArray(client, gs_WhitelistIp, sizeof(gs_WhitelistIp));
		}
	}
	return Plugin_Handled;
}

public Action Command_WhitelistURL(int client, int args)
{
	switch (gb_UseWhitelistURL)
	{
		case 0: ReplyToCommand(client, "[Advanced Filters] URL Whitelist is disabled.");
		case 1:
		{
			ReplyToCommand(client, "[Advanced Filters] Whitelisted URLs:");
			PrintStringArray(client, gs_WhitelistURL, sizeof(gs_WhitelistURL));
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