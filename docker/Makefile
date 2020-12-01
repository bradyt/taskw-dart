run:
	docker build . -t this && \
	docker run --rm \
	-it \
	-p 53589:53589 \
	--mount type=bind,source="`dirname \`pwd\``/fixture",dst=/opt/fixture \
	this

bash:
	docker build . -t this && \
	docker run --rm \
	-it \
	-p 53589:53589 \
	--mount type=bind,source="`dirname \`pwd\``/fixture",dst=/opt/fixture \
	this bash
