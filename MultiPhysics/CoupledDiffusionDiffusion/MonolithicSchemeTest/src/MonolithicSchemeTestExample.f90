!> \file
!> $Id: MonolithicSchemeTestExample.f90 20 2009-05-28 20:22:52Z chrm76 $
!> \authors Andrew Cookson
!> \brief This is an example program to solve coupled multi-compartment diffusion equations in monolithic scheme using openCMISS calls.
!>
!> \section LICENSE
!>
!> Version: MPL 1.1/GPL 2.0/LGPL 2.1
!>
!> The contents of this file are subject to the Mozilla Public License
!> Version 1.1 (the "License"); you may not use this file except in
!> compliance with the License. You may obtain a copy of the License at
!> http://www.mozilla.org/MPL/
!>
!> Software distributed under the License is distributed on an "AS IS"
!> basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
!> License for the specific language governing rights and limitations
!> under the License.
!>
!> The Original Code is OpenCMISS
!>
!> The Initial Developer of the Original Code is University of Auckland,
!> Auckland, New Zealand and University of Oxford, Oxford, United
!> Kingdom. Portions created by the University of Auckland and University
!> of Oxford are Copyright (C) 2007 by the University of Auckland and
!> the University of Oxford. All Rights Reserved.
!>
!> Contributor(s):
!>
!> Alternatively, the contents of this file may be used under the terms of
!> either the GNU General Public License Version 2 or later (the "GPL"), or
!> the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
!> in which case the provisions of the GPL or the LGPL are applicable instead
!> of those above. If you wish to allow use of your version of this file only
!> under the terms of either the GPL or the LGPL, and not to allow others to
!> use your version of this file under the terms of the MPL, indicate your
!> decision by deleting the provisions above and replace them with the notice
!> and other provisions required by the GPL or the LGPL. If you do not delete
!> the provisions above, a recipient may use your version of this file under
!> the terms of any one of the MPL, the GPL or the LGPL.
!>

!> \example MultiPhysics/CoupledDiffusionDiffusion/MonolithicSchemeTest/src/MonolithicSchemeTestExample.f90
!! Example program to solve coupled MonolithicSchemeTest equations using OpenCMISS calls.
!! \par Latest Builds:
!! \li <a href='http://autotest.bioeng.auckland.ac.nz/opencmiss-build/logs_x86_64-linux/MultiPhysics/CoupledDiffusionDiffusion/MonolithicSchemeTest/build-intel'>Linux Intel Build</a>
!! \li <a href='http://autotest.bioeng.auckland.ac.nz/opencmiss-build/logs_x86_64-linux/MultiPhysics/CoupledDiffusionDiffusion/MonolithicSchemeTest/build-intel'>Linux GNU Build</a>
!!
!<

! ! 
! !  This example considers a volume coupled multi-compartment diffusion model, as a means of testing the monolithic assembly of
! !  such a system of equations, for use in more complicated problem in future.
! !  This example will initially couple together three diffusion equations, with the transfer between each equation being proportional to
! !  the concentration difference between each equation.

!> Main program

PROGRAM MONOLITHICSCHEMETESTEXAMPLE

  !
  !================================================================================================================================
  !

  !PROGRAM LIBRARIES

  USE OPENCMISS
  USE FLUID_MECHANICS_IO_ROUTINES
  USE MPI

#ifdef WIN32
  USE IFQWINCMISS
