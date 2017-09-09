--MAIN SCREEN

--buttons
START_X = function(W) return (display.contentWidth - 2 * W) / 3 end
START_Y = display.contentHeight * 5 / 6

SCORE_X = function(W) return 2 * display.contentWidth / 3 + 2 * W / 3 end
SCORE_Y = display.contentHeight * 5 / 6

--text transition
LOGO_Y_SHIFT = 20
LOGO_TIME_SHIFT = 500

MAIN_LOGO_Y = display.contentHeight / 3 - LOGO_Y_SHIFT


--GAME SCREEN

--walls
WALLS_TRANS_TIME = 4500

--bird position
BIRD_X_START = 2*display.contentWidth / 7
BIRD_Y_START = display.contentCenterY

--physics
G_GRAVITY = 9.8 * 4
V_BIRD_VELOCITY = -350

BIRD_MAX_SPEED = 250

--counter distant
NUM_DISTANT = 6


--PAUSE SCREEN

PAUSE_BACK_ALPHA = 0.6