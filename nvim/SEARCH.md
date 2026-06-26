# Telescope search cheat-sheet

Three search keymaps, two different match engines:

| Key | Picker | Searches | Syntax |
|---|---|---|---|
| `<leader>ff` | `find_files` | file **names / paths** | fzf-native operators (`^` `$` `'` `!`) |
| `<leader>fs` | `grep_string` | file **contents** (everywhere) | ripgrep; prompts for the text |
| `<leader>fS` | `grep_string` + glob | file **contents**, scoped to matching files | ripgrep `--glob` (`*` `**` `?` …) |

Examples below use this small C# tree:
`src/Services/AccountService.cs`, `src/Controllers/AccountController.cs`,
`src/Models/Account.cs`, `tests/AccountServiceTests.cs`, `Dashboard.csproj`.

## fzf operators — `<leader>ff` search box (matches the file path)

No `*` here (fuzzy by default); you anchor with `^` / `$`.

| Type | Means | Example | Matches |
|---|---|---|---|
| `foo` | fuzzy (chars in order) | `accser` | `src/Services/AccountService.cs`, also `…AccountServiceTests.cs` |
| `'foo` | exact substring | `'AccountService` | `…/AccountService.cs`, `tests/AccountServiceTests.cs` — **not** `AccountController.cs` |
| `^foo` | starts with | `^src/` | everything under `src/` — **not** `tests/…` |
| `foo$` | ends with | `Service.cs$` | `…/AccountService.cs` — **not** `AccountServiceTests.cs` (ends `Tests.cs`) |
| `!foo` | exclude | `Service.cs$ !tests` | `src/Services/AccountService.cs` — **excludes** `tests/AccountService.cs` |
| space | AND | `^src Service.cs$` | `src/Services/AccountService.cs` — **not** `tests/OrderService.cs` |
| `\|` | OR | `Controller.cs$ \| Service.cs$` | both `AccountController.cs` **and** `AccountService.cs` |

## ripgrep glob — `<leader>fS` "File glob" prompt (matches the file path)

This is where `*` lives; no `^` / `$`.

| Symbol | Means | Example | Matches |
|---|---|---|---|
| `*` | any chars except `/` | `*Service.cs` | `AccountService.cs` at any depth — **not** `AccountServiceTests.cs` |
| `**` | any chars incl. `/` | `**/Services/*.cs` | files directly in any `Services/` dir |
| `?` | single char | `Foo?.cs` | `Foo1.cs`, `FooA.cs` — **not** `Foo.cs` or `Foo12.cs` |
| `[...]` | char class | `[A-Z]*.cs` | basenames starting uppercase: `Account.cs` — **not** `account.cs` |
| `{a,b}` | alternation | `*.{cs,csproj}` | `Account.cs` **and** `Dashboard.csproj` |
| `!` (prefix) | exclude | `!*Tests.cs` | every file **except** those ending `Tests.cs` |
| `.` | literal dot | `*.cs` | all `.cs` files |

## One-liner

- `<leader>ff` → `Service.cs$` — files **named** `…Service.cs`
- `<leader>fS` → `*Service.cs` — grep **inside** files named `…Service.cs`

Same `*Service.cs` idea, two syntaxes: one filters a fuzzy file list, the other is a real file glob passed to ripgrep.
