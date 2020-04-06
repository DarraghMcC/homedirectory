# CLI prompt bar info
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

if [ -f $(brew --prefix)/etc/bash_completion ]; then 
. $(brew --prefix)/etc/bash_completion
fi

source <(kubectl completion bash)
KUBE_PS1_SYMBOL_COLOR=green
KUBE_PS1_CTX_COLOR=green
KUBE_PS1_NS_COLOR=magenta
KUBE_PS1_BG_COLOR=''
KUBE_PS1_SYMBOL="⎈"
source /usr/local/opt/kube-ps1/share/kube-ps1.sh
PS1='[\u@\h] [\w] [$(parse_git_branch)] $(kube_ps1)\n'
PS1+='  |--> '
export PS1

# generic util commands
alias ls='ls -G'
alias ll='ls -l -G'
alias vi='vim'
alias grep='grep --color=auto'

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

####### WORK SPECIFIC COMMANDS #####
alias dbconnect='ssh -i ~/.ssh/gpu -N -L 3309:$(aws rds describe-db-clusters --query DBClusters[0].Endpoint --output text):3306 darragh@$(aws ec2 describe-instances --filters "Name=tag-value,Values=bastion" "Name=instance-state-code,Values=16" --query "Reservations[0].Instances[0].PublicDnsName" --output text)'
alias dbread='ssh -i ~/.ssh/gpu -N -L 3309:$(aws rds describe-db-clusters --query DBClusters[0].ReaderEndpoint --output text):3306 darragh@$(aws ec2 describe-instances --filters "Name=tag-value,Values=bastion" "Name=instance-state-code,Values=16" --query "Reservations[0].Instances[0].PublicDnsName" --output text)'
alias bastion='ssh -i ~/.ssh/gpu darragh@$(aws ec2 describe-instances --filters "Name=tag-value,Values=bastion" "Name=instance-state-code,Values=16" --query "Reservations[0].Instances[0].PublicDnsName" --output text)'
alias terraform='aws-vault exec terraformer -- terraform' #needed to allow role hopping with MFA

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