#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
HarmonOszillator.py
-------------------------------------------------------------------------
Python-Programm zum Kapitel "Physik der Bewegung" aus
"Fingerübungen der Physik" von Michael Kaschke und Holger Cartarius
unter Mitwirkung von Ulrich Potthoff
Transformiert von MATLAB nach Python

Beispielberechnungen zum Harmonischen Oszillator
a) verschiedene Dämpfungen (Reibungskoeffizienten)
b) verschiedene Anregungsfrequenzen und Dämpfungen(Reibungskoeffizienten)
c) Frequenz-, Phasengang und Energieübertrag bei Anregung
-------------------------------------------------------------------------
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
import warnings
warnings.filterwarnings('ignore')

# Farben und Stile definieren
colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b']
line_styles = ['-', '-.', ':', '--', ':']

# Parameter
m = 0.2                    # Masse
k = 1                      # rücktreibende Kraftkonstante  
q0 = 1.0                   # Auslenkung t = 0
qdot0 = 5.0                # Anfangsgeschwindigkeit
omega0 = np.sqrt(k/m)      # Eigenfrequenz

tmax = 8                   # Maximalzeit
NPkt = 500                 # Anzahl Punkte
t = np.linspace(0, tmax, NPkt)  # Zeitbereich

print("Harmonischer Oszillator Simulation")
print("=" * 40)
print(f"Parameter:")
print(f"Masse m = {m} kg")
print(f"Federkonstante k = {k} N/m") 
print(f"Eigenfrequenz ω₀ = {omega0:.3f} rad/s")
print(f"Anfangsauslenkung q₀ = {q0} m")
print(f"Anfangsgeschwindigkeit v₀ = {qdot0} m/s")
print()

# =========================================================================
# Teil a) Verschiedene Dämpfungen
# =========================================================================

print("Teil a) Verschiedene Dämpfungsszenarien")
print("-" * 40)

# Fall ohne Dämpfung
eta10 = 0.00                              # Reibungsterm 1
B = np.sqrt(q0**2 + qdot0**2/omega0**2)   # Konstante B
theta = np.arctan(omega0*q0/qdot0)        # Winkel theta
q = B * np.sin(omega0*t + theta)          # Ungedämpfter Oszillator
print(f"Ungedämpft: B = {B:.3f}, θ = {theta:.3f} rad")

# Fall mit schwacher Dämpfung
eta11 = 0.05                              # Reibungsterm 1
gamma = eta11/(2*m)                       # Kritischer Parameter gamma
Disc = omega0**2 - gamma**2               # Diskriminator: hier positiv
if Disc <= 0:
    print('Keine schwache Dämpfung möglich')
    exit()

omega = np.sqrt(Disc)                     # Aktuelle Frequenz
B1 = np.sqrt(q0**2 + (qdot0 + gamma*q0)**2/omega**2)  # Konstante B
theta1 = np.arctan(omega*q0/(qdot0 + gamma*q0))       # Winkel theta
q1 = B1 * np.exp(-gamma*t) * np.sin(omega*t + theta1) # Schwach gedämpfter Oszillator
q1e = B1 * np.exp(-gamma*t)               # Einhüllende
print(f"Schwache Dämpfung: γ = {gamma:.4f}, ω = {omega:.3f} rad/s")

# Fall mit starker Dämpfung  
eta12 = 1.2                               # Reibungsterm 1
fac = eta12/(2*m)
gamma1 = fac - np.sqrt(fac**2 - k/m)      # Kritischer Parameter gamma1
gamma2 = fac + np.sqrt(fac**2 - k/m)      # Kritischer Parameter gamma2
Disc = fac**2 - k/m                       # Diskriminator: hier positiv
if Disc <= 0:
    print('Keine starke Dämpfung möglich')
    exit()

A = q0 - (qdot0 + gamma1*q0)/(gamma1 - gamma2)    # Konstante A
B2 = (qdot0 + gamma1*q0)/(gamma1 - gamma2)        # Konstante B
q2 = A * np.exp(-gamma1*t) + B2 * np.exp(-gamma2*t)  # Stark gedämpfter Oszillator
print(f"Starke Dämpfung: γ₁ = {gamma1:.3f}, γ₂ = {gamma2:.3f}")

