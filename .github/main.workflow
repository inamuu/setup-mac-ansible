workflow "Test workflow" {
  on = "push"
  resolves = ["HelloWorld"]
}

action "HelloWorld" {
  uses = "actions/aws/cli@8d31870"
  runs = [ "printf", "HelloWorld" ]
}
