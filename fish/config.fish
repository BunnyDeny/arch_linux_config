if status is-interactive
    # Commands to run in interactive sessions can go here
end
command -q starship; and starship init fish | source

abbr -a dsh "cd /home/bunnydeny/.deepseek-harness && pnpm dsh web"
abbr -a ssh_debian "ssh gyh@192.168.110.168"
zoxide init --cmd cd fish | source
set -gx EDITOR nvim

