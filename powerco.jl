numplants = 3
numcities = 4

costs = [8 6 10 9;
        9 12 13 7;
        14 9 16 5]
        
supply = [35 50 40]
demand = [45 20 30 30];

using JuMP, HiGHS

power = Model(HiGHS.Optimizer)

#Create a variable xij for each pair of plant and city that represents
#the amount of power sent from plant i to city j
@variable(power, x[1:numplants,1:numcities] >= 0)

#Each power plant i can provide at most supply[i] power
@constraint(power, supplyconstraint[i in 1:numplants], sum(x[i,j] for j in 1:numcities) <= supply[i])

#Each city j requires at least demand[j] power
@constraint(power, demandconstraint[j in 1:numcities], sum(x[i,j] for i in 1:numplants) >= demand[j])

#Cost of sending from plant i to city j is given by costs[i,j]
@objective(power, Min, sum(sum(costs[i,j]*x[i,j] for j in 1:numcities) for i in 1:numplants))

print(power)

optimize!(power)

@show objective_value(power)
@show value.(x)