Jenkins-Makespec
================

This is a perl script that will create a properly-formatted SPEC file for use in RPM Building


Assumptions:
- Changelog is stored within the CMS root.
- All files "built" are to be deployed from the "install root"; works well for web apps, not so much for wide-spread apps.
- Resulting RPM is of type "noarch"; works for web apps and other non-compiled apps.


Arguments are passed as standard short *nix command-line flags and are
automatically populated into the %opts hash

$opts{'c'} = Changelog name (FORMAT MUST BE CORRECT! SEE RPM DOCUMENTATION)
$opts{'d'} = project directory install root
$opts{'D'} = project description
$opts{'l'} = license type (default "GPLv3")
$opts{'p'} = project name (default "$ENV{'JOB_NAME'}")
$opts{'s'} = project summary text (default "Project Summary")
$opts{'u'} = project files owner (default "root")
$opts{'w'} = project directory owner (default "root")
$opts{'v'} = major version
