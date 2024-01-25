local checkConditional

function checkDistance(rActor, nodeEffect, aConditions, rTarget, aIgnore, ...)
    Debug.chat(rActor, nodeEffect, aConditions, rTarget, aIgnore)
    local isntConditional = checkConditional(rActor, nodeEffect, aConditions, rTarget, aIgnore, ...)

    for _,v in ipairs(aConditions) do
		local sLower = v:lower();
        local distanceCheck = sLower:match("^distance%s*%(([^)]+)%)$");
        if distanceCheck then
            if rTarget then
                local sourceToken = CombatManager.getTokenFromCT(rActor.sCTNode)
                local targetToken = CombatManager.getTokenFromCT(rTarget.sCTNode)
                
                Debug.chat(sourceToken, targetToken)
                local distance
                if sourceToken and targetToken then
                    
                    distance = Token.getDistanceBetween(sourceToken, targetToken)
                end
                Debug.chat(distance)
            end
        end
    end
end

function isCreatureSizeDnD3(rActor, sParam)
	if not DataCommon.creaturesize then
		return false;
	end

	local tParamSize = ActorCommonManager.internalIsCreatureSizeDnDParam(sParam);
	if not tParamSize then
		return false;
	end
	
	local nActorSize = ActorCommonManager.getCreatureSizeDnD3(rActor);

	return ActorCommonManager.internalIsCreatureSizeDnDCompare(tParamSize, nActorSize);
end

function internalIsCreatureSizeDnDParam(sParam)
	Debug.chat(sParam)
	local tParams = StringManager.splitByPattern(sParam:lower(), ",", true);

	local tParamSize = {};
	for _,sParamComp in ipairs(tParams) do
		local sParamCompLower = StringManager.trim(sParamComp):lower();
		local sParamOp = sParamCompLower:match("^[<>]?=?");
		if sParamOp then
			sParamCompLower = StringManager.trim(sParamCompLower:sub(#sParamOp + 1));
		end
		local nParamSize = DataCommon.creaturesize[sParamCompLower];
		if nParamSize then
			table.insert(tParamSize, { nParamSize = nParamSize, sParamOp = sParamOp });
		end
	end
	Debug.chat(tParamSize)
	if #tParamSize == 0 then
		return nil;
	end
	return tParamSize;
end

function internalIsCreatureSizeDnDCompare(tParamSize, nActorSize)
	for _,t in ipairs(tParamSize) do
		local bReturn;
		if t.sParamOp then
			if t.sParamOp == "<" then
				bReturn = (nActorSize < t.nParamSize);
			elseif t.sParamOp == ">" then
				bReturn = (nActorSize > t.nParamSize);
			elseif t.sParamOp == "<=" then
				bReturn = (nActorSize <= t.nParamSize);
			elseif t.sParamOp == ">=" then
				bReturn = (nActorSize >= t.nParamSize);
			else
				bReturn = (nActorSize == t.nParamSize);
			end
		else
			bReturn = (nActorSize == t.nParamSize);
		end
		if bReturn then
			return true;
		end
	end
	return false;
end

function onInit()
    checkConditional = EffectManager35E.checkConditional
    EffectManager35E.checkConditional = checkDistance
end
