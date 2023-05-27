-- Copyright 2023 Multi Theft Auto
-- Use of this source code is governed by the license that can be
-- found in the LICENSE file.

local testsPassed, testsFailed = 0, 0

local dataToHash = "nothing up my sleeve"

local secretKey = "this is a secret key"

local secretKey16Bytes = "this is 16 bytes"

local hashTests = {
	{ algorithm = "md5", knownHash = "01fc12bd278f59e825c022b70faa97a5" },
	{ algorithm = "sha1", knownHash = "06abc74ff5b27f887fbe52e832f3da8c5a1873cb" },
	{ algorithm = "sha224", knownHash = "cd7b50a8503bedbd034522f24219bcff17c39c165adf330944494ec7" },
	{ algorithm = "sha256", knownHash = "82c26503ef633533407ec269b51c0e4089c34fcbf91e7c02f28d7e6acaae0d14" },
	{ algorithm = "sha384", knownHash = "d7653621df74ac7a8cb352b34735dcf962d21e8215c78c8f4608a77d65baedbfa11d22721b6841331e4a50046ee44705" },
	{ algorithm = "sha512", knownHash = "de62f04498e61f4f9b40c3084e5e469715d032fbcd29faf81447bd743546770effbd1a38ab7b065fd867e494b325a1f423b8ea0cb636c81123c3f3a8e742c6be" },
	{ algorithm = "hmac", options = { algorithm = "md5", key = secretKey }, knownHash = "6fc36e61fb61b35deb343a85b338f242" },
	{ algorithm = "hmac", options = { algorithm = "sha1", key = secretKey }, knownHash = "e0866bd17b09772c85f5308320c59f526fde2b51" },
	{ algorithm = "hmac", options = { algorithm = "sha224", key = secretKey }, knownHash = "64007573069f96185f1d6057d791ae377bf15b555186702075ef1029" },
	{ algorithm = "hmac", options = { algorithm = "sha256", key = secretKey }, knownHash = "c346033dc489009f42276f7abdc24af455cc680fcb8d62e80a2e60cafd63042d" },
	{ algorithm = "hmac", options = { algorithm = "sha384", key = secretKey }, knownHash = "17c9322b79ffc56bf501a38b6e2a5dd0b52df5f0ca32bc6cc54f7163b89a88912d9b4816a8ea9d694b67f29412f629b7" },
	{ algorithm = "hmac", options = { algorithm = "sha512", key = secretKey }, knownHash = "5202ca8f903d4e624af8678f5e4f7a5500e16043e45965286d12b54e563bed2498ce02430dbd1899afaeb4e1d70d82398c93919407399307b78f4dd324414d82" },
}

