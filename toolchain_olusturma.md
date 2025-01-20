```shell
git clone https://github.com/riscv-collab/riscv-gnu-toolchain
cd riscv-gnu-toolchain
./configure --prefix=$RISCV --enable-multilib --with-multilib-generator='rv32e-ilp32e--;rv32ea-ilp32e--;rv32em-ilp32e--;rv32eac-ilp32e--;rv32emac-ilp32e--;rv32i-ilp32--;rv32if-ilp32f--;rv32ifd-ilp32d--;rv32ia-ilp32--;rv32iaf-ilp32f--;rv32imaf-ilp32f--;rv32iafd-ilp32d--;rv32im-ilp32--;rv32imf-ilp32f--;rv32imfc-ilp32f--;rv32imfd-ilp32d--;rv32iac-ilp32--;rv32imac-ilp32--;rv32imafc-ilp32f--;rv32imafdc-ilp32d--;rv64i-lp64--;rv64if-lp64f--;rv64ifd-lp64d--;rv64ia-lp64--;rv64iaf-lp64f--;rv64imaf-lp64f--;rv64iafd-lp64d--;rv64im-lp64--;rv64imf-lp64f--;rv64imfc-lp64f--;rv64imfd-lp64d--;rv64iac-lp64--;rv64imac-lp64--;rv64imafc-lp64f--;rv64imafdc-lp64d--;rv64imafdc_zifencei-lp64d--;'
make
make linux
```
