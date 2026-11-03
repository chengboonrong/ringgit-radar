# Rating-descriptor filter test

Question: can a descriptor rule (Sexual Innuendo, Nudity, Sex) flag the adult-themed shovelware without hiding recognisable real games? Run against the real data in `eshop_radar` after the first age-rating import.

**Verdict: no rule is safe. `flagged` is left as the existing keyword regex.** Every rule below catches well-known games that are not shovelware (Street Fighter 6, Hades II, the Octopath Traveler games, Persona 5 Tactica, Xenoblade Chronicles X, Dispatch, Atelier Ryza, Coffee Talk, Gnosia, Reigns and more, all listed). The 18 rating is never used alone as a flag.

## Data

- Games in the catalogue (category game): 3927. With an age rating from the import: 3190. Without: 737.
- Games the keyword regex already flags: 75 (42 of them rated, 33 unrated, so no descriptor rule could reach those).
- Source: titledb GB.en (UK PEGI), matched by normalised title. Descriptors are PEGI content descriptors. Some source ratings look inconsistent (for example, Resident Evil 4 is 15 with no descriptors), so a rating is a hint, not a verdict.
- No product in the catalogue has Witcher in its title, so The Witcher 3 cannot be tested. Bayonetta (18 or 16, Bad Language and Violence, no sexual descriptor), Devil May Cry, DOOM, Mortal Kombat 11 and Persona 5 Royal carry no sexual descriptor, so they are not caught by any rule here. That is luck of the source labels, not a property of the rules: PEGI's `Sex` and `Nudity` also mark mainstream games, as the lists show.

## Rules tried

| Rule | Catches | Of which already flagged by keyword | Newly caught |
|---|---|---|---|
| R1: any of Sexual Innuendo, Nudity, Sex | 382 | 41 | 341 |
| R2: R1 and age <= 16 | 372 | 39 | 333 |
| R3: Sexual Innuendo | 227 | 37 | 190 |
| R4: Nudity | 82 | 2 | 80 |
| R5: Sex | 84 | 2 | 82 |
| R6: Sexual Innuendo as the only descriptor | 198 | 37 | 161 |
| R7: Sex or Nudity, and age <= 12 | 64 | 1 | 63 |
| R8: Nudity as the only descriptor, age <= 16 | 64 | 2 | 62 |

`Catches` counts rated games in the catalogue (a Switch and a Switch 2 listing of one title count twice).

## Who the newly caught games come from

**R1 (any of Sexual Innuendo, Nudity, Sex), newly caught only, top publishers:** eastasiasoft (53), Pakotime (44), Red Fables (43), 17Studio (41), KOEI TECMO GAMES (12), SQUARE ENIX (9), KEMCO (7), ARC SYSTEM WORKS (6), Big Way (6), Clouded Leopard Entertainment (6), G-MODE (5), iMel (5).

**R3 (Sexual Innuendo), newly caught only, top publishers:** Red Fables (43), 17Studio (41), eastasiasoft (23), G-MODE (5), KEMCO (5), KONAMI (4), OperaHouse (4), SOFT SOURCE (4), CIRCLE Ent. (3), CyberStep (3), iMel (3), BeXide (2).

## Recognisable games a rule would hide

| Game | Publisher | Age | Descriptors | Rules that catch it |
|---|---|---|---|---|
| Street Fighter™ 6 | CAPCOM | 12 | Bad Language / In-game purchases / Sex / Violence | R1, R2, R5, R7 |
| Hades II | Supergiant Games | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| Hades II – Nintendo Switch™ 2 Edition | Supergiant Games | 12 | Mild Swearing / Moderate Violence / Sexual Innuendo | R1, R2, R3 |
| Octopath Traveler™ | SQUARE ENIX | 12 | Bad Language / Sex | R1, R2, R5, R7 |
| Octopath Traveler™ | SQUARE ENIX | 12 | Bad Language / Sex | R1, R2, R5, R7 |
| OCTOPATH TRAVELER 0 | SQUARE ENIX | 12 | Bad Language / Horror / Sex / Violence | R1, R2, R5, R7 |
| OCTOPATH TRAVELER 0 | SQUARE ENIX | 12 | Bad Language / Horror / Sex / Violence | R1, R2, R5, R7 |
| OCTOPATH TRAVELER II | SQUARE ENIX | 12 | Bad Language / Sex | R1, R2, R5, R7 |
| OCTOPATH TRAVELER II | SQUARE ENIX | 12 | Bad Language / Sex | R1, R2, R5, R7 |
| Persona 5 Tactica | SEGA | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| Xenoblade Chronicles X: Definitive Edition | Nintendo | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| Xenoblade Chronicles X: Definitive Edition – Nintendo Switch 2 Edition | Nintendo | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| Dispatch | AdHoc Studio | 18 | Extreme Violence / In-game purchases / Nudity / Strong Language | R1, R4 |
| Dispatch Nintendo Switch 2 Edition | AdHoc Studio | 18 | Extreme Violence / In-game purchases / Nudity / Strong Language | R1, R4 |
| Atelier Ryza 2: Lost Legends & the Secret Fairy DX | KOEI TECMO GAMES | 12 | Sex / Violence | R1, R2, R5, R7 |
| Atelier Ryza 2: Lost Legends & the Secret Fairy DX | KOEI TECMO GAMES | 12 | Sex / Violence | R1, R2, R5, R7 |
| Atelier Ryza 3: Alchemist of the End & the Secret Key DX | KOEI TECMO GAMES | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| Atelier Ryza 3: Alchemist of the End & the Secret Key DX | KOEI TECMO GAMES | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| Atelier Ryza: Ever Darkness & the Secret Hideout DX | KOEI TECMO GAMES | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| Atelier Ryza: Ever Darkness & the Secret Hideout DX | KOEI TECMO GAMES | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| Atelier Yumia: The Alchemist of Memories & the Envisioned Land | KOEI TECMO GAMES | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| Atelier Yumia: The Alchemist of Memories & the Envisioned Land – Nintendo Switch 2 Edition | KOEI TECMO GAMES | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| Digimon Story Time Stranger | Bandai Namco Entertainment | 12 | Bad Language / In-game purchases / Sex | R1, R2, R5, R7 |
| Digimon Story Time Stranger | Bandai Namco Entertainment | 12 | Bad Language / In-game purchases / Sex | R1, R2, R5, R7 |
| Castlevania Dominus Collection | KONAMI | 12 | Horror / Sex / Violence | R1, R2, R5, R7 |
| DRAGON QUEST® XI S: Echoes of an Elusive Age – Definitive Edition | SQUARE ENIX | 12 | Gambling / Sex / Violence | R1, R2, R5, R7 |
| DRAGON QUEST XI S: Echoes of an Elusive Age - Definitive Edition | SQUARE ENIX | 12 | Gambling / Sex / Violence | R1, R2, R5, R7 |
| 13 Sentinels: Aegis Rim | SEGA | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| Coffee Talk | Chorus Worldwide Games | 12 | Mild Swearing / Sexual Innuendo | R1, R2, R3 |
| Gnosia | PLAYISM | 12 | Mild Swearing / Sexual Innuendo | R1, R2, R3 |
| Reigns: Beyond | Devolver Digital | 12 | Mild Swearing / Sexual Innuendo | R1, R2, R3 |
| Reigns: Three Kingdoms | Devolver Digital | 12 | Mild Swearing / Sexual Innuendo | R1, R2, R3 |
| Idol Manager | PLAYISM | 12 | Sexual Innuendo | R1, R2, R3, R6 |
| Loop Hero | Devolver Digital | 12 | Bad Language / Sex | R1, R2, R5, R7 |
| Ys IX -Monstrum NOX- | Clouded Leopard Entertainment | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| FAIRY TAIL | KOEI TECMO GAMES | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| FAIRY TAIL 2 | KOEI TECMO GAMES | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| Blacksad: Under the Skin | Microids | 16 | Bad Language / Drugs / Sex / Violence | R1, R2, R5 |
| Chaos on Deponia | Daedalic Entertainment | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| Deponia | Daedalic Entertainment | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| Deponia Doomsday | Daedalic Entertainment | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| Goodbye Deponia | Daedalic Entertainment | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| Super Nintendo Entertainment System – Nintendo Classics | Nintendo | 12 | Mild Swearing / Moderate Violence / Sexual Innuendo / Users Interact | R1, R2, R3 |
| Plunderer's Adventures | eastasiasoft | 16 | Nudity | R1, R2, R4, R8 |
| Milanoir | Good Shepherd | 18 | Nudity / Strong Language | R1, R4 |
| Twofold | refint/games | 12 | Sexual Innuendo | R1, R2, R3, R6 |
| Twofold – Nintendo Switch 2 Edition | refint/games | 12 | Sexual Innuendo | R1, R2, R3, R6 |
| Twofold: First Snow | refint/games | 16 | Sex | R1, R2, R5 |
| Moonlight Peaks | Clouded Leopard Entertainment | 12 | Sex | R1, R2, R5, R7 |
| Moonlight Peaks - Nintendo Switch 2 Edition | Clouded Leopard Entertainment | 12 | Sexual Innuendo | R1, R2, R3, R6 |
| Sunny Café | eastasiasoft | 12 | Sexual Innuendo | R1, R2, R3, R6 |
| BLUE REFLECTION Quartet | KOEI TECMO GAMES | 16 | Sex | R1, R2, R5 |
| BLUE REFLECTION Quartet | KOEI TECMO GAMES | 16 | Sex | R1, R2, R5 |
| RAIDOU Remastered: The Mystery of the Soulless Army | SEGA | 12 | Bad Language / Horror / In-game purchases / Sex / Violence | R1, R2, R5, R7 |
| RAIDOU Remastered: The Mystery of the Soulless Army | SEGA | 12 | Bad Language / Horror / In-game purchases / Sex / Violence | R1, R2, R5, R7 |
| Shining Resonance Refrain | SEGA | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| Gal Guardians: Demon Purge | Inti Creates | 12 | Bad Language / Sex / Violence | R1, R2, R5, R7 |
| Space Adventure Cobra - The Awakening | Microids | 12 | Sex / Violence | R1, R2, R5, R7 |
| The Rumble Fish 2 | 3goo | 12 | Sex / Violence | R1, R2, R5, R7 |
| The Rumble Fish 2 - Nintendo Switch 2 Edition | 3goo | 12 | Moderate Violence / Sexual Innuendo | R1, R2, R3 |
| Tales from Toyotoki: Arrival of the Witch | KEMCO | 12 | Bad Language / Sex | R1, R2, R5, R7 |
| The Witch's Bakery | Silver Lining | 12 | Bad Language / Sex | R1, R2, R5, R7 |
| The Witch's Bakery | Silver Lining | 12 | Bad Language / Sex | R1, R2, R5, R7 |

## Full lists

Format: title, publisher, age, descriptors. `[kw]` means the existing keyword regex already flags it. `(S2)` is a Switch 2 listing.

### R1: any of Sexual Innuendo, Nudity, Sex (382)

