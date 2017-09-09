local composer = require("composer")
local common = require("game.common")
require("game.consts")
local scene = composer.newScene()

local function onTapStartButton( event )
  if not event.target.taped then
    event.target.taped = true
    composer.hideOverlay("fade", 300 )
    composer.gotoScene( "game.gameScreen", {time = 300} )
  end
end

local function addFakeBackground(sceneView)
  local back = display.newImageRect(textures.gameTexture, 5, display.contentWidth, display.contentHeight)
  back.anchorX = 0
  back.anchorY = 0
  back.alpha = 0
  sceneView.back = back
  sceneView:insert(back)
end

local function addFailScreenText(sceneView)
  local failtext = common:newImage( "textTexture", 2 )
  
  failtext.anchorX = 0.5
  failtext.anchorY = 0.5
  failtext.x = display.contentCenterX
  failtext.y = display.contentHeight / 3 - LOGO_Y_SHIFT
  failtext.alpha = 0
  
  sceneView.failtext = failtext
  sceneView:insert(failtext)
end

local function addFailScreenBoard(sceneView)
  local board = common:newImage( "scoreBoardTexture", 1 )
  
  board.anchorX = 0.5
  board.anchorY = 0.5
  board.x = display.contentCenterX
  board.y = display.contentCenterY
  
  sceneView.board = board
  sceneView:insert(board)
end

local function addFailScreenButtons(sceneView)
  local startButton = common:newImage( "UITexture", 1 )
  local scoreButton = common:newImage( "UITexture", 2 )
  
  startButton.anchorX = 0
  startButton.anchorY = 1
  startButton.x = (display.contentWidth - 2 * startButton.width) / 3
  startButton.y = display.contentHeight * 5 / 6
  
  startButton.taped = false
  startButton:addEventListener( "tap", common.onTapButton )
  startButton:addEventListener( "tap", onTapStartButton )
  
  scoreButton.anchorX = 1
  scoreButton.anchorY = 1
  scoreButton.x = 2 * display.contentWidth / 3 + 2 * scoreButton.width / 3
  scoreButton.y = display.contentHeight * 5 / 6
  
  scoreButton:addEventListener( "tap", common.onTapButton )
  
  sceneView.startButton = startButton
  sceneView.scoreButton = scoreButton
  sceneView:insert(startButton)
  sceneView:insert(scoreButton)
end

local function setScreenCounter(sceneView, counter)
  local first = counter % 10
  local firstTmp = math.floor(counter/10)
  local second = firstTmp % 10
  local third = math.floor(firstTmp/10)
  local XX = display.contentCenterX + 0.5 * sceneView.board.width - 3*sceneView.counterSprites[1].width
  
  sceneView.counterSprites.x = 0
  sceneView.counterSprites.y = sceneView.board.y - 1.5 * sceneView.counterSprites[1].height
  sceneView.counterSprites[1].x = XX
  sceneView.counterSprites[1].y = 0
  sceneView.counterSprites[1]:setFrame(1)
  
  sceneView.counterSprites[2].y = 0
  sceneView.counterSprites[3].y = 0
  sceneView.counterSprites[2].alpha = 0
  sceneView.counterSprites[3].alpha = 0
  
  if third > 0 then
    sceneView.counterSprites[3]:setFrame(third + 1)
    sceneView.counterSprites[2]:setFrame(second + 1)
    sceneView.counterSprites[1]:setFrame(first + 1)
    sceneView.counterSprites[3].alpha = 1
    sceneView.counterSprites[3].x = XX - 2*NUM_DISTANT - 2*scene.view.counterSprites[3].width
    sceneView.counterSprites[2].x = XX - NUM_DISTANT - scene.view.counterSprites[3].width
--    sceneView.counterSprites[1].x = display.contentCenterX + 2*NUM_DISTANT + scene.view.counterSprites[1].width
  elseif second > 0 then
    sceneView.counterSprites[2].alpha = 1
    sceneView.counterSprites[2]:setFrame(second + 1)
    sceneView.counterSprites[1]:setFrame(first + 1)
    sceneView.counterSprites[2].x = XX - NUM_DISTANT - scene.view.counterSprites[3].width
--    sceneView.counterSprites[1].x = display.contentCenterX + NUM_DISTANT + scene.view.counterSprites[1].width * 0.5
  else
    sceneView.counterSprites[1]:setFrame(first + 1)
  end
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
  
  if (event.phase == "will") then
    event.parent.view.pauseButton.alpha = 0
    event.parent.view.counterSprites.alpha = 0
    sceneView.startButton.taped = false
    sceneView.failtext.alpha = 0
    sceneView.back.alpha = 0
    sceneView.back:toFront()
    setScreenCounter(sceneView, event.parent.view.counter)
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