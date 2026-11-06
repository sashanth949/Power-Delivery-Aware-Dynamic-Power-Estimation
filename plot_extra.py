import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

# ------------------------------------------------ buck at 1.2 V (LTspice, 12 V in)
RL    = np.array([10, 20, 40, 100, 200, 400, 1000])           # ohm
eta   = np.array([77.7235, 77.0424, 74.6482, 65.2931, 55.513, 59.394, 62.8246])   # %
eta_t = np.array([64.0518, 53.9716, 40.9239, 23.8618, 30.0788, 33.5286, 22.3565]) # % incl. gate

# ------------------------------------------------ digital blocks (1.0 V, 100 MHz)
blocks = {            # name: (P0 mW, cycles per product, Fmax MHz)
    "Braun":   (3.625,  1, 272.7),
    "Wallace": (3.625,  1, 293.2),
    "Booth":   (0.94,  10, 255.7),
    "ALU":     (3.0625, 1, 180.9),
    "MAC":     (4.5,    1, 227.2),
}
COL = {"Braun": "#1f77b4", "Wallace": "#2ca02c", "Booth": "#d62728",
       "ALU": "#9467bd", "MAC": "#8c564b"}
Vdd, T_ns = 1.2, 10.0                                          # V, clock period at 100 MHz

# ============================================ 1. digital summary bars
names = ["Braun", "Wallace", "Wallace\n(rst_n)", "Booth", "ALU", "MAC"]
fmax  = [272.7, 293.2, 298.9, 255.7, 180.9, 227.2]
power = [3.625, 3.625, 3.625, 0.938, 3.062, 4.5]
energy = [36.25, 36.25, 36.25, 93.75, 30.6, 45.0]
cols  = ["#1f77b4", "#2ca02c", "#98df8a", "#d62728", "#9467bd", "#8c564b"]
fig, ax = plt.subplots(1, 3, figsize=(13, 4), dpi=150)
for a, v, t, yl in zip(ax, [fmax, power, energy],
                       ["Fmax (register to register)", "Dynamic power per block (1.0 V, 100 MHz)",
                        "Energy per operation (1.0 V)"], ["MHz", "mW", "pJ"]):
    bars = a.bar(names, v, color=cols)
    a.set_title(t, fontsize=10); a.set_ylabel(yl); a.grid(alpha=.3, axis="y")
    for r, x in zip(bars, v):
        a.text(r.get_x() + r.get_width() / 2, x, f"{x:.1f}" if x > 10 else f"{x:.2f}",
               ha="center", va="bottom", fontsize=8)
    a.tick_params(axis="x", labelsize=8)
fig.tight_layout(); fig.savefig("extra1_digital_summary.png"); plt.close(fig)

# ============================================ 2. bridge results
rows = {}
for n, (P0, cpp, fmax_) in blocks.items():
    P = P0 * (Vdd / 1.0) ** 2                                  # mW at 1.2 V
    Req = Vdd ** 2 / (P * 1e-3)                                # ohm
    e  = np.interp(np.log(Req), np.log(RL), eta) / 100
    et = np.interp(np.log(Req), np.log(RL), eta_t) / 100
    E = P * 1e-3 * cpp * T_ns * 1e-9 * 1e12                    # pJ per product
    rows[n] = dict(P=P, Req=Req, eta=e, eta_t=et, E=E, Es=E / e, Est=E / et)

fig, ax = plt.subplots(1, 2, figsize=(11, 4), dpi=150)
ax[0].semilogx(RL, eta, "o-", label="efficiency, gate excluded")
ax[0].semilogx(RL, eta_t, "s-", label="efficiency, gate included")
for n, r in rows.items():
    if n == "Wallace":                      # same R_eq as Braun: one line, one label
        continue
    lab = "Braun/Wallace" if n == "Braun" else n
    ax[0].axvline(r["Req"], color=COL[n], ls=":", lw=1.2)
    ax[0].text(r["Req"] * 0.97, 83, lab, rotation=90, fontsize=7, ha="right", va="top", color=COL[n])
ax[0].set_xlabel("Load R (ohm) at Vout of about 1.2 V"); ax[0].set_ylabel("Buck efficiency (%)")
ax[0].set_title("Buck efficiency vs load (dotted: each block's R_eq)", fontsize=10)
ax[0].set_ylim(15, 85); ax[0].legend(fontsize=8); ax[0].grid(alpha=.3)
x = np.arange(len(rows)); w = 0.27
ax[1].bar(x - w, [r["E"] for r in rows.values()], w, label="digital only", color="#999")
ax[1].bar(x,     [r["Es"] for r in rows.values()], w, label="system, efficiency", color="#4c78a8")
ax[1].bar(x + w, [r["Est"] for r in rows.values()], w, label="system, efficiency incl. gate", color="#f58518")
ax[1].set_xticks(x); ax[1].set_xticklabels(list(rows)); ax[1].set_ylabel("Energy per product (pJ)")
ax[1].set_title("Energy per 8x8 product at Vdd = 1.2 V", fontsize=10)
ax[1].legend(fontsize=8); ax[1].grid(alpha=.3, axis="y")
fig.tight_layout(); fig.savefig("extra2_bridge_results.png"); plt.close(fig)

print(f"{'block':8s} {'Req(ohm)':>9s} {'eta%':>6s} {'eta_t%':>7s} {'E_dig':>7s} {'E_sys':>7s} {'E_sys_t':>8s}")
for n, r in rows.items():
    print(f"{n:8s} {r['Req']:9.1f} {100*r['eta']:6.1f} {100*r['eta_t']:7.1f} "
          f"{r['E']:7.1f} {r['Es']:7.1f} {r['Est']:8.1f}")
