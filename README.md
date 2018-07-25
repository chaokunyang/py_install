# Python Offline Install

Python is an easy to learn, powerful programming language. But the long-term lack of pre-built distribution for linux offline free installation has been a headache (at least for me). This project is headed to fill the gap by **building a linux python distribution that can be used directly after extract from archive**.

It don't need to be installed, don't pollute system directory such as `/usr/local/lib`. You can have any number of `python` installations on your machine in this way. It didn't make modifications to python source code. It compiles python and its dependencies to the same directory, and use some linux tricks to export `LD_LIBRARY_PATH` when execute `python` program, so python can find dynamic libs from ralative `lib` directory. Thus it can run on linux and at any file directory location. And also demonstrates a way using `pip` to download python libs and libs sdependencies for python libs offline installation. It is not a perfect way. but can be useful in many situation.

## Download python source code

python3.6.6: https://www.python.org/ftp/python/3.6.6/Python-3.6.6.tgz

## Download dependencies

* bzip2: http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz
* zlib: https://zlib.net/zlib-1.2.11.tar.gz
* readline: ftp://ftp.cwru.edu/pub/bash/readline-6.3.tar.gz
* openssl: https://www.openssl.org/source/openssl-1.0.2o.tar.gz
* sqlite: https://www.sqlite.org/2018/sqlite-autoconf-3240000.tar.gz
* ncurses: ftp://ftp.invisible-island.net/ncurses/ncurses-6.1.tar.gz
* xz utils (lzma): https://excellmedia.dl.sourceforge.net/project/lzmautils/xz-5.2.4.tar.gz

## Download python libs (optional)

If you want install python lib offline when install python, you can following the commands:

* Create an requirements.txt file, and fill the lib

    Example requirements.txt:

    ```text
    Flask==0.12
    requests>=2.7.0
    scikit-learn==0.19.1
    numpy==1.14.3
    pandas==0.22.0
    ```

* Execute the command to download libs and dependencies of libs to directory wheelhouse (Of course on a machine which network connected and python installed)

    ```bash
    pip install -r requirements.txt --no-index --find-links wheelhouse
    ```

* Archive requirements.txt and wheelhouse to `py_assembly.tar.gz`
* Or you can install python libs using following command after you download libs and dependencies of libs to directory wheelhouse

    ```bash
    pip install -r requirements.txt --no-index --find-links wheelhouse
    ```

## Package all files

The archive should have the following contents

* Python-3.6.6.tgz
* bzip2-1.0.6.tar.gz
* zlib-1.2.11.tar.gz
* readline-6.3.tar.gz
* openssl-1.0.2o.tar.gz
* gdbm-1.16.tar.gz
* sqlite-autoconf-3240000.tar.gz
* ncurses-5.7.tar.gz
* xz-5.2.4.tar.gz
* py_assembly.tar.gz (optional)

## Compile and install native dependencies, python and python libs

Build python

```bash
./py_build.sh build_python
```

Install python libs (optional)

```bash
./py_build.sh install_pylib
```

Configure PATH environment variable

```bash
echo "" >> ~/.bashrc
echo "# Python" >> ~/.bashrc
echo "export PATH=`pwd`/python/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
```

Or you can do all in one big step

```bash
./py_build.sh
```

## Contribute

* Issue Tracker: https://github.com/chaokunyang/py_build/issues
* I'm not sure if there is a better way to do this, or it has be implemented by others. If you know, just tell me. I'll be appreciated.

## LICENSE

This project is licensed under Apache License 2.0.