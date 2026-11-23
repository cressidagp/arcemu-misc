_run = true
if(GetEngineName == nil) then print("You NEED LuaBridge to run this script.") _run = false end
if(LCF == nil) then print("You NEED LCF to run this script.") _run = false end
if(_run == false) then print("Gossip system script execution terminated.") return; end
_run = nil
if (MapMgr == nil) then return; end

--[[
FULL CREDIT ABOUT THIS GOES TO Rochet2 AT WOW-V.COM

YOU ARE NOT ALLOWED TO RELEASE THIS SCRIPT ANYWHERE WITHOUT MY PERMISSION.
YOU ARE NOT ALLOWED TO SHARE THIS SCRIPT BY POSTING THE SCRIPT OR LINK TO IT ON ANY WEBSITE.
ALL SHARING IS DONE BY GIVING CREDIT TO THE MAKER (Rochet2) AND BY ONLY POSTING A LINK TO HIS THREAD AT WOW-V.COM
LINK TO THE ORIGINAL AND ONLY RELEASE THREAD: http://wow-v.com/forums/index.php?topic=24301.0

THIS SCRIPT IS FOR YOUR OWN USE ONLY!

More Rochet2's work at projectcode.zzl.org
]]--

DBGossipsys = {}

function DBGossipsys.Command(event, pPlayer, pMessage, pType, pLanguage, pMisc)

	if(pPlayer:GetSession():IsGM() and pMessage:lower() == ".reload gossip") then
		DBGossipsys.LoadData()
		DBGossipsys.reLoadUnitMenu(true)
		SendWorldMessage("Gossip_* tables reloaded", 2)
		return false
	end

end

