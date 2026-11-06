import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

N = 16
ERR = 0.19                       # mW, rounding uncertainty per block

def block(design, baseline):     # (clocks, slice, signals) tuples -> mW
    return (sum(design) - sum(baseline)) / N

# ---------------------------------------------------------------- data
# Power vs frequency at 1.0 V (50 and 200 MHz from this work, 100 MHz from
# the earlier summary table).
f = np.array([50, 100, 200])
base50, base200 = (2, 2, 3), (6, 7, 11)
P_f = {
    "Wallace (rst)": [block((5, 15, 13), base50), 3.625, block((22, 58, 54), base200)],
    "Braun":         [block((6, 15, 13), base50), 3.625, block((24, 60, 53), base200)],
    "Booth":         [block((3, 5, 6),   base50), 0.94,  block((11, 20, 26), base200)],
}

# Power vs voltage (VCCINT 0.95, 1.0, 1.05 V). Multipliers at 200 MHz with the
# bench_base_x baseline; ALU at 125 MHz with bench_alubase_x; MAC at 200 MHz.
V = np.array([0.95, 1.0, 1.05])
base_v   = [(6, 6, 10), (6, 7, 11), (7, 7, 12)]
base_alu = [(5, 5, 10), (6, 6, 11), (7, 6, 12)]
des = {
    "Wallace (rst), 200 MHz": ([(20, 53, 49), (22, 58, 54), (25, 64, 60)], base_v),
    "Braun, 200 MHz":         ([(22, 54, 48), (24, 60, 53), (27, 66, 59)], base_v),
    "Booth, 200 MHz":         ([(10, 18, 23), (11, 20, 26), (12, 22, 29)], base_v),
    "ALU, 125 MHz":           ([(11, 30, 31), (12, 33, 35), (13, 37, 38)], base_alu),
    "MAC, 200 MHz":           ([(23, 71, 56), (26, 79, 62), (29, 87, 68)], base_v),
}
P_v = {k: [block(d, b) for d, b in zip(*v)] for k, v in des.items()}

# Power vs activity (Braun and Wallace, 100 MHz, 1.0 V). Activity 1 = new
# operands every cycle (HOLD 0); 0.25 = every fourth cycle (HOLD 3).
base_h3 = (3, 2, 5)
act = np.array([0.25, 1.0])
P_act = {
    "Braun":         [block((12, 9, 10), base_h3), 3.625],
    "Wallace (rst)": [block((12, 10, 11), base_h3), 3.625],
}

# Buck converter at 1.2 V (LTspice): Run A capacitor, Run B inductor, Run C recovery.
C_uF   = np.array([0.1, 0.2, 0.5, 1.0])
ripple_A = np.array([21.3, 10.8, 4.3, 2.2])          # % of Vout
vout_A   = np.array([1.1957, 1.1996, 1.2016, 1.2024])
L_uH   = np.array([20, 50, 80, 100])
vout_B   = np.array([1.956, 1.457, 1.183, 1.202])    # D = 0.085, no retune
ripple_B = np.array([5.84, 3.70, 2.71, 2.18])
vout_C   = {20: 1.20205, 50: 1.19758}                # after duty-cycle retune
P0 = 3.625                                           # mW, Braun/Wallace at 1.0 V, 100 MHz

STYLE = dict(figsize=(6.2, 4.2), dpi=150)
COL = ["#1f4e9c", "#c0392b", "#2e8b57", "#8e44ad", "#d68910"]

def finish(ax, title, xl, yl, name, legend=True):
    ax.set_title(title, fontsize=10); ax.set_xlabel(xl); ax.set_ylabel(yl)
    ax.grid(alpha=0.3)
    if legend: ax.legend(fontsize=8)
    ax.figure.tight_layout(); ax.figure.savefig(name); plt.close(ax.figure)

# ---------------------------------------------------- 1 power vs frequency
fig, ax = plt.subplots(**STYLE)
for (name, p), c in zip(P_f.items(), COL):
    p = np.array(p)
    k, b = np.polyfit(f, p, 1)
    r2 = np.corrcoef(f, p)[0, 1] ** 2
    ax.errorbar(f, p, yerr=ERR, fmt="o", color=c, capsize=3,
                label=f"{name}: {k*1000:.1f} uW/MHz, R2={r2:.3f}")
    ax.plot([0, 210], [b, b + k * 210], "--", color=c, alpha=0.5)
