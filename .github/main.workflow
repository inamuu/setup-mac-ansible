workflow "Test workflow" {
  on = "push"
  resolves = [
    "1_HelloWorld",
    "nginx"
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
  needs = "Shell"
  uses  = "docker://nginx:latest"
  runs  = "nginx -t"
}