function DBGossipsys.LoadData()

	DBGossipsys.menu = {}
	DBGossipsys.scripts = {}
	DBGossipsys.option = {}
	DBGossipsys.conditions = {}

	DBGossipsys.gossip_menu = WorldDB:Query("SELECT `menu_id`, `npc_text_id` FROM `custom_gossip`.`gossip_menu`")
	if(DBGossipsys.gossip_menu ~= nil) then
	DBGossipsys.menu["rowcount"] = DBGossipsys.gossip_menu:GetRowCount()
	else
		DBGossipsys.menu["rowcount"] = 0
		print("Table `custom_gossip`.`gossip_menu` was empty. Using npc_text = 1.\nAfter filling, use .reload gossip")
	end

	DBGossipsys.gossip_scripts = WorldDB:Query("SELECT `command`, `float`, `map`, `x`, `y`, `z`, `o`, `value`, `bool`, `string`, `value2`, `script_id` FROM `custom_gossip`.`gossip_scripts` ORDER BY `command` DESC, `script_id` ASC")
	if(DBGossipsys.gossip_scripts ~= nil) then
		DBGossipsys.scripts["rowcount"] = DBGossipsys.gossip_scripts:GetRowCount()
	else
		DBGossipsys.scripts["rowcount"] = 0
		print("Table `custom_gossip`.`gossip_scripts` was empty. After fill, reload gossip")
	end

	DBGossipsys.gossip_option = WorldDB:Query("SELECT `menu_id`, `order`, `script_id`, `next_menu_id`, `icon`, `name`, `cost`, `popup`, `req_level`, `team` FROM `custom_gossip`.`gossip_menu_option` WHERE `order` BETWEEN 1 AND 30 ORDER BY `menu_id` ASC, `order` ASC")
	if(DBGossipsys.gossip_option ~= nil) then
		DBGossipsys.option["rowcount"] = DBGossipsys.gossip_option:GetRowCount()
	else
		DBGossipsys.option["rowcount"] = 0
		print("Table `custom_gossip`.`gossip_menu_option` was empty.\nAfter filling, use .reload gossip")
	end
	
	DBGossipsys.gossip_conditions = WorldDB:Query("SELECT `menu_id`, `order`, `has_id`, `value`, `bool` FROM `custom_gossip`.`gossip_conditions` ORDER BY `menu_id` ASC, `order` ASC")
	if(DBGossipsys.gossip_conditions ~= nil) then
		DBGossipsys.conditions["rowcount"] = DBGossipsys.gossip_conditions:GetRowCount()
	else
		DBGossipsys.conditions["rowcount"] = 0
		print("Table `custom_gossip`.`gossip_conditions` was empty.\nAfter filling, use .reload gossip")
	end

	for i = 1, DBGossipsys.menu["rowcount"] do
		DBGossipsys.menu[i] = {DBGossipsys.gossip_menu:GetColumn(0):GetUInt32(), DBGossipsys.gossip_menu:GetColumn(1):GetUInt32()}
		DBGossipsys.gossip_menu:NextRow()
	end
	for i = 1, DBGossipsys.scripts["rowcount"] do
		if(DBGossipsys.gossip_scripts:GetColumn(8):GetUInt32() == 0) then
			truefalse = false
		else
			truefalse = true
		end
		DBGossipsys.scripts[i] = {DBGossipsys.gossip_scripts:GetColumn(0):GetUInt32(), DBGossipsys.gossip_scripts:GetColumn(1):GetFloat(), DBGossipsys.gossip_scripts:GetColumn(2):GetUInt32(), DBGossipsys.gossip_scripts:GetColumn(3):GetFloat(), DBGossipsys.gossip_scripts:GetColumn(4):GetFloat(), DBGossipsys.gossip_scripts:GetColumn(5):GetFloat(), DBGossipsys.gossip_scripts:GetColumn(6):GetFloat(), DBGossipsys.gossip_scripts:GetColumn(7):GetUInt32(), truefalse, DBGossipsys.gossip_scripts:GetColumn(9):GetString(), DBGossipsys.gossip_scripts:GetColumn(10):GetUInt32(), DBGossipsys.gossip_scripts:GetColumn(11):GetUInt32()}
		DBGossipsys.gossip_scripts:NextRow()
	end
	for i = 1, DBGossipsys.option["rowcount"] do
		DBGossipsys.option[i] = {DBGossipsys.gossip_option:GetColumn(0):GetUInt32(), DBGossipsys.gossip_option:GetColumn(1):GetUInt32(), DBGossipsys.gossip_option:GetColumn(2):GetUInt32(), DBGossipsys.gossip_option:GetColumn(3):GetUInt32(), DBGossipsys.gossip_option:GetColumn(4):GetUInt32(), DBGossipsys.gossip_option:GetColumn(5):GetString(), DBGossipsys.gossip_option:GetColumn(6):GetUInt32(), DBGossipsys.gossip_option:GetColumn(7):GetString(), DBGossipsys.gossip_option:GetColumn(8):GetUInt32(), DBGossipsys.gossip_option:GetColumn(9):GetUInt32()}
		DBGossipsys.gossip_option:NextRow()
	end
	for i = 1, DBGossipsys.conditions["rowcount"] do
		if(DBGossipsys.gossip_conditions:GetColumn(4):GetUInt32() == 0) then
			_bool = false
		else
			_bool = true
		end
		DBGossipsys.conditions[i] = {DBGossipsys.gossip_conditions:GetColumn(0):GetUInt32(), DBGossipsys.gossip_conditions:GetColumn(1):GetUInt32(), DBGossipsys.gossip_conditions:GetColumn(2):GetUInt32(), DBGossipsys.gossip_conditions:GetColumn(3):GetUInt32()}
		DBGossipsys.gossip_conditions:NextRow()
	end
	
	-- empty load table, no useless data storing
	DBGossipsys.gossip_menu = nil
	DBGossipsys.gossip_scripts = nil
	DBGossipsys.gossip_option = nil
	DBGossipsys.gossip_conditions = nil
	
end

RegisterServerHook(16, DBGossipsys.Command)

