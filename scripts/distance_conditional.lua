local checkConditional

function checkDistance(rActor, nodeEffect, aConditions, rTarget, aIgnore, ...)
    Debug.chat(rActor, nodeEffect, aConditions, rTarget, aIgnore)
    local bReturn = checkConditional(rActor, nodeEffect, aConditions, rTarget, aIgnore, ...)

	if bReturn then
		for _,v in ipairs(aConditions) do
			local sLower = v:lower();
			local distanceCheck = sLower:match("^distance%s*%(([^)]+)%)$");
			if distanceCheck then
				if not isTargetDistance(rActor, rTarget, distanceCheck) then
					bReturn = false
					break;
				end
			end
		end
	end
	return bReturn
end

function isTargetDistance(rActor, rTarget, sParam)
    if not rTarget then
        return false
    end

	local tParamDistance = parseDistanceParam(sParam)
	if not tParamDistance then
		return false
	end
	
	local nDistance = getDistanceBetween(rActor, rTarget)
	if not nDistance then
		return false
	end

	return ActorCommonManager.compareDistance(tParamDistance, nDistance)
end

function parseDistanceParam(sParam)
	local tParams = StringManager.splitByPattern(sParam:lower(), ",", true);

	local tParamSize = {};
	for _,sParamComp in ipairs(tParams) do
		local sParamCompLower = StringManager.trim(sParamComp):lower();
		local sParamOp = sParamCompLower:match("^[<>]?=?");
		if sParamOp then
			sParamCompLower = StringManager.trim(sParamCompLower:sub(#sParamOp + 1));
		end
		local nParamDistance = tonumber(sParamCompLower);
		if nParamDistance then
			table.insert(tParamSize, { nParamDistance = nParamDistance, sParamOp = sParamOp });
		end
	end
	if #tParamSize == 0 then
		return nil;
	end
	return tParamSize;
end

function getDistanceBetween(source, target)
    local sourceToken, targetToken = getToken(source), getToken(target)
	if sourceToken and targetToken then
		return Token.getDistanceBetween(sourceToken, targetToken)
	end
	return nil
end

function getToken(item)
    local token = item
    if type(token) == "table" then
        token = token.sCTNode
    end
    if type(token) == "string" then
        token = CombatManager.getTokenFromCT(token)
    end
    return token
end

function compareDistance(tParamDistance, nDistance)
	for _,t in ipairs(tParamDistance) do
		local bReturn;
		if t.sParamOp then
			if t.sParamOp == "<" then
				bReturn = (nDistance < t.nParamDistance);
			elseif t.sParamOp == ">" then
				bReturn = (nDistance > t.nParamDistance);
			elseif t.sParamOp == "<=" then
				bReturn = (nDistance <= t.nParamDistance);
			elseif t.sParamOp == ">=" then
				bReturn = (nDistance >= t.nParamDistance);
			else
				bReturn = (nDistance == t.nParamDistance);
			end
		else
			bReturn = (nDistance == t.nParamDistance);
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
