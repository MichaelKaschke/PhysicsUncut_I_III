# --------------------------------------------------------------------------
# HarmonicOscillator.py
# --------------------------------------------------------------------------
# Python program based on the chapter "Physics of Motion" from
# "Fingerübungen der Physik" by Michael Kaschke and Holger Cartarius,
# with contributions from Ulrich Potthoff.
# All rights reserved by the authors.
# Free use is permitted with the book and/or citation of the source.
# --------------------------------------------------------------------------
# Example calculations for the Harmonic Oscillator:
# a) various dampings (friction coefficients)
# b) various excitation frequencies and dampings (friction coefficients)
# c) frequency, phase response, and energy transfer with excitation
# --------------------------------------------------------------------------

import numpy as np
import matplotlib.pyplot as plt

# The original MATLAB code uses custom color and style functions.
# We'll define a simple color palette and styles for this translation.
# You can customize these as needed.
def get_colors():
    """A simple color palette."""
    return plt.cm.viridis(np.linspace(0, 1, 6))

def get_line_styles():
    """A simple list of line styles."""
    return ['-', '-.', ':', '--', ':']

# --- Parameters ---
m = 0.2  # Mass
k = 1.0  # Restoring force constant
q0 = 1.0  # Initial displacement at t = 0
qdot0 = 5.0  # Initial velocity
omega0 = np.sqrt(k / m)  # Natural frequency

t_max = 8.0  # Maximum time
n_points = 500  # Number of points
t = np.linspace(0, t_max, n_points)  # Time domain

# --- Part a) ---

## Undamped case
friction_term_1 = 0.00  # Friction term 1
B = np.sqrt(q0**2 + qdot0**2 / omega0**2)  # Constant B
theta = np.arctan(omega0 * q0 / qdot0)  # Angle theta
q_undamped = B * np.sin(omega0 * t + theta)  # Undamped oscillator

## Weakly damped case
friction_term_2 = 0.05  # Friction term 2
gamma_weak = friction_term_2 / (2 * m)  # Critical parameter gamma
discriminant_weak = omega0**2 - gamma_weak**2  # Discriminant: positive here
if discriminant_weak <= 0:
    print('Not weakly damped.')
    # In a real application, you might raise an error or handle this differently.
    # We'll just continue for the purpose of the plot.
    omega_weak = np.nan # Use NaN to prevent plotting
else:
    omega_weak = np.sqrt(discriminant_weak)  # Current frequency
    B_weak = np.sqrt(q0**2 + (qdot0 + gamma_weak * q0)**2 / omega_weak**2)  # Constant B
    theta_weak = np.arctan(omega_weak * q0 / (qdot0 + gamma_weak * q0))  # Angle theta
    q_weakly_damped = B_weak * np.exp(-gamma_weak * t) * np.sin(omega_weak * t + theta_weak)  # Weakly damped oscillator
    envelope = B_weak * np.exp(-gamma_weak * t)  # Envelope

## Overdamped case
friction_term_3 = 1.2  # Friction term 3
fac = friction_term_3 / (2 * m)
gamma1_over = fac - np.sqrt(fac**2 - k / m)  # Critical parameter gamma1
gamma2_over = fac + np.sqrt(fac**2 - k / m)  # Critical parameter gamma2
discriminant_over = fac**2 - k / m  # Discriminant: positive here
if discriminant_over <= 0:
    print('Not overdamped.')
    # Same as above, handle gracefully for plotting.
    q_overdamped = np.full_like(t, np.nan)
else:
    A_over = q0 - (qdot0 + gamma1_over * q0) / (gamma1_over - gamma2_over)  # Constant A
    B_over = (qdot0 + gamma1_over * q0) / (gamma1_over - gamma2_over)  # Constant B
    q_overdamped = A_over * np.exp(-gamma1_over * t) + B_over * np.exp(-gamma2_over * t)  # Overdamped oscillator

## Critically damped case
friction_term_4 = 2 * m * omega0  # Friction term 4
gamma_crit = friction_term_4 / (2 * m)  # Critical parameter gamma
A_crit = q0  # Constant A
B_crit = (qdot0 + gamma_crit * q0)  # Constant B
# Note: The original MATLAB code used gamma1 and gamma2 here, which seems like a typo.
# It should be gamma_crit, as per the critical damping equation.
q_critically_damped = (A_crit + B_crit * t) * np.exp(-gamma_crit * t)  # Critically damped oscillator

# --- Graphics Part a) ---
colors = get_colors()
styles = get_line_styles()

plt.figure(figsize=(10, 6))
plt.title('Harmonic Oscillator')
plt.plot(t, q_undamped, color=colors[3], linewidth=1, linestyle=styles[0], label='Undamped')
if 'q_weakly_damped' in locals():
    plt.plot(t, q_weakly_damped, color=colors[1], linewidth=1, linestyle=styles[1], label='Weak Damping')
    plt.plot(t, envelope, color=colors[1], linewidth=1, linestyle=styles[0], label='Envelope')
