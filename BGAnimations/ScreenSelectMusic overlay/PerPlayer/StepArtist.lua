local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]

-- Resting position of this player's step-artist strip, and which way it slides
-- in when a player joins.  Absolute coordinates (rather than a relative addy)
-- keep the resting position stable even if "Appear" is queued more than once.
-- The STEPS strip sits flush under the density graph (its bottom = the
-- graph's top) and its inner edge lines up with the graph's centre-side edge.
-- (The strip's background quad spans local x 25.5..200.5.)
local final_y = _screen.cy + 24 - _screen.h/56
local slide = (player == PLAYER_1) and 30 or -30
local graph_inner = (player == PLAYER_1) and (_screen.w*0.5 - 60) or (_screen.w*0.5 + 60)
local final_x = (player == PLAYER_1) and (graph_inner - 200.5) or (graph_inner - 25.5)

-- Colours the STEPS / chart-description strip for the current chart's
-- difficulty (or the player colour if no chart is selected yet).
local function SetStepArtistBackground(quad)
	local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)
	if StepsOrTrail then
		quad:diffuse( DifficultyColor(StepsOrTrail:GetDifficulty()) )
	else
		quad:diffuse( PlayerColor(player) )
	end
end

local text_table, marquee_index

return Def.ActorFrame{
	Name="StepArtistAF_" .. pn,

	-- song and course changes
	OnCommand=function(self) self:queuecommand("Reset") end,
	["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self) self:queuecommand("Reset") end,
	CurrentSongChangedMessageCommand=function(self) self:queuecommand("Reset") end,
	CurrentCourseChangedMessageCommand=function(self) self:queuecommand("Reset") end,

	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:queuecommand("Appear" .. pn)
		end
	end,

	-- Simply Love doesn't support player unjoining (that I'm aware of!) but this
	-- animation is left here as a reminder to a future me to maybe look into it.
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:stoptweening():ease(0.5, 275):y(final_y + slide):diffusealpha(0)
		end
	end,

	-- depending on the value of pn, this will either become
	-- an AppearP1Command or an AppearP2Command when the screen initializes
	-- Do NOT call stoptweening() here: queued commands (like the "Reset" queued
	-- by OnCommand) are stored as zero-duration tweens, so stoptweening would
	-- cancel them and leave the background stuck on its initial black colour
	-- until the next song change.
	["Appear"..pn.."Command"]=function(self)
		self:xy(final_x, final_y + slide)
		self:visible(true):ease(0.5, 275):y(final_y):diffusealpha(1)
	end,

	-- In the U-shaped layout each player's chart info lives in their own
	-- bottom corner: P1 bottom-left, P2 bottom-right.
	InitCommand=function(self)
		self:visible( false ):halign( p )
		self:xy(final_x, final_y)

		if GAMESTATE:IsHumanPlayer(player) then
			self:queuecommand("Appear" .. pn)
		end
	end,

	-- colored background quad
	Def.Quad{
		Name="BackgroundQuad",
		InitCommand=function(self) self:zoomto(175, _screen.h/28):x(113) SetStepArtistBackground(self) end,
		ResetCommand=function(self) SetStepArtistBackground(self) end
	},

	--STEPS label
	LoadFont("Common Normal")..{
		Text=GAMESTATE:IsCourseMode() and THEME:GetString("ScreenSelectCourse", "SongNumber"):format(1) or Screen.String("STEPS"),
		InitCommand=function(self)
			self:diffuse(0,0,0,1):horizalign(left):x(30):maxwidth(40):zoom(0.8)
		end,
		UpdateTrailTextMessageCommand=function(self, params)
			self:settext( THEME:GetString("ScreenSelectCourse", "SongNumber"):format(params.index) )
		end
	},

	--stepartist text
	LoadFont("Common Normal")..{
		InitCommand=function(self)
			self:diffuse(color("#1e282f")):horizalign(left):zoom(0.8)

			if GAMESTATE:IsCourseMode() then
				self:x(60):maxwidth(138)
			else
				self:x(75):maxwidth(124):diffuse(color("#000000"))
			end
		end,
		ResetCommand=function(self)

			local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
			local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)

			-- always stop tweening when steps change in case a MarqueeCommand is queued
			self:stoptweening()

			if SongOrCourse and StepsOrTrail then

				text_table = GetStepsCredit(player)
				marquee_index = 0

				-- don't queue a Marquee in CourseMode
				-- each TrailEntry text change will be broadcast from CourseContentsList.lua
				-- to ensure it stays synced with the scrolling list of songs
				if not GAMESTATE:IsCourseMode() then
					-- only queue a Marquee if there are things in the text_table to display
					if #text_table > 0 then
						self:queuecommand("Marquee")
					else
						-- no credit information was specified in the simfile for this stepchart, so just set to an empty string
						self:settext("")
					end
				end
			else
				-- there wasn't a song/course or a steps object, so the MusicWheel is probably hovering
				-- on a group title, which means we want to set the stepartist text to an empty string for now
				self:settext("")
			end
		end,
		MarqueeCommand=function(self)
			-- increment the marquee_index, and keep it in bounds
			marquee_index = (marquee_index % #text_table) + 1
			-- retrieve the text we want to display
			local text = text_table[marquee_index]

			-- set this BitmapText actor to display that text
			self:settext( text )

			-- check for emojis; they shouldn't be diffused to Color.Black
			DiffuseEmojis(self, text)

			if not GAMESTATE:IsCourseMode() then
				-- sleep 2 seconds before queueing the next Marquee command to do this again
				if #text_table > 1 then
					self:sleep(2):queuecommand("Marquee")
				end
			else
				self:sleep(0.5):queuecommand("m")
			end
		end,
		UpdateTrailTextMessageCommand=function(self, params)
			if text_table then
				self:settext( text_table[params.index] or "" )
			end
		end,
		OffCommand=function(self) self:stoptweening() end
	}
}