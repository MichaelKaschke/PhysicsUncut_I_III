# MATLAB to Teaching Notebook Conversion Rules

This guide records the conversion style extracted from the sample pair:

- `PythonEnglisch/optbas/sample/PSFFresnel2P.m`
- `PythonEnglisch/optbas/sample/PSFFresnel2P.ipynb`

Use it when translating `MatlabDateien/optbas` MATLAB scripts into teaching-oriented Python notebooks.

## Overall Goal

Do not translate MATLAB line by line mechanically. Convert each script into a readable teaching notebook:

1. Explain the physical problem.
2. Define parameters clearly.
3. Implement the numerical method transparently.
4. Plot the results in notebook-friendly form.
5. Add short interpretation of the output.

The preferred notebook structure is:

1. Title and physical picture.
2. Mathematical model and relevant equations.
3. Imports.
4. Parameters.
5. Helper functions.
6. Main numerical computation.
7. Diagnostic quantities or metrics.
8. 2D plots.
9. Optional interactive 3D plots.
10. Brief physical interpretation.

## Markdown and Teaching Text

- Replace MATLAB header comments with Markdown cells.
- Explain what is being calculated before showing the code.
- Include the main equations in LaTeX.
- State the numerical strategy, especially when it differs from MATLAB.
- Explain physical quantities such as wavelength, numerical aperture, pupil radius, aberration coefficients, and normalization.
- Avoid copying garbled MATLAB comments. Rewrite them clearly.
- Keep comments in code short; use Markdown for longer explanations.

## Naming and Units

- Prefer descriptive Python variable names over short MATLAB names.
- Include units in variable names when useful.
- Explain non-obvious mathematical or astronomical symbols before using them. For teaching notebooks, prefer readable text subscripts such as `sun`, `moon`, or `bulb` over unexplained symbolic subscripts such as `\odot`.

Examples:

```python
lambda_um = 0.550
n_img = 1.0
a_um = 5000.0
f_um = a_um / (NA / n_img)
x_range_um = 1.0
z_range_um = 10.0
```

- Do not use Python keywords as variable names. MATLAB `lambda` should become `lambda_um` or similar.
- Keep important physics symbols recognizable when possible: `NA`, `k`, `c40`, `X`, `Y`, `R`, `Z`.
- Use consistent suffixes:
  - `_um` for micrometers.
  - `_0` for reference or unaberrated cases.
  - `_sp` and `_sm` for plus/minus shifted source positions if useful.
- For SI quantities, use explicit names when they prevent ambiguity:
  - `lambda_m` for wavelength in meters.
  - `lambda_nm` for wavelength in nanometers.
  - `Lv_lambda` for spectral luminance per wavelength interval.
  - `Lv_lambda_per_nm` when the plotted quantity has been converted to per nanometer.

When a quantity is stored per meter but plotted against a nanometer axis, convert the dependent variable if the axis label says "per nm":

```python
Lv_lambda_per_nm = Lv_lambda * 1e-9
```

Keep the integration in the physically correct base units. For example, if `Lv_lambda` is in `cd m^-2 m^-1`, integrate over `lambda_m`, not over `lambda_nm`.

## MATLAB to Python Indexing

- MATLAB uses 1-based indexing; Python uses 0-based indexing.
- Convert center indices explicitly.

MATLAB:

```matlab
Ni = (N+1)/2;
PSFr = PSFn_rz(Ni,:);
PSFmin(k) = PSFr(Ni);
```

Python:

```python
center = N // 2
PSFr_line = PSFn_rz[center, :]
Imin = PSFr_line[center]
idx = kk - 1
```

- Be careful with loop counters used as array indices.
- If MATLAB stores results at index `k`, Python usually stores at `k - 1`.

## Arrays, Meshes, and Shapes

- Use NumPy arrays for all numerical work.
- For MATLAB-style grids, use:

```python
X, Y = np.meshgrid(x, y, indexing="xy")
```

- Check whether rows and columns correspond to the intended physical axes.
- For image plots, use `origin="lower"` and explicit `extent`.

Example:

