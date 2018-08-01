#
# Executes commands at logout.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

tmux kill-server

# Print the message.
cat <<-EOF
  (^_^)/~
EOF
