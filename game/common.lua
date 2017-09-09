require("textures.textures")
require("game.consts")
local common = {}

local function locate( self, x, y, xAnch, yAnch )
  self.x = x
  self.y = y
  if xAnch ~= nil then self.anchorX = xAnch end
  if yAnch ~= nil then self.anchorY = yAnch end
end

function common:newImage( textureSet, num )
  local image = display.newImage(textures[textureSet], num)
  image.height = image.height * textures.SCALE_COEF_H
  image.width = image.width * textures.SCALE_COEF_W
  image.anchorX = 0.5
  image.anchorY = 0.5
  image.locate = locate
  return image
end

function common:createBird()
  local bird = display.newSprite(textures.birdTexture, { name = "bird", frames = {2, 3, 2, 1}, loopCount = 0, time = 300})
  
  bird.xScale = textures.SCALE_COEF_H
  bird.yScale = textures.SCALE_COEF_W
  
  bird.locate = locate
  return bird
end

function common:createWall( bTop, bBottom, wallWidth )
  local wall
  local num = 5
  local spriteName = "sensor"
  local anchorY = 0.5
  
  if bTop then num = 3 elseif bBottom then num = 4 end
  if bTop then anchorY = 1 elseif bBottom then anchorY = 0 end
  if bTop or bBottom then spriteName = "wall" end
  
  wall = common:newImage( "gameTexture", num )
  
  wall.anchorY = anchorY
  wall.spriteName = spriteName
  
  if not bTop and not bBottom then 
    wall.anchorX = 0
    wall.height = ( display.contentWidth - 1.5 * wallWidth ) * 0.5
    wall.width = wallWidth * 0.5
    wall.alpha = 0
  end
  return wall
end

function common:createWallGroup( bTop, bBottom, wallWidth )
  local group = {}
    
  group.a = self:createWall( bTop, bBottom, wallWidth )
  group.b = self:createWall( bTop, bBottom, wallWidth )
  group.c = self:createWall( bTop, bBottom, wallWidth )
  
  if not wallWidth then
    group.wallWidth = group.a.width
  else
    group.wallWidth = wallWidth
  end
  group.delta = ( display.contentWidth - 1.5 * group.wallWidth ) * 0.5
  
  return group  
end

function common:addGameScreenCounter(sceneView)
  local counter = 0
  local counterSprites = display.newGroup()
  local first = display.newSprite( textures.numbersMiddleTexture, {name = "counter", start = 1, count = 10} )
  local second = display.newSprite( textures.numbersMiddleTexture, {name = "counter", start = 1, count = 10} )
  local third = display.newSprite( textures.numbersMiddleTexture, {name = "counter", start = 1, count = 10} )

  
  first.xScale = textures.SCALE_COEF_H
  first.yScale = textures.SCALE_COEF_W
  first.anchorX = 0.5
  first.anchorY = 0
  
  second.xScale = textures.SCALE_COEF_H
  second.yScale = textures.SCALE_COEF_W
  second.anchorX = 0.5
  second.anchorY = 0
  
  third.xScale = textures.SCALE_COEF_H
  third.yScale = textures.SCALE_COEF_W
  third.anchorX = 0.5
  third.anchorY = 0
  
  sceneView.counter = counter
  counterSprites[1] = first
  counterSprites[2] = second
  counterSprites[3] = third
  sceneView.counterSprites = counterSprites
  counterSprites:insert(first)
  counterSprites:insert(second)
  counterSprites:insert(third)
  sceneView:insert(counterSprites)
end

function common:addBackgroundElements(sceneView)
  local background = display.newImageRect(textures.gameTexture, 1, display.contentWidth, display.contentHeight)
  background.anchorX = 0
  background.anchorY = 0
  sceneView:insert(background)
  background:toBack()
  
  local panel = self:newImage( "gameTexture", 2 )
  panel.anchorX = 0.5
  panel.anchorY = 0
  panel.x = display.contentCenterX
  panel.y = display.contentHeight * 5 / 6
  panel.spriteName = "panel"
  sceneView.panel = panel
  sceneView:insert(panel)
  panel:toFront()
  
  local copyright = self:newImage( "textTexture", 4 )
  copyright.anchorX = 0.5
  copyright.anchorY = 0
  copyright.x = display.contentCenterX
  copyright.y = (display.contentHeight + panel.y) * 0.5
  sceneView:insert(copyright)
  copyright:toFront()
  
  local fakeTop = display.newImageRect(textures.gameTexture, 5, display.contentWidth, 20)
  fakeTop.anchorX = 0.5
  fakeTop.anchorY = 1
  fakeTop.x = display.contentCenterX
  fakeTop.y = 0
  sceneView.fakeTop = fakeTop
  sceneView:insert(fakeTop)
end
--BOUNCING TRANSITION
function common:addUpDownTransition( obj )
  obj.down = transition.to( obj, { tag = "down", time = LOGO_TIME_SHIFT, y = obj.y + LOGO_Y_SHIFT, iterations = -1,
                  transition = easing.inOutSine, 
                  onRepeat = 
                  function( obj )
                    transition.pause( obj.down )
                    obj.down.running = false
                    if ( obj.up ) then
                      transition.resume( obj.up )
                      obj.up.running = true
                    else
                      obj.up = transition.to( obj, { tag = "up", time = LOGO_TIME_SHIFT, y = obj.y - LOGO_Y_SHIFT, 
                                    iterations = -1, transition = easing.inOutSine,
                                    onRepeat = 
                                    function ( obj )
                                      transition.pause( obj.up )
                                      obj.up.running = false
                                      transition.resume( obj.down )
                                      obj.down.running = true
                                    end })
                      obj.up.running = true
                    end
                  end })
  obj.down.running = true
end

function common:removeUpDownTransition( obj )
  if obj.up then
    transition.cancel( obj.up )
    obj.up = nil
  end
  if obj.down then
    transition.cancel( obj.down )
    obj.down = nil
  end
end

function common:pauseUpDownTransition( obj )
  if obj.down and obj.down.running then
    transition.pause( obj.down )
  elseif obj.up and obj.up.running then
    transition.pause( obj.up )
  end
end

function common:resumeUpDownTransition( obj )
  if obj.down and obj.down.running then
    transition.resume( obj.down )
  elseif obj.up and obj.up.running then
    transition.resume( obj.up )
  end
end
------------------------------------------------------
common.onTapButton = function ( event )
  if event.numTaps == 1 then
    transition.cancel( event.target )
    transition.to( event.target, { time = 50, y = event.target.y + event.target.height * 0.125 } )
    transition.from( event.target, { delay = 50, time = 50, y = event.target.y + event.target.height * 0.125 } )
  end
end

return common