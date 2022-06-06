---

excalidraw-plugin: parsed
tags: [excalidraw]

---
==⚠  Switch to EXCALIDRAW VIEW in the MORE OPTIONS menu of this document. ⚠==


# Text Elements
DCS ^XK1J9KhT

pg ^MuZvWHAY

bot ^QGhcen6S

pg ^SsUF44fZ

bot ^NzguyGNN

pg ^Vbqnc48L

bot ^fAYk672X

pg ^sKn6RWXZ

patroni ^2ytUCclR

primary ^Y1HWnMyp

standby ^yKbxlkcD

standby ^s1XBLJYE

follower ^FFzJuyjV

candidate ^6BEIKKp5

leader ^CQVFm8hH

经过election timeout，
没有收到其他的邀请选举信息
可以从follower变成candidate ^vBM28SjB

收到最多的选举票数成为leader ^WG9dHKQs

成为candidate为自己投票 ^FBpuDcDn

follower收到投票的请求，会重置election timeout ^U083rnIf

leader会在heartbeats timeout内发送消息
给follower，follower收到消息会重置election 
timeout；超过election timeout没收到heartbeats
重新选举 ^kigIrEKn

Request vote message ^A9ZtWuls

Appended Entries ^p3kQjlXG

Heartbeats ^VWifTSFl

respond Appended entries ^iCV75jQT

Leader Election ^lpHkpCdN

如果两个节点同事收到相同的票数，会暂停继续一轮投票 ^IUONZ31m

