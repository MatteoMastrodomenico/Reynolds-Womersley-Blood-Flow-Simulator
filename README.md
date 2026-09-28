# Reynolds–Womersley Blood Flow Simulator

An interactive MATLAB project for visualizing blood-flow behavior inside an idealized cylindrical blood vessel using two fundamental dimensionless parameters in biomedical fluid mechanics: the **Reynolds number** and the **Womersley number**.

The simulator was developed as an educational tool for the study of **hemodynamics, cardiovascular fluid mechanics, and biomedical engineering**, with particular attention to the physical mechanisms governing blood flow inside vessels.

## Overview

Blood flow in the cardiovascular system depends on multiple factors, including:

- Blood density
- Blood viscosity
- Vessel diameter
- Blood velocity
- Cardiac frequency
- Pulsatile pressure gradients
- Vessel geometry

Although real blood vessels are compliant, curved, branching, and anatomically complex, a straight cylindrical vessel provides a useful simplified model for studying the fundamental principles of vascular fluid dynamics.

This MATLAB project provides an interactive 3D visualization that connects these physical parameters with the corresponding flow behavior.

The simulator focuses particularly on two dimensionless quantities:

- **Reynolds number (Re)** — Used to characterize the relative importance of inertial and viscous forces
- **Womersley number (α)** — Used to characterize pulsatile blood flow and the relative importance of unsteady inertia and viscosity

## Biomedical Relevance

Understanding blood-flow behavior is fundamental in several areas of biomedical engineering, including:

- Arterial hemodynamics
- Cardiovascular physiology
- Vascular prostheses
- Stent design
- Artificial blood vessels
- Heart valves
- Vascular stenosis
- Aneurysms
- Blood pumps
- Cardiovascular medical devices
- Computational biofluid mechanics

The Reynolds and Womersley numbers provide complementary information about the physical behavior of blood inside the cardiovascular system.

While the Reynolds number is mainly associated with the balance between inertial and viscous effects, the Womersley number is particularly relevant when the flow is **pulsatile**, as occurs naturally because of the cardiac cycle.

## Reynolds Number

The Reynolds number is defined as:

Re = ρUD / μ

where:

- ρ = Blood density
- U = Characteristic blood velocity
- D = Vessel diameter
- μ = Dynamic viscosity

It represents the ratio between inertial and viscous forces.

At relatively low Reynolds numbers, viscous effects dominate and the flow tends to remain ordered and laminar.

As Reynolds number increases, inertial effects become increasingly important and flow disturbances may become stronger.

In cardiovascular applications, Reynolds number can be particularly relevant when studying:

- Large arteries
- High-velocity blood flow
- Stenotic vessels
- Vascular bifurcations
- Heart valves
- Pathological jets

## Womersley Number

The Womersley number is defined as:

α = R√(ωρ / μ)

where:

- R = Vessel radius
- ω = Angular frequency of pulsation
- ρ = Blood density
- μ = Dynamic viscosity

The Womersley number describes the relative importance of **unsteady inertial effects** compared with **viscous effects**.

This makes it particularly important for the study of pulsatile blood flow.

### Low Womersley Number

At low α values, viscous effects dominate.

The velocity profile can adapt relatively quickly to changes in the pressure gradient and tends to remain close to a parabolic profile.

This behavior is more representative of smaller vessels.

### High Womersley Number

At high α values, fluid inertia becomes increasingly important.

The central region of the velocity profile tends to become flatter, while stronger velocity gradients remain close to the vessel wall.

This behavior is particularly relevant in large arteries, where blood flow is strongly affected by cardiac pulsatility.

## What the MATLAB Code Does

The MATLAB code creates an interactive graphical simulation of blood flow inside a simplified cylindrical vessel.

The current implementation combines physical calculations with intuitive scientific visualization.

### 1. Defines the Blood Vessel Geometry

The program generates a three-dimensional cylindrical geometry representing an idealized blood vessel.

The vessel acts as the domain inside which the simulated blood flow is displayed.

This simplified geometry allows the user to focus on the fundamental fluid-mechanics concepts without introducing the complexity of real vascular anatomy.

