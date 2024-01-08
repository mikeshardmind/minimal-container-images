FROM debian:bullseye-slim as build-stage

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
# This could be replaced with building python ourselves, but I find this acceptable.
# swap it up if you want to

# This is arch + cpu instructionset
ENV PY_FLAVOR x86_64_v3-unknown-linux-gnu-install_only
# And the actual release version for that
ENV BASE_URL https://github.com/indygreg/python-build-standalone/releases/download
ENV PYTHON_VER 3.11.7
ENV RELEASE_VER 20240107
ENV SHASUM 08dd57796b8fcc2a7307ed4dbe7a69cf35856cb29a5c79f827fe08a0663c227f
# pip
ENV PYTHON_PIP_VERSION 23.2.1
ENV PYTHON_SETUPTOOLS_VERSION 65.5.1
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/9af82b715db434abb94a0a6f3569f43e72157346/public/get-pip.py
ENV PYTHON_GET_PIP_SHA256 45a2bb8bf2bb5eff16fdd00faef6f29731831c7c59bd9fc2bf1f3bed511ff1fe

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		wget \
		ca-certificates \
		netbase \
		tzdata \
	; \
	rm -rf /var/lib/apt/lists/*

RUN set -eux; \
	wget -O python.tar.gz "${BASE_URL}/${RELEASE_VER}/cpython-${PYTHON_VER}+${RELEASE_VER}-${PY_FLAVOR}.tar.gz"; \
	echo "${SHASUM}  python.tar.gz" | sha256sum --check --status; \
	tar --extract --directory / --file python.tar.gz; \
	rm -r /python/share/ ;\
	rm python.tar.gz; \
	rm /python/bin/pip*; \
	\
	wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
	echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum -c -; \
	\
	export PYTHONDONTWRITEBYTECODE=1; \
	export PYTHONHOME=/python/lib/python3.11; \
	export PYTHONPATH=/python/lib/python3.11; \
	\
	/python/bin/python3 get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		--no-compile \
		"pip==$PYTHON_PIP_VERSION" \
		"setuptools==$PYTHON_SETUPTOOLS_VERSION" \
		> /dev/null 2>&1 \
	; \
	rm -f get-pip.py

ENV PATH /python/bin:$PATH
ENV PYTHONHOME /python/lib/python3.11
ENV PYTHONPATH /python/lib/python3.11

# This is where you can build any deps

ADD requirements.txt .

RUN set -eux; \
	mkdir -p /deps; \
	/python/bin/python3 -m pip install --target=/deps -r requirements.txt --require-hashes;

# We use base, not static, despite indygreg's work on ensuring these dependencies are included for python
# because many extensions may not statically link the few things included additionally
FROM gcr.io/distroless/base-debian11:debug-nonroot as final_stage

# Note: there is a shell. python's os.system, popen, etc will **not** work without one
# you can change this to :nonroot instead of :debug-nonroot and remove the busybox shell
# so long as you don't use it in your application code.
# Note:
# This example was previously provided without a shell.
# I personally believe in removing it, but many people do not agree this is worth the friction
# if needing to inspect given how few things are available as-is

# Various envioronment settings neccessary
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONHOME /lib/python3.11
ENV PYTHONPATH /lib/python3.11:/deps

# Various desirable environment settings
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONOPTIMIZE 1
ENV PYTHONUNBUFFERED 1
ENV PYTHONFAULTHANDLER 1

# copy in python and the built dependencies
COPY --from=build-stage /python /
COPY --from=build-stage /deps /deps

# copy in your app code, as well as any native deps built in build stage here

ADD app.py /app.py

ENTRYPOINT [ "/bin/python3", "/app.py"]