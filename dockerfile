version: '3'

networks:
  atlassian:
    driver: overlay
    driver_opts:
      encrypted: "true"

volumes:
  jira-home:
    labels:
      app: "jira"
      path: "/var/atlassian/jira"
      
  jira-logs:
    labels:
      app: "jira"
      path: "/opt/atlassian/jira/logs"
      
  confluence-home:
    labels:
      app: "confluence"
      path: "/var/atlassian/confluence"
      
  confluence-logs:
    labels:
      app: "confluence"
      path: "/opt/atlassian/confluence/logs"
  
  mysql-jira:
    labels:
      app: "jira"
      path: "/var/lib/mysql"

  mysql-confluence:
    labels:
      app: "confluence"
      path: "/var/lib/mysql"

services:
  jira:
    labels:
      app: "jira"
    image: de-mucd3jira:5000/capgemini-jira:7.3.7.2
    depends_on:
     - mysql-jira
    networks:
     - atlassian
    ports:
     - "8082:8080"
    volumes:
     - jira-home:/var/atlassian/jira
     - jira-logs:/opt/atlassian/jira/logs
    environment:
      X_PROXY_NAME: "staging.d3.ce.capgemini.com"
      X_PROXY_PORT: "443"
      X_PROXY_SCHEME: "https"
      X_PATH: "/jira"
      CATALINA_OPTS: " -Xms4096m -Xmx4096m -Datlassian.mail.senddisabled=true -Datlassian.mail.fetchdisabled=true -Datlassian.mail.popdisabled=true"
    extra_hosts:
      - "staging.d3.ce.capgemini.com:10.40.253.25"
      - "atc.bmwgroup.net:160.48.106.12"
    deploy:
      mode: global
      placement:
        constraints:
         - node.labels.app == jira
      restart_policy:
        condition: on-failure
        max_attempts: 1
      resources:
        limits:
          cpus: '2.0'
    stop_grace_period: 1m
      
  confluence:
    labels:
      app: "confluence"
    image: de-mucd3jira:5000/capgemini-confluence:6.1.3.4
    depends_on:
     - mysql-confluence
    networks:
     - atlassian
    ports:
     - "8093:8090"
    volumes:
     - confluence-home:/var/atlassian/confluence
     - confluence-logs:/opt/atlassian/confluence/logs
    environment:
      X_PROXY_NAME: "staging.d3.ce.capgemini.com"
      X_PROXY_PORT: "443"
      X_PROXY_SCHEME: "https"
      X_PATH: "/confluence"
      CATALINA_OPTS: " -Xms4096m -Xmx4096m -Datlassian.mail.senddisabled=true -Datlassian.mail.fetchdisabled=true -Dsynchrony.proxy.enabled=true -Dsynchrony.proxy.healthcheck.disabled=true -Dconfluence.upgrade.recovery.file.enabled=false"
    extra_hosts:
      - "staging.d3.ce.capgemini.com:10.40.253.25"
    deploy:
      mode: global
      placement:
        constraints:
         - node.labels.app == confluence
      restart_policy:
        condition: on-failure
        max_attempts: 1
      resources:
        limits:
          cpus: '2.0'
    stop_grace_period: 1m
  
  mysql-jira:
    labels:
      app: "jira"
    image: de-mucd3jira:5000/capgemini-mysql:5.6
    networks:
     - atlassian
    volumes:
     - mysql-jira:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: A78c47vv83r
      MYSQL_USER: jira
      MYSQL_PASSWORD: jira
      MYSQL_DATABASE: jira
    deploy:
      mode: global
      placement:
        constraints:
         - node.labels.app == jira
      restart_policy:
        condition: on-failure
        max_attempts: 1
    stop_grace_period: 1m
    
  mysql-confluence:
    labels:
      app: "confluence"
    image: de-mucd3jira:5000/capgemini-mysql:5.6
    networks:
     - atlassian
    volumes:
     - mysql-confluence:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: A78c47vv83r
      MYSQL_USER: confluence
      MYSQL_PASSWORD: confluence
      MYSQL_DATABASE: confluence
    deploy:
      mode: global
      placement:
        constraints:
         - node.labels.app == confluence
      restart_policy:
        condition: on-failure
        max_attempts: 1
    stop_grace_period: 1m      
    
