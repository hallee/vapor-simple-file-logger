workflow "Lint" {
  on = "pull_request"
  resolves = ["swiftlint"]
}

action "swiftlint" {
  uses = "norio-nomura/action-swiftlint@master"
  secrets = ["GITHUB_TOKEN"]
}
