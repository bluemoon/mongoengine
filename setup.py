from setuptools import find_packages
from distutils.core import setup
from distutils.extension import Extension

from Cython.Distutils import build_ext

import os

DESCRIPTION = "A Python Document-Object Mapper for working with MongoDB"

LONG_DESCRIPTION = None
try:
    LONG_DESCRIPTION = open('README.rst').read()
except:
    pass

def get_version(version_tuple):
    version = '%s.%s' % (version_tuple[0], version_tuple[1])
    if version_tuple[2]:
        version = '%s.%s' % (version, version_tuple[2])
    return version

# Dirty hack to get version number from monogengine/__init__.py - we can't
# import it as it depends on PyMongo and PyMongo isn't installed until this
# file is read
init = os.path.join(os.path.dirname(__file__), 'mongoengine', '__init__.py')
version_line = filter(lambda l: l.startswith('VERSION'), open(init))[0]
VERSION = get_version(eval(version_line.split('=')[-1]))
print VERSION


ext_modules = [Extension("mongoengine.optimized", ["mongoengine/optimized.pyx"]),
               Extension("mongoengine.fields", ["mongoengine/fields.pyx"]),
               Extension("mongoengine.base_opt", ["mongoengine/base_opt.pyx"])]

CLASSIFIERS = [
    'Development Status :: 4 - Beta',
    'Intended Audience :: Developers',
    'License :: OSI Approved :: MIT License',
    'Operating System :: OS Independent',
    'Programming Language :: Python',
    'Topic :: Database',
    'Topic :: Software Development :: Libraries :: Python Modules',
]

setup(name='mongoengine',
      version=VERSION,
      packages=find_packages(exclude=('tests',)),
      author='Harry Marr',
      author_email='harry.marr@{nospam}gmail.com',
      maintainer="Ross Lawley",
      maintainer_email="ross.lawley@{nospam}gmail.com",
      url='http://mongoengine.org/',
      license='MIT',
      include_package_data=True,
      description=DESCRIPTION,
      long_description=LONG_DESCRIPTION,
      platforms=['any'],
      classifiers=CLASSIFIERS,
      install_requires=['pymongo'],
      tests_require=['nose', 'coverage', 'blinker', 'django>=1.3', 'PIL'],
      cmdclass = {'build_ext': build_ext},
      ext_modules = ext_modules
)
