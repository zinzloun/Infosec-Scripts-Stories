# Some scripts to abuse DevOps pipe
- download_gitlab_projects.py: Download all projects content from a Gitlab server, according to the token access permission
- jenkins: abuse On-Merge builds misconfiguration
  - rev_shell.sh: Remote reverse shell script to be served from the attacker, through HTTP (e.g python -m http.server)
  - Jenkinsfile: configuration file hosted on the GitLab CI/CD pipe
 - jenkins/rs.groovy: Groovy script reverse shell
