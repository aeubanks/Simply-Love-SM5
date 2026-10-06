-- Currently the Density Graph in SSM doesn't work for Courses.
-- Disable the functionality.
if GAMESTATE:IsCourseMode() then return end

local player = ...
local pn = ToEnumShortString(player)

-- Height and width of the density graph.  Width matches the bottom pane
-- (_screen.w/2 - 60) and the graph is centred on the pane.
local height = 64
local width = _screen.w/2 - 60
-- The density graph is always shown; the tech counts and Peak NPS now live in
-- the player's bottom PaneDisplay (see PaneDisplay.lua).

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:visible( GAMESTATE:IsHumanPlayer(player) )
		-- Sit directly above the player's pane, sharing its width and centre.
		if player == PLAYER_1 then
			self:xy(_screen.w * 0.25 - 30, _screen.cy + 56)
		else
			self:xy(_screen.w * 0.75 + 30, _screen.cy + 56)
		end
	end,
	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:visible(true)
		end
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:visible(false)
		end
	end,
	PlayerProfileSetMessageCommand=function(self, params)
		if params.Player == player then
			self:queuecommand("Redraw")
		end
	end,
}

-- Background quad for the density graph
af[#af+1] = Def.Quad{
	InitCommand=function(self)
		self:diffuse(color("#1e282f")):zoomto(width, height)
		if ThemePrefs.Get("RainbowMode") then
			self:diffusealpha(0.9)
		end
		if ThemePrefs.Get("VisualStyle") == "Technique" then
			self:diffusealpha(0.5)
		end
	end
}

af[#af+1] = Def.ActorFrame{
	Name="ChartParser",
	-- Hide when scrolling through the wheel. This also handles the case of
	-- going from song -> folder. It will get unhidden after a chart is parsed
	-- below.
	CurrentSongChangedMessageCommand=function(self)
		self:playcommand("Hide")
	end,
	["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self)
		local steps = GAMESTATE:GetCurrentSteps(player)
		if steps then
			ParseChartInfo(steps, pn)
			self:playcommand("Show")
		end

		-- Computing the GrooveStats hash requires parsing the simfile, which is
		-- expensive. Debounce it so that scrolling through the wheel doesn't
		-- parse every chart we pass over, only the one we settle on.
		-- Only needed for GrooveStats score/leaderboard lookups.
		self:stoptweening()
		self:sleep(0.4)
		self:queuecommand("ComputeHash")
	end,
	ComputeHashCommand=function(self)
		local steps = GAMESTATE:GetCurrentSteps(player)
		if steps then
			ComputeChartHash(steps, pn)
			MESSAGEMAN:Broadcast("ChartParsed")
		end
	end,
	ShowCommand=function(self)
		if GAMESTATE:GetCurrentSong() and
				GAMESTATE:GetCurrentSteps(player) then
			self:playcommand("Redraw")
		else
			self:playcommand("Hide")
		end
	end
}

local af2 = af[#af]

-- The Density Graph itself. It already has a "RedrawCommand".
af2[#af2+1] = NPS_Histogram(player, width, height)..{
	Name="DensityGraph",
	OnCommand=function(self)
		self:addx(-width/2):addy(height/2)
	end,
	HideCommand=function(self)
		self:visible(false)
	end,
	RedrawCommand=function(self)
		self:visible(true)
	end
}
-- Don't let the density graph parse the chart.
-- We do this in parent actorframe because we want to "stall" before we parse.
af2[#af2]["CurrentSteps"..pn.."ChangedMessageCommand"] = nil

-- Breakdown
af2[#af2+1] = Def.ActorFrame{
	Name="Breakdown",
	InitCommand=function(self)
		local actorHeight = 17
		self:addy(height/2 - actorHeight/2)
	end,
	HideCommand=function(self)
		self:visible(false)
	end,
	RedrawCommand=function(self)
		self:visible(true)
	end,
	Def.Quad{
		InitCommand=function(self)
			local bgHeight = 17
			self:diffuse(color("#000000")):zoomto(width, bgHeight):diffusealpha(0.5)
		end
	},

	LoadFont("Common Normal")..{
		Text="",
		Name="BreakdownText",
		InitCommand=function(self)
			local textZoom = 0.8
			self:maxwidth(width/textZoom):zoom(textZoom)
		end,
		HideCommand=function(self)
			self:settext("")
		end,
		RedrawCommand=function(self)
			local textZoom = 0.8
			self:settext(GenerateBreakdownText(pn, 0))
			local minimization_level = 1
			while self:GetWidth() > (width/textZoom) and minimization_level < 4 do
				self:settext(GenerateBreakdownText(pn, minimization_level))
				minimization_level = minimization_level + 1
			end
		end,
	}
}

return af