function DBGossipsys.reLoadUnitMenu(reload)

	if(reload == true)then
		DBGossipsys.unit_reload = {}
		DBGossipsys.gossip_units_reload = WorldDB:Query("SELECT `entry`, `type`, `menu_id`, `check_combat` FROM `custom_gossip`.`units` WHERE `entry` BETWEEN 1 AND 200000 ORDER BY `entry` ASC")
		if(DBGossipsys.gossip_units_reload ~= nil) then
			DBGossipsys.unit_reload["rowcount"] = DBGossipsys.gossip_units_reload:GetRowCount()
		else
			DBGossipsys.unit_reload["rowcount"] = 0
			print("Table `custom_gossip`.`units` was empty.\nAfter filling, reload luaengine or restart server.")
		end
		for i = 1, DBGossipsys.unit_reload["rowcount"] do
			if(DBGossipsys.gossip_units_reload:GetColumn(0):GetUInt32() == DBGossipsys.unit[i][1] and DBGossipsys.gossip_units_reload:GetColumn(1):GetUInt32() == DBGossipsys.unit[i][2])then
				DBGossipsys.unit[i][3] = DBGossipsys.gossip_units_reload:GetColumn(2):GetUInt32()
				DBGossipsys.unit[i][4] = DBGossipsys.gossip_units_reload:GetColumn(3):GetUInt32()
			end
			DBGossipsys.gossip_units_reload:NextRow()
		end
		-- empty reload table, no useless data storing
		DBGossipsys.unit_reload = nil
	else
		DBGossipsys.unit = {}
		DBGossipsys.gossip_units = WorldDB:Query("SELECT `entry`, `type`, `menu_id`, `check_combat` FROM `custom_gossip`.`units` WHERE `entry` BETWEEN 1 AND 200000 ORDER BY `entry` ASC")
		if(DBGossipsys.gossip_units ~= nil) then
			DBGossipsys.unit["rowcount"] = DBGossipsys.gossip_units:GetRowCount()
		else
			DBGossipsys.unit["rowcount"] = 0
			print("Table `custom_gossip`.`units` was empty.\nAfter filling, reload luaengine or restart server.")
		end
		for i = 1, DBGossipsys.unit["rowcount"] do
			DBGossipsys.unit[i] = {DBGossipsys.gossip_units:GetColumn(0):GetUInt32(), DBGossipsys.gossip_units:GetColumn(1):GetUInt32(), DBGossipsys.gossip_units:GetColumn(2):GetUInt32(), DBGossipsys.gossip_units:GetColumn(3):GetUInt32()}
			DBGossipsys.gossip_units:NextRow()
		end
		-- empty load table, no useless data storing
		DBGossipsys.gossip_units = nil
	end

end

-- Populating data tables on load
DBGossipsys.reLoadUnitMenu(false)
DBGossipsys.LoadData()

function DBGossipsys.GetMenu(npc_text, pUnit, pPlayer) -- (menu_id, pPlayer, pUnit, npc_text, DBGossipsys.option)

	local menu = GossipMenu(pUnit, npc_text, 0)
	for i = 1, DBGossipsys.option["rowcount"] do
		if(DBGossipsys.option[i][1] == menu_id) then
			if(pPlayer:GetLevel() >= DBGossipsys.option[i][9] and (pPlayer:GetTeam() == DBGossipsys.option[i][10] or DBGossipsys.option[i][10] == 2)) then
				_hide = false
				for l = 1, DBGossipsys.conditions["rowcount"] do
					if(DBGossipsys.conditions[l][1] == menu_id and DBGossipsys.conditions[l][2] == DBGossipsys.option[i][2]) then
						local _has_ID = DBGossipsys.conditions[l][3]
						local _value = DBGossipsys.conditions[l][4]
						if(_has_ID == 0) then
							if(_bool) then
								if(pPlayer:HasSpell(_value) == false) then
									_hide = true
								end
							else
								if(pPlayer:HasSpell(_value) == true) then
									_hide = true
								end
							end
						elseif(_has_ID == 1) then
							if(_bool) then
								if(pPlayer:HasAura(_value) == false) then
									_hide = true
								end
							else
								if(pPlayer:HasAura(_value) == true) then
									_hide = true
								end
							end
						elseif(_has_ID == 2) then
							if(_bool) then
								if(pPlayer:HasSkill(_value) == false) then
									_hide = true
								end
							else
								if(pPlayer:HasSkill(_value) == true) then
									_hide = true
								end
							end
						elseif(_has_ID == 3) then
							if(_bool) then
								if(pPlayer:HasItem(_value) == false) then
									_hide = true
								end
							else
								if(pPlayer:HasItem(_value) == true) then
									_hide = true
								end
							end
						elseif(_has_ID == 4) then
							if(_bool) then
								if(pPlayer:HasQuest(_value) == false) then
									_hide = true
								end
							else
								if(pPlayer:HasQuest(_value) == true) then
									_hide = true
								end
							end
						elseif(_has_ID == 5) then
							if(_bool) then
								if(pPlayer:HasFinishedQuest(_value) == false) then
									_hide = true
								end
							else
								if(pPlayer:HasFinishedQuest(_value) == true) then
									_hide = true
								end
							end
						elseif(_has_ID == 6) then
							if(_bool) then
								if(pPlayer:HasTitle(_value) == false) then
									_hide = true
								end
							else
								if(pPlayer:HasTitle(_value) == true) then
									_hide = true
								end
							end
						elseif(_has_ID == 7) then
							if(_bool) then
								if(pPlayer:IsInPhase(_value) == false) then
									_hide = true
								end
							else
								if(pPlayer:IsInPhase(_value) == true) then
									_hide = true
								end
							end
						elseif(_has_ID == 8) then
							if(_bool) then
								if(pPlayer:IsStealthed() == false) then
									_hide = true
								end
							else
								if(pPlayer:IsStealthed() == true) then
									_hide = true
								end
							end
						elseif(_has_ID == 9) then -- true: male, false: female
							if(_bool) then
								if(pPlayer:GetGender() == 1) then
									_hide = true
								end
							else
								if(pPlayer:GetGender() == 0) then
									_hide = true
								end
							end
						end
					end
				end
				if(_hide == false) then
					menu:AddMenuItem(DBGossipsys.option[i][5], DBGossipsys.option[i][6], i, DBGossipsys.option[i][7], DBGossipsys.option[i][8])
				end
			end
		end
	end
	menu:Send(pPlayer)

