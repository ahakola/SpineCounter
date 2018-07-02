--localization file for deDE
local L = LibStub("AceLocale-3.0"):NewLocale("SpineCounter", "deDE")
if not L then return end

L["skyline"] = "Die Platten! Es zerreißt ihn! Zerlegt die Platten und wir können ihn vielleicht runterbringen." -- http://www.wowhead.com/npc=55870
L["Corrupted Blood"] = "Verderbtes Blut" -- http://www.wowhead.com/npc=53889
L["Dragon Soul"] = "Drachenseele" -- http://www.wowhead.com/zone=5892
L["Deathwing"] = "Todesschwinge" -- http://de.wowhead.com/npc=53879 (if the window doesn't show automaticly, check the minimap text for zone during the encounter and use it here)
L["Residue"] = "Überrest"
L["Active"] = "Aktiv"

-- Slash-command replies
L["snoarg"] = "Keine Attribute gegeben, versuchen '/scount show' oder '/scount hide'"
L["sshow"] = "Zeigt"
L["shide"] = "Versteckt"
L["sunknown"] = "Unbekannter Befehl, versuchen '/scount show' oder '/scount hide'"