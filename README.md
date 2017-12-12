# GreenSolverCode
The only file that really needs to be changed is the InputMaker.m file. This sets up the system parameters and the values of mu to loop through. The actual simulation is done by running SmoothSurfaceInterfaceCalc.m and values in there can be edited if necessary, but for the most part is not recommended. 

There are example plotting codes and data in the PlottingCodes folder. 

The simplest way to look at the Green's functions might be in ldos.m or by calling it. After running the simulation or inside the simulation you can look at the local density of states by calling ldos(shoot(E,v,vL,vR)) where E is the energy you are looking at, v is the total potential of whatever system/fragment you are looking at, and vL & vR are the left and right boundary conditions of the potential. The only one that is non-zero is the left boundary condition anytime the metal potential is included, then vL = -V0. This outputs the Green's function divided by (pi * i). 
