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
					BreakString(line, line, sizeof(line));
					
					if (line[0] != '\0')
					{
						strcopy(stringarray[x], sizeofstring, line);
						x++;
					}
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

void PerformBlock(int client, const char[] message)
{
	PrintToChat(client, "Your message has been blocked as it contains unpermitted words.");
	LogToFile(gs_LogFilePath, "Blocked \"%N\" message according to the chat filters. Message: \"%s\"", client, message);
}

void PerformKick(int client, const char[] message, const char[] filter)
{
	KickClient(client, "Kicked for using unpermitted words in chat.\n\nUnpermitted words: %s", filter);
	LogToFile(gs_LogFilePath, "Kicked \"%N\" according to the chat filters. Message: \"%s\"", client, message);
}

void PerformBan(int client, const char[] message, const char[] filter)
{
	char steamid[32], ip[32];
	
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	GetClientIP(client, ip, sizeof(ip));
	
	if (gb_SourcebansPP)
	{
		SBPP_BanPlayer(0, client, gi_BanDuration, "Chat Abuse (autodetected by Advanced-Filters)");
		LogToFile(gs_LogFilePath, "Banned \"%N [%s | %s]\" according to the chat filters. Message: \"%s\"", client, steamid, ip, message);
	}
	else
	{
		switch (gi_BanMethod)
		{
			case 0: 
			{
				BanClient(client, gi_BanDuration, BANFLAG_AUTHID | BANFLAG_NOKICK, "Chat Abuse (autodetected by Advanced-Filters)", "", "Advanced-filters");
				LogToFile(gs_LogFilePath, "Banned \"%N [%s]\" according to the chat filters. Message: \"%s\"", client, steamid, message);
			}
			case 1: 
			{
				BanClient(client, gi_BanDuration, BANFLAG_IP | BANFLAG_NOKICK, "Chat Abuse (autodetected by Advanced-Filters)", "", "Advanced-filters");
				LogToFile(gs_LogFilePath, "Banned \"%N [%s]\" according to the chat filters. Message: \"%s\"", client, ip, message);
			}
			case 2:
			{
				BanClient(client, gi_BanDuration, BANFLAG_AUTHID | BANFLAG_NOKICK, "Chat Abuse (autodetected by Advanced-Filters)", "", "Advanced-filters");
				BanClient(client, gi_BanDuration, BANFLAG_IP | BANFLAG_NOKICK, "Chat Abuse (autodetected by Advanced-Filters)", "", "Advanced-filters");
				LogToFile(gs_LogFilePath, "Banned \"%N [%s | %s]\" according to the chat filters. Message: \"%s\"", client, steamid, ip, message);
			}
		}
	}
	
	switch (gi_BanDuration)
	{
		case 0: KickClient(client, "Banned permanently from the server.\n\nAdmin: Server Console\nReason: Chat Abuse (autodetected by Advanced-Filters)\nUnpermitted words: %s", filter);
		default: KickClient(client, "Banned temporarily from the server.\n\nAdmin: Server Console\nDuration: %i minutes\nReason: Chat Abuse (autodetected by Advanced-Filters)\nUnpermitted words: %s", gi_BanDuration, filter);
	}
}

void PerformPunishment(int client, const char[] message, const char[] filter)
{
	switch(gi_PunishmentMethod)
	{
		case 0: PerformBlock(client, message);
		case 1: PerformKick(client, message, filter);
		case 2: PerformBan(client, message, filter);
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
		int matches;
		if ((matches = gr_RegexASCII.MatchAll(name)) > 0)
		{
			char substring[64];
			for (int x = 0; x < matches; x++)
			{
				gr_RegexASCII.GetSubString(0, substring, sizeof(substring), x);
				ReplaceStringEx(name, sizeof(name), substring, "");
			}
		}
		TrimString(name);
	}
	
	if (gb_RemoveNameURL)
	{
		int matches;
		if ((matches = gr_RegexURL.MatchAll(name)) > 0)
		{
			char substring[20];
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
	LogToFile(gs_LogFilePath, "Renamed \"%s\" according to the name filters. New name: \"%s\"", namecopy, name);
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
