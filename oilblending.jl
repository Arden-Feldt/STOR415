#Gas and Crude Types
gastype = [:gas_1, :gas_2, :gas_3]
crudetype = [:crude_1, :crude_2, :crude_3]

#Dictionary for sales price of each gas type
saleprice = Dict(zip(gastype, [70, 60, 50]))
#Dictionary for purchase price of each crude type
purchaseprice = Dict(zip(crudetype, [45, 35, 25]))

#Dictionary for octane level of each crude oil type
octanecrude = Dict(zip(crudetype, [12,6,8]))
#Dictionary for sulfur content of each crude oil type (in %)
sulfurcrude = Dict(zip(crudetype, [0.005,0.02,0.03]))

#Dictionary for minimum average octane level in each type of gasoline
octanegas = Dict(zip(gastype, [10, 8, 6]))
#Dictionary for maximum average sulfur level in each type of gasoline
sulfurgas = Dict(zip(gastype, [0.01, 0.02, 0.01]))

#Dictionary for demand of each type of gasoline
demand = Dict(zip(gastype, [3000, 2000, 1000]))

#Cost to transform one barrel of crude into 1 of gasoline
transformcost = 4
#Maximum purchasable barrels per day (for each type)
maxpurchase = 5000
#Max production per day (in barrels of gasoline)
maxproduce = 14000;

using JuMP, HiGHS

m = Model(HiGHS.Optimizer)

@variable(m, x[crudetype, gastype] >= 0)

#Maximum amount purchased for each crude
@constraint(m, mpurconstraint[i in crudetype], sum(x[i,j] for j in gastype) <= maxpurchase)
#Maximum amount produced per day
@constraint(m, mprodconstraint, sum(sum(x[i,j] for j in gastype) for i in crudetype) <= maxproduce)

#Meet demand obligations
@constraint(m, meetdemand[j in gastype], sum(x[i,j] for i in crudetype) >= demand[j])

#Minimum average octane constraint
@constraint(m, minoctane[j in gastype], sum(octanecrude[i]*x[i,j] for i in crudetype)
                                        >= sum(octanegas[j]*x[i,j] for i in crudetype))
#Maximum average sulfur constraint
@constraint(m, maxsulfur[j in gastype], sum(sulfurcrude[i]*x[i,j] for i in crudetype)
                                        <= sum(sulfurgas[j]*x[i,j] for i in crudetype))

#Objective is revenue (sales) minus cost (purchase and conversion)
@objective(m, Max, sum(saleprice[j]*sum(x[i,j] for i in crudetype) for j in gastype)
    - sum((purchaseprice[i]+transformcost)*sum(x[i,j] for j in gastype) for i in crudetype))

#print(m)
#If you have the LaTeX extension in VSCode installed, print the model in a nicer format
latex_formulation(m)

status = optimize!(m)
blend = value.(x)
objval = objective_value(m)

println(status)
println(blend)
println(objval)