- Panty Match Girls, 17Studio, 12, Sexual Innuendo [kw]
- Anime Codex: Final Pose, 17Studio, 12, Sexual Innuendo
- Anime Codex: Shy Girls, 17Studio, 12, Sexual Innuendo
- Anime Codex: Triple Pleasure, 17Studio, 12, Sexual Innuendo
- Anime Codex: Whispered Lips, 17Studio, 12, Sexual Innuendo
- Bad Girls: Naughty Hands, 17Studio, 12, Sexual Innuendo
- Bad Girls: Sweet Trouble, 17Studio, 12, Sexual Innuendo
- Bad Girls: Tempting Night, 17Studio, 12, Sexual Innuendo
- Bikini Match Girls, 17Studio, 12, Sexual Innuendo
- Call of Beauty, 17Studio, 12, Sexual Innuendo
- Cyber Love Story, 17Studio, 12, Sexual Innuendo
- Dirty Little Puzzle, 17Studio, 12, Sexual Innuendo [kw]
- Doku Girls 2, 17Studio, 12, Sexual Innuendo
- Doku Girls 3, 17Studio, 12, Sexual Innuendo
- Double Trouble: Sexy Logic, 17Studio, 12, Sexual Innuendo [kw]
- Good Girls: Angels With Dirty Intentions, 17Studio, 12, Sexual Innuendo [kw]
- Good Girls: Seduction Starts With a Smile, 17Studio, 12, Sexual Innuendo
- Good Girls: Sweet Faces, 17Studio, 12, Sexual Innuendo
- Good Girls: Temptation in Disguise, 17Studio, 12, Sexual Innuendo
- Hentai Balls 3D: Heavy Attraction, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Balls 3D: Perfect Motion, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Balls 3D: Sexy Girls, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Balls 3D: Triple Trouble, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Banana, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Bikini, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Demon's Lullaby, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Gallery: Hidden Charms, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Gallery: Lovely Angels, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Girls Panic, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Girls Puzzle, 17Studio, 12, Sexual Innuendo [kw]
- Hentai House: Lost Rooms, 17Studio, 12, Sexual Innuendo [kw]
- Hentai House: Mystery Rooms, 17Studio, 12, Sexual Innuendo [kw]
- Hentai House: Next Door, 17Studio, 12, Sexual Innuendo [kw]
- Hentai House: Puzzle Nights, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Office Enigma, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Panty: Private Collection, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Project, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Protocol: Lesson One, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Puzzle Simulator, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Puzzle Simulator 2, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Puzzle Simulator 3, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Reality, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Reality 2, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Reality 3, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Succubus Serenade, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Tales Vol. 1, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Tales Vol. 2, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Tales Vol. 3, 17Studio, 12, Sexual Innuendo [kw]
- Hidden Girls: Bikini Dreams, 17Studio, 12, Sexual Innuendo
- Hidden Girls: Private Nights, 17Studio, 12, Sexual Innuendo
- Hidden Girls: Quiet Beauty, 17Studio, 12, Sexual Innuendo
- Hidden Girls: Secret Puzzle, 17Studio, 12, Sexual Innuendo
- Hidden Girls: Tropical Vibes, 17Studio, 12, Sexual Innuendo
- Hidden Pleasure: Deeper and Deeper, 17Studio, 12, Sexual Innuendo
- Hidden Pleasure: Faster and Faster, 17Studio, 12, Sexual Innuendo
- Hidden Pleasure: More and More, 17Studio, 12, Sexual Innuendo
- Photo Girls: First Session, 17Studio, 12, Sexual Innuendo
- Photo Girls: No Retouch, 17Studio, 12, Sexual Innuendo
- Photo Girls: Raw Photo, 17Studio, 12, Sexual Innuendo
- Photo Girls: Secret Footage, 17Studio, 12, Sexual Innuendo
- Pure Hentai: Dreams, 17Studio, 12, Sexual Innuendo [kw]
- Puzzle Girls: Dark Temptation, 17Studio, 12, Sexual Innuendo
- Puzzle Girls: Gentle Passion, 17Studio, 12, Sexual Innuendo
- Puzzle Girls: Inner Flame, 17Studio, 12, Sexual Innuendo
- Puzzle Girls: Seductive Nights, 17Studio, 12, Sexual Innuendo
- Real Girls: Burning Whisper, 17Studio, 12, Sexual Innuendo
- Real Girls: Midnight Desire, 17Studio, 12, Sexual Innuendo
- Real Girls: Velvet Flame, 17Studio, 12, Sexual Innuendo
- Sexy Erotic Xtreme Club, 17Studio, 12, Sexual Innuendo [kw]
- Snapshot Girls, 17Studio, 12, Sexual Innuendo
- Snapshot Girls 2, 17Studio, 12, Sexual Innuendo
- Snapshot Girls 3, 17Studio, 12, Sexual Innuendo
- The Last of Touch, 17Studio, 12, Sexual Innuendo
- Toilet Hero, 17Studio, 12, Sexual Innuendo
- Triple Trouble: Locker Room Secrets, 17Studio, 12, Sexual Innuendo
- Triple Trouble: Midnight Club, 17Studio, 12, Sexual Innuendo
- The Rumble Fish 2, 3goo, 12, Sex / Violence
- The Rumble Fish 2 - Nintendo Switch 2 Edition, 3goo, 12, Moderate Violence / Sexual Innuendo (S2)
- Dispatch, AdHoc Studio, 18, Extreme Violence / In-game purchases / Nudity / Strong Language
- Dispatch Nintendo Switch 2 Edition, AdHoc Studio, 18, Extreme Violence / In-game purchases / Nudity / Strong Language (S2)
- Future Knight, Aeternum Game Studios, 12, Sexual Innuendo
- Beholder: Conductor, Alawar Premium, 16, Sex / Strong Violence
- Lucky Tower Ultimate, AMC Games, 12, Sexual Innuendo
- LeMrosh in the Lazy Kingdom, AppsGears, 12, Nudity
- BLAZBLUE CENTRALFICTION Special Edition, ARC SYSTEM WORKS, 12, Bad Language / Fear / Sex / Violence
- DEMONS' NIGHT FEVER, ARC SYSTEM WORKS, 12, Bad Language / Sex / Violence
- Double Dragon Revive, ARC SYSTEM WORKS, 12, Bad Language / Sex / Violence
- GUILTY GEAR XX ACCENT CORE PLUS R, ARC SYSTEM WORKS, 12, Bad Language / Sex / Violence
- HUNTER×HUNTER NEN×IMPACT, ARC SYSTEM WORKS, 16, Sex / Violence
- KILL la KILL -IF, ARC SYSTEM WORKS, 16, Sex
- Digimon Story Time Stranger, Bandai Namco Entertainment, 12, Bad Language / In-game purchases / Sex (S2)
- Digimon Story Time Stranger, Bandai Namco Entertainment, 12, Bad Language / In-game purchases / Sex
- SUPER ROBOT WARS Y, Bandai Namco Entertainment, 12, Bad Language / In-game purchases / Sex / Violence
- Super Bullet Break, BeXide, 12, Sex
- The Fox's Way Home, BeXide, 12, Sexual Innuendo
- The Fox's Way Home – Nintendo Switch 2 Edition, BeXide, 12, Sexual Innuendo (S2)
- Anime: Fantasy Uni 2, Big Way, 12, Nudity
- Anime Uni 3D: Hot Vacay, Big Way, 12, Nudity
- Anime Video Puzzle, Big Way, 12, Sexual Innuendo
- Anime: Fantasy Uni, Big Way, 12, Nudity
- Anime: Fantasy Uni 3, Big Way, 12, Sexual Innuendo
- Damsels in Distress, Big Way, 12, Nudity
- Hentai Uni 5, Big Way, 12, Nudity [kw]
- Sailing Era, BILIBILI HK, 12, Sexual Innuendo
- Yog-Sothoth’s Yard, Bone Nail, 12, Sexual Innuendo
- Street Fighter™ 6, CAPCOM, 12, Bad Language / In-game purchases / Sex / Violence (S2)
- Coffee Talk, Chorus Worldwide Games, 12, Mild Swearing / Sexual Innuendo
- Mercenaries Lament: Requiem of the Silver Wolf, CIRCLE Ent., 12, Moderate Violence / Sexual Innuendo
- Mercenaries Wings: The False Phoenix, CIRCLE Ent., 12, Mild Swearing / Sexual Innuendo
- Runestone Keeper, CIRCLE Ent., 12, Sexual Innuendo
- Shadows of Adam, CIRCLE Ent., 12, Mild Swearing / Nudity
- City Hunter, Clouded Leopard Entertainment, 12, Bad Language / Sex / Violence
- City Hunter, Clouded Leopard Entertainment, 12, Bad Language / Sex / Violence (S2)
- DEMON GAZE EXTRA, Clouded Leopard Entertainment, 12, Bad Language / Sex
- Moonlight Peaks, Clouded Leopard Entertainment, 12, Sex
- Moonlight Peaks - Nintendo Switch 2 Edition, Clouded Leopard Entertainment, 12, Sexual Innuendo (S2)
- Ys IX -Monstrum NOX-, Clouded Leopard Entertainment, 12, Bad Language / Sex / Violence
- Speed Dates, COSEN, 12, Sexual Innuendo
- Speed Dates Summer Edition, COSEN, 12, Sexual Innuendo
- Demetrios - The BIG Cynical Adventure, COWCAT, 12, Mild Swearing / Sexual Innuendo
- After School .LIVE -Mirror of Twilight-, CyberStep, 12, Sexual Innuendo
- Rica Mode♡, CyberStep, 12, Sexual Innuendo
- Serena Hanazono’s Lost Item ～Sweet Memory～, CyberStep, 12, Sexual Innuendo
- Chaos on Deponia, Daedalic Entertainment, 12, Bad Language / Sex / Violence
- Deponia, Daedalic Entertainment, 12, Bad Language / Sex / Violence
- Deponia Doomsday, Daedalic Entertainment, 12, Bad Language / Sex / Violence
- Goodbye Deponia, Daedalic Entertainment, 12, Bad Language / Sex / Violence
- Loop Hero, Devolver Digital, 12, Bad Language / Sex
- Reigns: Beyond, Devolver Digital, 12, Mild Swearing / Sexual Innuendo
- Reigns: Three Kingdoms, Devolver Digital, 12, Mild Swearing / Sexual Innuendo
- 20 Ladies, eastasiasoft, 16, Nudity
- Another World Mahjong Girl, eastasiasoft, 12, Sexual Innuendo
- Bishoujo Battle Cyber Panic!, eastasiasoft, 12, Sexual Innuendo
- Bishoujo Battle Mahjong Solitaire, eastasiasoft, 12, Sexual Innuendo
- Boo Party, eastasiasoft, 16, Nudity
- Burning Secrets - A Bara Visual Novel, eastasiasoft, 16, Nudity / Sex / Strong Language
- Burrow of the Fallen Bear: A Gay Furry Visual Novel, eastasiasoft, 16, Sex / Strong Language
- Crawlco Block Knockers, eastasiasoft, 16, Nudity / Sex
- Crimson Spires, eastasiasoft, 16, Drugs / Nudity / Sex / Strong Language / Strong Violence
- Delicious! Pretty Girls Mahjong Solitaire, eastasiasoft, 16, Nudity
- Demoniaca: Everlasting Night, eastasiasoft, 18, Nudity
- Dreamcutter, eastasiasoft, 18, Sex / Strong Language
- Empire of Angels IV, eastasiasoft, 12, Moderate Violence / Sexual Innuendo
- Freezer Pops, eastasiasoft, 16, Sex / Strong Language
- Giant Wishes, eastasiasoft, 16, Nudity / Sex / Strong Language
- In the Mood, eastasiasoft, 16, Nudity
- Marble Maid, eastasiasoft, 16, Nudity / Sex
- Moe Waifu H, eastasiasoft, 12, Sexual Innuendo [kw]
- Moe Waifu H Genius, eastasiasoft, 12, Sexual Innuendo [kw]
- Moero Crystal H, eastasiasoft, 16, Nudity
- Mugen Souls, eastasiasoft, 18, Sex
- Mugen Souls Z, eastasiasoft, 18, Sex
- My Incubi Harem, eastasiasoft, 16, Sex / Strong Language
- Neko Journey, eastasiasoft, 16, Nudity
- Neko Secret Homecoming, eastasiasoft, 16, Nudity
- Neko Secret Room, eastasiasoft, 16, Nudity / Sex
- Plunderer's Adventures, eastasiasoft, 16, Nudity
- Pretty Girls 2048 Strike, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Breakers!, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Breakers! PLUS, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Escape, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Escape PLUS, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Four Kings Solitaire, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Klondike Solitaire, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Klondike Solitaire PLUS, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Mahjong Solitaire, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Mahjong Solitaire - Blue, eastasiasoft, 16, Nudity
- Pretty Girls Mahjong Solitaire - Green, eastasiasoft, 16, Nudity
- Pretty Girls Panic!, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Panic! PLUS, eastasiasoft, 16, Nudity
- Pretty Girls Pop Match, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Rivers, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Speed, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Tile Match, eastasiasoft, 12, Sexual Innuendo
- Rule No.1, eastasiasoft, 16, Nudity / Strong Language
- Saga of the Moon Priestess, eastasiasoft, 12, Sexual Innuendo
- Sense - A Cyberpunk Ghost Story, eastasiasoft, 12, Horror / Mild Swearing / Sexual Innuendo
- Seven Pirates H, eastasiasoft, 16, Nudity
- Shuttlecock-H, eastasiasoft, 16, Nudity / Sex
- Slime Girl Smoothies, eastasiasoft, 18, Sex / Strong Language / Use of Alcohol/Tobacco
- Sofiya and the Ancient Clan, eastasiasoft, 16, Nudity / Sex / Strong Language
- Sunny Café, eastasiasoft, 12, Sexual Innuendo
- Super XYX, eastasiasoft, 12, Sexual Innuendo
- Synthetic Lover, eastasiasoft, 16, Sex / Strong Language / Use of Alcohol/Tobacco
- Waifu Discovered 2: Medieval Fantasy, eastasiasoft, 18, Sex [kw]
- Waifu Uncovered, eastasiasoft, 18, Sex [kw]
- Wife Quest, eastasiasoft, 12, Mild Swearing / Sexual Innuendo
- Ambition of the Slimes, Flyhigh Works, 12, Sexual Innuendo
- Tayutama:It's happy days, Frontier Works, 12, Sexual Innuendo
- Can I Not Fall for Idols?, Futaba Games, 12, Sexual Innuendo
- Japan Stigmatized Property2 -日本事故物件監視協会-, G-MODE, 12, Horror / Sexual Innuendo
- KUUKIYOMI 2: Consider It More! - New Era, G-MODE, 12, Sexual Innuendo
- KUUKIYOMI 3: Consider It More and More!! - Father to Son, G-MODE, 12, Moderate Violence / Sexual Innuendo
- KUUKIYOMI 4: Consider It, G-MODE, 12, Sexual Innuendo
- KUUKIYOMI: Consider It World - Thailand Ver., G-MODE, 12, Sexual Innuendo
- In Trusted Hands, Games Harbor, 12, Sexual Innuendo
- CoffeeFox: Kim Samwol, GaniTani, 12, Sexual Innuendo
- DopePie Survivors 3D, GCHJ studio, 12, Sexual Innuendo
- Milanoir, Good Shepherd, 18, Nudity / Strong Language
- Oh...Sir! The Insult Simulator, Good Shepherd, 12, Mild Swearing / Sexual Innuendo
- Anime Love Chat Girls, GreenWookland Games, 12, Sexual Innuendo
- Caladrius Blaze, H2 INTERACTIVE, 12, Sexual Innuendo
- Love Too Easily 2: Summer Pocha, H2 INTERACTIVE, 12, Moderate Violence / Sexual Innuendo
- Artis Impact, Happinet Corporation, 12, Mild Swearing / Sexual Innuendo
- MAMIYA - A Shared Illusion of the World's End -, HuneX, 12, Horror / Sexual Innuendo
- SAEKO: Giantess Dating Sim, HYPER REAL, 12, Sexual Innuendo
- A Maiden Astrologer Divines the Future, iMel, 12, Nudity
- COSPLAY LOVE! Enchanted princess, iMel, 12, Sexual Innuendo
- Hot“Sento Girls”and love, iMel, 12, Sexual Innuendo
- Secret Kiss is Sweet and Tender, iMel, 12, Sexual Innuendo
- Virtual Maid Streamer Ramie, iMel, 16, Nudity / Sex / Strong Language
- Gal Guardians: Demon Purge, Inti Creates, 12, Bad Language / Sex / Violence
- Asdivine Knot, KEMCO, 12, In-game purchases / Moderate Violence / Sexual Innuendo
- Asdivine Knot - Nintendo Switch 2 Edition, KEMCO, 12, In-game purchases / Moderate Violence / Sexual Innuendo (S2)
- Chrome Wolf, KEMCO, 12, In-game purchases / Sexual Innuendo
- Dragon Ruins II, KEMCO, 12, Sexual Innuendo
- Genso Chronicles, KEMCO, 12, Sexual Innuendo
- Horrific Xanatorium, KEMCO, 16, Horror / Nudity
- Tales from Toyotoki: Arrival of the Witch, KEMCO, 12, Bad Language / Sex (S2)
- Atelier Ryza 2: Lost Legends & the Secret Fairy DX, KOEI TECMO GAMES, 12, Sex / Violence
- Atelier Ryza 2: Lost Legends & the Secret Fairy DX, KOEI TECMO GAMES, 12, Sex / Violence (S2)
- Atelier Ryza 3: Alchemist of the End & the Secret Key DX, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence
- Atelier Ryza 3: Alchemist of the End & the Secret Key DX, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence (S2)
- Atelier Ryza: Ever Darkness & the Secret Hideout DX, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence
- Atelier Ryza: Ever Darkness & the Secret Hideout DX, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence (S2)
- Atelier Yumia: The Alchemist of Memories & the Envisioned Land, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence
- Atelier Yumia: The Alchemist of Memories & the Envisioned Land – Nintendo Switch 2 Edition, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence (S2)
- BLUE REFLECTION Quartet, KOEI TECMO GAMES, 16, Sex
- BLUE REFLECTION Quartet, KOEI TECMO GAMES, 16, Sex (S2)
- FAIRY TAIL, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence
- FAIRY TAIL 2, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence
- Castlevania Dominus Collection, KONAMI, 12, Horror / Sex / Violence
- The Prince of Tennis Doki Doki Survival ~eternal passion! Tie break ♡ game~, KONAMI, 12, Sexual Innuendo
- The Prince of Tennis Doki Doki Survival ~eternal passion! Tie break ♡ game~ Nintendo Switch 2 Edition, KONAMI, 12, Sexual Innuendo (S2)
- The Prince of Tennis Sweet School Festival ~♡-40 and more...~, KONAMI, 12, Sexual Innuendo
- The Prince of Tennis Sweet School Festival ~♡-40 and more...~ Nintendo Switch 2 Edition, KONAMI, 12, Sexual Innuendo (S2)
- Half Billion: Love Choice, Kunyu Studio, 12, Sexual Innuendo
- Fractured Worlds, Laser Guided Games, 12, Mild Swearing / Moderate Violence / Sexual Innuendo / Users Interact
- What have you done, father?, Making Port, 16, Nudity / Sex / Strong Violence (S2)
- What have you done, father?, Making Port, 16, Nudity / Sex / Strong Violence
- Majotori, Mameshiba Games, 12, Sexual Innuendo
- Blacksad: Under the Skin, Microids, 16, Bad Language / Drugs / Sex / Violence
- Space Adventure Cobra - The Awakening, Microids, 12, Sex / Violence
- Night Swarm, NAISU, 12, Moderate Violence / Sexual Innuendo
- The Palace on the Hill, Niku Games, 12, Sexual Innuendo
- Super Nintendo Entertainment System – Nintendo Classics, Nintendo, 12, Mild Swearing / Moderate Violence / Sexual Innuendo / Users Interact
- Xenoblade Chronicles X: Definitive Edition, Nintendo, 12, Bad Language / Sex / Violence
- Xenoblade Chronicles X: Definitive Edition – Nintendo Switch 2 Edition, Nintendo, 12, Bad Language / Sex / Violence (S2)
- Love is all around, NiuGamer, 12, Mild Swearing / Sexual Innuendo
- Blast Linkers, ODDCADIA, 12, Sexual Innuendo
- Byakko-tai Samurai Boys, OperaHouse, 12, Sexual Innuendo
- Dateless Love - Love Story Behind the Restoration -, OperaHouse, 12, Sexual Innuendo
- Diamond Girl ★An Earnest Education in Love★, OperaHouse, 12, Sexual Innuendo
- Princess Closet - Fashion and love will change me -, OperaHouse, 12, Sexual Innuendo
- Dosa Divas, Outerloop Games, 12, Mild Swearing / Sexual Innuendo (S2)
- Dosa Divas, Outerloop Games, 12, Mild Swearing / Sexual Innuendo
- Anime Girls: Awesome Adventurer, Pakotime, 16, Nudity
- Anime Girls: Beautiful Bride, Pakotime, 16, Nudity
- Anime Girls: Bouncy Basketball, Pakotime, 16, Nudity
- Anime Girls: Busty Baseball, Pakotime, 16, Nudity
- Anime Girls: Cheerful Cosplay, Pakotime, 16, Nudity
- Anime Girls: Clever Clover, Pakotime, 16, Nudity
- Anime Girls: College Love, Pakotime, 16, Nudity
- Anime Girls: Gorgeous Girlfriend, Pakotime, 16, Nudity
- Anime Girls: Graceful Goddess, Pakotime, 16, Nudity
- Anime Girls: Lady Liberty, Pakotime, 16, Nudity
- Anime Girls: Lovely Lolita, Pakotime, 16, Nudity
- Anime Girls: Natty New Year, Pakotime, 16, Nudity
- Anime Girls: Natty Nurse, Pakotime, 16, Nudity
- Anime Girls: Naughty Neko, Pakotime, 16, Nudity
- Anime Girls: Nimble Ninja, Pakotime, 16, Nudity
- Anime Girls: Sakura Love, Pakotime, 16, Nudity
- Anime Girls: Shanghai Romance, Pakotime, 16, Nudity
- Anime Girls: Summer Vacay, Pakotime, 16, Nudity
- Anime Girls: Tokyo Christmas, Pakotime, 16, Nudity
- Kawaii Girls: Vegas Romance, Pakotime, 16, Nudity
- Sugoi Girls: Attractive Archer, Pakotime, 16, Nudity
- Sugoi Girls: Clover Crush, Pakotime, 16, Nudity
- Sugoi Girls: Delhi Darling, Pakotime, 16, Nudity
- Sugoi Girls: Dental Darling, Pakotime, 16, Nudity
- Sugoi Girls: Dragon Love, Pakotime, 16, Nudity
- Sugoi Girls: Enchanting Elf, Pakotime, 16, Nudity
- Sugoi Girls: Exotic Egypt, Pakotime, 16, Nudity
- Sugoi Girls: Firefighter Love, Pakotime, 16, Nudity
- Sugoi Girls: Kinky Knight, Pakotime, 16, Nudity
- Sugoi Girls: Lovely Wife, Pakotime, 16, Nudity
- Sugoi Girls: Pretty Party, Pakotime, 16, Nudity
- Sugoi Girls: Pretty Patriot, Pakotime, 16, Nudity
- Sugoi Girls: Sassy Heroine, Pakotime, 16, Nudity
- Sugoi Girls: Sassy Spy, Pakotime, 16, Nudity
- Sugoi Girls: Sexy Steampunk, Pakotime, 16, Nudity [kw]
- Sugoi Girls: Tribal Crush, Pakotime, 16, Nudity
- Sugoi Girls: Victoria Vogue, Pakotime, 16, Nudity
- Sugoi Girls: Vivacious Vampire, Pakotime, 16, Nudity
- Yabai Girls: Ballet Beauty, Pakotime, 16, Nudity
- Yabai Girls: Elegant Egyptian, Pakotime, 16, Nudity
- Yabai Girls: Fairy Love, Pakotime, 16, Nudity
- Yabai Girls: Heavenly Homemaker, Pakotime, 16, Nudity
- Yabai Girls: Hot Hiker, Pakotime, 16, Nudity
- Yabai Girls: Saucy Police, Pakotime, 16, Nudity
- Yabai Girls: Valentine Babe, Pakotime, 16, Nudity
- Gnosia, PLAYISM, 12, Mild Swearing / Sexual Innuendo
- Idol Manager, PLAYISM, 12, Sexual Innuendo
- Arcade Spirits, PQube, 12, Sex
- Celestia: Chain of Fate, PQube, 12, Bad Language / Sex
- Kotodama: The 7 Mysteries of Fujisawa, PQube, 12, Bad Language / Sex
- Harmonia, PROTOTYPE, 12, Mild Swearing / Sexual Innuendo
- LUNARiA -Virtualized Moonchild-, PROTOTYPE, 12, Sexual Innuendo
- Anime Feet Boys: The Charm Finder Quest, Red Fables, 12, Sexual Innuendo
- Anime Feet Girls: The Charm Finder Quest, Red Fables, 12, Sexual Innuendo
- Anime School Love: Her Teacher's Secret Lesson, Red Fables, 12, Sexual Innuendo
- Anime School Love: His Teacher Secret Lesson, Red Fables, 12, Sexual Innuendo
- Beach Volleyball Boys: Hot Spike, Red Fables, 12, Sexual Innuendo
- Bug Error 404: Anime Boys Not Found, Red Fables, 12, Sexual Innuendo
- Criminal Hearts: Obsession Bad Boys Dating Sim, Red Fables, 12, Sexual Innuendo
- Dangerous Superheroes After Dark: Heroes Behind the Mask, Red Fables, 12, Sexual Innuendo
- Dangerous Superheroes After Dark: Heroines Behind the Mask, Red Fables, 12, Sexual Innuendo
- Dino Evolution: Catch Dinosaurs and Raise Anime Primeval Boys, Red Fables, 12, Sexual Innuendo
- Dino Evolution: Catch Dinosaurs and Raise Anime Primeval Girls, Red Fables, 12, Sexual Innuendo
- Farm Love Legend: Transform your Animals into Anime Boys, Red Fables, 12, Sexual Innuendo
- Furry Girls Paradise: Love & Fun, Red Fables, 12, Sexual Innuendo
- Furry Pride Paradise Love & Fun, Red Fables, 12, Sexual Innuendo
- Geisha's Heart: Romance Among the Cherry Blossoms, Red Fables, 12, Sexual Innuendo
- Hospital Romance: Anime Doctor Crush, Red Fables, 12, Sexual Innuendo
- Hospital Romance: Anime Nurse Crush, Red Fables, 12, Sexual Innuendo
- Kawaii Anime: Cute Boys Magic World, Red Fables, 12, Sexual Innuendo
- Kawaii Anime: Cute Girls Magic World, Red Fables, 12, Sexual Innuendo
- Love Island: Forbidden Boys Temptation, Red Fables, 12, Sexual Innuendo
- Maid-Sama Cafe: Anime Boys Services in Cute Outfits, Red Fables, 12, Sexual Innuendo
- Mermaid Catch: Transform Sirens into Anime Boys, Red Fables, 12, Sexual Innuendo
- Mermaid Catch: Transform Sirens into Anime Girls, Red Fables, 12, Sexual Innuendo
- Mom Crush: Hidden Hotel Love Story, Red Fables, 12, Sexual Innuendo
- Pixel Hunters: Turn Retro Consoles into your Boyfriend, Red Fables, 12, Sexual Innuendo
- Pool Party Boys: Splash Guys, Red Fables, 12, Sexual Innuendo
- Pool Party Girls: Splash Babes, Red Fables, 12, Sexual Innuendo
- Prince Date Diaries: A Fairy Tale Love, Red Fables, 12, Sexual Innuendo
- Princess Date Diaries: A Fairy Tale Love, Red Fables, 12, Sexual Innuendo
- Samurai Shoguns Heart: Romance Among the Cherry Blossoms, Red Fables, 12, Sexual Innuendo
- Seven Deadly Sins: Anime Boys Fantasy Love, Red Fables, 12, Sexual Innuendo
- Spa Massage Boys: Love & Relax, Red Fables, 12, Sexual Innuendo
- Sugar Daddy Crush: Hidden Hotel Love Story, Red Fables, 12, Sexual Innuendo
- The Arcana: Dark Tarot & Kings of Madness, Red Fables, 12, Sexual Innuendo
- The Arcana: Dark Tarot & Queens of Madness, Red Fables, 12, Sexual Innuendo
- Therian Crush: Wild Animal Boys, Red Fables, 12, Sexual Innuendo
- Tokyo Yakuza Idols: Save the Heart of a Rebel Boy, Red Fables, 12, Sexual Innuendo
- Tokyo Yakuza Idols: Save the Heart of a Rebel Girl, Red Fables, 12, Sexual Innuendo
- Vampire Boys Love Story: Date or Die, Red Fables, 12, Sexual Innuendo
- Vampire Girls Love Story: Date or Die, Red Fables, 12, Sexual Innuendo
- Villain Boys: Date the Dark Side, Red Fables, 12, Sexual Innuendo
- Youtuber Boys: Love Behind the Camera, Red Fables, 12, Sexual Innuendo
- Zombie Hearts: Turn the Undead into Anime Boys, Red Fables, 12, Sexual Innuendo
- Twofold, refint/games, 12, Sexual Innuendo
- Twofold – Nintendo Switch 2 Edition, refint/games, 12, Sexual Innuendo (S2)
- Twofold: First Snow, refint/games, 16, Sex
- CAFE 0 ~The Sleeping Beast~ REMASTERED, ROSEVERTE, 12, Sexual Innuendo
- How to Sing to Open Your Heart Remastered, ROSEVERTE, 12, Sexual Innuendo
- 13 Sentinels: Aegis Rim, SEGA, 12, Bad Language / Sex / Violence
- Persona 5 Tactica, SEGA, 12, Bad Language / Sex / Violence
- RAIDOU Remastered: The Mystery of the Soulless Army, SEGA, 12, Bad Language / Horror / In-game purchases / Sex / Violence
- RAIDOU Remastered: The Mystery of the Soulless Army, SEGA, 12, Bad Language / Horror / In-game purchases / Sex / Violence (S2)
- Shining Resonance Refrain, SEGA, 12, Bad Language / Sex / Violence
- The Witch's Bakery, Silver Lining, 12, Bad Language / Sex
- The Witch's Bakery, Silver Lining, 12, Bad Language / Sex (S2)
- Fetch Quest Remastered, SOFT SOURCE, 12, Sexual Innuendo
- Fetch Re:Quest, SOFT SOURCE, 12, Sexual Innuendo
- Matchmaker Agency, SOFT SOURCE, 12, Sexual Innuendo
- Pirated Code: Admin Edition, SOFT SOURCE, 12, Sexual Innuendo
- BRAVELY DEFAULT FLYING FAIRY HD Remaster, SQUARE ENIX, 12, Sex / Violence (S2)
- DRAGON QUEST® XI S: Echoes of an Elusive Age – Definitive Edition, SQUARE ENIX, 12, Gambling / Sex / Violence
- DRAGON QUEST XI S: Echoes of an Elusive Age - Definitive Edition, SQUARE ENIX, 12, Gambling / Sex / Violence (S2)
- Octopath Traveler™, SQUARE ENIX, 12, Bad Language / Sex (S2)
- Octopath Traveler™, SQUARE ENIX, 12, Bad Language / Sex
- OCTOPATH TRAVELER 0, SQUARE ENIX, 12, Bad Language / Horror / Sex / Violence
- OCTOPATH TRAVELER 0, SQUARE ENIX, 12, Bad Language / Horror / Sex / Violence (S2)
- OCTOPATH TRAVELER II, SQUARE ENIX, 12, Bad Language / Sex
- OCTOPATH TRAVELER II, SQUARE ENIX, 12, Bad Language / Sex (S2)
- Five Hearts Under One Roof, StoryTaco, 12, In-game purchases / Sexual Innuendo
- Blossom Voyage, Sunjoy Game, 12, Sexual Innuendo
- Hades II, Supergiant Games, 12, Bad Language / Sex / Violence
- Hades II – Nintendo Switch™ 2 Edition, Supergiant Games, 12, Mild Swearing / Moderate Violence / Sexual Innuendo (S2)
- Love and Legends, Voltage, 12, Sexual Innuendo
- Jesus Simulator, VRCFORGE STUDIOS, 12, Sexual Innuendo

