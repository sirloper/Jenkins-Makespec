#!/usr/bin/perl -w
# Changelog
# * Mon Jun 24 2013 Mark Cartwright <sirloper@gmail.com> 1.1.2 Bug fix: project directory placeholder in template was too short to handle most paths.
# * Mon Jun 24 2013 Mark Cartwright <sirloper@gmail.com> 1.1.1 Completed in-code documentation
# * Fri Jun 21 2013 Mark Cartwright <sirloper@gmail.com> 1.1 Updated project to be more generic using CL options
# * Wed Jun 19 2013 Mark Cartwright <sirloper@gmail.com> 1.0 Initial Version

# User-configurable to match your envionrment:
my $RPM_BUILD_ROOT = '/data/rpmbuild'; # NO TRAILING SLASH!!

# BEGIN
use strict;
use Getopt::Std;
use File::Basename;
my(%opts, $project_changelog); # Define placeholders
my @parsed = fileparse( $0 );

# Assumptions:
# - Changelog is stored within the CMS root.
# - All files "built" are to be deployed from the "install root"; works well for web apps, not so much for wide-spread apps.
# - Resulting RPM is of type "noarch"; works for web apps and other non-compiled apps.

#
# Arguments are passed as standard short *nix command-line flags and are
# automatically populated into the %opts hash
#
# $opts{'c'} = Changelog name (FORMAT MUST BE CORRECT! SEE RPM DOCUMENTATION)
# $opts{'d'} = project directory install root
# $opts{'D'} = project description
# $opts{'l'} = license type (default "GPLv3")
# $opts{'p'} = project name (default "$ENV{'JOB_NAME'}")
# $opts{'s'} = project summary text (default "Project Summary")
# $opts{'u'} = project files owner (default "root")
# $opts{'w'} = project directory owner (default "root")
# $opts{'v'} = major version
#
# list of options. If they're not here, they are not valid.  
# Options with ':' require an option.
getopts( 'c:D:d:l:p:s:p:u:w:v:', \%opts );

# Variables that need to be set OR passed via Jenkins 
# (note that thr %{/VAR/i} variables are RPM Macros, not Jenkins or %ENV):
my $project_name = $opts{'p'} || $ENV{'JOB_NAME'};
my $project_summary = $opts{'s'} || "Project Summary";
my $project_version = $opts{'v'};
my $project_release = '%{?BUILD_NUMBER}';
my $project_group = 'Application/Files';
my $project_specfile = "$ENV{'JOB_NAME'}.$ENV{'BUILD_NUMBER'}.spec";
my $project_license = $opts{'l'} || 'GPLv3';
my $project_u_owner = $opts{'u'} || 'root';
my $project_d_owner = $opts{'w'} || 'root';
my $project_description = $opts{'D'} || 'Project Description';

my $project_install = <<END;
mkdir -p %{buildroot}$opts{'d'}
cp -Rpf $ENV{'WORKSPACE'}/* %{buildroot}$opts{'d'}
find $ENV{'WORKSPACE'}/ -name .htaccess -exec cp {} %{buildroot}$opts{'d'} \;

install -d -m 755 %{buildroot}
END

if ($opts{'c'}) {
	# Changelog has been defined, read it if you can...
	open(CHANGELOG, "<", $opts{'c'}) or warn("Could not open changelog ($opts{'c'}) for reading.  This will not cause a build failure but the changelog will not be present in the resulting RPM: $!\n");
	$project_changelog = <CHANGELOG>;
	close(CHANGELOG);
}

open ( SPECFILE, ">", "$RPM_BUILD_ROOT/$ENV{'JOB_NAME'}/SPECS/$project_specfile" ) or die( "Cannot open spec file ($RPM_BUILD_ROOT/$ENV{'JOB_NAME'}/SPECS/$project_specfile) for writing: $!\n" );

format SPECFILE =
Name:		@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$project_name
Summary:	@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$project_summary
Version:	@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$project_version
Release:	@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$ENV{'BUILD_NUMBER'}

Group:		@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$project_group
License:	@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$project_license

BuildArch:	noarch
Buildroot:	%(mktemp -ud $RPM_BUILD_ROOT/\%{name}-%{version}-%{release}-XXXX)

%description
@*
$project_description


%prep

%build

%install
@*
$project_install

%clean
rm -rf %{buildroot}

%files
%defattr(644,@<<<<<<<<<<,@<<<<<<<<<,755)
$project_u_owner, $project_d_owner
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$opts{'d'}

%changelog
@*
$project_changelog
.

write SPECFILE;

#
# Subs
#

sub VERSION_MESSAGE {
	print "$parsed[0] v1.0\n";
	print <<EOH;
	$parsed[0]
	-c <Changelog name> (FORMAT MUST BE CORRECT! SEE RPM DOCUMENTATION)
	-d <project directory installed root>
	-D <project description>
	-p <project name (default \"\$ENV\{\'JOB_NAME\'\}\")
	-v <major version>
	-s <project summary text>
	-l <license type> (default "GPLv3")
	-u <project files owner> (default "root")
	-w <project directory owner> (default "root")
	--version = This message.
	--help = This message.
EOH
	exit( 0 );
}