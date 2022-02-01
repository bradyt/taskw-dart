run:
	docker build .. -t this \
	-f Dockerfile && \
	docker run --rm \
	-it \
	this

local:
	docker build -t bradyt/dart-task .. \
	-f Dockerfile

push: local
	docker push bradyt/dart-task
