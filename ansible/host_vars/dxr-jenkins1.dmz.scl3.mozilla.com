---
user_pw_file: /root/jenkins_user_pw
jenkins_prefix: jenkins
jenkins_jar_location: /data/jenkins-cli.jar
# need to change this manually for each [new] jenkins master:
jenkins_cred_id: d94c0f16-40f1-452d-b398-0abcc04cc587
# should match jenkins-slave:
jenkins_dir: /data/jenkins
