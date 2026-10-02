RegisterNetEvent('fivem-connect:execute', function(command)
    if type(command) ~= 'string' or #command == 0 or #command > 512 or command:find('[%c]') then
        return
    end

    -- Executa como comando de console no cliente destinatário (F8).
    ExecuteCommand(command)
end)

local function message(text)
    TriggerEvent('chat:addMessage', { args = { text } })
end

local function requestControl(entity)
    if not DoesEntityExist(entity) then return false end
    local deadline = GetGameTimer() + 1500
    while not NetworkHasControlOfEntity(entity) and GetGameTimer() < deadline do
        NetworkRequestControlOfEntity(entity)
        Wait(0)
    end
    return NetworkHasControlOfEntity(entity)
end

RegisterCommand('fix', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 8.0, 0, 71) end
    if vehicle == 0 or not DoesEntityExist(vehicle) then return message('^1Nenhum veiculo proximo encontrado.') end
    if not requestControl(vehicle) then return message('^1Nao foi possivel obter controle do veiculo.') end
    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleEngineOn(vehicle, true, true, false)
    message('^2Veiculo consertado.')
end, false)

RegisterCommand('car', function(_, args)
    local modelName = args[1]
    if not modelName or not modelName:match('^[%w_]+$') then return message('^1Informe um modelo valido. Exemplo: /car adder') end
    local model = GetHashKey(modelName)
    if not IsModelInCdimage(model) or not IsModelAVehicle(model) then return message('^1Modelo de veiculo invalido: ' .. modelName) end
    RequestModel(model)
    local deadline = GetGameTimer() + 10000
    while not HasModelLoaded(model) and GetGameTimer() < deadline do Wait(0) end
    if not HasModelLoaded(model) then return message('^1Nao foi possivel carregar o modelo do veiculo.') end
    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 4.0, 0.5)
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetModelAsNoLongerNeeded(model)
    message('^2Veiculo criado: ' .. modelName)
end, false)
