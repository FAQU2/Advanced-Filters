void RegisterConVars()
{
	gc_bUseChatFilters = CreateConVar("advanced_chat_filters", "1", "Use chat filters fetched from chatfilters.cfg [1 = Enabled / 0 = Disabled]");
	gc_bUseChatIpFilters = CreateConVar("advanced_chat_ipfilters", "1", "Use chat ip filters based on pattern recognition [1 = Enabled / 0 = Disabled]");
	gc_bBlockChatSymbols = CreateConVar("advanced_chat_blocksymbols", "1", "Block messages that contain non-ASCII characters [1 = Enabled / 0 = Disabled]");
	gc_bHideChatCommands = CreateConVar("advanced_chat_hidecommands", "1", "Hide sourcemod commands from chat [1 = Enabled / 0 = Disabled]");
	gc_bHideNameChangeMsg = CreateConVar("advanced_chat_hidenamechangemsg", "1", "Hide namechange notifications from chat [1 = Enabled / 0 = Disabled]");
	gc_bHideConnectMsg = CreateConVar("advanced_chat_hideconnectmsg", "1", "Hide player connected notifications from chat [1 = Enabled / 0 = Disabled]");
	gc_bDisableTeamChat = CreateConVar("advanced_teamchat_disabled", "0", "Disable teamchat and redirect all messages to general chat [1 = Enabled / 0 = Disabled]");
	gc_iPunishmentMethod = CreateConVar("advanced_chat_punishment", "0", "Punishment method for chat abuse [0 = Message blocked / 1 = Kick player / 2 = Ban player]");
	gc_iBanMethod = CreateConVar("advanced_chat_banmethod", "0", "Method of applying the player ban [0 = SteamID only / 1 = IP address only / 2 = SteamID + IP address]");
	gc_iBanDuration = CreateConVar("advanced_chat_banduration", "1440", "Duration to apply the player ban for [number = minutes / 0 = permanent]");
	gc_bUseWhitelist = CreateConVar("advanced_whitelist", "1", "Use whitelist filters fetched from whitelist.cfg for IP addresses [1 = Enabled / 0 = Disabled]");
	gc_bUseNameFilters = CreateConVar("advanced_name_filters", "1", "Use name filters fetched from namefilters.cfg [1 = Enabled / 0 = Disabled]");
	gc_bUseIpNameFilters = CreateConVar("advanced_name_ipfilters", "1", "Use chat ip filters based on pattern recognition [1 = Enabled / 0 = Disabled");
	gc_bRemoveNameSymbols = CreateConVar("advanced_name_removesymbols", "1", "Remove non-ASCII characters from the players' nicknames [1 = Enabled / 0 = Disabled]");
	gc_bRenameTooShort = CreateConVar("advanced_name_renametooshort", "1", "Rename players with nicknames shorter than 3 characters to 'Player #userid' [1 = Enabled / 0 = Disabled]");
	AutoExecConfig(true, "advanced-filters");
}

void HookAllConVars()
{
	gc_bUseChatFilters.AddChangeHook(Hook_UseChatFilters);
	gc_bUseChatIpFilters.AddChangeHook(Hook_UseChatIpFilters);
	gc_bBlockChatSymbols.AddChangeHook(Hook_BlockChatSymbols);
	gc_bHideChatCommands.AddChangeHook(Hook_HideChatCommands);
	gc_bHideNameChangeMsg.AddChangeHook(Hook_HideNameChangeMsg);
	gc_bHideConnectMsg.AddChangeHook(Hook_HideConnectMsg);
	gc_bDisableTeamChat.AddChangeHook(Hook_DisableTeamChat);
	gc_iPunishmentMethod.AddChangeHook(Hook_PunishmentMethod);
	gc_iBanMethod.AddChangeHook(Hook_BanMethod);
	gc_iBanDuration.AddChangeHook(Hook_BanDuration);
	gc_bUseWhitelist.AddChangeHook(Hook_UseWhitelist);
	gc_bUseNameFilters.AddChangeHook(Hook_UseNameFilters);
	gc_bUseIpNameFilters.AddChangeHook(Hook_UseIpNameFilters);
	gc_bRemoveNameSymbols.AddChangeHook(Hook_RemoveNameSymbols);
	gc_bRenameTooShort.AddChangeHook(Hook_RenameTooShort);
}