# Fall mit kritischer Dämpfung
eta13 = 2*m*omega0                        # Reibungsterm 1
gamma_crit = eta13/(2*m)                  # Kritischer Parameter gamma
A3 = q0                                   # Konstante A
B3 = qdot0 + gamma_crit*q0                # Konstante B  
q3 = A3 * np.exp(-gamma_crit*t) + B3 * t * np.exp(-gamma_crit*t)  # Kritisch gedämpfter Oszillator
print(f"Kritische Dämpfung: γ_crit = {gamma_crit:.3f}")

# Graphik Teil a)
plt.figure(figsize=(12, 8))
plt.plot(t, q, color=colors[3], linewidth=2, linestyle=line_styles[0], label='ungedämpft')
plt.plot(t, q1, color=colors[1], linewidth=2, linestyle=line_styles[1], label='schwache Dämpfung')
plt.plot(t, q1e, color=colors[1], linewidth=1, linestyle=line_styles[0], alpha=0.7, label='Einhüllende')
plt.plot(t, -q1e, color=colors[1], linewidth=1, linestyle=line_styles[0], alpha=0.7)
plt.plot(t, q2, color=colors[2], linewidth=2, linestyle=line_styles[3], label='überkritische Dämpfung')
plt.plot(t, q3, color=colors[4], linewidth=2, linestyle=line_styles[4], label='kritische Dämpfung')

plt.ylabel('Auslenkung q in m', fontsize=14)
plt.xlabel('Zeit t in s', fontsize=14)
plt.title('Harmonischer Oszillator - Verschiedene Dämpfungen', fontsize=16)
plt.legend(loc='upper right', bbox_to_anchor=(1, 0.95), ncol=2)
plt.axis([0, 8, -4, 4])
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()

# =========================================================================
# Teil b) Variable Anregungsfrequenz und Reibung
# =========================================================================

print("\nTeil b) Variable Anregung")
print("-" * 40)

# Variable Anregungsfrequenz
omegaD = omega0 * np.array([0.5, 0.9, 1.1, 1.5])  # Anregungsfrequenz
eta = np.array([0.01, 0.05, 0.25, 0.75])          # Reibungskoeffizient
FA = 0.5                                           # Amplitude der Anregung
phiA = 0                                           # Phase der Anregung

tmax = 50                                          # Maximalzeit
NPkt = 500                                         # Anzahl Punkte
t = np.linspace(0, tmax, NPkt)                     # Zeitbereich

q_results = np.zeros((4, NPkt))
titles = []

print("Variable Anregungsfrequenz (feste Dämpfung):")

for index in range(4):
    indexo = index
    indexe = 1  # Index 2 in MATLAB entspricht Index 1 in Python
    omegaA = omegaD[indexo]
    gamma = eta[indexe]/(2*m)                      # Kritischer Parameter gamma
    Disc = (2*gamma*omegaA)**2 + (omega0**2 - omegaA**2)**2
    A = FA/m/np.sqrt(Disc)                         # Amplitude durch Anregung
    NN = omega0**2 - omegaA**2                     # Nenner
    if NN == 0:
        NN = 1e-4
    
    if omegaA <= omega0:
        phi = np.arctan(2*gamma*omegaA/NN)         # Phase zwischen Anregung und Osz.
    else:
        phi = np.pi + np.arctan(2*gamma*omegaA/NN)  # Shift um pi bei omegaA > omega0
    
    delta = theta - phi                            # Phase der Lösung
    qp = A * np.cos(omegaA*t + delta)              # Spezielle Lösung der inhomogenen DGL
    
    Disc = omega0**2 - gamma**2                    # Positiv für schwache Dämpfung
    if Disc <= 0:
        print('Zu starke Dämpfung')
        continue
    
    omega1 = np.sqrt(Disc)
    theta_temp = np.arctan(omega1*q0/(qdot0 + gamma*q0))      # Winkel theta
    B_temp = np.sqrt(q0**2 + (qdot0 + gamma*q0)**2/omega1**2) # Konstante B
    qh = B_temp * np.exp(-gamma*t) * np.sin(omega1*t + theta_temp)  # Lösung homogene DGL
    q_results[index, :] = qp + qh
    
    titles.append(f'γ = {gamma:.3f}, ωₐ/ω₀ = {omegaA/omega0:.1f}')
    print(f"  Index {index+1}: γ = {gamma:.4f}, ωₐ/ω₀ = {omegaA/omega0:.1f}")

