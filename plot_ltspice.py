import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

B, R, G, P = "#1f4e9c", "#c0392b", "#2e8b57", "#8e44ad"

# ===================================================== 1. ideal vs MOSFET, 12 V
# Efficiency (%) excluding gate drive. L = 100 uH, C = 1 uF, 250 kHz unless swept.
duty   = [0.3, 0.5, 0.7]
eff_d  = {"ideal": [93.630, 97.093, 98.636], "MOSFET": [93.054, 96.715, 98.359]}
fsw    = [100, 250, 500]
eff_f  = {"ideal": [97.376, 97.093, 96.867], "MOSFET": [96.974, 96.715, 96.212]}
RLs    = [10, 20, 40]
eff_r  = {"ideal": [96.536, 96.921, 97.093], "MOSFET": [96.145, 96.608, 96.715]}

fig, ax = plt.subplots(1, 3, figsize=(12, 3.8), dpi=150)
for a, x, d, xl in [(ax[0], duty, eff_d, "Duty cycle D"),
                    (ax[1], fsw, eff_f, "Switching frequency (kHz)"),
                    (ax[2], RLs, eff_r, "Load resistance (ohm)")]:
    a.plot(x, d["ideal"], "o--", color=B, label="Ideal switch")
    a.plot(x, d["MOSFET"], "s-", color=R, label="IRF530 + 1N5819")
    a.set_xlabel(xl); a.set_ylabel("Efficiency (%)"); a.grid(alpha=.3); a.legend(fontsize=8)
ax[0].set_title("vs duty cycle", fontsize=10)
ax[1].set_title("vs frequency: falls as fsw rises", fontsize=10)
ax[2].set_title("vs load: falls at heavier load", fontsize=10)
fig.suptitle("Buck converter, 12 V in: efficiency, ideal vs real switch", fontsize=11)
fig.tight_layout(); fig.savefig("ltspice1_efficiency_ideal_vs_mosfet.png"); plt.close(fig)

# ============================================================ 2. Vin sweep
Vin    = np.array([6, 9, 12, 15, 18, 21, 24])
Pout_i = np.array([0.2051, 0.4746, 0.856, 1.3494, 1.955, 2.6728, 3.5032])
Pout_m = np.array([0.2138, 0.491, 0.8818, 1.3861, 2.0037, 2.7346, 3.5784])
eff_i  = np.array([94.943, 96.359, 97.093, 97.546, 97.884, 98.094, 98.309])
eff_m  = np.array([95.132, 96.141, 96.715, 97.099, 97.359, 97.593, 97.740])
n = np.polyfit(np.log(Vin), np.log(Pout_m), 1)[0]
fig, ax = plt.subplots(1, 2, figsize=(10, 3.9), dpi=150)
ax[0].loglog(Vin, Pout_i, "o--", color=B, label="Ideal switch")
ax[0].loglog(Vin, Pout_m, "s-", color=R, label=f"MOSFET (slope {n:.2f})")
ax[0].loglog(Vin, Pout_m[2] * (Vin / 12) ** 2, "k:", lw=1, label="Vin$^2$ reference")
ax[0].set_xlabel("Vin (V)"); ax[0].set_ylabel("Pout (W)"); ax[0].set_title("Pout is proportional to Vin$^2$", fontsize=10)
ax[1].plot(Vin, eff_i, "o--", color=B, label="Ideal switch")
ax[1].plot(Vin, eff_m, "s-", color=R, label="MOSFET")
ax[1].set_xlabel("Vin (V)"); ax[1].set_ylabel("Efficiency (%)"); ax[1].set_title("Efficiency vs input voltage", fontsize=10)
for a in ax: a.grid(alpha=.3, which="both"); a.legend(fontsize=8)
fig.tight_layout(); fig.savefig("ltspice2_vin_sweep.png"); plt.close(fig)

# ===================================== 3. loss breakdown with Rg = 10 ohm (mW)
# order: Pfet, Pdiode, Pgate
loss_f = {"100 kHz": (5.164, 23.212, 15.434), "250 kHz": (11.109, 22.514, 39.993),
          "500 kHz": (21.767, 22.243, 80.052)}
loss_v = {"6 V": (1.648, 9.995, 35.408), "9 V": (5.435, 16.094, 37.542),
          "12 V": (11.109, 22.514, 39.993), "15 V": (18.199, 29.130, 41.962),
          "18 V": (27.019, 35.956, 44.056), "21 V": (37.333, 42.966, 46.137),
          "24 V": (49.444, 50.082, 48.138)}
fig, ax = plt.subplots(1, 2, figsize=(11, 4), dpi=150)
for a, d, t in [(ax[0], loss_f, "vs frequency (12 V, 40 ohm)"), (ax[1], loss_v, "vs input voltage (250 kHz, 40 ohm)")]:
    names = list(d); arr = np.array(list(d.values())).T
    bottom = np.zeros(len(names))
    for row, lab, c in zip(arr, ["MOSFET", "Diode", "Gate drive"], [B, G, R]):
        a.bar(names, row, bottom=bottom, label=lab, color=c); bottom += row
    a.set_ylabel("Loss (mW)"); a.set_title("Loss breakdown " + t, fontsize=10); a.legend(fontsize=8); a.grid(alpha=.3, axis="y")