void SaveConVarData()
{
	gb_UseChatFilters = gc_bUseChatFilters.BoolValue;
	gb_UseChatIpFilters = gc_bUseChatIpFilters.BoolValue;
	gb_BlockChatSymbols = gc_bBlockChatSymbols.BoolValue;
	gb_HideChatCommands = gc_bHideChatCommands.BoolValue;
	gb_HideNameChangeMsg = gc_bHideNameChangeMsg.BoolValue;
	gb_HideConnectMsg = gc_bHideConnectMsg.BoolValue;
	gb_DisableTeamChat = gc_bDisableTeamChat.BoolValue;
	gi_PunishmentMethod = gc_iPunishmentMethod.IntValue;
	gi_BanMethod = gc_iBanMethod.IntValue;
	gi_BanDuration = gc_iBanDuration.IntValue;
	gb_UseWhitelist = gc_bUseWhitelist.BoolValue;
	gb_UseNameFilters = gc_bUseNameFilters.BoolValue;
	gb_UseIpNameFilters = gc_bUseIpNameFilters.BoolValue;
	gb_RemoveNameSymbols = gc_bRemoveNameSymbols.BoolValue;
	gb_RenameTooShort = gc_bRenameTooShort.BoolValue;
}

public void Hook_UseChatFilters(ConVar convar, const char[] oldValue, const char[] newValue)
{
	switch((gb_UseChatFilters = convar.BoolValue))
	{
		case 0: EmptyStringArray(gs_ChatFilters, sizeof(gs_ChatFilters));
		case 1: WriteLinesToStringArray(gs_ChatFilePath, gs_ChatFilters, sizeof(gs_ChatFilters[]));
	}
}

public void Hook_UseChatIpFilters(ConVar convar, const char[] oldValue, const char[] newValue)
{
	gb_UseChatIpFilters = convar.BoolValue;
}

public void Hook_BlockChatSymbols(ConVar convar, const char[] oldValue, const char[] newValue)
{
	gb_BlockChatSymbols = convar.BoolValue;
}

public void Hook_HideChatCommands(ConVar convar, const char[] oldValue, const char[] newValue)
{
	gb_HideChatCommands = convar.BoolValue;
}

public void Hook_HideNameChangeMsg(ConVar convar, const char[] oldValue, const char[] newValue)
{
	gb_HideNameChangeMsg = convar.BoolValue;
}

public void Hook_HideConnectMsg(ConVar convar, const char[] oldValue, const char[] newValue)
{
	gb_HideConnectMsg = convar.BoolValue;
}

public void Hook_DisableTeamChat(ConVar convar, const char[] oldValue, const char[] newValue)
{
	gb_DisableTeamChat = convar.BoolValue;
}

public void  Hook_PunishmentMethod(ConVar convar, const char[] oldValue, const char[] newValue)
{
	gi_PunishmentMethod = convar.IntValue;
}

public void Hook_BanMethod(ConVar convar, const char[] oldValue, const char[] newValue)
{
	gi_BanMethod = convar.IntValue;
}

public void Hook_BanDuration(ConVar convar, const char[] oldValue, const char[] newValue)
{
	gi_BanDuration = convar.IntValue;
}

public void Hook_UseWhitelist(ConVar convar, const char[] oldValue, const char[] newValue)
{
	switch((gb_UseWhitelist = convar.BoolValue))
	{
		case 0:
		{
			EmptyStringArray(gs_WhitelistFilters, sizeof(gs_WhitelistFilters));
			PerformNameCheckAll();
		}
		case 1: WriteLinesToStringArray(gs_WhitelistFilePath, gs_WhitelistFilters, sizeof(gs_WhitelistFilters[]));
	}
}

public void Hook_UseNameFilters(ConVar convar, const char[] oldValue, const char[] newValue)
{
	switch((gb_UseNameFilters = convar.BoolValue))
	{
		case 0: EmptyStringArray(gs_NameFilters, sizeof(gs_NameFilters));
		case 1:
		{
			WriteLinesToStringArray(gs_NameFilePath, gs_NameFilters, sizeof(gs_NameFilters[]));
			PerformNameCheckAll();
		}
	}
}

public void Hook_UseIpNameFilters(ConVar convar, const char[] oldValue, const char[] newValue)
{
	switch((gb_UseIpNameFilters = convar.BoolValue))
	{
		case 1: PerformNameCheckAll();
	}
}

public void Hook_RemoveNameSymbols(ConVar convar, const char[] oldValue, const char[] newValue)
{
	switch((gb_RemoveNameSymbols = convar.BoolValue))
	{
		case 1: PerformNameCheckAll();
	}
}

public void Hook_RenameTooShort(ConVar convar, const char[] oldValue, const char[] newValue)
{
	switch((gb_RenameTooShort = convar.BoolValue))
	{
		case 1: PerformNameCheckAll();
	}
}