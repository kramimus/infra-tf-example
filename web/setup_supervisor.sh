#!/bin/bash

CMD=$1

cp /opt/web/supervisord /etc/rc.d/init.d/
chmod +x /etc/rc.d/init.d/supervisord

cat << EOF >> /etc/supervisord.conf
[unix_http_server]
file=/tmp/supervisor.sock   ; the path to the socket file


[supervisord]
logfile=/tmp/supervisord.log ; main log file; default $CWD/supervisord.log
logfile_maxbytes=50MB        ; max main logfile bytes b4 rotation; default 50MB
logfile_backups=10           ; # of main logfile backups; 0 means none, default 10
loglevel=info                ; log level; default info; others: debug,warn,trace
pidfile=/tmp/supervisord.pid ; supervisord pidfile; default supervisord.pid
nodaemon=false               ; start in foreground if true; default false
minfds=1024                  ; min. avail startup file descriptors; default 1024
minprocs=200                 ; min. avail process descriptors;default 200
user=ec2-user


[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface


[supervisorctl]
serverurl=unix:///tmp/supervisor.sock ; use a unix:// URL  for a unix socket

[program:web]
command=python $CMD
EOF

chkconfig --add supervisord
chkconfig supervisord on
