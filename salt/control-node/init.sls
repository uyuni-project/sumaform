Init-control-node:
  cmd.run:
    - name: |
        zypper addrepo http://download.suse.de/ibs/Devel:/Galaxy:/ruby:/test/SLE_12/Devel:Galaxy:ruby:test.repo
        zypper addrepo http://download.suse.de/ibs/SUSE:/SLE-12:/Update/standard/SUSE:SLE-12:Update.repo
        zypper -n --gpg-auto-import-keys ref
        zypper -n in phantomjs 