```python
plt.imshow(data, extent=[x[0], x[-1], y[0], y[-1]], origin="lower")
```

## Complex Numbers

- MATLAB `1i` or `1j` becomes Python `1j`.
- Use `np.exp`, `np.abs`, and NumPy complex arrays.
- Initialize complex fields explicitly:

```python
U = np.zeros_like(X, dtype=np.complex128)
```

## Numerical Integration

- MATLAB scripts often use adaptive integration:

```matlab
integral(@(p) integrand(p), 0, a, 'ArrayValued', true)
```

- In teaching notebooks, it is acceptable to use an explicit integration grid when this makes the method clearer:

```python
Np = 2000
p = np.linspace(0.0, a_um, Np)
dp = p[1] - p[0]

for pj in p:
    U += integrand(pj) * dp
```

- If replacing adaptive integration with a Riemann or trapezoidal sum, state this in Markdown.
- Mention that increasing `Np` improves accuracy.
- Avoid generating very large 3D arrays if a loop over the integration variable is clearer and uses less memory.
- Use `scipy.integrate` only when it improves accuracy or matches the MATLAB method better.

## Special Functions

Use SciPy equivalents for MATLAB special functions.

Common mappings:

```text
besselj(0, x)      -> scipy.special.j0(x)
besselj(n, x)      -> scipy.special.jv(n, x)
interp1(...)       -> scipy.interpolate.interp1d or np.interp
integral(...)      -> scipy.integrate.quad, scipy.integrate.quad_vec, or explicit grid integration
```

## Helper Functions

- MATLAB local functions at the end of a script can become Python functions inside the notebook.
- Split complicated kernels into smaller named functions when helpful for teaching.
- If a helper is reused by several notebooks, place it under `PythonEnglisch/optbas/IncludeFolder`.
- Keep shared helper names consistent with existing Python files where possible.

Example:

```python
def spherical_phase(p, a, k, c40):
    rho = p / a
    poly = 6 * rho**4 - 6 * rho**2 + 1
    return np.exp(1j * k * c40 * poly)
```

## Physics Logic Must Be Preserved

- Preserve the physical order of operations.
- For incoherent point sources, compute fields separately, convert to intensities, then add intensities.

Correct:

```python
I_total = np.abs(U1)**2 + np.abs(U2)**2
```

Do not add incoherent fields before taking intensity unless the MATLAB code and physics require coherent interference.

- Preserve the original normalization logic.
- If the MATLAB code normalizes aberrated results by an unaberrated reference maximum, keep that behavior.

Example:

```python
Pn = np.max(PSF_xy_0)
PSFn_xy = PSF_xy / (Pn + 1e-30)
```

- Add tiny denominators such as `1e-30` only to avoid division by zero; do not change the intended normalization.

## Plotting Style

- Replace MATLAB `figure`, `surf`, and `view(2)` with notebook-friendly plots.
- Use Matplotlib for static 2D images and curves.
- Use Plotly for interactive 3D surfaces when helpful.
- Label all axes with quantities and units.
- Use readable titles that describe the physical case.
- Keep plot sizes moderate for notebooks.
- Check that the plotted values match the axis label, not only that the curve shape matches MATLAB.
- MATLAB scripts may contain correct numerical computations but incorrect plot labels. In that case, keep the physics and units correct in Python and document the MATLAB issue in both the notebook and `CodelistMatlabPython.xlsx`.
- Preserve the visual encoding logic of the MATLAB plot unless there is a clear teaching reason to change it. If MATLAB uses the outer loop index for color and the inner loop index for marker shape, keep the same mapping in Python.
- Match MATLAB marker style when it carries meaning. MATLAB markers such as `o`, `d`, and `s` often appear as hollow symbols; in Matplotlib use `markerfacecolor="none"` and set `markeredgecolor` explicitly.
- For polar plots, set the physically meaningful radial range explicitly. If the maximum possible value is 1, use `ax.set_ylim(0, 1)` instead of relying on Matplotlib autoscaling.
- Place polar radial labels deliberately. Avoid labels that sit directly on top of the plotted radial line; use `ax.set_rlabel_position(angle_degrees)` to offset them.

