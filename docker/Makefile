run:
	docker build . -t this && \
	docker run --rm \
	-it \
	-p 53589:53589 \
	--mount type=bind,source="`dirname \`pwd\``/fixture",dst=/opt/fixture \
	--mount type=bind,source="`dirname \`pwd\``/taskc",dst=/opt/taskc \
	--mount type=bind,source="`dirname \`pwd\``/taskw",dst=/opt/taskw \
	--mount type=bind,source="`dirname \`pwd\``/task/assets",dst=/opt/assets \
	this

bash:
	docker build . -t this && \
	docker run --rm \
	-it \
	-p 53589:53589 \
	--mount type=bind,source="`dirname \`pwd\``/fixture",dst=/opt/fixture \
	--mount type=bind,source="`dirname \`pwd\``/taskc",dst=/opt/taskc \
	--mount type=bind,source="`dirname \`pwd\``/taskw",dst=/opt/taskw \
	--mount type=bind,source="`dirname \`pwd\``/task/assets",dst=/opt/assets \
	this bash
