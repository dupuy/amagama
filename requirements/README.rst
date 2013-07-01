Python Requirements Management
==============================

The ``requirements/`` directory (and the ``requirements.txt`` file)
are used to manage Python dependencies for ``pip`` and ``virtualenv``.
You can use these files with ``pip`` to install any Python packages
required for using or developing this one.  We strongly recommend
using ``virtualenv`` so that other Python packages are installed
locally rather than in system directories, especially if you might do
anything more than just run commands from this package.

Note that this package may have dependencies on non-Python software as
well - those are not recorded or managed here; see the ``README.rst``
file in the top-level directory for details on those requirements,
which are typically satisfied by installing system packages using your
operating system's package manager.

This package may itself be installed using the system package manager,
in which case the packagers have read this document and dealt with any
dependencies and requirements, so you won't need to read this.  Note
that if this package is installed in that way, using virtualenv is not
necessary (unless you want to support multiple versions of the package
on a single system).

Using these requirements files
------------------------------

Run any of the following commands from the top-level directory:

* To install known-working versions of recommended Python dependencies
  (you will just be using this package, not developing with it)::

        # "stable" versions
        pip install -r requirements.txt

* To install the most recent versions expected to work of recommended
  Python dependencies (you will mainly be using this package, perhaps
  together with other packages)::

        # "leading edge" versions
        pip install -r requirements/recommended.txt

* To install the most recent versions expected to work of all possible
  Python dependencies (you will be developing and/or testing this
  package)::

        # "bleeding edge" versions
        pip install -r requirements/documentation.txt

* To install the oldest available versions expected to work of all
  direct Python dependencies, with any version of their dependencies
  (you are maintaining these requirements files)::

        # "trailing edge" versions
        pip install -r requirements/MINVERS.txt

  See the section below on 'Maintaining these requirements files' for
  details.

Understanding these requirements files
--------------------------------------

The files in this directory specify different kinds of Python
dependencies - you may use different ones according to your needs, and
it is important to understand the distinctions if you are recording
new dependencies on other Python packages.

* requirements/README.rst (the source for what you are now reading)

* requirements/required.txt

  This file has the minimal set of Python dependencies, without which
  this package will not work.  Each of these should also specify the
  minimum version with ``>=`` (e.g. ``lxml>=2.1.4``) and may specify a
  maximum version with ``<`` if there are incompatibilities
  (e.g. ``South>=0.7.6,<0.8``).

* requirements/recommended.txt

  This file has additional Python dependencies needed for a production
  (as opposed to testing or trial) deployment.  You may need to edit
  this to reflect deployment choices (for example whether you will use
  MySQL or PostgreSQL database).  The (``-r required.txt``) line means
  that all the dependencies in that file are required as well.

* requirements/optional.txt

  This file has additional Python dependencies that may be useful for
  this package.  The (``-r recommended.txt``) line means that all the
  dependencies in that file (and files it references with *-r*) are
  required as well.

* requirements/documentation.txt

  This file has additional Python dependencies needed to build this
  package (typically just for generating documentation, since Python
  code is compiled automatically as needed).  The (``-r optional.txt``)
  line means that all the dependencies in the previous file are
  required as well.

* requirements/py25.txt

  This file is an example of a Python version requirement file, in
  this case for Python 2.5.  It specifies maximum versions for Python
  dependencies that no longer support Python 2.5.  The maximum version
  specified should be the first official release that dropped Python
  2.5 support (in case there might be security or other bug fixes for
  older versions).  Additional requirements will be added to this file
  as other packages drop support for Python 2.5, until this package
  itself drops support for Python 2.5, at which time this file will be
  removed.

* requirements/MINVERS.txt

  This file is generated from the other files in the requirements/
  directory by running ``make requirements`` (or ``make
  requirements/MINVERS.txt``).  Using this file with pip will install
  the oldest (minimum) supported version of every Python dependency
  should be installed; this is generally not what you want, but is
  very useful when running tests to ensure that the minimum versions
  are actually supported.

* requirements.txt

  This file is generated from the requirements/recommended.txt file
  directory by running ``make requirements`` (or ``make
  requirements.txt``).  Using this file with pip will install the most
  recent known-working versions of the recommended Python dependencies,
  including known-working versions of their own dependencies.  In some
  cases, you may be able to use more recent versions, but this is always
  a reliable set of versions that can be installed to get things working.

* Makefile

  The Makefile in the top-level directory has targets for generating
  requirements files, but the shell commands to do so are in the
  ``requirements/Makefile``.

* requirements/Makefile

  This sub-Makefile has the targets and actual shell commands to
  generate the stable (``requirements.txt``) and trailing edge
  (``requirements/MINVERS.txt``) requirements files.  The trailing
  edge requirements are generated by simple textual substitution on
  all the requirements files in the requirements/ directory, which is
  quite fast, although it leads to some restrictions on the types of
  version specifications in the requirements files.

  The stable requirements file is generated by running pip to download
  the required Python packages, then analyze their dependencies and
  download them as well, proceeding recursively until all requirements
  are satisfied; the set of all downloaded Python packages with their
  specific versions is then output.  Because of the need to download
  all dependencies in full (and for older versions of pip, to install
  the dependencies), this process can be slow and time consuming.

Format of the requirements files
--------------------------------

The `format of requirements files`_ is described in the documentation
for the pip command, but to support the automatic generation of the
stable ``requirements.txt`` and trailing edge ``MINVERS.txt`` files,
some additional restrictions are imposed.

For normal lines in requirements files (without ``-e`` or ``-r``), a
minimum dependency *must* be specified with ``>=`` (not ``>``); this is
necessary to allow generation of the trailing edge requirements file.

Python version requirement files (specifying maximum versions for
Python dependencies no longer supporting a language version that is
still supported by this package) have some additional restrictions.
These files must be named ``py$VER.txt`` (where $VER is the Python
version as a two-digit number, e.g. ``py25.txt`` for Python 2.5).
Furthermore, these files should only contain direct version
requirements (i.e. no lines beginning with ``-e`` or ``-r``).

Maintaining these requirements files
------------------------------------

There are a number of situations that require updates and changes to
the requirements files.  The two generated files should not require
any editing, but they are still managed by the Git version control
system, and if they change after being regenerated, the updates may
need to be committed.

The following are descriptions of the various situations, and what
developers need to do to maintain the requirements files in each case:

* You have added code that depends on other Python packages not
  already present in the requirements files.

  You need to add the additional package(s) to one of the requirements
  files.  Determine the minimum useful version for each package, and
  specify it with a line like this: ``somepackage>=1.2.3``.  For any
  packages essential for basic operation, add them to ``required.txt``;
  add packages only used for building releases to ``documentation.txt``.
  Add anything useful for most installations to ``recommended.txt``, and
  for a package only used for testing or development, add it to
  ``optional.txt``.  You should only add the package to *one* of these
  files, as they include each other with ``-r`` lines and multiple
  entries for a package will cause problems for pip.

  After making these additions, run ``make requirements`` to
  regenerate any out-of-date requirements files and commit your
  changes (all related changes to manually maintained and generated
  requirements files should be combined in a single commit).

* You have removed the last code that depended on some Python package
  (or modified code so that the package is optional and not required
  for proper operation).

  Remove the now-obsolete lines from requirements files (or move them
  from ``required.txt`` to another file), run ``make requirements`` to
  regenerate any out-of-date requirements files, and commit resulting
  requirements changes as a single commit).

* An important update (for example, to fix a security vulnerability)
  has just been released for a Python package that is required.

  Update the minimum version for the package in any requirements file,
  and run ``make MINVERS.txt`` to regenerate the trailing edge file.
  You should install and test the resulting environment with older
  Python versions to make sure they still work (Travis does this
  automatically if you push the change or make a pull request).

  If the new package version causes problems for older Python
  versions, you may wish to back out the change, or consider dropping
  support for incompatible Python versions.  See below if you decide
  to drop support for an older Python version.  If you back out a
  change, leave a comment in the Python version requirement file (e.g.
  ``py25.txt`` for Python 2.5) indicating the desired package minimum,
  so that you can increase it when support for that Python version is
  dropped.  Putting a minimum version specification in the file will
  typically have no effect, as higher minimums in the ``required.txt``
  file or elsewhere will override it.

