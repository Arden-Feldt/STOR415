types = [:Nuclear, :Coal, :Solar]
counties = [:A, :B]

dmax = 5
emax = 7.2*10^3

using NamedArrays
#Remember that the x variables will be in units of 10^3 MW 
cmat = [5.2*10^3 4.8*10^3; 2.5*10^3 2.25*10^3; 8*10^3 8.5*10^3]
c = NamedArray( cmat, (types,counties), ("type","county") )

e = Dict(zip(types,[1.5,5.3,0.1]))

umat = [Inf 0; Inf 1.5; Inf Inf]
u = NamedArray( umat, (types,counties), ("type","county") )

lmat = [0 0; 0 0; 0 2]
l = NamedArray( lmat, (types,counties), ("type","county") )


using JuMP
using HiGHS

power = Model(HiGHS.Optimizer)

@variable(power, l[i,j] <= x[i in types, j in counties] <= u[i,j])

@constraint(power, demand, sum(sum(x[i,j] for j in counties) for i in types) >= dmax)
@constraint(power, emissions, sum(e[i]*sum(x[i,j] for j in counties) for i in types) <= emax)

@objective(power, Min, sum(sum(c[i,j]*x[i,j] for j in counties) for i in types))

print(power)

optimize!(power)

@show objective_value(power);
@show value.(x);

report = lp_sensitivity_report(power)

NArange = report[x[:Nuclear,:A]]
println("c[:Nuclear,:A] can stay between ", c[:Nuclear,:A]+NArange[1], " and ", c[:Nuclear,:A]+NArange[2])

NBrange = report[x[:Nuclear,:B]]
println("c[:Nuclear,:B] can stay between ", c[:Nuclear,:B]+NBrange[1], " and ", c[:Nuclear,:B]+NBrange[2])

Emissionsrange = report[emissions]
println("emax can stay between ", emax+Emissionsrange[1], " and ", emax+Emissionsrange[2])