FROM bradyt/dart-task

EXPOSE 53589

COPY entrypoint.sh /bin/

ENTRYPOINT ["/bin/entrypoint.sh"]
CMD taskd server --data /opt/fixture/var/taskd --debug
