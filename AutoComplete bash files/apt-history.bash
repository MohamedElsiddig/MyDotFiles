_apt_history_completions()
{

   if [ "${#COMP_WORDS[@]}" != "2" ]; then
      return
   fi
    COMPREPLY=($(compgen -W "install upgrade remove rollback" "${COMP_WORDS[1]}"))
}

 complete -F _apt_history_completions apt-history
