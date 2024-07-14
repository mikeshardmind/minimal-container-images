FROM debian:bullseye-slim as build-stage

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
# This could be replaced with building python ourselves, but I find this acceptable.
# swap it up if you want to

# This is arch + cpu instructionset
ENV PY_FLAVOR x86_64_v3-unknown-linux-gnu-pgo+lto-full
# And the actual release version for that
ENV BASE_URL https://github.com/indygreg/python-build-standalone/releases/download
ENV PYTHON_VER 3.12.4
ENV RELEASE_VER 20240713
ENV SHASUM 7bd1ba6c8d3cc0852d0f542ad39f257d4316bad4ea20b19c9b2031eae13b3f7f
# pip
ENV PYTHON_PIP_VERSION 24.1.1
ENV PYTHON_SETUPTOOLS_VERSION 65.5.1
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/e03e1607ad60522cf34a92e834138eb89f57667c/public/get-pip.py
ENV PYTHON_GET_PIP_SHA256 ee09098395e42eb1f82ef4acb231a767a6ae85504a9cf9983223df0a7cbd35d7

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		zstd \
		wget \
		ca-certificates \
		netbase \
		tzdata \
	; \
	rm -rf /var/lib/apt/lists/*

RUN set -eux; \
	wget -O python.tar.zst "${BASE_URL}/${RELEASE_VER}/cpython-${PYTHON_VER}+${RELEASE_VER}-${PY_FLAVOR}.tar.zst"; \
	echo "${SHASUM}  python.tar.zst" | sha256sum --check --status; \
	tar --extract --use-compress-program=unzstd --directory / --file python.tar.zst; \
	rm -r /python/build/; \
	rm -r /python/licenses/; \
	rm -r /python/install/share/; \
	rm python.tar.zst; \
	rm /python/install/bin/pip*; \
	\
	wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
	echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum -c -; \
	\
	export PYTHONDONTWRITEBYTECODE=1; \
	export PYTHONHOME=/python/install/lib/python3.12; \
	export PYTHONPATH=/python/install/lib/python3.12; \
	\
	/python/install/bin/python3 get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		--no-compile \
		"pip==$PYTHON_PIP_VERSION" \
		"setuptools==$PYTHON_SETUPTOOLS_VERSION" \
		> /dev/null 2>&1 \
	; \
	rm -f get-pip.py

ENV PATH /python/bin:$PATH
ENV PYTHONHOME /python/install/lib/python3.12
ENV PYTHONPATH /python/install/lib/python3.12

# This is where you can build any deps

ADD requirements.txt .

RUN set -eux; \
	mkdir -p /deps; \
	/python/install/bin/python3 -m pip install --target=/deps -r requirements.txt;

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
ENV PYTHONHOME /lib/python3.12
ENV PYTHONPATH /lib/python3.12:/deps

# Various desirable environment settings
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONOPTIMIZE 1
ENV PYTHONUNBUFFERED 1
ENV PYTHONFAULTHANDLER 1

# copy in python and the built dependencies
COPY --from=build-stage /python/install /
COPY --from=build-stage /deps /deps

# copy in your app code, as well as any native deps built in build stage here

ADD app.py /app.py

ENTRYPOINT [ "/bin/python3", "/app.py"]