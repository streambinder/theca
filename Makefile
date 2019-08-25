PKGR_NAME := $(shell awk -F'=' '/^Name/ {print $$2}' $(HOME)/.solus | xargs)
PKGR_EMAIL := $(shell awk -F'=' '/^Email/ {print $$2}' $(HOME)/.solus | xargs)
PKGS_BIN := bin

.PHONY: all
all: packages components

.PHONY: prepare
prepare:
	@ ( \
		mkdir -p $(PKGS_BIN) && \
		echo Updating solbuild images... && \
		sudo solbuild update > /dev/null 2>&1; \
	);

.PHONY: packages
packages: prepare
	@ ( \
		cd $(PKGS_BIN) && \
		for pkg_name in $$(grep -v ^# ../src/series); do \
			pkg="$$(find ../src -type d -name $${pkg_name})"; \
			if [ -z "$${pkg}" ]; then \
				echo "Package $$(tput bold)$${pkg_name}$$(tput sgr0) sources not found."; \
				continue; \
			fi; \
			pkg_version="$$(awk -F': ' '/^version/ {print $$2}' $${pkg}/package.yml)"; \
			pkg_release="$$(awk -F': ' '/^release/ {print $$2}' $${pkg}/package.yml)"; \
			if [ -f "$${pkg_name}-$${pkg_version}-$${pkg_release}-"*".eopkg" ]; then \
				echo "Package $$(tput bold)$${pkg_name}$$(tput sgr0) already in and updated."; \
			else \
				echo "Compiling $$(tput bold)$${pkg_name}$$(tput sgr0)..."; \
				sudo solbuild build "$${pkg}/package.yml" > /dev/null 2>&1 || \
				echo "$$(tput bold)Unable to build $${pkg_name}!$$(tput sgr0)"; \
			fi; \
		done; \
		rm -f *.xml; \
		echo Triggering index...; \
		sudo solbuild index > /dev/null 2>&1; \
		echo Finished.; \
	);

.PHONY: components
components: packages
	@ ( \
		cd $(PKGS_BIN) && \
		sudo chmod a+w eopkg-index.xml* && \
		sed -i '$$ d' eopkg-index.xml && \
		find ../src -maxdepth 1 -type d -name \*.\* -printf "%f\n" | while read comp; do \
			comp_group="$$(awk -F'.' '{print $$1}' <<< "$${comp}")"; \
			echo -e "\t<Component>\n\t\t<Name>$${comp}</Name>\n\t\t<Group>$${comp_group}</Group>\n\t\t<Maintainer>\n\t\t\t<Name>$(PKGR_NAME)</Name>\n\t\t\t<Email>$(PKGR_EMAIL)</Email>\n\t\t</Maintainer>\n\t</Component>" >> eopkg-index.xml; \
		done; \
		echo "</PISI>" >> eopkg-index.xml; \
		sha1sum eopkg-index.xml | awk '{print $$1}' > eopkg-index.xml.sha1sum && \
		xz -kf eopkg-index.xml && \
		sha1sum eopkg-index.xml.xz | awk '{print $$1}' > eopkg-index.xml.xz.sha1sum; \
	);

.PHONY: check
check:
	@ ( \
		find src -type f -name 'package.yml' | sort -u | while read -r pkg; do \
			pkg_name="$$(awk -F': ' '/^name/ {print $$2}' < "$${pkg}")"; \
			pkg_version="$$(awk -F': ' '/^version/ {print $$2}' < "$${pkg}")"; \
			pkg_src="$$(awk '/^\s+/ {print $$2}' < "$${pkg}" | head -1)"; \
			pkg_version_new="$$(cuppa q "$${pkg_src}" | awk '{print $$1}')"; \
			echo $$pkg_version $$pkg_version_new $$pkg_name; \
			[ "$${pkg_version}" != "$${pkg_version_new}" ] && \
				[ "$${pkg_version_new}" != "🕱" ] && \
				echo "$${pkg_name}: $${pkg_version_new}" || echo -n; \
		done; \
	);

.PHONY: fetch
fetch: prepare
	@ ( \
		cd $(PKGS_BIN); \
		curl -s https://api.github.com/repos/streambinder/ashtray/releases \
			| jq '.[0].assets[] | .browser_download_url' | sed 's/"//g' \
			| while read -r asset; do \
				asset_name="$$(awk -F'/' '{print $$NF}' <<< "$${asset}")"; \
				[ ! -f "$${asset_name}" ] && \
					echo "Downloading $${asset_name}" && \
					wget -q "$${asset}" || echo -n; \
		done; \
	);

.PHONY: release
release: fetch packages components

.PHONY: clean
clean:
	@ ( \
		rm -rfv $(PKGS_BIN) && \
		find src -type f \( -name \*.eopkg -o -name pspec_\*.xml \) -print -delete; \
	);
