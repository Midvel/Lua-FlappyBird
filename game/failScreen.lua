local composer = require("composer")
local common = require("game.common")
require("game.consts")
local scene = composer.newScene()

-- SCENE COMMON LOGIC

local function onTapStartButton( event )
  if not event.target.taped then
    event.target.taped = true
    composer.hideOverlay("fade", 300 )
    composer.gotoScene( "game.gameScreen", {time = 300} )
  end
end

local function counterOnBoard( sceneView )
  local XX = display.contentCenterX + 0.5 * sceneView.board.width - 2.5 * sceneView.counterSprites[1].width
  local YY = display.contentCenterY - sceneView.counterSprites[1].height
  return XX, YY
end


-- SCENE ELEMENTS CREATING

local function addFakeBackground(sceneView)
  local back = common:createBackground( "gameTexture", 5 )
  back.alpha = 0
  
  sceneView.back = back
  sceneView:insert(back)
end

local function addFailScreenText(sceneView)
  local failtext = common:newImage( "textTexture", 2 )
  
  failtext:locate( display.contentCenterX, display.contentHeight / 3 - LOGO_Y_SHIFT )
  
  sceneView.failtext = failtext
  sceneView:insert(failtext)
end

local function addFailScreenBoard(sceneView)
  local board = common:newImage( "scoreBoardTexture", 1 )
  
  board:locate( display.contentCenterX, display.contentCenterY )
  
  sceneView.board = board
  sceneView:insert(board)
end

local function addFailScreenButtons(sceneView)
  local startButton = common:newImage( "UITexture", 1 )
  local scoreButton = common:newImage( "UITexture", 2 )
  
  startButton:locate( START_X(startButton.width), START_Y, 0, 1) 
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


-- SCENE LISTENERS

function scene:create(event)
  local sceneView = self.view

  addFakeBackground(sceneView)
  addFailScreenText(sceneView)
  addFailScreenBoard(sceneView)
  common:addGameScreenCounter(sceneView)
  addFailScreenButtons(sceneView)  
end

function scene:show(event)
  local sceneView = self.view
  local countX, countY = counterOnBoard(sceneView)
  
  if (event.phase == "will") then
    event.parent.view.pauseButton.alpha = 0
    event.parent.view.counterSprites.alpha = 0
    
    sceneView.startButton.taped = false
    sceneView.back.alpha = 0
    sceneView.counterSprites:setCounter( event.parent.view.counterSprites.counter )
    sceneView.counterSprites:locate( countX, countY, 1 )
  elseif (event.phase == "did") then
    transition.fadeIn(sceneView.failtext, {y = sceneView.failtext.y + LOGO_Y_SHIFT, time = LOGO_TIME_SHIFT, 
                                          transition = easing.outSine})
    transition.from(sceneView.board, {y = display.contentHeight + sceneView.board.height * 0.5, time = LOGO_TIME_SHIFT,
                                      transition = easing.outSine} )
    transition.from(sceneView.counterSprites, {y = display.contentHeight + sceneView.board.height * 0.5, time = LOGO_TIME_SHIFT,
                                      transition = easing.outSine} )
  end
end

function scene:hide(event)
  local sceneView = self.view
    
  if event.phase == "will" then
    sceneView.back.alpha = 1
  elseif ( event.phase == "did" ) then
    event.parent.view.pauseButton.alpha = 1
    event.parent.view.counterSprites.alpha = 1
  end
end

function scene:destroy(event)
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene