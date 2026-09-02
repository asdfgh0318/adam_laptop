# ---- adam's .bashrc additions (from the Precision 5520) ----

alias emacs="emacsclient -c -a 'emacs'"

export EDITOR="emacs -nw"
export PATH="$HOME/bin:$HOME/.config/emacs/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# Model default now lives in ~/.claude/settings.json ("model") so that /model
# selections actually persist. Uncomment only to force-pin a model:
# export ANTHROPIC_MODEL="claude-opus-5[1m]"

# opencode
export PATH=$HOME/.opencode/bin:$PATH

# --- go: build the standard sway working layout ------------------------
# Two rangers stacked on the left, brave on the right, beeper in the
# scratchpad ($mod+minus). Builds on the lowest empty workspace. The
# launching terminal closes itself so it does not end up as a stray pane.
#   go            build it
#   go --ws 3     build on a specific workspace
#   go --mode ws2 keep a terminal on the right, brave gets its own workspace
#   go -k ...     keep this terminal open (useful for reading the log)
go() {
    local keep=0 bin
    [ "${1:-}" = "-k" ] && { keep=1; shift; }
    if ! bin=$(command -v go-layout); then
        printf 'go: go-layout not found in PATH\n' >&2
        return 1
    fi
    # Launch via sway, not setsid. A setsid child of this terminal races the
    # terminal closing and loses: it is killed before it can even start.
    # Anything sway execs is parented to sway and outlives the terminal.
    # Pass the absolute path -- sway's own PATH has no ~/.local/bin, so a
    # bare name is silently not-found and nothing happens at all.
    if ! swaymsg exec -- "'$bin' $*" >/dev/null 2>&1; then
        printf 'go: swaymsg exec failed\n' >&2
        return 1
    fi
    [ "$keep" = 1 ] && return 0
    exit
}
# -----------------------------------------------------------------------
