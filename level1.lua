-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()
physics.setGravity( 0, 0 )

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
    system.activate( "multitouch" )

	-- create a grey rectangle as the backdrop
	local background = display.newRect( 0, 0, screenW, screenH )
	background:setFillColor( 128 )
	
	-- make a Player1 (off-screen), position it, and rotate slightly
	local player1 = display.newRect(75, 75, 40, 40 )
	player1.x, player1.y = 160, 100
    player1:setFillColor( 200 )
	
	-- add physics to the Player1
    
    -- make a Player1 (off-screen), position it, and rotate slightly
	local player2 = display.newRect(75, 75, 40, 40 )
	player2.x, player2.y = 160, 300
	player2:setFillColor( 200 )

	-- add physics to the Player1

    local player1CollisionFilter = { categoryBits = 1, maskBits = 58 } 
    local player2CollisionFilter = { categoryBits = 2, maskBits = 61 }
    local player1CreepCollisionFilter = { categoryBits = 16, maskBits = 59 }
    local player2CreepCollisionFilter = { categoryBits = 32, maskBits = 63 }
    local player1ProjectileCollisionFilter = { categoryBits = 4, maskBits = 34 }
    local borderCollisionFilter = { categoryBits = 8, maskBits = 51 }

    local p1Creeps = {}
    local p2Creeps = {}

    for i = 1, 4 do
        p1Creeps[i] = display.newRect(screenW/2-50,50+50*i,20,20)
        p1Creeps[i].x, p1Creeps[i].y = screenW/2-50, 50+50*i;
        p1Creeps[i]:setFillColor(50)
        physics.addBody( p1Creeps[i], { density=10, friction=0.3, bounce=0.3, filter=player1CreepCollisionFilter } )
        p2Creeps[i] = display.newRect(screenW/2+50,50+50*i,20,20)
        p2Creeps[i].x, p2Creeps[i].y = screenW/2+50, 50+50*i;
        p2Creeps[i]:setFillColor(250)
        physics.addBody( p2Creeps[i], { density=10, friction=0.3, bounce=0.3, filter=player2CreepCollisionFilter} )
    end

    local borderTop = display.newRect(0,0,screenW,0)
    borderTop:setFillColor( 0, 0, 0, 0)		-- make invisible
    physics.addBody(borderTop,"static", { filter=borderCollisionFilter })

    local borderBot = display.newRect(0,screenH,screenW,screenH)
    borderBot:setFillColor( 0, 0, 0, 0)		-- make invisible
    physics.addBody(borderBot,"static", { filter=borderCollisionFilter })

    local borderLeft = display.newRect(0,0,0,screenH)
    borderLeft:setFillColor( 0, 0, 0, 0)		-- make invisible
    physics.addBody(borderLeft,"static", { filter=borderCollisionFilter })

    local borderRight = display.newRect(screenW,0,screenW,screenH)
    borderRight:setFillColor( 0, 0, 0, 0)		-- make invisible
    physics.addBody(borderRight,"static", { filter=borderCollisionFilter })
	
	-- all display objects must be inserted into group

    physics.addBody( player1, { density=1.0, friction=0.3, bounce=0.3, filter = player1CollisionFilter } )
    physics.addBody( player2, { density=1.0, friction=0.3, bounce=0.3, filter = player2CollisionFilter } )

    local player1Projectiles = {}

	group:insert( background )
	group:insert( player1 )
    group:insert( player2 )

    local moveP1X = player1.x
    local moveP1Y = player1.y
    local playerSpeed = 8
    local touchSwipeBarrier = 30

    local startX
    local startY
    local destX
    local destY

    local function shootProjectile (event)
        local phase = event.phase
        if "ended" == phase then 

            local projectile = display.newRect(player1.x+2.5, player1.y+10, 5, 5 )

            local force = 20;
            local xComp = event.x - projectile.x
            local yComp = event.y - projectile.y
            local hyp = math.sqrt(math.pow(xComp,2)+math.pow(yComp,2))
            local forceX = force * xComp / hyp
            local forceY = force * yComp / hyp

            local index = #player1Projectiles + 1
            player1Projectiles[index] = projectile
   
            physics.addBody( player1Projectiles[index], { density=3.0, friction=0.5, bounce=0.05, filter=player1ProjectileCollisionFilter} )
            player1Projectiles[index]:applyForce( forceX, forceY, player1Projectiles[index].x, player1Projectiles[index].y )
        end
    end

    local function movePlayer (event)
        local phase = event.phase
        local LBX = moveP1X - 5
        local UBX = moveP1X + 5
        local LBY = moveP1Y - 5
        local UBY = moveP1Y + 5
        if player1.x > LBX and player1.x < UBX and player1.y > LBY and player1.y < UBY then
            moveP1X = player1.x
            moveP1Y = player1.y
        else 
            local xComp = moveP1X - player1.x
            local yComp = moveP1Y - player1.y
            local hyp = math.sqrt(math.pow(xComp,2)+math.pow(yComp,2))
            local speedX = playerSpeed * xComp / hyp
            local speedY = playerSpeed * yComp / hyp
            player1.x = player1.x + speedX
            player1.y = player1.y + speedY
        end
    end

    local function touchHandler (event)
        local phase = event.phase

        if phase == "began" then 
            startX = event.x
            startY = event.y
        end
        if phase == "ended" then 
            destX = event.x
            destY = event.y
            if (math.abs(destX - startX) < touchSwipeBarrier) and (math.abs(destY - startY) < touchSwipeBarrier) then 
                moveP1X = destX
                moveP1Y = destY
            else 
                moveP1X = player1.x
                moveP1Y = player1.y
                shootProjectile (event)
            end
        end
    end

    local function removeOffscreenItems (event) 
        local phase = event.phase
       	for i = 1, #player1Projectiles do
            local proj = player1Projectiles[i]
            if (proj and proj.x) then
                if proj.x < 0 or proj.x > screenW or proj.y < 0 or proj.y > screenH then 
                    proj:removeSelf()
                    table.remove( player1Projectiles, i ) 
                end
            end
        end
    end 
    
    local function enterFrameEventHandler (event)
        removeOffscreenItems(event)
        movePlayer(event)
    end

    local function onP1Collision (event) 
        local phase = event.phase

    end

    local function onP2Collision (event)
        local phase = event.phase
        if (phase == "began") then 
            for i = 1, #player1Projectiles do
                local proj = player1Projectiles[i]
                if (proj and proj.x) then
                    if (proj == event.other) then 
                        proj:removeSelf()
                        table.remove( player1Projectiles, i ) 
                        break
                    end
                end
            end
        end
    end

    player1:addEventListener( "collision", onP1Collision )
    player2:addEventListener( "collision", onP2Collision )
    background:addEventListener( "touch", touchHandler )
    Runtime:addEventListener( "enterFrame", enterFrameEventHandler )

end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	physics.start()
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	physics.stop()
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene