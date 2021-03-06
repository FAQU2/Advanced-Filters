void WriteLinesToStringArray(const char[] filepath, char[][] stringarray, int sizeofstring)
{
	File file = OpenFile(filepath, "r");
	
	switch (file)
	{
		case 0: LogError("Could not read from file %s", filepath);
		default:
		{
			int x; char line[256];
			
			while (!file.EndOfFile() && file.ReadLine(line, sizeof(line)))
			{
				SplitString(line, "//", line, sizeof(line));
				TrimString(line);
				
				if (line[0] != '\0')
				{
					BreakString(line, stringarray[x], sizeofstring);
					x++;
				}
			}
		}
	}
	delete file;
}

void EmptyStringArray(char[][] stringarray, int sizeofarray)
{
	for (int x = 0; x < sizeofarray; x++)
	{
		stringarray[x][0] = '\0';
	}
}

void PrintStringArray(int client, char[][] stringarray, int sizeofarray)
{
	int x, y;
	
	while (x < sizeofarray)
	{
		if (stringarray[x][0] != '\0')
		{
			ReplyToCommand(client, "%02i/%02i  -  \"%s\"", x + 1, sizeofarray, stringarray[x]);
			y++;
		}
		x++;
	}
	
	switch (y)
	{
		case 0: ReplyToCommand(client, "---EMPTY ARRAY---");
	}
}

void ReloadFilters()
{
	EmptyStringArray(gs_ChatFilters, sizeof(gs_ChatFilters));
	EmptyStringArray(gs_NameFilters, sizeof(gs_NameFilters));
	EmptyStringArray(gs_WhitelistIp, sizeof(gs_WhitelistIp));
	EmptyStringArray(gs_WhitelistURL, sizeof(gs_WhitelistURL));
	
	if (gb_UseChatFilters)
	{
		WriteLinesToStringArray(gs_ChatFilePath, gs_ChatFilters, sizeof(gs_ChatFilters[]));
	}
	if (gb_UseNameFilters)
	{
		WriteLinesToStringArray(gs_NameFilePath, gs_NameFilters, sizeof(gs_NameFilters[]));
	}
	if (gb_UseWhitelistIp)
	{
		WriteLinesToStringArray(gs_WhitelistIpFilePath, gs_WhitelistIp, sizeof(gs_WhitelistIp[]));
	}
	if (gb_UseWhitelistURL)
	{
		WriteLinesToStringArray(gs_WhitelistUrlFilePath, gs_WhitelistURL, sizeof(gs_WhitelistURL[]));
	}
}

void PerformBlock(int client, const char[] message, const char[] content)
{
	PrintToChat(client, "Your message has been blocked as it contains %s.", content);
	PerformLogging(gs_LogFilePath, "Blocked \"%N\" according to the chat filters. Message: \"%s\"", client, message);
}

void PerformKick(int client, const char[] message, const char[] content, const char[] filter)
{
	KickClient(client, "You have been kicked from the server.\n\nReason: Typing %s in chat. (%s)", content, filter);
	PerformLogging(gs_LogFilePath, "Kicked \"%N\" according to the chat filters. Message: \"%s\"", client, message);
}

void PerformBan(int client, const char[] message, const char[] content, const char[] filter)
{
	char steamid[32];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	char ip[32];
	GetClientIP(client, ip, sizeof(ip));
	
	PerformLogging(gs_LogFilePath, "Banned \"%N [%s | %s]\" according to the chat filters. Message: \"%s\"", client, steamid, ip, message);
	
	switch (gb_SourcebansPP)
	{
		case 1: SBPP_BanPlayer(0, client, gi_BanDuration, "Breaking chat rules");
		case 0:
		{
			char kickmsg[192];
			FormatEx(kickmsg, sizeof(kickmsg), "You have been %s banned from the server.\n\nReason: Typing %s in chat. (%s)", gi_BanDuration ? "temporarily":"permanently", content, filter);
			
			switch (gi_BanMethod)
			{
				case 0: BanClient(client, gi_BanDuration, BANFLAG_AUTHID, "Breaking chat rules", kickmsg, "Advanced-Filters");
				case 1: BanClient(client, gi_BanDuration, BANFLAG_IP, "Breaking chat rules", kickmsg, "Advanced-Filters");
				case 2:
				{
					BanClient(client, gi_BanDuration, BANFLAG_AUTHID, "Breaking chat rules", kickmsg, "Advanced-Filters");
					BanClient(client, gi_BanDuration, BANFLAG_IP, "Breaking chat rules", kickmsg, "Advanced-Filters");
					
				}
			}
		}
	}
}

