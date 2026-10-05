if status is-interactive
    # Commands to run in interactive sessions can go here
end
starship init fish | source

abbr -a dsh "cd /home/bunnydeny/.deepseek-harness && pnpm dsh web"
abbr -a ssh_server "ssh bunnydeny@154.9.254.26"
zoxide init --cmd cd fish | source
set -gx EDITOR nvim

