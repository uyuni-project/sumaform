buildRepo-needForTests:
  file.managed:
    - name: /etc/zypp/repos.d/Devel_Galaxy_BuildRepo.repo
    - source: salt://test-client/repos.d/Devel_Galaxy_BuildRepo.repo
    - template: jinja

# HACK: this repo should be removed, but we need this packages then in non-updates repos:
# "openscap-content", "openscap-extra-probes", "openscap-utils"
suse-manager-update-repo:
  file.managed:
    - name: /etc/zypp/repos.d/SUSE-Manager-3.0-x86_64-Update.repo
    - source: salt://suse-manager/repos.d/SUSE-Manager-3.0-x86_64-Update.repo
    - template: jinja

refresh-test-client-repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
