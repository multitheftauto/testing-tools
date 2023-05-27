// Copyright 2023 Multi Theft Auto
// Use of this source code is governed by the license that can be
// found in the LICENSE file.

export default {
	async fetch(request) {
		const url = new URL(request.url);

		// fetchRemote and callRemote requests are supposed to set a user-agent
		if (
			!/^MTA:SA Server (?:port |\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:)\d{1,5} - See http/.test(
				request.headers.get("user-agent")
			)
		) {
			return new Response('["ER"]', {
				headers: defaultHeaders,
				status: 400,
			});
		}

		const defaultHeaders = { "www-authenticate": "Basic" };

		if (
			url.pathname.endsWith("-auth") &&
			request.headers.get("authorization") !==
				"Basic Y29ycmVjdHVzZXI6Y29ycmVjdHBhc3M=" // correctuser:correctpass
		) {
			return new Response('["ER"]', {
				headers: defaultHeaders,
				status: 401,
			});
		} else if (request.method === "POST") {
			if (
				url.pathname === "/fetchRemote" ||
				url.pathname === "/fetchRemote-auth"
			) {
				if (
					request.headers.has("x-test-header") &&
					request.headers.get("x-test-header") === "Works" &&
					parseInt(request.headers.get("content-length"), 10) === 0
				) {
					return new Response('["OK"]', {
						headers: defaultHeaders,
						status: 200,
					});
				}

				try {
					if (
						request.headers.has("content-type") &&
						request.headers
							.get("content-type")
							.startsWith("multipart/form-data")
					) {
						const formData = await request.formData();

						if (
							formData.get("firstname") === "testfirst" &&
							formData.get("lastname") === "testlast"
						) {
							return new Response('["OK"]', {
								headers: defaultHeaders,
								status: 200,
							});
						}
					} else if (
						request.headers.has("content-type") &&
						request.headers
							.get("content-type")
							.startsWith("application/octet-stream")
					) {
						const data = await request.arrayBuffer();
						const hashBuffer = await crypto.subtle.digest(
							"SHA-256",
							data
						);
						const hashArray = Array.from(
							new Uint8Array(hashBuffer)
						);
						const hashHex = hashArray
							.map((b) => b.toString(16).padStart(2, "0"))
							.join("");

						// Check that test_fetchRemote.png matches with what we expect
						if (
							data.byteLength === 366 &&
							parseInt(
								request.headers.get("content-length"),
								10
							) === data.byteLength &&
							hashHex ===
								"8c754b636778e92abc2f7a7a02ad4e7e7f76e50b0bfdc9b5f3a2069ecfe0a4e3"
						) {
							return new Response(data, {
								headers: defaultHeaders,
								status: 200,
							});
						}
					} else {
						const text = await request.text();

						if (
							!request.headers.has("content-length") ||
							parseInt(
								request.headers.get("content-length"),
								10
							) === text.length
						) {
							if (
								!text ||
								text === "firstname=testfirst&lastname=testlast"
							) {
								return new Response('["OK"]', {
									headers: defaultHeaders,
									status: 200,
								});
							}
						}
					}
				} catch (e) {
					console.error(e);
				}
			} else if (
				url.pathname === "/callRemote" ||
				url.pathname === "/callRemote-auth"
			) {
				try {
					const text = await request.text();

					if (text === '["hello1",{"hello":"2"},[3],4]') {
						return new Response('["OK"]', {
							headers: defaultHeaders,
							status: 200,
						});
					}
				} catch (e) {}
			}
		} else if (
			request.method === "GET" &&
			(url.pathname === "/fetchRemote" ||
				url.pathname === "/fetchRemote-auth")
		) {
			if (
				!request.headers.has("x-test-header") ||
				request.headers.get("x-test-header") === "Works"
			) {
				return new Response('["OK"]', {
					headers: defaultHeaders,
					status: 200,
				});
			}
		}

		return new Response('["ER"]', { headers: defaultHeaders, status: 400 });
	},
};
