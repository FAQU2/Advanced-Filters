#include <sourcemod>
#include <sdktools>
#include <regex>

#undef REQUIRE_PLUGIN
#include <sourcebanspp>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "Advanced Filters",
	author = "FAQU",
	description = "Chat & Name filtering",
	version = "1.0",
	url = "https://github.com/FAQU2"
};

#include "advanced-filters/globals.sp"

public void OnPluginStart()
{
	gr_RegexSymbols = new Regex("[^[:ascii:]]+", PCRE_UTF8);
	gr_RegexIP = new Regex("(?<!\\d)((2[0-5][0-5]|1\\d\\d|[1-9]\\d|\\d)\\.){3}(2[0-5][0-5]|1\\d\\d|[1-9]\\d|\\d)(?!\\d)");
	
	BuildPath(Path_SM, gs_ChatFilePath, sizeof(gs_ChatFilePath), "configs/advanced-filters/chatfilters.cfg");
	BuildPath(Path_SM, gs_NameFilePath, sizeof(gs_NameFilePath), "configs/advanced-filters/namefilters.cfg");
	BuildPath(Path_SM, gs_WhitelistFilePath, sizeof(gs_WhitelistFilePath), "configs/advanced-filters/whitelist.cfg");
	BuildPath(Path_SM, gs_LogFilePath, sizeof(gs_LogFilePath), "logs/advanced-filters.log");
	
	RegisterCommands();
	RegisterConVars();
	HookAllConVars();
	
	HookEvent("player_connect", Event_PlayerConnect, EventHookMode_Pre);
	HookEvent("player_changename", Event_PlayerChangename);
	HookUserMessage(GetUserMessageId("SayText2"), Hook_SayText2, true);
	
	gb_SourcebansPP = LibraryExists("sourcebans++");
}

public void OnLibraryAdded(const char[] library)
{
	if (strcmp(library, "sourcebans++") == 0)
	{
		gb_SourcebansPP = true;
	}
}

public void OnLibraryRemoved(const char[] library)
{
	if (strcmp(library, "sourcebans++") == 0)
	{
		gb_SourcebansPP = false;
	}
}

public void OnConfigsExecuted()
{
	SaveConVarData();
	ReloadFilters();
}

public Action OnClientSayCommand(int client, const char[] command, const char[] argstring)
{
	if (!client)
	{
		return Plugin_Continue;
	}
	
	if (!IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	char message[256];
	strcopy(message, sizeof(message), argstring);
	TrimString(message);
	
	if (gb_HideChatCommands)
	{
		if (message[0] == '!' || message[0] == '/')
		{
			if (!IsChatTrigger())
			{
				PrintToChat(client, "This command does not exist.");
			}
			return Plugin_Handled;
		}
	}
	
	if (gb_BlockChatSymbols)
	{
		if (gr_RegexSymbols.Match(message) > 0)
		{
			PrintToChat(client, "Your message has been blocked as it contains non-ASCII characters.");
			return Plugin_Handled;
		}
	}
	
	if (gb_UseChatFilters)
	{
		int loops = sizeof(gs_ChatFilters);
		for (int x = 0; x < loops; x++)
		{
			if (gs_ChatFilters[x][0] == '\0')
			{
				break;
			}
			else if (StrContains(message, gs_ChatFilters[x], false) != -1)
			{
				PerformPunishment(client, message, gs_ChatFilters[x]);
				return Plugin_Handled;
			}
		}
	}
	
	if (gb_UseChatIpFilters)
	{
		int matches;
		if ((matches = gr_RegexIP.MatchAll(message)) > 0)
		{
			char substring[20];
			
			if (gb_UseWhitelist)
			{
				for (int i = 0; i < matches; i++)
				{
					bool shouldpunish = true;
					
					gr_RegexIP.GetSubString(0, substring, sizeof(substring), i);
					
					int loops = sizeof(gs_WhitelistFilters);
					for (int x = 0; x < loops; x++)
					{
						if (gs_WhitelistFilters[x][0] == '\0')
						{
							break;
						}
						else if (strcmp(substring, gs_WhitelistFilters[x]) == 0)
						{
							shouldpunish = false;
							break;
						}
					}
					if (shouldpunish)
					{
						PerformPunishment(client, message, substring);
						return Plugin_Handled;
					}
				}
			}
			else
			{
				gr_RegexIP.GetSubString(0, substring, sizeof(substring), 0);
				PerformPunishment(client, message, substring);
				return Plugin_Handled;
			}
		}
	}
	
	if (gb_DisableTeamChat)
	{
		if (strcmp(command, "say_team") == 0)
		{
			FakeClientCommandEx(client, "say %s", message);
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}

public Action Hook_SayText2(UserMsg msg_id, Handle msg, const int[] players, int playersNum, bool reliable, bool init)
{
	if (!reliable)
	{
		return Plugin_Continue;
	}
	
	if (!gb_HideNameChangeMsg)
	{
		return Plugin_Continue;
	}
	
	char msgname[256];
	
	switch (GetUserMessageType())
	{
		case UM_Protobuf: PbReadString(msg, "msg_name", msgname, sizeof(msgname));
		case UM_BitBuf:
		{
			BfReadByte(msg);
			BfReadByte(msg);
			BfReadString(msg, msgname, sizeof(msgname));
		}
	}
	
	if (StrContains(msgname, "Name_Change") != -1)
	{
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action Event_PlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
	if (gb_HideConnectMsg)
	{
		SetEventBroadcast(event, true);
	}
}

public void OnClientPutInServer(int client)
{
	PerformNameCheck(client, view_as<Event>(INVALID_HANDLE));
}

public void Event_PlayerChangename(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	PerformNameCheck(client, event);
}

#include "advanced-filters/functions.sp"
#include "advanced-filters/commands.sp"
#include "advanced-filters/convars.sp"