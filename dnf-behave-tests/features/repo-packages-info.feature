Feature: repository-packages info

Scenario: List info of all packages from repository
Given I use the repository "dnf-ci-fedora"
 When I execute dnf with args "install filesystem"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                                  |
      | install       | filesystem-0:3.9-2.fc29.x86_64           |
      | install       | setup-0:2.12.1-1.fc29.noarch             |
 When I execute dnf with args "repository-packages dnf-ci-fedora info all"
 Then the exit code is 0
 Then stdout contains "Source\s+:\s+glibc-2.28-9.fc29.src.rpm"
 Then stdout contains "Available Packages"
 Then stdout contains "Installed Packages"
 Then stdout contains "Name\s+:\s+wget"
 Then stdout contains "Version\s+:\s+1.19.5"
 Then stdout contains "Architecture\s+:\s+src"
 Then stdout contains "Size\s+:\s+6.6 k"
 Then stdout contains "Source\s+:\s+None"
 Then stdout contains "Repository\s+:\s+dnf-ci-fedora"
 Then stdout contains "Summary\s+:\s+A utility for retrieving files using the HTTP or FTP protocols"
 Then stdout contains "URL\s+:\s+http://www.gnu.org/software/wget/"
 Then stdout contains "License\s+:\s+GPLv3+"
 Then stdout contains "Description\s+:\s+[a-zA-Z ]*"


Scenario: List all installed packages from repository
Given I use the repository "dnf-ci-fedora"
 When I execute dnf with args "install setup"
 Then the exit code is 0
 When I execute dnf with args "repository-packages dnf-ci-fedora info installed"
 Then the exit code is 0
 Then stdout contains "Installed Packages"
 Then stdout contains "Source\s+:\s+setup-2.12.1-1.fc29.src.rpm"
 Then stdout does not contain "Source\s+:\s+glibc-2.28-9.fc29.src.rpm"


Scenario: Single repository package info
Given I use the repository "dnf-ci-fedora"
 When I execute dnf with args "install setup"
 Then the exit code is 0
 When I execute dnf with args "repository-packages dnf-ci-fedora info setup"
 Then the exit code is 0
 Then stdout contains "Installed Packages"
 Then stdout contains "Source\s+:\s+setup-2.12.1-1.fc29.src.rpm"
 Then stdout does not contain "Source\s+:\s+glibc-2.28-9.fc29.src.rpm"


Scenario Outline: List repo <extras alias> - installed from repo, but not available anymore
# use temporary copy of repository dnf-ci-fedora for this test
Given I copy directory "{context.dnf.repos_location}/dnf-ci-fedora" to "/temp-repos/temp-repo"
  And I create and substitute file "/etc/yum.repos.d/test.repo" with
  """
  [testrepo]
  name=testrepo
  baseurl={context.dnf.installroot}/temp-repos/temp-repo
  enabled=1
  gpgcheck=0
  """
  And I do not set reposdir
  And I use the repository "testrepo"
 When I execute dnf with args "install setup"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                                  |
      | install       | setup-0:2.12.1-1.fc29.noarch             |
Given I delete file "/temp-repos/temp-repo/noarch/setup-2.12.1-1.fc29.noarch.rpm"
 Then the exit code is 0
Given I delete file "/temp-repos/temp-repo/src/setup-2.12.1-1.fc29.src.rpm"
 Then the exit code is 0
  And I execute bash with args "createrepo_c --update ." in directory "{context.dnf.installroot}/temp-repos/temp-repo"
 Then the exit code is 0
 When I execute dnf with args "clean expire-cache"
 Then the exit code is 0
 When I execute dnf with args "repository-packages testrepo info <extras alias>"
 Then the exit code is 0
 Then stdout contains "testrepo"
 Then stdout contains "Extra Packages"
 Then stdout contains "Source\s+:\s+setup-2.12.1-1.fc29.src.rpm"
 Then stdout does not contain "Source\s+:\s+glibc-2.28-9.fc29.src.rpm"
 Then stdout does not contain "basesystem"
 Then stdout does not contain "Available Packages"
 Then stdout does not contain "Installed Packages"

Examples:
    | extras alias   |
    | extras         |
    | --extras       |

