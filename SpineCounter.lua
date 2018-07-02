--=======================================--
--Close your eyes, don't look any further--
--=======================================--
--(I'm not trying to hide that I borrowed some code,
--but the fact that my own code ain't as good as the
--code I borrowed)

local SC = LibStub("AceAddon-3.0"):NewAddon("SpineCounter", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("SpineCounter")

local pullLine = L["skyline"]
local bloodName = L["Corrupted Blood"]
--local bloodName = "Cutpurse" -- Debug

function SC:OnInitialize()
	DEFAULT_CHAT_FRAME:AddMessage("SpineCounter: |cFF00FF00Loaded|r")

	SC:RegisterChatCommand("scount", "SlashCMD")
	SC:RegisterChatCommand("scounter", "SlashCMD")
	SC:RegisterChatCommand("spinecounter", "SlashCMD")
end

--Random init stuff
local pinwin = false -- 1.0.3
local testMode = false
local spamtimer = 0
local bloodCount = 0
local aliveCount = 0
local row1 = ""
local row2 = ""
local row3 = ""
local row4 = "0"
local row5 = "0"
local deadBlood = {}
local aliveBlood = {}

--Output-frame
local Output = CreateFrame("Frame", "SCOutput", UIParent)
Output:SetMovable(true)
Output:SetClampedToScreen(true)
Output:EnableMouse(true)
Output:RegisterForDrag("LeftButton")
Output:SetScript("OnDragStart", Output.StartMoving)
Output:SetScript("OnDragStop", Output.StopMovingOrSizing)
Output:SetBackdrop(StaticPopup1:GetBackdrop())

Output:SetHeight(50)
Output:SetWidth(100)

Output.text = Output:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
Output.text:SetAllPoints()
Output.text:SetText("Spine Counter")
Output:SetPoint("CENTER", 0, 100)


function SC:SlashCMD(arg)
	arg = arg:trim()
	if not arg or arg == "" then
		self:Print(L["snoarg"]);
	elseif arg == "enable" or arg == "toggle" or arg == "true" or arg == "show" then
		Output:Show()
		pinwin = true -- 1.0.3
		self:Print(L["sshow"])
	elseif arg == "disable" or arg == "false" or arg == "hide" then
		Output:Hide()
		pinwin = false -- 1.0.3
		self:Print(L["shide"])
	elseif arg == "debug" then
		if testMode then
			testMode = false
			Output:SetHeight(50)
			Output:SetWidth(100)
			Output:Show()
			self:Print("Debug-mode |cFFFF0000Off|r")
		else
			testMode = true
			Output:SetHeight(90)
			Output:SetWidth(250)
			Output:Show()
			self:Print("Debug-mode |cFF00FF00On|r")
		end
	else
		self:Print(L["sunknown"]);
	end
end

function SC:OnEnable()
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "CheckDS")
	self:RegisterEvent("ZONE_CHANGED", "CheckDS")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "CheckDS")

--	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED","GrabEvent") -- Debug
end

local function winUp(line, text)
	if line == 1 then
		row1 = text
	elseif line == 2 then
		row2 = text
	elseif line == 3 then
		row3 = text
	elseif line == 4 then
		row4 = text
	elseif line == 5 then
		row5 = text
	end
	if testMode then
		Output.text:SetText("E: "..row1.."\nF: "..row2.."\nA: "..row3.."\n"..L["Residue"]..": "..row4.."\n"..L["Active"]..": "..row5)
	else
		Output.text:SetText(L["Residue"]..": "..row4.."\n"..L["Active"]..": "..row5)
	end
end

function SC:CheckDS()
--	self:Print("'"..GetRealZoneText().."' - '"..GetSubZoneText().."'") -- Debug line to check Zone info
	--Spine of Deathwing - Zone: "Dragon Soul", SubZone: "Deathwing"
	if (GetRealZoneText() == L["Dragon Soul"] and GetSubZoneText() == L["Deathwing"]) then
--	if (GetRealZoneText() == "Elwynn Forest") then -- Debug
		self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "PullCheck")
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED","GrabEvent")
		Output:Show()
	else
		self:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		if not pinwin then -- 1.0.3
			Output:Hide()
		end -- 1.0.3
	end
