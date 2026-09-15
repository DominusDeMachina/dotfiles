#!/bin/bash

# Read JSON input from Claude Code
input=$(cat)


# Parse values from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "~"')
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // empty')
wt_name=$(echo "$input" | jq -r '.worktree.name // .workspace.git_worktree // empty')
wt_branch=$(echo "$input" | jq -r '.worktree.branch // empty')
wt_orig_branch=$(echo "$input" | jq -r '.worktree.original_branch // empty')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Shorten directory path (last 3 components, replace home with ~)
dir_short=$(echo "$cwd" | sed "s|$HOME|~|" | awk -F'/' '{n=NF; if(n<=3) print $0; else printf "%s/%s/%s", $(n-2), $(n-1), $n}')

# Fallback: plain git worktree (wt-new.sh style) — linked worktree has git-dir != git-common-dir
if [ -z "$wt_name" ] && [ -z "$wt_branch" ]; then
  gd=$(git -C "$cwd" rev-parse --absolute-git-dir 2>/dev/null)
  gcd=$(cd "$cwd" 2>/dev/null && cd "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null && pwd)
  if [ -n "$gd" ] && [ -n "$gcd" ] && [ "$gd" != "$gcd" ]; then
    wt_name=$(basename "$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)")
  fi
fi

# Location segment: worktree when in one, otherwise the path
if [ -n "$wt_name" ]; then
  wt_target="${wt_orig_branch:-dev}"
  loc="\033[35m⑂ ${wt_name}\033[0m \033[90m⇢ ${wt_target}\033[0m"
elif [ -n "$wt_branch" ]; then
  loc="\033[35m⑂ ${wt_branch}\033[0m"
else
  loc="\033[34m${dir_short}\033[0m"
fi

# SSH info (only show if in SSH session)
ssh_info=""
if [ -n "$SSH_CONNECTION" ]; then
  user=$(whoami)
  host=$(hostname -s)
  ssh_info="\033[36m${user}@${host}\033[0m:"
fi

# Git info
git_info=""
branch=$(git -c core.fileMode=false symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
if [ -n "$branch" ]; then
  # Check if repo is dirty
  if git -c core.fileMode=false diff --quiet --ignore-submodules 2>/dev/null &&
    git -c core.fileMode=false diff --cached --quiet --ignore-submodules 2>/dev/null; then
    git_color="\033[32m" # Green for clean
    status="✔"
  else
    git_color="\033[38;5;208m" # Orange for dirty
    status="✗"
  fi
  git_info=" ${git_color}${branch} ${status}\033[0m"
fi

# Model color based on type
if echo "$model" | grep -qi "opus"; then
  model_color="\033[31m" # Red for Opus
elif echo "$model" | grep -qi "sonnet"; then
  model_color="\033[33m" # Yellow for Sonnet
elif echo "$model" | grep -qi "haiku"; then
  model_color="\033[32m" # Green for Haiku
else
  model_color="\033[90m" # Grey for others
fi

# Context usage with color coding
ctx=""
if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used" 2>/dev/null || echo "50")
  if [ "$used_int" -gt 80 ] 2>/dev/null; then
    ctx_color="\033[31m" # Red when high usage
  elif [ "$used_int" -gt 50 ] 2>/dev/null; then
    ctx_color="\033[33m" # Yellow when medium
  else
    ctx_color="\033[32m" # Green when low usage
  fi

  # Format tokens (convert to k if >= 1000)
  tokens_info=""
  if [ -n "$input_tokens" ] && [ -n "$output_tokens" ]; then
    if [ "$input_tokens" -ge 1000 ] 2>/dev/null; then
      in_fmt="$(echo "scale=1; $input_tokens/1000" | bc)k"
    else
      in_fmt="$input_tokens"
    fi
    if [ "$output_tokens" -ge 1000 ] 2>/dev/null; then
      out_fmt="$(echo "scale=1; $output_tokens/1000" | bc)k"
    else
      out_fmt="$output_tokens"
    fi
    tokens_info=" ${in_fmt}↓ ${out_fmt}↑"
  fi

  ctx=" ${ctx_color}(${used_int}%%${tokens_info})\033[0m"
fi

# Row 2: model + context
row2=" ${model_color}[${model}]\033[0m${ctx}"

# Lines added/removed this session — shown on row 1, right after the branch
diff_info=""
if [ "$lines_added" -gt 0 ] 2>/dev/null || [ "$lines_removed" -gt 0 ] 2>/dev/null; then
  diff_info=" \033[32m+${lines_added}\033[0m\033[90m/\033[0m\033[31m-${lines_removed}\033[0m"
fi

# Output the status line
printf "${ssh_info}${loc}${git_info}${diff_info}\n"
[ -n "$row2" ] && printf "${row2# }\n"
