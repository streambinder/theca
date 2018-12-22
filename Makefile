all:
	@ ( \
		sudo solbuild update && \
		mkdir -p bin && \
		cd bin && \
		for pkg in ../src/*; do \
			pkg_name="$$(awk -F'/' '{print $$NF}' <<< "$$pkg")"; \
			if [ ! -e "$${pkg_name}-"*".eopkg" ]; then \
				sudo solbuild build $${pkg}/package.yml; \
				rm -vf pspec*.xml; \
			fi; \
		done && \
		sudo solbuild index; \
	);

clean:
	@ ( \
		rm -rfv bin && \
		find src -type f -name \*.eopkg -delete; \
	);