fig.tight_layout(); fig.savefig("ltspice3_loss_breakdown_Rg10.png"); plt.close(fig)

# ===================================================== 4. 6 V degradation study
C_uF  = np.array([1.0, 0.5, 0.2, 0.1]); ESR = [0.1, 0.2, 0.5, 1.0]
pp_C  = np.array([60.8, 121.4, 308.2, 595.5])                  # mV
L_uH  = np.array([100, 80, 50, 20])
vo_L  = np.array([5.951, 5.9433, 5.9262, 7.2249]); pp_L = np.array([60.8, 77.0, 121.9, 257.9])
D_rec = np.array([0.339, 0.34, 0.36, 0.38]); vo_rec = np.array([5.951, 5.969, 6.3062, 6.5606])
fig, ax = plt.subplots(1, 3, figsize=(13, 3.9), dpi=150)
ax[0].loglog(C_uF, pp_C, "o-", color=R); ax[0].invert_xaxis()
ax[0].set_xlabel("C (uF), with ESR rising 0.1 to 1 ohm"); ax[0].set_ylabel("Vout ripple p-p (mV)")
ax[0].set_title("Capacitor degradation", fontsize=10)
ax[1].plot(L_uH, vo_L, "o-", color=R); ax[1].axhline(5.951, color="k", ls="--", lw=1)
ax[1].axvline(73, color="gray", ls=":"); ax[1].invert_xaxis()
ax[1].set_xlabel("L (uH)"); ax[1].set_ylabel("Average Vout (V)")
ax[1].set_title("Inductor degradation: DCM raises Vout", fontsize=10)
ax[2].plot(D_rec, vo_rec, "o-", color=G); ax[2].axhline(5.951, color="k", ls="--", lw=1, label="healthy 5.951 V")
ax[2].set_xlabel("Duty cycle D (L = 20 uH)"); ax[2].set_ylabel("Average Vout (V)")
ax[2].set_title("Recovery: D = 0.339 restores Vout", fontsize=10); ax[2].legend(fontsize=8)
for a in ax: a.grid(alpha=.3, which="both")
fig.suptitle("Buck converter at 6 V out (12 V in): degradation and recovery", fontsize=11)
fig.tight_layout(); fig.savefig("ltspice4_degradation_6V.png"); plt.close(fig)

# ================================================ 5. buck at 1.2 V, seven loads
RL   = np.array([10, 20, 40, 100, 200, 400, 1000])
Fosc = np.array([250, 250, 250, 250, 250, 85, 27])             # kHz
Vout = np.array([1.2061, 1.2014, 1.2024, 1.2030, 1.2112, 1.2057, 1.1991])
pp   = np.array([26.6, 26.4, 26.2, 21.7, 15.1, 30.1, 44.0])    # mV
Pout = Vout ** 2 / RL * 1000                                    # mW
eta  = np.array([77.72, 77.04, 74.65, 65.29, 55.51, 59.39, 62.82])
etat = np.array([64.05, 53.97, 40.92, 23.86, 30.08, 33.53, 22.36])
Pg   = np.array([39.95, 40.04, 39.90, 38.49, 11.17, 4.72, 4.14])
fig, ax = plt.subplots(2, 2, figsize=(11, 8), dpi=150)
a = ax[0, 0]; a.semilogx(RL, eta, "o-", color=B, label="efficiency, gate excluded")
a.semilogx(RL, etat, "s-", color=R, label="efficiency, gate included")
a.axvspan(70, 2000, color="0.92", zorder=0)
a.set_xlabel("Load R (ohm)"); a.set_ylabel("Efficiency (%)"); a.set_title("Efficiency at Vout of about 1.2 V"); a.legend()
a = ax[0, 1]; a.loglog(RL, Pout, "o-", color=G)
a.set_xlabel("Load R (ohm)"); a.set_ylabel("Pout (mW)"); a.set_title("Delivered power, Vout$^2$/RL")
a = ax[1, 0]; rip = 100 * pp / 1000 / Vout; a.semilogx(RL, rip, "o-", color=R)
for x, y, f in zip(RL, rip, Fosc):
    a.annotate(f"{f} kHz", (x, y), textcoords="offset points", xytext=(0, 6), ha="center", fontsize=7)
a.set_xlabel("Load R (ohm)"); a.set_ylabel("Ripple (% of Vout)"); a.set_title("Output ripple (oscillator frequency annotated)")
a = ax[1, 1]; a.semilogx(RL, Pg, "o-", color=P)
a.set_xlabel("Load R (ohm)"); a.set_ylabel("Gate-drive power (mW)"); a.set_title("Gate power falls at narrow pulses and low fsw")
for a in ax.flat: a.grid(alpha=.3, which="both")
fig.suptitle("Buck converter at 1.2 V (12 V in, L = 100 uH, C = 1 uF). Grey: DCM, pulse-limited. "
             "400 and 1000 ohm at reduced oscillator frequency", fontsize=9)
fig.tight_layout(); fig.savefig("ltspice5_buck_1p2V_seven_loads.png"); plt.close(fig)
print("Vin-sweep Pout slope:", round(float(n), 2))
