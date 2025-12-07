# Godot Client for Keymaster's Keep
This project is a Godot Client implementation for [Keymaster's Keep](https://github.com/silasary/Archipelago/releases/tag/keymasters-2.0.1), a bingo-style game for [Archipelago](https://archipelago.gg/).

It uses the [GodotAP](https://github.com/EmilyV99/GodotAP) library to handle connection between client and server.

This client doesn't store any info locally, so you need to keep connected to the server for it to work. However, this means it's easier to make it able to connect via Browser and Mobile.

# What you should know before using it:
This is just an attempt to make a client that's able to connect via mobile/browser, and is my first project involving Archipelago, so there's probably things to optimize and to make better.

If you find any bug or have any suggestion, you can either create an Issue here in github, or contact me via discord: @fafale (in the Archipelago server or DMs)
## What is already implemented:
- Unlocking areas, sending objectives from trials. (Including game medleys)
- Goaling for both goal types (Keymaster's Challenge and Magic Key Heist)
- Items you receive will be handled accordingly, but you won't have a chat/log to notify you that you've received them

## What is NOT implemented yet:
- Server chat, including sent/received items and hints.
- Shop locations (you should be able to safely connect to slots with shops enabled, you just can't send their items)
- Completed trials tab
- Wrong connection info, such as writing the wrong address or port (you'll need to re-open the client to try again)
- Reconnecting after accidental disconnection, such as internet failing (you'll need to re-open the client to connect again)