end

function DBGossipsys.Item_trigg(pUnit, event, pPlayer)

	return DBGossipsys.Hello(pUnit, event, pPlayer)
	
end

function DBGossipsys.Hello(pUnit, event, pPlayer)
	
	if(pUnit:IsCreature()) then
		unit_type = 0
	elseif(pUnit:IsGameObject()) then
		unit_type = 1
	elseif(pUnit:IsItem()) then
		unit_type = 2
	end
	for i = 1, DBGossipsys.unit["rowcount"] do
		if(DBGossipsys.unit[i][1] == pUnit:GetEntry() and DBGossipsys.unit[i][2] == unit_type) then
			check_combat = DBGossipsys.unit[i][4]
			menu_id = DBGossipsys.unit[i][3]
			break
		end
	end
	for i = 1, DBGossipsys.menu["rowcount"] do
		if(DBGossipsys.menu[i][1] == menu_id) then
			npc_text = DBGossipsys.menu[i][2]
			break
		end
	end
	if(check_combat == 1 and pPlayer.CombatStatus:IsInCombat() == true) then
		pPlayer:SendAreaTriggerMessage("|cffff0000You are in combat|r")
		GossipMenu.Complete(pPlayer)
	else
		if(npc_text == nil or npc_text <= 0) then npc_text = 1 end
		DBGossipsys.GetMenu(npc_text, pUnit, pPlayer)
	end

end

