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


 ### Comparison between python here to python-slim (outdated, but remains true of current versions)

  (Current 3.12.4, no deps, ours: less than 94MB)

  (below outdated)

  comparing against using python:3.11.3-slim-bullseye as a direct base (for the closest possible comparison)

  - we get an image that is about 22% smaller for including python (prior to our code being added for python to run) (good)
  - we don't run as root (good)
  - we don't have a shell (good)
  - we don't have runtime access to buildtools (good)
  - a dependency on a specific build of python (mixed good and bad, this can be sidestepped without losing other benefits here)

  we don't compare to alpine based official python builds, as these are currently slower performance wise by a margin that should matter even to people who claim python performance doesn't matter. A fair comparison to this could be constructed, but we actually want an optimized runtime

### TODO

- other (non-python) examples
- detailed explanation of how to asses various tradeoffs