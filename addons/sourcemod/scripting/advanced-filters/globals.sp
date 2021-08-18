// Handles for storing precompiled regex
Regex gr_RegexASCII;
Regex gr_RegexIP;
Regex gr_RegexURL;

// Strings for storing filepaths
char gs_ChatFilePath[256];
char gs_NameFilePath[256];
char gs_WhitelistIpFilePath[256];
char gs_WhitelistUrlFilePath[256];
char gs_LogFilePath[256];

// StringArrays for storing filters
char gs_ChatFilters[100][50];
char gs_NameFilters[100][50];
char gs_WhitelistIp[20][20];
char gs_WhitelistURL[20][100];

// ConVars created by the plugin
ConVar gc_bUseChatFilters;
ConVar gc_bUseChatIpFilters;
ConVar gc_bBlockChatSymbols;
ConVar gc_bBlockChatURL;
ConVar gc_bHideChatCommands;
ConVar gc_bHideNameChangeMsg;
ConVar gc_bHideConnectMsg;
ConVar gc_bDisableTeamChat;
ConVar gc_iPunishmentMethod;
ConVar gc_iBanMethod;
ConVar gc_iBanDuration;
ConVar gc_bUseWhitelistIp;
ConVar gc_bUseWhitelistURL;
ConVar gc_bUseNameFilters;
ConVar gc_bUseIpNameFilters;
ConVar gc_bRemoveNameSymbols;
ConVar gc_bRemoveNameURL;
ConVar gc_bRenameTooShort;

// Variables used for storing ConVar data
bool gb_UseChatFilters;
bool gb_UseChatIpFilters;
bool gb_BlockChatSymbols;
bool gb_BlockChatURL;
bool gb_HideChatCommands;
bool gb_HideNameChangeMsg;
bool gb_HideConnectMsg;
bool gb_DisableTeamChat;
int gi_PunishmentMethod;
int gi_BanMethod;
int gi_BanDuration;
bool gb_UseWhitelistIp;
bool gb_UseWhitelistURL;
bool gb_UseNameFilters;
bool gb_UseIpNameFilters;
bool gb_RemoveNameSymbols;
bool gb_RemoveNameURL;
bool gb_RenameTooShort;

// Variable used for storing sourcebans++ status
bool gb_SourcebansPP;