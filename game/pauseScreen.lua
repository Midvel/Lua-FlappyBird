local composer = require("composer")
local common = require("game.common")
require("game.consts")
local scene = composer.newScene()

-- SCENE COMMON LOGIC

local function onTapPlayButton(event)
  if not event.target.taped then
    event.target.taped = true
    composer.hideOverlay()
  end
end

local function onTapMenuButton(event)
  if not event.target.taped then
    event.target.taped = true
    transition.cancel("wall")
    composer.gotoScene( "game.mainScreen", { effect = "fade", time = 300 } )
  end
end

-- SCENE ELEMENTS CREATING

local function addPauseBackground(sceneView)
  local back = display.newImageRect(textures.gameTexture, 5, display.contentWidth, display.contentHeight)
  back.anchorX = 0
  back.anchorY = 0
  back.alpha = PAUSE_BACK_ALPHA
  sceneView:insert(back)
end

local function addPauseScreenButtons(sceneView)
  local playButton = common:newImage( "UITexture", 6 )
  local menuButton = common:newImage( "UITexture", 3 )
  
  playButton.anchorX = 0
  playButton.anchorY = 0
  playButton.x = playButton.width
  playButton.y = playButton.height
  
  playButton.taped = false
  playButton:addEventListener( "tap", onTapPlayButton )
  
  menuButton.anchorX = 0.5
  menuButton.anchorY = 0.5
  menuButton.x = display.contentCenterX
  menuButton.y = display.contentCenterY
  
  menuButton.taped = false
  menuButton:addEventListener( "tap", onTapMenuButton )
  menuButton:addEventListener( "tap", common.onTapButton )
  
  sceneView.playButton = playButton
  sceneView.menuButton = menuButton
  sceneView:insert(playButton)
  sceneView:insert(menuButton)
end

-- SCENE LISTENERS

function scene:create(event)
  local sceneView = self.view
  
  addPauseBackground(sceneView)
  addPauseScreenButtons(sceneView)  
end

function scene:show(event)
  local sceneView = self.view
  
  if (event.phase == "will") then
    sceneView.playButton.taped = false
    sceneView.menuButton.taped = false
  elseif (event.phase == "did") then
  
  end
end

function scene:hide(event)
  local sceneView = self.view
  if ( event.phase == "will" ) then
    event.parent:resumeGame(sceneView.menuButton.taped)
  end
end

function scene:destroy(event)
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene