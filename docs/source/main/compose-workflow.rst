Documentation Development Workflow
==================================

Local Builds
------------

Activate the Python virtual environment from the repository root:

.. code-block:: bash

   source .venv/bin/activate

Build the documentation:

.. code-block:: bash

   make -C docs html

The generated HTML is stored in docs/build/html.

Planned Live Reload
--------------------

The development service will use sphinx-autobuild to watch the source
files and rebuild the documentation when they change.

Verification
------------

After editing a page, check that the build succeeds and that the updated
content appears in the browser.
