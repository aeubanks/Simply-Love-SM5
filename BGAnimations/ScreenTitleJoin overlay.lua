return Def.Actor {
	CodeMessageCommand=function(self, param)
		Trace("Code entered by " .. param.PlayerNumber .. " is: " .. param.Name)
		if param.Name == "OperatorMenu" then
			local top_screen= SCREENMAN:GetTopScreen()
			top_screen:SetNextScreenName("ScreenOptionsService")
			top_screen:StartTransitioningScreen("SM_GoToNextScreen")
		end
	end,
	InitCommand=function(self)
		self:xy(_screen.cx,_screen.h-80):zoom(0.7):shadowlength(0.75)
		self:visible(false):queuecommand("Refresh")
	end,
	OnCommand=function(self)
		self:diffuseshift():effectperiod(1.333)
		self:effectcolor1(1,1,1,0):effectcolor2(1,1,1,1)
	end,
	OffCommand=function(self) self:visible(false) end,

	CoinsChangedMessageCommand=function(self) self:queuecommand("Refresh") end,
	CoinModeChangedMessageCommand=function(self) self:queuecommand("Refresh") end,

	RefreshCommand=function(self)
		self:visible( false )

		if GAMESTATE:GetCoinMode() == "CoinMode_Free" then
		 	self:settext( THEME:GetString("ScreenTitleJoin", "Press Start") )
			return
		end

		if GetCredits().Credits <= 0 then
			self:settext( THEME:GetString("ScreenLogo", "EnterCreditsToPlay") )
		else
		 	self:settext( THEME:GetString("ScreenTitleJoin", "Press Start") )
		end
	end
}