#endif

  !
  !================================================================================================================================
  !

  !PROGRAM VARIABLES AND TYPES

  IMPLICIT NONE

  !Test program parameters

  INTEGER(CMISSIntg), PARAMETER :: CoordinateSystemUserNumber=1
  INTEGER(CMISSIntg), PARAMETER :: RegionUserNumber=2
  INTEGER(CMISSIntg), PARAMETER :: MeshUserNumber=3
  INTEGER(CMISSIntg), PARAMETER :: DecompositionUserNumber=4
  INTEGER(CMISSIntg), PARAMETER :: GeometricFieldUserNumber=5
  INTEGER(CMISSIntg), PARAMETER :: DependentFieldUserNumber=6
  INTEGER(CMISSIntg), PARAMETER :: MaterialsFieldUserNumberDiffusionOne=9
  INTEGER(CMISSIntg), PARAMETER :: MaterialsFieldUserNumberDiffusionTwo=10
  INTEGER(CMISSIntg), PARAMETER :: MaterialsFieldUserNumberDiffusionThree=11
  INTEGER(CMISSIntg), PARAMETER :: SourceFieldUserNumberDiffusionOne=15
  INTEGER(CMISSIntg), PARAMETER :: SourceFieldUserNumberDiffusionTwo=16
  INTEGER(CMISSIntg), PARAMETER :: SourceFieldUserNumberDiffusionThree=17
  INTEGER(CMISSIntg), PARAMETER :: EquationsSetUserNumberDiffusionOne=12
  INTEGER(CMISSIntg), PARAMETER :: EquationsSetUserNumberDiffusionTwo=13
  INTEGER(CMISSIntg), PARAMETER :: EquationsSetUserNumberDiffusionThree=14
  INTEGER(CMISSIntg), PARAMETER :: ProblemUserNumber=20

  INTEGER(CMISSIntg), PARAMETER :: DomainUserNumber=1
  INTEGER(CMISSIntg), PARAMETER :: NumberOfUserDomains=1
  INTEGER(CMISSIntg), PARAMETER :: SolverDiffusionUserNumber=1
  INTEGER(CMISSIntg), PARAMETER :: MaterialsFieldUserNumberDarcyPorosity=1
  INTEGER(CMISSIntg), PARAMETER :: MaterialsFieldUserNumberDarcyPermOverVis=2
  INTEGER(CMISSIntg), PARAMETER :: MaterialsFieldUserNumberMatPropertiesPorosity=1     !??? 3 ???
  INTEGER(CMISSIntg), PARAMETER :: MaterialsFieldUserNumberMatPropertiesPermOverVis=2     !??? 4 ???

  !Program types

  TYPE(EXPORT_CONTAINER):: CM

  !Program variables

  INTEGER(CMISSIntg) :: NUMBER_OF_DIMENSIONS

  INTEGER(CMISSIntg) :: NUMBER_OF_COMPARTMENTS
  
  INTEGER(CMISSIntg) :: BASIS_TYPE
  INTEGER(CMISSIntg) :: BASIS_NUMBER_GEOMETRY
  INTEGER(CMISSIntg) :: BASIS_NUMBER_CONC_ONE
  INTEGER(CMISSIntg) :: BASIS_NUMBER_CONC_TWO
  INTEGER(CMISSIntg) :: BASIS_NUMBER_CONC_THREE
  INTEGER(CMISSIntg) :: BASIS_XI_GAUSS_GEOMETRY
  INTEGER(CMISSIntg) :: BASIS_XI_GAUSS_CONC_ONE
  INTEGER(CMISSIntg) :: BASIS_XI_GAUSS_CONC_TWO
  INTEGER(CMISSIntg) :: BASIS_XI_GAUSS_CONC_THREE
  INTEGER(CMISSIntg) :: BASIS_XI_INTERPOLATION_GEOMETRY
  INTEGER(CMISSIntg) :: BASIS_XI_INTERPOLATION_CONC_ONE
  INTEGER(CMISSIntg) :: BASIS_XI_INTERPOLATION_CONC_TWO
  INTEGER(CMISSIntg) :: BASIS_XI_INTERPOLATION_CONC_THREE
  INTEGER(CMISSIntg) :: MESH_NUMBER_OF_COMPONENTS,MESH_NUMBER_OF_ALL_COMPONENTS
  INTEGER(CMISSIntg) :: MESH_COMPONENT_NUMBER_GEOMETRY
  INTEGER(CMISSIntg) :: MESH_COMPONENT_NUMBER_CONC_ONE
  INTEGER(CMISSIntg) :: MESH_COMPONENT_NUMBER_CONC_TWO
  INTEGER(CMISSIntg) :: MESH_COMPONENT_NUMBER_CONC_THREE
  INTEGER(CMISSIntg) :: NUMBER_OF_NODES_GEOMETRY
  INTEGER(CMISSIntg) :: NUMBER_OF_NODES_CONC_ONE
  INTEGER(CMISSIntg) :: NUMBER_OF_NODES_CONC_TWO
  INTEGER(CMISSIntg) :: NUMBER_OF_NODES_CONC_THREE
  INTEGER(CMISSIntg) :: NUMBER_OF_ELEMENT_NODES_GEOMETRY
  INTEGER(CMISSIntg) :: NUMBER_OF_ELEMENT_NODES_CONC_ONE
  INTEGER(CMISSIntg) :: NUMBER_OF_ELEMENT_NODES_CONC_TWO
  INTEGER(CMISSIntg) :: NUMBER_OF_ELEMENT_NODES_CONC_THREE
  INTEGER(CMISSIntg) :: TOTAL_NUMBER_OF_NODES,TOTAL_NUMBER_OF_ALL_NODES
  INTEGER(CMISSIntg) :: TOTAL_NUMBER_OF_ELEMENTS
  INTEGER(CMISSIntg) :: MAXIMUM_ITERATIONS
  INTEGER(CMISSIntg) :: RESTART_VALUE
  INTEGER(CMISSIntg) :: NUMBER_OF_FIXED_WALL_NODES_DIFFUSION_ONE
  INTEGER(CMISSIntg) :: NUMBER_OF_INLET_WALL_NODES_DIFFUSION_ONE
  INTEGER(CMISSIntg) :: NUMBER_OF_FIXED_WALL_NODES_DIFFUSION_TWO
  INTEGER(CMISSIntg) :: NUMBER_OF_INLET_WALL_NODES_DIFFUSION_TWO
  INTEGER(CMISSIntg) :: NUMBER_OF_FIXED_WALL_NODES_DIFFUSION_THREE
  INTEGER(CMISSIntg) :: NUMBER_OF_INLET_WALL_NODES_DIFFUSION_THREE
  INTEGER(CMISSIntg) :: EQUATIONS_DIFFUSION_ONE_OUTPUT
  INTEGER(CMISSIntg) :: EQUATIONS_DIFFUSION_TWO_OUTPUT
  INTEGER(CMISSIntg) :: EQUATIONS_DIFFUSION_THREE_OUTPUT
  INTEGER(CMISSIntg) :: COMPONENT_NUMBER
  INTEGER(CMISSIntg) :: NODE_NUMBER
  INTEGER(CMISSIntg) :: ELEMENT_NUMBER
  INTEGER(CMISSIntg) :: NODE_COUNTER
  INTEGER(CMISSIntg) :: CONDITION

  INTEGER(CMISSIntg) :: LINEAR_SOLVER_DIFFUSION_OUTPUT_FREQUENCY
  INTEGER(CMISSIntg) :: LINEAR_SOLVER_DIFFUSION_OUTPUT_TYPE


  REAL(CMISSDP) :: DOMAIN_X1, DOMAIN_X2, DOMAIN_Y1, DOMAIN_Y2, DOMAIN_Z1, DOMAIN_Z2
  REAL(CMISSDP) :: GEOMETRY_TOLERANCE

  INTEGER, ALLOCATABLE, DIMENSION(:):: FIXED_WALL_NODES_DIFFUSION_ONE
  INTEGER, ALLOCATABLE, DIMENSION(:):: INLET_WALL_NODES_DIFFUSION_ONE
  INTEGER, ALLOCATABLE, DIMENSION(:):: FIXED_WALL_NODES_DIFFUSION_TWO
  INTEGER, ALLOCATABLE, DIMENSION(:):: INLET_WALL_NODES_DIFFUSION_TWO
  INTEGER, ALLOCATABLE, DIMENSION(:):: FIXED_WALL_NODES_DIFFUSION_THREE
  INTEGER, ALLOCATABLE, DIMENSION(:):: INLET_WALL_NODES_DIFFUSION_THREE

  REAL(CMISSDP) :: INITIAL_FIELD_DIFFUSION_ONE
  REAL(CMISSDP) :: INITIAL_FIELD_DIFFUSION_TWO
  REAL(CMISSDP) :: INITIAL_FIELD_DIFFUSION_THREE
  REAL(CMISSDP) :: BOUNDARY_CONDITIONS_DIFFUSION_ONE
  REAL(CMISSDP) :: BOUNDARY_CONDITIONS_DIFFUSION_TWO
  REAL(CMISSDP) :: BOUNDARY_CONDITIONS_DIFFUSION_THREE
  REAL(CMISSDP) :: DIVERGENCE_TOLERANCE
  REAL(CMISSDP) :: RELATIVE_TOLERANCE
  REAL(CMISSDP) :: ABSOLUTE_TOLERANCE
  REAL(CMISSDP) :: LINESEARCH_ALPHA
  REAL(CMISSDP) :: VALUE

  REAL(CMISSDP) :: LINEAR_SOLVER_DIFFUSION_START_TIME
  REAL(CMISSDP) :: LINEAR_SOLVER_DIFFUSION_STOP_TIME
  REAL(CMISSDP) :: LINEAR_SOLVER_DIFFUSION_TIME_INCREMENT

  LOGICAL :: EXPORT_FIELD_IO
  LOGICAL :: LINEAR_SOLVER_DIFFUSION_DIRECT_FLAG
  LOGICAL :: INLET_WALL_NODES_DIFFUSION_ONE_FLAG
  LOGICAL :: INLET_WALL_NODES_DIFFUSION_TWO_FLAG
  LOGICAL :: INLET_WALL_NODES_DIFFUSION_THREE_FLAG
  !CMISS variables

  !Regions
  TYPE(CMISSRegionType) :: Region
  TYPE(CMISSRegionType) :: WorldRegion
  !Coordinate systems
  TYPE(CMISSCoordinateSystemType) :: CoordinateSystem
  TYPE(CMISSCoordinateSystemType) :: WorldCoordinateSystem
  !Basis
  TYPE(CMISSBasisType) :: BasisGeometry
  TYPE(CMISSBasisType) :: BasisConcOne
  TYPE(CMISSBasisType) :: BasisConcTwo
  TYPE(CMISSBasisType) :: BasisConcThree
  !Nodes
  TYPE(CMISSNodesType) :: Nodes
  !Elements
  TYPE(CMISSMeshElementsType) :: MeshElementsGeometry
  TYPE(CMISSMeshElementsType) :: MeshElementsConcOne
  TYPE(CMISSMeshElementsType) :: MeshElementsConcTwo
  TYPE(CMISSMeshElementsType) :: MeshElementsConcThree
  !Meshes
  TYPE(CMISSMeshType) :: Mesh
  !Decompositions
  TYPE(CMISSDecompositionType) :: Decomposition
  !Fields
  TYPE(CMISSFieldsType) :: Fields
  !Field types
  TYPE(CMISSFieldType) :: GeometricField
  TYPE(CMISSFieldType) :: DependentField
  TYPE(CMISSFieldType) :: MaterialsFieldDiffusionOne
  TYPE(CMISSFieldType) :: MaterialsFieldDiffusionTwo
  TYPE(CMISSFieldType) :: MaterialsFieldDiffusionThree
  TYPE(CMISSFieldType) :: SourceFieldDiffusionOne
  TYPE(CMISSFieldType) :: SourceFieldDiffusionTwo
  TYPE(CMISSFieldType) :: SourceFieldDiffusionThree
  !Boundary conditions
  TYPE(CMISSBoundaryConditionsType) :: BoundaryConditionsDiffusionOne
  TYPE(CMISSBoundaryConditionsType) :: BoundaryConditionsDiffusionTwo
  TYPE(CMISSBoundaryConditionsType) :: BoundaryConditionsDiffusionThree
  !Equations sets
  TYPE(CMISSEquationsSetType) :: EquationsSetDiffusionOne
  TYPE(CMISSEquationsSetType) :: EquationsSetDiffusionTwo
  TYPE(CMISSEquationsSetType) :: EquationsSetDiffusionThree
  !Equations
  TYPE(CMISSEquationsType) :: EquationsDiffusionOne
  TYPE(CMISSEquationsType) :: EquationsDiffusionTwo
  TYPE(CMISSEquationsType) :: EquationsDiffusionThree
  !Problems
  TYPE(CMISSProblemType) :: Problem
  !Control loops
  TYPE(CMISSControlLoopType) :: ControlLoop
  !Solvers
  TYPE(CMISSSolverType) :: SolverDiffusion
  TYPE(CMISSSolverType) :: LinearSolverDiffusion
  !Solver equations
  TYPE(CMISSSolverEquationsType) :: SolverEquationsDiffusion

#ifdef WIN32
  !Quickwin type
  LOGICAL :: QUICKWIN_STATUS=.FALSE.
  TYPE(WINDOWCONFIG) :: QUICKWIN_WINDOW_CONFIG
#endif
  
  !Generic CMISS variables
  
  INTEGER(CMISSIntg) :: EquationsSetIndexOne
  INTEGER(CMISSIntg) :: EquationsSetIndexTwo
  INTEGER(CMISSIntg) :: EquationsSetIndexThree
  INTEGER(CMISSIntg) :: Err


  INTEGER(CMISSIntg) :: DIAG_LEVEL_LIST(5)
!   CHARACTER(LEN=255) :: DIAG_ROUTINE_LIST(8) !,TIMING_ROUTINE_LIST(1)
  CHARACTER(LEN=255) :: DIAG_ROUTINE_LIST(1) !,TIMING_ROUTINE_LIST(1)

  
  !
  !--------------------------------------------------------------------------------------------------------------------------------
  !

  !Program variables and types (finite elasticity part)

  !Test program parameters

! 
  INTEGER(CMISSIntg) :: TotalNumberOfSolidNodes
!   INTEGER(CMISSIntg) :: NumberOfSolidMeshComponents

! 

  !End - Program variables and types (finite elasticity part)

  !
  !--------------------------------------------------------------------------------------------------------------------------------
  !


#ifdef WIN32
  !Initialise QuickWin
  QUICKWIN_WINDOW_CONFIG%TITLE="General Output" !Window title
  QUICKWIN_WINDOW_CONFIG%NUMTEXTROWS=-1 !Max possible number of rows
  QUICKWIN_WINDOW_CONFIG%MODE=QWIN$SCROLLDOWN
  !Set the window parameters
  QUICKWIN_STATUS=SETWINDOWCONFIG(QUICKWIN_WINDOW_CONFIG)
  !If attempt fails set with system estimated values
  IF(.NOT.QUICKWIN_STATUS) QUICKWIN_STATUS=SETWINDOWCONFIG(QUICKWIN_WINDOW_CONFIG)
