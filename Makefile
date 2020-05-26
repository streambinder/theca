ROOT_DIR	:= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
MAKE_DIR	:= $(ROOT_DIR)/.make
BUILD_DIR	:= $(ROOT_DIR)/build

export BUILD_DIR

.PHONY: packages
packages: init update
	@python3 $(MAKE_DIR)/packages.py

.PHONY: init
init:
	@mkdir -p $(BUILD_DIR)

.PHONY: test
test:
	@python3 $(MAKE_DIR)/test.py

.PHONY: update
update:
	@sudo solbuild update

.PHONY: components
components: init
	@bash $(MAKE_DIR)/components.sh

.PHONY: strip
strip:
	@python3 $(MAKE_DIR)/strip.py

.PHONY: index
index:
	@(cd $(BUILD_DIR) && sudo solbuild index > /dev/null 2>&1)

.PHONY: release
release: packages strip index components

.PHONY: fetch
fetch: init
	@bash $(MAKE_DIR)/fetch.sh

.PHONY: index-table
index-table:
	@python3 $(MAKE_DIR)/index-table.py

.PHONY: sync
sync:
	@bash $(MAKE_DIR)/sync.sh

.PHONY: clean
clean:
	@rm -rf $(BUILD_DIR)