end

function SC:PullCheck(...)
	local event, arg1, arg2 = select(1, ...)
	if (arg1 == pullLine) then
		--Reset counters and tables on pull
		row1 = ""
		row2 = ""
		row3 = ""
		row4 = "0"
		row5 = "0"
		bloodCount = 0
		aliveCount = 0
		wipe(deadBlood)
		wipe(aliveBlood)
		winUp(4,bloodCount) -- 1.0.1
		winUp(5,aliveCount) -- 1.0.1
	end
end

--Magic?

local function residueDecrease(GUID)
	bloodCount = bloodCount - 1
	deadBlood[GUID] = nil
end

local function aliveDecrease(GUID)
	aliveCount = aliveCount - 1
	aliveBlood[GUID] = nil
end

local function ResidueChange(spellId, sGUID)
	if spellId == 109371 or spellId == 109372 or spellId == 109373 or spellId == 105219 then
		-- Burst (+1)
		bloodCount = bloodCount + 1
		aliveDecrease(sGUID) -- Added
		-- Mark this blood as dead so we know if he revives
		deadBlood[sGUID] = GetTime()
	elseif spellId == 105248 then
		residueDecrease(sGUID)
	end
	winUp(4,bloodCount)
	winUp(5,aliveCount)
end

-- Here we're using the four common tank AoE threat auras: Thunder Clap,
-- Thrash, Frost Fever, and Vindication. At some point one of these should
-- be applied to a blood, and if it is at least 5s after death, we know that
-- it revived.
local function bloodCheck(GUID, debug)
	if deadBlood[GUID] and GetTime() - deadBlood[GUID] > 5 then
		residueDecrease(GUID)
		winUp(4,bloodCount)
	end
end

local function BloodCheckDest(spellName, dGUID, dName)
	if dName == bloodName then
		if not aliveBlood[dGUID] then
			aliveCount = aliveCount + 1
			aliveBlood[dGUID] = GetTime()
			winUp(5,aliveCount)
		end
	end
	bloodCheck(dGUID, spellName)
	if testMode then
		winUp(3, "BloodCheck: "..spellName)
	end
end

local function BloodCheckSource(sGUID, sName)
	if sName == bloodName then
		if not aliveBlood[sGUID] then
			aliveCount = aliveCount + 1
			aliveBlood[sGUID] = GetTime()
			winUp(5,aliveCount)
		end
	end
	bloodCheck(sGUID, "Melee")
	if testMode then
		winUp(3, "BloodCheck: Melee")
	end
end

--Grabin' some events

function SC:GrabEvent(...)
	local timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, auraType, amount = select(2, ...)
	-- Debug
	if (testMode and ((GetTime() - spamtimer) > 1) and (event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_CAST_SUCCESS" or event == "SPELL_AURA_APPLIED" or event == "SWING_DAMAGE" or event == "SWING_MISSED")) then
		winUp(1, event)
		spamtimer = GetTime()
	end

	if (event == "SPELL_AURA_APPLIED_DOSE" and spellId == 105248) then
--	if (event == "SPELL_AURA_APPLIED_DOSE") then -- Debug
		if testMode then
			winUp(2,"AbsorbBlood")
			winUp(3,destName..": "..spellName.." ("..amount..")")
		end

	elseif (event == "SPELL_CAST_SUCCESS" and (spellId == 105248 or spellId == 109371 or spellId == 109372 or spellId == 109373 or spellID == 105219)) then
--	elseif (event == "SPELL_CAST_SUCCESS") then -- Debug
		ResidueChange(spellId, sourceGUID)
		if testMode then
			winUp(2, "ResidueChange")
		end

	elseif (event == "SPELL_AURA_APPLIED" and (spellId == 6343 or spellId == 77758 or spellId == 55095 or spellId == 26017)) then
--	elseif (event == "SPELL_AURA_APPLIED") then -- Debug
		BloodCheckDest(spellName, destGUID, destName)
		if testMode then
			winUp(2, "BloodCheckDest")
		end

	elseif (event == "SWING_DAMAGE" or event == "SWING_MISSED") then
		BloodCheckSource(sourceGUID, sourceName)
		if testMode then
			winUp(2, "BloodCheckSource")
		end
	end
end