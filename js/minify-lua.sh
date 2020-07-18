#/bin/bash
printf 'return String.raw`'
luamin -f jisho.lua | sed '1,/{}/ s/{}/{${terms}}/' | sed '1,/{}/ s/{}/{${defs}}/' | tr -d '\n'
printf '`\n'


# term insertion is at f={}, definition insertion is at G={}
