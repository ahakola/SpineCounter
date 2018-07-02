--localization file for enUS
local L = LibStub("AceLocale-3.0"):NewLocale("SpineCounter", "enUS", true)
if not L then return end

L["skyline"] = "The plates! He's coming apart! Tear up the plates and we've got a shot at bringing him down!" -- http://www.wowhead.com/npc=55870
L["Corrupted Blood"] = true -- http://www.wowhead.com/npc=53889
L["Dragon Soul"] = true -- http://www.wowhead.com/zone=5892
L["Deathwing"] = true -- http://www.wowhead.com/npc=53879 (if the window doesn't show automaticly, check the minimap text for zone during the encounter and use it here)
L["Residue"] = true
L["Active"] = true

-- Slash-command replies
L["snoarg"] = "No attributes given, try '/scount show' or '/scount hide'"
L["sshow"] = "Showing"
L["shide"] = "Hiding"
L["sunknown"] = "Unknown command, try '/scount show' or '/scount hide'"