#endif

  !
  !================================================================================================================================
  !

  !INITIALISE OPENCMISS

  CALL CMISSInitialise(WorldCoordinateSystem,WorldRegion,Err)

  CALL CMISSErrorHandlingModeSet(CMISSTrapError,Err)

  !
  !================================================================================================================================
  !

  !PROBLEM CONTROL PANEL

  !Import cmHeart mesh information
  CALL FLUID_MECHANICS_IO_READ_CMHEART(CM,Err)  
  BASIS_NUMBER_GEOMETRY=CM%ID_M
  BASIS_NUMBER_CONC_ONE=CM%ID_V !USE THE V COMPONENT OF CMHEART INPUT FOR CONCENTRATION ONE
  BASIS_NUMBER_CONC_TWO=CM%ID_P !USE THE p COMPONENT OF CMHEART INPUT FOR CONCENTRATION TWO
  NUMBER_OF_DIMENSIONS=CM%D
  BASIS_TYPE=CM%IT_T
  BASIS_XI_INTERPOLATION_GEOMETRY=CM%IT_M
  BASIS_XI_INTERPOLATION_CONC_ONE=CM%IT_V
  BASIS_XI_INTERPOLATION_CONC_TWO=CM%IT_P
  NUMBER_OF_NODES_GEOMETRY=CM%N_M
  NUMBER_OF_NODES_CONC_ONE=CM%N_V
  NUMBER_OF_NODES_CONC_TWO=CM%N_P
  TOTAL_NUMBER_OF_NODES=CM%N_T
  TOTAL_NUMBER_OF_ELEMENTS=CM%E_T
  NUMBER_OF_ELEMENT_NODES_GEOMETRY=CM%EN_M
  NUMBER_OF_ELEMENT_NODES_CONC_ONE=CM%EN_V
  NUMBER_OF_ELEMENT_NODES_CONC_TWO=CM%EN_P
!   !Set domain dimensions
!   DOMAIN_X1 = -5.0_CMISSDP
!   DOMAIN_X2 =  5.0_CMISSDP
!   DOMAIN_Y1 = -5.0_CMISSDP
!   DOMAIN_Y2 =  5.0_CMISSDP
!   DOMAIN_Z1 = -5.0_CMISSDP
!   DOMAIN_Z2 =  5.0_CMISSDP
  !Set domain dimensions
  DOMAIN_X1 =  0.0_CMISSDP
  DOMAIN_X2 =  1.0_CMISSDP
  DOMAIN_Y1 =  0.0_CMISSDP
  DOMAIN_Y2 =  1.0_CMISSDP
  DOMAIN_Z1 =  0.0_CMISSDP
  DOMAIN_Z2 =  1.0_CMISSDP
  !Set geometric tolerance
  GEOMETRY_TOLERANCE = 1.0E-12_CMISSDP
  !Set initial values
  INITIAL_FIELD_DIFFUSION_ONE=1.0_CMISSDP
  INITIAL_FIELD_DIFFUSION_TWO=1.0_CMISSDP
  INITIAL_FIELD_DIFFUSION_THREE=1.0_CMISSDP
  !Set initial boundary conditions
  INLET_WALL_NODES_DIFFUSION_ONE_FLAG=.TRUE.
  IF(INLET_WALL_NODES_DIFFUSION_ONE_FLAG) THEN
    NUMBER_OF_INLET_WALL_NODES_DIFFUSION_ONE=36
    ALLOCATE(INLET_WALL_NODES_DIFFUSION_ONE(NUMBER_OF_INLET_WALL_NODES_DIFFUSION_ONE))
    INLET_WALL_NODES_DIFFUSION_ONE=(/191,155,119,83,23,21,192,156,120,84,24,22,&
     & 198,162,126,90,36,35,204,168,132,96,48,47,210,174,138,102,60,59,216,180,144,108,72,71/)
    !Set initial boundary conditions
    BOUNDARY_CONDITIONS_DIFFUSION_ONE=1.0_CMISSDP
  ENDIF  !Set material parameters

  INLET_WALL_NODES_DIFFUSION_TWO_FLAG=.TRUE.
  IF(INLET_WALL_NODES_DIFFUSION_TWO_FLAG) THEN
    NUMBER_OF_INLET_WALL_NODES_DIFFUSION_TWO=36
    ALLOCATE(INLET_WALL_NODES_DIFFUSION_TWO(NUMBER_OF_INLET_WALL_NODES_DIFFUSION_TWO))
    INLET_WALL_NODES_DIFFUSION_TWO=(/191,155,119,83,23,21,192,156,120,84,24,22,&
     & 198,162,126,90,36,35,204,168,132,96,48,47,210,174,138,102,60,59,216,180,144,108,72,71/)
    !Set initial boundary conditions
    BOUNDARY_CONDITIONS_DIFFUSION_TWO=1.0_CMISSDP
  ENDIF  !Set material parameters

  INLET_WALL_NODES_DIFFUSION_THREE_FLAG=.TRUE.
  IF(INLET_WALL_NODES_DIFFUSION_THREE_FLAG) THEN
    NUMBER_OF_INLET_WALL_NODES_DIFFUSION_THREE=36
    ALLOCATE(INLET_WALL_NODES_DIFFUSION_THREE(NUMBER_OF_INLET_WALL_NODES_DIFFUSION_THREE))
    INLET_WALL_NODES_DIFFUSION_THREE=(/191,155,119,83,23,21,192,156,120,84,24,22,&
     & 198,162,126,90,36,35,204,168,132,96,48,47,210,174,138,102,60,59,216,180,144,108,72,71/)
    !Set initial boundary conditions
    BOUNDARY_CONDITIONS_DIFFUSION_THREE=1.0_CMISSDP
  ENDIF  !Set material parameters



  !Set material parameters
  !Set number of Gauss points (Mind that also material field may be interpolated)
  BASIS_XI_GAUSS_GEOMETRY=3 !4
  BASIS_XI_GAUSS_CONC_ONE=3 !4
  BASIS_XI_GAUSS_CONC_TWO=3 !4
  !Set output parameter
  !(NoOutput/ProgressOutput/TimingOutput/SolverOutput/SolverMatrixOutput)
  LINEAR_SOLVER_DIFFUSION_OUTPUT_TYPE=CMISSSolverSolverOutput
  !(NoOutput/TimingOutput/MatrixOutput/ElementOutput)
  EQUATIONS_DIFFUSION_ONE_OUTPUT=CMISSEquationsNoOutput
  EQUATIONS_DIFFUSION_TWO_OUTPUT=CMISSEquationsNoOutput
  EQUATIONS_DIFFUSION_THREE_OUTPUT=CMISSEquationsNoOutput
  !Set time parameter
  LINEAR_SOLVER_DIFFUSION_START_TIME=0.0_CMISSDP
  LINEAR_SOLVER_DIFFUSION_STOP_TIME=1.0001_CMISSDP 
  LINEAR_SOLVER_DIFFUSION_TIME_INCREMENT=0.125_CMISSDP
  !Set result output parameter
  LINEAR_SOLVER_DIFFUSION_OUTPUT_FREQUENCY=1
  !Set solver parameters
  LINEAR_SOLVER_DIFFUSION_DIRECT_FLAG=.FALSE.

  RELATIVE_TOLERANCE=1.0E-10_CMISSDP !default: 1.0E-05_CMISSDP
  ABSOLUTE_TOLERANCE=1.0E-10_CMISSDP !default: 1.0E-10_CMISSDP
  DIVERGENCE_TOLERANCE=1.0E5_CMISSDP !default: 1.0E5
  MAXIMUM_ITERATIONS=10000_CMISSIntg !default: 100000
  RESTART_VALUE=30_CMISSIntg !default: 30
  LINESEARCH_ALPHA=1.0_CMISSDP

  !
  !================================================================================================================================
  !

  !Set diagnostics

  DIAG_LEVEL_LIST(1)=1
  DIAG_LEVEL_LIST(2)=2
  DIAG_LEVEL_LIST(3)=3
  DIAG_LEVEL_LIST(4)=4
  DIAG_LEVEL_LIST(5)=5

!   DIAG_ROUTINE_LIST(1)="DIFFUSION_EQUATION_FINITE_ELEMENT_CALCULATE"
!   DIAG_ROUTINE_LIST(2)="DARCY_EQUATION_PRE_SOLVE_STORE_REFERENCE_DATA"
!   DIAG_ROUTINE_LIST(3)="DARCY_EQUATION_PRE_SOLVE_ALE_UPDATE_MESH"
!   DIAG_ROUTINE_LIST(4)="DARCY_EQUATION_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS"
!   DIAG_ROUTINE_LIST(5)="DARCY_EQUATION_PRE_SOLVE_MAT_PROPERTIES"
!   DIAG_ROUTINE_LIST(6)="GALERKIN_PROJECTION_FINITE_ELEMENT_CALCULATE"
!   DIAG_ROUTINE_LIST(7)="FINITE_ELASTICITY_FINITE_ELEMENT_JACOBIAN_EVALUATE"
!   DIAG_ROUTINE_LIST(8)="FINITE_ELASTICITY_FINITE_ELEMENT_RESIDUAL_EVALUATE"
!   DIAG_ROUTINE_LIST(1)="PROBLEM_SOLVER_EQUATIONS_SOLVE"
!   DIAG_ROUTINE_LIST(1)="SOLVER_NEWTON_SOLVE"
!   DIAG_ROUTINE_LIST(2)="SOLVER_NEWTON_LINESEARCH_SOLVE"
!   DIAG_ROUTINE_LIST(1)="SOLVER_SOLUTION_UPDATE"
!  DIAG_ROUTINE_LIST(1)="FINITE_ELASTICITY_FINITE_ELEMENT_RESIDUAL_EVALUATE"

  !CMISSAllDiagType/CMISSInDiagType/CMISSFromDiagType
