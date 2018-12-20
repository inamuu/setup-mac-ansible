workflow "Test workflow" {
  on = "push"
  resolves = "shell"
}

action "shell" {
  uses = "actions/bin/sh@master"
  args = "\"echo\", \"'Hello World!!'\""
}
