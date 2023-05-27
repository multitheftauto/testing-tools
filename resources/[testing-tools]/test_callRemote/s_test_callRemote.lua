-- Copyright 2023 Multi Theft Auto
-- Use of this source code is governed by the license that can be
-- found in the LICENSE file.

local testUrl, testAuthUrl, testFailUrl, testTimeoutUrl = "http://curl-test-endpoint.multitheftauto.workers.dev/callRemote", "http://%s:%s@curl-test-endpoint.multitheftauto.workers.dev/callRemote-auth", "http://localhost:1234/test-fail", "http://httpstat.us/200?sleep=1000"
local testsPassed, testsFailed = 0, 0

local function callback(responseData, errno, testName, expectedResponseData, expectedErrno, printTestResults)
	local success = false

	if (expectedResponseData) then
		success = responseData == expectedResponseData
	end

	if (success) and (expectedErrno) then
		success = errno == expectedErrno
	end

	responseData = responseData and responseData:sub(0, 16) .. (#responseData > 16 and "..." or "") or ""

	outputDebugString("Test [" .. testName .. "] " .. (success and "passed" or "FAILED"), success and 3 or 1)

	if (success) then
		testsPassed = testsPassed + 1
	else
		testsFailed = testsFailed + 1
	end

	if (expectedHeaders == true) or (printTestResults) then
		print("[" .. testsPassed .. "] tests passed; [" .. testsFailed .. "] tests failed; [" .. testsPassed + testsFailed .. "] tests conducted")
	end
end

function runCallRemoteFailTest()
	callRemote(
		testFailUrl,
		"tests",
		1,
		10000,
		function(responseData, errno)
			callback(responseData, errno, "runCallRemoteFailTest", "ERROR", 7)
		end
	)
end

function runCallRemoteTimeoutTest()
	callRemote(
		testTimeoutUrl,
		"tests",
		1,
		500,
		function(responseData, errno)
			callback(responseData, errno, "runCallRemoteTimeoutTest", "ERROR", 28)
		end
	)
end

function runCallRemoteTest()
	callRemote(
		testUrl,
		"tests",
		function(responseData, errno)
			callback(responseData, errno, "runCallRemoteTest", "OK", nil)
		end,
		"hello1",
		{ hello = "2" },
		{ 3 },
		4
	)
end

function runCallRemoteFailAuthTest()
	callRemote(
		testAuthUrl:format("wronguser", "wrongpass"),
		"tests",
		function(responseData, errno)
			callback(responseData, errno, "runCallRemoteFailAuthTest", "ERROR", 401)
		end
	)
end

function runCallRemoteSuccessAuthTest()
	callRemote(
		testAuthUrl:format("correctuser", "correctpass"),
		"tests",
		function(responseData, errno)
			callback(responseData, errno, "runCallRemoteSuccessAuthTest", "OK", nil, true)
		end,
		"hello1",
		{ hello = "2" },
		{ 3 },
		4
	)
end

function runCallRemoteTests()
	testsPassed, testsFailed = 0, 0
	runCallRemoteFailTest()
	runCallRemoteTimeoutTest()
	runCallRemoteTest()
	runCallRemoteFailAuthTest()
	runCallRemoteSuccessAuthTest()
end
addEventHandler("onResourceStart", resourceRoot, runCallRemoteTests)
