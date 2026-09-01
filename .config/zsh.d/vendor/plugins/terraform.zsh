#!/usr/bin/env zsh
#
# Vendored from oh-my-zsh @ ff1df9a0399d56b9f6e957bb62a2d4ba6bc0ef4c
# Upstream: plugins/terraform/terraform.plugin.zsh
# Local changes: none
#
# DO NOT EDIT BY HAND -- see .config/zsh.d/vendor/VENDOR.md

function tf_prompt_info() {
  # dont show 'default' workspace in home dir
  [[ "$PWD" != ~ ]] || return
  # check if in terraform dir and file exists
  [[ -d "${TF_DATA_DIR:-.terraform}" && -r "${TF_DATA_DIR:-.terraform}/environment" ]] || return

  local workspace="$(<"${TF_DATA_DIR:-.terraform}/environment")"
  echo "${ZSH_THEME_TF_PROMPT_PREFIX-[}${workspace:gs/%/%%}${ZSH_THEME_TF_PROMPT_SUFFIX-]}"
}

function tf_version_prompt_info() {
  local terraform_version
  terraform_version=$(terraform --version | head -n 1 | cut -d ' ' -f 2)
  echo "${ZSH_THEME_TF_VERSION_PROMPT_PREFIX-[}${terraform_version:gs/%/%%}${ZSH_THEME_TF_VERSION_PROMPT_SUFFIX-]}"
}

alias tf='terraform'
alias tfa='terraform apply'
alias tfa!='terraform apply -auto-approve'
alias tfap='terraform apply -parallelism=1'
alias tfapp='terraform apply tfplan'
alias tfc='terraform console'
alias tfd='terraform destroy'
alias tfd!='terraform destroy -auto-approve'
alias tfdp='terraform destroy -parallelism=1'
alias tff='terraform fmt'
alias tffr='terraform fmt -recursive'
alias tfi='terraform init'
alias tfir='terraform init -reconfigure'
alias tfiu='terraform init -upgrade'
alias tfiur='terraform init -upgrade -reconfigure'
alias tfo='terraform output'
alias tfp='terraform plan'
alias tfpo='terraform plan -out tfplan'
alias tfv='terraform validate'
alias tfs='terraform state'
alias tft='terraform test'
alias tfsh='terraform show'
alias tfw='terraform workspace'
alias tfwl='terraform workspace list'
alias tfws='terraform workspace select'
