-- Geometry for one MusicWheel item in the U-shaped wheel.
local item_width = _screen.w / 3.02
local item_height = _screen.h / 16
-- section folders live against the left edge of the card
local folder_x = -item_width/2 + 6

return Def.ActorFrame{

	Def.Quad{
		InitCommand=function(self) 
			self:horizalign(center):diffuse(color("#000000")):zoomto(item_width, item_height)
			if ThemePrefs.Get("VisualStyle") == "Technique" then
				self:diffusealpha(0.5)
			end
		end
	},
	Def.Quad{
		InitCommand=function(self) 
			self:horizalign(center):diffuse(color("#4c565d")):zoomto(item_width, item_height - 1)
			if ThemePrefs.Get("VisualStyle") == "Technique" then
				self:diffusealpha(0.5)
			end
		end
	},
	Def.ActorFrame{
		Name="FolderStack",
		InitCommand=function(self)
			self:x(folder_x)
		end,
		SetCommand=function(self, params)
			local is_parent = params and params.IsParentSection
			self:GetChild("FolderBack"):visible(is_parent)
			self:GetChild("FolderFront"):visible(is_parent)
			self:GetChild("FolderMid"):visible(true):diffuse(params.Color)
			if not is_parent and params.ParentSection ~= "" then
				self:x(folder_x + 11)
			else
				self:x(folder_x)
			end
		end,
		Def.Sprite{
			Name="FolderBack",
			Texture=THEME:GetPathG("", "folder-solid.png"),
			InitCommand=function(self)
				self:horizalign(left):zoom(0.175)
				self:x(-4 + self:GetWidth()*self:GetZoom() - 8, -4)
					self:diffuse(color("#5c6972"))
			end,
			SetCommand=function(self, params)
				local is_parent = params and params.IsParentSection
				self:diffuse(color("#5c6972"))
			end
		},
		Def.Sprite{
			Name="FolderMid",
			Texture=THEME:GetPathG("", "folder-solid.png"),
			InitCommand=function(self)
				self:horizalign(left):zoom(0.175)
				self:xy( 0 + self:GetWidth()*self:GetZoom() - 8, 1 )
				self:diffuse(color("#74818b"))
			end,
			SetCommand=function(self, params)
				local is_parent = params and params.IsParentSection
				if not is_parent then
					self:diffuse(params.Color)
				else
					self:diffuse(color("#74818b"))
				end
			end,
		},
		Def.Sprite{
			Name="FolderFront",
			Texture=THEME:GetPathG("", "folder-solid.png"),
			InitCommand=function(self)
				self:horizalign(left):zoom(0.175)
				self:xy( 4 + self:GetWidth()*self:GetZoom() - 8, 2)
				self:diffuse(color("#8495a1"))
			end
		},
	},
}
