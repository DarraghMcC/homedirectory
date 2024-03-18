eval "$(/opt/homebrew/bin/brew shellenv)"

if [ -f $(brew --prefix)/etc/bash_completion ]; then 
. $(brew --prefix)/etc/bash_completion
fi

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

source <(kubectl completion bash)
KUBE_PS1_SYMBOL_COLOR=green
KUBE_PS1_CTX_COLOR=green
KUBE_PS1_NS_COLOR=magenta
KUBE_PS1_BG_COLOR=''
KUBE_PS1_SYMBOL="⎈"
source /opt/homebrew/opt/kube-ps1/share/kube-ps1.sh
PS1='[\u@\h] [\w] [$(parse_git_branch)] $(kube_ps1)\n'
PS1+='  |--> '
export PS1

# generic util commands
alias ls='ls -G'
alias ll='ls -l -G'
alias vi='vim'
alias grep='grep --color=auto'
alias refreshbash='. ~/.bash_profile'
alias golint='golangci-lint run -v --enable-all --disable gochecknoglobals --exclude G107 --disable gomnd'

# gradle specific build commands
alias gbuildclean='./gradlew clean --refresh-dependencies'
alias gbuild='./gradlew build'
alias gtest='./gradlew test'
alias gjac='./gradlew jacocoTestReport'
alias grad='./gradlew'

#git util commands
alias gcommit='git commit -a -m'
alias uncommit='git reset --soft HEAD~1'
alias squash='git commit -a -m "tmp";git rebase -i '

####### AWS COMMANDS #####
alias dbconnect='echo "Do not forget to use VPN"; ssh -o ConnectTimeout=1 -i ~/.ssh/gpu -N -L 3309:$(aws rds describe-db-clusters --query DBClusters[0].Endpoint --output text):3306 darragh@$(aws ec2 describe-instances --filters "Name=tag-value,Values=bastion" "Name=instance-state-code,Values=16" --query "Reservations[0].Instances[0].PublicDnsName" --output text);'
alias dbread='echo "Do not forget to use VPN"; ssh -o ConnectTimeout=1 -i ~/.ssh/gpu -N -L 3309:$(aws rds describe-db-clusters --query DBClusters[0].ReaderEndpoint --output text):3306 darragh@$(aws ec2 describe-instances --filters "Name=tag-value,Values=bastion" "Name=instance-state-code,Values=16" --query "Reservations[0].Instances[0].PublicDnsName" --output text);'
alias bastion='ssh -i ~/.ssh/gpu darragh@$(aws ec2 describe-instances --filters "Name=tag-value,Values=bastion" "Name=instance-state-code,Values=16" --query "Reservations[0].Instances[0].PublicDnsName" --output text)'
alias staging-terraform='aws-vault exec staging-terraformer -- terraform' #needed to allow role hopping with MFA
alias sandpit-terraform='aws-vault exec sandpit-developer -- terraform' #needed to allow role hopping with MFA

##### AWS PROFILE HOPPING #####
awsprof() {
    case "$1" in
        "")
            export AWS_PROFILE=""
            ;;
        *)
            export AWS_PROFILE="$1"
            ;;
    esac
 
    echo "AWS Profile: $AWS_PROFILE"
}
 
_awsprof_completions() {
    COMPREPLY=($(compgen -W "$( \
        grep '\[' ~/.aws/credentials \
        | tr -d '[]'
    )" "${COMP_WORDS[1]}"))
}
 
complete -F _awsprof_completions awsprof

####### SYSTEM SPECIFIC COMMANDS #####
if [ -f $HOME/.bash_profile_local ]; then
    . $HOME/.bash_profile_local
fi

####### WORK SPECIFIC COMMANDS #####
if [ -f $HOME/.bash_profile_work ]; then
    . $HOME/.bash_profile_work
fi

alias ovpn='networksetup -connectpppoeservice "Office vpn"'

export BASH_SILENCE_DEPRECATION_WARNING=1
