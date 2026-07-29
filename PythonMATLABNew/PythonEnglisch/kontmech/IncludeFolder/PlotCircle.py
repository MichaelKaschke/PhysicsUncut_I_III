# -------------------------------------------------------------------------
# PlotCircle.py
# -------------------------------------------------------------------------
# Python program for the chapter Celestial Mechanics from
# "Fingerübungen der Physik" by Michael Kaschke and Holger Cartarius
# with the collaboration of Ulrich Potthoff
# All rights with the authors
# Free use allowed with the book and/or citation of the source.
# -------------------------------------------------------------------------
# Helper function for drawing a circle
# -------------------------------------------------------------------------

import numpy as np
import matplotlib.pyplot as plt


def PlotCircle(xM, yM, rC, Col, LW):
    """
    Draw a circle centered at (xM, yM) with radius rC.

    Parameters
    ----------
    xM : float
        x-coordinate of circle center.
    yM : float
        y-coordinate of circle center.
    rC : float
        Circle radius.
    Col : str or tuple
        Line color.
    LW : float
        Line width.
    """

    u = np.linspace(0, 360, 360)

    nx = np.zeros(360)
    ny = np.zeros(360)

    Nmax = round(30 / rC)
    if Nmax > 100:
        Nmax = 100

    for k in range(1, Nmax + 1):
        nx = rC * k * np.cos(np.deg2rad(u)) / Nmax + xM
        ny = rC * k * np.sin(np.deg2rad(u)) / Nmax + yM

        plt.plot(nx, ny, linewidth=LW, color=Col)


# ======================================================================
# Minimal example / test (only executed when running this file directly)
# ======================================================================

if __name__ == "__main__":

    plt.figure(figsize=(6, 6))

    # Test circles with different radii
    PlotCircle(0, 0, 1.0, "blue", 2)
    PlotCircle(1.5, 0.5, 0.5, "red", 2)
    PlotCircle(-1.5, -0.5, 0.75, "green", 2)

    plt.gca().set_aspect("equal")
    plt.xlabel("x")
    plt.ylabel("y")
    plt.title("Test of PlotCircle function")
    plt.grid(True)

    plt.show()