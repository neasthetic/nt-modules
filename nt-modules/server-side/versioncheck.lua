------------------------------------------------------------------------------------------------------------------------
-- VERSION CHECK
------------------------------------------------------------------------------------------------------------------------
function VersionCheck()
    local Repository = "neasthetic/nt-modules"
    local Resource = GetCurrentResourceName()
    local CurrentVersion = GetResourceMetadata(Resource, 'version', 0)

    if CurrentVersion then
        CurrentVersion = CurrentVersion:match('%d%.%d+%.%d+')
    end

    if not CurrentVersion then 
        return print(("\27[37m[\27[91mERROR\27[37m] \27[91mUnable to determine current resource version for '%s' ^0"):format(Resource)) 
    end

    SetTimeout(2500, function()
        -- 1) Primeiro, buscar a versão mais recente do fxmanifest.lua (COMO VOCÊ JÁ FAZ)
        PerformHttpRequest(('https://raw.githubusercontent.com/%s/main/nt-modules/fxmanifest.lua'):format(Repository), function(status, response)
            if status ~= 200 then return end

            local LatestVersion = response:match("%sversion \"(.-)\"")
            if not LatestVersion then return end

            -- Se a versão for igual, não há update, exibir mensagem e sair.
            if LatestVersion == CurrentVersion then
                print(('[\27[92mSUCESSO\27[37m] %s version is up to date (\27[92m%s\27[37m)'):format(Resource, CurrentVersion))
                return
            end

            -- 2) Caso haja diferença, pegamos as duas versões e comparamos.
            local cv = { string.strsplit('.', CurrentVersion) }
            local lv = { string.strsplit('.', LatestVersion) }
            
            local updateNeeded = false

            for i = 1, #cv do
                local currentNum = tonumber(cv[i])
                local latestNum  = tonumber(lv[i])

                if currentNum ~= latestNum then
                    if currentNum < latestNum then
                        updateNeeded = true
                    end
                    break
                end
            end

            -- 3) Se precisar atualizar, chamamos uma função que busca o versioninfo.json e imprime as infos:
            if updateNeeded then
                print(('[\27[96mVERSION\27[37m] An update is available for %s.\nCurrent version: (\27[91m%s\27[37m)\nLatest version: (\27[92m%s\27[37m)'):format(Resource, CurrentVersion, LatestVersion))
                FetchAndPrintChangelog(Repository)
            end

        end, 'GET')
    end)
end

-- Função auxiliar para buscar o versioninfo.json e exibir dados:
function FetchAndPrintChangelog(repo)
    PerformHttpRequest(('https://raw.githubusercontent.com/%s/main/versioninfo.json'):format(repo), function(status, response)
        if status ~= 200 then 
            print("Não foi possível obter informações do changelog.")
            return
        end

        local ok, data = pcall(json.decode, response)
        if not ok then 
            print("Falha ao decodificar JSON do changelog.")
            return
        end

        -- 'data' agora tem a estrutura do seu versioninfo.json
        -- Ex: data.version e data.categories["Bugfixes"] etc.
        if not data.categories then
            print("Não há categorias definidas no changelog.")
            return
        end

        -- Exemplo de impressão semelhante ao lb-phone:
        for categoryName, items in pairs(data.categories) do
            print(("[script:%s] %s:"):format(GetCurrentResourceName(), categoryName))
            for _, desc in ipairs(items) do
                print(("[script:%s]   • %s"):format(GetCurrentResourceName(), desc))
            end
        end

    end, 'GET')
end


------------------------------------------------------------------------------------------------------------------------
-- ONRESOURCESTART
------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(1000)
        VersionCheck()
    end
end)