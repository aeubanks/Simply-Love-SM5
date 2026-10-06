-- The stock Simply Love "downward cascade" entrance animation assumed the
-- MusicWheel was a full-height vertical strip on the right half of the screen.
-- The U-shaped wheel deliberately breaks that assumption, so the old cover
-- quads would be drawn in the wrong place.  Disable them for now; the wheel
-- items simply fade/animate in normally.
return Def.ActorFrame{}