MATLAB:

```matlab
surf(X, Y, PSFn_xy, 'EdgeColor', 'none');
view(2)
```

Python:

```python
im = ax.imshow(
    PSFn_xy,
    extent=[x[0], x[-1], y[0], y[-1]],
    origin="lower",
    cmap="hot",
)
ax.set_aspect("equal")
fig.colorbar(im, ax=ax)
```

For spectral plots, distinguish carefully between "per meter" and "per nanometer" quantities:

```python
# Integration quantity: per meter
Lv_formal = trapezoid_integral(Lv_lambda, lambda_m)

# Plot quantity: per nanometer
Lv_lambda_per_nm = Lv_lambda * 1e-9
ax.set_ylabel(r"Spectral luminance [cd m$^{-2}$ nm$^{-1}$]")
```

For MATLAB-style marker and color grouping, translate the loop structure, not just the final data array:

```matlab
for k = 1:length(B)
  for m = 1:length(theta)
    plot(B(k), I(k,m), marker(m), 'Color', Colors(k,:))
  end
end
```

Python:

```python
for i, B in enumerate(baseline_m):
    for j, theta_value in enumerate(theta_mas):
        ax.plot(
            B,
            visibility[i, j],
            linestyle="none",
            marker=markers[j],
            markeredgecolor=Colors[i],
            color=Colors[i],
            markerfacecolor="none",
        )
```

For polar plots with a known maximum:

```python
ax.set_ylim(0, 1)
ax.set_yticks([0.25, 0.50, 0.75, 1.00])
ax.set_rlabel_position(12)  # offset labels from the radial line
```

## Progress Bars and Console Output

- MATLAB `waitbar` should usually be omitted.
- For long computations, either:
  - print concise progress messages, or
  - use `tqdm` only if the project already uses it or the dependency is acceptable.
- Keep output minimal and educational.

## File and Name Mismatches

- If the MATLAB source name, book name, and Python notebook name differ, record the mismatch in `CodelistMatlabPython.xlsx`.
- In the notebook title or first Markdown cell, mention the MATLAB source file.

Example:

```markdown
This notebook reproduces the Matlab script **PSFFresnel2P.m**.
```

- Use the repository MATLAB filename as the source of truth for conversion tracking.

## Accuracy Checks

Before considering a conversion done:

1. Run the notebook from top to bottom.
2. Check that all imports work.
3. Check array shapes after mesh and integration steps.
4. Confirm figures render.
5. Compare key numerical values or qualitative plot features with MATLAB when possible.
6. Verify indexing changes, especially center lines and extrema.
7. Check dimensional consistency of plotted quantities and axis labels.
8. If MATLAB output is questionable, decide whether the Python notebook should reproduce the MATLAB display or correct the physics. Prefer the physically correct version for teaching notebooks, and document the difference.
9. Update `CodelistMatlabPython.xlsx` with the Python filename and any name mismatch notes.

For unit-sensitive scripts, compare both:

- printed scalar values, which usually reveal whether formulas and integrations are correct;
- plotted axis scales, which can reveal unit conversion or labeling mistakes.

## Handoff Notes from Checked optbas Conversions

These notes summarize lessons from the checked notebooks:

- `BilderMembraninterferenzen.ipynb`
- `Spaltbeugung_bunt.ipynb`
- `BilderSpannungsdoppelbrechung.ipynb`
- `Fresnel2Fraunhofer.ipynb`
- `plotSpotDiagramm.ipynb`
- `PlotPupilleMitSpotDiagramm.ipynb`
- `OTFGrating2Imaging.ipynb`

Use these as concrete guidance for the next conversion agent.

### Read Helper Functions Before Converting

Do not infer the physical model from the main MATLAB script alone. Many optbas scripts call local helpers in `MatlabDateien/optbas/IncludeFolder`, and the important geometry, color model, or wavefront formula may live there.

Examples:

