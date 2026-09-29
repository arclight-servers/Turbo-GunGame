#pragma semicolon 1
#pragma newdecls required

bool WasMedicPreRegen[MAXPLAYERS];

void DHook_Setup()
{
	GameData gamedata = LoadGameConfigFile("zombie_riot");

	if (!gamedata)
	{
		SetFailState("Failed to load gamedata (zombie_riot).");
	}

	DHook_CreateDetour(gamedata, "CTFPlayer::RegenThink", DHook_RegenThinkPre, DHook_RegenThinkPost);
	DHook_CreateDetour(gamedata, "CTFPlayer::ManageRegularWeapons()", DHook_ManageRegularWeaponsPre);
	DHook_CreateDetour(gamedata, "CTFPlayer::SpeakConceptIfAllowed()", SpeakConceptIfAllowed_Pre, SpeakConceptIfAllowed_Post);

	delete gamedata;
}

public MRESReturn DHook_ManageRegularWeaponsPre(int client, DHookParam param)
{
	// Gives our desired class's wearables
	if(Cvar_TGG_AllowFreeClassPicking.IntValue)
		CurrentClass[client] = view_as<TFClassType>(GetEntProp(client, Prop_Send, "m_iDesiredPlayerClass"));

	if(!CurrentClass[client])
	{
		CurrentClass[client] = TFClass_Scout;
	}
	TF2_SetPlayerClass_ZR(client, CurrentClass[client]);
	return MRES_Ignored;
}

public MRESReturn DHook_RegenThinkPre(int client, DHookParam param)
{
	if(TF2_GetPlayerClass(client) == TFClass_Medic)
	{
		WasMedicPreRegen[client] = true;
		TF2_SetPlayerClass_ZR(client, TFClass_Scout, false, false);
	}
	else
	{
		WasMedicPreRegen[client] = false;
	}

	return MRES_Ignored;
}

public MRESReturn DHook_RegenThinkPost(int client, DHookParam param)
{
	if(WasMedicPreRegen[client])
		TF2_SetPlayerClass_ZR(client, TFClass_Medic, false, false);

	WasMedicPreRegen[client] = false;
	return MRES_Ignored;
}

public MRESReturn SpeakConceptIfAllowed_Pre(int client, DHookReturn returnHook, DHookParam param)
{
	for(int client_2=1; client_2<=MaxClients; client_2++)
	{
		if(IsClientInGame(client_2))
		{
			if(!CurrentClass[client_2])
			{
				CurrentClass[client_2] = TFClass_Scout;
			}
			TF2_SetPlayerClass_ZR(client_2, CurrentClass[client_2], false, false);
		}
	}
	return MRES_Ignored;
}

public MRESReturn SpeakConceptIfAllowed_Post(int client, DHookReturn returnHook, DHookParam param)
{
	for(int client_2=1; client_2<=MaxClients; client_2++)
	{
		if(IsClientInGame(client_2))
		{
			if(GetEntProp(client_2, Prop_Send, "m_iHealth") > 0)
			{
				if(!WeaponClass[client_2])
				{
					WeaponClass[client_2] = TFClass_Scout;
				}
				TF2_SetPlayerClass_ZR(client_2, WeaponClass[client_2], false, false);
			}
		}
	}
	return MRES_Ignored;
}