# Plot für variable Anregungsfrequenz
fig, axes = plt.subplots(2, 2, figsize=(15, 10))
axes = axes.flatten()

for index in range(4):
    axes[index].plot(t, q_results[index, :], color=colors[index+1], 
                    linewidth=2, linestyle=line_styles[0])
    axes[index].set_title(titles[index], fontsize=12)
    axes[index].set_ylabel('q(t) in m')
    axes[index].set_xlabel('t in s')
    axes[index].grid(True, alpha=0.3)
    axes[index].set_xlim([0, tmax])

plt.suptitle('Variable Anregungsfrequenz', fontsize=16)
plt.tight_layout()
plt.show()

# Variable Reibung (feste Anregungsfrequenz)
print("\nVariable Reibung (feste Anregungsfrequenz):")

for index in range(4):
    indexo = 1  # Index 2 in MATLAB entspricht Index 1 in Python  
    indexe = index
    omegaA = omegaD[indexo]
    gamma = eta[indexe]/(2*m)                      # Kritischer Parameter gamma
    Disc = (2*gamma*omegaA)**2 + (omega0**2 - omegaA**2)**2
    A = FA/m/np.sqrt(Disc)                         # Amplitude durch Anregung
    NN = omega0**2 - omegaA**2                     # Nenner
    if NN == 0:
        NN = 1e-4
    
    if omegaA <= omega0:
        phi = np.arctan(2*gamma*omegaA/NN)         # Phase zwischen Anregung und Osz.
    else:
        phi = np.pi + np.arctan(2*gamma*omegaA/NN)  # Shift um pi bei omegaA > omega0
    
    delta = theta - phi                            # Phase der Lösung
    qp = A * np.cos(omegaA*t + delta)              # Spezielle Lösung der inhomogenen DGL
    
    Disc = omega0**2 - gamma**2                    # Positiv für schwache Dämpfung
    if Disc <= 0:
        print('Zu starke Dämpfung')
        continue
    
    omega1 = np.sqrt(Disc)
    theta_temp = np.arctan(omega1*q0/(qdot0 + gamma*q0))      # Winkel theta
    B_temp = np.sqrt(q0**2 + (qdot0 + gamma*q0)**2/omega1**2) # Konstante B
    qh = B_temp * np.exp(-gamma*t) * np.sin(omega1*t + theta_temp)  # Lösung homogene DGL
    q_results[index, :] = qp + qh
    
    titles[index] = f'γ = {gamma:.3f}, ωₐ/ω₀ = {omegaA/omega0:.1f}'
    print(f"  Index {index+1}: γ = {gamma:.4f}, ωₐ/ω₀ = {omegaA/omega0:.1f}")

# Plot für variable Reibung
fig, axes = plt.subplots(2, 2, figsize=(15, 10))
axes = axes.flatten()

for index in range(4):
    axes[index].plot(t, q_results[index, :], color=colors[index+1], 
                    linewidth=2, linestyle=line_styles[0])
    axes[index].set_title(titles[index], fontsize=12)
    axes[index].set_ylabel('q(t) in m')
    axes[index].set_xlabel('t in s')
    axes[index].grid(True, alpha=0.3)
    axes[index].set_xlim([0, tmax])

plt.suptitle('Variable Reibung', fontsize=16)
plt.tight_layout()
plt.show()

# =========================================================================
# Teil c) Frequenz-, Phasengang und Energieübertrag
# =========================================================================

print("\nTeil c) Frequenz-, Phasengang und Energieübertrag")
print("-" * 50)

