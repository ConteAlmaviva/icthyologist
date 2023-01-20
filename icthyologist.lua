--[[
* Icthyologist
]]--

_addon.author   = 'Almavivaconte';
_addon.name     = 'Icthyologist';
_addon.version  = '0.0.1';

require 'common'

---------------------------------------------------------------------------------------------------
-- Variables
---------------------------------------------------------------------------------------------------

local default_config =
{
    font =
    {
        family      = 'Arial',
        size        = 7,
        color       = 0xFFFFFFFF,
        position    = { 640, 360 },
        bgcolor     = 0x80000000,
        bgvisible   = true
    },
};

local icthyologist_config = default_config;

local fish_messages = {
	[1] = "Something caught the hook!", 
	[2] = "You feel something pulling at your line.", 
	[3] = "Something clamps onto your line ferociously!",
	[4] = "Your keen angler's senses"
};

local popup_text = {
	[1] = "Fish",
	[2] = "Item",
	[3] = "Monster",
	[4] = ""
};

----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Attempt to load the configuration..
    icthyologist_config = ashita.settings.load_merged(_addon.path .. 'settings/settings.json', icthyologist_config);

    -- Create our font object..
    local f = AshitaCore:GetFontManager():Create('__icthyologist_addon');
    f:SetColor(icthyologist_config.font.color);
    f:SetFontFamily(icthyologist_config.font.family);
    f:SetFontHeight(icthyologist_config.font.size);
    f:SetBold(true);
    f:SetPositionX(icthyologist_config.font.position[1]);
    f:SetPositionY(icthyologist_config.font.position[2]);
    f:SetVisibility(true);
    f:GetBackground():SetColor(icthyologist_config.font.bgcolor);
    f:GetBackground():SetVisibility(icthyologist_config.font.bgvisible);
end);

----------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Event called when the addon is being unloaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
    local f = AshitaCore:GetFontManager():Get('__icthyologist_addon');
    icthyologist_config.font.position = { f:GetPositionX(), f:GetPositionY() };
        
    -- Save the configuration..
    ashita.settings.save(_addon.path .. 'settings/settings.json', icthyologist_config);
    
    -- Unload the font object..
    AshitaCore:GetFontManager():Delete('__icthyologist_addon');
end );

---------------------------------------------------------------------------------------------------
-- desc: called when receiving a new chat message
---------------------------------------------------------------------------------------------------
ashita.register_event('incoming_text', function(mode, message)
    if (string.len(message) == 0) then
        return false;
    end
	
	local f = AshitaCore:GetFontManager():Get('__icthyologist_addon');
	if(message:contains(fish_messages[1])) then
		if(message:contains("!!!")) then
			popup_text[1] = "Fish (Large)";
		else
			popup_text[1] = "Fish (Small)";
		end
	elseif(message:contains(fish_messages[4])) then
		local specific_Fish = string.gsub(string.gsub(message, "Your keen angler's senses tell you that this is the pull of a", ""), "n ", ""):sub(2,-4);
		popup_text[4] = specific_Fish:sub(1,1):upper()..specific_Fish:sub(2);
	end
    for k, v in pairs(fish_messages) do
        if (message:contains(v)) then
            f:SetText(popup_text[k]);
            f:SetVisibility(true);
        end
    end
	popup_text[1] = "";
    return false;
end);

ashita.register_event('outgoing_packet', function(id, size, data, modified, blocked)
    
    if (id == 0x110) then --You've hit enter/confirmed you want to (try to) pull up whatever you've hooked
        local f = AshitaCore:GetFontManager():Get('__icthyologist_addon');
        f:SetVisibility(false);
    end
    return false;
    
end);

ashita.register_event('incoming_packet', function(id, size, data, modified, blocked)
    
    if (id == 0x00A) then --You've changed zones (e.g. the boat has docked) - keeps text from persisting on screen if you were mid-fish when you zoned
        local f = AshitaCore:GetFontManager():Get('__icthyologist_addon');
        f:SetVisibility(false);
    end
    return false;
    
end);