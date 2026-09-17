#! /usr/bin/awk

BEGIN {
   insideForwDecls = 0
   result = 0
}

insideForwDecls == 0 && $0 ~ /\/\/{{{@@/ {
   insideForwDecls = 1
}

insideForwDecls == 0 && $0 !~ /^\s*$/ && $0 !~ /^\s*\/\// && $0 !~ /^\s*\*/ && $0 !~ /^\s*\/\*/ {
   result++
}

insideForwDecls == 1 && $0 ~ /\/\/}}}/ {
   insideForwDecls = 1
}

END {
   printf "%d\n", result
}