- `BilderMembraninterferenzen.m` calls `Membraninterferenzen.m`; the helper shows that the membrane is a rectangular wedge, not a circular/radial film.
- `BilderSpannungsdoppelbrechung.m` calls `Spannungsdoppelbrechung.m`; the helper shows that the displayed colors come from wavelength-by-wavelength Jones propagation, CIE XYZ integration, and sRGB conversion.
- `PlotPupilleMitSpotDiagramm.m` calls `PupilleMitSpotDiagramm.m`; the helper contains the 14 wavefront modes and analytic ray-error formulas.

Workflow:

1. Open the main MATLAB file.
2. Search for helper calls and local functions.
3. Open the helper files before writing Python.
4. Only then decide the notebook structure.

### Prefer Physical Correctness for Teaching Notebooks

When MATLAB contains a physically wrong formula, label, unit conversion, or display mapping, do not blindly reproduce the wrong physics in Python. For teaching notebooks, prefer the physically correct result.

Record the MATLAB issue in `CodelistMatlabPython.xlsx` `Remark`, not in the teaching Markdown.

Do not write notebook text like "MATLAB is wrong" or "the MATLAB code has a bug" in the student-facing explanation. The notebook should teach the correct physical process. Put source-code caveats in the workbook.

Recommended workbook remark pattern:

```text
Matlab code issue: <specific issue>. Python uses <specific correction>.
```

Checked examples:

```text
Matlab code issue: theta is computed as asin(sin(pi/4)/1.33)/180*pi, which converts an already-radian Snell angle to a much smaller angle; Python uses the physical Snell angle asin(sin(pi/4)/1.33).
```

```text
Matlab code issue: wavelength/channel mapping is physically reversed: MATLAB assigns 486 nm to red channel and 656 nm to blue channel via cat(3,I_red,I_green,I_blue). Python intentionally uses physical RGB mapping: 656 nm red, 546 nm green, 486 nm blue.
```

If the Python result intentionally differs from MATLAB because of a physical correction, set `check = No` until the user/reviewer has checked the corrected output. After review, set `check = Yes`.

### Student-Facing Markdown Style

Each notebook should have three levels of explanation:

1. A short title cell identifying the MATLAB source.
2. Intuitive physical background: describe what actually happens in the optical system.
3. Formula explanation immediately before each major calculation block: explain what the next code cell computes and how the variables correspond to the equations.

Do not use generic headings such as:

```markdown
## Formula used in the next code cell
```

Use specific headings instead:

```markdown
## Convert film thickness into reflected color
## Sum the slit contributions for each wavelength
## Propagate polarized light through the stressed sample
## Propagate the rectangular-aperture spectrum through free space
## Compute Seidel wavefronts and their spot diagrams
## Apply the defocused OTF to a two-frequency grating
```

Use formulas, but keep them tied to the code. The reader should be able to identify the Python variables in the equation.

### Avoid Markdown Parse Errors

When programmatically editing notebooks, write Markdown with raw strings or escaped backslashes. Otherwise LaTeX commands such as `\frac`, `\lambda`, `\Delta`, and `\approx` can become control characters and cause Markdown/MathJax parse errors.

After editing Markdown, scan for control characters:

```python
bad = [
    (i, repr(ch))
    for i, ch in enumerate(text)
    if ord(ch) < 32 and ch not in "\n\r\t"
]
```

Also verify notebooks with `nbformat.read(..., as_version=4)`.

### Color Images Are Often Real RGB, Not Colormaps

Do not assume color images are `imshow(data, cmap=...)`. Some MATLAB helpers compute actual RGB values.

For wavelength-dependent color:

1. Compute intensity for each wavelength.
2. Integrate against CIE 1931 color matching functions.
3. Convert XYZ to sRGB.
4. Apply gamma correction.
5. Normalize only according to the original physical/display intent.

Use this for thin-film and stress-birefringence images.

For direct RGB channel composites, verify that wavelength-to-channel mapping is physically meaningful. If MATLAB maps wavelengths to wrong RGB channels, correct Python for teaching and document the MATLAB issue in Excel.

### FFT and Propagation Rules

Keep FFT shifts explicit and consistent:

- If an FFT output is used with centered frequency coordinates, apply `fftshift` after `fft2`.
- Before `ifft2` on a centered spectrum, apply `ifftshift`.
- After `ifft2`, apply `fftshift` if the real-space output should be centered.
- Shift the frequency coordinate arrays consistently with the transformed spectrum.

For propagation scripts, do not always FFT a small sampled aperture. MATLAB may be using an analytic aperture spectrum. For `Fresnel2Fraunhofer`, the cleaner and MATLAB-consistent method is:

```python
F = np.sinc(a * FX) * np.sinc(b * FY)
H = np.exp(1j * 2 * np.pi * z * np.sqrt((1 - FX**2 - FY**2).astype(complex)))
U = centered_ifft2(F * H)
```

Explain the physics correctly: free-space propagation itself acts as a spatial-frequency filter. Components above the propagating cutoff become evanescent and decay with distance. A central crop after inverse FFT is only a display/windowing choice, not the physical high-frequency filter.

### OTF Scripts

Check whether MATLAB uses an ideal in-focus OTF approximation or computes an OTF from a complex pupil.

For `OTFGrating2Imaging`, the correct conversion is not the ideal circular-pupil OTF. MATLAB computes an autocorrelation of a defocused complex pupil:

```text
OTF(s) proportional to integral conj(g(x,y)) * g(s-x,y) dx dy
```

The defocus phase can make the OTF negative for some spatial frequencies. A negative OTF means contrast reversal of that sinusoidal component, not negative intensity.

### Spot Diagram Scripts

Spot diagrams are wavefront-slope diagrams. Preserve the analytic relationship:

```text
epsilon_x proportional to -dW/dx
epsilon_y proportional to -dW/dy
```

Do not replace a full MATLAB spot-diagram script with a simplified demonstration unless the user explicitly asks for a simplified illustration.

For `plotSpotDiagramm`, MATLAB has two figures:

1. Six Seidel aberrations: pupil wavefronts and spot diagrams.
2. Astigmatism through focus.

For `PlotPupilleMitSpotDiagramm`, MATLAB has two 8x7 overview sheets covering 14 aberration modes and five focus positions. Use the helper's 14 analytic wavefront and PSF/ray-error formulas, and use enough pupil samples for a high-resolution teaching image.

### Plot Count and Layout Must Be Checked

For every conversion, count MATLAB figures and tiles/subplots before finalizing. A notebook can look plausible while missing an entire MATLAB figure.

Checklist:

- Count `figure` calls.
- Count `subplot`, `tiledlayout`, `nexttile`, or repeated plotting loops.
- Verify that the notebook has the same conceptual outputs.
- If the notebook intentionally combines or rearranges plots for teaching, state the new layout in Markdown.

### Progress Tracking After Review

When a user says a group of notebooks has been checked:

1. Update `CodelistMatlabPython.xlsx`.
2. Set `matlab code = Yes`, `python code = Yes`, and `check = Yes` for those rows.
3. Preserve any existing `Remark` notes about MATLAB issues or name mismatches.
4. Create a backup workbook before editing.

## Progress Tracking in CodelistMatlabPython.xlsx

Use `PythonMATLABNew/CodelistMatlabPython.xlsx` as the source of truth for conversion progress.

The workbook is organized by sheet:

- `BookCode`: code referenced directly in the book text.
- `SolutionCode`: code used for exercises, solutions, or additional examples.
- `TableCode`: helper functions, table-listed code, and reusable support files.

Keep the chapter-based organization already used in the workbook. New entries should be placed under the appropriate chapter section whenever the chapter is known. If the chapter is not known yet, add a clearly named chapter-style scan section, for example:

- `Chapter 9 - optbas repository scan`
- `Chapter 9 - optbas IncludeFolder repository scan`

The standard columns are:

```text
A: numbering or formula-based index
B: MATLAB/book code name
C: matlab code
D: python code
E: Remark
F: check
```

Columns `C`, `D`, and `F` must be interactive `Yes,No` dropdown cells.