# Variable Anregungsfrequenz für Frequenzgang
omegaMin = 0.001 * omega0
omegaMax = 2.5 * omega0
NPkt = 500
omegaA = np.linspace(omegaMin, omegaMax, NPkt)
etamin = 0.02                               # Minimum eta
etamax = 2*m*omega0/np.sqrt(2)              # Maximum eta  
etastep = (etamax - etamin)/5

print(f"Frequenzbereich: {omegaMin/omega0:.3f} bis {omegaMax/omega0:.1f} × ω₀")
print(f"Dämpfungsbereich: γ von {etamin/(2*m):.4f} bis {etamax/(2*m):.4f}")

fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(18, 6))

jPlot = 0
eta_values = np.arange(etamin, etamax + etastep, etastep)

for eta_val in eta_values:
    gamma = eta_val/(2*m)                   # gamma
    jPlot += 1
    
    Disc = (2*gamma*omegaA)**2 + (omega0**2 - omegaA**2)**2
    A = FA/m/np.sqrt(Disc)                  # Amplitude
    
    # Amplitude Plot
    ax1.semilogy(omegaA/omega0, A, color=colors[jPlot-1], linewidth=2, 
                linestyle=line_styles[0], label=f'γ = {gamma:.3f}')
    
    # Resonanzfrequenz und Maximum
    if omega0**2 - 2*gamma**2 > 0:
        omega_res = np.sqrt(omega0**2 - 2*gamma**2)      # Resonanzfrequenz
        Amax = FA/(2*m*gamma*np.sqrt(omega0**2 - gamma**2))  # Max @ Resonanz
        ax1.plot(omega_res/omega0, Amax, marker='+', markersize=10, 
                color=colors[jPlot-1], markeredgewidth=2)
        ax1.text(omega_res/omega0 + 0.01, 1.1*Amax, f'γ={gamma:.2f}', 
                fontsize=10, color=colors[jPlot-1])
    
    # Phasengang
    NN = omega0**2 - omegaA**2
    phi = np.zeros_like(omegaA)
    
    for i in range(NPkt):
        if omegaA[i] <= omega0:
            phi[i] = np.degrees(np.arctan(2*gamma*omegaA[i]/NN[i]))
        else:
            phi[i] = 180 + np.degrees(np.arctan(2*gamma*omegaA[i]/NN[i]))
    
    ax2.plot(omegaA/omega0, phi, color=colors[jPlot-1], linewidth=2, 
            linestyle=line_styles[0])
    ax2.text(1.05, (1 + 0.1)*phi[100] + 5, f'γ={gamma:.2f}', 
            fontsize=10, color=colors[jPlot-1])
    
    # Leistungstransfer
    Power = 0.5 * FA * A * omegaA * np.sin(np.radians(phi))
    ax3.semilogy(omegaA/omega0, Power, color=colors[jPlot-1], linewidth=2, 
                linestyle=line_styles[0])
    
    max_power_idx = np.argmax(Power)
    max_power = Power[max_power_idx]
    ax3.text(1.05, max_power + 0.02, f'γ={gamma:.2f}', 
            fontsize=10, color=colors[jPlot-1])

# Subplot 1: Amplitude
ax1.set_title('Amplitude über Anregungsfrequenz', fontsize=14)
ax1.set_ylabel('Amplitude A', fontsize=14)
ax1.set_xlabel('ωₐ/ω₀', fontsize=14)
ax1.set_xlim([0, 2.5])
ax1.set_ylim([0.1, 20])
ax1.grid(True, alpha=0.3)

# Subplot 2: Phase
ax2.set_title('Phasendifferenz', fontsize=14)
ax2.set_ylabel('Phase φ [°]', fontsize=14)
ax2.set_xlabel('ωₐ/ω₀', fontsize=14)
ax2.set_xlim([0, 2.5])
ax2.set_ylim([0, 180])
ax2.grid(True, alpha=0.3)

# Subplot 3: Leistung
ax3.set_title('Leistungstransfer', fontsize=14)
ax3.set_ylabel('Leistung P', fontsize=14)
ax3.set_xlabel('ωₐ/ω₀', fontsize=14)
ax3.set_xlim([0, 2.5])
ax3.set_ylim([0.01, 10])
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.show()

print("\nSimulation abgeschlossen!")
print("=" * 40)