* You are about to make a new release of this package.

  You should always run ``make requirements`` during the QA period
  before a release and before creating alpha, beta, or release
  candidate PyPI packages.  Note that you should *not* update the
  generated requirements for the final release - you should use the
  requirements files from the final release candidate, as that is what
  is actually tested.  If you really need to update the requirements,
  you should consider generating another release candidate instead.

* You are packaging this package for inclusion in an operating system
  release's system package set.

  As this sort of distribution will typically *not* use a virtualenv
  or be installed with pip, the requirements files are mostly
  irrelevant and you should probably omit this entire directory from
  binary packages in your distribution (per the LICENSE, you should
  include it in source packages).  You may want to provide a
  requirements.txt file; you should probably take the generated
  version and update the specific pinned versions to match the
  versions in your operating system release.  If you have an internal
  PyPI mirror with the specific versions packaged with your operating
  system, using that may help you to use ``make requirements.txt`` to
  generate your specific requirements.txt versioned file.

* Changes to the code in this package have caused testing failures
  with the minimum ("trailing edge") versions of requirements.

  Update the minimum version for the package in any requirements file,
  and run ``make MINVERS.txt`` to regenerate the trailing edge file.
  You should install and test the resulting environment with older
  Python versions to make sure they still work (Travis does this
  automatically if you push the change or make a pull request).

  If the new package version causes problems for older Python
  versions, you probably want to back out the change, or at least
  re-work it so that it can handle older package versions that lack
  the new feature you are using.  Adding try/except blocks can be
  helpful for this in some cases.  Also leave a comment in the Python 
  version requirement file indicating the desired package minimum that
  isn't being required, so that you can increase it when you drop
  support for that Python version.

* Changes to the code in this package have caused testing failures
  with older Python versions

  If it is code in this package that is breaking older Python
  versions, you should generally re-work it so that the older version
  can still be supported.  However, you may want to consider dropping
  support for that Python version.  In any event, there isn't anything
  you can do with or to requirements files to address this issue.

* You have decided to drop support for an older version of Python.

  You should remove the corresponding Python version requirements
  (``py*.txt``) file from this directory (if there is not one, your
  decision to drop support is probably premature), and run ``make
  requirements`` to regenerate the requirements files.  If you left
  comments in the removed file about package minimum versions that
  were left below the desired level, you may be able to increase them
  now (but check values in other Python version requirements files).

* New releases of required packages have caused testing failures with
  the most recent ("leading edge") versions of requirements.

  If the failures are occurring with older versions of Python, it is
  probably caused by dropping support for those older versions; you
  will probably need to add this package with a maximum version to the
  Python version requirements (``py*.txt``) files for any version of
  Python that is no longer supported by that package.  The maximum
  version should be based on the first release where support was
  dropped (e.g. ``South<0.8``) rather than the last supported release
  (e.g. ``South<=0.7.6``) as you never know if there might be a minor
  release for a security vulnerability in the near future.

  If the failures are occurring even with newer Python versions, this
  may be a compatibility issue with the package itself, where the new
  version does not provide a compatible API; in this case placing a
  maximum version specification (or even a specific version
  requirement, e.g. ``django-voting==0.1``) in ``required.txt`` (or
  whichever requirements file the package is listed in) is
  recommended.

  In other cases, there may be incompatibilities between the new
  package revision and other packages, e.g. South 0.8 only worked with
  Django 1.5, and not with earlier versions of Django. In this case a
  version exclusion might be the best solution, but setting maximum
  versions may be a reasonable choice as well.

.. _format of requirements files: http://www.pip-installer.org/en/latest/requirements.html#requirements-file-format