### R2: R1 and age <= 16 (372)

Same as R1 minus these 10 games rated above 16 (so every game in R1 not listed here is in R2):

- Dispatch, AdHoc Studio, 18, Extreme Violence / In-game purchases / Nudity / Strong Language
- Dispatch Nintendo Switch 2 Edition, AdHoc Studio, 18, Extreme Violence / In-game purchases / Nudity / Strong Language (S2)
- Demoniaca: Everlasting Night, eastasiasoft, 18, Nudity
- Dreamcutter, eastasiasoft, 18, Sex / Strong Language
- Mugen Souls, eastasiasoft, 18, Sex
- Mugen Souls Z, eastasiasoft, 18, Sex
- Slime Girl Smoothies, eastasiasoft, 18, Sex / Strong Language / Use of Alcohol/Tobacco
- Waifu Discovered 2: Medieval Fantasy, eastasiasoft, 18, Sex [kw]
- Waifu Uncovered, eastasiasoft, 18, Sex [kw]
- Milanoir, Good Shepherd, 18, Nudity / Strong Language

### R3: Sexual Innuendo (227)

- Panty Match Girls, 17Studio, 12, Sexual Innuendo [kw]
- Anime Codex: Final Pose, 17Studio, 12, Sexual Innuendo
- Anime Codex: Shy Girls, 17Studio, 12, Sexual Innuendo
- Anime Codex: Triple Pleasure, 17Studio, 12, Sexual Innuendo
- Anime Codex: Whispered Lips, 17Studio, 12, Sexual Innuendo
- Bad Girls: Naughty Hands, 17Studio, 12, Sexual Innuendo
- Bad Girls: Sweet Trouble, 17Studio, 12, Sexual Innuendo
- Bad Girls: Tempting Night, 17Studio, 12, Sexual Innuendo
- Bikini Match Girls, 17Studio, 12, Sexual Innuendo
- Call of Beauty, 17Studio, 12, Sexual Innuendo
- Cyber Love Story, 17Studio, 12, Sexual Innuendo
- Dirty Little Puzzle, 17Studio, 12, Sexual Innuendo [kw]
- Doku Girls 2, 17Studio, 12, Sexual Innuendo
- Doku Girls 3, 17Studio, 12, Sexual Innuendo
- Double Trouble: Sexy Logic, 17Studio, 12, Sexual Innuendo [kw]
- Good Girls: Angels With Dirty Intentions, 17Studio, 12, Sexual Innuendo [kw]
- Good Girls: Seduction Starts With a Smile, 17Studio, 12, Sexual Innuendo
- Good Girls: Sweet Faces, 17Studio, 12, Sexual Innuendo
- Good Girls: Temptation in Disguise, 17Studio, 12, Sexual Innuendo
- Hentai Balls 3D: Heavy Attraction, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Balls 3D: Perfect Motion, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Balls 3D: Sexy Girls, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Balls 3D: Triple Trouble, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Banana, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Bikini, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Demon's Lullaby, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Gallery: Hidden Charms, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Gallery: Lovely Angels, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Girls Panic, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Girls Puzzle, 17Studio, 12, Sexual Innuendo [kw]
- Hentai House: Lost Rooms, 17Studio, 12, Sexual Innuendo [kw]
- Hentai House: Mystery Rooms, 17Studio, 12, Sexual Innuendo [kw]
- Hentai House: Next Door, 17Studio, 12, Sexual Innuendo [kw]
- Hentai House: Puzzle Nights, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Office Enigma, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Panty: Private Collection, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Project, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Protocol: Lesson One, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Puzzle Simulator, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Puzzle Simulator 2, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Puzzle Simulator 3, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Reality, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Reality 2, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Reality 3, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Succubus Serenade, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Tales Vol. 1, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Tales Vol. 2, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Tales Vol. 3, 17Studio, 12, Sexual Innuendo [kw]
- Hidden Girls: Bikini Dreams, 17Studio, 12, Sexual Innuendo
- Hidden Girls: Private Nights, 17Studio, 12, Sexual Innuendo
- Hidden Girls: Quiet Beauty, 17Studio, 12, Sexual Innuendo
- Hidden Girls: Secret Puzzle, 17Studio, 12, Sexual Innuendo
- Hidden Girls: Tropical Vibes, 17Studio, 12, Sexual Innuendo
- Hidden Pleasure: Deeper and Deeper, 17Studio, 12, Sexual Innuendo
- Hidden Pleasure: Faster and Faster, 17Studio, 12, Sexual Innuendo
- Hidden Pleasure: More and More, 17Studio, 12, Sexual Innuendo
- Photo Girls: First Session, 17Studio, 12, Sexual Innuendo
- Photo Girls: No Retouch, 17Studio, 12, Sexual Innuendo
- Photo Girls: Raw Photo, 17Studio, 12, Sexual Innuendo
- Photo Girls: Secret Footage, 17Studio, 12, Sexual Innuendo
- Pure Hentai: Dreams, 17Studio, 12, Sexual Innuendo [kw]
- Puzzle Girls: Dark Temptation, 17Studio, 12, Sexual Innuendo
- Puzzle Girls: Gentle Passion, 17Studio, 12, Sexual Innuendo
- Puzzle Girls: Inner Flame, 17Studio, 12, Sexual Innuendo
- Puzzle Girls: Seductive Nights, 17Studio, 12, Sexual Innuendo
- Real Girls: Burning Whisper, 17Studio, 12, Sexual Innuendo
- Real Girls: Midnight Desire, 17Studio, 12, Sexual Innuendo
- Real Girls: Velvet Flame, 17Studio, 12, Sexual Innuendo
- Sexy Erotic Xtreme Club, 17Studio, 12, Sexual Innuendo [kw]
- Snapshot Girls, 17Studio, 12, Sexual Innuendo
- Snapshot Girls 2, 17Studio, 12, Sexual Innuendo
- Snapshot Girls 3, 17Studio, 12, Sexual Innuendo
- The Last of Touch, 17Studio, 12, Sexual Innuendo
- Toilet Hero, 17Studio, 12, Sexual Innuendo
- Triple Trouble: Locker Room Secrets, 17Studio, 12, Sexual Innuendo
- Triple Trouble: Midnight Club, 17Studio, 12, Sexual Innuendo
- The Rumble Fish 2 - Nintendo Switch 2 Edition, 3goo, 12, Moderate Violence / Sexual Innuendo (S2)
- Future Knight, Aeternum Game Studios, 12, Sexual Innuendo
- Lucky Tower Ultimate, AMC Games, 12, Sexual Innuendo
- The Fox's Way Home, BeXide, 12, Sexual Innuendo
- The Fox's Way Home – Nintendo Switch 2 Edition, BeXide, 12, Sexual Innuendo (S2)
- Anime Video Puzzle, Big Way, 12, Sexual Innuendo
- Anime: Fantasy Uni 3, Big Way, 12, Sexual Innuendo
- Sailing Era, BILIBILI HK, 12, Sexual Innuendo
- Yog-Sothoth’s Yard, Bone Nail, 12, Sexual Innuendo
- Coffee Talk, Chorus Worldwide Games, 12, Mild Swearing / Sexual Innuendo
- Mercenaries Lament: Requiem of the Silver Wolf, CIRCLE Ent., 12, Moderate Violence / Sexual Innuendo
- Mercenaries Wings: The False Phoenix, CIRCLE Ent., 12, Mild Swearing / Sexual Innuendo
- Runestone Keeper, CIRCLE Ent., 12, Sexual Innuendo
- Moonlight Peaks - Nintendo Switch 2 Edition, Clouded Leopard Entertainment, 12, Sexual Innuendo (S2)
- Speed Dates, COSEN, 12, Sexual Innuendo
- Speed Dates Summer Edition, COSEN, 12, Sexual Innuendo
- Demetrios - The BIG Cynical Adventure, COWCAT, 12, Mild Swearing / Sexual Innuendo
- After School .LIVE -Mirror of Twilight-, CyberStep, 12, Sexual Innuendo
- Rica Mode♡, CyberStep, 12, Sexual Innuendo
- Serena Hanazono’s Lost Item ～Sweet Memory～, CyberStep, 12, Sexual Innuendo
- Reigns: Beyond, Devolver Digital, 12, Mild Swearing / Sexual Innuendo
- Reigns: Three Kingdoms, Devolver Digital, 12, Mild Swearing / Sexual Innuendo
- Another World Mahjong Girl, eastasiasoft, 12, Sexual Innuendo
- Bishoujo Battle Cyber Panic!, eastasiasoft, 12, Sexual Innuendo
- Bishoujo Battle Mahjong Solitaire, eastasiasoft, 12, Sexual Innuendo
- Empire of Angels IV, eastasiasoft, 12, Moderate Violence / Sexual Innuendo
- Moe Waifu H, eastasiasoft, 12, Sexual Innuendo [kw]
- Moe Waifu H Genius, eastasiasoft, 12, Sexual Innuendo [kw]
- Pretty Girls 2048 Strike, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Breakers!, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Breakers! PLUS, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Escape, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Escape PLUS, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Four Kings Solitaire, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Klondike Solitaire, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Klondike Solitaire PLUS, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Mahjong Solitaire, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Panic!, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Pop Match, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Rivers, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Speed, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Tile Match, eastasiasoft, 12, Sexual Innuendo
- Saga of the Moon Priestess, eastasiasoft, 12, Sexual Innuendo
- Sense - A Cyberpunk Ghost Story, eastasiasoft, 12, Horror / Mild Swearing / Sexual Innuendo
- Sunny Café, eastasiasoft, 12, Sexual Innuendo
- Super XYX, eastasiasoft, 12, Sexual Innuendo
- Wife Quest, eastasiasoft, 12, Mild Swearing / Sexual Innuendo
- Ambition of the Slimes, Flyhigh Works, 12, Sexual Innuendo
- Tayutama:It's happy days, Frontier Works, 12, Sexual Innuendo
- Can I Not Fall for Idols?, Futaba Games, 12, Sexual Innuendo
- Japan Stigmatized Property2 -日本事故物件監視協会-, G-MODE, 12, Horror / Sexual Innuendo
- KUUKIYOMI 2: Consider It More! - New Era, G-MODE, 12, Sexual Innuendo
- KUUKIYOMI 3: Consider It More and More!! - Father to Son, G-MODE, 12, Moderate Violence / Sexual Innuendo
- KUUKIYOMI 4: Consider It, G-MODE, 12, Sexual Innuendo
- KUUKIYOMI: Consider It World - Thailand Ver., G-MODE, 12, Sexual Innuendo
- In Trusted Hands, Games Harbor, 12, Sexual Innuendo
- CoffeeFox: Kim Samwol, GaniTani, 12, Sexual Innuendo
- DopePie Survivors 3D, GCHJ studio, 12, Sexual Innuendo
- Oh...Sir! The Insult Simulator, Good Shepherd, 12, Mild Swearing / Sexual Innuendo
- Anime Love Chat Girls, GreenWookland Games, 12, Sexual Innuendo
- Caladrius Blaze, H2 INTERACTIVE, 12, Sexual Innuendo
- Love Too Easily 2: Summer Pocha, H2 INTERACTIVE, 12, Moderate Violence / Sexual Innuendo
- Artis Impact, Happinet Corporation, 12, Mild Swearing / Sexual Innuendo
- MAMIYA - A Shared Illusion of the World's End -, HuneX, 12, Horror / Sexual Innuendo
- SAEKO: Giantess Dating Sim, HYPER REAL, 12, Sexual Innuendo
- COSPLAY LOVE! Enchanted princess, iMel, 12, Sexual Innuendo
- Hot“Sento Girls”and love, iMel, 12, Sexual Innuendo
- Secret Kiss is Sweet and Tender, iMel, 12, Sexual Innuendo
- Asdivine Knot, KEMCO, 12, In-game purchases / Moderate Violence / Sexual Innuendo
- Asdivine Knot - Nintendo Switch 2 Edition, KEMCO, 12, In-game purchases / Moderate Violence / Sexual Innuendo (S2)
- Chrome Wolf, KEMCO, 12, In-game purchases / Sexual Innuendo
- Dragon Ruins II, KEMCO, 12, Sexual Innuendo
- Genso Chronicles, KEMCO, 12, Sexual Innuendo
- The Prince of Tennis Doki Doki Survival ~eternal passion! Tie break ♡ game~, KONAMI, 12, Sexual Innuendo
- The Prince of Tennis Doki Doki Survival ~eternal passion! Tie break ♡ game~ Nintendo Switch 2 Edition, KONAMI, 12, Sexual Innuendo (S2)
- The Prince of Tennis Sweet School Festival ~♡-40 and more...~, KONAMI, 12, Sexual Innuendo
- The Prince of Tennis Sweet School Festival ~♡-40 and more...~ Nintendo Switch 2 Edition, KONAMI, 12, Sexual Innuendo (S2)
- Half Billion: Love Choice, Kunyu Studio, 12, Sexual Innuendo
- Fractured Worlds, Laser Guided Games, 12, Mild Swearing / Moderate Violence / Sexual Innuendo / Users Interact
- Majotori, Mameshiba Games, 12, Sexual Innuendo
- Night Swarm, NAISU, 12, Moderate Violence / Sexual Innuendo
- The Palace on the Hill, Niku Games, 12, Sexual Innuendo
- Super Nintendo Entertainment System – Nintendo Classics, Nintendo, 12, Mild Swearing / Moderate Violence / Sexual Innuendo / Users Interact
- Love is all around, NiuGamer, 12, Mild Swearing / Sexual Innuendo
- Blast Linkers, ODDCADIA, 12, Sexual Innuendo
- Byakko-tai Samurai Boys, OperaHouse, 12, Sexual Innuendo
- Dateless Love - Love Story Behind the Restoration -, OperaHouse, 12, Sexual Innuendo
- Diamond Girl ★An Earnest Education in Love★, OperaHouse, 12, Sexual Innuendo
- Princess Closet - Fashion and love will change me -, OperaHouse, 12, Sexual Innuendo
- Dosa Divas, Outerloop Games, 12, Mild Swearing / Sexual Innuendo
- Dosa Divas, Outerloop Games, 12, Mild Swearing / Sexual Innuendo (S2)
- Gnosia, PLAYISM, 12, Mild Swearing / Sexual Innuendo
- Idol Manager, PLAYISM, 12, Sexual Innuendo
- Harmonia, PROTOTYPE, 12, Mild Swearing / Sexual Innuendo
- LUNARiA -Virtualized Moonchild-, PROTOTYPE, 12, Sexual Innuendo
- Anime Feet Boys: The Charm Finder Quest, Red Fables, 12, Sexual Innuendo
- Anime Feet Girls: The Charm Finder Quest, Red Fables, 12, Sexual Innuendo
- Anime School Love: Her Teacher's Secret Lesson, Red Fables, 12, Sexual Innuendo
- Anime School Love: His Teacher Secret Lesson, Red Fables, 12, Sexual Innuendo
- Beach Volleyball Boys: Hot Spike, Red Fables, 12, Sexual Innuendo
- Bug Error 404: Anime Boys Not Found, Red Fables, 12, Sexual Innuendo
- Criminal Hearts: Obsession Bad Boys Dating Sim, Red Fables, 12, Sexual Innuendo
- Dangerous Superheroes After Dark: Heroes Behind the Mask, Red Fables, 12, Sexual Innuendo
- Dangerous Superheroes After Dark: Heroines Behind the Mask, Red Fables, 12, Sexual Innuendo
- Dino Evolution: Catch Dinosaurs and Raise Anime Primeval Boys, Red Fables, 12, Sexual Innuendo
- Dino Evolution: Catch Dinosaurs and Raise Anime Primeval Girls, Red Fables, 12, Sexual Innuendo
- Farm Love Legend: Transform your Animals into Anime Boys, Red Fables, 12, Sexual Innuendo
- Furry Girls Paradise: Love & Fun, Red Fables, 12, Sexual Innuendo
- Furry Pride Paradise Love & Fun, Red Fables, 12, Sexual Innuendo
- Geisha's Heart: Romance Among the Cherry Blossoms, Red Fables, 12, Sexual Innuendo
- Hospital Romance: Anime Doctor Crush, Red Fables, 12, Sexual Innuendo
- Hospital Romance: Anime Nurse Crush, Red Fables, 12, Sexual Innuendo
- Kawaii Anime: Cute Boys Magic World, Red Fables, 12, Sexual Innuendo
- Kawaii Anime: Cute Girls Magic World, Red Fables, 12, Sexual Innuendo
- Love Island: Forbidden Boys Temptation, Red Fables, 12, Sexual Innuendo
- Maid-Sama Cafe: Anime Boys Services in Cute Outfits, Red Fables, 12, Sexual Innuendo
- Mermaid Catch: Transform Sirens into Anime Boys, Red Fables, 12, Sexual Innuendo
- Mermaid Catch: Transform Sirens into Anime Girls, Red Fables, 12, Sexual Innuendo
- Mom Crush: Hidden Hotel Love Story, Red Fables, 12, Sexual Innuendo
- Pixel Hunters: Turn Retro Consoles into your Boyfriend, Red Fables, 12, Sexual Innuendo
- Pool Party Boys: Splash Guys, Red Fables, 12, Sexual Innuendo
- Pool Party Girls: Splash Babes, Red Fables, 12, Sexual Innuendo
- Prince Date Diaries: A Fairy Tale Love, Red Fables, 12, Sexual Innuendo
- Princess Date Diaries: A Fairy Tale Love, Red Fables, 12, Sexual Innuendo
- Samurai Shoguns Heart: Romance Among the Cherry Blossoms, Red Fables, 12, Sexual Innuendo
- Seven Deadly Sins: Anime Boys Fantasy Love, Red Fables, 12, Sexual Innuendo
- Spa Massage Boys: Love & Relax, Red Fables, 12, Sexual Innuendo
- Sugar Daddy Crush: Hidden Hotel Love Story, Red Fables, 12, Sexual Innuendo
- The Arcana: Dark Tarot & Kings of Madness, Red Fables, 12, Sexual Innuendo
- The Arcana: Dark Tarot & Queens of Madness, Red Fables, 12, Sexual Innuendo
- Therian Crush: Wild Animal Boys, Red Fables, 12, Sexual Innuendo
- Tokyo Yakuza Idols: Save the Heart of a Rebel Boy, Red Fables, 12, Sexual Innuendo
- Tokyo Yakuza Idols: Save the Heart of a Rebel Girl, Red Fables, 12, Sexual Innuendo
- Vampire Boys Love Story: Date or Die, Red Fables, 12, Sexual Innuendo
- Vampire Girls Love Story: Date or Die, Red Fables, 12, Sexual Innuendo
- Villain Boys: Date the Dark Side, Red Fables, 12, Sexual Innuendo
- Youtuber Boys: Love Behind the Camera, Red Fables, 12, Sexual Innuendo
- Zombie Hearts: Turn the Undead into Anime Boys, Red Fables, 12, Sexual Innuendo
- Twofold, refint/games, 12, Sexual Innuendo
- Twofold – Nintendo Switch 2 Edition, refint/games, 12, Sexual Innuendo (S2)
- CAFE 0 ~The Sleeping Beast~ REMASTERED, ROSEVERTE, 12, Sexual Innuendo
- How to Sing to Open Your Heart Remastered, ROSEVERTE, 12, Sexual Innuendo
- Fetch Quest Remastered, SOFT SOURCE, 12, Sexual Innuendo
- Fetch Re:Quest, SOFT SOURCE, 12, Sexual Innuendo
- Matchmaker Agency, SOFT SOURCE, 12, Sexual Innuendo
- Pirated Code: Admin Edition, SOFT SOURCE, 12, Sexual Innuendo
- Five Hearts Under One Roof, StoryTaco, 12, In-game purchases / Sexual Innuendo
- Blossom Voyage, Sunjoy Game, 12, Sexual Innuendo
- Hades II – Nintendo Switch™ 2 Edition, Supergiant Games, 12, Mild Swearing / Moderate Violence / Sexual Innuendo (S2)
- Love and Legends, Voltage, 12, Sexual Innuendo
- Jesus Simulator, VRCFORGE STUDIOS, 12, Sexual Innuendo