!   CALL CMISSDiagnosticsSetOn(CMISSInDiagType,DIAG_LEVEL_LIST,"Diagnostics",DIAG_ROUTINE_LIST,Err)

  !CMISSAllTimingType/CMISSInTimingType/CMISSFromTimingType
  !TIMING_ROUTINE_LIST(1)="PROBLEM_FINITE_ELEMENT_CALCULATE"
  !CALL TIMING_SET_ON(IN_TIMING_TYPE,.TRUE.,"",TIMING_ROUTINE_LIST,ERR,ERROR,*999)

  !
  !================================================================================================================================
  !

  !COORDINATE SYSTEM

  !Start the creation of a new RC coordinate system
  CALL CMISSCoordinateSystemTypeInitialise(CoordinateSystem,Err)
  CALL CMISSCoordinateSystemCreateStart(CoordinateSystemUserNumber,CoordinateSystem,Err)
  !Set the coordinate system dimension
  CALL CMISSCoordinateSystemDimensionSet(CoordinateSystem,NUMBER_OF_DIMENSIONS,Err)
  !Finish the creation of the coordinate system
  CALL CMISSCoordinateSystemCreateFinish(CoordinateSystem,Err)

  !
  !================================================================================================================================
  !

  !REGION
  !For a volume-coupled problem, both concentrations are based in the same region

  !Start the creation of a new region
  CALL CMISSRegionTypeInitialise(Region,Err)
  CALL CMISSRegionCreateStart(RegionUserNumber,WorldRegion,Region,Err)
  !Set the regions coordinate system as defined above
  CALL CMISSRegionCoordinateSystemSet(Region,CoordinateSystem,Err)
  !Finish the creation of the region
  CALL CMISSRegionCreateFinish(Region,Err)

  !
  !================================================================================================================================
  !

  !BASES

  !Start the creation of new bases: Geometry
  MESH_NUMBER_OF_COMPONENTS=1
  CALL CMISSBasisTypeInitialise(BasisGeometry,Err)
  CALL CMISSBasisCreateStart(BASIS_NUMBER_GEOMETRY,BasisGeometry,Err)
  !Set the basis type (Lagrange/Simplex)
  CALL CMISSBasisTypeSet(BasisGeometry,BASIS_TYPE,Err)
  !Set the basis xi number
  CALL CMISSBasisNumberOfXiSet(BasisGeometry,NUMBER_OF_DIMENSIONS,Err)
  !Set the basis xi interpolation and number of Gauss points
  IF(NUMBER_OF_DIMENSIONS==2) THEN
    CALL CMISSBasisInterpolationXiSet(BasisGeometry,(/BASIS_XI_INTERPOLATION_GEOMETRY,BASIS_XI_INTERPOLATION_GEOMETRY/),Err)
    CALL CMISSBasisQuadratureNumberOfGaussXiSet(BasisGeometry,(/BASIS_XI_GAUSS_GEOMETRY,BASIS_XI_GAUSS_GEOMETRY/),Err)
  ELSE IF(NUMBER_OF_DIMENSIONS==3) THEN
    CALL CMISSBasisInterpolationXiSet(BasisGeometry,(/BASIS_XI_INTERPOLATION_GEOMETRY,BASIS_XI_INTERPOLATION_GEOMETRY, & 
      & BASIS_XI_INTERPOLATION_GEOMETRY/),Err)                         
    CALL CMISSBasisQuadratureNumberOfGaussXiSet(BasisGeometry,(/BASIS_XI_GAUSS_GEOMETRY,BASIS_XI_GAUSS_GEOMETRY, &
      & BASIS_XI_GAUSS_GEOMETRY/),Err)
  ENDIF
  !Finish the creation of the basis
  CALL CMISSBasisCreateFinish(BasisGeometry,Err)
  !
  !Start the creation of another basis: Concentration_One
  IF(BASIS_XI_INTERPOLATION_CONC_ONE==BASIS_XI_INTERPOLATION_GEOMETRY) THEN
    BasisConcOne=BasisGeometry
  ELSE
    MESH_NUMBER_OF_COMPONENTS=MESH_NUMBER_OF_COMPONENTS+1
    !Initialise a new velocity basis
    CALL CMISSBasisTypeInitialise(BasisConcOne,Err)
    !Start the creation of a basis
    CALL CMISSBasisCreateStart(BASIS_NUMBER_CONC_ONE,BasisConcOne,Err)
    !Set the basis type (Lagrange/Simplex)
    CALL CMISSBasisTypeSet(BasisConcOne,BASIS_TYPE,Err)
    !Set the basis xi number
    CALL CMISSBasisNumberOfXiSet(BasisConcOne,NUMBER_OF_DIMENSIONS,Err)
    !Set the basis xi interpolation and number of Gauss points
    IF(NUMBER_OF_DIMENSIONS==2) THEN
      CALL CMISSBasisInterpolationXiSet(BasisConcOne,(/BASIS_XI_INTERPOLATION_CONC_ONE,BASIS_XI_INTERPOLATION_CONC_ONE/),Err)
      CALL CMISSBasisQuadratureNumberOfGaussXiSet(BasisConcOne,(/BASIS_XI_GAUSS_CONC_ONE,BASIS_XI_GAUSS_CONC_ONE/),Err)
    ELSE IF(NUMBER_OF_DIMENSIONS==3) THEN
      CALL CMISSBasisInterpolationXiSet(BasisConcOne,(/BASIS_XI_INTERPOLATION_CONC_ONE,BASIS_XI_INTERPOLATION_CONC_ONE, & 
        & BASIS_XI_INTERPOLATION_CONC_ONE/),Err)                         
      CALL CMISSBasisQuadratureNumberOfGaussXiSet(BasisConcOne,(/BASIS_XI_GAUSS_CONC_ONE,BASIS_XI_GAUSS_CONC_ONE, & 
        & BASIS_XI_GAUSS_CONC_ONE/),Err)
    ENDIF
    !Finish the creation of the basis
    CALL CMISSBasisCreateFinish(BasisConcOne,Err)
  ENDIF
  !
  !Start the creation of another basis: Concentration_Two
  IF(BASIS_XI_INTERPOLATION_CONC_TWO==BASIS_XI_INTERPOLATION_GEOMETRY) THEN
    BasisConcTwo=BasisGeometry
  ELSE IF(BASIS_XI_INTERPOLATION_CONC_TWO==BASIS_XI_INTERPOLATION_CONC_ONE) THEN
    BasisConcTwo=BasisConcOne
  ELSE
    MESH_NUMBER_OF_COMPONENTS=MESH_NUMBER_OF_COMPONENTS+1
    !Initialise a new concentration basis
    CALL CMISSBasisTypeInitialise(BasisConcTwo,Err)
    !Start the creation of a basis
    CALL CMISSBasisCreateStart(BASIS_NUMBER_CONC_TWO,BasisConcTwo,Err)
    !Set the basis type (Lagrange/Simplex)
    CALL CMISSBasisTypeSet(BasisConcTwo,BASIS_TYPE,Err)
    !Set the basis xi number
    CALL CMISSBasisNumberOfXiSet(BasisConcTwo,NUMBER_OF_DIMENSIONS,Err)
    !Set the basis xi interpolation and number of Gauss points
    IF(NUMBER_OF_DIMENSIONS==2) THEN
      CALL CMISSBasisInterpolationXiSet(BasisConcTwo,(/BASIS_XI_INTERPOLATION_CONC_TWO,BASIS_XI_INTERPOLATION_CONC_TWO/),Err)
      CALL CMISSBasisQuadratureNumberOfGaussXiSet(BasisConcTwo,(/BASIS_XI_GAUSS_CONC_TWO,BASIS_XI_GAUSS_CONC_TWO/),Err)
    ELSE IF(NUMBER_OF_DIMENSIONS==3) THEN
      CALL CMISSBasisInterpolationXiSet(BasisConcTwo,(/BASIS_XI_INTERPOLATION_CONC_TWO,BASIS_XI_INTERPOLATION_CONC_TWO, & 
        & BASIS_XI_INTERPOLATION_CONC_TWO/),Err)                         
      CALL CMISSBasisQuadratureNumberOfGaussXiSet(BasisConcTwo,(/BASIS_XI_GAUSS_CONC_TWO,BASIS_XI_GAUSS_CONC_TWO, & 
        & BASIS_XI_GAUSS_CONC_TWO/),Err)
    ENDIF
    !Finish the creation of the basis
    CALL CMISSBasisCreateFinish(BasisConcTwo,Err)
  ENDIF

    BasisConcThree=BasisGeometry

  !
  !================================================================================================================================
  !

  !MESH
  !All types of physics utilize the same "mesh", but may be represented on individual mesh components.

  TotalNumberOfSolidNodes = NUMBER_OF_NODES_GEOMETRY
  TOTAL_NUMBER_OF_ALL_NODES = TOTAL_NUMBER_OF_NODES + TotalNumberOfSolidNodes

