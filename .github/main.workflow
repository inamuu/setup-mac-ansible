workflow "Test workflow" {
  on = "push"
  resolves = ["aws cli help"]
}

action "aws cli help" {
  uses = "actions/aws/cli@8d31870"
  args = [
    "aws",
    "help"
  ]
}
