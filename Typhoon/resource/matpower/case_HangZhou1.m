function mpc = case_HangZhou1
%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
global IEEE57_l IEEE57_n
mpc.bus = IEEE57_n;

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
	1	128.9	-16.1	2000	-140	1.04	100	1	5750.88	0	0	0	0	0	0	0	0	0	0	0	0;
	2	0	-0.8	5000	-17	1.01	100	1	1000	0	0	0	0	0	0	0	0	0	0	0	0;
	3	40	-1	6000	-10	0.985	100	1	1400	0	0	0	0	0	0	0	0	0	0	0	0;
	6	0	0.8	2500	-8	0.98	100	1	1000	0	0	0	0	0	0	0	0	0	0	0	0;
	8	450	62.1	20000	-140	1.005	1000	1	550	0	0	0	0	0	0	0	0	0	0	0	0;
	9	0	2.2	9000	-3	0.98	100	1	1000	0	0	0	0	0	0	0	0	0	0	0	0;
	12	310	128.5	15500	-150	1.015	1000	1	410	0	0	0	0	0	0	0	0	0	0	0	0;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = IEEE57_l;

%%-----  OPF Data  -----%%
%% generator cost data
%	1	startup	shutdown	n	x1	y1	...	xn	yn
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
	2	0	0	3	0.077579519	20	0;
	2	0	0	3	0.01	40	0;
	2	0	0	3	0.25	20	0;
	2	0	0	3	0.01	40	0;
	2	0	0	3	0.0222222222	20	0;
	2	0	0	3	0.01	40	0;
	2	0	0	3	0.0322580645	20	0;
];

%% bus names
mpc.bus_name = {
	'Kanawha   V1';
	'Turner    V1';
	'Logan     V1';
	'Sprigg    V1';
	'Bus 5     V1';
	'Beaver Ck V1';
	'Bus 7     V1';
	'Clinch Rv V1';
	'Saltville V1';
	'Bus 10    V1';
	'Tazewell  V1';
	'Glen Lyn  V1';
	'Bus 13    V1';
	'Bus 14    V1';
	'Bus 15    V1';
	'Bus 16    V1';
	'Bus 17    V1';
	'Sprigg    V2';
	'Bus 19    V2';
	'Bus 20    V2';
	'Bus 21    V3';
	'Bus 22    V3';
	'Bus 23    V3';
	'Bus 24    V3';
	'Bus 25    V4';
	'Bus 26    V5';
	'Bus 27    V5';
	'Bus 28    V5';
	'Bus 29    V5';
	'Bus 30    V4';
	'Bus 31    V4';
	'Bus 32    V4';
	'Bus 33    V4';
	'Bus 34    V3';
	'Bus 35    V3';
	'Bus 36    V3';
	'Bus 37    V3';
	'Bus 38    V3';
	'Bus 39    V3';
	'Bus 40    V3';
	'Tazewell  V6';
	'Bus 42    V6';
	'Tazewell  V7';
	'Bus 44    V3';
	'Bus 45    V3';
	'Bus 46    V3';
	'Bus 47    V3';
	'Bus 48    V3';
	'Bus 49    V3';
	'Bus 50    V3';
	'Bus 51    V3';
	'Bus 52    V5';
	'Bus 53    V5';
	'Bus 54    V5';
	'Saltville V5';
	'Bus 56    V6';
	'Bus 57    V6';
};