!   NumberOfSolidMeshComponents = 1
!   MESH_NUMBER_OF_ALL_COMPONENTS = MESH_NUMBER_OF_COMPONENTS + NumberOfSolidMeshComponents
  MESH_NUMBER_OF_ALL_COMPONENTS = MESH_NUMBER_OF_COMPONENTS

  !Start the creation of mesh nodes
  CALL CMISSNodesTypeInitialise(Nodes,Err)
  CALL CMISSNodesCreateStart(Region,TOTAL_NUMBER_OF_ALL_NODES,Nodes,Err)
  CALL CMISSNodesCreateFinish(Nodes,Err)
  !Start the creation of the mesh
  CALL CMISSMeshTypeInitialise(Mesh,Err)
  CALL CMISSMeshCreateStart(MeshUserNumber,Region,NUMBER_OF_DIMENSIONS,Mesh,Err)
  !Set number of mesh elements
  CALL CMISSMeshNumberOfElementsSet(Mesh,TOTAL_NUMBER_OF_ELEMENTS,Err)
  !Set number of mesh components
  CALL CMISSMeshNumberOfComponentsSet(Mesh,MESH_NUMBER_OF_ALL_COMPONENTS,Err)
  !
  CALL CMISSMeshElementsTypeInitialise(MeshElementsGeometry,Err)
  CALL CMISSMeshElementsTypeInitialise(MeshElementsConcOne,Err)
  CALL CMISSMeshElementsTypeInitialise(MeshElementsConcTwo,Err)
  CALL CMISSMeshElementsTypeInitialise(MeshElementsConcThree,Err)
  MESH_COMPONENT_NUMBER_GEOMETRY=1
  MESH_COMPONENT_NUMBER_CONC_ONE=1
  MESH_COMPONENT_NUMBER_CONC_TWO=1
  MESH_COMPONENT_NUMBER_CONC_THREE=1
  !Specify spatial mesh component
  CALL CMISSMeshElementsCreateStart(Mesh,MESH_COMPONENT_NUMBER_GEOMETRY,BasisGeometry,MeshElementsGeometry,Err)
  DO ELEMENT_NUMBER=1,TOTAL_NUMBER_OF_ELEMENTS
    CALL CMISSMeshElementsNodesSet(MeshElementsGeometry,ELEMENT_NUMBER,CM%M(ELEMENT_NUMBER,1:NUMBER_OF_ELEMENT_NODES_GEOMETRY),Err)
  ENDDO
  CALL CMISSMeshElementsCreateFinish(MeshElementsGeometry,Err)
  !Specify concentration one mesh component
! !  IF(BASIS_XI_INTERPOLATION_CONC_ONE==BASIS_XI_INTERPOLATION_GEOMETRY) THEN
!     MeshElementsConcOne=MeshElementsGeometry
! !   ELSE
! !     MESH_COMPONENT_NUMBER_CONC_ONE=MESH_COMPONENT_NUMBER_GEOMETRY+1
!      CALL CMISSMeshElementsCreateStart(Mesh,MESH_COMPONENT_NUMBER_CONC_ONE,BasisConcOne,MeshElementsConcOne,Err)
! !     DO ELEMENT_NUMBER=1,TOTAL_NUMBER_OF_ELEMENTS
! !       CALL CMISSMeshElementsNodesSet(MeshElementsConcOne,ELEMENT_NUMBER,CM%V(ELEMENT_NUMBER, & 
! !         & 1:NUMBER_OF_ELEMENT_NODES_CONC_ONE),Err)
! !     ENDDO
!     CALL CMISSMeshElementsCreateFinish(MeshElementsConcOne,Err)
! !  ENDIF
!   !Specify concentration two mesh component
! !  IF(BASIS_XI_INTERPOLATION_CONC_TWO==BASIS_XI_INTERPOLATION_GEOMETRY) THEN
!     MeshElementsConcTwo=MeshElementsGeometry
! !    MESH_COMPONENT_NUMBER_CONC_TWO=MESH_COMPONENT_NUMBER_GEOMETRY
! !  ELSE IF(BASIS_XI_INTERPOLATION_CONC_TWO==BASIS_XI_INTERPOLATION_CONC_ONE) THEN
! !    MeshElementsConcTwo=MeshElementsConcOne
! !    MESH_COMPONENT_NUMBER_CONC_TWO=MESH_COMPONENT_NUMBER_CONC_ONE
! !  ELSE
! !    MESH_COMPONENT_NUMBER_CONC_TWO=MESH_COMPONENT_NUMBER_CONC_ONE+1
!     CALL CMISSMeshElementsCreateStart(Mesh,MESH_COMPONENT_NUMBER_CONC_TWO,BasisConcTwo,MeshElementsConcTwo,Err)
! !    DO ELEMENT_NUMBER=1,TOTAL_NUMBER_OF_ELEMENTS
! !      CALL CMISSMeshElementsNodesSet(MeshElementsConcTwo,ELEMENT_NUMBER,CM%P(ELEMENT_NUMBER, & 
! !        & 1:NUMBER_OF_ELEMENT_NODES_CONC_TWO),Err)
! !    ENDDO
!     CALL CMISSMeshElementsCreateFinish(MeshElementsConcTwo,Err)
!  ! ENDIF
!   !Specify concentration three mesh component
! !  IF(BASIS_XI_INTERPOLATION_CONC_THREE==BASIS_XI_INTERPOLATION_GEOMETRY) THEN
!     MeshElementsConcThree=MeshElementsGeometry
! !    MESH_COMPONENT_NUMBER_CONC_THREE=MESH_COMPONENT_NUMBER_GEOMETRY
! !   ELSE IF(BASIS_XI_INTERPOLATION_CONC_THREE==BASIS_XI_INTERPOLATION_CONC_ONE) THEN
! !     MeshElementsConcThree=MeshElementsConcOne
! !    MESH_COMPONENT_NUMBER_CONC_THREE=MESH_COMPONENT_NUMBER_CONC_ONE
! !  ELSE
! !    MESH_COMPONENT_NUMBER_CONC_TWO=MESH_COMPONENT_NUMBER_CONC_ONE+1
!     CALL CMISSMeshElementsCreateStart(Mesh,MESH_COMPONENT_NUMBER_CONC_THREE,BasisConcThree,MeshElementsConcThree,Err)
! !    DO ELEMENT_NUMBER=1,TOTAL_NUMBER_OF_ELEMENTS
! !      CALL CMISSMeshElementsNodesSet(MeshElementsConcTwo,ELEMENT_NUMBER,CM%P(ELEMENT_NUMBER, & 
! !        & 1:NUMBER_OF_ELEMENT_NODES_CONC_TWO),Err)
! !    ENDDO
!     CALL CMISSMeshElementsCreateFinish(MeshElementsConcThree,Err)
! !  ENDIF

  !Finish the creation of the mesh
  CALL CMISSMeshCreateFinish(Mesh,Err)

  !
  !================================================================================================================================
  !

  !GEOMETRIC FIELD

  !Create a decomposition:
  !All mesh components share the same decomposition
  CALL CMISSDecompositionTypeInitialise(Decomposition,Err)
  CALL CMISSDecompositionCreateStart(DecompositionUserNumber,Mesh,Decomposition,Err)
  !Set the decomposition to be a general decomposition with the specified number of domains
  CALL CMISSDecompositionTypeSet(Decomposition,CMISSDecompositionCalculatedType,Err)
  CALL CMISSDecompositionNumberOfDomainsSet(Decomposition,NumberOfUserDomains,Err)
  !Finish the decomposition
  CALL CMISSDecompositionCreateFinish(Decomposition,Err)

  !Start to create a default (geometric) field on the region
  CALL CMISSFieldTypeInitialise(GeometricField,Err)
  CALL CMISSFieldCreateStart(GeometricFieldUserNumber,Region,GeometricField,Err)
  !Set the field type
  CALL CMISSFieldTypeSet(GeometricField,CMISSFieldGeometricType,Err)
  !Set the decomposition to use
  CALL CMISSFieldMeshDecompositionSet(GeometricField,Decomposition,Err)
  !Set the scaling to use
  CALL CMISSFieldScalingTypeSet(GeometricField,CMISSFieldNoScaling,Err)

  DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS
    CALL CMISSFieldComponentMeshComponentSet(GeometricField,CMISSFieldUVariableType,COMPONENT_NUMBER, & 
      & MESH_COMPONENT_NUMBER_GEOMETRY,Err)
  ENDDO
   WRITE(*,'(A)') "now finishing creating geometric field"
  !Finish creating the field
  CALL CMISSFieldCreateFinish(GeometricField,Err)
  !Update the geometric field parameters
  DO NODE_NUMBER=1,NUMBER_OF_NODES_GEOMETRY
    DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS
      VALUE=CM%N(NODE_NUMBER,COMPONENT_NUMBER)
      CALL CMISSFieldParameterSetUpdateNode(GeometricField,CMISSFieldUVariableType,CMISSFieldValuesSetType, & 
        & CMISSNoGlobalDerivative,NODE_NUMBER,COMPONENT_NUMBER,VALUE,Err)
    ENDDO
  ENDDO
  CALL CMISSFieldParameterSetUpdateStart(GeometricField,CMISSFieldUVariableType,CMISSFieldValuesSetType,Err)
  CALL CMISSFieldParameterSetUpdateFinish(GeometricField,CMISSFieldUVariableType,CMISSFieldValuesSetType,Err)
  WRITE(*,'(A)') "geometric field made"
  !
  !================================================================================================================================
  !
 !
  !================================================================================================================================
  !
  !EQUATIONS SETS
  !Create the equations set for diffusion_one
  CALL CMISSEquationsSetTypeInitialise(EquationsSetDiffusionOne,Err)
  CALL CMISSEquationsSetCreateStart(EquationsSetUserNumberDiffusionOne,Region,GeometricField,EquationsSetDiffusionOne,Err)
  !Set the equations set to be a constant source diffusion problem
  CALL CMISSEquationsSetSpecificationSet(EquationsSetDiffusionOne,CMISSEquationsSetClassicalFieldClass, &
    & CMISSEquationsSetDiffusionEquationType,CMISSEquationsSetMultiCompTransportDiffusionSubtype,Err)
  !Finish creating the equations set
  CALL CMISSEquationsSetCreateFinish(EquationsSetDiffusionOne,Err)
  !Create the equations set for diffusion_two
  CALL CMISSEquationsSetTypeInitialise(EquationsSetDiffusionTwo,Err)
  CALL CMISSEquationsSetCreateStart(EquationsSetUserNumberDiffusionTwo,Region,GeometricField,EquationsSetDiffusionTwo,Err)
  !Set the equations set to be a constant source diffusion problem
  CALL CMISSEquationsSetSpecificationSet(EquationsSetDiffusionTwo,CMISSEquationsSetClassicalFieldClass, &
    & CMISSEquationsSetDiffusionEquationType,CMISSEquationsSetMultiCompTransportDiffusionSubtype,Err)
  !Finish creating the equations set
  CALL CMISSEquationsSetCreateFinish(EquationsSetDiffusionTwo,Err)
  !Create the equations set for diffusion_three
  CALL CMISSEquationsSetTypeInitialise(EquationsSetDiffusionThree,Err)
  CALL CMISSEquationsSetCreateStart(EquationsSetUserNumberDiffusionThree,Region,GeometricField,EquationsSetDiffusionThree,Err)
  !Set the equations set to be a constant source diffusion problem
  CALL CMISSEquationsSetSpecificationSet(EquationsSetDiffusionThree,CMISSEquationsSetClassicalFieldClass, &
    & CMISSEquationsSetDiffusionEquationType,CMISSEquationsSetMultiCompTransportDiffusionSubtype,Err)
  !Finish creating the equations set
  CALL CMISSEquationsSetCreateFinish(EquationsSetDiffusionThree,Err)

  !-------------------------------------------------------------------------------------
  ! DEPENDENT FIELD: Shared. We're gonna create the dependent field manually for now
  ! U1 & DEL_U1_DEL_N: Diffusion-one
  ! U2 & DEL_U2_DEL_N: Diffusion-two
  ! U3 & DEL_U3_DEL_N: Diffusion-three
  CALL CMISSFieldTypeInitialise(DependentField,Err)
    ! -- Advection-diffusion
    CALL CMISSFieldCreateStart(DependentFieldUserNumber,Region,DependentField,Err)
    CALL CMISSFieldTypeSet(DependentField,CMISSFieldGeneralType,Err)  
    CALL CMISSFieldMeshDecompositionSet(DependentField,Decomposition,Err)
    CALL CMISSFieldGeometricFieldSet(DependentField,GeometricField,Err) 
    CALL CMISSFieldDependentTypeSet(DependentField,CMISSFieldDependentType,Err) 
     CALL CMISSFieldNumberOfVariablesSet(DependentField,6,Err)
     CALL CMISSFieldVariableTypesSet(DependentField,&
      & (/CMISSFieldU1VariableType,CMISSFieldDelU1DelNVariableType,CMISSFieldU2VariableType,&
      & CMISSFieldDelU2DelNVariableType,CMISSFieldU3VariableType,CMISSFieldDelU3DelNVariableType/),Err)
   WRITE(*,'(A)') "set number of variables"
     CALL CMISSFieldDimensionSet(DependentField,CMISSFieldU1VariableType, &
                   & CMISSFieldScalarDimensionType,Err)
     CALL CMISSFieldDimensionSet(DependentField,CMISSFieldDelU1DelNVariableType, &
                   & CMISSFieldScalarDimensionType,Err)
     CALL CMISSFieldDimensionSet(DependentField,CMISSFieldU2VariableType, &
                   & CMISSFieldScalarDimensionType,Err)
     CALL CMISSFieldDimensionSet(DependentField,CMISSFieldDelU2DelNVariableType, &
                   & CMISSFieldScalarDimensionType,Err)
     CALL CMISSFieldDimensionSet(DependentField,CMISSFieldU3VariableType, &
                   & CMISSFieldScalarDimensionType,Err)
     CALL CMISSFieldDimensionSet(DependentField,CMISSFieldDelU3DelNVariableType, &
                   & CMISSFieldScalarDimensionType,Err)


     CALL CMISSFieldNumberOfComponentsSet(DependentField,CMISSFieldU1VariableType,1,Err)
     CALL CMISSFieldNumberOfComponentsSet(DependentField,CMISSFieldDelU1DelNVariableType,1,Err)
      CALL CMISSFieldComponentMeshComponentSet(DependentField,CMISSFieldU1VariableType,1, & 
        & MESH_COMPONENT_NUMBER_CONC_ONE,Err)
      CALL CMISSFieldComponentMeshComponentSet(DependentField,CMISSFieldDelU1DelNVariableType,1, & 
        & MESH_COMPONENT_NUMBER_CONC_ONE,Err)

     CALL CMISSFieldNumberOfComponentsSet(DependentField,CMISSFieldU2VariableType,1,Err)
     CALL CMISSFieldNumberOfComponentsSet(DependentField,CMISSFieldDelU2DelNVariableType,1,Err)
      CALL CMISSFieldComponentMeshComponentSet(DependentField,CMISSFieldU2VariableType,1, & 
        & MESH_COMPONENT_NUMBER_CONC_TWO,Err)
      CALL CMISSFieldComponentMeshComponentSet(DependentField,CMISSFieldDelU2DelNVariableType,1, & 
        & MESH_COMPONENT_NUMBER_CONC_TWO,Err)

     CALL CMISSFieldNumberOfComponentsSet(DependentField,CMISSFieldU3VariableType,1,Err)
     CALL CMISSFieldNumberOfComponentsSet(DependentField,CMISSFieldDelU3DelNVariableType,1,Err)
      CALL CMISSFieldComponentMeshComponentSet(DependentField,CMISSFieldU3VariableType,1, & 
        & MESH_COMPONENT_NUMBER_CONC_THREE,Err)
      CALL CMISSFieldComponentMeshComponentSet(DependentField,CMISSFieldDelU3DelNVariableType,1, & 
        & MESH_COMPONENT_NUMBER_CONC_THREE,Err)


  CALL CMISSFieldCreateFinish(DependentField,Err)
  WRITE(*,'(A)') "field created"
 


  !DEPENDENT FIELDS


