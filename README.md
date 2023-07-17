# minimal container images

### Why a repo with basically nothing but an example that still needs modifying for each use in it?
 Because people keep pulling way too many things into images.

 you don't have to give up convienice or build speed to have a minimal container attack surface, and I want a public example
 out there that works even in cases that people don't typically think of using distroless/scratch for

### Disclaimer
 most of the time, people jumpt to using containers when they don't need or benefit from them too.
 proper use of systemd units, good SELinux policies, and cgroups directly on the host is often preferable.

 what's here is meant to be an example for non-trivial cases. google's distroless / distroless-static
 are great for many cases and there's overlap here with those.
 If you can use those directly (any of the flavors they support), go for it.