- `matlab code`: whether the MATLAB source exists in the repository.
- `python code`: whether the Python notebook or helper file exists.
- `check`: whether the converted Python code has been reviewed or verified.

Formatting must match the existing workbook style:

- `Yes` is shown in green.
- `No` is shown in red.
- The same red/green conditional formatting applies to `matlab code`, `python code`, and `check`.
- Chapter rows should remain simple chapter-style separator rows, not colored data rows.
- Added scan rows should use the same visual style as ordinary data rows.

When updating the workbook:

- If `python code` is set to `Yes`, set `check` to `Yes` only when the file has actually been checked.
- For bulk initialization, existing `python code = Yes` entries may be initialized with `check = Yes`, but future manual updates should distinguish "file exists" from "file checked".
- For newly converted notebooks, set `python code = Yes` and `check = No` until the user or reviewer has checked the notebook.
- If `python code = No`, leave `check` blank unless there is a specific reason to mark it.
- Do not use free text in the `matlab code`, `python code`, or `check` columns. Use only the dropdown values `Yes` or `No`.

Use the repository MATLAB filename as the tracking source of truth. If the name in the book/table differs from the actual repository file, keep the book/table name in column `B` when appropriate and add the repository name in `Remark`.

Recommended remark patterns:

```text
Python: ExampleName.ipynb
Matlab source: MatlabDateien/optbas/ExampleName.m
Matlab source name in repository: MatlabDateien/optbas/ActualName.m; table/book name differs from repository name.
Added by optbas repository scan YYYY-MM-DD; Matlab source: MatlabDateien/optbas/ExampleName.m; Python: ExampleName.ipynb
Added by optbas repository scan YYYY-MM-DD; Matlab source: MatlabDateien/optbas/ExampleName.m; no matching Python file found under PythonMATLABNew/Python*/*optbas*
```

For `IncludeFolder` helpers, record the source path explicitly:

```text
Matlab source: MatlabDateien/optbas/IncludeFolder/helper_name.m
```

When a Python file exists but uses a different filename, record that mismatch:

```text
Python: wave_interference.ipynb; repository/Python name differs from Matlab source name
```

If the MATLAB script produces a questionable or wrong output, record the issue in `Remark`.
This includes wrong axis labels, unit inconsistencies, known wrong plotted quantities, or formulas that must be corrected in the Python notebook.

Recommended pattern:

```text
Matlab plot issue: right y-axis label says cd/m^2/nm, but plotted Lv_lambda is per meter; Python plot converts spectral luminance to per nm by multiplying 1e-9.
```

Also mention the correction in the notebook near the affected calculation or plot. The reader should be able to understand why the Python plot scale may differ from MATLAB while the physical calculation remains the same.

## Conversion Checklist

Use this checklist for each `optbas` script:

- [ ] Identify the MATLAB source file and any helper dependencies.
- [ ] Check whether a Python helper already exists in `IncludeFolder`.
- [ ] Create a notebook with a title and physical explanation.
- [ ] Add equations and numerical strategy in Markdown.
- [ ] Convert parameters with descriptive names and units.
- [ ] Explain any non-obvious notation or replace it with clearer text-style subscripts.
- [ ] Convert arrays and grids with `np.meshgrid(..., indexing="xy")`.
- [ ] Convert local MATLAB functions into Python functions.
- [ ] Convert special functions to SciPy equivalents.
- [ ] Handle 1-based to 0-based indexing explicitly.
- [ ] Preserve physical order: field, intensity, incoherent/coherent addition.
- [ ] Preserve normalization and reference cases.
- [ ] Replace MATLAB plotting with Matplotlib or Plotly.
- [ ] Preserve MATLAB visual encoding where meaningful: color grouping, marker grouping, hollow markers, legends, polar scales, and axis ranges.
- [ ] Verify that plotted values and axis units are consistent.
- [ ] Add a brief interpretation of the plotted results.
- [ ] Run the notebook and fix errors.
- [ ] Update `CodelistMatlabPython.xlsx`, including `python code`, `check`, name mismatch notes, and any known MATLAB output issues.
