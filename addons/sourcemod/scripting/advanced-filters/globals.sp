// Handles for storing precompiled regex
Regex gr_RegexSymbols;
Regex gr_RegexIP;

// Strings for storing filepaths
char gs_ChatFilePath[256];
char gs_NameFilePath[256];
char gs_WhitelistFilePath[256];
char gs_LogFilePath[256];

// StringArrays for storing filters
char gs_ChatFilters[100][50];
char gs_NameFilters[100][50];
char gs_WhitelistFilters[20][20];

// ConVars created by the plugin
ConVar gc_bUseChatFilters;
ConVar gc_bUseChatIpFilters;
ConVar gc_bBlockChatSymbols;
ConVar gc_bHideChatCommands;
ConVar gc_bHideNameChangeMsg;
ConVar gc_bHideConnectMsg;
ConVar gc_bDisableTeamChat;
ConVar gc_iPunishmentMethod;
ConVar gc_iBanMethod;
ConVar gc_iBanDuration;
ConVar gc_bUseWhitelist;
ConVar gc_bUseNameFilters;
ConVar gc_bUseIpNameFilters;
ConVar gc_bRemoveNameSymbols;
ConVar gc_bRenameTooShort;

// Variables used for storing ConVar data
bool gb_UseChatFilters;
bool gb_UseChatIpFilters;
bool gb_BlockChatSymbols;
bool gb_HideChatCommands;
bool gb_HideNameChangeMsg;
bool gb_HideConnectMsg;
bool gb_DisableTeamChat;
int gi_PunishmentMethod;
int gi_BanMethod;
int gi_BanDuration;
bool gb_UseWhitelist;
bool gb_UseNameFilters;
bool gb_UseIpNameFilters;
bool gb_RemoveNameSymbols;
bool gb_RenameTooShort;

// Variable used for storing sourcebans++ status
bool gb_SourcebansPP;