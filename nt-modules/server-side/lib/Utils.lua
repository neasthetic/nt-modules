-----------------------------------------------------------------------------------------------------------------------------------------
-- MODULE PRINT
-----------------------------------------------------------------------------------------------------------------------------------------
function ModulePrint(Type, Message)
	
    local Colors = {
        ["Error"] = "\27[31m[ERROR]:\27[91m ",
        ["Success"] = "\27[32m[SUCESSO]:\27[92m ",
        ["Alert"] = "\27[33m[ALERTA]:\27[93m ",
        ["Debug"] = "\27[36m[DEBUG]:\27[96m ",
        ["System"] = "\27[92m[SISTEMA]:^7 ",
        ["Scheduler"] = "\27[95m[SCHEDULER]:^7 ",
    }

    local Prefix = Colors[Type] or "^7[TIPO INVÁLIDO]^7 "
    print(Prefix .. Message .. "^7")
end