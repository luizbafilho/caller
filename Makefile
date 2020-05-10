run:
	docker-compose up --build app

build:
	go build

test:
	docker-compose up --build test