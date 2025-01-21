FROM debian:bullseye-slim as build-stage

# This could be replaced with building python ourselves, but I find this acceptable.
# swap it up if you want to

# This is arch + cpu instructionset
ENV PY_FLAVOR x86_64_v3-unknown-linux-gnu-install_only_stripped
# And the actual release version for that
ENV BASE_URL https://github.com/astral-sh/python-build-standalone/releases/download
ENV PYTHON_VER 3.12.8
ENV RELEASE_VER 20250106
ENV SHASUM 3337c050775285e757406bcac24f221383958f75edb1e2ed923b0abdfd5ee350

# pip
ENV PYTHON_PIP_VERSION 24.3.1
ENV PYTHON_SETUPTOOLS_VERSION 75.8.0

ENV PYTHONHOME /python/lib/python3.12
ENV PYTHONPATH /python/lib/python3.12
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONOPTIMIZE 1
ENV PYTHONUNBUFFERED 1
ENV PYTHONFAULTHANDLER 1

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		wget \
		ca-certificates \
	; \
	rm -rf /var/lib/apt/lists/*

RUN set -eux; \
	wget -O python.tar.gz "${BASE_URL}/${RELEASE_VER}/cpython-${PYTHON_VER}+${RELEASE_VER}-${PY_FLAVOR}.tar.gz" ; \
	echo "${SHASUM}  python.tar.gz" | sha256sum --check --status; \
	tar --extract --directory / --file python.tar.gz ; \
	rm -r /python/share/; \
	rm python.tar.gz; \
	rm /python/bin/pip*; \
	wget -O get-pip.py https://bootstrap.pypa.io/get-pip.py; \
	/python/bin/python3 get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		--no-compile \
		"pip>=$PYTHON_PIP_VERSION" \
		"setuptools>=$PYTHON_SETUPTOOLS_VERSION" \
		> /dev/null 2>&1 \
	; \
	rm -f get-pip.py

# This is where you can build any deps

ADD requirements.txt .

RUN set -eux; \
	mkdir -p /deps; \
	/python/bin/python -m pip install --no-compile --target=/deps -r requirements.txt; \
	/python/bin/python -m pip uninstall -y setuptools wheel; \
	rm -r /python/lib/python3.12/bin/pip*; \
	rm -r /python/lib/python3.12/lib/python3.12/site-packages/pip*/**


# We use base, not static, despite indygreg's and later astral's
# work on ensuring these dependencies are included for python
# because many extensions may not statically link the few things included additionally
FROM gcr.io/distroless/base-debian12:debug-nonroot as final_stage

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
COPY --from=build-stage /python /
COPY --from=build-stage /deps /deps

# copy in your app code, as well as any native deps built in build stage here

ADD app.py /app.py

ENTRYPOINT [ "/bin/python3", "/app.py"]