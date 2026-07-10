// ============================================================================
// Filelist do teste geral do top
// ============================================================================
//
// Este arquivo e lido pelo VCS quando voce roda:
//
//   make test TEST=top
//
// Aqui o testbench vem primeiro, mas o top precisa de todos os modulos abaixo.
// Essa lista mostra a primeira ideia de integracao: o top conecta varios blocos
// que antes foram testados separadamente.

../tb/tb_top.sv

// Modulos usados pelo top.
../rtl/mux.sv
../rtl/regbank.sv
../rtl/alu.sv
../rtl/memory.sv
../rtl/control.sv
../rtl/top.sv
