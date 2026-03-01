# WORKAROUND: see github:saltstack/salt#10852
{{ sls }}_nop:
  test.nop: []