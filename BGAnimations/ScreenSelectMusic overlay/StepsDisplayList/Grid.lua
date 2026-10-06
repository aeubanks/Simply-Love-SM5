-- this difficulty grid doesn't support CourseMode
-- CourseContentsList.lua should be used instead
if GAMESTATE:IsCourseMode() then return end
-- ----------------------------------------------

local GetStepsToDisplay = LoadActor("./StepsToDisplay.lua")
local autoStyle = ThemePrefs.Get("PreferredStyle")=="auto"
-- size of each difficulty block
local box, spacing = 40, 2
local t = Def.ActorFrame{
	Name="StepsDisplayList",
	-- Difficulty column now sits at the bottom centre, in the gap between the
	-- two shrunken player panes.
	InitCommand=function(self) self:xy(_screen.cx, _screen.cy + 102) end,

	OnCommand=function(self)                           self:queuecommand("RedrawStepsDisplay") end,
	CurrentSongChangedMessageCommand=function(self)    self:queuecommand("RedrawStepsDisplay") end,
	CurrentStepsP1ChangedMessageCommand=function(self) self:queuecommand("RedrawStepsDisplay") end,
	CurrentStepsP2ChangedMessageCommand=function(self) self:queuecommand("RedrawStepsDisplay") end,

	RedrawStepsDisplayCommand=function(self)
		if autoStyle then
			self:visible(false)
			return
		end
		local song = GAMESTATE:GetCurrentSong()

		if song then
			local steps = SongUtil.GetPlayableSteps( song )

			if steps then
				local StepsToDisplay = GetStepsToDisplay(steps)

				for i=1,5 do
					if StepsToDisplay[i] then
						-- if this particular song has a stepchart for this row, update the Meter
						-- and BlockRow coloring appropriately
						local meter = StepsToDisplay[i]:GetMeter()
						local difficulty = StepsToDisplay[i]:GetDifficulty()
						self:GetChild("Grid"):GetChild("Meter_"..i):playcommand("Set",  {Meter=meter, Difficulty=difficulty})
					else
						-- otherwise, set the meter to an empty string and hide this particular colored BlockRow
						self:GetChild("Grid"):GetChild("Meter_"..i):playcommand("Unset")
					end
				end
			end
		else
			self:playcommand("Unset")
		end
	end,
}

t[#t+1] = Def.Quad{
	Name="Background",
	InitCommand=function(self)
		-- +4 on the height gives the same 2px margin above/below as beside the boxes
		self:diffuse(color("#1e282f")):zoomto(box + 4, 5*box + 4*spacing + 4)
		if ThemePrefs.Get("RainbowMode") then
			self:diffusealpha(0.9)
		end
		if ThemePrefs.Get("VisualStyle") == "Technique" then
			self:diffusealpha(0.5)
		end
	end
}

local Grid = Def.ActorFrame{
	Name="Grid",
	InitCommand=function(self) end,
}

for RowNumber=-2, 2 do
	Grid[#Grid+1] = Def.Quad{
		Name="MeterBackground_"..(RowNumber + 3),
		InitCommand=function(self)
			self:diffuse(color("#0f0f0f")):zoomto(box, box):y((box+spacing)*RowNumber)
			if ThemePrefs.Get("RainbowMode") then
				self:diffusealpha(0.9)
			end
		end
	}

	Grid[#Grid+1] = LoadFont("Common Bold")..{
		Name="Meter_"..(RowNumber + 3),
		InitCommand=function(self)
			self:y((box+spacing)*RowNumber):zoom(0.64)
		end,
		SetCommand=function(self, params)
			-- diffuse and set each chart's difficulty meter
			self:diffuse( DifficultyColor(params.Difficulty) )
			self:settext(params.Meter)
		end,
		UnsetCommand=function(self) self:settext(""):diffuse(color("#182025")) end,
	}
end

t[#t+1] = Grid

return t