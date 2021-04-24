#!/usr/bin/env zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title genpass-xkcd
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🔐

# Documentation:
# @raycast.author Logan Linn
# @raycast.authorURL https://github.com/loganlinn

genpass-xkcd () {
	emulate -L zsh -o no_unset -o warn_create_global -o warn_nested_var -o extended_glob
	if [[ ARGC -gt 1 || ${1-1} != ${~:-<1-$((16#7FFFFFFF))>} ]]
	then
		print -ru2 -- "usage: $0 [NUM]"
		return 1
	fi
	zmodload zsh/system zsh/mathfunc || return
	local -r dict=/usr/share/dict/words 
	if [[ ! -e $dict ]]
	then
		print -ru2 -- "$0: file not found: $dict"
		return 1
	fi
	local -a words
	words=(${(M)${(f)"$(<$dict)"}:#[a-zA-Z](#c1,6)})  || return
	if (( $#words < 2 ))
	then
		print -ru2 -- "$0: not enough suitable words in $dict"
		return 1
	fi
	if (( $#words > 16#7FFFFFFF ))
	then
		print -ru2 -- "$0: too many words in $dict"
		return 1
	fi
	local -i n=$((ceil(128. / (log($#words) / log(2))))) 
	{
		local c
		repeat ${1-1}
		do
			print -rn -- $n
			repeat $n
			do
				while true
				do
					local -i rnd=0 
					repeat 4
					do
						sysread -s1 c || return
						(( rnd = (~(1 << 23) & rnd) << 8 | #c ))
					done
					(( rnd < 16#7FFFFFFF / $#words * $#words )) || continue
					print -rn -- -$words[rnd%$#words+1]
					break
				done
			done
			print
		done
	} < /dev/urandom
}


genpass-xkcd | tee >(pbcopy)
