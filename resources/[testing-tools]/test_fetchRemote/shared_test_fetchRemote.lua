-- Copyright 2023 Multi Theft Auto
-- Use of this source code is governed by the license that can be
-- found in the LICENSE file.

testUrl, testSubstAuthUrl, testAuthUrl, testFailUrl, testTimeoutUrl = "http://curl-test-endpoint.multitheftauto.workers.dev/fetchRemote", "http://%s:%s@curl-test-endpoint.multitheftauto.workers.dev/fetchRemote-auth", "http://curl-test-endpoint.multitheftauto.workers.dev/fetchRemote-auth", "http://localhost:1234/test-fail", "http://httpstat.us/200?sleep=1000"
local testsPassed, testsFailed = 0, 0

local function callback(responseData, responseInfo, testName, expectedResponseData, expectedStatusCode, expectedSuccess, expectedHeaders, printTestResults)
	local success = true

	if (expectedResponseData) then
		success = responseData == expectedResponseData
	end

	if (success) and (type(expectedSuccess) == "boolean") then
		success = responseInfo.success == expectedSuccess
	end

	if (success) and (expectedStatusCode) then
		success = responseInfo.statusCode == expectedStatusCode
	end

	if (success) and (type(expectedHeaders) == "table") then
		for name, value in pairs(expectedHeaders) do
			if (responseInfo.headers[name] ~= value) then
				success = false
				break
			end
		end
	end

	responseData = responseData:sub(0, 16) .. (#responseData > 16 and "..." or "")
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

function runFetchRemoteFailTest()
	fetchRemote(
		testFailUrl,
		{ queueName = "tests",
			connectionAttempts = 1,
			connectTimeout = 10000 },
		callback,
		{ "runFetchRemoteFailTest", "", 7, false }
	)
end

function runFetchRemoteTimeoutTest()
	fetchRemote(
		testTimeoutUrl,
		{ queueName = "tests",
			connectionAttempts = 1,
			connectTimeout = 500 },
		callback,
		{ "runFetchRemoteTimeoutTest", "", 28, false }
	)
end

function runFetchRemoteGetTest()
	fetchRemote(
		testUrl,
		{ queueName = "tests" },
		callback,
		{ "runFetchRemoteGetTest", "[\"OK\"]", 200, true }
	)
end

function runFetchRemoteMethodGetTest()
	fetchRemote(
		testUrl,
		{ queueName = "tests",
			method = "GET" },
		callback,
		{ "runFetchRemoteMethodGetTest", "[\"OK\"]", 200, true }
	)
end

function runFetchRemoteMethodPostTest()
	fetchRemote(
		testUrl,
		{ queueName = "tests",
			method = "POST",
			headers = { ["Content-Length"] = 0 } },
		callback,
		{ "runFetchRemoteMethodPostTest", "[\"OK\"]", 200, true }
	)
end

function runFetchRemotePostDataTest()
	fetchRemote(
		testUrl,
		{ queueName = "tests",
			postData = "firstname=testfirst&lastname=testlast" },
		callback,
		{ "runFetchRemotePostDataTest", "[\"OK\"]", 200, true }
	)
end

function runFetchRemoteFormFieldsTest()
	fetchRemote(
		testUrl,
		{ queueName = "tests",
			formFields = {
				firstname = "testfirst",
				lastname = "testlast" } },
		callback,
		{ "runFetchRemoteFormFieldsTest", "[\"OK\"]", 200, true }
	)
end

function runFetchRemoteFailAuthTest()
	fetchRemote(
		testAuthUrl,
		{ queueName = "tests",
			username = "wronguser",
			password = "wrongpass" },
		callback,
		{ "runFetchRemoteFailAuthTest", "[\"ER\"]", 401, false }
	)
end

function runFetchRemoteSuccessAuthTest()
	fetchRemote(
		testAuthUrl,
		{ queueName = "tests",
			username = "correctuser",
			password = "correctpass" },
		callback,
		{ "runFetchRemoteSuccessAuthTest", "[\"OK\"]", 200, true }
	)
end

function runFetchRemoteFailSubstAuthTest()
	fetchRemote(
		testSubstAuthUrl:format("wronguser", "wrongpass"),
		{ queueName = "tests" },
		callback,
		{ "runFetchRemoteFailSubstAuthTest", "[\"ER\"]", 401, false }
	)
end

function runFetchRemoteSuccessSubstAuthTest()
	fetchRemote(
		testSubstAuthUrl:format("correctuser", "correctpass"),
		{ queueName = "tests" },
		callback,
		{ "runFetchRemoteSuccessSubstAuthTest", "[\"OK\"]", 200, true }
	)
end

function runFetchRemoteAuthWithMethodPostTest()
	fetchRemote(
		testAuthUrl,
		{ queueName = "tests",
			username = "correctuser",
			password = "correctpass",
			method = "POST",
			headers = { ["Content-Length"] = 0 } },
		callback,
		{ "runFetchRemoteAuthWithMethodPostTest", "[\"OK\"]", 200, true }
	)
end

function runFetchRemoteAuthWithPostDataTest()
	fetchRemote(
		testAuthUrl,
		{ queueName = "tests",
			username = "correctuser",
			password = "correctpass",
			postData = "firstname=testfirst&lastname=testlast" },
		callback,
		{ "runFetchRemoteAuthWithPostDataTest", "[\"OK\"]", 200, true }
	)
end

function runFetchRemoteAuthWithFormFieldsTest()
	fetchRemote(
		testAuthUrl,
		{ queueName = "tests",
			username = "correctuser",
			password = "correctpass",
			formFields = {
				firstname = "testfirst",
				lastname = "testlast" } },
		callback,
		{ "runFetchRemoteAuthWithFormFieldsTest", "[\"OK\"]", 200, true }
	)
end

function runFetchRemoteHeaderTest()
	fetchRemote(
		testUrl,
		{ queueName = "tests",
			headers = { ["X-Test-Header"] = "Works" } },
		callback,
		{ "runFetchRemoteHeaderTest", "[\"OK\"]", 200, true }
	)
end

function runFetchRemoteMethodPostHeaderTest()
	fetchRemote(
		testUrl,
		{ queueName = "tests",
			method = "POST",
			headers = {
				["Content-Length"] = 0,
				["X-Test-Header"] = "Works" } },
		callback,
		{ "runFetchRemoteMethodPostHeaderTest", "[\"OK\"]", 200, true }
	)
end

function runFetchRemotePostBinaryTest()
	local file = fileOpen("test_fetchRemote.png")
	if (file) then
		local fileData = fileRead(file, fileGetSize(file))
		fetchRemote(
			testUrl,
			{ queueName = "tests",
				method = "POST",
				postIsBinary = true,
				postData = fileData },
			callback,
			{ "runFetchRemotePostBinaryTest", fileData, 200, true, true }
		)
		fileClose(file)
	else
		outputDebugString("Test [runFetchRemotePostBinaryTest] FAILED ([test_fetchRemote.png] could not be opened)", 1)
		testsFailed = testsFailed + 1
	end
end

function runFetchRemoteTests()
	testsPassed, testsFailed = 0, 0
	runFetchRemoteFailTest()
	runFetchRemoteTimeoutTest()
	runFetchRemoteGetTest()
	runFetchRemoteMethodGetTest()
	runFetchRemoteMethodPostTest()
	runFetchRemotePostDataTest()
	runFetchRemoteFormFieldsTest()
	runFetchRemoteFailAuthTest()
	runFetchRemoteSuccessAuthTest()
	runFetchRemoteFailSubstAuthTest()
	runFetchRemoteSuccessSubstAuthTest()
	runFetchRemoteAuthWithMethodPostTest()
	runFetchRemoteAuthWithPostDataTest()
	runFetchRemoteAuthWithFormFieldsTest()
	runFetchRemoteHeaderTest()
	runFetchRemoteMethodPostHeaderTest()
	runFetchRemotePostBinaryTest()
end
