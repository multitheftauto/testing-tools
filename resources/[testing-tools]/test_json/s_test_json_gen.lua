-- Copyright 2023 Multi Theft Auto
-- Use of this source code is governed by the license that can be
-- found in the LICENSE file.

local json = toJSON(testTable)

if (json) then
	local fileHandle = fileCreate("test_json.json")

	if (fileHandle) then
		fileWrite(fileHandle, json)
		fileClose(fileHandle)
	end
end