local encodeDecodeTests = {
	{ algorithm = "tea", knownEncode = "sccpStj4k8qIITM5IbqqEKMhOSHi1KnDW9RIRu1af889T1jLBg==", options = { key = secretKey16Bytes } },
	{ algorithm = "aes128", knownEncode = "KQOo6/KX4xmB0tGlj3Pg8sKJl9wfF3VqgqqizgWLAaE=", options = { key = secretKey16Bytes } },
	-- 4096 bit
	{ name = "rsa-4096",
		algorithm = "rsa",
		knownEncoded = base64Decode("BPpKU3onF8TYDcDdlK0A5XbLBtZv4zgfFvNMrPS5N9xjD07WSiyxqpdqP0mC4dQdiTA8fdbEX+HGVIEr3IRU+EyP8ikkc23O+Xj9bEzexu2PYmrMOPiSa44nsP/yT9Sf+G1OriZ9hUUWmZu9TSE2sR4dpWDMhP9uN3rW5iTh1FWcGBohxDRv4Q69JnXdB6agz2HrwYN5IG7nxT/VW3R5F3idsjFOANa4v4UnOgeM/sHjL5YJ01N9KMzvdrbAVMc+ZUibOOKgzaE5DkL0XNz5eLRf8t79BaCUSI827Y5jwYFDOMvu+QaGAh/8m2faojXY+3jqOOOU7WVfC/c7ukg9iv/s+ckn8Sm4iPz1oVtxfwMJQuSSdSicv0Nd+X6qEieByh3tdVaFfCv/H85BZnS41MTVB64QB+BoZ2v7zQoA7g9hyi0frBOM8F3wDnj/5omfVdpLX6dNxh+74p2MlvMnOp547PETLKFighswFEG0Bf6U6NHen7VSdDKvoFWVzOjseAdr4lpxkLaageYBqtT9bLinfG2TFnisWRrIG4EwnWOoCXFxObs853WSZ4tkGtD5oXk26wNcZwN6PmIlDFpmaMAM039xIgbU7sJ8DfVwxAtgVL28mvKxKo7/98k9sKRMvoLiv/+yF7YPq44ByJ4PRFMZ5BkVg5o3Ghi8c9muL6Y="),
		publicKey = base64Decode("MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqmP0Q+WPteKLLufX8gU1r+5JZ8JVp4HUU2DiRfTaHJJOaV2MNztzrPLxIL6Z7atNex7zk5ryiV/cpZMu5CsUJlnVLAEuzYFSaK2KK0gsSoUifWWSEQfIAFniTz0KGCNJPGnvc75aaUGeWPEa/fpTB6kWB8i5vP5JlG6LjUzlulOiM7cXraaxgc5j1oLMXqPJnZXsNE9tXEgTljnfWMXxcHd12tyuumFSy1r9+1DxnFMCXYQmmAGkvZck5WLmr7z6GXXkCaFslPOB0hGbszbHptCiqW/cOVqjsTz3JdRM0juqlDZiXbNIjGKrq6byL+cUuB7OzsBh85iKi4zQfkfCfifcWsLi6r2tBqWYt3GcGqNhFBgbSFQGlyHy+PCoNDwziCiiW+p4VuHCOBnvzMoz8hVeIixgBRfSHoUGJ/5AyQv5W+TB4SMf8bfZFGr9Nt9/ZngB2Ag9we8OjgQjPO2upZQw93CsnkQ+mP0XH3113Am7x0+KYMPXy7cTcmJK65gKs3OCi1xQxp1I7Hzp7eXaTPvX7mB6XrBOCsv3PHolItYY+KSeiLq+pvNxND4NU+/UTfYNK25XBMC9Z/Haw6Y6rRi2YfR/zG/9su/GodiRlFDWtvO7LQb9Tw5MUh9LSH4i+ebtsj501LnJ6agk5tgxWnWLFLiYtmvcaAWq93XfQV8CAwEAAQ=="),
		privateKey = base64Decode("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") },
	-- 3072 bit
	{ name = "rsa-3072",
		algorithm = "rsa",
		knownEncoded = base64Decode("OTexhK0D/IhxXPhMDlzBl+dNvifgNtlwMpaTiprdqQY/qwsYF62vF5hbGuogTUHg2GdIbmM0cvLMUJ+bfifAfLwdKLmVIMUy0qxm4Ou4Qjwfd+jssStrKc5EJjgF9t0CgwsnXcf/j+keQQ4ohged0ho2WJuKzOqHhx3ycMllSLiSSJmg5g/zAux0VLgGHPWVd80ik/gqiRbKXWJt3iNxk+UiMedgbmIOsPa0xxs8B5/mpK+UtPs7wPrbJML8uvOZ/80YjkPFuDvny7FfJZQzTPYeDzhDlal/x+SU/KbS82qkp3PFC7sKY1Ui4nDUWKv1xYxf5ABwdlb/+VkJy5THFSlm+GfIQQV+sG94qph7aa2RHugl0yjgbTVLc2e7AE8VYv7QQiddMBgwfUiaYDKAR8g0/TiFWGp8NlklNHGGic3vkkU0/0he3D9itSfIr6P5nbpFykVuhU9Ah/pvVUPN5SClwcPauXPTPo9LJxYCBeUI+NYbO1QG4fynTEIF5fc2"),
		publicKey = base64Decode("MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAudNijQ3Qr9vdVCMOKkwnrFhJJM2kQ0aG4Lfd/6aQp0nUxWhoXQTgnr3efrYE869Sjl9WWezxSjZdUfttAyZP9OpREtE7wnHNQGT2+FikfxHKud4VTIH06bxLt6+GuM0v3tuO6ZrMV+ufKQ+/msl2UYdIoCd+P5EtMKhWeV7WKO5/9TNUZ/AVhLdvcxdvaY6KoVbDtZ3TuV10lPy5602Jcl/ZGFzs/DuaJd+sWF4wKylugiLhk41Dw4uItvkvAre8R8LMgP/3Dt4nmWEIHU0VuA3yFkxtBIYgPCQDkdxB2c8ujWUmGahiwOJYZz0M2za0HgUk379x6n4q8NpjxzmmGwZ8yKjGpVIMuS9QE4WD19mKUqn+O1a8tMfct2U7mWjvfJn5B71+fh5AW7SVSxq7+6TjQgUTbYc5Mgn/UlNoGDVZmIAWWlrzwadflRxuKRAToA90vz4C+NoJnIkjJkp2+BegtzcYqBrr69k9qywhaHYRjKjRbZdfItipbAJjTE4HAgMBAAE="),
		privateKey = base64Decode("MIIG/wIBADANBgkqhkiG9w0BAQEFAASCBukwggblAgEAAoIBgQC502KNDdCv291UIw4qTCesWEkkzaRDRobgt93/ppCnSdTFaGhdBOCevd5+tgTzr1KOX1ZZ7PFKNl1R+20DJk/06lES0TvCcc1AZPb4WKR/Ecq53hVMgfTpvEu3r4a4zS/e247pmsxX658pD7+ayXZRh0igJ34/kS0wqFZ5XtYo7n/1M1Rn8BWEt29zF29pjoqhVsO1ndO5XXSU/LnrTYlyX9kYXOz8O5ol36xYXjArKW6CIuGTjUPDi4i2+S8Ct7xHwsyA//cO3ieZYQgdTRW4DfIWTG0EhiA8JAOR3EHZzy6NZSYZqGLA4lhnPQzbNrQeBSTfv3Hqfirw2mPHOaYbBnzIqMalUgy5L1AThYPX2YpSqf47Vry0x9y3ZTuZaO98mfkHvX5+HkBbtJVLGrv7pONCBRNthzkyCf9SU2gYNVmYgBZaWvPBp1+VHG4pEBOgD3S/PgL42gmciSMmSnb4F6C3NxioGuvr2T2rLCFodhGMqNFtl18i2KlsAmNMTgcCAwEAAQKCAYABrnD418QoozOofDy3k0LUo2PeCmJPHYdA50kB9C7g5KEhPCWdmdqydQNbYChBUDfOA/zTCXrRchZ8FGtTGPimPayIIA6LXt49k+xMKPksESwlbGYC8DYYG1UQD22HpIunV5M+d+Ebdo1VIMhaDTKd4Dx+/nx89MJU62EE7h+/9RCBVnqQCjMXpVVD1FV0vg5xEUjqDsiIp9jTNEo2X9g7ibR8LPMUATIO36w+jHOhIFnYoZoq7J9NWKjfBvgu7RyqDXEQ4f81uWyeo3EjWkNzuYXkJQXnLDo/NuXifY3zr7VAp7hhr4A+9VxsMW91qKe1/NqQuP00m4VhcQBjAR3s6rSG74BCNXOxiRXyxQJfLw6hw84+io+ekyTvbeqei1/tDf5xhtIo0heb+hwrOXYA/1ow2OqIfE1WSN5YjTl32hu7zVsMEndgyVaf2PZDu1c5Bv+3iOw9Fjn3PrrnBn3txZsmAVOJlCdlfj+LfESlBfd57AZ2FAI70/i0b9tOqJECgcEA8nWhC4fuPRhf4PmX6plgHD3pw9o/2uorwWXcLHwM35qXNA1f5wvGn1NGQhWjt/WlxkFkDti4jQRqE2wJ5dtEWf4dh1R+/PnFYnNlVFwwzExNKnEbumUbLacl3QT+hLHE9Uh/xl5ak8bA+QSK6hqNgq/tO6LgPUie70wlQvjY3Ltog91kNc3V0z+A8uBx1wvznPp+wqJ0B045MnCdX0kYAtwnqRsk8HCRUChS2jxbHghgeexCaImq9tApPQjl0qU/AoHBAMQ0FHBC5RvAc4LYpBdU0ayo6dCKVMtxCQKqrzb+c3ho2om0kxTf/DPcLmX4gUW9qJ108cgHIgLvnQzA4W6/+iF2Q8gCLCdj+hHBwICVMGzuc6DpBAbbHO+ztHJmQu0AWkMkyw3ig3n9hIk6/GuFeq+hIRvsLkQsjDFifX58p85wMQLlrMcU6Lj/OFkF+W4/Sbp1xdZXcnJstXH/a4yOID9BHpC11fiN30sdsKa13sWhtk07UGDNrVXR4EboVRq9OQKBwQCeEIuV/d8V218eRvmACs96ee59LTp12DYAVgyMv66Q07KBT7rW4HlzgxGJoZvjIPUa46R8fVMLM/aHhOaLAEB2PtE3WaGUAK1qunoz3go+Ffw0kBqYkLOANrjbdxcKoO4bTlFmnDqGnotNjGWXqwnYSiLpvwxbR429ybF9EMgoVtETLnDXFsKwfnTtYd81Z+hAzZl3//qOjLODK6Gc7gUGUEpW14hka66ASFmDRtfMI3/p3FmK1z0qvJg13ygdBHcCgcEArAsq3OGbusD/yP2krZy/mxImrKmP/zCoAQGgUK3AnRX8g4Gm80gRA3yP5vSIjpnnD+Lq3EZ86WwpH3TGeHG4qLzmZKybARNmxUlLPrUTWIGjPLb2w/hAoGPI2AOZre6AN548u3kjZsYKALeLfdD2qqi0uqJYU4loiSle95nhH2E7aNnyrkNEamvJgi598NFoGiuJhhD6FyIB3Otm6EH8PtsgLS51aNUmttxa+WRC6rOJgqF/MtNHqhg1/JdfgOnpAoHBAMDh5piGB+Yed32EqT+5nMjMDUEdq7FeYD/zuq5mPyzcTivWARmCrsu2kZ6YYmo5IKG057pObYxT+rR5QGlEd75MzK/yA/xewH0B/7nB32Hi/ZHIk8IQuGvDSzhL0heYtRDmqQylzLjdbrkBdE2etCRzUygtBW8apQJ51HQ3S1YSILYlnlWgaNJ9jVkx5ZJZ70cir3FRmtPKXNTnZCvrWJRrswhPd/VyGCYmvYt8FqNIygmnuTKNiPi+hCGR0QVaTA==") },
	-- 2048 bit
	{ name = "rsa-2048",
		algorithm = "rsa",
		knownEncoded = base64Decode("S+19w5/o2yg/vNFo5CXkh6wMH79xEKyUK9KBn80QOyGVACCB7+XPohBOriOg3Is9zuHoFHxzjRZdm1wz+cxPw54gpnSYNZbtChZF4op8OkN0lDuV4g38iaCwhoNZR52yghmvRDCB2ZCSPeKsflkJ4OuK4YkjpMt7SIw6zFiXPeZbtOu+9o360taLWZzXoR8Ez1mFf2l7RuJw8Y1sgoYrr10SgEvTABmk5m8I6PgH4z+onex8s2AkJnQWzdWroyLE9hmieSCyzpJWJlYQHEVMeVF/oEAcV3fglXeX++UkIRdby54h3BZqpH/zVKtq06xkdEQ/2QSsaVBsnzLKGZ5+yA=="),
		publicKey = base64Decode("MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkNPnXsaqYSPTvvyXP6KMADGj0X8VktwDF+XmxmFPCGTLpB78ETPKRMFhj+iftELNt0ZeEhvEmqafzqKia3C1dZ6/EEIjnvxRVag69F/uA3iGWi6dpYojPWJjmuBCenGKIXdBzWtHxyYMDOXuJfvGWyE4nqBYsQb5P5dWJcSN8dCUSLAoTSdXXX/KeCTJWTGs6aGUAwk2K8Pka+mM/2iImlbvj+ESsezP/g/k0NiwPvpD+XbjcJpGaQ+gnNW9CxO9R0dhEn1d++/WdNDZ/FoJZgIzmUtueufY7H+KBtY/96+32xFzPM8zmrA66LWChyBxNt/OxfBgNiQ0JyUYtnQC8QIDAQAB"),
		privateKey = base64Decode("MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCQ0+dexqphI9O+/Jc/oowAMaPRfxWS3AMX5ebGYU8IZMukHvwRM8pEwWGP6J+0Qs23Rl4SG8Sapp/OoqJrcLV1nr8QQiOe/FFVqDr0X+4DeIZaLp2liiM9YmOa4EJ6cYohd0HNa0fHJgwM5e4l+8ZbITieoFixBvk/l1YlxI3x0JRIsChNJ1ddf8p4JMlZMazpoZQDCTYrw+Rr6Yz/aIiaVu+P4RKx7M/+D+TQ2LA++kP5duNwmkZpD6Cc1b0LE71HR2ESfV3779Z00Nn8WglmAjOZS25659jsf4oG1j/3r7fbEXM8zzOasDrotYKHIHE2387F8GA2JDQnJRi2dALxAgMBAAECggEAA7DCppGdadhF3woEuKRluOOK7x2z6QgeNA+xr8BvCSG4Zrg7aBzPvKzI1afx2eAR6eerIf7/JYm1bMiMJvy6QwMGj12AFt8LG4mr5upC4GfD1Kx3a+53M2s8aofoacJW6L9nN9rR+2smx3Vcei9OQKg6DyC64dfxpgMvOMsnatAB/ul96kIemoS2rdsZIsh1MN5LFh6SmCajm8adIcOGvAY2f/g/fDDHfXdk2imZTaTnKPpzHM7lFKBZGKWI6REXLO+YG+vw9mNtcM3PgNNvWWykaDjjUCUXAUXH4C5F5vi+Xy8HeBHZ/zr4FfPtK+Z7BoUpBJVR5T3srw5Lrrf9WQKBgQDQwwoBR6q8E0BKrz/MI4FldDUkZuY2U70N2g/mFLsa9RBVoS+QMOQL74YqNHmLgYLKCdjpkPfiUYg52L9ewnj7owBGBf6QHGzfZQZPMOnlxm/9t7abHqA68p1jsSY74E9zB6p+nwNss/hcSl0Vx5pDggBFOt6Hs/qfhPiNGtSajwKBgQCxmVlhATBw4hz6VQnvH/u0F/5g1JnYfWT/SDw73Cq+9cNNQfhqN2myPLJ0xusHbH8EiAzyUppv0MuBl9eV/X2X8RzxbV56H9XFDXQJn8JHDkASL0GBV+z/akfCsyx6Pjasdpkivhd+YYLvVuino62WGWe7jmPwB44nCB4Fx9JKfwKBgCWGKVI5k5Li0veZsJn899FIphS4+kBhpOXMgHcW2trpmdoKcwY0A4mxsCf97qsIyH2Qb5DsIeJoTVg4gY2C30Q79FyhzzQQJ/GvswahACnxFUhBsW0IgDyYR3oX6YtxslY21oqUAoWTg9zy8PBtRGlGAM5w2ncB/taVjCew3u45AoGAIVF6oic99j+FXjVr+q+OYhgKQhJAlovX0ci0fCpu3opuzGSu/QZOTwDyHdRfrXHeVnRLsX5ruMR8GWDqMhpvYHz8iBKToeetDB3dAh01rmzu+jphWKmtLbG7qrxAgOKBEVPioND2yV/z14D/fsvHOhykCFzLRPG16n6sWztEqXMCgYBYccE+uvAF2VtZam345wbr9HRVJMHm+ObLrL/AKBjdWADOpxghApXL0LzrngCzEQKwS48qzOyS/xzq/92qM7XrtMXkaql52+pcXVNhpNjNy5YrIUTB3KqYH1FiWf94EEN3wQzmmQYhkfGuRCfJaWzfOAC6sKhmJpQgazL695e7GA==") },
	-- 1024 bit
	{ name = "rsa-1024",
		algorithm = "rsa",
		knownEncoded = base64Decode("TvO81kNaAHzmdxZOIwKX76SAIeJb+qsnLVGWID2x3PVXms/oqAj/j4dpYZT3x52hHS8TOkcmJY+eqnPBvBrLysCsdojCbfxR9nhGvF3PBFjtNIpRjK2J3rbTXN9JVigssU2V7QTwi4lSQRfUBt6W9+kraCszQQ8v/YIPah/vGZA="),
		publicKey = base64Decode("MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC+PYrQiqqBoE7gsk8z1vVezjfn444V6amtryYUroO0LouJFVMX/QPM8Gsmpp6G0/k6RaR+mtxlu7APrYiIgvK9wOLrehNvlm/R6dD8fye33gec3Ay9k5dEV3mmP+rPTRlpouxyCugERE+G02IaKETf6wr53/8m052v+lvuQNg0VQIDAQAB"),
		privateKey = base64Decode("MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAL49itCKqoGgTuCyTzPW9V7ON+fjjhXpqa2vJhSug7Qui4kVUxf9A8zwayamnobT+TpFpH6a3GW7sA+tiIiC8r3A4ut6E2+Wb9Hp0Px/J7feB5zcDL2Tl0RXeaY/6s9NGWmi7HIK6ARET4bTYhooRN/rCvnf/ybTna/6W+5A2DRVAgMBAAECgYA4ICH/KpnpSmlbA2A4lBeqE78Mq+b0cg58Tms2uNHka8MA+4ibUCs54EhMi+XDM3CZD4jbTUbuwLPNvE3GsJN6g0eFGiQOLV3wn/gNQZkUck3oeYQWgwmvVo/TN5DO3iuoOc6QV2P5ACdgRDXx7I4q1j52DyNvrHUIFh7MYSHaYQJBAPLsdbazxXLqv+sBKUAw/ynJwZ79P/eZf8dZSFLidT2TAfGUJsWGq9GOfIQD/Q9CYd0ImUtnqgIsyAKBKkLjuJ0CQQDIexh9fVhSXLo2usiQ0t3I7nHC2+E9jy4tVr9bC6Ev/xJCtlZktzrQn1M3XDtU7xBT0jSMeAtj8ruSV9pNf9EZAkEAjQBjcyD1wrYvn6CU6QWHliHdmQM2VelrGbLhH/sCQjNKNYbg2lZI9OHXtGj8Qhct5rZPBE2viIOltI50kU7MoQJATyGnTQEIt5m6NpgLSn6w4/qaFJvNkArP4z12Um2ItfUsNADcoOxh3q7EnfldweyKuUsjSr6nYFATEXRzyltFIQJAGAxfqZkAmJ3sNqV/9SmsU53ObNpBO+JCZEqNGiZtDJTCdnSmxHaV82uf7F9ElcHPbb34TR1B9M0Fa4kzdFD+eA==") },
	-- 515 bit
	{ name = "rsa-515",
		algorithm = "rsa",
		knownEncoded = base64Decode("JUZrCBKOxYNAS6h9OYy5yfeGtjTWTe9uctAYai+JZKyPrkWrWAL9t/8BrCh+pXEtjAm8ZhJR3jcMY/aD7Ev0Mg=="),
		publicKey = base64Decode("MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAIa5c0R8jl1jgaqtx8pW6zNEjvdS5T78Syi/OHXApzQZArcIWKqRiGa9pVagbYElUbMjPbjFrEvqVeYW1Tgqd1UCAwEAAQ=="),
		privateKey = base64Decode("MIIBUwIBADANBgkqhkiG9w0BAQEFAASCAT0wggE5AgEAAkEAhrlzRHyOXWOBqq3HylbrM0SO91LlPvxLKL84dcCnNBkCtwhYqpGIZr2lVqBtgSVRsyM9uMWsS+pV5hbVOCp3VQIDAQABAkBC/smxTvdEvYznoU9u8VY4wmkN2G0jqzZ85spe1BTRtLzn2n/7NSYTUV4xia/g+SAXmFnjJIFkp9y0yp57S/CBAiEAyfmVsui/aKqH2j0OGjhoWYGKCTUgOEcd24W68eG6J6UCIQCqwtNQg921Rzw9CjUy8nL3JrUscW9XsxhZKNwPB12B8QIgbJOWjSIf28Vo2MJftWrDdfJ0YTTFCFv6ygsfD274Yt0CIB7S6D4ib4TnhPInw46cwS/n5tBM8aJNC9ocTAzScYihAiAGvdyhmxWAB+2aRgPbFnHCkbebPhPopCJoT6lludyj/g==") },
}