%%
# Drawing
```json
{
	"type": "excalidraw",
	"version": 2,
	"source": "https://excalidraw.com",
	"elements": [
		{
			"type": "rectangle",
			"version": 173,
			"versionNonce": 2070878271,
			"isDeleted": false,
			"id": "qpFqd5Lo30wOhGmhuWt2R",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -411,
			"y": 340,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 262,
			"height": 137,
			"seed": 1003325873,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false
		},
		{
			"type": "ellipse",
			"version": 104,
			"versionNonce": 148688689,
			"isDeleted": false,
			"id": "ID8bMoBU1LxyRwS0hgh-5",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 253,
			"y": 376,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 71,
			"height": 70,
			"seed": 1224255391,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [
				{
					"id": "0NKxLHKPFuYmuYS0zu5Cv",
					"type": "arrow"
				},
				{
					"id": "zw7YZPxj0ZjfZGpWaERtX",
					"type": "arrow"
				},
				{
					"id": "CM3J4GF6EXRIIYB24kZwr",
					"type": "arrow"
				},
				{
					"id": "xvldDmXBth3dhvVLTXJV3",
					"type": "arrow"
				}
			],
			"updated": 1654531955234,
			"link": null,
			"locked": false
		},
		{
			"type": "ellipse",
			"version": 147,
			"versionNonce": 461355103,
			"isDeleted": false,
			"id": "eUPDjRlND1jvIGiGxEs4M",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 328.5,
			"y": 483,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 71,
			"height": 70,
			"seed": 691784287,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [
				{
					"id": "_PR6YzgHed47E24Y_fREz",
					"type": "arrow"
				},
				{
					"id": "xvldDmXBth3dhvVLTXJV3",
					"type": "arrow"
				}
			],
			"updated": 1654531955234,
			"link": null,
			"locked": false
		},
		{
			"type": "ellipse",
			"version": 137,
			"versionNonce": 666747153,
			"isDeleted": false,
			"id": "x0aK4ieo2QQ27Li8ylFKN",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 192.5,
			"y": 486,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 71,
			"height": 70,
			"seed": 1896075025,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [
				{
					"id": "0NKxLHKPFuYmuYS0zu5Cv",
					"type": "arrow"
				},
				{
					"id": "_PR6YzgHed47E24Y_fREz",
					"type": "arrow"
				}
			],
			"updated": 1654531955234,
			"link": null,
			"locked": false
		},
		{
			"type": "ellipse",
			"version": 175,
			"versionNonce": 214389887,
			"isDeleted": false,
			"id": "zbFfBdgfRUvIIzD0jnfDo",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 153,
			"y": 330,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 286,
			"height": 298,
			"seed": 403428753,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [
				{
					"id": "pmWP-YUFngPQO4UI9vQOg",
					"type": "arrow"
				},
				{
					"id": "v-vuZpb5eAESpG29Mv2FT",
					"type": "arrow"
				},
				{
					"id": "n02wMhZlkEXQDXS8BJqzP",
					"type": "arrow"
				},
				{
					"id": "pZ6d7nWVePmx6ayry-KNu",
					"type": "arrow"
				},
				{
					"id": "eBO2FVDl7-eD4tyIaWClI",
					"type": "arrow"
				},
				{
					"id": "xrxsQhSOTSBEcH9-36qgY",
					"type": "arrow"
				}
			],
			"updated": 1654531955234,
			"link": null,
			"locked": false
		},
		{
			"type": "text",
			"version": 38,
			"versionNonce": 90535665,
			"isDeleted": false,
			"id": "XK1J9KhT",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 364,
			"y": 394,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 42,
			"height": 25,
			"seed": 1546905777,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "DCS",
			"rawText": "DCS",
			"baseline": 18,
			"textAlign": "left",
			"verticalAlign": "top",
			"containerId": null,
			"originalText": "DCS"
		},
		{
			"type": "rectangle",
			"version": 83,
			"versionNonce": 117861535,
			"isDeleted": false,
			"id": "zNsR6VwcSBr-NHfy-zeuG",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -381,
			"y": 386,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 75,
			"height": 40,
			"seed": 871883953,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [
				{
					"id": "MuZvWHAY",
					"type": "text"
				},
				{
					"id": "oV7Hf2nSK0CRSJZToALZF",
					"type": "arrow"
				},
				{
					"id": "0klg6ldE-zEM0ORbA0Yjk",
					"type": "arrow"
				},
				{
					"id": "ynSEiZQ_YOPhx26zbOIP6",
					"type": "arrow"
				},
				{
					"id": "qVA6erKI9GJKL09nfdZ0O",
					"type": "arrow"
				}
			],
			"updated": 1654531955234,
			"link": null,
			"locked": false
		},
		{
			"type": "text",
			"version": 33,
			"versionNonce": 609972433,
			"isDeleted": false,
			"id": "MuZvWHAY",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -376,
			"y": 393.5,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 65,
			"height": 25,
			"seed": 894886431,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "pg",
			"rawText": "pg",
			"baseline": 18,
			"textAlign": "center",
			"verticalAlign": "middle",
			"containerId": "zNsR6VwcSBr-NHfy-zeuG",
			"originalText": "pg"
		},
		{
			"type": "rectangle",
			"version": 71,
			"versionNonce": 1978499263,
			"isDeleted": false,
			"id": "-VSwCg8jHbcQyzvi6jUgO",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -260,
			"y": 390,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 85,
			"height": 35,
			"seed": 1730062577,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [
				{
					"id": "QGhcen6S",
					"type": "text"
				},
				{
					"id": "pmWP-YUFngPQO4UI9vQOg",
					"type": "arrow"
				},
				{
					"id": "pZ6d7nWVePmx6ayry-KNu",
					"type": "arrow"
				},
				{
					"id": "oV7Hf2nSK0CRSJZToALZF",
					"type": "arrow"
				},
				{
					"id": "0klg6ldE-zEM0ORbA0Yjk",
					"type": "arrow"
				}
			],
			"updated": 1654531955234,
			"link": null,
			"locked": false
		},
		{
			"type": "text",
			"version": 34,
			"versionNonce": 1245130417,
			"isDeleted": false,
			"id": "QGhcen6S",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -255,
			"y": 395,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 75,
			"height": 25,
			"seed": 639328479,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "bot",
			"rawText": "bot",
			"baseline": 18,
			"textAlign": "center",
			"verticalAlign": "middle",
			"containerId": "-VSwCg8jHbcQyzvi6jUgO",
			"originalText": "bot"
		},
		{
			"type": "rectangle",
			"version": 276,
			"versionNonce": 2065502431,
			"isDeleted": false,
			"id": "VfKlJKSZV6crxhiRDD0HE",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -403,
			"y": 572.5,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 262,
			"height": 137,
			"seed": 217261169,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false
		},
		{
			"type": "rectangle",
			"version": 161,
			"versionNonce": 497037457,
			"isDeleted": false,
			"id": "Ca5Nq85IZEf4yW8B-uSzD",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -387,
			"y": 617.5,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 75,
			"height": 40,
			"seed": 1251235615,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [
				{
					"id": "sKn6RWXZ",
					"type": "text"
				},
				{
					"id": "SsUF44fZ",
					"type": "text"
				},
				{
					"id": "Eq8GjCcQufV-ZFX5wZx3d",
					"type": "arrow"
				},
				{
					"id": "TlN1BOWy0EuyXL3xRR4YS",
					"type": "arrow"
				},
				{
					"id": "ynSEiZQ_YOPhx26zbOIP6",
					"type": "arrow"
				}
			],
			"updated": 1654531955234,
			"link": null,
			"locked": false
		},
		{
			"type": "text",
			"version": 35,
			"versionNonce": 807771391,
			"isDeleted": false,
			"id": "SsUF44fZ",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -382,
			"y": 625,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 65,
			"height": 25,
			"seed": 416771665,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "pg",
			"rawText": "pg",
			"baseline": 18,
			"textAlign": "center",
			"verticalAlign": "middle",
			"containerId": "Ca5Nq85IZEf4yW8B-uSzD",
			"originalText": "pg"
		},
		{
			"type": "rectangle",
			"version": 173,
			"versionNonce": 72218225,
			"isDeleted": false,
			"id": "gWO44dVP8pMTKt9a211Qr",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -241,
			"y": 622.5,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 85,
			"height": 35,
			"seed": 358226751,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [
				{
					"id": "NzguyGNN",
					"type": "text"
				},
				{
					"id": "v-vuZpb5eAESpG29Mv2FT",
					"type": "arrow"
				},
				{
					"id": "eBO2FVDl7-eD4tyIaWClI",
					"type": "arrow"
				},
				{
					"id": "Eq8GjCcQufV-ZFX5wZx3d",
					"type": "arrow"
				},
				{
					"id": "TlN1BOWy0EuyXL3xRR4YS",
					"type": "arrow"
				}
			],
			"updated": 1654531955234,
			"link": null,
			"locked": false
		},
		{
			"type": "text",
			"version": 41,
			"versionNonce": 679978271,
			"isDeleted": false,
			"id": "NzguyGNN",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -236,
			"y": 627.5,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 75,
			"height": 25,
			"seed": 425163825,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "bot",
			"rawText": "bot",
			"baseline": 18,
			"textAlign": "center",
			"verticalAlign": "middle",
			"containerId": "gWO44dVP8pMTKt9a211Qr",
			"originalText": "bot"
		},
		{
			"type": "rectangle",
			"version": 219,
			"versionNonce": 1091043409,
			"isDeleted": false,
			"id": "w8qhN8cslEEBnAiufklqN",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -405,
			"y": 782.5,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 262,
			"height": 137,
			"seed": 2092893119,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false
		},
		{
			"type": "rectangle",
			"version": 145,
			"versionNonce": 867412287,
			"isDeleted": false,
			"id": "flSJwXLt5Z8mB616nWNqh",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -386,
			"y": 833.5,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 75,
			"height": 40,
			"seed": 1970494385,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [
				{
					"id": "Vbqnc48L",
					"type": "text"
				},
				{
					"id": "YIzf-ki7zu8ADZyzk5itr",
					"type": "arrow"
				},
				{
					"id": "NsBIftJAzzUklNRY8ls_x",
					"type": "arrow"
				},
				{
					"id": "qVA6erKI9GJKL09nfdZ0O",
					"type": "arrow"
				}
			],
			"updated": 1654531955234,
			"link": null,
			"locked": false
		},
		{
			"type": "text",
			"version": 95,
			"versionNonce": 1369820721,
			"isDeleted": false,
			"id": "Vbqnc48L",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -381,
			"y": 841,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 65,
			"height": 25,
			"seed": 1388721119,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "pg",
			"rawText": "pg",
			"baseline": 18,
			"textAlign": "center",
			"verticalAlign": "middle",
			"containerId": "flSJwXLt5Z8mB616nWNqh",
			"originalText": "pg"
		},
		{
			"type": "rectangle",
			"version": 128,
			"versionNonce": 1594501471,
			"isDeleted": false,
			"id": "ccmAm0RXY9KQNdhkAW21n",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -236,
			"y": 837.5,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 85,
			"height": 35,
			"seed": 1255062929,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [
				{
					"id": "fAYk672X",
					"type": "text"
				},
				{
					"id": "xrxsQhSOTSBEcH9-36qgY",
					"type": "arrow"
				},
				{
					"id": "n02wMhZlkEXQDXS8BJqzP",
					"type": "arrow"
				},
				{
					"id": "YIzf-ki7zu8ADZyzk5itr",
					"type": "arrow"
				}
			],
			"updated": 1654531955234,
			"link": null,
			"locked": false
		},
		{
			"type": "text",
			"version": 93,
			"versionNonce": 219078673,
			"isDeleted": false,
			"id": "fAYk672X",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -231,
			"y": 842.5,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 75,
			"height": 25,
			"seed": 481452031,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "bot",
			"rawText": "bot",
			"baseline": 18,
			"textAlign": "center",
			"verticalAlign": "middle",
			"containerId": "ccmAm0RXY9KQNdhkAW21n",
			"originalText": "bot"
		},
		{
			"type": "arrow",
			"version": 187,
			"versionNonce": 937141631,
			"isDeleted": false,
			"id": "pmWP-YUFngPQO4UI9vQOg",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -174,
			"y": 408,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 329.0000672196279,
			"height": 37.00000755965419,
			"seed": 1641991391,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "-VSwCg8jHbcQyzvi6jUgO",
				"gap": 1,
				"focus": -0.1971350613915416
			},
			"endBinding": {
				"elementId": "zbFfBdgfRUvIIzD0jnfDo",
				"gap": 1.7300252273767853,
				"focus": 0.12106102716335325
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					329.0000672196279,
					37.00000755965419
				]
			]
		},
		{
			"type": "arrow",
			"version": 327,
			"versionNonce": 20624881,
			"isDeleted": false,
			"id": "v-vuZpb5eAESpG29Mv2FT",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -155,
			"y": 636.2207063544997,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 313.2798823355794,
			"height": 101.6640184966567,
			"seed": 1490387839,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "gWO44dVP8pMTKt9a211Qr",
				"gap": 1,
				"focus": 0.3303446817508987
			},
			"endBinding": {
				"elementId": "zbFfBdgfRUvIIzD0jnfDo",
				"gap": 4.70616012793937,
				"focus": -0.06961744503765119
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					313.2798823355794,
					-101.6640184966567
				]
			]
		},
		{
			"type": "arrow",
			"version": 281,
			"versionNonce": 1298701727,
			"isDeleted": false,
			"id": "n02wMhZlkEXQDXS8BJqzP",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -144.13811075538393,
			"y": 862.739304218865,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 343.08052240770786,
			"height": 266.1335304187461,
			"seed": 1224572831,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "ccmAm0RXY9KQNdhkAW21n",
				"gap": 6.861889244616066,
				"focus": 0.9120668575473257
			},
			"endBinding": {
				"elementId": "zbFfBdgfRUvIIzD0jnfDo",
				"gap": 6.000763113842652,
				"focus": -0.22780487559954302
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					343.08052240770786,
					-266.1335304187461
				]
			]
		},
		{
			"type": "arrow",
			"version": 97,
			"versionNonce": 288411601,
			"isDeleted": false,
			"id": "NsBIftJAzzUklNRY8ls_x",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -303,
			"y": 849.0000000000001,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 67.55020788796247,
			"height": 0.9177153185637508,
			"seed": 1942504753,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "flSJwXLt5Z8mB616nWNqh",
				"gap": 8,
				"focus": -0.1892712504338541
			},
			"endBinding": null,
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					67.55020788796247,
					-0.9177153185637508
				]
			]
		},
		{
			"type": "arrow",
			"version": 72,
			"versionNonce": 1927385535,
			"isDeleted": false,
			"id": "0NKxLHKPFuYmuYS0zu5Cv",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 264.4091347776742,
			"y": 440.18999458954147,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 25.139713849267935,
			"height": 42.27470959437113,
			"seed": 870591793,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "ID8bMoBU1LxyRwS0hgh-5",
				"focus": 0.16785057594368757,
				"gap": 2.647195380039804
			},
			"endBinding": {
				"elementId": "x0aK4ieo2QQ27Li8ylFKN",
				"focus": -0.28301565923704264,
				"gap": 5.11060788853915
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					-25.139713849267935,
					42.27470959437113
				]
			]
		},
		{
			"type": "arrow",
			"version": 34,
			"versionNonce": 1393077681,
			"isDeleted": false,
			"id": "_PR6YzgHed47E24Y_fREz",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 268,
			"y": 521,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 56,
			"height": 4,
			"seed": 1889251327,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "x0aK4ieo2QQ27Li8ylFKN",
				"focus": 0.08141925380592956,
				"gap": 4.5
			},
			"endBinding": {
				"elementId": "eUPDjRlND1jvIGiGxEs4M",
				"focus": 0.1099159926380049,
				"gap": 4.512816040751481
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					56,
					-4
				]
			]
		},
		{
			"type": "arrow",
			"version": 91,
			"versionNonce": 1097269727,
			"isDeleted": false,
			"id": "CM3J4GF6EXRIIYB24kZwr",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 346,
			"y": 489,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 37,
			"height": 40,
			"seed": 791024113,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"startBinding": null,
			"endBinding": {
				"elementId": "ID8bMoBU1LxyRwS0hgh-5",
				"focus": 0.3049179376921815,
				"gap": 8.065639058454956
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					-37,
					-40
				]
			]
		},
		{
			"type": "arrow",
			"version": 59,
			"versionNonce": 770297745,
			"isDeleted": false,
			"id": "zw7YZPxj0ZjfZGpWaERtX",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 253,
			"y": 497,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 30.241443725196405,
			"height": 46.60906779173189,
			"seed": 558058737,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"startBinding": null,
			"endBinding": {
				"elementId": "ID8bMoBU1LxyRwS0hgh-5",
				"focus": -0.48169284395507594,
				"gap": 4.731780027121673
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					30.241443725196405,
					-46.60906779173189
				]
			]
		},
		{
			"type": "arrow",
			"version": 59,
			"versionNonce": 1510567423,
			"isDeleted": false,
			"id": "xvldDmXBth3dhvVLTXJV3",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 327,
			"y": 420,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 46,
			"height": 60,
			"seed": 2114801055,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "ID8bMoBU1LxyRwS0hgh-5",
				"focus": -0.710107379084509,
				"gap": 4.064318502086756
			},
			"endBinding": {
				"elementId": "eUPDjRlND1jvIGiGxEs4M",
				"focus": 0.8569228287686481,
				"gap": 4.0251490116783515
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					46,
					60
				]
			]
		},
		{
			"type": "arrow",
			"version": 95,
			"versionNonce": 940291441,
			"isDeleted": false,
			"id": "EaTwHEc1BL8FRJcO4D0QB",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 341,
			"y": 540,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 82,
			"height": 2,
			"seed": 644315825,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"startBinding": null,
			"endBinding": null,
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					-82,
					-2
				]
			]
		},
		{
			"type": "arrow",
			"version": 203,
			"versionNonce": 1741248031,
			"isDeleted": false,
			"id": "pZ6d7nWVePmx6ayry-KNu",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 165.33338303209615,
			"y": 415.96207867547855,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 333.33338303209615,
			"height": 18.96207867547855,
			"seed": 71338577,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "zbFfBdgfRUvIIzD0jnfDo",
				"gap": 1,
				"focus": 0.37263158031918464
			},
			"endBinding": {
				"elementId": "-VSwCg8jHbcQyzvi6jUgO",
				"gap": 7,
				"focus": -0.6685456595264938
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					-333.33338303209615,
					-18.96207867547855
				]
			]
		},
		{
			"type": "arrow",
			"version": 311,
			"versionNonce": 1421205329,
			"isDeleted": false,
			"id": "eBO2FVDl7-eD4tyIaWClI",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 154.4757550093692,
			"y": 513.4130160233675,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 309.4757550093692,
			"height": 113.27604644165865,
			"seed": 1896940351,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "zbFfBdgfRUvIIzD0jnfDo",
				"gap": 2.331766967575959,
				"focus": 0.11010517471469791
			},
			"endBinding": {
				"elementId": "gWO44dVP8pMTKt9a211Qr",
				"gap": 1,
				"focus": 0.07899227956115401
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					-309.4757550093692,
					113.27604644165865
				]
			]
		},
		{
			"type": "arrow",
			"version": 284,
			"versionNonce": 1637300799,
			"isDeleted": false,
			"id": "xrxsQhSOTSBEcH9-36qgY",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 185.77126758079328,
			"y": 578.3937233667993,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 335.7712675807933,
			"height": 267.38361758856934,
			"seed": 65628017,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "zbFfBdgfRUvIIzD0jnfDo",
				"gap": 2.8220528679261463,
				"focus": -0.06193935036433734
			},
			"endBinding": {
				"elementId": "ccmAm0RXY9KQNdhkAW21n",
				"gap": 1,
				"focus": 0.4950453593859037
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					-335.7712675807933,
					267.38361758856934
				]
			]
		},
		{
			"type": "arrow",
			"version": 127,
			"versionNonce": 306171185,
			"isDeleted": false,
			"id": "oV7Hf2nSK0CRSJZToALZF",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -264,
			"y": 399,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 41,
			"height": 1.9523809523809632,
			"seed": 377135743,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "-VSwCg8jHbcQyzvi6jUgO",
				"gap": 4,
				"focus": 0.32195121951219513
			},
			"endBinding": {
				"elementId": "zNsR6VwcSBr-NHfy-zeuG",
				"gap": 1,
				"focus": -0.49508196721311476
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					-41,
					-1.9523809523809632
				]
			]
		},
		{
			"type": "arrow",
			"version": 111,
			"versionNonce": 206805599,
			"isDeleted": false,
			"id": "0klg6ldE-zEM0ORbA0Yjk",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -305,
			"y": 421.8837209302326,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 41.99999999999994,
			"height": 4.883720930232471,
			"seed": 1829302289,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "zNsR6VwcSBr-NHfy-zeuG",
				"gap": 1,
				"focus": 0.8357995226730309
			},
			"endBinding": {
				"elementId": "-VSwCg8jHbcQyzvi6jUgO",
				"gap": 3,
				"focus": -0.18756476683937826
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					41.99999999999994,
					-4.883720930232471
				]
			]
		},
		{
			"type": "arrow",
			"version": 250,
			"versionNonce": 1209073425,
			"isDeleted": false,
			"id": "YIzf-ki7zu8ADZyzk5itr",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -236.58265871295797,
			"y": 874.917665620076,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 67.41734128704203,
			"height": 2.723065342860423,
			"seed": 1020590271,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "ccmAm0RXY9KQNdhkAW21n",
				"gap": 2.4868852459017035,
				"focus": -1.1270358306188948
			},
			"endBinding": {
				"elementId": "flSJwXLt5Z8mB616nWNqh",
				"gap": 7,
				"focus": 0.7853801169590764
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					-67.41734128704203,
					-2.723065342860423
				]
			]
		},
		{
			"type": "text",
			"version": 9,
			"versionNonce": 1020196479,
			"isDeleted": false,
			"id": "sKn6RWXZ",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "dotted",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -382,
			"y": 625,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 65,
			"height": 25,
			"seed": 841760735,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "pg",
			"rawText": "pg",
			"baseline": 18,
			"textAlign": "center",
			"verticalAlign": "middle",
			"containerId": "Ca5Nq85IZEf4yW8B-uSzD",
			"originalText": "pg"
		},
		{
			"type": "arrow",
			"version": 114,
			"versionNonce": 1956705521,
			"isDeleted": false,
			"id": "Eq8GjCcQufV-ZFX5wZx3d",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -311,
			"y": 631,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 65,
			"height": 0,
			"seed": 458850609,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "Ca5Nq85IZEf4yW8B-uSzD",
				"gap": 1,
				"focus": -0.325
			},
			"endBinding": {
				"elementId": "gWO44dVP8pMTKt9a211Qr",
				"gap": 5,
				"focus": 0.5142857142857142
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					65,
					0
				]
			]
		},
		{
			"type": "arrow",
			"version": 112,
			"versionNonce": 1506397855,
			"isDeleted": false,
			"id": "TlN1BOWy0EuyXL3xRR4YS",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -243,
			"y": 656,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 66,
			"height": 3,
			"seed": 253167711,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "gWO44dVP8pMTKt9a211Qr",
				"gap": 2,
				"focus": -0.9274853801169591
			},
			"endBinding": {
				"elementId": "Ca5Nq85IZEf4yW8B-uSzD",
				"gap": 3,
				"focus": 0.6293193717277488
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					-66,
					-3
				]
			]
		},
		{
			"type": "rectangle",
			"version": 262,
			"versionNonce": 1534537425,
			"isDeleted": false,
			"id": "bCFDeh3qSTw2XU03M1QWo",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "dotted",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -280,
			"y": 209,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 468.75,
			"height": 817,
			"seed": 1061874271,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955234,
			"link": null,
			"locked": false
		},
		{
			"type": "text",
			"version": 15,
			"versionNonce": 502571711,
			"isDeleted": false,
			"id": "2ytUCclR",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "dotted",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -95,
			"y": 251,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 123,
			"height": 45,
			"seed": 363278737,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"fontSize": 36,
			"fontFamily": 1,
			"text": "patroni",
			"rawText": "patroni",
			"baseline": 32,
			"textAlign": "left",
			"verticalAlign": "top",
			"containerId": null,
			"originalText": "patroni"
		},
		{
			"type": "arrow",
			"version": 213,
			"versionNonce": 1663773873,
			"isDeleted": false,
			"id": "ynSEiZQ_YOPhx26zbOIP6",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -382,
			"y": 413.0394736842104,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 100.66666666666669,
			"height": 233.79385964912285,
			"seed": 2051818929,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "zNsR6VwcSBr-NHfy-zeuG",
				"gap": 1,
				"focus": 0.6276124732206632
			},
			"endBinding": {
				"elementId": "Ca5Nq85IZEf4yW8B-uSzD",
				"gap": 1.6666666666666856,
				"focus": -0.8540461583406362
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					-100.66666666666669,
					131.79385964912285
				],
				[
					-6.666666666666686,
					233.79385964912285
				]
			]
		},
		{
			"type": "text",
			"version": 15,
			"versionNonce": 435155679,
			"isDeleted": false,
			"id": "Y1HWnMyp",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -352,
			"y": 432.16666666666663,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 68,
			"height": 25,
			"seed": 1357502751,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "primary",
			"rawText": "primary",
			"baseline": 18,
			"textAlign": "left",
			"verticalAlign": "top",
			"containerId": null,
			"originalText": "primary"
		},
		{
			"type": "text",
			"version": 12,
			"versionNonce": 862219921,
			"isDeleted": false,
			"id": "yKbxlkcD",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -376,
			"y": 665.8333333333333,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 77,
			"height": 25,
			"seed": 1689133567,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "standby",
			"rawText": "standby",
			"baseline": 18,
			"textAlign": "left",
			"verticalAlign": "top",
			"containerId": null,
			"originalText": "standby"
		},
		{
			"type": "text",
			"version": 12,
			"versionNonce": 1984708351,
			"isDeleted": false,
			"id": "s1XBLJYE",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -372.6666666666667,
			"y": 879.1666666666666,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 77,
			"height": 25,
			"seed": 365968081,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "standby",
			"rawText": "standby",
			"baseline": 18,
			"textAlign": "left",
			"verticalAlign": "top",
			"containerId": null,
			"originalText": "standby"
		},
		{
			"type": "arrow",
			"version": 205,
			"versionNonce": 316306545,
			"isDeleted": false,
			"id": "qVA6erKI9GJKL09nfdZ0O",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -383.33333333333337,
			"y": 402.83333333333326,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 230.66666666666663,
			"height": 453.3333333333335,
			"seed": 147154961,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "zNsR6VwcSBr-NHfy-zeuG",
				"gap": 2.3333333333333712,
				"focus": 0.6646432544096625
			},
			"endBinding": {
				"elementId": "flSJwXLt5Z8mB616nWNqh",
				"gap": 1.3333333333333712,
				"focus": -0.7743480574773818
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					-230.66666666666663,
					156.66666666666674
				],
				[
					-4.000000000000057,
					453.3333333333335
				]
			]
		},
		{
			"type": "ellipse",
			"version": 171,
			"versionNonce": 1971980063,
			"isDeleted": false,
			"id": "Z3cextxOAS10rge0FkYuB",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -170.60059802195087,
			"y": 1240.6957114473194,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 189,
			"height": 146.6223098084779,
			"seed": 1433286367,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [
				{
					"type": "text",
					"id": "FFzJuyjV"
				},
				{
					"id": "qN5LIPZqdC0lxVlGsc6k5",
					"type": "arrow"
				},
				{
					"id": "Sw_9mJ-vA34UOau0NFVvg",
					"type": "arrow"
				},
				{
					"id": "SPLmWLRbblYxviyDxXW2S",
					"type": "arrow"
				},
				{
					"id": "qV9RfuhFgJ2UTZi_yRPiz",
					"type": "arrow"
				}
			],
			"updated": 1654531955235,
			"link": null,
			"locked": false
		},
		{
			"type": "text",
			"version": 112,
			"versionNonce": 89439825,
			"isDeleted": false,
			"id": "FFzJuyjV",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -165.60059802195087,
			"y": 1301.5068663515583,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 179,
			"height": 25,
			"seed": 791309553,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "follower",
			"rawText": "follower",
			"baseline": 18,
			"textAlign": "center",
			"verticalAlign": "middle",
			"containerId": "Z3cextxOAS10rge0FkYuB",
			"originalText": "follower"
		},
		{
			"type": "ellipse",
			"version": 306,
			"versionNonce": 907660095,
			"isDeleted": false,
			"id": "yeOQcPGKXkroDZhhz_1V4",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 8.604447299522008,
			"y": 1521.9933280428438,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 192.23813952667115,
			"height": 144.45012744094493,
			"seed": 1645429297,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [
				{
					"type": "text",
					"id": "6BEIKKp5"
				},
				{
					"id": "qN5LIPZqdC0lxVlGsc6k5",
					"type": "arrow"
				},
				{
					"id": "benpViakf-wMuw9kPLInY",
					"type": "arrow"
				}
			],
			"updated": 1654531955235,
			"link": null,
			"locked": false
		},
		{
			"type": "text",
			"version": 251,
			"versionNonce": 699059249,
			"isDeleted": false,
			"id": "6BEIKKp5",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 13.604447299522008,
			"y": 1581.7183917633163,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 182.23813952667115,
			"height": 25,
			"seed": 1758312799,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"fontSize": 20.05237259880598,
			"fontFamily": 1,
			"text": "candidate",
			"rawText": "candidate",
			"baseline": 18,
			"textAlign": "center",
			"verticalAlign": "middle",
			"containerId": "yeOQcPGKXkroDZhhz_1V4",
			"originalText": "candidate"
		},
		{
			"type": "ellipse",
			"version": 213,
			"versionNonce": 878447455,
			"isDeleted": false,
			"id": "QBLKgkOe-gFbSLuc9EKIj",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 193.23994853982754,
			"y": 1241.781802631086,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 205.2712337318692,
			"height": 162.9136775649754,
			"seed": 333149905,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [
				{
					"id": "benpViakf-wMuw9kPLInY",
					"type": "arrow"
				},
				{
					"id": "Sw_9mJ-vA34UOau0NFVvg",
					"type": "arrow"
				},
				{
					"type": "text",
					"id": "CQVFm8hH"
				},
				{
					"id": "SPLmWLRbblYxviyDxXW2S",
					"type": "arrow"
				}
			],
			"updated": 1654531955235,
			"link": null,
			"locked": false
		},
		{
			"type": "arrow",
			"version": 443,
			"versionNonce": 1472470545,
			"isDeleted": false,
			"id": "qN5LIPZqdC0lxVlGsc6k5",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -88.8888169398939,
			"y": 1387.6487572119954,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 120.31834744351045,
			"height": 156.0886669537431,
			"seed": 1454603537,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "Z3cextxOAS10rge0FkYuB",
				"gap": 1,
				"focus": 0.6316891427118333
			},
			"endBinding": {
				"elementId": "yeOQcPGKXkroDZhhz_1V4",
				"gap": 2.875152514323105,
				"focus": -0.3095252687730375
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					120.31834744351045,
					156.0886669537431
				]
			]
		},
		{
			"type": "arrow",
			"version": 419,
			"versionNonce": 211896191,
			"isDeleted": false,
			"id": "benpViakf-wMuw9kPLInY",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 178.33765846930993,
			"y": 1546.4551588841086,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 82.2460396711603,
			"height": 140.68401522698468,
			"seed": 1108403455,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "yeOQcPGKXkroDZhhz_1V4",
				"gap": 1,
				"focus": 0.4352170872208195
			},
			"endBinding": {
				"elementId": "QBLKgkOe-gFbSLuc9EKIj",
				"gap": 5.825495358509116,
				"focus": -0.11452461541663311
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					82.2460396711603,
					-140.68401522698468
				]
			]
		},
		{
			"type": "arrow",
			"version": 427,
			"versionNonce": 2123903985,
			"isDeleted": false,
			"id": "Sw_9mJ-vA34UOau0NFVvg",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 199.77391849487958,
			"y": 1287.3966820118726,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 179.2301967977183,
			"height": 9.776192552602879,
			"seed": 1000527185,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "QBLKgkOe-gFbSLuc9EKIj",
				"gap": 3.39048865302982,
				"focus": 0.5031766744311578
			},
			"endBinding": {
				"elementId": "Z3cextxOAS10rge0FkYuB",
				"gap": 4.4893198616091325,
				"focus": -0.157329522573825
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					-179.2301967977183,
					9.776192552602879
				]
			]
		},
		{
			"type": "text",
			"version": 113,
			"versionNonce": 2099904415,
			"isDeleted": false,
			"id": "CQVFm8hH",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 198.23994853982754,
			"y": 1310.7386414135738,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 195.2712337318692,
			"height": 25,
			"seed": 309088593,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"fontSize": 20.027818844294277,
			"fontFamily": 1,
			"text": "leader",
			"rawText": "leader",
			"baseline": 18,
			"textAlign": "center",
			"verticalAlign": "middle",
			"containerId": "QBLKgkOe-gFbSLuc9EKIj",
			"originalText": "leader"
		},
		{
			"type": "arrow",
			"version": 407,
			"versionNonce": 1110347217,
			"isDeleted": false,
			"id": "SPLmWLRbblYxviyDxXW2S",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 20.548650762489316,
			"y": 1325.410860139009,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 167.260841858506,
			"height": 2.172218725434959,
			"seed": 2055299953,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "Z3cextxOAS10rge0FkYuB",
				"gap": 3.2398936940783756,
				"focus": 0.17265319818054642
			},
			"endBinding": {
				"elementId": "QBLKgkOe-gFbSLuc9EKIj",
				"gap": 5.430455918832195,
				"focus": 0.01722713094149003
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					167.260841858506,
					-2.172218725434959
				]
			]
		},
		{
			"type": "arrow",
			"version": 383,
			"versionNonce": 673625023,
			"isDeleted": false,
			"id": "qV9RfuhFgJ2UTZi_yRPiz",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 57.31300387148741,
			"y": 1531.6361795100747,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 89.95674979897291,
			"height": 150.8586749750516,
			"seed": 1237344927,
			"groupIds": [],
			"strokeSharpness": "round",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"startBinding": {
				"elementId": "A9ZtWuls",
				"gap": 13.25936981229188,
				"focus": -1.6421163442108835
			},
			"endBinding": {
				"elementId": "Z3cextxOAS10rge0FkYuB",
				"gap": 1.5591923764144155,
				"focus": -0.03497495806566614
			},
			"lastCommittedPoint": null,
			"startArrowhead": null,
			"endArrowhead": "arrow",
			"points": [
				[
					0,
					0
				],
				[
					-89.95674979897291,
					-150.8586749750516
				]
			]
		},
		{
			"type": "text",
			"version": 125,
			"versionNonce": 1503570865,
			"isDeleted": false,
			"id": "vBM28SjB",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -344.37518742459133,
			"y": 1405.47030084996,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 271,
			"height": 84,
			"seed": 1722659903,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "经过election timeout，\n没有收到其他的邀请选举信息\n可以从follower变成candidate",
			"rawText": "经过election timeout，\n没有收到其他的邀请选举信息\n可以从follower变成candidate",
			"baseline": 77,
			"textAlign": "left",
			"verticalAlign": "top",
			"containerId": null,
			"originalText": "经过election timeout，\n没有收到其他的邀请选举信息\n可以从follower变成candidate"
		},
		{
			"type": "text",
			"version": 114,
			"versionNonce": 364372959,
			"isDeleted": false,
			"id": "WG9dHKQs",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 249.71669009568586,
			"y": 1515.1655104103768,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 281,
			"height": 28,
			"seed": 2020149599,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "收到最多的选举票数成为leader",
			"rawText": "收到最多的选举票数成为leader",
			"baseline": 21,
			"textAlign": "left",
			"verticalAlign": "top",
			"containerId": null,
			"originalText": "收到最多的选举票数成为leader"
		},
		{
			"type": "text",
			"version": 111,
			"versionNonce": 756026769,
			"isDeleted": false,
			"id": "FBpuDcDn",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 271.438513771016,
			"y": 1555.3508842097374,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 236,
			"height": 28,
			"seed": 1351500191,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "成为candidate为自己投票",
			"rawText": "成为candidate为自己投票",
			"baseline": 21,
			"textAlign": "left",
			"verticalAlign": "top",
			"containerId": null,
			"originalText": "成为candidate为自己投票"
		},
		{
			"type": "text",
			"version": 128,
			"versionNonce": 1978535935,
			"isDeleted": false,
			"id": "U083rnIf",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -210.78597182131148,
			"y": 1167.6163316050956,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 451,
			"height": 28,
			"seed": 1550372209,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "follower收到投票的请求，会重置election timeout",
			"rawText": "follower收到投票的请求，会重置election timeout",
			"baseline": 21,
			"textAlign": "left",
			"verticalAlign": "top",
			"containerId": null,
			"originalText": "follower收到投票的请求，会重置election timeout"
		},
		{
			"type": "text",
			"version": 197,
			"versionNonce": 867840881,
			"isDeleted": false,
			"id": "kigIrEKn",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 432.1800089684582,
			"y": 1211.059978955756,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 460,
			"height": 112,
			"seed": 2023033073,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "leader会在heartbeats timeout内发送消息\n给follower，follower收到消息会重置election \ntimeout；超过election timeout没收到heartbeats\n重新选举",
			"rawText": "leader会在heartbeats timeout内发送消息\n给follower，follower收到消息会重置election \ntimeout；超过election timeout没收到heartbeats\n重新选举",
			"baseline": 105,
			"textAlign": "left",
			"verticalAlign": "top",
			"containerId": null,
			"originalText": "leader会在heartbeats timeout内发送消息\n给follower，follower收到消息会重置election \ntimeout；超过election timeout没收到heartbeats\n重新选举"
		},
		{
			"type": "text",
			"version": 221,
			"versionNonce": 583645215,
			"isDeleted": false,
			"id": "A9ZtWuls",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 1.0731812051156675,
			"x": -57.54815920550359,
			"y": 1459.903642586856,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 224,
			"height": 25,
			"seed": 1323528799,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [
				{
					"id": "qV9RfuhFgJ2UTZi_yRPiz",
					"type": "arrow"
				}
			],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "Request vote message",
			"rawText": "Request vote message",
			"baseline": 18,
			"textAlign": "left",
			"verticalAlign": "top",
			"containerId": null,
			"originalText": "Request vote message"
		},
		{
			"type": "text",
			"version": 110,
			"versionNonce": 300195153,
			"isDeleted": false,
			"id": "p3kQjlXG",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 57.917837668838274,
			"y": 1262.4717277418945,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 167,
			"height": 25,
			"seed": 1482582687,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "Appended Entries",
			"rawText": "Appended Entries",
			"baseline": 18,
			"textAlign": "left",
			"verticalAlign": "top",
			"containerId": null,
			"originalText": "Appended Entries"
		},
		{
			"type": "text",
			"version": 108,
			"versionNonce": 1648057407,
			"isDeleted": false,
			"id": "VWifTSFl",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 76.66783766883827,
			"y": 1239.9717277418945,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 113,
			"height": 25,
			"seed": 873470065,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "Heartbeats",
			"rawText": "Heartbeats",
			"baseline": 18,
			"textAlign": "left",
			"verticalAlign": "top",
			"containerId": null,
			"originalText": "Heartbeats"
		},
		{
			"type": "text",
			"version": 113,
			"versionNonce": 1994836785,
			"isDeleted": false,
			"id": "iCV75jQT",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": 39.167837668838274,
			"y": 1332.4717277418945,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 246,
			"height": 25,
			"seed": 950509311,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "respond Appended entries",
			"rawText": "respond Appended entries",
			"baseline": 18,
			"textAlign": "left",
			"verticalAlign": "top",
			"containerId": null,
			"originalText": "respond Appended entries"
		},
		{
			"type": "text",
			"version": 110,
			"versionNonce": 1747156063,
			"isDeleted": false,
			"id": "lpHkpCdN",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -38.332162331161726,
			"y": 1696.2217277418945,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 154,
			"height": 25,
			"seed": 1944696703,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531955235,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "Leader Election",
			"rawText": "Leader Election",
			"baseline": 18,
			"textAlign": "left",
			"verticalAlign": "top",
			"containerId": null,
			"originalText": "Leader Election"
		},
		{
			"type": "text",
			"version": 228,
			"versionNonce": 936152639,
			"isDeleted": false,
			"id": "IUONZ31m",
			"fillStyle": "hachure",
			"strokeWidth": 1,
			"strokeStyle": "solid",
			"roughness": 1,
			"opacity": 100,
			"angle": 0,
			"x": -185.83216233116173,
			"y": 1112.3608638709472,
			"strokeColor": "#000000",
			"backgroundColor": "transparent",
			"width": 501,
			"height": 28,
			"seed": 522791071,
			"groupIds": [],
			"strokeSharpness": "sharp",
			"boundElements": [],
			"updated": 1654531996618,
			"link": null,
			"locked": false,
			"fontSize": 20,
			"fontFamily": 1,
			"text": "如果两个节点同事收到相同的票数，会暂停继续一轮投票",
			"rawText": "如果两个节点同事收到相同的票数，会暂停继续一轮投票",
			"baseline": 21,
			"textAlign": "left",
			"verticalAlign": "top",
			"containerId": null,
			"originalText": "如果两个节点同事收到相同的票数，会暂停继续一轮投票"
		}
	],
	"appState": {
		"theme": "light",
		"viewBackgroundColor": "#ffffff",
		"currentItemStrokeColor": "#000000",
		"currentItemBackgroundColor": "transparent",
		"currentItemFillStyle": "hachure",
		"currentItemStrokeWidth": 1,
		"currentItemStrokeStyle": "solid",
		"currentItemRoughness": 1,
		"currentItemOpacity": 100,
		"currentItemFontFamily": 1,
		"currentItemFontSize": 20,
		"currentItemTextAlign": "left",
		"currentItemStrokeSharpness": "sharp",
		"currentItemStartArrowhead": null,
		"currentItemEndArrowhead": "arrow",
		"currentItemLinearStrokeSharpness": "round",
		"gridSize": null,
		"colorPalette": {}
	},
	"files": {}
}
```
%%