function DBGossipsys.Select(pUnit, event, pPlayer, intid, code)

	cost_in_copper = DBGossipsys.option[intid][7]
	if(DBGossipsys.option[intid][3] ~= 0) then
		for l = 1, DBGossipsys.scripts["rowcount"] do
			if(DBGossipsys.scripts[l][12] == DBGossipsys.option[intid][3]) then
				-- todo, implement quest add, remove, PVP flags
				-- define things
				local _value = DBGossipsys.scripts[l][8]
				local _value2 = DBGossipsys.scripts[l][11]
				local _command = DBGossipsys.scripts[l][1]
				local _float = DBGossipsys.scripts[l][2]
				local _map = DBGossipsys.scripts[l][3]
				local _x = DBGossipsys.scripts[l][4]
				local _y = DBGossipsys.scripts[l][5]
				local _z = DBGossipsys.scripts[l][6]
				local _o = DBGossipsys.scripts[l][7]
				local _string = DBGossipsys.scripts[l][10]
				if(_command == 1) then -- set scale
					pPlayer:SetScale(_float)
				elseif(_command == 2) then -- set phase
					pPlayer:PhaseSet(_value)
				elseif(_command == 3) then -- play sound false: to player true: to ppl around
					if(truefalse == false) then
						pPlayer:PlaySoundToPlayer(_value)
					else
						pPlayer:PlaySoundToSet(_value)
					end
				elseif(_command == 4) then -- false:set, true:add level
					if(truefalse == false) then
						pPlayer:SetLevel(_value)
					else
						pPlayer:ModLevel(_value)
					end
				elseif(_command == 5) then -- set NPC faction temporarily
					if(pUnit:IsCreature()) then
						pUnit:SetFaction(_value)
					end
				elseif(_command == 6) then -- false:morph, true: demorph
					if(truefalse == false) then
						pPlayer:SetDisplayID(_value)
					else
						pPlayer:Demorph()
					end
				elseif(_command == 7) then -- NPC casts spell on False: player, true: self
					if(pUnit:IsCreature()) then
						if(truefalse == false) then
							pUnit:FullCastSpellOnTarget(pPlayer, _value)
						else
							pUnit:FullCastSpellOnTarget(pUnit, _value)
						end
					end
				elseif(_command == 8) then -- Player casts spell on False: player, true: NPC
					if(truefalse == false) then
						pPlayer:FullCastSpellOnTarget(pPlayer, _value)
					else
						if(pUnit:IsCreature()) then
							pPlayer:FullCastSpellOnTarget(pUnit, _value)
						end
					end
				elseif(_command == 9) then -- remove aura
					pPlayer:RemoveAura(_value, pPlayer)
				elseif(_command == 10) then -- player sends message to ppl
					pPlayer:SendChatMessage(_value, 0, _string, 0)
				elseif(_command == 11) then -- send false:areatriggermessage, true:error to player
					if(truefalse == false) then
						pPlayer:SendAreaTriggerMessage(_string)
					else
						pPlayer:SendAreaTriggerMessage("|cffff0000".._string.."|r")
					end
				elseif(_command == 12) then -- teach spell
					--if(truefalse == false) then
					--	pPlayer:UnlearnSpell(_value) -- Does not work yet?
					--else
						pPlayer:AddSpell(_value)
					--end
				elseif(_command == 13) then -- reset talents
					pPlayer:ResetTalents()
				elseif(_command == 14) then -- false: remove, true: add title
					pPlayer:SetKnownTitle(_value, truefalse) 
				elseif(_command == 15) then -- dismount
					pPlayer:Dismount()
				elseif(_command == 16) then -- True:possess, False:unpossess
					if(pUnit:IsCreature()) then
						if(truefalse == false) then
							pPlayer:Unpossess()
						else
							pPlayer:Possess(pUnit)
						end
					end
				elseif(_command == 17) then -- Set Hearthstone false: to player, true: to coords
					if(truefalse == false) then
						pPlayer:SetBindPoint(pPlayer:GetPositionX(), pPlayer:GetPositionY(), pPlayer:GetPositionZ(), 0, pPlayer:GetMapID())
					else
						pPlayer:SetBindPoint(_x, _y, _z, 0, _map)
					end
				elseif(_command == 18) then -- Join guild (if not in one already)
					if(pPlayer:IsInGuild() == false) then
						pPlayer:SetGuildID(_value) 
					end
				elseif(_command == 19) then -- set guild rank
					pPlayer:SetGuildRank(_value)
				elseif(_command == 20) then -- true: give, false: take gold (copper)
					if(truefalse == false) then
						pPlayer:TakeGold(_value)
					else
						pPlayer:GiveGold(_value)
					end
				elseif(_command == 21) then -- true: add, false: take items
					if(truefalse == false) then
						pPlayer:RemoveItem(_value, _value2)
					else
						pPlayer:AddItem(_value, _value2)
					end
				elseif(_command == 22) then -- Send a message to everyone
					SendWorldMessage(_string, _value)
				elseif(_command == 23) then -- Make an SQL statement (insert, delete, update..) Default DB = world
					WorldDB:Query(_string)
				elseif(_command == 24) then -- spawn npc true: to coords, false: to player (temporarlily if time > 0)
					if(truefalse == false) then
						pPlayer:SpawnCreature(_value, pPlayer:GetPositionX(), pPlayer:GetPositionY(), pPlayer:GetPositionZ(), pPlayer:GetOrientation(), 0, _value2)
					else
						pPlayer:SpawnCreature(_value, _x, _y, _z, _o, 0, _value2)
					end
				elseif(_command == 25) then -- false: NPC, true: player emotes -- _value2 = time to use for emoting.
					if(truefalse == false and pUnit:IsCreature()) then
						pUnit:Emote(_value, _value2)
					elseif(truefalse == true) then
						pPlayer:Emote(_value, _value2)
					end
				elseif(_command == 26) then -- Activate gameobject nearest false: to player, true: to coords; with Entry
					if(truefalse == false) then
						local GOB = pPlayer:GetGameObjectNearestCoords(pPlayer:GetPositionX(), pPlayer:GetPositionY(), pPlayer:GetPositionZ(), _value)
						if(GOB ~= nil) then
							GOB:Activate()
						end
					else
						local GOB = pPlayer:GetGameObjectNearestCoords(_x, _y, _z, _value)
						if(GOB ~= nil) then
							GOB:Activate()
						end
					end
				elseif(_command == 27) then -- NPC instant casts spell on False: player, true: self
					if(pUnit:IsCreature()) then
						if(truefalse == false) then
							pUnit:CastSpellOnTarget(pPlayer, _value)
						else
							pUnit:CastSpellOnTarget(pUnit, _value)
						end
					end
				elseif(_command == 28) then
					if(truefalse == false) then -- Player instant casts spell on False: player, true: NPC
						pPlayer:CastSpellOnTarget(pPlayer, _value)
					else
						if(pUnit:IsCreature()) then
							pPlayer:CastSpellOnTarget(pUnit, _value)
						end
					end
				elseif(_command == 0) then -- teleport
					GossipMenu.Complete(pPlayer)
					pPlayer:SafeTeleport(_map, 0, _x, _y, _z, _o)
					break
				end
			end
		end
	end
	if(DBGossipsys.option[intid][4] < 0) then
		GossipMenu.Complete(pPlayer)
	else
		menu_id = DBGossipsys.option[intid][4]
		for i = 1, DBGossipsys.menu["rowcount"] do
			if(DBGossipsys.menu[i][1] == menu_id) then
				npc_text = DBGossipsys.menu[i][2]
				break
			end
		end
		if(npc_text == nil or npc_text <= 0) then npc_text = 1 end
		DBGossipsys.GetMenu(npc_text, pUnit, pPlayer)
	end
	if(pPlayer:GetSession():IsGM() == false) then
		pPlayer:TakeGold(cost_in_copper)
	end
	
