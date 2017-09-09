local composer = require("composer")
local physics = require("physics")
local common = require("game.common")
require("game.consts")
local scene = composer.newScene()

local function birdEnterFrame(event)
  local vx, vy = scene.view.bird:getLinearVelocity()
  if ( vy >= BIRD_MAX_SPEED ) then
    scene.view.bird:setLinearVelocity(0, BIRD_MAX_SPEED)
  end
end

local function birdPanelCollision(event)
  if (event.phase == "began") then
    if (event.other.spriteName == "panel" or event.other.spriteName == "wall") then
      scene:endGame()
      composer.showOverlay( "game.failScreen", { isModal = true } )
    elseif event.other.spriteName == "sensor" then
      scene.view.counterSprites:setCounter( scene.view.counterSprites.counter + 1 )
    end
  end
end

local function startPhysics(sceneView)
  --physics.setDrawMode( "hybrid" )
  physics.addBody(sceneView.panel, "static", {bounce = 0})
  physics.addBody(sceneView.fakeTop, "static", {bounce = 0})
  physics.addBody(sceneView.wallsA.top, "static", {bounce = 0})
  physics.addBody(sceneView.wallsB.top, "static", {bounce = 0})
  physics.addBody(sceneView.wallsC.top, "static", {bounce = 0})
  physics.addBody(sceneView.wallsA.bottom, "static", {bounce = 0})
  physics.addBody(sceneView.wallsB.bottom, "static", {bounce = 0})
  physics.addBody(sceneView.wallsC.bottom, "static", {bounce = 0})
  physics.addBody(sceneView.wallsA.fake, "static", {isSensor=true})
  physics.addBody(sceneView.wallsB.fake, "static", {isSensor=true})
  physics.addBody(sceneView.wallsC.fake, "static", {isSensor=true})
  physics.addBody(sceneView.bird, "dynamic", { radius = sceneView.bird.contentHeight * 0.5, density = 2, bounce = 0})
  sceneView.bird:addEventListener( "collision", birdPanelCollision )
  Runtime:addEventListener( "enterFrame", birdEnterFrame )
end


local function inPauseButtonCoords( pauseButton, x, y )
  local px = pauseButton.x
  local py = pauseButton.y
  local w = pauseButton.width
  local h = pauseButton.height
  return x >= px and x <= px + w and y >= py and y <= py + h 
end

local function wallsTransition(walls, delay)
  local wwidth = walls.wallWidth
  local delta = walls.delta
  local wallStartX = display.contentWidth + wwidth * 0.5
  local wallStartY = display.contentCenterY 
  
  walls.timer = timer.performWithDelay( WALLS_TRANS_TIME + delay, 
                                        function(event)
                                          wallStartY = math.random(delta, PANEL_Y - delta)
                                        end,
                                        -1 )
  
  transition.to( walls.top, { tag = "wall", delay = delay, x = -wwidth - delta, 
                              time = WALLS_TRANS_TIME, iterations = -1,
                              onRepeat = function (wall)
                                            wall.x = wallStartX 
                                            wall.y = wallStartY - delta * 0.5  
                                         end })
  transition.to( walls.fake, { tag = "wall", delay = delay, x = -wwidth - delta, 
                               time = WALLS_TRANS_TIME, iterations = -1,
                               onRepeat = function (wall) wall.x = wallStartX; wall.y = wallStartY end })
  transition.to( walls.bottom, { tag = "wall", delay = delay, x = -wwidth - delta, 
                                 time = WALLS_TRANS_TIME, iterations = -1,
                                 onRepeat = function (wall) 
                                                wall.x = wallStartX; 
                                                wall.y = wallStartY + delta * 0.5
                                            end })
end

local function onTapScene( event )
  if event.phase == "began" and not inPauseButtonCoords( scene.view.pauseButton, event.x, event.y )  then
    if scene.view.firstTap then
      scene.view.firstTap = false
      scene:startGame()
    end
    scene.view.bird:setLinearVelocity( 0, V_BIRD_VELOCITY )
  end
end

local function onTapPauseButton(event)
  if not event.target.taped then
    event.target.taped = true
    composer.showOverlay( "game.pauseScreen", { isModal = true } )
  end
end


-- SCENE ELEMENTS CREATING

local function locateGameScreenWalls(sceneView)
  local wwidth = sceneView.wallsA.wallWidth
  local delta = sceneView.wallsA.delta
  local wallStartX = display.contentWidth + wwidth * 0.5
  local aY = math.random(delta, PANEL_Y - delta) 
  local bY = math.random(delta, PANEL_Y - delta)
  local cY = math.random(delta, PANEL_Y - delta)
  
  sceneView.wallsA.top:locate( wallStartX, aY - delta * 0.5 )
  sceneView.wallsB.top:locate( wallStartX, bY - delta * 0.5 )
  sceneView.wallsC.top:locate( wallStartX, cY - delta * 0.5 )

  sceneView.wallsA.bottom:locate( wallStartX, aY + delta * 0.5 )
  sceneView.wallsB.bottom:locate( wallStartX, bY + delta * 0.5 )
  sceneView.wallsC.bottom:locate( wallStartX, cY + delta * 0.5 )
  
  sceneView.wallsA.fake:locate( wallStartX, aY )
  sceneView.wallsB.fake:locate( wallStartX, bY )
  sceneView.wallsC.fake:locate( wallStartX, cY )
end

