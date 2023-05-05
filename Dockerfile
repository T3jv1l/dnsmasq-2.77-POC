FROM ubuntu:18.04


RUN apt update && apt install -y \
    gcc-multilib g++-multilib libc6-dev-i386\
    libbsd-dev\
    make \
    g++ \
    socat \
    libssl-dev\
    gdb \
    python3 \
    net-tools \
    python3-pip

RUN useradd -d /home/ctf/ -m -p ctf -s /bin/bash ctf
RUN echo "ctf:ctf" | chpasswd

RUN python3 -m pip install --upgrade pip
WORKDIR /home/ctf

RUN apt-get install -y --force-yes wget git make gnupg nano
COPY libllvm-3.9-ocaml-dev_3.9.1-5ubuntu1_amd64.deb .
COPY libllvm3.9_3.9.1-19ubuntu1_amd64.deb .
COPY dnsmasq-2.77 .

RUN ls
RUN dpkg -i libllvm3.9_3.9.1-19ubuntu1_amd64.deb


# RUN apt install llvm-3.9-ocaml-dev

RUN apt install llvm-3.9-dev gcc make perl -y

RUN apt-get install -y --force-yes clang-3.9 clang-3.9-doc libclang-common-3.9-dev libclang-3.9-dev libclang1-3.9 libclang1-3.9-dbg libllvm3.9 libllvm3.9-dbg lldb-3.9 llvm-3.9 llvm-3.9-dev llvm-3.9-doc llvm-3.9-examples llvm-3.9-runtime clang-format-3.9 python-clang-3.9 libfuzzer-3.9-dev


env CFLAGS="-O1 -g -fsanitize=address,bool,float-cast-overflow,integer-divide-by-zero,return,returns-nonnull-attribute,shift-exponent,signed-integer-overflow,unreachable,vla-bound -fno-sanitize-recover=all -fno-omit-frame-pointer -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION=1"
env CXXFLAGS="-O1 -g -fsanitize=address,bool,float-cast-overflow,integer-divide-by-zero,return,returns-nonnull-attribute,shift-exponent,signed-integer-overflow,unreachable,vla-bound -fno-sanitize-recover=all -fno-omit-frame-pointer -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION=1"
env LDFLAGS="-g -fsanitize=address,bool,float-cast-overflow,integer-divide-by-zero,return,returns-nonnull-attribute,shift-exponent,signed-integer-overflow,unreachable,vla-bound"
env CC="/usr/bin/clang-3.9"
env CXX="/usr/bin/clang++-3.9"
env ASAN_OPTIONS="exitcode=1,handle_segv=1,detect_leaks=1,leak_check_at_exit=1,allocator_may_return_null=1,detect_odr_violation=0"
env ASAN_SYMBOLIZER_PATH="/usr/lib/llvm-3.9/bin/llvm-symbolizer"

RUN bash -c 'echo "export CFLAGS=\"${CFLAGS}\"" >> /root/.bashrc'
RUN bash -c 'echo "export CXXFLAGS=\"${CXXFLAGS}\"" >> /root/.bashrc'
RUN bash -c 'echo "export LDFLAGS=\"${LDFLAGS}\"" >> /root/.bashrc'
RUN bash -c 'echo "export CC=\"${CC}\"" >> /root/.bashrc'
RUN bash -c 'echo "export CXX=\"${CXX}\"" >> /root/.bashrc'
RUN bash -c 'echo "export CXXFLAGS=\"${CXXFLAGS}\"" >> /root/.bashrc'
RUN bash -c 'echo "export ASAN_OPTIONS=\"${ASAN_OPTIONS}\"" >> /root/.bashrc'
RUN bash -c 'echo "export ASAN_SYMBOLIZER_PATH=\"${ASAN_SYMBOLIZER_PATH}\"" >> /root/.bashrc'

RUN bash -c "$(wget https://gef.blah.cat/sh -O -)"
RUN pip3 install pwntools
RUN make

ENTRYPOINT /home/ctf/src/dnsmasq --no-daemon --dhcp-range=fd00::2,fd00::ff
# ENTRYPOINT /bin/bashc