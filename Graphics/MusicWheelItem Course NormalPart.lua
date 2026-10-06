-- Geometry for one MusicWheel item in the U-shaped wheel.
-- The card is centred on the wheel origin; the ItemTransformFunction in
-- metrics.ini [MusicWheel] places that origin along the V.
local item_width = _screen.w / 3.02
local item_height = _screen.h / 16

return Def.ActorFrame {
    Def.Quad {
        InitCommand = function(self)
            self:horizalign(center):diffuse(0, 10 / 255, 17 / 255, 0.5):zoomto(item_width, item_height)
        end
    },
    Def.Quad {
        InitCommand = function(self)
            self:horizalign(center):diffuse(DarkUI() and {1, 1, 1, 0.5} or {10 / 255, 20 / 255, 27 / 255, 1}):zoomto(item_width, item_height - 1)
            if ThemePrefs.Get("VisualStyle") == "SRPG10" or ThemePrefs.Get("VisualStyle") == "Technique" then
                self:diffusealpha(0.5)
            end
        end,
		SetCommand=function(self, params)
			if params.Song then
				local song = params.Song
				local offset = round(SONGMAN:GetGroup(song):GetSyncOffset(), 3)
				if offset == -0.009 then
					self:diffuserightedge(DarkUI() and {1, 1, 1, 0.5} or {10 / 255, 20 / 255, 27 / 255, 1})
				else
					self:diffuserightedge(DarkUI() and {1, 0.5, 0.5, 0.5} or {80 / 255, 20 / 255, 27 / 255, 1})
				end
				if ThemePrefs.Get("VisualStyle") == "SRPG10" or ThemePrefs.Get("VisualStyle") == "Technique" then
					self:diffusealpha(0.5)
				end
			end
		end,
    }
}
