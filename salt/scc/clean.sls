clean_sles_release_package:
   cmd.run:
     - name: rpm -e --nodeps sles-release; exit 0

clean_suseconnect_registration :
   cmd.run:
     - name: SUSEConnect --cleanup
