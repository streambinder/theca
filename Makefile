all:
	@ ( \
		sudo solbuild update && \
		mkdir -p bin && \
		cd bin && \
		for pkg in ../src/*; do \
			pkg_name="$$(awk -F'/' '{print $$NF}' <<< "$${pkg}")"; \
			pkg_version="$$(awk -F': ' '/version/ {print $$2}' $${pkg}/package.yml)"; \
			pkg_release="$$(awk -F': ' '/release/ {print $$2}' $${pkg}/package.yml)"; \
			if [ -f "$${pkg_name}-$${pkg_version}-$${pkg_release}-"*".eopkg" ]; then \
				echo "Package $$(tput bold)$${pkg_name}$$(tput sgr0) already in and updated."; \
			else \
				echo "Compiling $$(tput bold)$${pkg_name}$$(tput sgr0)..."; \
				sudo solbuild build "$${pkg}/package.yml" > /dev/null; \
			fi; \
		done; \
		rm -f pspec*.xml; \
		sudo solbuild index; \
	);

clean:
	@ ( \
		rm -rfv bin && \
		find src -type f -name \*.eopkg -delete; \
	);
