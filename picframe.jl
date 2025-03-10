#Uncomment the lines below to download the JuMP and HiGHS packages if they are not already installed
#import Pkg
#Pkg.add("JuMP")
#Pkg.add("HiGHS")

#Import JuMP package to build an optimization model
using JuMP
#Import HiGHS solver
using HiGHS

#Create a JuMP model named picframe1 that will be solved using the HiGHS solver
picframe1 = Model(HiGHS.Optimizer);

#Add the variables x1 and x2
@variable(picframe1, x1 >= 0);
@variable(picframe1, x2 >= 0);

#Create the constraints, name them constraint1 and constraint2
@constraint(picframe1, constraint1, 2x1 + x2 <= 4000);
@constraint(picframe1, constraint2, x1 + 2x2 <= 5000);

#Create our objective function and set it for minimization
@objective(picframe1, Max, 2.25x1 + 2.6x2);

#Print out the model
print(picframe1)
#If you have the LaTeX extension in VSCode installed, print the model in a nicer format
#latex_formulation(picframe1)

#Solve the model
optimize!(picframe1);
#Outputs detailed information about the solution process
@show solution_summary(picframe1);

#Final objective value
@show objective_value(picframe1);
#Value of x1 at solution
@show value(x1);
#Value of x2 at solution
@show value(x2);