# Power-Delivery-Aware-Dynamic-Power-Estimation
Power-Delivery-Aware Dynamic Power Estimation

Mini project, 21ECE464T. Dynamic power versus voltage, frequency and switching activity for Braun, Wallace and Booth multipliers, an ALU and a MAC (Vivado 2025.2, Artix-7), and a DC-DC buck converter supply (LTspice), linked analytically.

*.v: Verilog designs and testbenches (bench_* are the power benchmarks, tb_bench1.v is the benchmark testbench).
*.asc: LTspice schematics of the buck converter.
plot_all.py, plot_ltspice.py, plot_extra.py: plotting scripts for all figures in the report.
Run with python plot_all.py (needs NumPy and Matplotlib).
