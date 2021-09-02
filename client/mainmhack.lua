ESX        = nil
searching  = false
cachedATM = {}

Config = {}
Config.CopsRequired = 0

local anycops  = 0
local oPlayer = false
local InVehicle = false
local playerpos = false

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end

Citizen.CreateThread(function()
    while(true) do
		oPlayer = GetPlayerPed(-1)
        InVehicle = IsPedInAnyVehicle(oPlayer, true)
		playerpos = GetEntityCoords(oPlayer)
        Citizen.Wait(500)
    end
end)

closestATM = {
	"prop_atm_01",
    "prop_atm_02",
    "prop_atm_03",
	"prop_fleeca_atm"
}

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(5)

		TriggerEvent("esx:getSharedObject", function(library)
			ESX = library
		end)
    end

    if ESX.IsPlayerLoaded() then
		ESX.PlayerData = ESX.GetPlayerData()
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(response)
	ESX.PlayerData = response
end)

Citizen.CreateThread(function()
    Citizen.Wait(100)
    while true do
        
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for i = 1, #closestATM do
            local x = GetClosestObjectOfType(playerCoords, 1.0, GetHashKey(closestATM[i]), false, false, false)
            local entity = nil
            if DoesEntityExist(x) then
                sleep  = 5
                entity = x
                atm   = GetEntityCoords(entity)
                drawText3D(atm.x, atm.y, atm.z + 1.6, '⚙️')		
                while IsControlPressed(0, 38) do
                drawText3D(atm.x, atm.y, atm.z + 1.5, 'Press [~g~H~s~] to hack the ATM ~s~')
				break
				end	  
                if IsControlJustReleased(0, 74) then
				ESX.TriggerServerCallback('esx_robatm:anycops', function(anycops)
				if anycops >= Config.CopsRequired then
                    if not cachedATM[entity] then
								atmheading = GetEntityHeading(entity)
								SetEntityHeading(oPlayer, atmheading)
								FreezeEntityPosition(oPlayer,true)
								ESX.ShowNotification("~g~Success - Executing!")
								searching = true
								exports.rprogress:Custom({
								Async = true,
								x = 0.5,
								y = 0.5,
								From = 0,
								To = 100,
								Duration = 5000,
								Radius = 60,
								Stroke = 10,
								MaxAngle = 360,
								Rotation = 0,
								Easing = "easeLinear",
								Label = "HACKING",
								LabelPosition = "right",
								Color = "rgba(255, 255, 255, 1.0)",
								BGColor = "rgba(107, 109, 110, 0.95)",
								Animation = {
								scenario = "PROP_HUMAN_ATM", -- https://pastebin.com/6mrYTdQv
								--animationDictionary = "missheistfbisetup1", -- https://alexguirre.github.io/animations-list/
								--animationName = "unlock_loop_janitor",
								},
								DisableControls = {
								Mouse = false,
								Player = true,
								Vehicle = true
								},
								})
								Citizen.Wait(5000)
								cachedATM[entity] = true
								local bars = math.random(4, 6)
								local timing = math.random(20, 35)
								TriggerEvent("mhacking:show")
								TriggerEvent("mhacking:start",bars,timing,mycb)
    
                    else
                        --sendNotification('You have already hacked here!', 'error', 2000)
						ESX.ShowNotification("You have already hacked here!")
                    end
				else
				ESX.ShowNotification("Not enough police!")	
                end
				end)
                break
				
				end
            else
                sleep = 1000
				
            end
        end
        Citizen.Wait(sleep)
    end
end)

function mycb(success, timeremaining)
	if success then				
								print('Success with '..timeremaining..'s remaining.')
								TriggerEvent('mhacking:hide')
								RequestAnimDict("mp_common")
								TaskPlayAnim(oPlayer, "mp_common", "givetake2_a", 8.0, 8.0, 2000, 0, 1, 0,0,0)
								TriggerServerEvent('esx_robatm:getMoney')
								Wait(3000)
								ClearPedTasks(PlayerPedId())
								FreezeEntityPosition(oPlayer,false)
								searching = false
								
    else
							print('Failure')
							TriggerEvent('mhacking:hide')
							Citizen.Wait(500)
							local ped = PlayerId(-1)
							TriggerServerEvent('esx_robatm:fail', ped)
							ESX.ShowNotification("~r~You activated the CCTV! Police were notified!")
							local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
							SetCamCoord(cam, atm.x, atm.y, atm.z + 1.6, 0)
							SetCamRot(cam, 0, 0, atmheading - 180, 2)
							RenderScriptCams(1, 0, 0, 1, 1)
							SetTimecycleModifier("scanline_cam_cheap")
							SetTimecycleModifierStrength(2.0)
							Wait(3000)
							DestroyCam(createdCamera, 0)
							RenderScriptCams(0, 0, 1, 1, 1)
							createdCamera = 0
							ClearTimecycleModifier("scanline_cam_cheap")
							SetFocusEntity(GetPlayerPed(PlayerId()))
							ClearPedTasks(PlayerPedId())
							FreezeEntityPosition(oPlayer,false)
							searching = false												
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if searching then
            DisableControlAction(0, 73) 
			DisableControlAction(0, 47)
        end
    end
end)

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end


RegisterNetEvent('esx_robatm:callCops')
AddEventHandler('esx_robatm:callCops', function(ped)
    local mugshot, mugshotStr = ESX.Game.GetPedMugshot(GetPlayerPed(ped))
	ESX.ShowAdvancedNotification('Fleeca', 'ATM hack attempt!', 'We have sent a photo of the hacker taken by the CCTV!', mugshotStr, 4)
    UnregisterPedheadshot(mugshot)
    local Atm = AddBlipForCoord(playerpos.x, playerpos.y, playerpos.z)
    SetBlipSprite(Atm , 161)
    SetBlipScale(Atm , 2.0)
    SetBlipColour(Atm, 1)
    PulseBlip(Atm)
	Wait(30*1000)
    RemoveBlip(Atm)
end)