### 2. Defines the Fluid and Flow Parameters

The simulation uses parameters relevant to blood flow, such as:

- Blood density
- Dynamic viscosity
- Vessel diameter or radius
- Characteristic velocity
- Pulsation frequency

These parameters determine the physical conditions of the simulated flow.

### 3. Calculates the Reynolds Number

Using the selected physical parameters, MATLAB calculates:

Re = ρUD / μ

The resulting Reynolds number is used to characterize the balance between viscous and inertial effects.

The calculated value contributes to the interpretation and visualization of the corresponding flow regime.

### 4. Calculates the Womersley Number

The code also calculates:

α = R√(ωρ / μ)

The Womersley number is used to characterize the importance of pulsatile inertia relative to viscosity.

This allows the simulation to represent the time-dependent behavior typical of cardiovascular blood flow.

### 5. Generates a Laminar Flow Visualization

For conditions associated with ordered flow, the program displays a regular and smooth velocity structure inside the vessel.

The graphical representation is designed to visually communicate the organized behavior expected in laminar flow.

The axial flow direction remains clearly recognizable and the fluid motion does not contain large disordered structures.

### 6. Generates a Disturbed or Turbulent-Like Visualization

When the simulated conditions correspond to stronger inertial effects, the visualization introduces irregular structures and vortex-like patterns.

These structures are intended to make disturbed flow visually distinguishable from laminar flow.

The user can therefore recognize the difference directly from the graphical representation rather than relying only on the numerical Reynolds number.

These vortex structures should currently be interpreted primarily as an **educational and qualitative representation** unless they are generated from a fully validated numerical turbulence model.

### 7. Represents Pulsatile Flow

The simulation incorporates time-dependent flow behavior to reproduce the concept of pulsatility.

This is particularly important in biomedical applications because blood flow in arteries is generated by the periodic pumping action of the heart.

The Womersley number provides the physical basis for interpreting the relationship between pulsation frequency, fluid inertia, and viscosity.

### 8. Displays the Fluid as a Continuous Domain

The flow is represented as a continuous fluid field rather than only as a collection of independent particles.

This provides a more intuitive representation of the fluid domain and makes it easier to observe the global flow structure.

### 9. Updates the Visualization

The graphical representation is updated as the simulation evolves.

Depending on the selected parameters and flow conditions, the user can visually observe changes in the fluid structure and flow behavior.

### 10. Provides Interactive 3D Navigation

The MATLAB figure can be explored interactively.

The user can:

- Rotate the vessel
- Change the camera angle
- Zoom in
- Zoom out
- Inspect the flow from different perspectives

This makes it possible to analyze flow structures from multiple viewpoints rather than observing the vessel from a fixed camera position.

### 11. Displays the Flow Regime

The graphical interface indicates the current type of flow without obscuring the main simulation.

This helps the user immediately associate the observed fluid behavior with its physical interpretation.

## Main Features

The current version includes:

- 3D cylindrical blood-vessel representation
- Continuous fluid visualization
- Reynolds number calculation
- Womersley number calculation
- Laminar-flow visualization
- Disturbed or turbulent-like flow visualization
- Vortex-like structures for visualization of flow disturbances
- Pulsatile-flow representation
- Interactive 3D rotation
- Zoom controls
- Camera navigation
- Dynamic graphical updates
- Automatic indication of the represented flow behavior

## Physical Interpretation

The simulator can be used to investigate how changes in cardiovascular parameters influence blood-flow behavior.

For example, increasing blood velocity increases the Reynolds number and therefore increases the relative importance of inertial effects.

Changing vessel diameter affects both Reynolds and Womersley numbers.

Increasing the pulsation frequency increases the Womersley number, modifying the balance between oscillatory inertia and viscous effects.

The simulator therefore provides a visual link between:

**Cardiovascular parameters → Dimensionless numbers → Flow behavior**

This relationship is central to the study of hemodynamics.

## Idealized Blood Vessel Model

The vessel represented in this project is intentionally simplified.

The current model assumes an idealized straight cylindrical vessel and does not reproduce the entire physiological complexity of the cardiovascular system.

Real blood vessels may include:

