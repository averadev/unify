---------------------------------------------------------------------------------
-- Trippy Rex
-- Alberto Vera Espitia
-- Parodiux Inc.
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- OBJETOS Y VARIABLES
---------------------------------------------------------------------------------
-- Includes
require('src.Tools')
local widget = require( "widget" )
local composer = require( "composer" )
local Globals = require( "src.Globals" )
local RestManager = require( "src.RestManager" )
local fxTap = audio.loadSound( "fx/click.wav")
local fxFav = audio.loadSound( "fx/fav.wav")

-- Grupos y Contenedores
local screen, scrViewR, tools
local scene = composer.newScene()

-- Variables
local intW = display.contentWidth
local intH = display.contentHeight
local midW = display.contentWidth / 2
local midH = display.contentHeight / 2
local h = display.topStatusBarContentHeight 
local lastX = 0
local txtPName, txtPConcept, lastYP
local btnToggle1, btnToggle2

-- Arrays
local rowReward = {}
local txtBg, txtFiltro, fpRows = {}, {}, {}




---------------------------------------------------------------------------------
-- FUNCIONES
---------------------------------------------------------------------------------

-- Tap reward event
function tapReward(event)
    local t = event.target
    audio.play(fxTap)
    composer.removeScene( "src.Reward" )
    composer.gotoScene("src.Reward", { time = 400, effect = "slideLeft", params = { idReward = t.idReward } } )
end

-- Creamos lista de comercios
function setListWallet(rewards)
    lastYP = -50
    local isAvailable = true
    tools:setLoading(false)
    
    local function setInfoBar(yPosc, txtInfo)
        local bg1 = display.newRect(midW, yPosc, 462, 30 )
        bg1:setFillColor( unpack(cBlueH) )
        scrViewR:insert( bg1 )
        
        local lblInfo = display.newText({
            text = txtInfo,     
            x = 180, y = yPosc, width = 300, 
            font = fLatoBold,   
            fontSize = 17, align = "left"
        })
        lblInfo:setFillColor( unpack(cWhite) )
        scrViewR:insert( lblInfo )
    end
    
    for z = 1, #rewards, 1 do 
        
        -- Mostrar separadores
        if z == 1 then
            if rewards[z].status == "1" then
                setInfoBar(30, "Regalos obtenidos")
                lastYP = lastYP + 40
            else
                setInfoBar(30, "Regalos canjeados")
                isAvailable = false
                lastYP = lastYP + 40
            end
        elseif isAvailable then
            if not (rewards[z-1].status == rewards[z].status) then
                setInfoBar((125*z) - 50, "Regalos canjeados")
                isAvailable = false
                lastYP = lastYP + 40
            end
        end
        
        -- Contenedor del Reward
        rowReward[z] = display.newContainer( 462, 125 )
        rowReward[z]:translate( midW, lastYP + (125*z) )
        scrViewR:insert( rowReward[z] )
        
        local bg1 = display.newRect(0, 0, intW - 20, 110 )
        bg1:setFillColor( 236/255 )
        rowReward[z]:insert( bg1 )
        local bg2 = display.newRect(0, 0, intW - 24, 106 )
        bg2:setFillColor( 1 )
        rowReward[z]:insert( bg2 )
        bg2.idReward = rewards[z].id
        bg2:addEventListener( 'tap', tapReward)
        
        local img = display.newImage( rewards[z].image, system.TemporaryDirectory )
        img:translate( -180, 0 )
        img.width = 110
        img.height = 110
        rowReward[z]:insert( img )
        
        local lblCommerce = display.newText({
            text = rewards[z].commerce,     
            x = 50, y = -15, width = 300, 
            font = fLatoBold,   
            fontSize = 17, align = "left"
        })
        lblCommerce:setFillColor( .6 )
        rowReward[z]:insert( lblCommerce )
        
        local lblName = display.newText({
            text = rewards[z].name, 
            x = 50, y = 15, width = 300,
            font = fLatoRegular,   
            fontSize = 19, align = "left"
        })
        lblName:setFillColor( .3 )
        rowReward[z]:insert( lblName )
        
        -- Diseño en redimido
        if rewards[z].status == "2" then
            rowReward[z].alpha = .8
            
            local lblFecha = display.newText({
                text = rewards[z].fecha,     
                x = 120, y = -40, width = 200, 
                font = fLatoBold,   
                fontSize = 14, align = "right"
            })
            lblFecha:setFillColor( .3 )
            rowReward[z]:insert( lblFecha )
        end
        
    end
    -- Set new scroll position
    scrViewR:setScrollHeight((125 * #rewards) + lastYP + 80)
end

---------------------------------------------------------------------------------
-- DEFAULT METHODS
---------------------------------------------------------------------------------
function scene:create( event )
	screen = self.view
    
	tools = Tools:new()
    tools:buildHeader()
    tools:buildNavBar()
    tools:buildBottomBar()
    screen:insert(tools)
    
    local initY = h + 140 -- inicio en Y del worksite
    local hWorkSite = intH - (h + 220)
    
    scrViewR = widget.newScrollView
	{
		top = initY,
		left = 0,
		width = display.contentWidth,
		height = hWorkSite,
		horizontalScrollDisabled = true,
		backgroundColor = { 1 }
	}
	screen:insert(scrViewR)
    scrViewR:toBack()
    
    tools:setLoading(true, scrViewR)
    RestManager.getWallet()
    
end	
-- Called immediately after scene has moved onscreen:
function scene:show( event )
    if event.phase == "will" then 
        Globals.scenes[#Globals.scenes + 1] = composer.getSceneName( "current" ) 
    end
end

-- Remove Listener
function scene:destroy( event )
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
--scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene