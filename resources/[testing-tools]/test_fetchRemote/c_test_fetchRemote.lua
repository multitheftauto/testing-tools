-- Copyright 2023 Multi Theft Auto
-- Use of this source code is governed by the license that can be
-- found in the LICENSE file.

addEventHandler("onClientResourceStart", resourceRoot, function()
	-- request access to the test urls, which are our test pages
	requestBrowserDomains({testUrl, testAuthUrl, testFailUrl, testTimeoutUrl}, true, runFetchRemoteTests)
end)
