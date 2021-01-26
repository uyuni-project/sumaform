# WORKAROUND for bsc#1181283
# We are including twice /etc/sudoers.d directory, one with @includedir and one with #includedir
# Thus, this workaround is adding an extra # to @includedir so that this line is treated as a comment
# and so ignored.

include:
  - default

/etc/sudoers:
  file.replace:
    - pattern: '^@includedir /etc/sudoers'
    - repl: '#@includedir /etc/sudoers'

