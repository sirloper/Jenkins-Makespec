Jenkins-Makespec
================

This is a perl script that will create a properly-formatted SPEC file for use in RPM Building

I wrote this with a Jenkins build in mind for web apps, but I have also used it for other
custom builds such as node.js without issue.  

I also check each RPM artifact as well as the resulting .spec file into Artifactory as a post-build step.  If there are 
issues with the build later that serves as a map to how the RPM was created, most specifically  with regard to package
listings -- the %files section of the rpm will contain no more than the "install root" directory and all files below
that level will be packaged.  This is fairly safe since each  BUILDROOT directory is unique per build (assuming defaults
are used and Jenkins increments the build number), which should avoid re-packaging older build files unintentionally.


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

I use this in the BUILD section of Jenkins/Hudson by executing a shell like so:

    # Clean up and create directories
    id
    for dir in BUILD RPMS SOURCES SPECS SRPMS
    do
     [[ -d /data/rpmbuild/${JOB_NAME}/$dir ]] && rm -Rf /data/rpmbuild/${JOB_NAME}/$dir
      mkdir -p /data/rpmbuild/${JOB_NAME}/$dir
    done
    /data/rpmbuild/makespec.pl -p ${JOB_NAME} -v 1.0 -d '/var/www/html/myproject' -s ${JOB_NAME}.spec -m "My Project Web Code"
    rpmbuild --define '_topdir '/data/rpmbuild/${JOB_NAME} -bb /data/rpmbuild/${JOB_NAME}/SPECS/${JOB_NAME}.${BUILD_NUMBER}.spec
    #... Additional build steps, such as publish to Artifactory, push to yum repo and rebuild yum database
    
Where '/data/rpmbuild' matches the value of $RPM_BUILD_ROOT defined within the script.