### R4: Nudity (82)

- Dispatch, AdHoc Studio, 18, Extreme Violence / In-game purchases / Nudity / Strong Language
- Dispatch Nintendo Switch 2 Edition, AdHoc Studio, 18, Extreme Violence / In-game purchases / Nudity / Strong Language (S2)
- LeMrosh in the Lazy Kingdom, AppsGears, 12, Nudity
- Anime: Fantasy Uni 2, Big Way, 12, Nudity
- Anime Uni 3D: Hot Vacay, Big Way, 12, Nudity
- Anime: Fantasy Uni, Big Way, 12, Nudity
- Damsels in Distress, Big Way, 12, Nudity
- Hentai Uni 5, Big Way, 12, Nudity [kw]
- Shadows of Adam, CIRCLE Ent., 12, Mild Swearing / Nudity
- 20 Ladies, eastasiasoft, 16, Nudity
- Boo Party, eastasiasoft, 16, Nudity
- Burning Secrets - A Bara Visual Novel, eastasiasoft, 16, Nudity / Sex / Strong Language
- Crawlco Block Knockers, eastasiasoft, 16, Nudity / Sex
- Crimson Spires, eastasiasoft, 16, Drugs / Nudity / Sex / Strong Language / Strong Violence
- Delicious! Pretty Girls Mahjong Solitaire, eastasiasoft, 16, Nudity
- Demoniaca: Everlasting Night, eastasiasoft, 18, Nudity
- Giant Wishes, eastasiasoft, 16, Nudity / Sex / Strong Language
- In the Mood, eastasiasoft, 16, Nudity
- Marble Maid, eastasiasoft, 16, Nudity / Sex
- Moero Crystal H, eastasiasoft, 16, Nudity
- Neko Journey, eastasiasoft, 16, Nudity
- Neko Secret Homecoming, eastasiasoft, 16, Nudity
- Neko Secret Room, eastasiasoft, 16, Nudity / Sex
- Plunderer's Adventures, eastasiasoft, 16, Nudity
- Pretty Girls Mahjong Solitaire - Blue, eastasiasoft, 16, Nudity
- Pretty Girls Mahjong Solitaire - Green, eastasiasoft, 16, Nudity
- Pretty Girls Panic! PLUS, eastasiasoft, 16, Nudity
- Rule No.1, eastasiasoft, 16, Nudity / Strong Language
- Seven Pirates H, eastasiasoft, 16, Nudity
- Shuttlecock-H, eastasiasoft, 16, Nudity / Sex
- Sofiya and the Ancient Clan, eastasiasoft, 16, Nudity / Sex / Strong Language
- Milanoir, Good Shepherd, 18, Nudity / Strong Language
- A Maiden Astrologer Divines the Future, iMel, 12, Nudity
- Virtual Maid Streamer Ramie, iMel, 16, Nudity / Sex / Strong Language
- Horrific Xanatorium, KEMCO, 16, Horror / Nudity
- What have you done, father?, Making Port, 16, Nudity / Sex / Strong Violence (S2)
- What have you done, father?, Making Port, 16, Nudity / Sex / Strong Violence
- Anime Girls: Awesome Adventurer, Pakotime, 16, Nudity
- Anime Girls: Beautiful Bride, Pakotime, 16, Nudity
- Anime Girls: Bouncy Basketball, Pakotime, 16, Nudity
- Anime Girls: Busty Baseball, Pakotime, 16, Nudity
- Anime Girls: Cheerful Cosplay, Pakotime, 16, Nudity
- Anime Girls: Clever Clover, Pakotime, 16, Nudity
- Anime Girls: College Love, Pakotime, 16, Nudity
- Anime Girls: Gorgeous Girlfriend, Pakotime, 16, Nudity
- Anime Girls: Graceful Goddess, Pakotime, 16, Nudity
- Anime Girls: Lady Liberty, Pakotime, 16, Nudity
- Anime Girls: Lovely Lolita, Pakotime, 16, Nudity
- Anime Girls: Natty New Year, Pakotime, 16, Nudity
- Anime Girls: Natty Nurse, Pakotime, 16, Nudity
- Anime Girls: Naughty Neko, Pakotime, 16, Nudity
- Anime Girls: Nimble Ninja, Pakotime, 16, Nudity
- Anime Girls: Sakura Love, Pakotime, 16, Nudity
- Anime Girls: Shanghai Romance, Pakotime, 16, Nudity
- Anime Girls: Summer Vacay, Pakotime, 16, Nudity
- Anime Girls: Tokyo Christmas, Pakotime, 16, Nudity
- Kawaii Girls: Vegas Romance, Pakotime, 16, Nudity
- Sugoi Girls: Attractive Archer, Pakotime, 16, Nudity
- Sugoi Girls: Clover Crush, Pakotime, 16, Nudity
- Sugoi Girls: Delhi Darling, Pakotime, 16, Nudity
- Sugoi Girls: Dental Darling, Pakotime, 16, Nudity
- Sugoi Girls: Dragon Love, Pakotime, 16, Nudity
- Sugoi Girls: Enchanting Elf, Pakotime, 16, Nudity
- Sugoi Girls: Exotic Egypt, Pakotime, 16, Nudity
- Sugoi Girls: Firefighter Love, Pakotime, 16, Nudity
- Sugoi Girls: Kinky Knight, Pakotime, 16, Nudity
- Sugoi Girls: Lovely Wife, Pakotime, 16, Nudity
- Sugoi Girls: Pretty Party, Pakotime, 16, Nudity
- Sugoi Girls: Pretty Patriot, Pakotime, 16, Nudity
- Sugoi Girls: Sassy Heroine, Pakotime, 16, Nudity
- Sugoi Girls: Sassy Spy, Pakotime, 16, Nudity
- Sugoi Girls: Sexy Steampunk, Pakotime, 16, Nudity [kw]
- Sugoi Girls: Tribal Crush, Pakotime, 16, Nudity
- Sugoi Girls: Victoria Vogue, Pakotime, 16, Nudity
- Sugoi Girls: Vivacious Vampire, Pakotime, 16, Nudity
- Yabai Girls: Ballet Beauty, Pakotime, 16, Nudity
- Yabai Girls: Elegant Egyptian, Pakotime, 16, Nudity
- Yabai Girls: Fairy Love, Pakotime, 16, Nudity
- Yabai Girls: Heavenly Homemaker, Pakotime, 16, Nudity
- Yabai Girls: Hot Hiker, Pakotime, 16, Nudity
- Yabai Girls: Saucy Police, Pakotime, 16, Nudity
- Yabai Girls: Valentine Babe, Pakotime, 16, Nudity

