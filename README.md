# using soda-opt

Build the docker image
```
docker build --rm --pull -f ./Dockerfile -t soda-opt:dev-panda .
```

Check out your code into work
```
# use the submodule
git submodule update --init --recursive
# or clone into work
cd work
git clone a-repo
```

Run the container
```
# for X forwarding to work
cp ~/.Xauthority ./env
docker run --rm -it --network=host --privileged -e DISPLAY=$DISPLAY -e UID=$(id -u) -e GID=$(id -g) -v `pwd`/env:/home/soda-opt-user/env:rw -v `pwd`/work:/home/soda-opt-user/work soda-opt:dev-panda
# in container test X forwarding
soda-opt-user@etc-gpu-09:~$ xclock
```

Work in the container
```
cd work/pytorch-iris
make ./output/01_tosa.mlir
make
make synth-baseline
make synth-optimized
```
