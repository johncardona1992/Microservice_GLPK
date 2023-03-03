set S;
/* feasible shifts*/

set P;
/* periods in a work day*/

set A;
/* Available Agents*/
 
set G;
/* parameters */

set K dimen 2;
/* Schedule period Covering*/

param N{p in P};
/*Number of operators needed at period p */

param E{s in S, p in P};
/* 1, if shift s covers period p; 0, otherwise */

param t{l in G};
/* parameters */

table tab_Shifts IN "CSV" "MILP/S.csv" :
  S <- [S_ID];
  
table tab_Agents IN "CSV" "MILP/A.csv" :
  A <- [A_ID];
  
table tab_Periods IN "CSV" "MILP/P.csv" :
  P <- [Period], N ~ REQ;

table tab_Net IN "CSV" "MILP/E.csv" :
[S_ID, Period], E ~ E_value;

table tab_Feasibility IN "CSV" "MILP/L.csv" :
K <-[A_ID, S_ID];

table tab_parameter IN "CSV" "MILP/Global_parameters.csv" :
  G <- [Parameter], t ~ Value ;

param CU := t['CostUnder'];
/* Cost for unfulfilling the requirement by FTE per period */

var x{a in A, s in S}, binary;
/* 1 if Agent a is asssigned to Schedule s, 0 otherwise*/

var u{p in P} >= 0, integer;
/* Unfulfilled demand in period p of the day */

minimize z: (sum{p in P}u[p]*CU);

s.t. C1{p in P}: u[p] >= N[p]- sum{(a,s) in K}x[a,s]*E[s,p];
/* Determines the Unfulfilled demand in period p of day d. */
s.t. C2{a in A}: sum{s in S}x[a,s] = 1;
/* 1 shift per agent */

solve;

printf "Costo Total: %0.2f, faltantes: %i\n", (sum{p in P}u[p]*CU), (sum{p in P}u[p]);

/*printf {p in P}: "%s,%s\n",  p, N[p];*/



table tab_result{a in A, s in S: x[a,s] == 1} OUT "CSV" "MILP/result.csv" :
  a ~ A_ID, s ~ S_ID, x[a,s] ~ x_value;

end;
