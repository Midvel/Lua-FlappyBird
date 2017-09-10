
local textures = {}
local TEXTURE_PATH = "textures/t.png"
local birdTextureOptions = 
{
  frames = 
  {
    {--wings down
      x = 6,
      y = 982,
      width = 34,
      height = 24
    },
    {--wings center
      x = 62,
      y = 982,
      width = 34,
      height = 24
    },
    {--wings up
      x = 118,
      y = 982,
      width = 34,
      height = 24
    }
  }
}

local textTextureOptions = 
{
  frames = 
  {
    {--get ready
      x = 584,
      y = 116,
      width = 196,
      height = 62
    },
    {--game over
      x = 784,
      y = 116,
      width = 204,
      height = 54
    },
    {--flappy bird
      x = 702,
      y = 182,
      width = 178,
      height = 48
    },
    {--copyright
      x = 884,
      y = 182,
      width = 126,
      height = 14
    },
    {--help
      x = 586, 
      y = 182, 
      width = 110, 
      height = 98
    }
  }
}

local numbersMiddleTextureOptions = 
{
  frames = 
  {
    {--0
      x = 274,
      y = 612,
      width = 14,
      height = 20
    },
    {--1
      x = 274,
      y = 954,
      width = 14,
      height = 20
    },
    {--2
      x = 274,
      y = 978,
      width = 14,
      height = 20
    },
    {--3
      x = 262,
      y = 1002,
      width = 14,
      height = 20
    },
    {--4
      x = 1004, 
      y = 0, 
      width = 14, 
      height = 20
    },
    {--5
      x = 1004, 
      y = 24, 
      width = 14, 
      height = 20
    },
    {--6
      x = 1010, 
      y = 52, 
      width = 14, 
      height = 20
    },
    {--7
      x = 1010, 
      y = 84, 
      width = 14, 
      height = 20
    },
    {--8
      x = 586, 
      y = 484, 
      width = 14, 
      height = 20
    },
    {--9
      x = 622, 
      y = 412, 
      width = 14, 
      height = 20
    }
  }
}

local UITextureOptions = 
{
  frames = 
  {
    {-- 1 start
      x = 702,
      y = 234,
      width = 116,
      height = 70
    },
    {-- 2 score
      x = 822,
      y = 234,
      width = 116,
      height = 70
    },
    {-- 3 menu
      x = 924,
      y = 52,
      width = 80,
      height = 28
    },
    {-- 4 ok
      x = 924,
      y = 84,
      width = 80,
      height = 28
    },
    {-- 5 pause
      x = 242,
      y = 612,
      width = 26,
      height = 28
    },
    {-- 6 play
      x = 668,
      y = 284,
      width = 26,
      height = 28
    }
  }
}

local gameTextureOptions = 
{
  frames = 
  {
    {-- 1 background
      x = 0,
      y = 0,
      width = 288,
      height = 512
    },
    {-- 2 panel
      x = 584,
      y = 0,
      width = 336,
      height = 112
    },
    {-- 3 wall top
      x = 112,
      y = 646,
      width = 52,
      height = 320
    },
    {-- 4 wall bottom
      x = 168,
      y = 646,
      width = 52,
      height = 320
    },
    {-- 5 fake background
      x = 584,
      y = 412,
      width = 32,
      height = 32
    }
  }
}

local scoreBoardTextureOptions = 
{
  frames = 
  {
    {-- 1 scoreboard
      x = 0,
      y = 516,
      width = 238,
      height = 126
    },
    {-- 2 new
      x = 224,
      y = 1002,
      width = 32,
      height = 14
    },
    {-- 3 bronze
      x = 224,
      y = 954,
      width = 44,
      height = 44
    },
    {-- 4 silver
      x = 224,
      y = 906,
      width = 44,
      height = 44
    },
    {-- 5 gold
      x = 242,
      y = 564,
      width = 44,
      height = 44
    },
    {-- 6 spark
      x = 276,
      y = 678,
      width = 10,
      height = 10
    },
    {-- 7 Spark
      x = 276,
      y = 734,
      width = 10,
      height = 10
    },
    {-- 8 SPARK
      x = 276,
      y = 786,
      width = 10,
      height = 10
    }
  }
}

function textures:loadTexture()
  self.SCALE_COEF_H = display.contentHeight / 512
  self.SCALE_COEF_W = display.contentWidth / 288
  self.birdTexture = graphics.newImageSheet(TEXTURE_PATH, birdTextureOptions)
  self.textTexture = graphics.newImageSheet(TEXTURE_PATH, textTextureOptions)
  self.numbersMiddleTexture = graphics.newImageSheet(TEXTURE_PATH, numbersMiddleTextureOptions)
  self.UITexture = graphics.newImageSheet(TEXTURE_PATH, UITextureOptions)
  self.gameTexture = graphics.newImageSheet(TEXTURE_PATH, gameTextureOptions)
  self.scoreBoardTexture = graphics.newImageSheet(TEXTURE_PATH, scoreBoardTextureOptions)
end

return textures