FROM debian:bullseye-slim as build-stage


# This could be replaced with building python ourselves, but I find this acceptable.
# swap it up if you want to

# This is arch + cpu instructionset
ENV PY_FLAVOR x86_64_v3-unknown-linux-gnu-install_only
# And the actual release version for that
ENV BASE_URL https://github.com/indygreg/python-build-standalone/releases/download
ENV PYTHON_VER cpython-3.11.3+20230507
ENV RELEASE_VER 20230507
ENV SHASUM 6452fe315b5240040acffc5688e97fc264d9eb8fbfdd90c6ede0bc46b20640e0

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		wget \
		ca-certificates \
		netbase \
		tzdata \
		libcrypt1 \
	; \
	rm -rf /var/lib/apt/lists/*

RUN set -eux; \
	wget -O python.tar.gz "${BASE_URL}/${RELEASE_VER}/${PYTHON_VER}-${PY_FLAVOR}.tar.gz"; \
	echo "${SHASUM}  python.tar.gz" | sha256sum --check --status; \
	tar --extract --directory / --file python.tar.gz; \
	rm -r /python/share/ ;\
	rm python.tar.gz

ENV PATH /python/bin:$PATH
ENV PYTHONHOME /lib/python3.11
ENV PYTHONPATH /lib/python3.11

# This is where you can build any deps from requirements.txt


# We use base, not static, despite indygreg's work on ensuring these dependencies are included for python
# because many extensions may not statically link the few things included additionally
FROM gcr.io/distroless/base-debian11:nonroot as final_stage

# Note: there is no shell. python's os.system, popen, etc will **not** work.
# This is intentional. Copy in a shell if you absolutely must, but this increases risks significantly.
# Better to use actual extension modules in your application code than glue together things in this manner.
# you can also switch this to :debug-nonroot for a busybox shell to be included

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PYTHONFAULTHANDLER 1
ENV PYTHONOPTIMIZE 1
ENV PYTHONHOME /lib/python3.11
ENV PYTHONPATH /lib/python3.11

COPY --from=build-stage /python /

ENV ARCH_INFO x86_64-linux-gnu
# A lot of distros have dropped LSB compliance as a requirement, and a lot of things, python included, relied on it
# https://github.com/indygreg/python-build-standalone/issues/173
# 3.13 moots this in the future with the removal of `crypt`
# https://discuss.python.org/t/pep-594-has-been-implemented-python-3-13-removes-20-stdlib-modules/27124
COPY --from=build-stage /lib/${ARCH_INFO}/libcrypt.so.1 /lib/${ARCH_INFO}/libcrypt.so.1

# copy in your app code, as well as any native deps built in build stage here

ENTRYPOINT [ "/bin/python3" ]
CMD [ "/bin/python3" ]