### R5: Sex (84)

- The Rumble Fish 2, 3goo, 12, Sex / Violence
- Beholder: Conductor, Alawar Premium, 16, Sex / Strong Violence
- BLAZBLUE CENTRALFICTION Special Edition, ARC SYSTEM WORKS, 12, Bad Language / Fear / Sex / Violence
- DEMONS' NIGHT FEVER, ARC SYSTEM WORKS, 12, Bad Language / Sex / Violence
- Double Dragon Revive, ARC SYSTEM WORKS, 12, Bad Language / Sex / Violence
- GUILTY GEAR XX ACCENT CORE PLUS R, ARC SYSTEM WORKS, 12, Bad Language / Sex / Violence
- HUNTER×HUNTER NEN×IMPACT, ARC SYSTEM WORKS, 16, Sex / Violence
- KILL la KILL -IF, ARC SYSTEM WORKS, 16, Sex
- Digimon Story Time Stranger, Bandai Namco Entertainment, 12, Bad Language / In-game purchases / Sex
- Digimon Story Time Stranger, Bandai Namco Entertainment, 12, Bad Language / In-game purchases / Sex (S2)
- SUPER ROBOT WARS Y, Bandai Namco Entertainment, 12, Bad Language / In-game purchases / Sex / Violence
- Super Bullet Break, BeXide, 12, Sex
- Street Fighter™ 6, CAPCOM, 12, Bad Language / In-game purchases / Sex / Violence (S2)
- City Hunter, Clouded Leopard Entertainment, 12, Bad Language / Sex / Violence (S2)
- City Hunter, Clouded Leopard Entertainment, 12, Bad Language / Sex / Violence
- DEMON GAZE EXTRA, Clouded Leopard Entertainment, 12, Bad Language / Sex
- Moonlight Peaks, Clouded Leopard Entertainment, 12, Sex
- Ys IX -Monstrum NOX-, Clouded Leopard Entertainment, 12, Bad Language / Sex / Violence
- Chaos on Deponia, Daedalic Entertainment, 12, Bad Language / Sex / Violence
- Deponia, Daedalic Entertainment, 12, Bad Language / Sex / Violence
- Deponia Doomsday, Daedalic Entertainment, 12, Bad Language / Sex / Violence
- Goodbye Deponia, Daedalic Entertainment, 12, Bad Language / Sex / Violence
- Loop Hero, Devolver Digital, 12, Bad Language / Sex
- Burning Secrets - A Bara Visual Novel, eastasiasoft, 16, Nudity / Sex / Strong Language
- Burrow of the Fallen Bear: A Gay Furry Visual Novel, eastasiasoft, 16, Sex / Strong Language
- Crawlco Block Knockers, eastasiasoft, 16, Nudity / Sex
- Crimson Spires, eastasiasoft, 16, Drugs / Nudity / Sex / Strong Language / Strong Violence
- Dreamcutter, eastasiasoft, 18, Sex / Strong Language
- Freezer Pops, eastasiasoft, 16, Sex / Strong Language
- Giant Wishes, eastasiasoft, 16, Nudity / Sex / Strong Language
- Marble Maid, eastasiasoft, 16, Nudity / Sex
- Mugen Souls, eastasiasoft, 18, Sex
- Mugen Souls Z, eastasiasoft, 18, Sex
- My Incubi Harem, eastasiasoft, 16, Sex / Strong Language
- Neko Secret Room, eastasiasoft, 16, Nudity / Sex
- Shuttlecock-H, eastasiasoft, 16, Nudity / Sex
- Slime Girl Smoothies, eastasiasoft, 18, Sex / Strong Language / Use of Alcohol/Tobacco
- Sofiya and the Ancient Clan, eastasiasoft, 16, Nudity / Sex / Strong Language
- Synthetic Lover, eastasiasoft, 16, Sex / Strong Language / Use of Alcohol/Tobacco
- Waifu Discovered 2: Medieval Fantasy, eastasiasoft, 18, Sex [kw]
- Waifu Uncovered, eastasiasoft, 18, Sex [kw]
- Virtual Maid Streamer Ramie, iMel, 16, Nudity / Sex / Strong Language
- Gal Guardians: Demon Purge, Inti Creates, 12, Bad Language / Sex / Violence
- Tales from Toyotoki: Arrival of the Witch, KEMCO, 12, Bad Language / Sex (S2)
- Atelier Ryza 2: Lost Legends & the Secret Fairy DX, KOEI TECMO GAMES, 12, Sex / Violence
- Atelier Ryza 2: Lost Legends & the Secret Fairy DX, KOEI TECMO GAMES, 12, Sex / Violence (S2)
- Atelier Ryza 3: Alchemist of the End & the Secret Key DX, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence
- Atelier Ryza 3: Alchemist of the End & the Secret Key DX, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence (S2)
- Atelier Ryza: Ever Darkness & the Secret Hideout DX, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence
- Atelier Ryza: Ever Darkness & the Secret Hideout DX, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence (S2)
- Atelier Yumia: The Alchemist of Memories & the Envisioned Land, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence
- Atelier Yumia: The Alchemist of Memories & the Envisioned Land – Nintendo Switch 2 Edition, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence (S2)
- BLUE REFLECTION Quartet, KOEI TECMO GAMES, 16, Sex (S2)
- BLUE REFLECTION Quartet, KOEI TECMO GAMES, 16, Sex
- FAIRY TAIL, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence
- FAIRY TAIL 2, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence
- Castlevania Dominus Collection, KONAMI, 12, Horror / Sex / Violence
- What have you done, father?, Making Port, 16, Nudity / Sex / Strong Violence
- What have you done, father?, Making Port, 16, Nudity / Sex / Strong Violence (S2)
- Blacksad: Under the Skin, Microids, 16, Bad Language / Drugs / Sex / Violence
- Space Adventure Cobra - The Awakening, Microids, 12, Sex / Violence
- Xenoblade Chronicles X: Definitive Edition, Nintendo, 12, Bad Language / Sex / Violence
- Xenoblade Chronicles X: Definitive Edition – Nintendo Switch 2 Edition, Nintendo, 12, Bad Language / Sex / Violence (S2)
- Arcade Spirits, PQube, 12, Sex
- Celestia: Chain of Fate, PQube, 12, Bad Language / Sex
- Kotodama: The 7 Mysteries of Fujisawa, PQube, 12, Bad Language / Sex
- Twofold: First Snow, refint/games, 16, Sex
- 13 Sentinels: Aegis Rim, SEGA, 12, Bad Language / Sex / Violence
- Persona 5 Tactica, SEGA, 12, Bad Language / Sex / Violence
- RAIDOU Remastered: The Mystery of the Soulless Army, SEGA, 12, Bad Language / Horror / In-game purchases / Sex / Violence (S2)
- RAIDOU Remastered: The Mystery of the Soulless Army, SEGA, 12, Bad Language / Horror / In-game purchases / Sex / Violence
- Shining Resonance Refrain, SEGA, 12, Bad Language / Sex / Violence
- The Witch's Bakery, Silver Lining, 12, Bad Language / Sex
- The Witch's Bakery, Silver Lining, 12, Bad Language / Sex (S2)
- BRAVELY DEFAULT FLYING FAIRY HD Remaster, SQUARE ENIX, 12, Sex / Violence (S2)
- DRAGON QUEST® XI S: Echoes of an Elusive Age – Definitive Edition, SQUARE ENIX, 12, Gambling / Sex / Violence
- DRAGON QUEST XI S: Echoes of an Elusive Age - Definitive Edition, SQUARE ENIX, 12, Gambling / Sex / Violence (S2)
- Octopath Traveler™, SQUARE ENIX, 12, Bad Language / Sex (S2)
- Octopath Traveler™, SQUARE ENIX, 12, Bad Language / Sex
- OCTOPATH TRAVELER 0, SQUARE ENIX, 12, Bad Language / Horror / Sex / Violence (S2)
- OCTOPATH TRAVELER 0, SQUARE ENIX, 12, Bad Language / Horror / Sex / Violence
- OCTOPATH TRAVELER II, SQUARE ENIX, 12, Bad Language / Sex
- OCTOPATH TRAVELER II, SQUARE ENIX, 12, Bad Language / Sex (S2)
- Hades II, Supergiant Games, 12, Bad Language / Sex / Violence

