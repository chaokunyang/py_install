#!/bin/bash
script_path=`readlink -f $0`
script_dir=`dirname ${script_path}`
echo dir: ${script_dir}
cd ${script_dir}
py_install_dir=${script_dir}/python

get_py_home() {
    echo ${script_dir}/python
}

exists_file() {
    if ls ${py_install_dir}/include/$1* 1>/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# zlib readline sqlite lzma(xz)
install_nlib() {
    # lib_name=`echo ${lib_pkg} | sed 's/\(\w*\).*/\1/'`
    lib_name=$1
    lib_pkg=`ls $1*gz`
    lib_src_dir=${lib_pkg::-7}
    rm -rf ${lib_src_dir}
    if ! exists_file ${lib_name}; then
        echo "*********** install lib ${lib_name} ***********"
        rm -rf ${lib_src_dir}
        tar -zxf ${lib_pkg}
        cd ${lib_src_dir}
        if [[ -e configure ]]; then
            ./configure --prefix=${py_install_dir}
        else
            ./config --prefix=${py_install_dir}
        fi
        make clean
        make && make install
        cd ${script_dir}
        echo "*********** install lib ${lib_name} succeed ***********"
    else
        echo "${lib_name} exists, won't install it"
    fi
}

install_bzip2() {
    lib_pkg=`ls bzip2*tar.gz`
    lib_src_dir=${lib_pkg::-7}
    rm -rf ${lib_src_dir}
    if ! exists_file bzlib; then
        echo "install bzip2 lib"
        tar -zxf ${lib_pkg}
        cd ${lib_src_dir}
        make clean
        make -f Makefile-libbz2_so
        make install PREFIX=${py_install_dir}
        cp libbz2.so* ${py_install_dir}/lib
        so_lib_file=`ls libbz2.so.1.0.*`
#        ln -s ${py_install_dir}/lib/${so_lib_file} ${py_install_dir}/lib/libbz2.so.1.0
        cd ${script_dir}
        echo "install bzip2 lib succeed"
    else
        echo "bzip2 exists, won't install it"
    fi
}

install_ssl() {
    lib_pkg=`ls openssl*tar.gz`
    lib_src_dir=${lib_pkg::-7}
    rm -rf ${lib_src_dir}
    if ! exists_file openssl; then
        echo "install openssl lib"
        tar -zxf ${lib_pkg}
        cd ${lib_src_dir}
        ./config --prefix=${py_install_dir} --openssldir=${py_install_dir}/ssl
        make && make install
        ./config shared --prefix=${py_install_dir} --openssldir=${py_install_dir}/ssl
        make clean
        make && make install
        cd ${script_dir}
        echo "install openssl lib succeed"
    else
        echo "openssl exists, won't install it"
    fi
}

install_ncurses() {
    lib_pkg=`ls ncurses*tar.gz`
    lib_src_dir=${lib_pkg::-7}
    rm -rf ${lib_src_dir}
    if ! exists_file ncurses; then
        echo "install ncurses lib"
        tar -zxf ${lib_pkg}
        cd ${lib_src_dir}
        # use --enable-overwrite to install on top dir, thus can be searched. or use CPPFLAGS
        ./configure --prefix=${py_install_dir} --with-shared --enable-overwrite
        make clean
        make && make install
        cd ${script_dir}
        echo "install ncurses lib succeed"
    else
        echo "ncurses exists, won't install it"
    fi
}


build_python() {
    rm -rf python
    install_nlib zlib
    install_nlib readline
    install_nlib sqlite
    install_nlib xz
    install_bzip2
    install_ssl
    install_ncurses

    py_pkg=`ls Python*tgz`
    py_src_dir=${py_pkg::-4}
    rm -rf ${py_src_dir}
    tar -zxf ${py_pkg}
    cd ${py_src_dir}
#    ./configure --prefix=${py_install_dir} --with-ensurepip=install --enable-shared --enable-optimizations
    ./configure --prefix=${py_install_dir} --with-ensurepip=install
    make clean
    make && make install
    cd ${py_install_dir}/bin
    make_pybin
    ln_by_relative_path
    replace_pybin_path
    ln -s pip3 pip
    cd ${script_dir}
}

make_pybin() {
    cd ${py_install_dir}/bin
    pyversion=`ls pip3.* | rev | cut -c-3 | rev`
    pybin="python${pyversion}"
    if test -h python3; then
        unlink python3
    fi
    echo "#!/bin/bash" > python3
    echo "bindir=\`readlink -f \$0\`" >> python3
    echo "export LD_LIBRARY_PATH=\`readlink -f \$0 | rev | cut -d'/' -f3- | rev\`/lib" >> python3
    echo "\"exec\"" "\"\`dirname \${bindir}\`/$pybin\"" \"\$@\" >> python3
    chmod +x python3
    if ! test -h python; then
        ln -s python3 python
    fi
}

ln_by_relative_path() {
    cd ${py_install_dir}/bin
    for link in `ls ${py_install_dir}/bin/*`; do
        if test -h ${link}; then
            target=`basename $(readlink ${link})`
            unlink ${link}
            ln -s ${target} ${link}
        fi
    done
}

replace_pybin_path() {
    cd ${py_install_dir}/bin
    bin_dir=`dirname python3`
    pyversion=`ls pip3.* | rev | cut -c-3 | rev`
    pybin="python${pyversion}"
{py_install_dir}/bin/python - <<-EOF
files = ['pip3', 'pydoc3', 'pyvenv']
for file in files:
    if open(file).read(200).split("\n")[0].endswith("${pybin}"):
        lines = open(file).read().split("\n")
        lines[0] = "#!/bin/sh"
        lines.insert(1, r'bindir=\`readlink -f \$0\`')
        lines.insert(2, r'"exec" "\`dirname \${bindir}\`/python" "\$0" "\$@"')
        with open(file, "w") as py_script:
            py_script.write("\n".join(lines))
EOF
}

install_pylib() {
    if exists_file py_assembly; then
        assembly_file=`ls py_assembly*gz`
        assembly_dir=${assembly_file::-7}
        tar -zxvf ${assembly_file}
        ${py_install_dir}/bin/pip install -r ${assembly_dir}/requirements.txt --no-index --find-links ${assembly_dir}/wheelhouse
        # pip install . --no-index --find-links ./wheelhouse
    fi
}

install() {
    build_python
    install_pylib
    echo "" >> ~/.bashrc
    echo "# Python" >> ~/.bashrc
    echo "export PATH=`pwd`/python/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc
}


if [ "$#" -eq 0 ]; then
    echo start install
    install
    echo install succeed
else
    echo start $1
    $1
    echo $1 finished
fi