Past Claude sessions are archived as org files under ~/.claude-archive (one file per session, with #+TITLE and #+CWD headers). When the user refers to earlier work you have no context for, search there with Grep before asking.

## Documents: Org, not Markdown

Write the documents you create for the user in Org mode (`.org`): notes, reports, plans, summaries, drafts and the like. The user exports them from Emacs to Markdown, HTML, PDF or Word when needed. Use real Org syntax, not Markdown inside a `.org` file:

- `*` headings, `#+TITLE:`
- `*bold*`, `/italic/`, `~code~`
- `[[url][text]]` links
- `#+begin_src LANG` … `#+end_src` code blocks
- `|` tables

Keep Markdown where the format is fixed:

- a repo's existing Markdown docs, such as README.md
- CLAUDE.md, skill and agent files
- anything for GitHub (PR descriptions, issues, comments)
- files a tool expects as Markdown
- anything the user asks for in Markdown

Your chat replies stay Markdown, since the session renders them.

## Emacs

When `$KDB_CLAUDE_SESSION` is set, you are running in the user's Emacs (agent-shell), in a tab of your own, and that variable is your session id. Get it once with `echo $KDB_CLAUDE_SESSION` and write it literally in the elisp below. Run elisp from Bash with a quoted heredoc, so apostrophes and `$` need no shell escaping (which also means shell variables are not expanded inside it):

```bash
"${EMACSCLIENT:-emacsclient}" --eval "$(cat <<'EOF'
(kdb-claude-show "YOUR-SESSION-ID" "src/parser.ts" 42)
EOF
)"
```

In strings, escape only `"` as `\"` and `\` as `\\` (elisp string rules), and use forward slashes in paths, including on Windows (`C:/Users/...`).

This works the same on Linux, macOS and Windows. On Windows your Bash tool is Git Bash, so the heredoc works there too.

### Keep to your tab

Everything you put on screen goes in your own tab, beside your session, and never moves the user: not their tab, window or cursor. Use only these helpers to show or run things. Don't call `find-file`, `switch-to-buffer`, `pop-to-buffer`, `display-buffer`, or make windows, tabs or frames yourself.

- `(kdb-claude-show ID FILE-OR-BUFFER LINE)` shows a file (relative to your directory, or absolute) or a buffer beside your session, at LINE if given. Calls reuse the same split.
- `(kdb-claude-run ID COMMAND DIR SHELL)` runs COMMAND in the project shell, shown in your tab, and returns the shell's buffer name. DIR defaults to your directory. SHELL is `"bash"` or `"pwsh"`. The default is bash (Git Bash on Windows, as your Bash tool uses), or pwsh when there's no bash. Stay with bash on Windows too, since PowerShell works poorly inside Emacs there. Pass `"pwsh"` only for something that has to be PowerShell. The shell persists, so `cd` and variables carry over.
- `(kdb-claude-output BUFFER LINES)` returns the last LINES (default 40) lines of BUFFER, to read a shell's results. Poll it rather than sleeping.

Show the user something only when they need to see it, such as a file you want them to review or a log you're pointing at. Don't show what you're merely reading.

### Running commands

Run any command that needs no admin rights and no password, in whichever way fits:

- Use your own Bash tool for quick commands whose output only you need.
- Use `kdb-claude-run` for what the user should watch or that keeps running: dev servers, watchers, long builds and test runs, REPLs.

Never run anything needing admin rights or a password through Emacs or Bash. That means:

- Linux: `sudo`, `su`, `pkexec`, or `doas`.
- macOS: `sudo`, or `osascript` with administrator privileges.
- Windows: `runas`, `gsudo`, Windows' own `sudo`, `Start-Process -Verb RunAs`, or anything that opens a UAC prompt.
- Anywhere: a command that stops to ask for a password or passphrase.

Such a prompt would stall the shell or wait on a dialog nobody sees. Instead, tell the user the exact command and why, and let them run it.

### Clean up after yourself

When you're done with what you opened, call `(kdb-claude-cleanup ID)`. It closes the windows you opened and kills the buffers and shells you started. It keeps anything with unsaved changes, and anything the user already had open. Do this before ending a task, not between steps you're still working on. The same cleanup runs when your session ends.

Leave things open when the user asked for them ("open X", "show me Y", "run the server") or invoked a skill that opens them. Those are theirs to close. Say what you left open, if anything.

### Tests and byte-compiling ~/.emacs.d

Run this config's ERT suites and byte-compiling in `emacs --batch`, not in the user's Emacs through emacsclient. The tests open and close tabs, kill buffers and start shells, which must not happen in the live session. To make a change live, load just the changed file into the user's Emacs with `(load FILE nil t)`. Don't reload `init.el` or `early-init.el` there. Loading doesn't replace a `defvar` or keymap that already exists: also set or `define-key` what changed. Never clear a buffer's local hooks with `kill-local-variable`, since other packages' hooks live there too. Remove only your own with `remove-hook`.

### Sibling sessions

You can start sibling sessions and message them yourself, instead of asking the user to open one. Use this for parallel or follow-up work, for example "fix this in a worktree and tell me when CI is green".

- `(kdb-claude-spawn DIR PROMPT FROM BRANCH)` starts a session and prints its id. Pass your own id as FROM, and the child's prompt ends with instructions to report back to you. BRANCH is optional: if given, the child works in that branch's own worktree beside the repo (the branch is created if needed, and the main checkout is never switched). Otherwise it works in DIR. The child opens in its project's tab without taking the user's focus.
- `(kdb-claude-message TO TEXT FROM)` sends TEXT to session TO. It arrives when TO's current turn is over. Use it to follow up with a child, or to answer a session that messaged you. Messages you receive start with `[Message from Claude session ID]`.

Use a trailing slash on DIR. A child can't see your conversation, so make its PROMPT self-contained. Tell the user which sessions you started and why. Don't wait or poll for a reply: end your turn, and the reply arrives as a new message.