ax.set_xlim(0, 210); ax.set_ylim(bottom=0)
finish(ax, "Dynamic power vs frequency (1.0 V)", "Frequency (MHz)",
       "Block power (mW)", "fig1_power_vs_frequency.png")

# ------------------------------------------------------ 2 power vs voltage
fig, ax = plt.subplots(**STYLE)
for (name, p), c in zip(P_v.items(), COL):
    p = np.array(p)
    n = np.log(p[2] / p[0]) / np.log(V[2] / V[0])
    ax.plot(V, p / p[1], "o-", color=c, label=f"{name}: n = {n:.2f}")
vv = np.linspace(0.94, 1.06, 50)
ax.plot(vv, vv ** 2, "k--", lw=1, label="V$^2$ reference")
finish(ax, "Power vs voltage, normalised to 1.0 V (Vivado estimate)",
       "VCCINT (V)", "P / P(1.0 V)", "fig2_power_vs_voltage.png")

# ------------------------------------------------------ 3 power vs activity
fig, ax = plt.subplots(**STYLE)
for (name, p), c in zip(P_act.items(), COL):
    p = np.array(p); k = (p[1] - p[0]) / 0.75; b = p[1] - k
    ax.errorbar(act, p, yerr=ERR, fmt="o", color=c, capsize=3,
                label=f"{name}: {k:.2f}*a + {b:.2f} mW")
    ax.plot([0, 1.05], [b, b + k * 1.05], "--", color=c, alpha=0.5)
ax.set_xlim(0, 1.1); ax.set_ylim(0, 4.2)
finish(ax, "Power vs switching activity (100 MHz, 1.0 V)",
       "Relative activity (1 = operands change every cycle)",
       "Block power (mW)", "fig3_power_vs_activity.png")

# --------------------------------------------- 4 Run A: capacitor ripple
fig, ax = plt.subplots(**STYLE)
ax.plot(C_uF, ripple_A, "o-", color=COL[0], label="measured ripple")
ax.plot(C_uF, ripple_A[-1] / C_uF, "k--", lw=1, label="1/C trend")
ax.set_xscale("log"); ax.set_yscale("log")
finish(ax, "Run A: output ripple vs capacitor (L = 100 uH)", "C (uF)",
       "Ripple (% of Vout)", "fig4_runA_capacitor.png")

# ----------------------------------- 5 Run B and C: inductor, DCM, recovery
fig, ax = plt.subplots(**STYLE)
ax.plot(L_uH, vout_B, "o-", color=COL[1], label="D = 0.085 (no retune)")
ax.plot(list(vout_C), list(vout_C.values()), "s", color=COL[2], ms=8,
        label="after duty-cycle retune")
ax.axhline(1.2, color="k", ls="--", lw=1, label="target 1.2 V")
ax.axvline(73, color="gray", ls=":", label="critical L about 73 uH")
finish(ax, "Runs B and C: output voltage vs inductor", "L (uH)",
       "Average Vout (V)", "fig5_runBC_inductor.png")

# -------------------- 6 effect on digital supply power (P = P0 * V^2)
cases = [("healthy\n100 uH", 1.20236), ("C = 0.1 uF", vout_A[0]),
         ("L = 80 uH", vout_B[2]), ("L = 50 uH\nno retune", vout_B[1]),
         ("L = 20 uH\nno retune", vout_B[0]),
         ("50 uH\nretuned", vout_C[50]), ("20 uH\nretuned", vout_C[20])]
labels = [c[0] for c in cases]; pw = [P0 * c[1] ** 2 for c in cases]
fig, ax = plt.subplots(figsize=(7.2, 4.2), dpi=150)
bars = ax.bar(labels, pw, color=[COL[0]] + [COL[1]] * 4 + [COL[2]] * 2)
for b_, p in zip(bars, pw):
    ax.text(b_.get_x() + b_.get_width() / 2, p + 0.2, f"{p:.2f}", ha="center", fontsize=8)
ax.tick_params(axis="x", labelsize=7)
finish(ax, "Digital power on the degraded supply (Braun, 100 MHz)", "",
       "Block power (mW)", "fig6_digital_supply_impact.png", legend=False)

print("Done. Voltage exponents:",
      {k: round(float(np.log(p[2] / p[0]) / np.log(V[2] / V[0])), 2) for k, p in P_v.items()})
