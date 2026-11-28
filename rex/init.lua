-- Rex config, modelled on ~/.tmux.conf: ctrl+b stays the leader, but the
-- tmux prefix becomes key sequences, `bind -r` becomes key modes, and
-- anything scripted is a custom action so it also shows up in the palette.
-- Reload with `rex config reload`, inspect with `rex keymap`.

local LEADER = "ctrl+b"
local TERMINAL = "com.superlogical.terminal"
local SHELL = "com.superlogical.terminal.shell"

-- The dotfiles checkout's bin/, found through the ~/.config/rex symlink so the
-- scripts work before install.sh links them into /usr/local/bin.
local CONFIG_DIR = (os.getenv("REX_CONFIG") or ""):match("^(.*)/[^/]*$")
  or (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/rex"
local resolved = rex.exec({ "realpath", CONFIG_DIR })
local DOTFILES_BIN = (resolved and resolved.ok and resolved.stdout:gsub("%s+$", "") or CONFIG_DIR) .. "/../bin"

local function lead(key, action, args)
  rex.bind(LEADER .. ">" .. key, action, args)
end

lead("ctrl+b", "pane.send_key", { key = "ctrl+b" })

-- Tabs (tmux windows)
lead("c", "client.tab.new")
lead("n", "client.tab.next")
lead("p", "client.tab.previous")
lead(",", "client.tab.rename")
lead("shift+7", "client.tab.close")
for i = 1, 9 do
  lead(tostring(i), "client.tab.goto", { index = i })
end

-- Panes
lead("shift+v", "pane.split", { direction = "right" })
lead("shift+s", "pane.split", { direction = "down" })
lead("z", "pane.zoom")
lead("x", "pane.close")
lead("o", "pane.focus_next")
lead(";", "pane.focus_previous")
lead("=", "pane.balance")
lead("f", "pane.float")
lead("shift+1", "pane.move_to_new_tab")
-- tmux's mark + join-pane, as a picker
lead("shift+m", "pane.move_to_tab")

-- Sessions
lead("s", "session.switch")
lead("shift+4", "session.rename")
lead("shift+9", "session.previous")
lead("shift+0", "session.next")
rex.bind("alt+j", "session.next")
rex.bind("alt+k", "session.previous")

-- workmux drives Rex natively (0.1.283+), so these match .tmux.conf: agent
-- sidebar, dashboard, and a new worktree from the current pane's repo.
lead("ctrl+t", "popup", { command = { "workmux", "sidebar" } })
lead("ctrl+d", "popup", { command = { "workmux", "dashboard" } })
lead("ctrl+w", "popup", { command = { "zsh", "-c", 'read "b?worktree: " && [[ -n $b ]] && workmux add "$b"' } })
-- Rex's own session sidebar
lead("shift+t", "client.sidebar.toggle")

lead("r", "client.config.reload")
lead("[", "client.find.open")

-- Repeatable keys (tmux `bind -r`): the leader key does the first step and
-- leaves you in an exclusive mode where the bare key repeats it. Escape or
-- enter leaves.
rex.mode("adjust", { exclusive = true })
rex.bind("adjust/enter", "client.mode.exit")

rex.action{
  name = "adjust",
  title = "Adjust Layout",
  description = "Run one layout step, then stay in adjust mode to repeat it",
  args = { action = "string", args = "object?" },
  run = function(ctx, args)
    rex.client.queue(args.action, args.args)
    rex.client.queue("client.mode.enter", { name = "adjust" })
  end,
}

local function repeatable(key, action, args)
  lead(key, "adjust", { action = action, args = args })
  rex.bind("adjust/" .. key, action, args)
end

for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  repeatable(key, "pane.resize", { direction = direction, amount = 10 })
  -- Move the pane within the tab (tmux swap-pane), shift+hjkl.
  repeatable("shift+" .. key, "pane.move", { direction = direction })
end
-- tmux's { and } swap with the previous/next pane; here left/right.
repeatable("shift+[", "pane.move", { direction = "left" })
repeatable("shift+]", "pane.move", { direction = "right" })
repeatable("left", "client.tab.move.backward")
repeatable("right", "client.tab.move.forward")

-- vim-tmux-navigator: ctrl+hjkl moves between panes, except inside (n)vim,
-- which keeps the key for its own splits and calls `rex focus` at an edge
-- (vim/configs/rex.vim). tmux gets the key too, for its own navigator.
local VIM = { vim = true, nvim = true, view = true, vimdiff = true, tmux = true }

for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+" .. key, function(ctx)
    local proc = rex.block.call(TERMINAL, "process", { block_id = ctx.block_id })
    local fg = proc and proc.foreground
    if fg and VIM[fg.name] then
      return false
    end
    rex.session.focus_direction{ direction = direction }
    return true
  end)
