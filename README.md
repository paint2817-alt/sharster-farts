# Sharster Farts

A five-catch Roblox demo set at a closed gas station and the municipal pool beneath it. Your starter equipment is a butterfly net. The employee parking cone is due.

## Play

**Roblox Studio** · Open **Sharster Farts.rbxlx** in Studio and press **F5** to spawn into the lot. Use the standard avatar controls and follow the gold objective marker. Hold the interaction prompt to swing the net. On touch, press the prompt itself. The **Binder** button shows the five specimen slots.

During the cone stakeout, stand near the cone, move a step facing away from it, then let go of the movement controls. The cone watches your avatar’s facing direction. In the pool, stand still close to Wayne. At the ledge, swing between whistles.

**Browser** · Double-click **Play Sharster Farts.html** for an offline, illustrated point-and-click version of the same shift. The entire game and its artwork are in that file. Click or tap highlighted targets, hold **Look away** during the stakeout, and time the last catch. Keyboard players can Tab to each action and use Enter. Sound is optional.

The Studio version keeps each player’s binder and encounters independent during the server session. Respawning preserves progress. The browser version remembers the current step on this device when browser storage is available. **New shift** starts an empty binder.

## What’s playable

| Catch | What it does this shift |
| --- | --- |
| Loose Change | Pays the vending machine by jingling. |
| Baja Mistake | Comes out of the vending machine and powers the staff entrance. |
| The Commuter | Parks his cone and brings the staff key for Stall 6. |
| Drain Wayne | Drains the pool and removes Adult Swim’s enormous reflection. |
| Adult Swim | Completes the binder. He brought his whistle. |

## Develop

Edit the Luau scripts in `src/`. The server validates progression, distance, stakeout time and boss timing. The client draws each player's creatures, net, prompts and binder. The world geometry and service layout are authored in `tools/build.py`.

Edit the browser version in `browser/`. The original field-guide sheets are in `art/`. The browser embeds cropped JPEG views from `browser/scenes/`. To change the crops, edit and run `tools/prepare-art.py` with Pillow installed.

From the repository root, run:

```sh
python tools/build.py
python tools/check-place.py
```

Building uses the Python standard library. Both playable files are committed. Regenerating the place replaces direct edits to the exported Studio file, so keep changes to geometry and scripts in source.

## Playtest

In Studio, try a solo shift through the pool, reset your character mid-pool and check that you return to the ladder with your binder intact. In a two-player test, advancing one binder should leave the other player's creatures and pool reflection available.

The browser smoke test accepts Playwright and an installed Chromium browser. Set `PLAYWRIGHT_MODULE` to the module path and `CHROME_PATH` to the browser executable if they are outside the defaults. Run `node tools/check-browser.cjs` from the repository root.