if 'q_overdamped' in locals():
    plt.plot(t, q_overdamped, color=colors[2], linewidth=1, linestyle=styles[3], label='Overdamped')
if 'q_critically_damped' in locals():
    plt.plot(t, q_critically_damped, color=colors[3], linewidth=1, linestyle=styles[4], label='Critically Damped')

plt.ylabel('Displacement $q$ in m', fontsize=14)
plt.xlabel('Time $t$ in s', fontsize=14)
plt.legend(loc='lower center', ncol=2)
plt.grid(True)
plt.xlim(0, 8)
plt.ylim(-4, 4)
plt.gca().tick_params(labelsize=16)
plt.tight_layout()
# plt.show()

# --- Part b) ---

## Variable Excitation Frequency
omega_driving_values = omega0 * np.array([0.5, 0.9, 1.1, 1.5])  # Excitation frequency
eta_values = np.array([0.01, 0.05, 0.25, 0.75])  # Friction coefficient
f_amplitude = 0.5  # Excitation amplitude
phi_excitation = 0  # Excitation phase

t_max_b = 50.0  # Maximum time
n_points_b = 500  # Number of points
t_b = np.linspace(0, t_max_b, n_points_b)  # Time domain

q_b = np.zeros((4, n_points_b))
titles_b = []

# Loop for variable excitation frequency
for index in range(4):
    omega_a = omega_driving_values[index]
    eta_b = eta_values[1]  # Using the second eta value from the array
    gamma_b = eta_b / (2 * m)  # Critical parameter gamma
    
    discriminant_b = (2 * gamma_b * omega_a)**2 + (omega0**2 - omega_a**2)**2
    A_driving = f_amplitude / (m * np.sqrt(discriminant_b))  # Amplitude due to excitation
    
    denominator = (omega0**2 - omega_a**2)
    if np.isclose(denominator, 0):
        denominator = 1e-4  # Avoid division by zero
        
    if omega_a <= omega0:
        phi_phase = np.arctan(2 * gamma_b * omega_a / denominator)  # Phase between excitation and osc.
    else:
        phi_phase = np.pi + np.arctan(2 * gamma_b * omega_a / denominator)  # Shift by pi when omega_a > omega0
        
    delta = theta - phi_phase  # Phase of the solution
    
    # Particular solution of the inhomogeneous differential equation
    q_particular = A_driving * np.cos(omega_a * t_b + delta)
    
    # Solution of the homogeneous differential equation
    discriminant_hom = omega0**2 - gamma_b**2
    if discriminant_hom <= 0:
        print('Damping is too strong for homogeneous solution.')
        # We'll use a placeholder for now
        q_homogeneous = np.full_like(t_b, 0)
    else:
        omega_hom = np.sqrt(discriminant_hom)
        theta_hom = np.arctan(omega_hom * q0 / (qdot0 + gamma_b * q0))  # Angle theta
        B_hom = np.sqrt(q0**2 + (qdot0 + gamma_b * q0)**2 / omega_hom**2)  # Constant B
        q_homogeneous = B_hom * np.exp(-gamma_b * t_b) * np.sin(omega_hom * t_b + theta_hom)
        
    q_b[index, :] = q_particular + q_homogeneous
    titles_b.append(f'$\\gamma = {gamma_b:.3f}$, $\\omega_A/\\omega_0 = {omega_a/omega0:.3f}$')

plt.figure(figsize=(12, 10))
for index in range(4):
    plt.subplot(2, 2, index + 1)
    plt.plot(t_b, q_b[index, :], color=colors[index + 1], linewidth=1, linestyle=styles[0])
    plt.title(titles_b[index], fontsize=12)
    plt.ylabel('q(t) in m')
    plt.xlabel('t in s', fontsize=8)
    plt.grid(True)
    # Set axis limits based on the second plot's data, as in the MATLAB code
    y_min_limit = 1.25 * np.min(q_b[1, :])
    y_max_limit = 1.25 * np.max(q_b[1, :])
    plt.axis([0, t_max_b, y_min_limit, y_max_limit])
    plt.gca().tick_params(labelsize=16)
plt.tight_layout()
# plt.show()

## Variable Damping
q_c = np.zeros((4, n_points_b))
titles_c = []

