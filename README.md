# Sharster Farts · Shatterberg Arena

Eat a free bowl of chili. Face a target and fire. Your character turns around, bends over and blasts. Amber Shatters break for currency. Spend it on stronger food or a longer-running colon.

## Play

- **Browser** · Open **Play Sharster Farts.html** in Chrome or Edge. Click a crystal or rival to approach, aim and fire. Click bare ground to walk. Use **E** to eat, **WASD** or arrows to move, and **Space** to fire in your current facing direction. Touch players can tap the field and buttons. The three rivals are NPCs. Purchases and currency save locally when browser storage is available.
- **Roblox Studio** · Open **Sharster Farts.rbxlx** and press **F5**. Eat with **E**, walk through the arena gate, face your target and press **F**. The HUD also supports tapping. Player attacks and NPC attacks work inside the striped boundary. Test with two Studio clients to fight another player. Wallet and upgrades last for the server session.

One meal fills one of three charges. Small Shatters pay 2, hard Shatters pay 4, and a knockout pays 5. Shatters and NPCs respawn. In Roblox, knocked-out players respawn in the canteen.

| Purchase | Shatters | Effect |
| --- | ---: | --- |
| Gas station eggs | 6 | Double power and greater reach |
| Reactor curry | 16 | Quadruple power and maximum reach |
| Extended colon | 5 | 1.5-second blast |
| Concert tuba | 14 | 2.4-second blast |

## Develop

Edit the shared economy in `rules.json`, Roblox game scripts in `src/`, and the offline game in `browser/`. World geometry lives in `tools/build.py`. From the repository root run:

```sh
python tools/build.py
python tools/check-place.py
```

Both exported games are committed. Building regenerates them from source. The browser regression test uses Playwright and Chromium. Set `PLAYWRIGHT_MODULE` and `CHROME_PATH` if using an external installation, then run `node tools/check-browser.cjs`.

The original gas-station hunt is available at commit `4a9eccf`.
