#! /bin/sh
grep -E '^\s*(bindsym|bindcode)' ~/.config/sway/config | \
   sed -e 's;\$mod;Win;g'  -e 's;^ \+;;' -e 's;bindsym ;;' -e 's;bindcode ;;' \
      -e 's;--locked ;;' -e 's;\$left;<-;g' -e 's;\$right;->;g'  -e 's;\$up;^;g' -e 's;\$down;v;g' | \
   sed 's;\([^ ]\+\) \(.*$\);\1 :: \2;'
echo "" 
echo "(use Win+c to close this window)" 

