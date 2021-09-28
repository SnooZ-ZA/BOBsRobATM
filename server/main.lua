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

ESX.RegisterServerCallback('esx_robatm:checkItem',function(source, cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local hackItemCount = xPlayer.getInventoryItem('atmcracker').count
  cb(hackItemCount)
end)

RegisterServerEvent('esx_robatm:getMoney')
AddEventHandler('esx_robatm:getMoney', function()
local xPlayer = ESX.GetPlayerFromId(source)
    local randomMoney = math.random(800, 2000)		
		--player.addMoney(randomMoney)
		xPlayer.addAccountMoney("black_money", randomMoney)
		xPlayer.removeInventoryItem("atmcracker", 1)
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