# Loop for variable damping
for index in range(4):
    omega_a = omega_driving_values[1]  # Using the second omega_A value
    eta_c = eta_values[index]
    gamma_c = eta_c / (2 * m)  # Critical parameter gamma
    
    discriminant_c = (2 * gamma_c * omega_a)**2 + (omega0**2 - omega_a**2)**2
    A_driving_c = f_amplitude / (m * np.sqrt(discriminant_c))  # Amplitude due to excitation
    
    denominator_c = (omega0**2 - omega_a**2)
    if np.isclose(denominator_c, 0):
        denominator_c = 1e-4
        
    if omega_a <= omega0:
        phi_phase_c = np.arctan(2 * gamma_c * omega_a / denominator_c)
    else:
        phi_phase_c = np.pi + np.arctan(2 * gamma_c * omega_a / denominator_c)
        
    delta_c = theta - phi_phase_c
    q_particular_c = A_driving_c * np.cos(omega_a * t_b + delta_c)
    
    discriminant_hom_c = omega0**2 - gamma_c**2
    if discriminant_hom_c <= 0:
        q_homogeneous_c = np.full_like(t_b, 0)
    else:
        omega_hom_c = np.sqrt(discriminant_hom_c)
        theta_hom_c = np.arctan(omega_hom_c * q0 / (qdot0 + gamma_c * q0))
        B_hom_c = np.sqrt(q0**2 + (qdot0 + gamma_c * q0)**2 / omega_hom_c**2)
        q_homogeneous_c = B_hom_c * np.exp(-gamma_c * t_b) * np.sin(omega_hom_c * t_b + theta_hom_c)
    
    q_c[index, :] = q_particular_c + q_homogeneous_c
    titles_c.append(f'$\\gamma = {gamma_c:.3f}$, $\\omega_A/\\omega_0 = {omega_a/omega0:.3f}$')

plt.figure(figsize=(12, 10))
for index in range(4):
    plt.subplot(2, 2, index + 1)
    plt.plot(t_b, q_c[index, :], color=colors[index + 1], linewidth=1, linestyle=styles[0])
    plt.title(titles_c[index], fontsize=12)
    plt.ylabel('q(t) in m')
    plt.xlabel('t in s', fontsize=8)
    plt.grid(True)
    # Set axis limits based on the second plot's data, as in the MATLAB code
    y_min_limit_c = 1.25 * np.min(q_c[1, :])
    y_max_limit_c = 1.25 * np.max(q_c[1, :])
    plt.axis([0, t_max_b, y_min_limit_c, y_max_limit_c])
    plt.gca().tick_params(labelsize=16)
plt.tight_layout()
# plt.show()

# --- Part c) ---

# Variable Excitation Frequency and Damping
omega_min_c = 0.001 * omega0
omega_max_c = 2.5 * omega0
n_points_c = 500
omega_a_c = np.linspace(omega_min_c, omega_max_c, n_points_c)

eta_min_c = 0.02  # Minimum eta
eta_max_c = 2 * m * omega0 / np.sqrt(2)  # Maximum eta
eta_step_c = (eta_max_c - eta_min_c) / 5

# --- Plot 1: Amplitude vs. Frequency ---
plt.figure(figsize=(18, 6))
plt.subplot(1, 3, 1)
j_plot = 0
for eta in np.arange(eta_min_c, eta_max_c + eta_step_c, eta_step_c):
    gamma = eta / (2 * m)  # gamma
    j_plot += 1
    
    discriminant_c_plot = (2 * gamma * omega_a_c)**2 + (omega0**2 - omega_a_c**2)**2
    amplitude = f_amplitude / (m * np.sqrt(discriminant_c_plot))  # Amplitude
    
    plt.semilogy(omega_a_c / omega0, amplitude, color=colors[j_plot], linewidth=1, linestyle=styles[0])
    
    # Resonance frequency and max amplitude
    # The MATLAB code has a typo in the calculation of Amax, it seems to be using omega0 instead of omega_res
    # Let's stick with the formula from the MATLAB code.
    omega_res = np.sqrt(omega0**2 - 2 * gamma**2)
    A_max = f_amplitude / (2 * m * gamma * np.sqrt(omega0**2 - gamma**2))
    
    # Find the amplitude at the resonance frequency to plot the marker
    if omega_res > omega_min_c and omega_res < omega_max_c:
        plt.plot(omega_res / omega0, A_max, marker='+', markersize=8, linewidth=1,
                 color=colors[j_plot], linestyle='')
        plt.text(omega_res / omega0 + 0.01, 1.1 * A_max, f'$\\gamma={gamma:.2f}$',
                 fontsize=10, color=colors[j_plot])

plt.title('Amplitude vs. Excitation Frequency', fontsize=14)
plt.ylabel('Amplitude $A$', fontsize=14)
plt.xlabel('$\\omega_A/\\omega_0$', fontsize=14)
plt.axis([0, 2.5, 0.1, 20])
plt.grid(True)
plt.gca().tick_params(labelsize=16)

# --- Plot 2: Phase Difference ---

