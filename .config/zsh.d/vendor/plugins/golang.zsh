#!/usr/bin/env zsh
#
# Vendored from oh-my-zsh @ ff1df9a0399d56b9f6e957bb62a2d4ba6bc0ef4c
# Upstream: plugins/golang/golang.plugin.zsh
# Local changes: none
#
# DO NOT EDIT BY HAND -- see .config/zsh.d/vendor/VENDOR.md

## completion
compctl -g "*.go" gofmt # standard go tools
compctl -g "*.go" gccgo # gccgo

# gc
for p in 5 6 8; do
  compctl -g "*.${p}" ${p}l
  compctl -g "*.go" ${p}g
done
unset p

## aliases
alias gob='go build'
alias goc='go clean'
alias god='go doc'
alias goe='go env'
alias gof='go fmt'
alias gofa='go fmt ./...'
alias gofx='go fix'
alias gog='go get'
alias goga='go get ./...'
alias goi='go install'
alias gol='go list'
alias gom='go mod'
alias gomt='go mod tidy'
alias gopa='cd $GOPATH'
alias gopb='cd $GOPATH/bin'
alias gops='cd $GOPATH/src'
alias gor='go run'
alias got='go test'
alias gota='go test ./...'
alias goto='go tool'
alias gotoc='go tool compile'
alias gotod='go tool dist'
alias gotofx='go tool fix'
alias gov='go vet'
alias gove='go version'
alias gow='go work'
