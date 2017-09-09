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
      scene:pauseGame()
      event.target:removeEventListener( "collision", birdPanelCollision )
      Runtime:removeEventListener( "enterFrame", birdEnterFrame )
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
  physics.addBody(sceneView.wallsTop.a, "static", {bounce = 0})
  physics.addBody(sceneView.wallsTop.b, "static", {bounce = 0})
  physics.addBody(sceneView.wallsTop.c, "static", {bounce = 0})
  physics.addBody(sceneView.wallsBottom.a, "static", {bounce = 0})
  physics.addBody(sceneView.wallsBottom.b, "static", {bounce = 0})
  physics.addBody(sceneView.wallsBottom.c, "static", {bounce = 0})
  physics.addBody(sceneView.wallsFake.a, "static", {isSensor=true})
  physics.addBody(sceneView.wallsFake.b, "static", {isSensor=true})
  physics.addBody(sceneView.wallsFake.c, "static", {isSensor=true})
  physics.addBody(sceneView.bird, "dynamic", { density = 2, bounce = 0})
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

local function wallsTransition(walls)
  local wwidth = walls.wallWidth
  local delta = walls.delta
  local XX = display.contentWidth + wwidth * 0.5
  transition.to( walls.a, { tag = "wall", x = -wwidth - delta, time = WALLS_TRANS_TIME, 
                            iterations = -1,
                             onRepeat = 
                             function (wall) 
                               wall.x = XX 
                             end })
  transition.to( walls.b, { tag = "wall", delay = WALLS_TRANS_TIME / 3, x = -wwidth - delta, 
                            time = WALLS_TRANS_TIME, iterations = -1,
                             onRepeat = 
                             function (wall)
                               wall.x = XX 
                             end })
  transition.to( walls.c, { tag = "wall", delay = 2*WALLS_TRANS_TIME / 3, x = -wwidth - delta, 
                            time = WALLS_TRANS_TIME, iterations = -1,
                             onRepeat = 
                             function (wall) 
                               wall.x = XX 
                             end })

end


local function onTapScene( event )
  if event.phase == "began" and not inPauseButtonCoords( scene.view.pauseButton, event.x, event.y )  then
    if scene.view.firstTap then
      scene.view.firstTap = false
      transition.fadeOut( scene.view.text, { time = 300 } )
      transition.fadeOut( scene.view.help, { time = 300 } )
      common:removeUpDownTransition(scene.view.bird)
      wallsTransition(scene.view.wallsTop)
      wallsTransition(scene.view.wallsBottom)
      wallsTransition(scene.view.wallsFake)
      startPhysics(scene.view)
    end
    scene.view.bird:setLinearVelocity( 0, V_BIRD_VELOCITY )
  end
end

local function onTapPauseButton(event)
  if not event.target.taped then
    event.target.taped = true
    scene:pauseGame()
    composer.showOverlay( "game.pauseScreen", { isModal = true } )
  end
end

-- SCENE ELEMENTS CREATING

local function locateGameScreenWalls(sceneView)
  local wwidth = sceneView.wallsTop.wallWidth
  local delta = sceneView.wallsTop.delta
  local XX = display.contentWidth + wwidth * 0.5
  local aY = math.random(delta, sceneView.panel.y - delta) 
  local bY = math.random(delta, sceneView.panel.y - delta)
  local cY = math.random(delta, sceneView.panel.y - delta)
  
  sceneView.wallsTop.a:locate( XX, aY - delta * 0.5 )
  sceneView.wallsTop.b:locate( XX, bY - delta * 0.5 )
  sceneView.wallsTop.c:locate( XX, cY - delta * 0.5 )

  sceneView.wallsBottom.a:locate( XX, aY + delta * 0.5 )
  sceneView.wallsBottom.b:locate( XX, bY + delta * 0.5 )
  sceneView.wallsBottom.c:locate( XX, cY + delta * 0.5 )
  
  sceneView.wallsFake.a:locate( XX, aY )
  sceneView.wallsFake.b:locate( XX, bY )
  sceneView.wallsFake.c:locate( XX, cY )
end

local function addGameScreenWalls(sceneView)
  local wallsTop = {}
  local wallsBottom = {}
  local wallsFake = {}
 
  wallsTop = common:createWallGroup( true, false )
  wallsBottom = common:createWallGroup( false, true )
  wallsFake = common:createWallGroup( false, false, wallsTop.wallWidth )
 
  sceneView.wallsTop = wallsTop
  sceneView.wallsBottom = wallsBottom
  sceneView.wallsFake = wallsFake
  sceneView:insert(wallsTop.a)
  sceneView:insert(wallsTop.b)
  sceneView:insert(wallsTop.c)
  sceneView:insert(wallsBottom.a)
  sceneView:insert(wallsBottom.b)
  sceneView:insert(wallsBottom.c)
  sceneView:insert(wallsFake.a)
  sceneView:insert(wallsFake.b)
  sceneView:insert(wallsFake.c)  
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

-- PAUSE / RESUME GAME

function scene:pauseGame()
  local sceneView = self.view
  
  sceneView.pauseButton.taped = true
  sceneView.bird:pause()
  common:pauseUpDownTransition( sceneView.bird )
  if (not sceneView.firstTap) then
    transition.pause("wall")
  end
  physics.pause()
end

function scene:resumeGame(exit)
  local sceneView = self.view
  
  sceneView.pauseButton.taped = false
  sceneView.bird:play()
  common:resumeUpDownTransition( sceneView.bird )
  if (not sceneView.firstTap) then
    transition.resume("wall")
  end
  if (exit) then
    sceneView.bird:removeEventListener("collision", birdPanelCollision)
    Runtime:removeEventListener("enterFrame", birdEnterFrame)
  end
  physics.start()
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