end

for i = 1, DBGossipsys.unit["rowcount"] do
	if(DBGossipsys.unit[i][2] == 0) then
		WorldDB:Query("UPDATE `creature_proto` SET `npcflags` = 1 WHERE `entry` = '"..DBGossipsys.unit[i][1].."'")
		RegisterUnitGossipEvent(DBGossipsys.unit[i][1], 1, DBGossipsys.Hello)
		RegisterUnitGossipEvent(DBGossipsys.unit[i][1], 2, DBGossipsys.Select)
	elseif(DBGossipsys.unit[i][2] == 1) then
		RegisterGameObjectEvent(DBGossipsys.unit[i][1], 4, DBGossipsys.Hello)
		RegisterGOGossipEvent(DBGossipsys.unit[i][1], 2, DBGossipsys.Select)
	elseif(DBGossipsys.unit[i][2] == 2) then
		WorldDB:Query("UPDATE `items` SET `spellid_1` = 33227, `spelltrigger_1` = 0 WHERE `entry` = '"..DBGossipsys.unit[i][1].."'")
		RegisterItemGossipEvent(DBGossipsys.unit[i][1], 1, DBGossipsys.Item_trigg)
		RegisterItemGossipEvent(DBGossipsys.unit[i][1], 2, DBGossipsys.Select)
	end
end

--[[
FULL CREDIT ABOUT THIS GOES TO Rochet2 AT WOW-V.COM

YOU ARE NOT ALLOWED TO RELEASE THIS SCRIPT ANYWHERE WITHOUT MY PERMISSION.
YOU ARE NOT ALLOWED TO SHARE THIS SCRIPT BY POSTING THE SCRIPT OR LINK TO IT ON ANY WEBSITE.
ALL SHARING IS DONE BY GIVING CREDIT TO THE MAKER (Rochet2) AND BY ONLY POSTING A LINK TO HIS THREAD AT WOW-V.COM
LINK TO THE ORIGINAL AND ONLY RELEASE THREAD: http://wow-v.com/forums/index.php?topic=24301.0

THIS SCRIPT IS FOR YOUR OWN USE ONLY!

More Rochet2's work at projectcode.zzl.org
]]--