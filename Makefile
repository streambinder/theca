all:
	@ ( \
		mkdir -p bin && \
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

clean:
	@ ( \
		rm -rfv bin && \
		find src -type f \( -name \*.eopkg -o -name pspec_\*.xml \) -print -delete; \
	);
