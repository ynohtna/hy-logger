#!/usr/bin/env python3
from setuptools import setup

with open("README.rst", "r") as fh:
    long_description = fh.read()

setup(name="hy_logger",
      version="0.3.1a1",
      description="A lightweight, highly pluggable logging sub-system for Hy",
      long_description=long_description,
      long_description_content_type="text/x-rst",
      author="Anthony Bowyer-Lowe",
      author_email="anthony@lowbroweye.com",
      url="https://github.com/ynohtna/hy_logger",
      license='MPL-2.0',
      classifiers=[
          'Development Status :: 2 - Pre-Alpha',
          'Intended Audience :: Developers',
          'Programming Language :: Python :: 3',
          'Programming Language :: Lisp',
          'Operating System :: OS Independent',
          'License :: OSI Approved :: Mozilla Public License 2.0 (MPL 2.0)',
          'Topic :: Software Development :: Libraries',
      ],
      packages=["hy_logger"],
      package_data={
          "hy_logger": ["*.hy"]
      },
      install_requires=["hy"],
    )
