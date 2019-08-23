PKGR_NAME := $(shell awk -F'=' '/^Name/ {print $$2}' $(HOME)/.solus | xargs)
PKGR_EMAIL := $(shell awk -F'=' '/^Email/ {print $$2}' $(HOME)/.solus | xargs)


.PHONY: all
all: packages components

.PHONY: prepare
prepare:
	@mkdir -p bin


.PHONY: packages
packages: prepare
	@ ( \
		cd bin && \
		echo Updating solbuild packages... && \
		sudo solbuild update > /dev/null 2>&1 && \
		for pkg_name in $$(grep -v ^# ../src/series); do \
			pkg="../src/$${pkg_name}"; \
			pkg_version="$$(awk -F': ' '/^version/ {print $$2}' $${pkg}/package.yml)"; \
			pkg_release="$$(awk -F': ' '/^release/ {print $$2}' $${pkg}/package.yml)"; \
			if [ -f "$${pkg_name}-$${pkg_version}-$${pkg_release}-"*".eopkg" ]; then \
				echo "Package $$(tput bold)$${pkg_name}$$(tput sgr0) already in and updated."; \
			else \
				echo "Compiling $$(tput bold)$${pkg_name}$$(tput sgr0)..."; \
				sudo solbuild build "$${pkg}/package.yml" 2>&1 > /dev/null || \
				echo "$$(tput bold)Unable to build $${pkg_name}!$$(tput sgr0)"; \
			fi; \
		done; \
		rm -f pspec*.xml; \
		echo Triggering index...; \
		sudo solbuild index > /dev/null 2>&1; \
		echo Finished. ; \
	);

.PHONY: components
components: packages
	@ ( \
		cd bin && \
		sudo chmod a+w eopkg-index.xml* && \
		sed -i '$$ d' eopkg-index.xml && \
		echo -e "$$(sed "s/{NAME}/$(PKGR_NAME)/g; s/{EMAIL}/$(PKGR_EMAIL)/g" ../src/components.xml)\n</PISI>" >> eopkg-index.xml && \
		sha1sum eopkg-index.xml | awk '{print $$1}' > eopkg-index.xml.sha1sum && \
		xz -kf eopkg-index.xml && \
		sha1sum eopkg-index.xml.xz | awk '{print $$1}' > eopkg-index.xml.xz.sha1sum; \
	);

.PHONY: check
check:
	@ ( \
		find src -maxdepth 1 -type d -not -name 'src' -printf "%f\n" | sort -u | while read -r pkg; do \
			pkg_path="src/$${pkg}/package.yml"; \
			pkg_version="$$(awk -F': ' '/^version/ {print $$2}' < "$${pkg_path}")"; \
			pkg_src="$$(awk '/^\s+/ {print $$2}' < "$${pkg_path}" | head -1)"; \
			pkg_version_new="$$(cuppa q "$${pkg_src}" | awk '{print $$1}')"; \
			[ "$${pkg_version}" != "$${pkg_version_new}" ] && \
				[ "$${pkg_version_new}" != "🕱" ] && \
				echo "$${pkg}: $${pkg_version_new}" || echo -n; \
		done; \
	);

.PHONY: fetch
fetch: prepare
	@ ( \
		cd bin; \
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
		rm -rfv bin && \
		find src -type f \( -name \*.eopkg -o -name pspec_\*.xml \) -print -delete; \
	);
