local function jsonResponse(res, status, payload)
    res.writeHead(status, { ['Content-Type'] = 'application/json; charset=utf-8' })
    res.send(json.encode(payload))
end

local function constantTimeEquals(a, b)
    if type(a) ~= 'string' or type(b) ~= 'string' or #a ~= #b then
        return false
    end
    local diff = 0
    for i = 1, #a do
        diff = diff | (string.byte(a, i) ~ string.byte(b, i))
    end
    return diff == 0
end

local function getHeader(headers, name)
    if type(headers) ~= 'table' then
        return nil
    end
    local expected = name:lower()
    for key, value in pairs(headers) do
        if type(key) == 'string' and key:lower() == expected then
            return value
        end
    end
    return nil
end

local function validCommand(command)
    if type(command) ~= 'string' or #command == 0 or #command > Config.MaxCommandBytes then
        return false
    end
    -- Controles e quebras de linha não são aceitos; cada requisição envia uma linha.
    return not command:find('[%c]')
end

SetHttpHandler(function(req, res)
    if req.path == '/health' and req.method == 'GET' then
        return jsonResponse(res, 200, { ok = true, resource = GetCurrentResourceName() })
    end
    -- Em requisições com corpo, o FXServer precisa consumi-lo antes de enviar
    -- qualquer resposta, inclusive erros de rota, método ou autenticação.
    req.setDataHandler(function(body)
        if req.path ~= '/execute' then
            return jsonResponse(res, 404, {
                error = 'not_found',
                expected = { 'GET /health', 'POST /execute' },
                received = req.method .. ' ' .. req.path,
                resource = GetCurrentResourceName()
            })
        end
        if req.method ~= 'POST' then
            return jsonResponse(res, 405, { error = 'method_not_allowed' })
        end

        local suppliedKey = getHeader(req.headers, 'x-api-key')
        if type(suppliedKey) == 'string' then
            suppliedKey = suppliedKey:match('^%s*(.-)%s*$')
        end
        if not constantTimeEquals(suppliedKey, Config.ApiKey) then
            return jsonResponse(res, 401, { error = 'unauthorized' })
        end

        if type(body) ~= 'string' or #body > Config.MaxBodyBytes then
            return jsonResponse(res, 413, { error = 'payload_too_large' })
        end

        local ok, data = pcall(json.decode, body)
        if not ok or type(data) ~= 'table' then
            return jsonResponse(res, 400, { error = 'invalid_json' })
        end

        local target = tonumber(data.playerId)
        if not target or target < 1 or target % 1 ~= 0 or GetPlayerName(target) == nil then
            return jsonResponse(res, 400, { error = 'invalid_player_id' })
        end
        if not validCommand(data.command) then
            return jsonResponse(res, 400, { error = 'invalid_command' })
        end

        TriggerClientEvent('fivem-connect:execute', target, data.command)
        return jsonResponse(res, 202, {
            ok = true,
            playerId = target,
            command = data.command,
            message = 'Comando encaminhado ao cliente.'
        })
    end)
end)

print(('API ativa na porta HTTP do FXServer (porta configurada: %d).'):format(Config.ApiPort))
print('Script Original - Fire Bots')
print('https://firerobots.com.br')
