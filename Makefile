QUIET := &>/dev/null

# Ensures we have all required dependencies
deps:
	@echo Ensuring dependencies are up to date
	@which dep $(QUIET) || go get -u github.com/golang/dep/cmd/dep
	@which packr $(QUIET) || go get -u github.com/gobuffalo/packr/...
	@which goreleaser $(QUIET) || go get github.com/goreleaser/goreleaser
	@dep ensure

# Builds the go binary
build: deps
	packr build

# Installs binary as 'exo' which is what it gets distributed as
install: deps
	@echo Building UI
	@cd ui && yarn run build
	packr build -o $(GOPATH)/bin/exo
	@echo 'exo' successfully installed
	@echo
	@exo

bootstrap: install
	@echo Creating new example wiki for you
	@mkdir ../example-wiki && cd ../example-wiki && exo init && git init && git init && git add -A && git commit -m "First Commit"
	@cd ../example-wiki && exo start . & 
	@open http://localhost:1234

release:
	@echo "--> Releasing"
	@goreleaser -p 1 --rm-dist -config .goreleaser.yml 
	@echo "--> Complete"

# Tests the packages
test: 
	@go test ./...

.PHONY: build deps install test bootstrap release
