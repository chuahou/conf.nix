This directory will contain submodules of other Git repositories that
are used as inputs to this flake for ease of access. Their presence as
submodules here is purely for convenience so that I get everything with
a single

::

	git clone git@github.com:chuahou/conf.nix --recurse-submodules

rather than having to clone each repo individually. As the flake inputs
use ``github:chuahou/xxx`` URLs (relative paths in flake inputs are not
yet supported), the submodules' presence here is orthogonal to builds
(which would also require a ``nix flake update --update-input``.
