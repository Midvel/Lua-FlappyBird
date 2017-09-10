-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

composer = require("composer")
textures = require("textures.textures")
highscore = require("game.highscore")

textures:loadTexture()
highscore:loadHighscore()

composer.gotoScene("game.mainScreen")
