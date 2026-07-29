import matplotlib.pyplot as plt

# Parameter
a = -0.6
b = 1
x0 = 1
n = 50

# Initialisierung der Liste
x = [x0]

# Iteration der Differenzengleichung
for k in range(n):
    x.append(a * x[k] + b)

# Plot
plt.figure()
plt.plot(x, '.-')
plt.xlabel('Schritt k')
plt.title('Differenzengleichung')
plt.grid(True)
plt.show()

