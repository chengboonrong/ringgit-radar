# Back-translation record, 2026-11-21

Every string in app_zh.arb and app_ms.arb was translated back into English by a fresh agent that saw only the translation and where it shows, never the English. Each round sent only the keys changed after the round before. A key is listed when its back-translation drifted from the English meaning, or when the agent flagged it as ambiguous or unnatural. Every other key back-translated to the English meaning.

Columns: key, what the agent read back, the problem, and the fix (the new text, or why the text stands).

## Chinese (简体中文)

### Round 1: 162 keys, 20 listed

| Key | Back-translation | Problem | Fix |
|---|---|---|---|
| biggestSwitch2Savings | Switch 2 saves the most | 省得最多 reads as 'saves the most', a verb about the console, not the biggest amount saved. | Switch 2 节省金额最高 |
| sortSavings | Saves the most | Same: 'saves the most' instead of 'biggest savings'. | 节省金额最高 |
| historyHeading | Our records show | 'Our records show' lost 'history' and reads as an unfinished sentence. | 我们的价格记录 |
| lowestSeenSince | Lowest price we have seen: {price}, since {date} | Comma left it unclear whether 'since' belongs to the price; kept 'we have seen'. | 我们见过的最低价：{price}（自{date}起） |
| genre | Type | 类型 back-translates as 'type', which clashes with Product Type. | 游戏类型 |
| couldNotLoad | {what, select, list{Unable to load the list.} highlights{Unable to load the picks.} ranking{Unable to load the ranking.} genres{Unable to load the types.} status{Unable to load the data status.} game{Unable to load this game.} other{Unable to load.}} | genres case used 类型 ('types'); aligned with the genre term. | {what, select, list{无法载入列表。} highlights{无法载入精选。} ranking{无法载入排行。} genres{无法载入游戏类型。} status{无法载入数据状态。} game{无法载入这款游戏。} other{无法载入。}} |
| ageN | {age} years old (UK PEGI) | '{age} years old' says the player's age, not the rating. | 年龄 {age}（UK PEGI） |
| sortSoonest | Fastest to release | 最快发售 = 'fastest to release'; soonest is about date, not speed. | 最早发售 |
| notYet | Not yet | 尚未 is a bare adverb; fine in meaning but stiff as a standalone value. | 还没有 |
| aboutRecord | It records the ringgit prices of the Malaysian eShop by itself. To buy games, please use your Switch. | 'records … by itself' suggests automation, not 'keeps its own record'. | 它保存自己的马来西亚 eShop 令吉价格记录。要购买游戏，请使用你的 Switch。 |
| buyOnSwitch | Please buy on the Nintendo eShop on your Switch. | Correct but clumsy double 上; reworded with 通过. | 请在你的 Switch 上通过 Nintendo eShop 购买。 |
| privacyLogsBody | Our server does not write access logs. It only records errors, for example database errors; these records contain only the error information and do not contain your address. To prevent a single visitor from overloading the server, the server counts the number of requests per network address, saved only in memory. These addresses are never written to disk. | 'your address' was ambiguous (home address?); now 'network address'. | 我们的服务器不写访问日志。它只记录错误，例如数据库错误，这些记录只包含错误信息，不包含你的网络地址。为了防止单一访客使服务器过载，服务器会按网络地址计算请求次数，只保存在内存中。这些地址从不写入磁盘。 |
| privacyDeviceBody | Your wish list, theme and language choices, and the "Show all games" setting are saved only on this device: the web version saves them in the browser's local storage, the Android app saves them in the app's preferences. When you open the wish list, the app requests these games from our server by game number, so the server receives these numbers in this request in order to answer. The server does not save these numbers, and does not associate them with you either. | 以便作答 ('in order to answer') is exam wording; changed to answering the request. | 你的愿望单、主题和语言选择以及“显示全部游戏”设置只保存在这台设备上：网页版保存在浏览器的本地存储中，Android 应用保存在应用的偏好设置中。打开愿望单时，应用会按游戏编号向我们的服务器请求这些游戏，因此服务器会在这次请求中收到这些编号，以便回应这次请求。服务器不会保存这些编号，也不会把它们与你关联。 |
| genreMultiplayer | Multi-person | 多人 alone = 'multi-person'. | 多人游戏 |
| genreLifestyle | Life | 生活 alone = 'life'. | 生活方式 |
| genreCommunication | Communication / exchange | 交流 = 'exchange'. | 沟通 |
| genrePractical | Practical | 实用 alone is an adjective; added 软件. | 实用软件 |
| percentOff | Minus {percent}% | 减{percent}% reads as 'minus'. | {percent}%折扣 |
| priceOnSaleDescription | Special price {now}, original price {was}, minus {percent}% | Same 'minus' wording. | 特价 {now}，原价 {was}，{percent}%折扣 |
| serverAnswered | The server returned {status}. | 'returned {status}' without saying {status} is a code. | 服务器返回了代码 {status}。 |

