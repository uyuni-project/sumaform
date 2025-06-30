mkdir -p /srv/www/htdocs/pub/TestRepoRpmUpdates
mkdir -p /srv/www/htdocs/pub/TestRepoAppStream

# Move RPM directories
find "/srv/www/htdocs/pub/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Updates/rpm/" -mindepth 1 -maxdepth 1 -type d -exec mv {} /srv/www/htdocs/pub/TestRepoRpmUpdates/ \;

# Move AppStream directories
find "/srv/www/htdocs/pub/repositories/systemsmanagement:/Uyuni:/Test-Packages:/Appstream/rhlike/" -mindepth 1 -maxdepth 1 -type d -exec mv {} /srv/www/htdocs/pub/TestRepoAppStream/ \;
