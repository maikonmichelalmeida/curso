// Filelist do Lab 03 para simulacao RTL com VCS.
//
// Ordem escolhida:
//   1. testbench primeiro, para ficar claro qual e o top de simulacao;
//   2. mini_datapath depois;
//   3. dependencias instanciadas pelo mini_datapath.
//
// O VCS aceita essa ordem porque elabora o design depois de ler os arquivos.

../tb/tb_mini_datapath.sv
../rtl/mini_datapath.sv
../rtl/regbank.sv
../rtl/alu.sv