- Compliant vessel walls
- Curved geometries
- Arterial branching
- Varying diameter
- Complex inlet velocity profiles
- Pressure-wave propagation
- Non-Newtonian blood behavior
- Interactions between blood and vessel walls

These phenomena may be incorporated into future versions of the project.

## Educational Purpose

This project is primarily intended as an educational scientific visualization.

Its purpose is to improve the understanding of fundamental concepts in biomedical fluid mechanics by combining mathematical parameters with interactive graphical representations.

The current software should not be interpreted as a complete or validated Computational Fluid Dynamics solver.

In particular, the graphical representation of disturbed or turbulent flow may contain qualitative visualization elements rather than structures directly obtained from the numerical solution of the complete Navier–Stokes equations with a turbulence model.

## Project Structure

```text
Reynolds-Womersley-Blood-Flow-Simulator/
│
├── reynolds_womersley_simulator.m
├── README.md
├── LICENSE
│
├── images/
│   ├── laminar_blood_flow.png
│   ├── disturbed_blood_flow.png
│   └── simulator_interface.png
│
└── docs/
    └── hemodynamics_theory.md
```

## Requirements

- MATLAB
- MATLAB graphics support

The current implementation is primarily based on MATLAB numerical and graphical functions.

Future versions may require additional MATLAB toolboxes depending on the implemented features.

## Running the Simulation

1. Clone or download the repository.
2. Open MATLAB.
3. Navigate to the repository directory.
4. Open `reynolds_womersley_simulator.m`.
5. Run the script.
6. The simulation window will open and display the blood-vessel model.
7. Use MATLAB's interactive controls to rotate, zoom, and inspect the simulated flow.

## Possible Future Developments

Future versions may include:

- Analytical Womersley velocity profiles
- Realistic arterial pressure waveforms
- Realistic cardiac-cycle velocity waveforms
- Systolic and diastolic flow phases
- Wall shear stress calculation
- Oscillatory shear index
- Pulse-wave propagation
- Compliant arterial walls
- Fluid-structure interaction
- Vascular stenosis
- Aneurysm geometries
- Arterial bifurcations
- Curved vessels
- Patient-specific vascular geometries
- Newtonian vs non-Newtonian blood models
- Healthy vs pathological vessel comparison
- Velocity-field export
- Pressure-field visualization
- Streamline visualization
- Quantitative validation against analytical solutions
- Numerical solution of the Navier–Stokes equations

## Potential Biomedical Applications

Future extensions of the simulator could support educational investigation of several cardiovascular conditions and biomedical applications.

### Vascular Stenosis

A reduction in vessel diameter can locally increase blood velocity and modify the Reynolds number, potentially producing disturbed flow downstream of the narrowing.

### Aneurysms

Changes in vessel geometry may strongly alter local flow patterns, recirculation regions, and wall shear stress.

### Arterial Bifurcations

Blood-flow division at vascular branches can generate complex local hemodynamics.

### Cardiovascular Devices

The same physical principles are relevant to the study and design of:

- Vascular grafts
- Stents
- Prosthetic heart valves
- Blood pumps
- Ventricular assist devices

## Limitations

The current model does not attempt to reproduce all physiological properties of blood or vascular tissue.

Unless otherwise specified in future implementations:

- Blood may be treated as a simplified fluid
- The vessel wall may be considered rigid
- The geometry is idealized
- Pathological geometries are not yet modeled
- Turbulence visualization may be qualitative
- The model is not patient-specific
- No clinical validation is provided

These limitations are intentional because the primary objective of the project is educational visualization and understanding of fundamental hemodynamic principles.

## Disclaimer

This software is intended exclusively for educational and research-learning purposes.

It is **not**:

- A medical device
- A diagnostic system
- A clinical simulation platform
- A validated CFD solver
- A tool for treatment planning
- A substitute for professional cardiovascular modeling software

Results generated by this project should not be used for clinical diagnosis, therapeutic decisions, or patient-specific medical assessment.

## Author

**Matteo Mastrodomenico**  
Biomedical Engineering

## License

Distributed under the MIT License.

See the `LICENSE` file for additional information.
