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
local storyboard = require( "storyboard" )
local Globals = require( "src.Globals" )
local RestManager = require( "src.RestManager" )
local fxTap = audio.loadSound( "fx/click.wav")
local fxFav = audio.loadSound( "fx/fav.wav")

-- Grupos y Contenedores
local screen, scrViewR, tools
local scene = storyboard.newScene()

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
function tapMessage(event)
    local t = event.target
    audio.play(fxTap)
    storyboard.removeScene( "src.Message" )
    storyboard.gotoScene("src.Message", { time = 400, effect = "slideLeft", params = { idMessage = t.idMessage } } )
end

-- Creamos lista de comercios
function setListMessages(rewards)
    lastYP = -50
    local isAvailable = true
    tools:setLoading(false)
    
    local function setInfoBar(yPosc, txtInfo)
        local bg1 = display.newRect(midW, yPosc, 462, 30 )
        bg1:setFillColor( 46/255, 190/255, 239/255 )
        scrViewR:insert( bg1 )
        
        local lblInfo = display.newText({
            text = txtInfo,     
            x = 180, y = yPosc, width = 300, 
            font = native.systemFontBold,   
            fontSize = 17, align = "left"
        })
        lblInfo:setFillColor( 1 )
        scrViewR:insert( lblInfo )
    end
    
    for z = 1, #rewards, 1 do 
        
        -- Mostrar separadores
        if z == 1 then
            if rewards[z].status == "1" then
                setInfoBar(30, "Mensajes nuevos")
                lastYP = lastYP + 40
            else
                setInfoBar(30, "Mensajes leidos")
                isAvailable = false
                lastYP = lastYP + 40
            end
        elseif isAvailable then
            if not (rewards[z-1].status == rewards[z].status) then
                setInfoBar((125*z) - 50, "Mensajes leidos")
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
        bg2.idMessage = rewards[z].id
        bg2:addEventListener( 'tap', tapMessage)
        
        local img = display.newImage("img/icon/iconMail.png")
        img:translate( -178, 0 )
        rowReward[z]:insert( img )
        
        local lblFecha = display.newText({
            text = rewards[z].fecha,     
            x = 120, y = -40, width = 200, 
            font = native.systemFontBold,   
            fontSize = 14, align = "right"
        })
        lblFecha:setFillColor( .3 )
        rowReward[z]:insert( lblFecha )
        
        local lblFrom = display.newText({
            text = "De: "..rewards[z].from,     
            x = 50, y = -15, width = 350, 
            font = native.systemFontBold,   
            fontSize = 17, align = "left"
        })
        lblFrom:setFillColor( .6 )
        rowReward[z]:insert( lblFrom )
        
        local lblName = display.newText({
            text = rewards[z].name, 
            x = 50, y = 15, width = 350,
            font = native.systemFont,   
            fontSize = 19, align = "left"
        })
        lblName:setFillColor( .3 )
        rowReward[z]:insert( lblName )
        
        -- Diseño visto
        if rewards[z].status == "2" then
            rowReward[z].alpha = .8
        end
        
    end
    -- Set new scroll position
    scrViewR:setScrollHeight((125 * #rewards) + lastYP + 80)
end

---------------------------------------------------------------------------------
-- DEFAULT METHODS
---------------------------------------------------------------------------------
function scene:createScene( event )
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
    RestManager.getMessages()
    
end	
-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    Globals.scenes[#Globals.scenes + 1] = storyboard.getCurrentSceneName()
end

-- Remove Listener
function scene:exitScene( event )
end

scene:addEventListener("createScene", scene )
scene:addEventListener("enterScene", scene )
scene:addEventListener("exitScene", scene )

return scene