workflow "Test workflow" {
  on = "push"
  resolves = [
    "HelloWorld",
    "Shell"
  ]
}

action "HelloWorld" {
  uses = "actions/aws/cli@8d31870"
  runs = [ "printf", "HelloWorld" ]
}

action "Shell" {
  uses = "actions/bin/sh@master"
  args = ["ls -ltr"]
}

action "nginx" {
  needs = "Shell"
  uses  = "docker://nginx:latest"
  runs  = "nginx -t"
}