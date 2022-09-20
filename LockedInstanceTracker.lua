LockedInstanceTracker = {};
LockedInstanceTracker.fully_loaded = false;
LockedInstanceTracker.default_options = {
	-- main frame position
	frameRef = "CENTER",
	frameX = 0,
	frameY = 0,
	hide = false,

	-- sizing
	frameW = 200,
	frameH = 200,
};

local savedHcInsanceNames = {}
local numSavedInstances = GetNumSavedInstances()

function LockedInstanceTracker.OnReady()
	_G.LockedInstanceTrackerPrefs = _G.LockedInstanceTrackerPrefs or {};

	for k,v in pairs(LockedInstanceTracker.default_options) do
		if (not _G.LockedInstanceTrackerPrefs[k]) then
			_G.LockedInstanceTrackerPrefs[k] = v;
		end
	end

    table.insert(savedHcInsanceNames, 'Locked HC instances:\n\n')
    for i = 0, numSavedInstances do
        local name, id, reset, difficulty,
            locked, extended, instanceIDMostSig,
            isRaid, maxPlayers, difficultyName,
            numEncounters, encounterProgress = GetSavedInstanceInfo(i)

        if (difficultyName == "Heroic" and locked) then
            table.insert(savedHcInsanceNames, name)
        end
    end

	LockedInstanceTracker.CreateUIFrame();
end

function LockedInstanceTracker.OnSaving()
	if (LockedInstanceTracker.UIFrame) then
		local point, relativeTo, relativePoint, xOfs, yOfs = LockedInstanceTracker.UIFrame:GetPoint()
		_G.LockedInstanceTrackerPrefs.frameRef = relativePoint;
		_G.LockedInstanceTrackerPrefs.frameX = xOfs;
		_G.LockedInstanceTrackerPrefs.frameY = yOfs;
	end
end

function LockedInstanceTracker.OnUpdate()
	if (not LockedInstanceTracker.fully_loaded) then
		return;
	end

	-- if (_G.LockedInstanceTrackerPrefs.hide) then
		-- return;
	-- end

	LockedInstanceTracker.UpdateFrame();
end

function LockedInstanceTracker.OnEvent(frame, event, ...)
	if (event == 'ADDON_LOADED') then
		local name = ...;
		if name == 'LockedInstanceTracker' then
			LockedInstanceTracker.OnReady();
		end
		return;
	end

	if (event == 'PLAYER_LOGIN') then
		LockedInstanceTracker.fully_loaded = true;
		return;
	end

	if (event == 'PLAYER_LOGOUT') then
		LockedInstanceTracker.OnSaving();
		return;
	end
end

function LockedInstanceTracker.CreateUIFrame()
	-- create the UI frame
	LockedInstanceTracker.UIFrame = CreateFrame("Frame",nil,UIParent);
	LockedInstanceTracker.UIFrame:SetFrameStrata("BACKGROUND")
	LockedInstanceTracker.UIFrame:SetWidth(_G.LockedInstanceTrackerPrefs.frameW);
	LockedInstanceTracker.UIFrame:SetHeight(_G.LockedInstanceTrackerPrefs.frameH);

	-- make it black
	LockedInstanceTracker.UIFrame.texture = LockedInstanceTracker.UIFrame:CreateTexture();
	LockedInstanceTracker.UIFrame.texture:SetAllPoints(LockedInstanceTracker.UIFrame);
	LockedInstanceTracker.UIFrame.texture:SetTexture(0, 0, 0);

	-- position it
	LockedInstanceTracker.UIFrame:SetPoint(_G.LockedInstanceTrackerPrefs.frameRef, _G.LockedInstanceTrackerPrefs.frameX, _G.LockedInstanceTrackerPrefs.frameY);

	-- make it draggable
	LockedInstanceTracker.UIFrame:SetMovable(true);
	LockedInstanceTracker.UIFrame:EnableMouse(true);

	-- create a button that covers the entire addon
	LockedInstanceTracker.Cover = CreateFrame("Button", nil, LockedInstanceTracker.UIFrame);
	LockedInstanceTracker.Cover:SetFrameLevel(128);
	LockedInstanceTracker.Cover:SetPoint("TOPLEFT", 0, 0);
	LockedInstanceTracker.Cover:SetWidth(_G.LockedInstanceTrackerPrefs.frameW);
	LockedInstanceTracker.Cover:SetHeight(_G.LockedInstanceTrackerPrefs.frameH);
	LockedInstanceTracker.Cover:EnableMouse(true);
	LockedInstanceTracker.Cover:RegisterForClicks("AnyUp");
	LockedInstanceTracker.Cover:RegisterForDrag("LeftButton");
	LockedInstanceTracker.Cover:SetScript("OnDragStart", LockedInstanceTracker.OnDragStart);
	LockedInstanceTracker.Cover:SetScript("OnDragStop", LockedInstanceTracker.OnDragStop);
	-- LockedInstanceTracker.Cover:SetScript("OnClick", LockedInstanceTracker.OnClick);

	-- add a main label - just so we can show something
	LockedInstanceTracker.Label = LockedInstanceTracker.Cover:CreateFontString(nil, "OVERLAY");
	LockedInstanceTracker.Label:SetPoint("CENTER", LockedInstanceTracker.UIFrame, "CENTER", 2, 0);
	LockedInstanceTracker.Label:SetJustifyH("LEFT");
	LockedInstanceTracker.Label:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE");
	LockedInstanceTracker.Label:SetText(" ");
	LockedInstanceTracker.Label:SetTextColor(1,1,1,1);
	LockedInstanceTracker.SetFontSize(LockedInstanceTracker.Label, 20);
end

function LockedInstanceTracker.SetFontSize(string, size)
	local Font, Height, Flags = string:GetFont()
	if (not (Height == size)) then
		string:SetFont(Font, size, Flags)
	end
end

function LockedInstanceTracker.OnDragStart(frame)
	LockedInstanceTracker.UIFrame:StartMoving();
	LockedInstanceTracker.UIFrame.isMoving = true;
	GameTooltip:Hide()
end

function LockedInstanceTracker.OnDragStop(frame)
	LockedInstanceTracker.UIFrame:StopMovingOrSizing();
	LockedInstanceTracker.UIFrame.isMoving = false;
end

function LockedInstanceTracker.OnClick(self, aButton)
    if (aButton == "RightButton") then
        print('hiding');
        LockedInstanceTracker.UIFrame:Hide()
    end
end

function LockedInstanceTracker.UpdateFrame()
    LockedInstanceTracker.Label:SetText(table.concat(savedHcInsanceNames, '\n'));
end

LockedInstanceTracker.EventFrame = CreateFrame("Frame");
LockedInstanceTracker.EventFrame:Show();
LockedInstanceTracker.EventFrame:SetScript("OnEvent", LockedInstanceTracker.OnEvent);
LockedInstanceTracker.EventFrame:SetScript("OnUpdate", LockedInstanceTracker.OnUpdate);
LockedInstanceTracker.EventFrame:RegisterEvent("ADDON_LOADED");
LockedInstanceTracker.EventFrame:RegisterEvent("PLAYER_LOGIN");
LockedInstanceTracker.EventFrame:RegisterEvent("PLAYER_LOGOUT");
