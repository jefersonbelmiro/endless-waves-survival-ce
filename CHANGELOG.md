# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.24.0]

### Added
- Scoreboard entry details, allowing players to view additional information by clicking on a scoreboard entry.
- 3 new traits to diversify gameplay.

### Changed
- Scoreboard reset to provide new players with a chance to appear in the rankings.

### Fixed
- Minor bugs for improved stability and performance.

## [v0.23.2]

### Fixed
- Scoreboard security issues.

## [v0.23.1]

### Fixed
- Fixed enemy collision in the Treacherous Tombs map.
- Resolved settings UI focus issue.

## [v0.23.0]

### Added
- Added a "quit" screen if a player leaves the game after 30 seconds.
- Added more background music options.
- Implemented settings to show/hide autocast skill icons.

### Changed
- Validated display names to prevent profanity.

### Fixed
- Fixed an issue where scores were not being sent after playing for 1 hour.

## [v0.22.0]

### Added
- Implemented basic leaderboard.
- Introduced new enemy: Reaper (1,000 score bonus on defeat).

### Changed
- Added Steam Cloud save support.
- Adjusted attack speed for balance (nerf).
- Deprecated old versions.

### Fixed
- Addressed game crashes and UI issues.

## [v0.21.0]

### Added
- Implemented the trait system, affecting the game as long as the player remains alive, similar to the "backpack" mechanic.
- Initially added 3 distinct traits to diversify strategic possibilities.

### Changed
- Updated icons and some color palettes; changed from "purple" to "black" for a darker aesthetic.
- Removed outlines from character and enemy textures, providing a cleaner and more streamlined visual presentation.
- Hidden the autocast icon from the HUD; a customizable option for this will be introduced in future updates.
- Introduced the "weapon" card type, featuring no cooldown but relying on attack speed.
- Standardized the card type to "weapon" for all characters.

### Fixed
- Performance and stability issues.

## [v0.20.0]

### Added
- 2 consumables.

### Changed
- Texture of some consumables.
- Unlock all card upgrades by default (you can still change upgrades in the deck editor).
- Consumables grouped when dropped.
- Increased enemy damage at high levels.
- Reduced invulnerability time to 1s after being hit.

### Fixed
- Portal made player immortal.

## [v0.19.0]

### Changed
- Desert map: reduce enemy level-up.
- Experience progression: reduce the experience required to level up at higher levels.
- Invulnerability is no longer a card; it is part of the game. When you receive a hit you become invulnerable for 2s.
- When upgrading all cards, enemies no longer drop experience gems.

### Fixed
- Frost attack bug with ice ball.

## [v0.18.0]

### Added
- 2 cards: shallow grave and invulnerability.

### Changed
- Desert map: enemy level-up by amount of kills instead of time.

### Fixed
- Small bugs.

## [v0.17.0]

### Added
- Card: scorch card.
- Setting: auto aiming mode setting.

### Changed
- Tweak glow effect (by default this setting is disabled).

## [v0.16.0]

### Added
- Character: caveman char.
- Card: club card.
- Setting: aiming mode setting (currently only used by the "Club" skill).

### Changed
- Spin attack: increase area and knockback.

## [v0.15.0]

### Added
- Link to Discord channel in the main menu.

### Changed
- Experience progression (increased the experience required to level up at higher levels).

### Fixed
- Game crash.
- Memory leak.

## [v0.14.1]

### Fixed
- Game crash.

## [v0.14.0]

### Added
- Druid: add new character.
- Boomerang: add new card.

### Changed
- Rogue: add lifesteal passive.

## [v0.13.1]

### Changed
- Desert map: increased difficulty.

### Fixed
- Treacherous Tombs: boss spawn.

## [v0.13.0]

### Added
- Added new map (Desert) without borders.

## [v0.12.1]

### Changed
- Removed knockback from early enemies.

### Fixed
- Camera zoom.

## [v0.12.0]

### Added
- 3 new cards.

### Fixed
- Enemy jumping out of the map.

## [v0.11.0]

### Added
- A new map.
- 4 new enemies.

### Changed
- Tower textures.
- Chest texture.
- In the shop you can now sell consumable items.

### Fixed
- Game crash and memory leak.

## [v0.10.1]

### Fixed
- Dash outside the map.

## [v0.10.0]

### Added
- Three consumable scrolls for summoning towers.
- Three cards to upgrade summoned towers.

### Fixed
- Game crash.

## [v0.9.0]

### Added
- Bulldoze skill.
- Default decks.
- Restored coins when removing deck.
- Improved touchscreen support.

### Changed
- Increase proc chance on passive frost attack.
- Change aiming skills (arrow and dagger) to autocast to the nearest enemy (the crosshair will come back later as settings).

### Fixed
- Game crash.

## [v0.8.1]

### Fixed
- Game crash (thanks to LC666 for helping find the problem).

## [v0.8.0]

### Added
- Dash damage upgrade.
- Shield explosion upgrade.
- Spiral ball explosion upgrade.

### Fixed
- Game crash.

## [v0.7.1]

### Fixed
- Deck edit screen.

## [v0.7.0]

### Added
- Background image to main menu (created by Inkpendude).
- Music to main menu (created by ComposerOfEmotions).
- Card setup in deck: when adding cards to the deck, you can now choose which upgrades. In the game, when evolving the card, the number of upgrades is random, minimum 1, maximum total of upgrades activated when configuring the deck.
- Two levels to the map Flying assault.

### Changed
- UI colors.

### Fixed
- Deck deletion.

## [v0.6.0]

### Added
- Projectile velocity passive card.
- Spell duration passive card.
- Knockback passive card.
- Ice attack passive card.
- Character: archer.

### Changed
- The deck is now linked to the character. When selecting the character you can change the deck or create a new one.
- Remove toggle version button and add switch version option in settings screen.
- Shield card: reduced damage block.
- Rusty shield card: reduced damage block.
- Fireball: reduced maximum projectiles.
- Maps: reduced chance of dropping coins.

### Fixed
- Landscape sensor.