### R6: Sexual Innuendo as the only descriptor (198)

- Panty Match Girls, 17Studio, 12, Sexual Innuendo [kw]
- Anime Codex: Final Pose, 17Studio, 12, Sexual Innuendo
- Anime Codex: Shy Girls, 17Studio, 12, Sexual Innuendo
- Anime Codex: Triple Pleasure, 17Studio, 12, Sexual Innuendo
- Anime Codex: Whispered Lips, 17Studio, 12, Sexual Innuendo
- Bad Girls: Naughty Hands, 17Studio, 12, Sexual Innuendo
- Bad Girls: Sweet Trouble, 17Studio, 12, Sexual Innuendo
- Bad Girls: Tempting Night, 17Studio, 12, Sexual Innuendo
- Bikini Match Girls, 17Studio, 12, Sexual Innuendo
- Call of Beauty, 17Studio, 12, Sexual Innuendo
- Cyber Love Story, 17Studio, 12, Sexual Innuendo
- Dirty Little Puzzle, 17Studio, 12, Sexual Innuendo [kw]
- Doku Girls 2, 17Studio, 12, Sexual Innuendo
- Doku Girls 3, 17Studio, 12, Sexual Innuendo
- Double Trouble: Sexy Logic, 17Studio, 12, Sexual Innuendo [kw]
- Good Girls: Angels With Dirty Intentions, 17Studio, 12, Sexual Innuendo [kw]
- Good Girls: Seduction Starts With a Smile, 17Studio, 12, Sexual Innuendo
- Good Girls: Sweet Faces, 17Studio, 12, Sexual Innuendo
- Good Girls: Temptation in Disguise, 17Studio, 12, Sexual Innuendo
- Hentai Balls 3D: Heavy Attraction, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Balls 3D: Perfect Motion, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Balls 3D: Sexy Girls, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Balls 3D: Triple Trouble, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Banana, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Bikini, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Demon's Lullaby, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Gallery: Hidden Charms, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Gallery: Lovely Angels, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Girls Panic, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Girls Puzzle, 17Studio, 12, Sexual Innuendo [kw]
- Hentai House: Lost Rooms, 17Studio, 12, Sexual Innuendo [kw]
- Hentai House: Mystery Rooms, 17Studio, 12, Sexual Innuendo [kw]
- Hentai House: Next Door, 17Studio, 12, Sexual Innuendo [kw]
- Hentai House: Puzzle Nights, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Office Enigma, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Panty: Private Collection, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Project, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Protocol: Lesson One, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Puzzle Simulator, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Puzzle Simulator 2, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Puzzle Simulator 3, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Reality, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Reality 2, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Reality 3, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Succubus Serenade, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Tales Vol. 1, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Tales Vol. 2, 17Studio, 12, Sexual Innuendo [kw]
- Hentai Tales Vol. 3, 17Studio, 12, Sexual Innuendo [kw]
- Hidden Girls: Bikini Dreams, 17Studio, 12, Sexual Innuendo
- Hidden Girls: Private Nights, 17Studio, 12, Sexual Innuendo
- Hidden Girls: Quiet Beauty, 17Studio, 12, Sexual Innuendo
- Hidden Girls: Secret Puzzle, 17Studio, 12, Sexual Innuendo
- Hidden Girls: Tropical Vibes, 17Studio, 12, Sexual Innuendo
- Hidden Pleasure: Deeper and Deeper, 17Studio, 12, Sexual Innuendo
- Hidden Pleasure: Faster and Faster, 17Studio, 12, Sexual Innuendo
- Hidden Pleasure: More and More, 17Studio, 12, Sexual Innuendo
- Photo Girls: First Session, 17Studio, 12, Sexual Innuendo
- Photo Girls: No Retouch, 17Studio, 12, Sexual Innuendo
- Photo Girls: Raw Photo, 17Studio, 12, Sexual Innuendo
- Photo Girls: Secret Footage, 17Studio, 12, Sexual Innuendo
- Pure Hentai: Dreams, 17Studio, 12, Sexual Innuendo [kw]
- Puzzle Girls: Dark Temptation, 17Studio, 12, Sexual Innuendo
- Puzzle Girls: Gentle Passion, 17Studio, 12, Sexual Innuendo
- Puzzle Girls: Inner Flame, 17Studio, 12, Sexual Innuendo
- Puzzle Girls: Seductive Nights, 17Studio, 12, Sexual Innuendo
- Real Girls: Burning Whisper, 17Studio, 12, Sexual Innuendo
- Real Girls: Midnight Desire, 17Studio, 12, Sexual Innuendo
- Real Girls: Velvet Flame, 17Studio, 12, Sexual Innuendo
- Sexy Erotic Xtreme Club, 17Studio, 12, Sexual Innuendo [kw]
- Snapshot Girls, 17Studio, 12, Sexual Innuendo
- Snapshot Girls 2, 17Studio, 12, Sexual Innuendo
- Snapshot Girls 3, 17Studio, 12, Sexual Innuendo
- The Last of Touch, 17Studio, 12, Sexual Innuendo
- Toilet Hero, 17Studio, 12, Sexual Innuendo
- Triple Trouble: Locker Room Secrets, 17Studio, 12, Sexual Innuendo
- Triple Trouble: Midnight Club, 17Studio, 12, Sexual Innuendo
- Future Knight, Aeternum Game Studios, 12, Sexual Innuendo
- Lucky Tower Ultimate, AMC Games, 12, Sexual Innuendo
- The Fox's Way Home, BeXide, 12, Sexual Innuendo
- The Fox's Way Home – Nintendo Switch 2 Edition, BeXide, 12, Sexual Innuendo (S2)
- Anime Video Puzzle, Big Way, 12, Sexual Innuendo
- Anime: Fantasy Uni 3, Big Way, 12, Sexual Innuendo
- Sailing Era, BILIBILI HK, 12, Sexual Innuendo
- Yog-Sothoth’s Yard, Bone Nail, 12, Sexual Innuendo
- Runestone Keeper, CIRCLE Ent., 12, Sexual Innuendo
- Moonlight Peaks - Nintendo Switch 2 Edition, Clouded Leopard Entertainment, 12, Sexual Innuendo (S2)
- Speed Dates, COSEN, 12, Sexual Innuendo
- Speed Dates Summer Edition, COSEN, 12, Sexual Innuendo
- After School .LIVE -Mirror of Twilight-, CyberStep, 12, Sexual Innuendo
- Rica Mode♡, CyberStep, 12, Sexual Innuendo
- Serena Hanazono’s Lost Item ～Sweet Memory～, CyberStep, 12, Sexual Innuendo
- Another World Mahjong Girl, eastasiasoft, 12, Sexual Innuendo
- Bishoujo Battle Cyber Panic!, eastasiasoft, 12, Sexual Innuendo
- Bishoujo Battle Mahjong Solitaire, eastasiasoft, 12, Sexual Innuendo
- Moe Waifu H, eastasiasoft, 12, Sexual Innuendo [kw]
- Moe Waifu H Genius, eastasiasoft, 12, Sexual Innuendo [kw]
- Pretty Girls 2048 Strike, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Breakers!, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Breakers! PLUS, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Escape, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Escape PLUS, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Four Kings Solitaire, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Klondike Solitaire, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Klondike Solitaire PLUS, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Mahjong Solitaire, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Panic!, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Pop Match, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Rivers, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Speed, eastasiasoft, 12, Sexual Innuendo
- Pretty Girls Tile Match, eastasiasoft, 12, Sexual Innuendo
- Saga of the Moon Priestess, eastasiasoft, 12, Sexual Innuendo
- Sunny Café, eastasiasoft, 12, Sexual Innuendo
- Super XYX, eastasiasoft, 12, Sexual Innuendo
- Ambition of the Slimes, Flyhigh Works, 12, Sexual Innuendo
- Tayutama:It's happy days, Frontier Works, 12, Sexual Innuendo
- Can I Not Fall for Idols?, Futaba Games, 12, Sexual Innuendo
- KUUKIYOMI 2: Consider It More! - New Era, G-MODE, 12, Sexual Innuendo
- KUUKIYOMI 4: Consider It, G-MODE, 12, Sexual Innuendo
- KUUKIYOMI: Consider It World - Thailand Ver., G-MODE, 12, Sexual Innuendo
- In Trusted Hands, Games Harbor, 12, Sexual Innuendo
- CoffeeFox: Kim Samwol, GaniTani, 12, Sexual Innuendo
- DopePie Survivors 3D, GCHJ studio, 12, Sexual Innuendo
- Anime Love Chat Girls, GreenWookland Games, 12, Sexual Innuendo
- Caladrius Blaze, H2 INTERACTIVE, 12, Sexual Innuendo
- SAEKO: Giantess Dating Sim, HYPER REAL, 12, Sexual Innuendo
- COSPLAY LOVE! Enchanted princess, iMel, 12, Sexual Innuendo
- Hot“Sento Girls”and love, iMel, 12, Sexual Innuendo
- Secret Kiss is Sweet and Tender, iMel, 12, Sexual Innuendo
- Dragon Ruins II, KEMCO, 12, Sexual Innuendo
- Genso Chronicles, KEMCO, 12, Sexual Innuendo
- The Prince of Tennis Doki Doki Survival ~eternal passion! Tie break ♡ game~, KONAMI, 12, Sexual Innuendo
- The Prince of Tennis Doki Doki Survival ~eternal passion! Tie break ♡ game~ Nintendo Switch 2 Edition, KONAMI, 12, Sexual Innuendo (S2)
- The Prince of Tennis Sweet School Festival ~♡-40 and more...~, KONAMI, 12, Sexual Innuendo
- The Prince of Tennis Sweet School Festival ~♡-40 and more...~ Nintendo Switch 2 Edition, KONAMI, 12, Sexual Innuendo (S2)
- Half Billion: Love Choice, Kunyu Studio, 12, Sexual Innuendo
- Majotori, Mameshiba Games, 12, Sexual Innuendo
- The Palace on the Hill, Niku Games, 12, Sexual Innuendo
- Blast Linkers, ODDCADIA, 12, Sexual Innuendo
- Byakko-tai Samurai Boys, OperaHouse, 12, Sexual Innuendo
- Dateless Love - Love Story Behind the Restoration -, OperaHouse, 12, Sexual Innuendo
- Diamond Girl ★An Earnest Education in Love★, OperaHouse, 12, Sexual Innuendo
- Princess Closet - Fashion and love will change me -, OperaHouse, 12, Sexual Innuendo
- Idol Manager, PLAYISM, 12, Sexual Innuendo
- LUNARiA -Virtualized Moonchild-, PROTOTYPE, 12, Sexual Innuendo
- Anime Feet Boys: The Charm Finder Quest, Red Fables, 12, Sexual Innuendo
- Anime Feet Girls: The Charm Finder Quest, Red Fables, 12, Sexual Innuendo
- Anime School Love: Her Teacher's Secret Lesson, Red Fables, 12, Sexual Innuendo
- Anime School Love: His Teacher Secret Lesson, Red Fables, 12, Sexual Innuendo
- Beach Volleyball Boys: Hot Spike, Red Fables, 12, Sexual Innuendo
- Bug Error 404: Anime Boys Not Found, Red Fables, 12, Sexual Innuendo
- Criminal Hearts: Obsession Bad Boys Dating Sim, Red Fables, 12, Sexual Innuendo
- Dangerous Superheroes After Dark: Heroes Behind the Mask, Red Fables, 12, Sexual Innuendo
- Dangerous Superheroes After Dark: Heroines Behind the Mask, Red Fables, 12, Sexual Innuendo
- Dino Evolution: Catch Dinosaurs and Raise Anime Primeval Boys, Red Fables, 12, Sexual Innuendo
- Dino Evolution: Catch Dinosaurs and Raise Anime Primeval Girls, Red Fables, 12, Sexual Innuendo
- Farm Love Legend: Transform your Animals into Anime Boys, Red Fables, 12, Sexual Innuendo
- Furry Girls Paradise: Love & Fun, Red Fables, 12, Sexual Innuendo
- Furry Pride Paradise Love & Fun, Red Fables, 12, Sexual Innuendo
- Geisha's Heart: Romance Among the Cherry Blossoms, Red Fables, 12, Sexual Innuendo
- Hospital Romance: Anime Doctor Crush, Red Fables, 12, Sexual Innuendo
- Hospital Romance: Anime Nurse Crush, Red Fables, 12, Sexual Innuendo
- Kawaii Anime: Cute Boys Magic World, Red Fables, 12, Sexual Innuendo
- Kawaii Anime: Cute Girls Magic World, Red Fables, 12, Sexual Innuendo
- Love Island: Forbidden Boys Temptation, Red Fables, 12, Sexual Innuendo
- Maid-Sama Cafe: Anime Boys Services in Cute Outfits, Red Fables, 12, Sexual Innuendo
- Mermaid Catch: Transform Sirens into Anime Boys, Red Fables, 12, Sexual Innuendo
- Mermaid Catch: Transform Sirens into Anime Girls, Red Fables, 12, Sexual Innuendo
- Mom Crush: Hidden Hotel Love Story, Red Fables, 12, Sexual Innuendo
- Pixel Hunters: Turn Retro Consoles into your Boyfriend, Red Fables, 12, Sexual Innuendo
- Pool Party Boys: Splash Guys, Red Fables, 12, Sexual Innuendo
- Pool Party Girls: Splash Babes, Red Fables, 12, Sexual Innuendo
- Prince Date Diaries: A Fairy Tale Love, Red Fables, 12, Sexual Innuendo
- Princess Date Diaries: A Fairy Tale Love, Red Fables, 12, Sexual Innuendo
- Samurai Shoguns Heart: Romance Among the Cherry Blossoms, Red Fables, 12, Sexual Innuendo
- Seven Deadly Sins: Anime Boys Fantasy Love, Red Fables, 12, Sexual Innuendo
- Spa Massage Boys: Love & Relax, Red Fables, 12, Sexual Innuendo
- Sugar Daddy Crush: Hidden Hotel Love Story, Red Fables, 12, Sexual Innuendo
- The Arcana: Dark Tarot & Kings of Madness, Red Fables, 12, Sexual Innuendo
- The Arcana: Dark Tarot & Queens of Madness, Red Fables, 12, Sexual Innuendo
- Therian Crush: Wild Animal Boys, Red Fables, 12, Sexual Innuendo
- Tokyo Yakuza Idols: Save the Heart of a Rebel Boy, Red Fables, 12, Sexual Innuendo
- Tokyo Yakuza Idols: Save the Heart of a Rebel Girl, Red Fables, 12, Sexual Innuendo
- Vampire Boys Love Story: Date or Die, Red Fables, 12, Sexual Innuendo
- Vampire Girls Love Story: Date or Die, Red Fables, 12, Sexual Innuendo
- Villain Boys: Date the Dark Side, Red Fables, 12, Sexual Innuendo
- Youtuber Boys: Love Behind the Camera, Red Fables, 12, Sexual Innuendo
- Zombie Hearts: Turn the Undead into Anime Boys, Red Fables, 12, Sexual Innuendo
- Twofold, refint/games, 12, Sexual Innuendo
- Twofold – Nintendo Switch 2 Edition, refint/games, 12, Sexual Innuendo (S2)
- CAFE 0 ~The Sleeping Beast~ REMASTERED, ROSEVERTE, 12, Sexual Innuendo
- How to Sing to Open Your Heart Remastered, ROSEVERTE, 12, Sexual Innuendo
- Fetch Quest Remastered, SOFT SOURCE, 12, Sexual Innuendo
- Fetch Re:Quest, SOFT SOURCE, 12, Sexual Innuendo
- Matchmaker Agency, SOFT SOURCE, 12, Sexual Innuendo
- Pirated Code: Admin Edition, SOFT SOURCE, 12, Sexual Innuendo
- Blossom Voyage, Sunjoy Game, 12, Sexual Innuendo
- Love and Legends, Voltage, 12, Sexual Innuendo
- Jesus Simulator, VRCFORGE STUDIOS, 12, Sexual Innuendo

