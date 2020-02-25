dbEnable = true -- DO NOT CHANGE

RegisterServerEvent('checkIsLinked')
AddEventHandler('checkIsLinked', function()
    local source = source
    local player = GetPlayerName(source)
    local _id = GetDiscordID(source)
    local steam = FetchIdentifier("steam", source)

    if _id ~= false then
        print("[DiscordDB] Discord Linked Successfully for " ..player)
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3[DiscordDB] ^2Discord Account Linked Successfully!"}
        })
        TriggerClientEvent('chat:addMessage', source, {
            args = {"^3[DiscordDB] ^7Your Discord ID: ^3" .._id}
        })
    end

    if steam == false then
    	TriggerClientEvent('chat:addMessage', source, {
  			args = {
  			"^3[DiscordDB] ^8ERROR: ^1We couldnt fetch your Discord ID :c"
  			}
		})
        TriggerClientEvent('chat:addMessage', source, {
            args = {
            "^3This could be caused by the following:"
            }
        })
        TriggerClientEvent('chat:addMessage', source, {
            args = {
            "^1-> ^2You have connected without Steam open"
            }
        })
        TriggerClientEvent('chat:addMessage', source, {
            args = {
            "^1-> ^2Your Discord ID is not in our database"
            }
        })
        TriggerClientEvent('chat:addMessage', source, {
            args = {
            "^3Try restarting FiveM, making sure Steam is running before connecting!"
            }
        })
    end
end)


AddEventHandler('playerConnecting', function()
    local source = source
    local player = GetPlayerName(source)
    local steam = FetchIdentifier("steam", source)
    local discord = FetchIdentifier("discord", source)
        
    if not steam then
        print("[DiscordDB] Failed to get Steam ID for " ..player)
        return
    elseif not discord then
        print("[DiscordDB] Failed to get Discord ID for " ..player)
        return
    end

    local _id = GetDiscordID(source)

    if _id == nil or _id == false then
        InsertToIdentifiers(player, steam, discord) 
        print("[DiscordDB] Collected Identifiers for " ..player.." successfully!")
    end
end)

---------- FUNCTIONS ----------

function CreateIdentifiersTable()
    local sql = "CREATE TABLE IF NOT EXISTS `identifiers` (`steam_hex` varchar(255) PRIMARY KEY NOT NULL, `discord_id` varchar(255) NOT NULL)"
    MySQL.ready(function ()
        MySQL.Async.execute(sql, {}, function() end)       
    end)
end

if dbEnable then
    CreateIdentifiersTable()
end

function FetchIdentifier(type, source)
	local identifiers = GetPlayerIdentifiers(source)	    
    for key, value in ipairs(identifiers) do
        if string.match(value, type..":") then	
        	local identifier = string.gsub(value, type..":", "")
            return identifier
        end
    end
    return false    
end
    
function InsertToIdentifiers(player, steam, discord)
    local sql1 = "SELECT steam_hex FROM `identifiers` WHERE steam_hex=@steam"
    MySQL.Async.fetchAll(sql1, {['steam'] = steam}, function(result)
        if not result[1] then
            local sql2 = "INSERT INTO `identifiers` (`steam_hex`, `discord_id`) VALUES (@steam, @discord)"
        	MySQL.Async.execute(sql2, {['steam'] = steam, ['discord'] = discord}, function()
            	print("[DiscordDB] Inserted Identifiers for "..player.." into table 'identifiers'")
        	end)
        end 
    end)         
end
   
function GetDiscordID(source)
    local steamID = FetchIdentifier("steam", source)
    local discordID = nil;
    if steamID ~= nil then
        local sql = "SELECT discord_id FROM `identifiers` WHERE steam_hex=@steam"
        data = MySQL.Sync.fetchAll(sql, {['steam'] = steamID})
        if not rawequal(next(data), nil) then
            discordID = data[1].discord_id
            return discordID;
        else
            return false
        end       
    end
end
    

