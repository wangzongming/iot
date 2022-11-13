-- 连接 wifi
function connectWifi(ssid, pwd, successCb, errorCb, disconnectCb) 
    wifi.setmode(wifi.STATION)
    station_cfg={}
    station_cfg.ssid = ssid
    station_cfg.pwd = pwd
    --station_cfg.save = false  
    print("连接wifi："..ssid.." - "..pwd)
    wifi.sta.config(station_cfg)
end
connectWifi("test", "12345678")

-- 连接成功
connectWifiSuccess = function() 

    yPin = 2  

--  前后方向状态 front | back
    yState = "front" 
--  左右转向  "left" | "right" | "none"
    rotate = "none"
    
    domain = "http://menhechuanghb.com:3000/personControl"  

--  定时读取 IO 口
    mytimer = tmr.create()
    mytimer:register(100, tmr.ALARM_AUTO, function()   
        yVal = gpio.read(yPin)
--        print(yVal.."  "..adc.read(0))
        -- [前后] --
        if(yVal == 1) then
        -- [默认状态是向前]
            if(yState ~= "front") then
                yState = "front" 
                print("front") 
                local body = '{"type":"yState", "value":"'..yState..'"}'
                postData(domain, body, function(data) print(data) end) 
            end 
        elseif(yVal == 0) then
        -- [说明用户控制了back]
            if(yState ~= "back") then
                yState = "back" 
                print("back")
                local body = '{"type":"back", "value":"'..yState..'"}'
                postData(domain, body, function(data) print(data) end) 
            end 
        end
        
        -- [let and right] -- 
         if(adc.read(0) > 1000 ) then
            -- [向左]
            if(rotate ~= "left") then
                rotate = "left"  
                print("left")
                local body = '{"type":"rotate", "value":"'..rotate..'"}'
                postData(domain, body, function(data) print(data) end) 
            end
         elseif(adc.read(0) < 100 ) then
            -- [向右]
            if(rotate ~= "right") then
                rotate = "right"
                print("right")
                local body = '{"type":"rotate", "value":"'..rotate..'"}'
                postData(domain, body, function(data) print(data) end) 
            end
         else 
            -- [不转向]
            if(rotate ~= "none") then
                rotate = "none"
                print("none")
                local body = '{"type":"rotate", "value":"'..rotate..'"}'
                postData(domain, body, function(data) print(data) end) 
            end
         end
    end) 
    mytimer:start()
end


-- 连接失败
connectWifiError = function() 
end

-- 断开 wifi
connectWifiDisconnect = function() 
--    mytimer:unregister()
end



----  wifi 成功回调 
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T) 
    print("连接 wifi 成功")
    if(type(connectWifiSuccess) == "function") then connectWifiSuccess() end
end)

--  wifi 失败回调
wifi.eventmon.register(wifi.eventmon.STA_DHCP_TIMEOUT, function() 
    print("连接 wifi 超时") 
    if(type(connectWifiError) == "function") then connectWifiError() end
end)
    
--  wifi 断开回调
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function() 
    print("断开 wifi")
    if(type(connectWifiDisconnect) == "function") then connectWifiDisconnect() end
end)


-- 经测试，用 ip 无法请求
-- post 请求
function postData(url, body, cb)
    print("\n发出POST请求:\n"..body)  
    http.post(url, 'Content-Type: application/json\r\n', body, function(code, data)
        if (code < 0) then
          print("HTTP request failed, code:"..code)
        else 
          cb(data)
        end
    end)
end


 
