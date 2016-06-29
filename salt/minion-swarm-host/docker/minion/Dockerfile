FROM suse/sles12
MAINTAINER Duncan Mac-Vicar P. "dmacvicar@suse.com"

RUN zypper --non-interactive ar -f http://download.suse.de/ibs/SUSE:/SLE-12:/Update/standard/SUSE:SLE-12:Update.repo
RUN zypper --non-interactive ar -f http://download.suse.de/ibs/SUSE:/SLE-12:/GA/standard/SUSE:SLE-12:GA.repo
RUN zypper --non-interactive ar -f http://download.suse.de/ibs/Devel:/Galaxy:/Manager:/Head/SLE_12/Devel:Galaxy:Manager:Head.repo

RUN zypper \
   --gpg-auto-import-keys --non-interactive \
   install --no-recommends -- \
   salt-minion
RUN rm -f /etc/machine-id

VOLUME ["/etc/salt/minion.d/master.conf"]

CMD ["/usr/bin/salt-minion"]

