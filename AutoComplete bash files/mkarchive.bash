#/usr/bin/env bash
_mkarchive_completions()
{ 
   if [ "${#COMP_WORDS[@]}" != "2" ]; then
      return
   fi

   COMPREPLY=($(compgen  -W "bz2 tgz tar zip" "${COMP_WORDS[1]}")) 
   
}

complete  -o dirnames  -F _mkarchive_completions mkarchive