### R7: Sex or Nudity, and age <= 12 (64)

- The Rumble Fish 2, 3goo, 12, Sex / Violence
- LeMrosh in the Lazy Kingdom, AppsGears, 12, Nudity
- BLAZBLUE CENTRALFICTION Special Edition, ARC SYSTEM WORKS, 12, Bad Language / Fear / Sex / Violence
- DEMONS' NIGHT FEVER, ARC SYSTEM WORKS, 12, Bad Language / Sex / Violence
- Double Dragon Revive, ARC SYSTEM WORKS, 12, Bad Language / Sex / Violence
- GUILTY GEAR XX ACCENT CORE PLUS R, ARC SYSTEM WORKS, 12, Bad Language / Sex / Violence
- Digimon Story Time Stranger, Bandai Namco Entertainment, 12, Bad Language / In-game purchases / Sex
- Digimon Story Time Stranger, Bandai Namco Entertainment, 12, Bad Language / In-game purchases / Sex (S2)
- SUPER ROBOT WARS Y, Bandai Namco Entertainment, 12, Bad Language / In-game purchases / Sex / Violence
- Super Bullet Break, BeXide, 12, Sex
- Anime: Fantasy Uni 2, Big Way, 12, Nudity
- Anime Uni 3D: Hot Vacay, Big Way, 12, Nudity
- Anime: Fantasy Uni, Big Way, 12, Nudity
- Damsels in Distress, Big Way, 12, Nudity
- Hentai Uni 5, Big Way, 12, Nudity [kw]
- Street Fighter™ 6, CAPCOM, 12, Bad Language / In-game purchases / Sex / Violence (S2)
- Shadows of Adam, CIRCLE Ent., 12, Mild Swearing / Nudity
- City Hunter, Clouded Leopard Entertainment, 12, Bad Language / Sex / Violence
- City Hunter, Clouded Leopard Entertainment, 12, Bad Language / Sex / Violence (S2)
- DEMON GAZE EXTRA, Clouded Leopard Entertainment, 12, Bad Language / Sex
- Moonlight Peaks, Clouded Leopard Entertainment, 12, Sex
- Ys IX -Monstrum NOX-, Clouded Leopard Entertainment, 12, Bad Language / Sex / Violence
- Chaos on Deponia, Daedalic Entertainment, 12, Bad Language / Sex / Violence
- Deponia, Daedalic Entertainment, 12, Bad Language / Sex / Violence
- Deponia Doomsday, Daedalic Entertainment, 12, Bad Language / Sex / Violence
- Goodbye Deponia, Daedalic Entertainment, 12, Bad Language / Sex / Violence
- Loop Hero, Devolver Digital, 12, Bad Language / Sex
- A Maiden Astrologer Divines the Future, iMel, 12, Nudity
- Gal Guardians: Demon Purge, Inti Creates, 12, Bad Language / Sex / Violence
- Tales from Toyotoki: Arrival of the Witch, KEMCO, 12, Bad Language / Sex (S2)
- Atelier Ryza 2: Lost Legends & the Secret Fairy DX, KOEI TECMO GAMES, 12, Sex / Violence (S2)
- Atelier Ryza 2: Lost Legends & the Secret Fairy DX, KOEI TECMO GAMES, 12, Sex / Violence
- Atelier Ryza 3: Alchemist of the End & the Secret Key DX, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence (S2)
- Atelier Ryza 3: Alchemist of the End & the Secret Key DX, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence
- Atelier Ryza: Ever Darkness & the Secret Hideout DX, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence
- Atelier Ryza: Ever Darkness & the Secret Hideout DX, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence (S2)
- Atelier Yumia: The Alchemist of Memories & the Envisioned Land, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence
- Atelier Yumia: The Alchemist of Memories & the Envisioned Land – Nintendo Switch 2 Edition, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence (S2)
- FAIRY TAIL, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence
- FAIRY TAIL 2, KOEI TECMO GAMES, 12, Bad Language / Sex / Violence
- Castlevania Dominus Collection, KONAMI, 12, Horror / Sex / Violence
- Space Adventure Cobra - The Awakening, Microids, 12, Sex / Violence
- Xenoblade Chronicles X: Definitive Edition, Nintendo, 12, Bad Language / Sex / Violence
- Xenoblade Chronicles X: Definitive Edition – Nintendo Switch 2 Edition, Nintendo, 12, Bad Language / Sex / Violence (S2)
- Arcade Spirits, PQube, 12, Sex
- Celestia: Chain of Fate, PQube, 12, Bad Language / Sex
- Kotodama: The 7 Mysteries of Fujisawa, PQube, 12, Bad Language / Sex
- 13 Sentinels: Aegis Rim, SEGA, 12, Bad Language / Sex / Violence
- Persona 5 Tactica, SEGA, 12, Bad Language / Sex / Violence
- RAIDOU Remastered: The Mystery of the Soulless Army, SEGA, 12, Bad Language / Horror / In-game purchases / Sex / Violence (S2)
- RAIDOU Remastered: The Mystery of the Soulless Army, SEGA, 12, Bad Language / Horror / In-game purchases / Sex / Violence
- Shining Resonance Refrain, SEGA, 12, Bad Language / Sex / Violence
- The Witch's Bakery, Silver Lining, 12, Bad Language / Sex (S2)
- The Witch's Bakery, Silver Lining, 12, Bad Language / Sex
- BRAVELY DEFAULT FLYING FAIRY HD Remaster, SQUARE ENIX, 12, Sex / Violence (S2)
- DRAGON QUEST® XI S: Echoes of an Elusive Age – Definitive Edition, SQUARE ENIX, 12, Gambling / Sex / Violence
- DRAGON QUEST XI S: Echoes of an Elusive Age - Definitive Edition, SQUARE ENIX, 12, Gambling / Sex / Violence (S2)
- Octopath Traveler™, SQUARE ENIX, 12, Bad Language / Sex
- Octopath Traveler™, SQUARE ENIX, 12, Bad Language / Sex (S2)
- OCTOPATH TRAVELER 0, SQUARE ENIX, 12, Bad Language / Horror / Sex / Violence
- OCTOPATH TRAVELER 0, SQUARE ENIX, 12, Bad Language / Horror / Sex / Violence (S2)
- OCTOPATH TRAVELER II, SQUARE ENIX, 12, Bad Language / Sex (S2)
- OCTOPATH TRAVELER II, SQUARE ENIX, 12, Bad Language / Sex
- Hades II, Supergiant Games, 12, Bad Language / Sex / Violence

