Jenkins-Makespec
================

This is a perl script that will create a properly-formatted SPEC file for use in RPM Building


Assumptions:
- Changelog is stored within the CMS root.
- All files "built" are to be deployed from the "install root"; works well for web apps, not so much for wide-spread apps.
- Resulting RPM is of type "noarch"; works for web apps and other non-compiled apps.


Arguments are passed as standard short *nix command-line flags and are automatically populated into the %opts hash

$opts{'c'} = Changelog name (FORMAT MUST BE CORRECT! SEE RPM DOCUMENTATION)

$opts{'d'} = project directory install root

$opts{'D'} = project description

$opts{'l'} = license type (default "GPLv3")

$opts{'p'} = project name (default "$ENV{'JOB_NAME'}")

$opts{'s'} = project summary text (default "Project Summary")

$opts{'u'} = project files owner (default "root")

$opts{'w'} = project directory owner (default "root")

$opts{'v'} = major version

Jenkins Integration
-------------------

I use this in the BUILD section of jenkins by executing a shell like so:

    # Clean up and create directories
    id
    for dir in BUILD RPMS SOURCES SPECS SRPMS
    do
     [[ -d /data/rpmbuild/${JOB_NAME}/$dir ]] && rm -Rf /data/rpmbuild/${JOB_NAME}/$dir
      mkdir -p /data/rpmbuild/${JOB_NAME}/$dir
    done
    /data/rpmbuild/makespec.pl -p ${JOB_NAME} -v 1.0 -d '/var/www/html/sparkenergy' -s ${JOB_NAME}.spec -m "Spark Energy Web Code"
    rpmbuild --define '_topdir '/data/rpmbuild/${JOB_NAME} -bb /data/rpmbuild/${JOB_NAME}/SPECS/${JOB_NAME}.${BUILD_NUMBER}.spec
    #... Additional build steps, such as publish to Artifactory, push to yum repo and rebuild yum database
    
Where '/data/rpmbuild' matches the value of $RPM_BUILD_ROOT defined within the script.