local function addGameScreenWalls(sceneView)
  local wallsA = {}
  local wallsB = {}
  local wallsC = {}
 
  wallsA = common:createWallGroup()
  wallsB = common:createWallGroup()
  wallsC = common:createWallGroup()
 
  sceneView.wallsA = wallsA
  sceneView.wallsB = wallsB
  sceneView.wallsC = wallsC
  sceneView:insert(wallsA.top)
  sceneView:insert(wallsA.fake)
  sceneView:insert(wallsA.bottom)
  sceneView:insert(wallsB.top)
  sceneView:insert(wallsB.fake)
  sceneView:insert(wallsB.bottom)
  sceneView:insert(wallsC.top)
  sceneView:insert(wallsC.fake)
  sceneView:insert(wallsC.bottom)  
end

local function locateGameScreenBird(sceneView)
  sceneView.bird:locate( BIRD_X_START, BIRD_Y_START - LOGO_Y_SHIFT )
  sceneView.bird.rotation = 0
end

local function addGameScreenBird(sceneView)
  local bird = common:createBird()
  
  sceneView.bird = bird
  sceneView:insert(bird)
end

local function addGameScreenButtons(sceneView)
  local pauseButton = common:newImage( "UITexture", 5 )
  
  pauseButton:locate( pauseButton.width, pauseButton.height, 0, 0 )
  
  pauseButton.taped = false
  pauseButton.spriteName = "pause"
  pauseButton:addEventListener( "tap", onTapPauseButton )

  sceneView.pauseButton = pauseButton
  sceneView:insert(pauseButton)
end

local function locateGameScreenTextElements(sceneView)
  sceneView.help:locate( display.contentCenterX, display.contentCenterY )
  sceneView.help.alpha = 1

  sceneView.text:locate( display.contentCenterX, display.contentHeight * 0.25 )
  sceneView.text.alpha = 1
end

local function addGameScreenTextElements(sceneView)
  local help = common:newImage( "textTexture", 5 )
  local text = common:newImage( "textTexture", 1)
  
  sceneView.help = help
  sceneView.text = text
  sceneView:insert(help)
  sceneView:insert(text)
end


-- START / PAUSE / RESUME / END / GAME

function scene:startGame()
  local sceneView = self.view
  
  transition.fadeOut( sceneView.text, { time = 300 } )
  transition.fadeOut( sceneView.help, { time = 300 } )
  common:removeUpDownTransition(sceneView.bird)
  wallsTransition(sceneView.wallsA, 0 )
  wallsTransition(sceneView.wallsB, WALLS_B_DELAY)
  wallsTransition(sceneView.wallsC, WALLS_C_DELAY)
  startPhysics(sceneView)
end

function scene:pauseGame()
  local sceneView = self.view
  
  sceneView.pauseButton.taped = true
  sceneView.bird:pause()
  common:pauseUpDownTransition( sceneView.bird )
  if (not sceneView.firstTap) then
    transition.pause("wall")
    timer.pause(sceneView.wallsA.timer)
    timer.pause(sceneView.wallsB.timer)
    timer.pause(sceneView.wallsC.timer)
  end
  physics.pause()
end

function scene:resumeGame()
  local sceneView = self.view
  
  sceneView.pauseButton.taped = false
  sceneView.bird:play()
  common:resumeUpDownTransition( sceneView.bird )
  if (not sceneView.firstTap) then
    transition.resume("wall")
    timer.resume(sceneView.wallsA.timer)
    timer.resume(sceneView.wallsB.timer)
    timer.resume(sceneView.wallsC.timer)
  end
  physics.start()
end

function scene:endGame()
  local sceneView = self.view
  
  self:pauseGame()
  if ( not sceneView.firstTap ) then
    timer.cancel(self.view.wallsA.timer)
    timer.cancel(self.view.wallsB.timer)
    timer.cancel(self.view.wallsC.timer)
    self.view.bird:removeEventListener( "collision", birdPanelCollision )
    Runtime:removeEventListener( "enterFrame", birdEnterFrame )
  end
end

-- SCENE LISTENERS

function scene:create(event)
  local sceneView = self.view
  
  sceneView.firstTap = true
  
  addGameScreenTextElements(sceneView)
  addGameScreenWalls(sceneView)
  addGameScreenBird(sceneView)
  addGameScreenButtons(sceneView)
  common:addGameScreenCounter(sceneView)
  common:addBackgroundElements(sceneView)
end

function scene:show(event)
  local sceneView = self.view
  
  if (event.phase == "will") then 
    locateGameScreenTextElements(sceneView)
    locateGameScreenWalls(sceneView)
    locateGameScreenBird(sceneView)
    sceneView.counterSprites:reinit( display.contentCenterX, sceneView.pauseButton.y, 0.5, 0 )
    
    sceneView.firstTap = true
    sceneView.pauseButton.taped = false
    
    composer.removeHidden(false)
    
  elseif (event.phase == "did") then
    sceneView.bird:setFrame(2)
    sceneView.bird:play()
    common:addUpDownTransition( sceneView.bird )
    Runtime:addEventListener("touch", onTapScene)
    physics.start()
    physics.setGravity( 0, G_GRAVITY )
  end
end

function scene:hide(event)
  local sceneView = self.view
  if ( event.phase == "will") then
    Runtime:removeEventListener("touch", onTapScene)
  elseif ( event.phase == "did" ) then
    sceneView.bird:pause()
    common:removeUpDownTransition( sceneView.bird )
    transition.cancel("wall")
    physics.stop()
  end
end

function scene:destroy(event)
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene