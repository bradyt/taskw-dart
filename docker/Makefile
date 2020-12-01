run: home
	docker build . -t this && \
	docker run --rm \
	-it \
	-p 53589:53589 \
	--mount type=bind,source="`dirname \`pwd\``/root",dst=/opt/root \
	this

home:
	mkdir home

stop:
	docker stop `docker ps -q`