local privateKey, publicKey = generateKeyPair("RSA", { size = 515 })
table.insert(encodeDecodeTests, { name = "generated rsa-515", algorithm = "rsa", publicKey = publicKey, privateKey = privateKey })

local privateKey, publicKey = generateKeyPair("RSA", { size = 1024 })
table.insert(encodeDecodeTests, { name = "generated rsa-1024", algorithm = "rsa", publicKey = publicKey, privateKey = privateKey })

local privateKey, publicKey = generateKeyPair("RSA", { size = 2048 })
table.insert(encodeDecodeTests, { name = "generated rsa-2048", algorithm = "rsa", publicKey = publicKey, privateKey = privateKey })

local privateKey, publicKey = generateKeyPair("RSA", { size = 3072 })
table.insert(encodeDecodeTests, { name = "generated rsa-3072", algorithm = "rsa", publicKey = publicKey, privateKey = privateKey })

local privateKey, publicKey = generateKeyPair("RSA", { size = 4096 })
table.insert(encodeDecodeTests, { name = "generated rsa-4096", algorithm = "rsa", publicKey = publicKey, privateKey = privateKey })

local function runTests()
	testsPassed, testsFailed = 0, 0

	local success = base64Encode(dataToHash) == "bm90aGluZyB1cCBteSBzbGVldmU="

	outputDebugString("Base64 encode " .. (success and "passed" or "FAILED"), success and 3 or 1)

	if (success) then
		testsPassed = testsPassed + 1
	else
		testsFailed = testsFailed + 1
	end

	local success = base64Decode("bm90aGluZyB1cCBteSBzbGVldmU") == dataToHash

	outputDebugString("Base64 decode " .. (success and "passed" or "FAILED"), success and 3 or 1)

	if (success) then
		testsPassed = testsPassed + 1
	else
		testsFailed = testsFailed + 1
	end

	for _, test in ipairs(hashTests) do
		local success = hash(test.algorithm, dataToHash, test.options) == test.knownHash

		outputDebugString("Hash test [" .. test.algorithm .. (test.options and "-" .. test.options.algorithm or "") .. "] " .. (success and "passed" or "FAILED"), success and 3 or 1)

		if (success) then
			testsPassed = testsPassed + 1
		else
			testsFailed = testsFailed + 1
		end
	end

	assert(secretKey16Bytes:len() == 16, "16 byte secret key must be 16 bytes long (is " .. secretKey16Bytes:len() .. ").")

	for _, test in ipairs(encodeDecodeTests) do
		if (test.knownEncoded) then
			local success = decodeString(test.algorithm, test.knownEncoded, test.options or { key = test.privateKey }) == dataToHash

			outputDebugString("Decode test [" .. (test.name or test.algorithm) .. "] " .. (success and "passed" or "FAILED"), success and 3 or 1)

			if (success) then
				testsPassed = testsPassed + 1
			else
				testsFailed = testsFailed + 1
			end
		end

		local encoded, iv = encodeString(test.algorithm, dataToHash, test.options or { key = test.publicKey })
		local options = test.options
		if (iv) then options.iv = iv end
		local success = decodeString(test.algorithm, encoded, options or { key = test.privateKey }) == dataToHash

		outputDebugString("Encode + Decode test [" .. (test.name or test.algorithm) .. "] " .. (success and "passed" or "FAILED"), success and 3 or 1)

		if (success) then
			testsPassed = testsPassed + 1
		else
			testsFailed = testsFailed + 1
		end
	end

	print("[" .. testsPassed .. "] tests passed; [" .. testsFailed .. "] tests failed; [" .. testsPassed + testsFailed .. "] tests conducted")
end
addEventHandler("onClientResourceStart", resourceRoot, runTests)
addEventHandler("onResourceStart", resourceRoot, runTests)
