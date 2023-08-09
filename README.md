Copyright 2023 Carnegie Mellon University.
MIT (SEI)
Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.
This material is based upon work funded and supported by the Department of
Defense under Contract No. FA8702-15-D-0002 with Carnegie Mellon University
for the operation of the Software Engineering Institute, a federally funded
research and development center.
The view, opinions, and/or findings contained in this material are those of
the author(s) and should not be construed as an official Government position,
policy, or decision, unless designated by other documentation.
NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING
INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON
UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR
PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE
MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND
WITH RESPECT TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
[DISTRIBUTION STATEMENT A] This material has been approved for public release
and unlimited distribution.  Please see Copyright notice for non-US
Government use and distribution.
DM23-0186


# using soda-opt

Build the docker image
```
docker build --rm --pull -f ./Dockerfile -t soda-opt:dev-panda .
```

Check out your code into work
```
cd work
git clone ssh://git@code.sei.cmu.edu:7999/acl/pytorch-iris.git
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

![Lowering](lowering.png)

Steps encoded in the Makefile.
- `$(ODIR)/01_tosa.mlir`: From pytorch model, create tosa mlir. Tensor
  Operator Set Architecture. Done by running Python on the script that
  contains the model and using torch_mlir to compile the model with tosa
  dialect.
- `$(ODIR)/02_linalg.mlir`: Lower the tosa dialect to linalg dialect using
  `tosa_to_linalg.sh` script provided by soda-opt, which invokes an `mlir-opt`
  pass. Creates linalg mlir with tensors and then removes tensors.
- `$(ODIR)/03-[01]{02}(03)_linalg_[searched]{outlined}(isolated).mlir`:
  Use soda-opt to outline and isolate operations. "Searched" has calls to
  `soda.launch`. "Outlined" has a `soda.module` for the kernel. "Isolated"
  contains only the isolated kernel.
- `$(ODIR)/04_llvm_baseline.mlir`: Lower the isolated kernel to llvm IR.
- `$(ODIR)/05_llvm_baseline.ll`: Translate mlir to llvm ir.
- `synth-baseline`: Create verilog for the kernel using bambu.
- `synth-optimized`:
