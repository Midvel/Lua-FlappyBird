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

local function increaseCounter()
  scene.view.counter = scene.view.counter + 1
  local counter = scene.view.counter
  local first = counter % 10
  local firstTmp = math.floor(counter/10)
  local second = firstTmp % 10
  local third = math.floor(firstTmp/10)
  
  if third > 0 then
    scene.view.counterSprites[3]:setFrame(third + 1)
    scene.view.counterSprites[2]:setFrame(second + 1)
    scene.view.counterSprites[1]:setFrame(first + 1)
    scene.view.counterSprites[3].alpha = 1
    scene.view.counterSprites[3].x = display.contentCenterX - 2*NUM_DISTANT - scene.view.counterSprites[3].width
    scene.view.counterSprites[2].x = display.contentCenterX
    scene.view.counterSprites[1].x = display.contentCenterX + 2*NUM_DISTANT + scene.view.counterSprites[1].width
  elseif second > 0 then
    scene.view.counterSprites[2].alpha = 1
    scene.view.counterSprites[2]:setFrame(second + 1)
    scene.view.counterSprites[1]:setFrame(first + 1)
    scene.view.counterSprites[2].x = display.contentCenterX - NUM_DISTANT - scene.view.counterSprites[2].width * 0.5
    scene.view.counterSprites[1].x = display.contentCenterX + NUM_DISTANT + scene.view.counterSprites[1].width * 0.5
  else
    scene.view.counterSprites[1]:setFrame(first + 1)
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
      increaseCounter()
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

--LOCATING ELEMENTS
local function locateGameScreenCounter(sceneView)
  sceneView.counter = 0
  sceneView.counterSprites.x = 0
  sceneView.counterSprites.y = sceneView.pauseButton.y
  sceneView.counterSprites[1].x = display.contentCenterX
  sceneView.counterSprites[1].y = 0
  sceneView.counterSprites[1]:setFrame(1)
  
  sceneView.counterSprites[2].y = 0
  sceneView.counterSprites[3].y = 0
  sceneView.counterSprites[2].alpha = 0
  sceneView.counterSprites[3].alpha = 0
  
end

local function locateGameScreenWalls(sceneView)
  local wwidth = sceneView.wallsTop.wallWidth
  local delta = sceneView.wallsTop.delta
  local XX = display.contentWidth + wwidth * 0.5
  local aY = math.random(delta, sceneView.panel.y - delta) 
  local bY = math.random(delta, sceneView.panel.y - delta)
  local cY = math.random(delta, sceneView.panel.y - delta)
  
  sceneView.wallsTop.a.x = XX
  sceneView.wallsTop.a.y = aY - delta * 0.5

  sceneView.wallsTop.b.x = XX
  sceneView.wallsTop.b.y = bY - delta * 0.5
  
  sceneView.wallsTop.c.x = XX
  sceneView.wallsTop.c.y = cY - delta * 0.5

  sceneView.wallsBottom.a.x = XX
  sceneView.wallsBottom.a.y = aY + delta * 0.5

  sceneView.wallsBottom.b.x = XX
  sceneView.wallsBottom.b.y = bY + delta * 0.5
  
  sceneView.wallsBottom.c.x = XX
  sceneView.wallsBottom.c.y = cY + delta * 0.5
  
  sceneView.wallsFake.a.x = XX
  sceneView.wallsFake.a.y = aY

  sceneView.wallsFake.b.x = XX
  sceneView.wallsFake.b.y = bY
  
  sceneView.wallsFake.c.x = XX
  sceneView.wallsFake.c.y = cY

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
  sceneView.bird.x = BIRD_X_START
  sceneView.bird.y = BIRD_Y_START - LOGO_Y_SHIFT
  sceneView.bird.rotation = 0
end

local function addGameScreenBird(sceneView)
  local bird = display.newSprite(textures.birdTexture, { name = "bird", frames = {2, 3, 2, 1}, loopCount = 0, time = 300})
  
  bird.xScale = textures.SCALE_COEF_H
  bird.yScale = textures.SCALE_COEF_W
  bird.anchorX = 0.5
  bird.anchorY = 0.5
  
  sceneView.bird = bird
  sceneView:insert(bird)
end

local function addGameScreenButtons(sceneView)
  local pauseButton = common:newImage( "UITexture", 5 )
  
  pauseButton.anchorX = 0
  pauseButton.anchorY = 0
  pauseButton.x = pauseButton.width
  pauseButton.y = pauseButton.height
  
  pauseButton.taped = false
  pauseButton.spriteName = "pause"
  pauseButton:addEventListener( "tap", onTapPauseButton )
  
  --pauseButton:addEventListener( "tap", common.onTapButton )

  sceneView.pauseButton = pauseButton
  sceneView:insert(pauseButton)
end

local function locateGameScreenTextElements(sceneView)
  sceneView.help.x = display.contentCenterX
  sceneView.help.y = display.contentCenterY
  sceneView.help.alpha = 1

  sceneView.text.x = display.contentCenterX
  sceneView.text.y = display.contentHeight * 0.25
  sceneView.text.alpha = 1
end

local function addGameScreenTextElements(sceneView)
  local help = common:newImage( "textTexture", 5 )
  local text = common:newImage( "textTexture", 1)
  
  help.anchorX = 0.5
  help.anchorY = 0.5

  
  text.anchorX = 0.5
  text.anchorY = 0.5

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
    locateGameScreenCounter(sceneView)
    
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