!  CALL CMISSFieldTypeInitialise(DependentFieldDiffusion,Err)
  CALL CMISSEquationsSetDependentCreateStart(EquationsSetDiffusionOne,DependentFieldUserNumber, & 
    & DependentField,Err)
  !Set the mesh component to be used by the field components.
!   DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS
!     CALL CMISSFieldComponentMeshComponentSet(DependentFieldDiffusionTwo,CMISSFieldUVariableType,COMPONENT_NUMBER, & 
!       & MESH_COMPONENT_NUMBER_CONC_TWO,Err)
!     CALL CMISSFieldComponentMeshComponentSet(DependentFieldDiffusionTwo,CMISSFieldDeludelnVariableType,COMPONENT_NUMBER, & 
!       & MESH_COMPONENT_NUMBER_CONC_TWO,Err)
!   ENDDO
  !Finish the equations set dependent field variables
  CALL CMISSEquationsSetDependentCreateFinish(EquationsSetDiffusionOne,Err)
!  CALL CMISSFieldTypeInitialise(DependentFieldDiffusion,Err)
  CALL CMISSEquationsSetDependentCreateStart(EquationsSetDiffusionTwo,DependentFieldUserNumber, & 
    & DependentField,Err)
  !Set the mesh component to be used by the field components.
!   DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS
!     CALL CMISSFieldComponentMeshComponentSet(DependentFieldDiffusionTwo,CMISSFieldUVariableType,COMPONENT_NUMBER, & 
!       & MESH_COMPONENT_NUMBER_CONC_TWO,Err)
!     CALL CMISSFieldComponentMeshComponentSet(DependentFieldDiffusionTwo,CMISSFieldDeludelnVariableType,COMPONENT_NUMBER, & 
!       & MESH_COMPONENT_NUMBER_CONC_TWO,Err)
!   ENDDO
  !Finish the equations set dependent field variables
  CALL CMISSEquationsSetDependentCreateFinish(EquationsSetDiffusionTwo,Err)
!  CALL CMISSFieldTypeInitialise(DependentFieldDiffusion,Err)
  CALL CMISSEquationsSetDependentCreateStart(EquationsSetDiffusionThree,DependentFieldUserNumber, & 
    & DependentField,Err)
  !Set the mesh component to be used by the field components.
