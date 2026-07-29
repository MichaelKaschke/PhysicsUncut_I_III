#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
HarmonicOscillator.py
-------------------------------------------------------------------------
Python program for the chapter "Physics of Motion" from
"Physics Exercises" by Michael Kaschke and Holger Cartarius
with contributions from Ulrich Potthoff
Transformed from MATLAB to Python

Example calculations for the Harmonic Oscillator
a) different dampings (friction coefficients)
b) different excitation frequencies and dampings (friction coefficients)
c) frequency response, phase response and energy transfer during excitation
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

# Parameters
m = 0.2                    # Mass
k = 1                      # Restoring force constant  
q0 = 1.0                   # Displacement at t = 0
qdot0 = 5.0                # Initial velocity
omega0 = np.sqrt(k/m)      # Natural frequency

tmax = 8                   # Maximum time
NPkt = 500                 # Number of points
t = np.linspace(0, tmax, NPkt)  # Time range

print("Harmonic Oscillator Simulation")
print("=" * 40)
print(f"Parameters:")
print(f"Mass m = {m} kg")
print(f"Spring constant k = {k} N/m") 
print(f"Natural frequency ω₀ = {omega0:.3f} rad/s")
print(f"Initial displacement q₀ = {q0} m")
print(f"Initial velocity v₀ = {qdot0} m/s")
print()

# =========================================================================
# Part a) Different damping scenarios
# =========================================================================

print("Part a) Different damping scenarios")
print("-" * 40)

# Case without damping
eta10 = 0.00                              # Friction term 1
B = np.sqrt(q0**2 + qdot0**2/omega0**2)   # Constant B
theta = np.arctan(omega0*q0/qdot0)        # Angle theta
q = B * np.sin(omega0*t + theta)          # Undamped oscillator
print(f"Undamped: B = {B:.3f}, θ = {theta:.3f} rad")

# Case with weak damping
eta11 = 0.05                              # Friction term 1
gamma = eta11/(2*m)                       # Critical parameter gamma
Disc = omega0**2 - gamma**2               # Discriminator: positive here
if Disc <= 0:
    print('No weak damping possible')
    exit()

omega = np.sqrt(Disc)                     # Current frequency
B1 = np.sqrt(q0**2 + (qdot0 + gamma*q0)**2/omega**2)  # Constant B
theta1 = np.arctan(omega*q0/(qdot0 + gamma*q0))       # Angle theta
q1 = B1 * np.exp(-gamma*t) * np.sin(omega*t + theta1) # Weakly damped oscillator
q1e = B1 * np.exp(-gamma*t)               # Envelope
print(f"Weak damping: γ = {gamma:.4f}, ω = {omega:.3f} rad/s")

# Case with strong damping  
eta12 = 1.2                               # Friction term 1
fac = eta12/(2*m)
gamma1 = fac - np.sqrt(fac**2 - k/m)      # Critical parameter gamma1
gamma2 = fac + np.sqrt(fac**2 - k/m)      # Critical parameter gamma2
Disc = fac**2 - k/m                       # Discriminator: positive here
if Disc <= 0:
    print('No strong damping possible')
    exit()

A = q0 - (qdot0 + gamma1*q0)/(gamma1 - gamma2)    # Constant A
B2 = (qdot0 + gamma1*q0)/(gamma1 - gamma2)        # Constant B
q2 = A * np.exp(-gamma1*t) + B2 * np.exp(-gamma2*t)  # Strongly damped oscillator
print(f"Strong damping: γ₁ = {gamma1:.3f}, γ₂ = {gamma2:.3f}")

# Case with critical damping
eta13 = 2*m*omega0                        # Friction term 1
gamma_crit = eta13/(2*m)                  # Critical parameter gamma
A3 = q0                                   # Constant A
B3 = qdot0 + gamma_crit*q0                # Constant B  
q3 = A3 * np.exp(-gamma_crit*t) + B3 * t * np.exp(-gamma_crit*t)  # Critically damped oscillator
print(f"Critical damping: γ_crit = {gamma_crit:.3f}")

# Graphics Part a)
plt.figure(figsize=(12, 8))
plt.plot(t, q, color=colors[3], linewidth=2, linestyle=line_styles[0], label='undamped')
plt.plot(t, q1, color=colors[1], linewidth=2, linestyle=line_styles[1], label='weak damping')
plt.plot(t, q1e, color=colors[1], linewidth=1, linestyle=line_styles[0], alpha=0.7, label='envelope')
plt.plot(t, -q1e, color=colors[1], linewidth=1, linestyle=line_styles[0], alpha=0.7)
plt.plot(t, q2, color=colors[2], linewidth=2, linestyle=line_styles[3], label='overdamped')
plt.plot(t, q3, color=colors[4], linewidth=2, linestyle=line_styles[4], label='critically damped')

