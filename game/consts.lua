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
WALLS_B_DELAY = 1500 --(1/3 of total transition time)
WALLS_C_DELAY = 3000 --(2/3 of total transition time)

--bird position
BIRD_X_START = 2*display.contentWidth / 7
BIRD_Y_START = display.contentCenterY

--physics
G_GRAVITY = 9.8 * 4
V_BIRD_VELOCITY = -350

V_BIRD_UP_ANGLE = -180
V_BIRD_DOWN_ANGLE = 110

BIRD_MAX_SPEED = 250
BIRD_UP_ANGLE = -30
BIRD_DOWN_ANGLE = 90

--counter distant
NUM_DISTANT = 6


--PAUSE SCREEN

PAUSE_BACK_ALPHA = 0.6


-- COMMON

--panel
PANEL_X = display.contentCenterX
PANEL_Y = display.contentHeight * 5 / 6

--copyright
COPY_X = display.contentCenterX
COPY_Y = (display.contentHeight + PANEL_Y) * 0.5
