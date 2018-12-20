workflow "Test workflow" {
  on = "push"
  resolves = ["Hello World"]
}

action "Shell" {
  uses = "actions/bin/sh@master"
  args = ["ls -ltr"]
}