plt.ylabel('Displacement q in m', fontsize=14)
plt.xlabel('Time t in s', fontsize=14)
plt.title('Harmonic Oscillator - Different Damping Types', fontsize=16)
plt.legend(loc='upper right', bbox_to_anchor=(1, 0.95), ncol=2)
plt.axis([0, 8, -4, 4])
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()

# =========================================================================
# Part b) Variable excitation frequency and friction
# =========================================================================

print("\nPart b) Variable excitation")
print("-" * 40)

# Variable excitation frequency
omegaD = omega0 * np.array([0.5, 0.9, 1.1, 1.5])  # Excitation frequency
eta = np.array([0.01, 0.05, 0.25, 0.75])          # Friction coefficient
FA = 0.5                                           # Excitation amplitude
phiA = 0                                           # Excitation phase

tmax = 50                                          # Maximum time
NPkt = 500                                         # Number of points
t = np.linspace(0, tmax, NPkt)                     # Time range

q_results = np.zeros((4, NPkt))
titles = []

print("Variable excitation frequency (fixed damping):")

for index in range(4):
    indexo = index
    indexe = 1  # Index 2 in MATLAB corresponds to index 1 in Python
    omegaA = omegaD[indexo]
    gamma = eta[indexe]/(2*m)                      # Critical parameter gamma
    Disc = (2*gamma*omegaA)**2 + (omega0**2 - omegaA**2)**2
    A = FA/m/np.sqrt(Disc)                         # Amplitude due to excitation
    NN = omega0**2 - omegaA**2                     # Denominator
    if NN == 0:
        NN = 1e-4
    
    if omegaA <= omega0:
        phi = np.arctan(2*gamma*omegaA/NN)         # Phase between excitation and osc.
    else:
        phi = np.pi + np.arctan(2*gamma*omegaA/NN)  # Phase shift by pi when omegaA > omega0
    
    delta = theta - phi                            # Phase of solution
    qp = A * np.cos(omegaA*t + delta)              # Particular solution of inhomogeneous ODE
    
    Disc = omega0**2 - gamma**2                    # Positive for weak damping
    if Disc <= 0:
        print('Too strong damping')
        continue
    
    omega1 = np.sqrt(Disc)
    theta_temp = np.arctan(omega1*q0/(qdot0 + gamma*q0))      # Angle theta
    B_temp = np.sqrt(q0**2 + (qdot0 + gamma*q0)**2/omega1**2) # Constant B
    qh = B_temp * np.exp(-gamma*t) * np.sin(omega1*t + theta_temp)  # Solution of homogeneous ODE
    q_results[index, :] = qp + qh
    
    titles.append(f'γ = {gamma:.3f}, ωₐ/ω₀ = {omegaA/omega0:.1f}')
    print(f"  Index {index+1}: γ = {gamma:.4f}, ωₐ/ω₀ = {omegaA/omega0:.1f}")

# Plot for variable excitation frequency
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

plt.suptitle('Variable Excitation Frequency', fontsize=16)
plt.tight_layout()
plt.show()

# Variable friction (fixed excitation frequency)
print("\nVariable friction (fixed excitation frequency):")

for index in range(4):
    indexo = 1  # Index 2 in MATLAB corresponds to index 1 in Python  
    indexe = index
    omegaA = omegaD[indexo]
    gamma = eta[indexe]/(2*m)                      # Critical parameter gamma
    Disc = (2*gamma*omegaA)**2 + (omega0**2 - omegaA**2)**2
    A = FA/m/np.sqrt(Disc)                         # Amplitude due to excitation
    NN = omega0**2 - omegaA**2                     # Denominator
    if NN == 0:
        NN = 1e-4
    
    if omegaA <= omega0:
        phi = np.arctan(2*gamma*omegaA/NN)         # Phase between excitation and osc.
    else:
        phi = np.pi + np.arctan(2*gamma*omegaA/NN)  # Phase shift by pi when omegaA > omega0
    
    delta = theta - phi                            # Phase of solution
    qp = A * np.cos(omegaA*t + delta)              # Particular solution of inhomogeneous ODE
    
    Disc = omega0**2 - gamma**2                    # Positive for weak damping
    if Disc <= 0:
        print('Too strong damping')
        continue
    
    omega1 = np.sqrt(Disc)
    theta_temp = np.arctan(omega1*q0/(qdot0 + gamma*q0))      # Angle theta
    B_temp = np.sqrt(q0**2 + (qdot0 + gamma*q0)**2/omega1**2) # Constant B
    qh = B_temp * np.exp(-gamma*t) * np.sin(omega1*t + theta_temp)  # Solution of homogeneous ODE
    q_results[index, :] = qp + qh
    
    titles[index] = f'γ = {gamma:.3f}, ωₐ/ω₀ = {omegaA/omega0:.1f}'
    print(f"  Index {index+1}: γ = {gamma:.4f}, ωₐ/ω₀ = {omegaA/omega0:.1f}")

# Plot for variable friction
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

plt.suptitle('Variable Friction', fontsize=16)
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