!   DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS
!     CALL CMISSFieldComponentMeshComponentSet(DependentFieldDiffusionTwo,CMISSFieldUVariableType,COMPONENT_NUMBER, & 
!       & MESH_COMPONENT_NUMBER_CONC_TWO,Err)
!     CALL CMISSFieldComponentMeshComponentSet(DependentFieldDiffusionTwo,CMISSFieldDeludelnVariableType,COMPONENT_NUMBER, & 
!       & MESH_COMPONENT_NUMBER_CONC_TWO,Err)
!   ENDDO
  !Finish the equations set dependent field variables
  CALL CMISSEquationsSetDependentCreateFinish(EquationsSetDiffusionThree,Err)



  !-------------------------------------------------------------------------------------
  ! INITIALISE DEPENDENT FIELDS


!   !Initialise dependent field (concentration one components)
!   CALL CMISSFieldComponentValuesInitialise(DependentField,CMISSFieldU1VariableType,CMISSFieldValuesSetType, & 
!     & 1,INITIAL_FIELD_DIFFUSION_ONE,Err)

!   !Initialise dependent field (concentration two components)
!   CALL CMISSFieldComponentValuesInitialise(DependentField,CMISSFieldU2VariableType,CMISSFieldValuesSetType, & 
!     & 1,INITIAL_FIELD_DIFFUSION_TWO,Err)

!   !Initialise dependent field (concentration three components)
!   CALL CMISSFieldComponentValuesInitialise(DependentField,CMISSFieldU3VariableType,CMISSFieldValuesSetType, & 
!     & 1,INITIAL_FIELD_DIFFUSION_THREE,Err)




  !
  !================================================================================================================================
  !

  !MATERIALS FIELDS

  CALL CMISSFieldTypeInitialise(MaterialsFieldDiffusionOne,Err)
  CALL CMISSEquationsSetMaterialsCreateStart(EquationsSetDiffusionOne,&
    & MaterialsFieldUserNumberDiffusionOne,MaterialsFieldDiffusionOne,Err)
  !Finish the equations set dependent field variables
  CALL CMISSEquationsSetMaterialsCreateFinish(EquationsSetDiffusionOne,Err)

  CALL CMISSFieldTypeInitialise(MaterialsFieldDiffusionTwo,Err)
  CALL CMISSEquationsSetMaterialsCreateStart(EquationsSetDiffusionTwo,&
    & MaterialsFieldUserNumberDiffusionTwo,MaterialsFieldDiffusionTwo,Err)
  !Finish the equations set dependent field variables
  CALL CMISSEquationsSetMaterialsCreateFinish(EquationsSetDiffusionTwo,Err)

  CALL CMISSFieldTypeInitialise(MaterialsFieldDiffusionThree,Err)
  CALL CMISSEquationsSetMaterialsCreateStart(EquationsSetDiffusionThree,&
    & MaterialsFieldUserNumberDiffusionThree,MaterialsFieldDiffusionThree,Err)
  !Finish the equations set dependent field variables
  CALL CMISSEquationsSetMaterialsCreateFinish(EquationsSetDiffusionThree,Err)


!   CALL CMISSFieldComponentValuesInitialise(MaterialsFieldDiffusionOne,CMISSFieldUVariableType,CMISSFieldValuesSetType, & 
!     & MaterialsFieldUserNumberDiffusionOne,POROSITY_PARAM_MAT_PROPERTIES,Err)
!   CALL CMISSFieldComponentValuesInitialise(MaterialsFieldDiffusionTwo,CMISSFieldUVariableType,CMISSFieldValuesSetType, & 
!     & MaterialsFieldUserNumberMatPropertiesPermOverVis,PERM_OVER_VIS_PARAM_MAT_PROPERTIES,Err)
  !
  !================================================================================================================================
  !

  !
  !================================================================================================================================
  !

  !SOURCE FIELDS

   !create the equations set source field variables for both equations sets 
  !Create the equations set source field variables
  !Create the equations set source field variables
  CALL CMISSFieldTypeInitialise(SourceFieldDiffusionOne,Err)
  CALL CMISSEquationsSetSourceCreateStart(EquationsSetDiffusionOne,SourceFieldUserNumberDiffusionOne,SourceFieldDiffusionOne,Err)
  !Finish the equations set dependent field variables
  CALL CMISSEquationsSetSourceCreateFinish(EquationsSetDiffusionOne,Err)

  CALL CMISSFieldTypeInitialise(SourceFieldDiffusionTwo,Err)
  CALL CMISSEquationsSetSourceCreateStart(EquationsSetDiffusionTwo,SourceFieldUserNumberDiffusionTwo,SourceFieldDiffusionTwo,Err)
  !Finish the equations set dependent field variables
  CALL CMISSEquationsSetSourceCreateFinish(EquationsSetDiffusionTwo,Err)

  CALL CMISSFieldTypeInitialise(SourceFieldDiffusionThree,Err)
  CALL CMISSEquationsSetSourceCreateStart(EquationsSetDiffusionThree,SourceFieldUserNumberDiffusionThree,&
        & SourceFieldDiffusionThree,Err)
  !Finish the equations set dependent field variables
  CALL CMISSEquationsSetSourceCreateFinish(EquationsSetDiffusionThree,Err)

  !
  !================================================================================================================================
  !

  !EQUATIONS

  WRITE(*,'(A)') "Creating equations set equations."

  !Create the equations set equations
  CALL CMISSEquationsTypeInitialise(EquationsDiffusionOne,Err)
  CALL CMISSEquationsSetEquationsCreateStart(EquationsSetDiffusionOne,EquationsDiffusionOne,Err)
  !Set the equations matrices sparsity type
  CALL CMISSEquationsSparsityTypeSet(EquationsDiffusionOne,CMISSEquationsSparseMatrices,Err)
!   !Set the equations lumping type
!   CALL CMISSEquationsLumpingTypeSet(EquationsDarcy,CMISSEquationsUnlumpedMatrices,Err)
  !Set the equations set output
  CALL CMISSEquationsOutputTypeSet(EquationsDiffusionOne,EQUATIONS_DIFFUSION_ONE_OUTPUT,Err)
  !Finish the equations set equations
  CALL CMISSEquationsSetEquationsCreateFinish(EquationsSetDiffusionOne,Err)

  !Create the equations set equations
  CALL CMISSEquationsTypeInitialise(EquationsDiffusionTwo,Err)
  CALL CMISSEquationsSetEquationsCreateStart(EquationsSetDiffusionTwo,EquationsDiffusionTwo,Err)
  !Set the equations matrices sparsity type
  CALL CMISSEquationsSparsityTypeSet(EquationsDiffusionTwo,CMISSEquationsSparseMatrices,Err)
!   !Set the equations lumping type
!   CALL CMISSEquationsLumpingTypeSet(EquationsDarcy,CMISSEquationsUnlumpedMatrices,Err)
  !Set the equations set output
  CALL CMISSEquationsOutputTypeSet(EquationsDiffusionTwo,EQUATIONS_DIFFUSION_TWO_OUTPUT,Err)
  !Finish the equations set equations
  CALL CMISSEquationsSetEquationsCreateFinish(EquationsSetDiffusionTwo,Err)

  !Create the equations set equations
  CALL CMISSEquationsTypeInitialise(EquationsDiffusionThree,Err)
  CALL CMISSEquationsSetEquationsCreateStart(EquationsSetDiffusionThree,EquationsDiffusionThree,Err)
  !Set the equations matrices sparsity type
  CALL CMISSEquationsSparsityTypeSet(EquationsDiffusionThree,CMISSEquationsSparseMatrices,Err)
!   !Set the equations lumping type
!   CALL CMISSEquationsLumpingTypeSet(EquationsDarcy,CMISSEquationsUnlumpedMatrices,Err)
  !Set the equations set output
  CALL CMISSEquationsOutputTypeSet(EquationsDiffusionThree,EQUATIONS_DIFFUSION_THREE_OUTPUT,Err)
  !Finish the equations set equations
  CALL CMISSEquationsSetEquationsCreateFinish(EquationsSetDiffusionThree,Err)

  !
  !================================================================================================================================
  !

!--------------------------------------------------------------------------------------------------------------------------------

  !BOUNDARY CONDITIONS
  !Start the creation of the equations set boundary conditions for advection-diffusion

  !Start the creation of the equations set boundary conditions for diffusion
  CALL CMISSBoundaryConditionsTypeInitialise(BoundaryConditionsDiffusionOne,Err)
  CALL CMISSEquationsSetBoundaryConditionsCreateStart(EquationsSetDiffusionOne,BoundaryConditionsDiffusionOne,Err)
  IF(INLET_WALL_NODES_DIFFUSION_ONE_FLAG) THEN
    DO NODE_COUNTER=1,NUMBER_OF_INLET_WALL_NODES_DIFFUSION_ONE
      NODE_NUMBER=INLET_WALL_NODES_DIFFUSION_ONE(NODE_COUNTER)
      CONDITION=CMISSBoundaryConditionFixed
!       DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS
        VALUE=0.2_CMISSDP
        CALL CMISSBoundaryConditionsSetNode(BoundaryConditionsDiffusionOne,CMISSFieldU1VariableType,CMISSNoGlobalDerivative, & 
          & NODE_NUMBER,MESH_COMPONENT_NUMBER_CONC_ONE,CONDITION,VALUE,Err)
