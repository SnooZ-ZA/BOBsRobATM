ESX = nil

TriggerEvent("esx:getSharedObject", function(response)
    ESX = response
end)

ESX.RegisterServerCallback('esx_robatm:anycops',function(source, cb)
  local anycops = 0
  local playerList = ESX.GetPlayers()
  for i=1, #playerList, 1 do
    local _source = playerList[i]
    local xPlayer = ESX.GetPlayerFromId(_source)
    local playerjob = xPlayer.job.name
    if playerjob == 'police' then
      anycops = anycops + 1
    end
  end
  cb(anycops)
end)

RegisterServerEvent('esx_robatm:getMoney')
AddEventHandler('esx_robatm:getMoney', function()
local player = ESX.GetPlayerFromId(source)
    local randomMoney = math.random(800, 2000)		
		--player.addMoney(randomMoney)
		player.addAccountMoney("black_money", randomMoney)
		TriggerClientEvent('esx:showNotification', source, "~g~Success, You hacked the ATM for $ " .. randomMoney)
end)

RegisterServerEvent('esx_robatm:fail')
AddEventHandler('esx_robatm:fail', function(ped)
	local xPlayers = ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			TriggerClientEvent('esx_robatm:callCops', xPlayers[i], ped)
		end
	end
end)