end

-- Popups (tmux display-popup): a floating layer in the current directory that
-- closes when the program exits.
rex.action{
  name = "popup",
  title = "Run in Popup",
  args = { command = "array" },
  run = function(ctx, args)
    local pwd = rex.block.call(TERMINAL, "pwd", { block_id = ctx.block_id })
    local cwd = pwd and pwd.pwd and pwd.pwd:gsub("^file://[^/]*", "")
    local _, err = rex.session.new_layer{
      bounds = { 0.05, 0.05, 0.9, 0.9 },
      focus = true,
      layout = rex.layout.block{
        flavor = SHELL,
        options = { command = args.command, cwd = cwd },
      },
    }
    if err ~= nil then error(err, 0) end
  end,
}

lead("ctrl+a", "popup", { command = { "claude", "agents" } })

-- iTerm2's cmd-click-a-path, by keyboard: Rex can't run a command on click, so
-- pick a path from this pane's screen and open it in the tab's nvim
-- (bin/rex-open-path).
rex.action{
  name = "open_path",
  title = "Open Path in Nvim",
  description = "Pick a file path on this pane's screen and open it in the tab's nvim",
  run = function(ctx)
    local _, err = rex.invoke("popup", {
      command = { DOTFILES_BIN .. "/rex-open-path", ctx.session_id, ctx.block_id },
    })
    if err ~= nil then error(err, 0) end
  end,
}
lead("ctrl+o", "open_path")

-- New agent in a tab of its own, in the current pane's directory. Agents started
-- from `claude agents` run in Claude Code's background daemon, outside any Rex
-- terminal, so they never show up in Rex's activity list; this one does.
rex.action{
  name = "claude_tab",
  title = "New Claude Tab",
  description = "Open claude in a new tab, in the current pane's directory",
  run = function(ctx)
    local pwd = rex.block.call(TERMINAL, "pwd", { block_id = ctx.block_id })
    local cwd = pwd and pwd.pwd and pwd.pwd:gsub("^file://[^/]*", "")
    local _, err = rex.session.new_window{
      window_label = "claude",
      focus = true,
      layout = rex.layout.block{
        flavor = SHELL,
        options = { command = { "claude" }, cwd = cwd },
      },
    }
    if err ~= nil then error(err, 0) end
  end,
}
lead("ctrl+n", "claude_tab")
-- tmux's choose-tree: every tab in every session (bin/rex-tab-picker)
lead("w", "popup", { command = { DOTFILES_BIN .. "/rex-tab-picker" } })

-- tmux's last-window, across sessions. tab-history.lua records the tab you leave;
-- this jumps there and records where it came from, so pressing again toggles back.
local tab_state = dofile(CONFIG_DIR .. "/tab_state.lua")

rex.action{
  name = "last_tab",
  title = "Last Tab",
  description = "Jump to the previously active tab, in any session",
  run = function(ctx)
    local st = tab_state.read()
    local target = st.previous
    if not target then error("no previous tab recorded yet", 0) end

    local view = rex.session.view{}
    st.previous = { session_id = ctx.session_id, window_id = view and view.active_window_id }
    st.pending = { window_id = target.window_id, at = os.time() }
    tab_state.write(st)

    if target.session_id == ctx.session_id then
      local _, err = rex.session.focus_window{ window_id = target.window_id }
      if err ~= nil then error(err, 0) end
    else
      rex.client.queue("session.select", target)
    end
  end,
}
lead("ctrl+l", "last_tab")
-- tab-history.lua is started by custom.zsh from the first Rex shell: processes
-- started while this file loads don't survive the load.
