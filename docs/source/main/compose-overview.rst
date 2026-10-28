Docker Compose Overview
=======================

Purpose
-------

This lab uses Docker Compose to build and serve the Docsy documentation
website with multiple services.
Live reload automatically updates this page when its source changes

Services
--------

The builder service converts Sphinx source files into HTML.
The Nginx web service serves the generated HTML to visitors.

Shared Storage
--------------

A named volume called site stores the generated HTML.
The builder writes to this volume, and Nginx reads from it.
