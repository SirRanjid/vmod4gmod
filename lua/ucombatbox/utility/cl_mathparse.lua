 /*
calculate math from a string
*/

UCombatBox.MathParse = UCombatBox.MathParse or {}
local MathParse = UCombatBox.MathParse
local charset = "%d%.%e%^%+%-%*%/%(%)"
local neg_charset = "[^"..charset.."]"
charset = "["..charset.."]"

function MathParse:Calculate(str)
	 --print(str)
	if not isstring(str) then return str end
	
	str = string.gsub(str,neg_charset,"")

	local err = RunString("UCombatBox.MathParse.cur = tonumber("..str..")","",false)

	if MathParse.cur and isnumber(MathParse.cur) then
		return MathParse.cur
	end
	return nil, err
end