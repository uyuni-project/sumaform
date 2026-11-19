#!/bin/sh
# Warns when a package offered by the repo given as $1 is not the one zypper
# would install. It only prints, it never fails.

export LC_ALL=C
repo="$1"

offered=$(zypper --non-interactive --quiet search -s -t package -r "$repo" 2>/dev/null |
  awk -F'|' '$3 ~ /package/ { gsub(/ /, "", $2); gsub(/ /, "", $4); print $2, $4 }' |
  sort -k1,1 -k2,2V |
  awk '{ version[$1] = $2 } END { for (name in version) print name, version[name] }')

[ -n "$offered" ] || exit 0

# zypper info reports the candidate zypper would install, priorities included
zypper --non-interactive info $(echo "$offered" | cut -d' ' -f1) 2>/dev/null |
  OFFERED="$offered" REPO="$repo" awk '
    BEGIN {
      count = split(ENVIRON["OFFERED"], lines, "\n")
      for (i = 1; i <= count; i++) {
        split(lines[i], fields, " ")
        offered[fields[1]] = fields[2]
      }
    }
    /^Repository +:/ { sub(/^[^:]*: */, ""); source = $0 }
    /^Name +:/       { sub(/^[^:]*: */, ""); name = $0 }
    /^Version +:/ {
      sub(/^[^:]*: */, "")
      if ((name in offered) && source != ENVIRON["REPO"] && $0 != offered[name]) {
        printf "WARNING: %s offers %s %s, but zypper will install %s from %s\n", ENVIRON["REPO"], name, offered[name], $0, source
      }
    }'

exit 0