### R8: Nudity as the only descriptor, age <= 16 (64)

- LeMrosh in the Lazy Kingdom, AppsGears, 12, Nudity
- Anime: Fantasy Uni 2, Big Way, 12, Nudity
- Anime Uni 3D: Hot Vacay, Big Way, 12, Nudity
- Anime: Fantasy Uni, Big Way, 12, Nudity
- Damsels in Distress, Big Way, 12, Nudity
- Hentai Uni 5, Big Way, 12, Nudity [kw]
- 20 Ladies, eastasiasoft, 16, Nudity
- Boo Party, eastasiasoft, 16, Nudity
- Delicious! Pretty Girls Mahjong Solitaire, eastasiasoft, 16, Nudity
- In the Mood, eastasiasoft, 16, Nudity
- Moero Crystal H, eastasiasoft, 16, Nudity
- Neko Journey, eastasiasoft, 16, Nudity
- Neko Secret Homecoming, eastasiasoft, 16, Nudity
- Plunderer's Adventures, eastasiasoft, 16, Nudity
- Pretty Girls Mahjong Solitaire - Blue, eastasiasoft, 16, Nudity
- Pretty Girls Mahjong Solitaire - Green, eastasiasoft, 16, Nudity
- Pretty Girls Panic! PLUS, eastasiasoft, 16, Nudity
- Seven Pirates H, eastasiasoft, 16, Nudity
- A Maiden Astrologer Divines the Future, iMel, 12, Nudity
- Anime Girls: Awesome Adventurer, Pakotime, 16, Nudity
- Anime Girls: Beautiful Bride, Pakotime, 16, Nudity
- Anime Girls: Bouncy Basketball, Pakotime, 16, Nudity
- Anime Girls: Busty Baseball, Pakotime, 16, Nudity
- Anime Girls: Cheerful Cosplay, Pakotime, 16, Nudity
- Anime Girls: Clever Clover, Pakotime, 16, Nudity
- Anime Girls: College Love, Pakotime, 16, Nudity
- Anime Girls: Gorgeous Girlfriend, Pakotime, 16, Nudity
- Anime Girls: Graceful Goddess, Pakotime, 16, Nudity
- Anime Girls: Lady Liberty, Pakotime, 16, Nudity
- Anime Girls: Lovely Lolita, Pakotime, 16, Nudity
- Anime Girls: Natty New Year, Pakotime, 16, Nudity
- Anime Girls: Natty Nurse, Pakotime, 16, Nudity
- Anime Girls: Naughty Neko, Pakotime, 16, Nudity
- Anime Girls: Nimble Ninja, Pakotime, 16, Nudity
- Anime Girls: Sakura Love, Pakotime, 16, Nudity
- Anime Girls: Shanghai Romance, Pakotime, 16, Nudity
- Anime Girls: Summer Vacay, Pakotime, 16, Nudity
- Anime Girls: Tokyo Christmas, Pakotime, 16, Nudity
- Kawaii Girls: Vegas Romance, Pakotime, 16, Nudity
- Sugoi Girls: Attractive Archer, Pakotime, 16, Nudity
- Sugoi Girls: Clover Crush, Pakotime, 16, Nudity
- Sugoi Girls: Delhi Darling, Pakotime, 16, Nudity
- Sugoi Girls: Dental Darling, Pakotime, 16, Nudity
- Sugoi Girls: Dragon Love, Pakotime, 16, Nudity
- Sugoi Girls: Enchanting Elf, Pakotime, 16, Nudity
- Sugoi Girls: Exotic Egypt, Pakotime, 16, Nudity
- Sugoi Girls: Firefighter Love, Pakotime, 16, Nudity
- Sugoi Girls: Kinky Knight, Pakotime, 16, Nudity
- Sugoi Girls: Lovely Wife, Pakotime, 16, Nudity
- Sugoi Girls: Pretty Party, Pakotime, 16, Nudity
- Sugoi Girls: Pretty Patriot, Pakotime, 16, Nudity
- Sugoi Girls: Sassy Heroine, Pakotime, 16, Nudity
- Sugoi Girls: Sassy Spy, Pakotime, 16, Nudity
- Sugoi Girls: Sexy Steampunk, Pakotime, 16, Nudity [kw]
- Sugoi Girls: Tribal Crush, Pakotime, 16, Nudity
- Sugoi Girls: Victoria Vogue, Pakotime, 16, Nudity
- Sugoi Girls: Vivacious Vampire, Pakotime, 16, Nudity
- Yabai Girls: Ballet Beauty, Pakotime, 16, Nudity
- Yabai Girls: Elegant Egyptian, Pakotime, 16, Nudity
- Yabai Girls: Fairy Love, Pakotime, 16, Nudity
- Yabai Girls: Heavenly Homemaker, Pakotime, 16, Nudity
- Yabai Girls: Hot Hiker, Pakotime, 16, Nudity
- Yabai Girls: Saucy Police, Pakotime, 16, Nudity
- Yabai Girls: Valentine Babe, Pakotime, 16, Nudity

## Decision

`flagged` is unchanged: the keyword regex stays as the only rule. Reasons:

1. Every sexual-descriptor rule catches mainstream, recognisable games (see the table above), most of them from large publishers (SEGA, SQUARE ENIX, KOEI TECMO, CAPCOM, Nintendo, Supergiant, Bandai Namco).
2. The shovelware publishers (17Studio, Pakotime, Red Fables, Big Way, eastasiasoft's Pretty Girls series) are caught, but only together with real games; a publisher block-list or a reviewed per-title list is the safe next step, not a descriptor rule.
3. The 18 rating alone is never a flag: it marks Bayonetta, DOOM, Resident Evil and Mortal Kombat.
4. The age and descriptors are shown on the game page and can be filtered by age, so the information is available without hiding anything.
