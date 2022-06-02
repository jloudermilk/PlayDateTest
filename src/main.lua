-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/ui"
import "lib/AnimatedSprite.lua"


local gfx <const> = playdate.graphics
local ui <const> = playdate.ui

-- Here's our player sprite declaration. We'll scope it to this file because
-- several functions need to access it.

local playerSprite = nil
local cranked = nil
local crankAcc = 0
local crankCoolDown = 0;

ui.crankIndicator:start()
ui.crankIndicator.clockwise = true

imagetable = playdate.graphics.imagetable.new("img/bat") -- Loading imagetable from the disk
playerSprite = AnimatedSprite.new(imagetable) -- Creating AnimatedSprite instance
playerSprite:addState("glide", 1,1)
playerSprite:addState("flyup", 1, 5, {tickStep = 4})

-- A function to set up our game environment.


function myGameSetUp()

	-- Set up the player sprite.
	-- The :setCenter() call specifies that the sprite will be anchored at its center.
	-- The :moveTo() call moves our sprite to the center of the display.


	playerSprite:moveTo( 200, 120 ) -- this is where the center of the sprite is placed; (200,120) is the center of the Playdate screen
	playerSprite:add() -- This is critical!
	playerSprite:playAnimation()
	-- We want an environment displayed behind our sprite.
	-- There are generally two ways to do this:
	-- 1) Use setBackgroundDrawingCallback() to draw a background image. (This is what we're doing below.)
	-- 2) Use a tilemap, assign it to a sprite with sprite:setTilemap(tilemap),
	--       and call :setZIndex() with some low number so the background stays behind
	--       your other sprites.

	local backgroundImage = gfx.image.new( "img/background.png" )
	assert( backgroundImage )

	gfx.sprite.setBackgroundDrawingCallback(
		function( x, y, width, height )
			gfx.setClipRect( x, y, width, height ) -- let's only draw the part of the screen that's dirty
			backgroundImage:draw( 0, 0 )
			gfx.clearClipRect() -- clear so we don't interfere with drawing that comes after this
		end
	)

end

-- Now we'll call the function above to configure our game.
-- After this runs (it just runs once), nearly everything will be
-- controlled by the OS calling `playdate.update()` 30 times a second.

myGameSetUp()

-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

function playdate.update()

	-- Poll the d-pad and move our player accordingly.
	-- (There are multiple ways to read the d-pad; this is the simplest.)
	-- Note that it is possible for more than one of these directions
	-- to be pressed at once, if the user is pressing diagonally.


	
	if playdate.isCrankDocked() then
		playdate.ui.crankIndicator:update()
	else
		crankAcc = playdate.getCrankTicks(24)
	end
	
	playerSprite:update()
	gfx.sprite.update()
	playdate.timer.updateTimers()

end
function playerSprite:update()
	
	
	if playdate.buttonIsPressed( playdate.kButtonUp ) then
		playerSprite:moveBy( 0, -2 )
	end
	if playdate.buttonIsPressed( playdate.kButtonRight ) then
		playerSprite:moveBy( 2, 0 )
		playerSprite.globalFlip = gfx.kImageFlippedX
	end
	if playdate.buttonIsPressed( playdate.kButtonDown ) then
		playerSprite:moveBy( 0, 2 )
	end
	if playdate.buttonIsPressed( playdate.kButtonLeft ) then
		playerSprite:moveBy( -2, 0 )
		playerSprite.globalFlip = gfx.kImageUnflipped
	end
	if playdate.buttonIsPressed( playdate.kButtonA ) then --this doesnt work why?
		print("A down")
	end
	if crankAcc == 1 then
		print('positive')
		playerSprite:changeState("flyup")
		crankCoolDown = 0
	elseif (crankAcc == -1) then
		print('negative')
	elseif (crankCoolDown > 30) then
		playerSprite:changeState("glide")
	else
		crankCoolDown += 1
	end
	playerSprite:updateAnimation()
	playerSprite:playAnimation()
end