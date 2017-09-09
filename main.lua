-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

composer = require("composer")
textures = require("textures.textures")

textures:loadTexture()

composer.gotoScene("game.mainScreen")
