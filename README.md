# Pokedoku

A Pokédoku puzzle game built in Godot 4.2 with a SQLite database behind it. You get a 3×3 grid with a category on every row and column. Each cell has to be filled with a Pokémon that fits both its row and its column, for example a Pokémon that is both a Starter and Grass-type.

> [!WARNING]
> **This is not actually multiplayer.** The other three players are simulated bots running on your machine. There is no networking code.
>
> We planned to add real online multiplayer, but it fell outside the scope of the project and we ran out of time during the class. The lobby and opponent boards were built to show how multiplayer would look. The real work of the project is the puzzle logic and the database described below.

> [!NOTE]
> **I didn't create Pokémon or Pokédoku and don't own the rights to either.** Pokémon, including its names, data and sprite artwork, belongs to Nintendo, Game Freak, Creatures Inc. and The Pokémon Company. The Pokédoku puzzle format comes from the original Pokédoku game. This is a non-commercial college project we built to challenge ourselves, and it isn't affiliated with or endorsed by any of them.

## The database

All Pokémon data and sprites live in one SQLite file, `Pokemon Data/PokemonDB.db`, which Godot reads through the [godot-sqlite](https://github.com/2shady4u/godot-sqlite) addon.

**`Pokemon`** has one row for each of 1,231 Pokémon, counting alternate forms such as Mega and Alolan forms as separate entries. Each row holds:

- National and regional Pokédex numbers
- Base stats and stat total
- Primary and secondary type (`Mono` for single-type Pokémon)
- Abilities and hidden ability
- EV yield, gender, egg groups and catch rate
- Evolution info
- Region, rarity and form

**`PokemonImages`** stores each Pokémon's sprite as a PNG blob, keyed by `PokemonID`. A trigger on `Pokemon` inserts a matching `PokemonImages` row whenever a new Pokémon is added. A foreign key with `ON DELETE CASCADE` removes the sprite when its Pokémon is deleted.

Because the sprites are in the database, the game needs no folder of image files. Search results, the grid and player avatars all load their PNGs straight out of SQLite.

## Generating a puzzle

The hard part of a Pokédoku is making sure every cell has at least one answer. Most of the logic is in `Scripts/PokemonData.gd`.

### Categories and difficulty

Categories are grouped into four tiers. Each difficulty level includes its own tier and every tier below it.

| Tier | Categories |
|---|---|
| Easy | Primary type, secondary type, rarity |
| Medium | Form, region |
| Hard | Egg groups, evolution info, abilities, hidden ability, Pokédex numbers, gender |
| Extreme | Catch rate, EV yield, individual base stats, stat total |

The game currently runs on Easy (`difficulty = 1`).

### Building the answer pool

At startup, for each active category, the game:

1. Runs `SELECT DISTINCT` to get every possible value for that category.
2. Runs `COUNT(*)` for each value.
3. Keeps only values that more than three Pokémon share. Missing values are dropped, except for the two evolution columns, where an empty value is a meaningful answer.

The count step keeps rare values out of the pool, so the game won't build a grid around a category value that only one or two Pokémon have.

### Choosing the rows and columns

The game picks the three columns and three rows one at a time, alternating between columns and rows. For each pick it:

1. Chooses a random category. The grid's very first pick comes from a shortlist of broad categories (types, rarity, region, egg groups and evolution info, limited to whichever are active at the current difficulty) so the grid starts from something with plenty of answers.
2. Pulls a random Pokémon from the database and uses that Pokémon's value for the category. This weights the choice by how common a value is, so Water comes up more often than Fairy.
3. Checks the new value against every category already chosen on the other axis. For each pair, it queries the database for at least one Pokémon that matches both.

A few rules keep the grid fair:

- A category can't appear on both axes.
- No value is repeated anywhere in the grid.
- Columns never use secondary type and rows never use primary type.

If a value fails the check, the game tries another. After 10 failed tries it throws the grid away and starts over. Because the picks alternate, all nine row and column pairs get checked by the time the grid is finished. A final pass prints each cell to the console in green (has an answer) or red (has none).

### Checking an answer

When you select a cell, a search box opens. After you type three or more letters, it lists every Pokémon whose name contains them, each with its sprite from the database. Picking one looks it up in the `Pokemon` table and compares it to the cell's row and column. If both the row and column are types, a Pokémon matches as long as it has both types, in either order. All other categories must match exactly.

A correct answer puts the Pokémon's sprite in the cell, turns it green and locks it. A wrong answer leaves the cell empty so you can try again. The refresh button generates a new set of categories and clears the board.

## The simulated opponents

When you click **Multiplayer** on the main menu:

1. The lobby adds three bot players, each with a random name and a random Pokémon from the database as its avatar.
2. The bots ready up on their own. The game starts once you tick your own ready box and all four players are ready.
3. In the game, your board sits next to the three bot boards. Each board generates its own grid with the same logic as yours.
4. Every 20 seconds, a random bot fills one of its empty cells. It does this by querying the database for a Pokémon that matches that cell's row and column.

## Running it

Open the project folder in [Godot 4.2](https://godotengine.org/download/archive/) and press Play. The main scene is `main_menu.tscn`. The SQLite addon is included in `addons/`, so nothing else needs installing.

## Project layout

| Path | Description |
|---|---|
| `Scripts/PokemonData.gd` | Autoload with the database connection, difficulty tiers, answer pool, grid generation and answer checking |
| `Scripts/PlayerManager.gd` | Autoload that tracks players, ready-ups and each player's puzzle |
| `Scripts/PokemonSearch.gd` | Search box and results list with sprites |
| `CellControl.gd`, `Scripts/PokeButton.gd` | The 3×3 grid: opening the search, checking answers, marking cells solved and resetting |
| `Scripts/Category.gd` | Row and column labels with a fade-in animation |
| `Puzzle.gd` | One player's board: name, avatar and the bot "solve a random cell" logic |
| `PlayerControl.gd` | 20-second timer that makes a random bot solve a cell |
| `MenuControl.gd`, `Scripts/PlayerPanel.gd`, `WaitingLabel.gd` | Main menu, lobby and ready-up |
| `Main.tscn`, `main_menu.tscn` | Game scene and main menu scene |
| `FakePlayer.tscn`, `FakePlayerPuzzle.tscn` | Bot lobby card and bot board |
| `Pokemon Data/PokemonDB.db` | The SQLite database |
| `addons/` | godot-sqlite, and the Godot Git plugin used during development |