### Round 2: 20 keys, 9 listed

| Key | Back-translation | Problem | Fix |
|---|---|---|---|
| percentOff | {percent}% discount | {percent}%折扣 can be read as Chinese 折 (pay {percent}%), the opposite meaning. Now 省{percent}% ('save'). | 省{percent}% |
| priceOnSaleDescription | Special price {now}, original price {was}, {percent}% discount | Same 折 confusion. | 特价 {now}，原价 {was}，省 {percent}% |
| genreCommunication | Communicating (the act of communication) | 沟通 is the act of communicating; the eShop category is 通讯. | 通讯 |
| genreLifestyle | Way of life | 生活方式 = 'way of life'; eShop category reads 生活. | 生活 |
| lowestSeenSince | Lowest price we have seen: {price} (since {date}) | '(since {date})' still read as a range on the price list; now 'at this price since {date}'. | 我们见过的最低价：{price}，{date}起为此价 |
| privacyLogsBody | Our server does not write access logs. It only records errors, for example database errors, and these records contain only the error information, not your network address. To prevent a single visitor from overloading the server, the server counts the number of requests per network address, kept only in memory. These addresses are never written to disk. | 'kept only in memory' had no subject (the counts); now names the counts. | 我们的服务器不写访问日志。它只记录错误，例如数据库错误，这些记录只包含错误信息，不包含你的网络地址。为了防止单一访客使服务器过载，服务器会按网络地址计算请求次数，这些计数只保存在内存中。这些地址从不写入磁盘。 |
| privacyDeviceBody | Your wishlist, your theme and language choices, and the "Show all games" setting are saved only on this device: the web version saves them in the browser's local storage, and the Android app saves them in the app's preferences. When you open the wishlist, the app requests these games from our server by game number, so the server receives these numbers in this request, in order to respond to this request. The server does not save these numbers, and does not link them to you. | 'this request' repeated twice; tightened. | 你的愿望单、主题和语言选择以及“显示全部游戏”设置只保存在这台设备上：网页版保存在浏览器的本地存储中，Android 应用保存在应用的偏好设置中。打开愿望单时，应用会按游戏编号向我们的服务器请求这些游戏，因此服务器会在这次请求中收到这些编号，以便作出回应。服务器不会保存这些编号，也不会把它们与你关联。 |
| notYet | Not yet (there isn't any yet) | 还没有 = 'there isn't any yet'; 暂无 is the usual value-cell wording. | 暂无 |
| aboutRecord | It keeps its own record of Malaysian eShop ringgit prices. To buy games, please use your Switch. | Sentence opened with bare 它 ('it'); now 本应用 ('this app'). | 本应用保存自己的马来西亚 eShop 令吉价格记录。要购买游戏，请使用你的 Switch。 |

### Round 3: 9 keys, 6 listed

| Key | Back-translation | Problem | Fix |
|---|---|---|---|
| genreCommunication | Communications | 通讯 reads as telecoms or newsletters. Round 1's 交流 back-translated as 'Communication', so the round-1 flag was over-strict; reverted to 交流. | 交流 |
| genreLifestyle | Life | 生活 alone = 'Life', vague. Round 2's 'way of life' for 生活方式 is what lifestyle means; reverted to 生活方式. | 生活方式 |
| lowestSeenSince | Lowest price we have seen: {price}, at this price since {date} | 'has been at this price since {date}' claims the price held without a break. The API's since is the first time that price was seen (backend/internal/api/server.go). Now {date}首次出现 ('first appeared on {date}'). | 我们见过的最低价：{price}，{date}首次出现 |
| notYet | None for now | 暂无 = 'none for now'. Accepted: the value cell shows that nothing has happened yet, and 暂无 is the usual wording there. | No change. |
| percentOff | Save {percent}% | 'Save {percent}%' rather than '{percent}% off'. Accepted: same meaning, and it avoids the 折 reversal. | No change. |
| privacyDeviceBody | Your wishlist, your theme and language choices, and the "Show all games" setting are saved only on this device: the web version saves them in the browser's local storage, and the Android app saves them in the app's preferences. When you open the wishlist, the app requests these games from our server by game number, so the server receives these numbers in this request in order to respond. The server does not save these numbers, and does not link them to you. | Quoted setting name must match the switch label. Checked: showAllTitles is 显示全部游戏 in app_zh.arb. No change. | No change. |

### Round 4: 3 keys, 3 listed

| Key | Back-translation | Problem | Fix |
|---|---|---|---|
| genreCommunication | Communication (exchange) | Back: 'Communication (exchange)'. The meaning matches. The flag that it is vague as a tag is a style note, and it swaps with every round (交流→沟通→通讯→交流). Ruling: keep 交流. | No change. |
| genreLifestyle | Way of life | Back: 'Way of life', which is what lifestyle means. The style flag swaps with every round (生活↔生活方式). Ruling: keep 生活方式. | No change. |
| lowestSeenSince | The lowest price we have seen: {price}, first appeared on {date} | Back: 'first appeared on {date}'. That is exactly what the API's since means, so the flag confirms the fix. No change. | No change. |

## Malay (Bahasa Melayu)

### Round 1: 162 keys, 22 listed

| Key | Back-translation | Problem | Fix |
|---|---|---|---|
| priceUnavailable | Price none | 'Harga tiada' word order reads 'price none'. | Tiada harga |
| aboutUnofficial | Ringgit Radar is an independent app that is not official. Not joined with or supported by Nintendo. | bergabung = 'joined', disokong = 'supported'; neither is 'affiliated/endorsed'. | Ringgit Radar ialah aplikasi bebas yang tidak rasmi. Ia tiada hubungan dengan Nintendo dan tidak diiktiraf oleh Nintendo. |
| privacyNotNintendoBody | Ringgit Radar is an independent app that is not official. Not joined with or supported by Nintendo. Prices are collected from Nintendo eShop Malaysia and shown together with their history; to buy games, use your Switch. | Same affiliation wording. | Ringgit Radar ialah aplikasi bebas yang tidak rasmi. Ia tiada hubungan dengan Nintendo dan tidak diiktiraf oleh Nintendo. Harga dikumpul daripada Nintendo eShop Malaysia dan ditunjukkan bersama sejarahnya; untuk membeli permainan, gunakan Switch anda. |
| sortSavings | Save the most | 'Save the most' is a verb, not 'biggest savings'. | Penjimatan terbesar |
| retryLoadingMore | Try loading again | 'Try loading again' lost 'more'. | Cuba muatkan lebih banyak |
| clear | Empty | Kosongkan = 'empty'; for filters the action is a reset. | Set semula |
| noFilterMatch | No titles match these filters. Empty one filter to see more. | 'Empty one filter'. | Tiada tajuk sepadan dengan penapis ini. Buang satu penapis untuk melihat lebih banyak. |
| noTitlesFound | No titles found. Try another keyword, or empty one filter. | 'Empty one filter'. | Tiada tajuk ditemui. Cuba kata kunci lain, atau buang satu penapis. |
| clearSearch | Empty search | 'Empty search'. | Padam carian |
| kindAddon | Addition | Tambahan alone = 'addition'. | Kandungan tambahan |
| saleEnds | Promotion ends {dateTime} | tamat with a date-time can read as 'ended'; sehingga makes it 'until'. | Promosi sehingga {dateTime} |
| endsOn | Ends {date} | Same, for the chip. | Hingga {date} |
| serverAnswered | The server answered {status}. | Bare number after menjawab; added 'code'. | Pelayan menjawab dengan kod {status}. |
| genreRacing | Race | Lumba = 'race' (the act). | Perlumbaan |
| players | Player | Pemain = one player; the field is a count. | Bilangan pemain |
| privacyDeviceBody | Your Wish List, your theme and language choice and the "Show all titles" setting are stored on this device only: in the browser's local storage on the web, in the app preferences on Android. When you open the Wish List, the app requests that game/those games from our server by id, so the server receives that id/those ids in that request in order to answer it. The server does not store it or link it to you. | Singular/plural ambiguous (game, id, it); made plural and named the ids. | Senarai Hajat anda, pilihan tema dan bahasa anda serta tetapan "Tunjuk semua tajuk" disimpan pada peranti ini sahaja: dalam storan setempat pelayar di web, dalam keutamaan aplikasi di Android. Apabila anda membuka Senarai Hajat, aplikasi meminta permainan-permainan itu daripada pelayan kami mengikut id permainan, jadi pelayan menerima id tersebut dalam permintaan itu untuk menjawabnya. Pelayan tidak menyimpan id itu atau mengaitkannya dengan anda. |
| privacyLogsBody | Our server does not write access logs. It only logs errors, for example database errors, and that line contains the error message, not your address. To avoid one visitor overloading it, the server counts requests for each internet address, in memory only. That address is never written to disk. | 'that line' singular; now log lines. | Pelayan kami tidak menulis log akses. Ia hanya melog ralat, contohnya ralat pangkalan data, dan baris log tersebut mengandungi mesej ralat, bukan alamat anda. Untuk mengelakkan seorang pelawat membebankannya, pelayan mengira permintaan bagi setiap alamat internet, dalam memori sahaja. Alamat itu tidak pernah ditulis ke cakera. |
| privacyNoAccountsBody | No sign-in. Ringgit Radar does not ask for your name, e-mail or phone number, and it has no ads and no analytics. | 'tiada iklan dan tiada analitik' stiff; reworded. | Tiada log masuk. Ringgit Radar tidak meminta nama, e-mel atau nombor telefon anda, dan ia tidak mempunyai iklan atau analitik. |
| appearanceHeading | Display | Paparan = 'display'. | Penampilan |
| privacyPicturesBody | Game art and screenshots are loaded directly from the store's image server (img-eshop.cdn.nintendo.net). Your browser or phone requests it for each picture, so Nintendo receives your internet address and the usual details of a request, under Nintendo's own privacy policy. Ringgit Radar does not store or send any pictures. | 'tidak menghantar' = 'does not send'; English says 'pass on'. | Seni permainan dan tangkapan skrin dimuatkan terus daripada pelayan imej kedai (img-eshop.cdn.nintendo.net). Pelayar atau telefon anda memintanya bagi setiap gambar, jadi Nintendo menerima alamat internet anda dan butiran biasa sesuatu permintaan, di bawah dasar privasi Nintendo sendiri. Ringgit Radar tidak menyimpan sebarang gambar dan tidak menyerahkannya kepada pihak lain. |
| genreShooter | Shooting each other | Tembak-menembak read as the act ('shooting each other'), not a genre. | Tembakan (reverted in round 3) |
| genreFirstPersonShooter | First Person Shooting | Same. | Tembakan Orang Pertama (replaced in rounds 3 and 4) |

### Round 2: 19 keys, 4 listed

| Key | Back-translation | Problem | Fix |
|---|---|---|---|
| serverAnswered | The server answered with code {status}. | menjawab is 'answer a question'; membalas is a reply, as a server gives. | Pelayan membalas dengan kod {status}. |
| privacyLogsBody | Our server does not write access logs. It only logs errors, for example database errors, and those log lines contain the error message, not your address. To stop one visitor from overburdening it, the server counts requests for each internet address, in memory only. That address is never written to disk. | 'alamat anda' again read as home address; now alamat internet anda. | Pelayan kami tidak menulis log akses. Ia hanya melog ralat, contohnya ralat pangkalan data, dan baris log tersebut mengandungi mesej ralat, bukan alamat internet anda. Untuk mengelakkan seorang pelawat membebankannya, pelayan mengira permintaan bagi setiap alamat internet, dalam memori sahaja. Alamat itu tidak pernah ditulis ke cakera. |
| retryLoadingMore | Try to load more | Lost 'again'. | Cuba lagi untuk memuatkan lebih banyak |
| clearSearch | Delete search | Padam = 'delete'; Kosongkan carian is the standard 'clear search'. | Kosongkan carian |

### Round 3: 7 keys, 5 listed

| Key | Back-translation | Problem | Fix |
|---|---|---|---|
| genreShooter | Shooting (a shot / gunfire) | Tembakan = 'a shot / gunfire'. Now Tembak-menembak, the usual Malaysian name for the genre. | Tembak-menembak |
| genreFirstPersonShooter | First-Person Shooting (lit. First Person Shot) | Same; now Tembak-menembak Orang Pertama. | Tembak-menembak Orang Pertama |
| privacyPicturesBody | Game art and screenshots are loaded directly from the store's image server (img-eshop.cdn.nintendo.net). Your browser or phone requests it for each picture, so Nintendo receives your internet address and the usual details of a request, under Nintendo's own privacy policy. Ringgit Radar does not store any pictures and does not hand them (it) over to other parties. | memintanya ('requests it') left unclear whether 'it' was the server or the picture. Now 'meminta setiap gambar daripada pelayan itu'. The last sentence's -nya means the pictures, as the English says. | Seni permainan dan tangkapan skrin dimuatkan terus daripada pelayan imej kedai (img-eshop.cdn.nintendo.net). Pelayar atau telefon anda meminta setiap gambar daripada pelayan itu, jadi Nintendo menerima alamat internet anda dan butiran biasa sesuatu permintaan, di bawah dasar privasi Nintendo sendiri. Ringgit Radar tidak menyimpan sebarang gambar dan tidak menyerahkannya kepada pihak lain. |
| retryLoadingMore | Try again to load more | 38 characters against a ~22 room, and RedButton's label does not wrap. Shortened to Cuba muatkan lebih banyak; the button only shows after a failed load, so 'again' is carried by where it appears. | Cuba muatkan lebih banyak |
| clearSearch | Empty the search | Kosongkan carian is natural for clearing a field. No change. | No change. |

### Round 4: 4 keys, 4 listed

| Key | Back-translation | Problem | Fix |
|---|---|---|---|
| genreShooter | Shooting at each other (gunfight) | Back: 'shooting at each other'. The agent says it reads fine as a genre label. Kept. | No change. |
| genreFirstPersonShooter | First-Person Gunfight | 29 characters, and the Search tile is one line with an ellipsis. Its reading was also ambiguous ('the first person's gunfight'). Now Tembak-menembak FPS: the genre word plus the acronym Malaysian players use. | Tembak-menembak FPS |
| retryLoadingMore | Try to load more | 'Try to load more' dropped the retry, and it was over the room. Ruling: Cuba muatkan lagi. Lagi means both 'more' and 'again', and here both are true. Round 1 back-translated it as 'Try loading again'. | Cuba muatkan lagi |
| privacyPicturesBody | Game art and screenshots are loaded directly from the store's image server (img-eshop.cdn.nintendo.net). Your browser or phone requests each picture from that server, so Nintendo receives your internet address and the usual details of a request, under Nintendo's own privacy policy. Ringgit Radar does not store any pictures and does not hand them over to other parties. | Clean; the host name is kept. | No change. |

### Round 5: 2 keys, 2 listed

| Key | Back-translation | Problem | Fix |
|---|---|---|---|
| retryLoadingMore | Try loading again / Try loading more | Lagi means both. | No change: both readings are true for this button. |
| genreFirstPersonShooter | Shootout FPS | Part Malay, part acronym; "first-person" comes only from FPS. | No change: FPS is the name Malaysian players use, and the label must fit one line on the Search tile. |

### Round 6 (after the screenshot check and the translation review): 3 keys, 3 listed

The screenshots showed the Malay wish-list button drawn smaller than English: the bar scales a label that is wider than its room, and "Tambah ke Senarai Hajat" is 23 characters against about 16. fit_test now checks that every language's label is no wider than the English one. A consulting agent proposed short labels; it warned against "Hajat" on its own, which also calls up "buang hajat". The translation review found Malay rendering "System" two ways.

| Key | Back-translation | Problem | Fix |
|---|---|---|---|
| addToWishList | + Wish List | No verb; the + says "add". | No change: the glossary term kept whole, and the heart button sits on the game page. |
| onWishList | Saved / Stored / Kept | Doesn't name the list. | No change: it sits next to the filled heart, the app's only "save" is the wish list, and the full term would not fit. |
| themeSystem | Follow system | Was "Sistem" while the Language chip says "Ikut sistem". | Ikut sistem, so both chips match (zh already uses 跟随系统 for both). |

## Result

Chinese settled after round 4 and Malay after round 6. The last rounds read back the English meaning. Their remaining notes are style preferences that swapped from round to round, and the tables above give a ruling for each.
