-- Copyright 2023 Multi Theft Auto
-- Use of this source code is governed by the license that can be
-- found in the LICENSE file.

local testsPassed, testsFailed = 0, 0

local function report(testName, success)
	outputDebugString("Test [" .. testName .. "] " .. (success and "passed" or "FAILED"), success and 3 or 1)

	if (success) then
		testsPassed = testsPassed + 1
	else
		testsFailed = testsFailed + 1
	end
end

function runToJsonComparisonTest()
	local success = false

	local json = toJSON(testTable)

	if (json) then
		local fileHandle = fileOpen("test_json.json")

		if (fileHandle) then
			local testJson = fileRead(fileHandle, fileGetSize(fileHandle))

			success = json == testJson

			fileClose(fileHandle)
		end
	end

	report("runToJsonComparisonTest", success)
end

function runJsonTests()
	testsPassed, testsFailed = 0, 0

	runToJsonComparisonTest()

	print("[" .. testsPassed .. "] tests passed; [" .. testsFailed .. "] tests failed; [" .. testsPassed + testsFailed .. "] tests conducted")
end
addEventHandler("onResourceStart", resourceRoot, runJsonTests)
