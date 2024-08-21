


local stateblue = 0
local statewhite = 0
local statered = 0


--BLUE
--- @param gre#context mapargs
function pressblue(mapargs)
  controlToggle("blue")
  sendData("blue")
end

--WHITE
--- @param gre#context mapargs
function presswhite(mapargs)
  controlToggle("white")
  sendData("white")
end

--RED
--- @param gre#context mapargs
function pressred(mapargs)
  controlToggle("red")  
  sendData("red")
end



--TOGGLE STATUS CHECK
--- @param gre#context mapargs
function controlToggle(toggle)
 --local control = "place holder"
 local state = 0

  if (toggle == "blue") then
    stateblue = stateblue + 1  
    if (stateblue > 1) then
      stateblue = 0
    end
    state = stateblue
  elseif (toggle == "white") then
    statewhite = statewhite + 1  
    if (statewhite > 1) then
      statewhite = 0
    end
    state = statewhite
  elseif (toggle == "red") then
    statered = statered + 1  
    if (statered > 1) then
      statered = 0
    end
    state = statered
  end
  
  AnimateToggle (toggle,state)
end


--TOGGLE ANIMATION
--- @param gre#context mapargs
function AnimateToggle(toggle,state)
  local ani_step = {}
  local id = gre.animation_create(60, 1)
  local position = 0
  
  ani_step["rate"] = "linear"
  ani_step["duration"] = 70
  ani_step["key"] = "bulbs.Group_".. toggle ..".sliderPoint".. toggle ..".grd_x"
  position = gre.get_value ("bulbs.Group_".. toggle ..".sliderPoint".. toggle ..".grd_x")
  
  --SWITCH ON
  if (state == 1) then
    ani_step["from"] = position
    ani_step["to"] = position + 60
    gre.set_value("bulbs.Group_".. toggle ..".slider".. toggle ..".image","images/Rectangle_1013.png")

  --SWITCH OFF
  else
    ani_step["from"] = position
    ani_step["to"] = position - 60
    gre.set_value("bulbs.Group_".. toggle ..".slider".. toggle ..".image","images/Rectangle_101.png")
  end
  
  --RUN ANIMATION
  gre.animation_add_step(id, ani_step)
  gre.animation_trigger(id)
end


--SEND TO PYTHON BACKEND
--- @param gre#context mapargs
function sendData(color,mapargs)
  local event_name = "blink"
  local format_string = "1s0 messege"
  local data = { messege = color }
  local channel = "sbio_backend"
  gre.send_event_data(event_name,format_string,data,channel)
end


--RECEIVE FROM PYTHON BACKEND
--- @param gre#context mapargs
function ackFromBackend(mapargs)
  local event = mapargs.context_event_data
  local ackReply  = event.ack
  local data_table  = {}
  local lastmsg_table  = {}
  local selectedLed = nil   --COLOR
  local stateLed = nil      --ON-OFF
  
  --last messege received 
  lastmsg_table["bulbs.Last_msg.text"] = ackReply
  gre.set_data( lastmsg_table )

  --led state update
  selectedLed, stateLed = string.match(ackReply, "(.*)%-(.*)")

  if (stateLed == "ON") then
    gre.set_value("bulbs."..selectedLed.."_bulb_control.image","images/LedOn_"..selectedLed..".png")
    gre.set_value("bulbs.".. selectedLed .."_bulb_control.alpha",255)
  elseif (stateLed == "OFF") then
    gre.set_value("bulbs."..selectedLed.."_bulb_control.image","images/white_bulb_off.png")
    gre.set_value("bulbs.".. selectedLed .."_bulb_control.alpha",26)
  end

  
end

