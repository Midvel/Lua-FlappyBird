local highscore = {}

highscore.highscore = 0

function highscore:saveScore()
  local path = system.pathForFile( "save.txt", system.DocumentsDirectory )
  local file = io.open( path, "w" )
  if file then
    file:write( tostring( self.highscore ) )
    io.close( file )
  end
  file = nil
end

function highscore:loadHighscore()
  local path = system.pathForFile( "save.txt", system.DocumentsDirectory )
  local file = io.open( path, "r" )
  if file then
    local contents = file:read( "*a" )
    if contents then self.highscore = tonumber(contents) end
    io.close( file )
  end
  self.highscore = self.highscore or 0
  file = nil
end

function highscore:update(score)
  local ret = (score > self.highscore)
  if ret then
    self.highscore = score
    timer.performWithDelay( 100, function(event) self:saveScore() end )
  end
  return ret
end

return highscore