!       ENDDO
    ENDDO
  ENDIF
  !Finish the creation of the equations set boundary conditions for diffusion
  CALL CMISSEquationsSetBoundaryConditionsCreateFinish(EquationsSetDiffusionOne,Err)

  CALL CMISSBoundaryConditionsTypeInitialise(BoundaryConditionsDiffusionTwo,Err)
  CALL CMISSEquationsSetBoundaryConditionsCreateStart(EquationsSetDiffusionTwo,BoundaryConditionsDiffusionTwo,Err)
  IF(INLET_WALL_NODES_DIFFUSION_TWO_FLAG) THEN
    DO NODE_COUNTER=1,NUMBER_OF_INLET_WALL_NODES_DIFFUSION_TWO
      NODE_NUMBER=INLET_WALL_NODES_DIFFUSION_TWO(NODE_COUNTER)
      CONDITION=CMISSBoundaryConditionFixed
!       DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS
        VALUE=0.2_CMISSDP
        CALL CMISSBoundaryConditionsSetNode(BoundaryConditionsDiffusionTwo,CMISSFieldU2VariableType,CMISSNoGlobalDerivative, & 
          & NODE_NUMBER,MESH_COMPONENT_NUMBER_CONC_TWO,CONDITION,VALUE,Err)
!       ENDDO
    ENDDO
  ENDIF
  !Finish the creation of the equations set boundary conditions for diffusion
  CALL CMISSEquationsSetBoundaryConditionsCreateFinish(EquationsSetDiffusionTwo,Err)

  CALL CMISSBoundaryConditionsTypeInitialise(BoundaryConditionsDiffusionThree,Err)
  CALL CMISSEquationsSetBoundaryConditionsCreateStart(EquationsSetDiffusionThree,BoundaryConditionsDiffusionThree,Err)
  IF(INLET_WALL_NODES_DIFFUSION_THREE_FLAG) THEN
    DO NODE_COUNTER=1,NUMBER_OF_INLET_WALL_NODES_DIFFUSION_THREE
      NODE_NUMBER=INLET_WALL_NODES_DIFFUSION_THREE(NODE_COUNTER)
      CONDITION=CMISSBoundaryConditionFixed
!       DO COMPONENT_NUMBER=1,NUMBER_OF_DIMENSIONS
        VALUE=0.2_CMISSDP
        CALL CMISSBoundaryConditionsSetNode(BoundaryConditionsDiffusionThree,CMISSFieldU3VariableType,CMISSNoGlobalDerivative, & 
          & NODE_NUMBER,MESH_COMPONENT_NUMBER_CONC_THREE,CONDITION,VALUE,Err)
!       ENDDO
    ENDDO
  ENDIF
  !Finish the creation of the equations set boundary conditions for diffusion
  CALL CMISSEquationsSetBoundaryConditionsCreateFinish(EquationsSetDiffusionThree,Err)


  !
  !
  !================================================================================================================================
  !

  WRITE(*,'(A)') "start creation of a problem"
  !PROBLEMS

  !Start the creation of a problem.
  CALL CMISSProblemTypeInitialise(Problem,Err)
  CALL CMISSControlLoopTypeInitialise(ControlLoop,Err)
  CALL CMISSProblemCreateStart(ProblemUserNumber,Problem,Err)
  !Set the problem to be a coupled diffusion-diffusion problem
  CALL CMISSProblemSpecificationSet(Problem,CMISSProblemMultiPhysicsClass,CMISSProblemMultiCompartmentTransportType, &
    & CMISSProblemStandardMultiCompartmentTransportSubtype,Err)
  !Finish the creation of a problem.
  CALL CMISSProblemCreateFinish(Problem,Err)
  !Start the creation of the problem control loop
  CALL CMISSProblemControlLoopCreateStart(Problem,Err)
  !Get the control loop
  CALL CMISSProblemControlLoopGet(Problem,CMISSControlLoopNode,ControlLoop,Err)
  !Set the times
  CALL CMISSControlLoopTimesSet(ControlLoop,LINEAR_SOLVER_DIFFUSION_START_TIME,&
    & LINEAR_SOLVER_DIFFUSION_STOP_TIME,LINEAR_SOLVER_DIFFUSION_TIME_INCREMENT,Err)
  !Set the output timing
  CALL CMISSControlLoopTimeOutputSet(ControlLoop,LINEAR_SOLVER_DIFFUSION_OUTPUT_FREQUENCY,Err)
  !Finish creating the problem control loop
  CALL CMISSProblemControlLoopCreateFinish(Problem,Err)


  !
  !================================================================================================================================
  !


  WRITE(*,'(A)') "Start creation of problem solver."
  !SOLVERS

  !Start the creation of the problem solvers
  CALL CMISSSolverTypeInitialise(SolverDiffusion,Err)
  CALL CMISSSolverTypeInitialise(LinearSolverDiffusion,Err)
  CALL CMISSProblemSolversCreateStart(Problem,Err)

  CALL CMISSProblemSolverGet(Problem,CMISSControlLoopNode,SolverDiffusionUserNumber,SolverDiffusion,Err)
  WRITE(*,'(A)') "Solver got."
  !Set the output type
  CALL CMISSSolverOutputTypeSet(SolverDiffusion,LINEAR_SOLVER_DIFFUSION_OUTPUT_TYPE,Err)
  !Set the solver settings
!  IF(LINEAR_SOLVER_DIFFUSION_ONE_DIRECT_FLAG) THEN
!    CALL CMISSSolverLinearTypeSet(LinearSolverDiffusionOne,CMISSSolverLinearDirectSolveType,Err)
!    CALL CMISSSolverLibraryTypeSet(LinearSolverDiffusionOne,CMISSSolverMUMPSLibrary,Err)
!  ELSE
!    CALL CMISSSolverLinearTypeSet(LinearSolverDiffusionOne,CMISSSolverLinearIterativeSolveType,Err)
   CALL CMISSSolverDynamicLinearSolverGet(SolverDiffusion,LinearSolverDiffusion,Err)
    CALL CMISSSolverLinearIterativeMaximumIterationsSet(LinearSolverDiffusion,MAXIMUM_ITERATIONS,Err)
!    CALL CMISSSolverLinearIterativeDivergenceToleranceSet(LinearSolverDiffusionOne,DIVERGENCE_TOLERANCE,Err)
!    CALL CMISSSolverLinearIterativeRelativeToleranceSet(LinearSolverDiffusionOne,RELATIVE_TOLERANCE,Err)
!    CALL CMISSSolverLinearIterativeAbsoluteToleranceSet(LinearSolverDiffusionOne,ABSOLUTE_TOLERANCE,Err)
!    CALL CMISSSolverLinearIterativeGMRESRestartSet(LinearSolverDiffusionOne,RESTART_VALUE,Err)
!  ENDIF
  !Finish the creation of the problem solver
  CALL CMISSProblemSolversCreateFinish(Problem,Err)

  !
  !================================================================================================================================
  !


  WRITE(*,'(A)') "Start creation of the problem solver equations."
  !SOLVER EQUATIONS

  !Start the creation of the problem solver equations
  CALL CMISSSolverTypeInitialise(SolverDiffusion,Err)
  CALL CMISSSolverEquationsTypeInitialise(SolverEquationsDiffusion,Err)
  CALL CMISSProblemSolverEquationsCreateStart(Problem,Err)
  !
  CALL CMISSProblemSolverGet(Problem,CMISSControlLoopNode,SolverDiffusionUserNumber,SolverDiffusion,Err)
  CALL CMISSSolverSolverEquationsGet(SolverDiffusion,SolverEquationsDiffusion,Err)
  CALL CMISSSolverEquationsSparsityTypeSet(SolverEquationsDiffusion,CMISSSolverEquationsSparseMatrices,Err)
  CALL CMISSSolverEquationsEquationsSetAdd(SolverEquationsDiffusion,EquationsSetDiffusionOne,EquationsSetIndexOne,Err)
  CALL CMISSSolverEquationsEquationsSetAdd(SolverEquationsDiffusion,EquationsSetDiffusionTwo,EquationsSetIndexTwo,Err)
  CALL CMISSSolverEquationsEquationsSetAdd(SolverEquationsDiffusion,EquationsSetDiffusionThree,EquationsSetIndexThree,Err)
  !Finish the creation of the problem solver equations
  CALL CMISSProblemSolverEquationsCreateFinish(Problem,Err)


  !
  !================================================================================================================================
  !

  !RUN SOLVERS

  !Turn of PETSc error handling
  !CALL PETSC_ERRORHANDLING_SET_ON(ERR,ERROR,*999)

  !Solve the problem
  WRITE(*,'(A)') "Solving problem..."
  CALL CMISSProblemSolve(Problem,Err)
  WRITE(*,'(A)') "Problem solved!"


  !
  !================================================================================================================================
  !

  !OUTPUT

  EXPORT_FIELD_IO=.TRUE.
  IF(EXPORT_FIELD_IO) THEN
    WRITE(*,'(A)') "Exporting fields..."
    CALL CMISSFieldsTypeInitialise(Fields,Err)
    CALL CMISSFieldsTypeCreate(Region,Fields,Err)
    CALL CMISSFieldIONodesExport(Fields,"MonolithicMultiCompDiffusionTest","FORTRAN",Err)
    CALL CMISSFieldIOElementsExport(Fields,"MonolithicMultiCompDiffusionTest","FORTRAN",Err)
    CALL CMISSFieldsTypeFinalise(Fields,Err)
    WRITE(*,'(A)') "Field exported!"
  ENDIF


  !Finialise CMISS
!   CALL CMISSFinalise(Err)

  WRITE(*,'(A)') "Program successfully completed."
  
  STOP

END PROGRAM MONOLITHICSCHEMETESTEXAMPLE