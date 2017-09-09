local composer = require("composer")
local common = require("game.common")
require("game.consts")
local scene = composer.newScene()

-- SCENE COMMON LOGIC

local function onTapStartButton( event )
  if not event.target.taped then
    event.target.taped = true
    composer.gotoScene( "game.gameScreen", { effect = "fade", time = 300 } )
  end
end

-- SCENE ELEMENTS CREATING

local function addMainScreenButtons(sceneView)
  local startButton = common:newImage( "UITexture", 1 )
  local scoreButton = common:newImage( "UITexture", 2 )
  
  startButton:locate( START_X(startButton.width), START_Y, 0, 1 )
 
  startButton.taped = false
  startButton:addEventListener( "tap", common.onTapButton )
  startButton:addEventListener( "tap", onTapStartButton )
  
  scoreButton:locate( SCORE_X(scoreButton.width), SCORE_Y, 1, 1 )
  
  scoreButton:addEventListener( "tap", common.onTapButton )
  
  sceneView.startButton = startButton
  sceneView.scoreButton = scoreButton
  sceneView:insert(startButton)
  sceneView:insert(scoreButton)
end

local function locateMainScreenLogo(sceneView)
  local emptySpace = (display.contentWidth - sceneView.bird.width - sceneView.birdtext.width) / 5
  
  sceneView.birdtext:locate( 2 * emptySpace, MAIN_LOGO_Y )
  sceneView.bird:locate( display.contentWidth - 2 * emptySpace, MAIN_LOGO_Y )
end

local function addMainScreenLogo(sceneView)
  local birdtext = common:newImage( "textTexture", 3 )
  local bird = common:createBird()
  
  birdtext.anchorX = 0
  birdtext.anchorY = 0.5
  
  bird.anchorX = 1
  bird.anchorY = 0.5  
  
  sceneView.birdtext = birdtext
  sceneView.bird = bird
  sceneView:insert(birdtext)
  sceneView:insert(bird)
end

-- SCENE LISTENERS

function scene:create(event)
  local sceneView = self.view
  
  common:addBackgroundElements(sceneView)
  addMainScreenButtons(sceneView)
  addMainScreenLogo(sceneView)
  
end

function scene:show(event)
  local sceneView = self.view
  
  if (event.phase == "will") then
    locateMainScreenLogo(sceneView)
    sceneView.startButton.taped = false
  elseif (event.phase == "did") then
    sceneView.bird:setFrame(2)
    sceneView.bird:play()
    common:addUpDownTransition( sceneView.birdtext )
    common:addUpDownTransition( sceneView.bird )
  end
end

function scene:hide(event)
  local sceneView = self.view
  
  if ( event.phase == "did" ) then
    sceneView.bird:pause()
    common:removeUpDownTransition( sceneView.birdtext )
    common:removeUpDownTransition( sceneView.bird )
  end
end

function scene:destroy(event)
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene