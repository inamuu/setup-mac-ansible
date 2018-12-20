workflow "Test workflow" {
  on = "push"
  resolves = [
    "1_HelloWorld",
    "ruby"
  ]
}

action "1_HelloWorld" {
  uses = "actions/aws/cli@8d31870"
  runs = [ "printf", "HelloWorld" ]
}

action "0_Shell" {
  uses = "actions/bin/sh@master"
  args = ["ls -ltr"]
}

action "nginx" {
  needs = "0_Shell"
  uses  = "docker://nginx:latest"
  runs  = "nginx -t"
}

action "ruby" {
  needs = "nginx"
  uses  = "docker://ruby:latest"
  runs  = "ruby -v"
}