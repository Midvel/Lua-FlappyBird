require("textures.textures")
require("game.consts")
local common = {}

--[[ COMMON IMAGES CREATION FUNCTIONS ]]--

--new image wrapper

local function locate( item, x, y, xAnch, yAnch )
  item.x = x
  if y ~= nil then item.y = y end
  if xAnch ~= nil then item.anchorX = xAnch end
  if yAnch ~= nil then item.anchorY = yAnch end
end

function common:newImage( textureSet, num )
  local image = display.newImage( textures[textureSet], num )
  image.height = image.height * textures.SCALE_COEF_H
  image.width = image.width * textures.SCALE_COEF_W
  image.anchorX = 0.5
  image.anchorY = 0.5
  image.locate = locate
  return image
end

--bird sprite creating

function common:createBird()
  local bird = display.newSprite(textures.birdTexture, { name = "bird", frames = {2, 3, 2, 1}, loopCount = 0, time = 300})
  
  bird.xScale = textures.SCALE_COEF_H
  bird.yScale = textures.SCALE_COEF_W
  bird.anchorX = 0.5
  bird.anchorY = 0.5
  
  bird.locate = locate
  return bird
end


--walls creating

function common:createWall( bTop, bBottom, wallWidth )
  local wall
  local num = 5
  local spriteName = "sensor"
  local anchorY = 0.5
  
  if bTop then num = 3 elseif bBottom then num = 4 end
  if bTop then anchorY = 1 elseif bBottom then anchorY = 0 end
  if bTop or bBottom then spriteName = "wall" end
  
  wall = self:newImage( "gameTexture", num )
  
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


--Counter creating

local function initNumber( number )
  number:locate( 0, 0, 0, 0 )
  number:setFrame(1)
  number.alpha = 0
end


function common:createNumber( textureSet )
  local number = display.newSprite( textures[textureSet], {name = "counter", start = 1, count = 10} ) 
  number.xScale = textures.SCALE_COEF_H
  number.yScale = textures.SCALE_COEF_W
  number.locate = locate
  number.init = initNumber
  number:init()
  return number
end

local function reinitCounter( counter, x, y, xAnch, yAnch )
  counter.counter = 0
  counter:locate( x, y, xAnch, yAnch )
  counter[1]:init()
  counter[2]:init()
  counter[3]:init()
  counter[1].alpha = 1
end

local function setCounter( counter, num )
  counter.counter = num or counter.counter
  local countString = tostring(counter.counter)
  local i = 1
  local k = 0
  
  while tonumber(string.sub(countString, i, i)) ~= nil do
    k = tonumber(string.sub(countString, i, i))
    counter[i]:setFrame(k+1)
    counter[i].alpha = 1
    if i > 1 then 
      counter[i].x = counter[i-1].x + NUM_DISTANT + counter[i].width
    end
    i = i + 1
  end
end


function common:addGameScreenCounter(sceneView)
  local counterSprites = display.newGroup()
  local first = self:createNumber( "numbersMiddleTexture" )
  local second = self:createNumber( "numbersMiddleTexture" )
  local third = self:createNumber( "numbersMiddleTexture" )
  
  counterSprites[1] = first
  counterSprites[2] = second
  counterSprites[3] = third
  
  counterSprites.anchorChildren = true
  counterSprites.locate = locate
  counterSprites.reinit = reinitCounter
  counterSprites.setCounter = setCounter
  
  counterSprites.counter = 0
  sceneView.counterSprites = counterSprites
  
  counterSprites:insert(first)
  counterSprites:insert(second)
  counterSprites:insert(third)
  sceneView:insert(counterSprites)
end


--background creating

function common:createBackground( textureSet, num )
  local background = display.newImageRect(textures[textureSet], num, display.contentWidth, display.contentHeight)
  
  background.anchorX = 0
  background.anchorY = 0
  
  return background
end

function common:addBackgroundElements(sceneView)
  local background = self:createBackground( "gameTexture", 1 )

  sceneView:insert(background)
  background:toBack()
  
  local panel = self:newImage( "gameTexture", 2 )
  panel:locate( display.contentCenterX, display.contentHeight * 5 / 6, 0.5, 0 )
  panel.spriteName = "panel"
  sceneView.panel = panel
  sceneView:insert(panel)
  panel:toFront()
  
  local copyright = self:newImage( "textTexture", 4 )
  copyright:locate( display.contentCenterX, (display.contentHeight + panel.y) * 0.5, 0.5, 0 )
  sceneView:insert(copyright)
  copyright:toFront()
  
  local fakeTop = display.newImageRect(textures.gameTexture, 5, display.contentWidth, 20)
  locate( fakeTop, display.contentCenterX, 0, 0.5, 1 )
  sceneView.fakeTop = fakeTop
  sceneView:insert(fakeTop)
end


--[[ BOUNCING TRANSITION ]]--

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


--[[ COMMON BUTTON EFFECTS ]]--

common.onTapButton = function ( event )
  if event.numTaps == 1 then
    transition.cancel( event.target )
    transition.to( event.target, { time = 50, y = event.target.y + event.target.height * 0.125 } )
    transition.from( event.target, { delay = 50, time = 50, y = event.target.y + event.target.height * 0.125 } )
  end
end

return common