http_proxy:
   cmd.run:
       - name: /usr/bin/podman run -d -p 3128:3128 --restart always --name http_proxy registry.opensuse.org/systemsmanagement/uyuni/master/docker/containers/proxy
       - unless: podman ps -a --filter "name=http_proxy" --format json|grep '"Id"'
       - runas: podman
       - requires:
           - sls: jenkins.podman
   cron.present:
       - name: /usr/bin/podman start http_proxy
       - user: podman
       - special: '@reboot'
