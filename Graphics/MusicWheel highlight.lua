-- The highlight for the selected MusicWheel item.  It lives at the wheel
-- origin, which is the vertex of the V (see [MusicWheel] ItemTransformFunction).
local item_width = _screen.w / 3.02
local item_height = _screen.h / 16

return Def.Quad{ InitCommand=function(self) self:horizalign(center):x(0):zoomto(item_width, item_height - 1) end }
