#!/bin/bash
set -ex

yum update -y
yum install -y \
    atlas-devel \
    atlas-sse3-devel \
    blas-devel \
    gcc \
    gcc-c++ \
    lapack-devel \
    python36-devel \
    python36-virtualenv \
    findutils \
    zip

do_pip () {
    pip install --upgrade pip wheel
    pip install --use-wheel --no-binary numpy numpy
    pip install --use-wheel --no-binary scipy scipy
    pip install --use-wheel smart-open
    pip install --use-wheel gensim
}

strip_virtualenv () {
    echo "venv original size $(du -sh $VIRTUAL_ENV | cut -f1)"
    find $VIRTUAL_ENV/lib64/python3.6/site-packages/ -name "*.so" | xargs strip
    echo "venv stripped size $(du -sh $VIRTUAL_ENV | cut -f1)"

    pushd $VIRTUAL_ENV/lib64/python3.6/site-packages/ && zip -r -9 -q /outputs/venv.zip * ; popd
    echo "site-packages compressed size $(du -sh /outputs/venv.zip | cut -f1)"

    pushd $VIRTUAL_ENV && zip -r -q /outputs/full-venv.zip * ; popd
    echo "venv compressed size $(du -sh /outputs/full-venv.zip | cut -f1)"
}

shared_libs () {
    libdir="$VIRTUAL_ENV/lib64/python3.6/site-packages/lib/"
    mkdir -p $VIRTUAL_ENV/lib64/python3.6/site-packages/lib || true
    cp /usr/lib64/atlas/* $libdir
    cp /usr/lib64/libquadmath.so.0 $libdir
    cp /usr/lib64/libgfortran.so.3 $libdir
}

main () {
    /usr/bin/virtualenv-3.6 \
        --python /usr/bin/python3.6 /sklearn_build \
        --always-copy \
        --no-site-packages
    source /sklearn_build/bin/activate

    do_pip

    shared_libs

    strip_virtualenv
}
main