void PerformLogging(const char[] filepath, const char[] format, any ...)
{
	if (gb_EnableLogging)
	{
		char buffer[512];
		VFormat(buffer, sizeof(buffer), format, 3);
		LogToFile(filepath, buffer);
	}
}

void PerformPunishment(int client, const char[] message, const char[] content, const char[] filter)
{
	switch(gi_PunishmentMethod)
	{
		case 0: PerformBlock(client, message, content);
		case 1: PerformKick(client, message, content, filter);
		case 2: PerformBan(client, message, content, filter);
	}
}

void PerformNameCheck(int client, Event event)
{
	if (!client || IsFakeClient(client))
	{
		return;
	}
	
	if (gb_AdminImmunityName)
	{
		if (CheckCommandAccess(client, "", gi_AdminImmunityFlags, true))
		{
			return;
		}
	}
	
	char name[128], namecopy[128];
	
	switch (event)
	{
		case 0: GetClientName(client, name, sizeof(name));
		default: event.GetString("newname", name, sizeof(name));
	}
	
	strcopy(namecopy, sizeof(namecopy), name);
	
	if (gb_RemoveNameSymbols)
	{
		int loops = sizeof(name);
		for (int x = 0; x < loops; x++)
		{
			if (name[x] == '\0')
			{
				break;
			}
			else if (name[x] > 0x7F)
			{
				strcopy(name[x], loops, name[x + 1]);
				x--;
			}
		}
		TrimString(name);
	}
	
	if (gb_RemoveNameURL)
	{
		int matches;
		if ((matches = gr_RegexURL.MatchAll(name)) > 0)
		{
			char substring[100];
			for (int i = 0; i < matches; i++)
			{
				gr_RegexURL.GetSubString(0, substring, sizeof(substring), i);
				
				switch (gb_UseWhitelistURL)
				{
					case 0: ReplaceStringEx(name, sizeof(name), substring, "");
					case 1:
					{
						bool shouldremove = true;
				
						int loops = sizeof(gs_WhitelistURL);
						for (int x = 0; x < loops; x++)
						{
							if (gs_WhitelistURL[x][0] == '\0')
							{
								break;
							}
							else if (StrContains(substring, gs_WhitelistURL[x]) != -1)
							{
								shouldremove = false;
								break;
							}
						}		
						if (shouldremove)
						{
							ReplaceStringEx(name, sizeof(name), substring, "");
						}
					}
				}
			}
		}
		TrimString(name);
	}
	
	if (gb_UseNameFilters)
	{
		int loops = sizeof(gs_NameFilters);
		for (int x = 0; x < loops; x++)
		{
			switch (gs_NameFilters[x][0])
			{
				case '\0': break;
				default: ReplaceString(name, sizeof(name), gs_NameFilters[x], "", false);
			}
		}
		TrimString(name);
	}
	
	if (gb_UseIpNameFilters)
	{
		int matches;
		if ((matches = gr_RegexIP.MatchAll(name)) > 0)
		{
			char substring[20];
			for (int i = 0; i < matches; i++)
			{
				gr_RegexIP.GetSubString(0, substring, sizeof(substring), i);
				
				switch (gb_UseWhitelistIp)
				{
					case 0: ReplaceStringEx(name, sizeof(name), substring, "");
					case 1:
					{
						bool shouldremove = true;
				
						int loops = sizeof(gs_WhitelistIp);
						for (int x = 0; x < loops; x++)
						{
							if (gs_WhitelistIp[x][0] == '\0')
							{
								break;
							}
							else if (strcmp(substring, gs_WhitelistIp[x]) == 0)
							{
								shouldremove = false;
								break;
							}
						}		
						if (shouldremove)
						{
							ReplaceStringEx(name, sizeof(name), substring, "");
						}
					}
				}
			}
		}
		TrimString(name);
	}
	
	if (gb_RenameTooShort)
	{
		if (strlen(name) < 3)
		{
			FormatEx(name, sizeof(name), "Player #%i", GetClientUserId(client));
			PerformRename(client, name, namecopy);
			return;
		}
	}
	
	if (!(strcmp(name, namecopy) == 0))
	{
		PerformRename(client, name, namecopy);
	}
}

void PerformRename(int client, const char[] name, const char[] namecopy)
{
	SetClientInfo(client, "name", name);
	PerformLogging(gs_LogFilePath, "Renamed \"%s\" according to the name filters. New name: \"%s\"", namecopy, name);
}

void PerformNameCheckAll()
{
	for (int x = 1; x <= MaxClients; x++)
	{
		if (IsClientInGame(x))
		{
			PerformNameCheck(x, view_as<Event>(INVALID_HANDLE));
		}
	}
}