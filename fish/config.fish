if status is-interactive
    # Commands to run in interactive sessions can go here
end
starship init fish | source

abbr -a dsh "cd /home/bunnydeny/project/deepseek-harness && pnpm dsh web"
