-- Tmux-style bindings from ~/.tmux.conf. Existing Rex shortcuts remain available.
-- Press Ctrl+A, release, then press the next key. Escape cancels a sequence.
-- Quick reference after Ctrl+A: | / - split; h/j/k/l focus; Alt+h/j/k/l resize;
-- c/n/p create/next/previous tab; 0 is the first tab; z zoom; [ scroll; r reload; M edit.
-- Defaults are preserved. This file must be installed separately on remote hosts.
-- After the first prefix + Alt-direction resize, repeat Alt+h/j/k/l without
-- the prefix. Escape exits resize mode; other keys keep their normal behavior.
local prefix = "ctrl+a>"

-- Send the prefix through to the shell or nested tmux.
rex.bind(prefix .. "ctrl+a", "pane.send_key", { key = "ctrl+a" })

-- Exclusive scroll mode: Page Up/Down scroll; Escape or q exits.
rex.mode("scroll", { exclusive = true })
rex.bind(prefix .. "[", "client.mode.enter", { name = "scroll" })
rex.bind("scroll/pageup", "client.scroll.page_up")
rex.bind("scroll/pagedown", "client.scroll.page_down")
rex.bind("scroll/q", "client.mode.exit")

-- Splits: | (Shift+backslash on a US layout) and -.
rex.bind(prefix .. "shift+\\", "pane.split", { direction = "right" })
rex.bind(prefix .. "-", "pane.split", { direction = "down" })

-- Vim-style pane focus, plus tmux's arrow-key navigation.
local directions = { h = "left", j = "down", k = "up", l = "right" }
rex.action{
  name = "resize_repeat",
  title = "Resize Pane and Enable Repeating",
  args = { direction = "string" },
  run = function(ctx, args)
    rex.client.queue("pane.resize", { direction = args.direction, amount = 5 })
    rex.client.queue("client.mode.enter", { name = "resize" })
  end,
}
for key, direction in pairs(directions) do
  rex.bind(prefix .. key, "pane.focus", { direction = direction })
  rex.bind(prefix .. direction, "pane.focus", { direction = direction })
  -- Rex moves the divider by 5 percent, not tmux's 5 cells.
  rex.bind(prefix .. "alt+" .. key, "resize_repeat", { direction = direction })
  rex.bind("resize/alt+" .. key, "pane.resize", { direction = direction, amount = 5 })
end
rex.bind(prefix .. "o", "pane.focus_next")
rex.bind(prefix .. "z", "pane.zoom")
-- Unlike tmux's confirmation prompt, this closes the focused pane directly.
rex.bind(prefix .. "x", "pane.close")
rex.bind(prefix .. "shift+1", "pane.move_to_new_tab") -- !

-- Tmux windows correspond to Rex tabs.
rex.bind(prefix .. "c", "client.tab.new")
rex.bind(prefix .. "n", "client.tab.next")
rex.bind(prefix .. "p", "client.tab.previous")
rex.bind(prefix .. "ctrl+n", "client.tab.next") -- tmux-sensible
rex.bind(prefix .. "ctrl+p", "client.tab.previous")
rex.bind(prefix .. ",", "client.tab.rename")
-- Tmux's default base-index is 0; Rex tab indices start at 1.
for index = 0, 9 do
  rex.bind(prefix .. tostring(index), "client.tab.goto", { index = index + 1 })
end
-- Ctrl+A a (tmux-sensible last-window) has no built-in Rex action; left unbound.

rex.bind(prefix .. "s", "session.switch")
rex.bind(prefix .. "shift+4", "session.rename") -- $
rex.bind(prefix .. "r", "client.config.reload")
rex.bind(prefix .. "shift+r", "client.config.reload") -- tmux-sensible

-- Like Ctrl+A M in tmux, open the corresponding config in a right-hand nvim split.
local config_path = os.getenv("REX_CONFIG")
  or ((os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/rex/init.lua")
rex.action{
  name = "edit_config",
  title = "Edit Rex Config in Neovim",
  run = function(ctx)
    return assert(rex.session.new_split{
      session_id = ctx.session_id,
      anchor_id = ctx.block_id,
      direction = "horizontal",
      side = "after",
      focus = true,
      layout = rex.layout.block{
        flavor = "com.superlogical.terminal.shell",
        options = { command = { "nvim", config_path } },
      },
    })
  end,
}
rex.bind(prefix .. "shift+m", "edit_config")
