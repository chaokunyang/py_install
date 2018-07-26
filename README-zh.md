# Python 离线安装指南

Python 是一门容易学习和强大的编程语言。 但是长期缺失以构建的Linux免安装离线发布，一直让人头疼。本项目试着解决这个问题，通过**构建一个可以类似于`JDK`那种可以直接使用免安装的`Python`发布**。

该发布不需要安装，不污染系统目录，比如`/usr/local/lib`. 如果你想要安装它，直接复制档案包到某个目录，解压皆可使用，如果你喜欢，也可以导出bin目录到环境变量。因此你可以在同一台机器上有任意多个`Python`安装，各个`Python`之间没有任何冲突，类似于`virtualenv`。如果需要卸载`Python`，直接删除安装目录即可(如果导出了PATH变量，需要从PATH变量移除该安装的bin路径)。

该发布是通过编译`python`和依赖到同一个目录，然后在启动`python`时导出`LD_LIBRARY_PATH`，从而让`python`能够从相对的lib目录找到其依赖的动态库。本项目同时也展示了一种通过`pip`离线安装python lib及其依赖的方法。

## 下载Python源码

python3.6.6: https://www.python.org/ftp/python/3.6.6/Python-3.6.6.tgz

## 下载Python依赖库源码

* bzip2: http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz
* zlib: https://zlib.net/zlib-1.2.11.tar.gz
* readline: ftp://ftp.cwru.edu/pub/bash/readline-6.3.tar.gz
* openssl: https://www.openssl.org/source/openssl-1.0.2o.tar.gz
* sqlite: https://www.sqlite.org/2018/sqlite-autoconf-3240000.tar.gz
* ncurses: ftp://ftp.invisible-island.net/ncurses/ncurses-6.1.tar.gz
* xz utils (lzma): https://excellmedia.dl.sourceforge.net/project/lzmautils/xz-5.2.4.tar.gz

## 下载Python库wheel (可选)

如果你想要离线安装python库及其依赖，参考下面步骤:

* 创建`requirements.txt`文件, 加入类库依赖

    `requirements.txt`示例:

    ```text
    Flask==0.12
    requests>=2.7.0
    scikit-learn==0.19.1
    numpy==1.14.3
    pandas==0.22.0
    ```

* 在一台有网和已经安装Python的相同操作系统和CPU架构机器上，执行下面命令下载Python库机器依赖

    ```bash
    pip download -r requirements.txt -d wheelhouse
    ```

* 归档 `requirements.txt` 和 wheelhouse 到 `py_assembly.tar.gz`
* 或者你可以在下载完python库及其依赖到wheelhouse目录后，使用下面命令安装python库及其依赖

    ```bash
    pip install -r requirements.txt --no-index --find-links wheelhouse
    ```

## 打包所有文件

档案包应该有下面这些内容：

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

## 编译和安装本地库、Python、Python库

构建 python

```bash
./py_install.sh build_python
```

安装 python 库 (可选)

```bash
./py_install.sh install_pylib
```

配置 `PATH` 环境变量

```bash
echo "" >> ~/.bashrc
echo "# Python" >> ~/.bashrc
echo "export PATH=`pwd`/python/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
```

或者一步完成所有这些工作

```bash
./py_install.sh
```

## Contribute

* Issue Tracker: https://github.com/chaokunyang/py_install/issues
* 如果这里有更好的方法，欢迎你告诉我

## LICENSE

This project is licensed under Apache License 2.0.