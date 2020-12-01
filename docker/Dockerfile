FROM bradyt/dart-task

EXPOSE 53589

COPY entrypoint.sh /bin/

ENTRYPOINT ["/bin/entrypoint.sh"]
CMD taskd server --data $TASKDDATA --debug
