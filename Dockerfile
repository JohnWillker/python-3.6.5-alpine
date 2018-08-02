FROM python:3.6.5-alpine

RUN   apk update \
      && apk --no-cache add hdf5 hdf5-dev libffi-dev --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
      && apk --update --no-cache --virtual .build-dep add \
      build-base \
      && pip install --upgrade pip

RUN   apk add --no-cache  \
            ca-certificates \
            libstdc++ \
            libgfortran \
      && ln -s /usr/include/locale.h /usr/include/xlocale.h \
      && apk add --virtual=build_dependencies \
            gfortran \
      && mkdir -p /tmp/build \
      && cd /tmp/build/ \
      && wget http://www.netlib.org/blas/blas-3.7.1.tgz \
      && wget http://www.netlib.org/lapack/lapack-3.7.1.tgz \
      && tar xzf blas-3.7.1.tgz \
      && tar xzf lapack-3.7.1.tgz \
      && cd /tmp/build/BLAS-3.7.1/ \
      && gfortran -O3 -std=legacy -m64 -fno-second-underscore -fPIC -c *.f \
      && ar r libfblas.a *.o \
      && ranlib libfblas.a \
      && mv libfblas.a /tmp/build/. \
      && cd /tmp/build/lapack-3.7.1/ \
      && sed -e "s/frecursive/fPIC/g" -e "s/ \.\.\// /g" -e "s/^CBLASLIB/\#CBLASLIB/g" make.inc.example > make.inc \
      && make lapacklib \
      && mv liblapack.a /tmp/build/.


