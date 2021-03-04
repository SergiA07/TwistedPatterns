
(
ServerQuit.removeAll;
ServerBoot.removeAll;
ServerTree.removeAll;
Buffer.freeAll;
Window.closeAll;
~bus = Dictionary.new;

~bus.add(\net0 -> Bus.audio(s,1));
~bus.add(\net1 -> Bus.audio(s,1));
~bus.add(\net2 -> Bus.audio(s,1));
~bus.add(\net3 -> Bus.audio(s,1));
~bus.add(\net4 -> Bus.audio(s,1));

~bus.add(\net5 -> Bus.audio(s,1));
~bus.add(\net6 -> Bus.audio(s,1));
~bus.add(\net7 -> Bus.audio(s,1));
~bus.add(\net8 -> Bus.audio(s,1));
~bus.add(\net9 -> Bus.audio(s,1));

~bus.add(\net10 -> Bus.audio(s,1));
~bus.add(\net11 -> Bus.audio(s,1));
~bus.add(\net12 -> Bus.audio(s,1));
~bus.add(\net13 -> Bus.audio(s,1));
~bus.add(\net14 -> Bus.audio(s,1));

~bus.add(\net15 -> Bus.audio(s,1));
~bus.add(\net16 -> Bus.audio(s,1));
~bus.add(\net17 -> Bus.audio(s,1));
~bus.add(\net18 -> Bus.audio(s,1));
~bus.add(\net19 -> Bus.audio(s,1));

~bus.add(\net20 -> Bus.audio(s,1));
~bus.add(\net21 -> Bus.audio(s,1));
~bus.add(\net22 -> Bus.audio(s,1));
~bus.add(\net23 -> Bus.audio(s,1));
~bus.add(\net24 -> Bus.audio(s,1));

~bus.add(\net25 -> Bus.audio(s,1));
~bus.add(\net26 -> Bus.audio(s,1));
~bus.add(\net27 -> Bus.audio(s,1));
~bus.add(\net28 -> Bus.audio(s,1));
~bus.add(\net29 -> Bus.audio(s,1));
~bus.add(\net30 -> Bus.audio(s,1));

~bus.add(\net31 -> Bus.audio(s,1));
~bus.add(\net32 -> Bus.audio(s,1));

~bus.add(\distorsion -> Bus.audio(s,2));

~bus.add(\reverb0 -> Bus.audio(s,2));
~bus.add(\reverb1 -> Bus.audio(s,2));


~grupos = {
	~grupoPrincipal = Group.new;

    ~grupoNet = Group.after(~grupoPrincipal);

	~grupoDistorsion = Group.after(~grupoNet);
	   ~distorsion0 = Synth(\distorsion, [\in, ~bus[\distorsion], \out, 0 ], ~grupoDistorsion);

	~grupoReverb = Group.after(~grupoDistorsion);
		~reverb0 = Synth(\reverb, [\in, ~bus[\reverb0], \out, 0, \mix, 0.025], ~grupoReverb);
		~reverb1 = Synth(\reverb, [\in, ~bus[\reverb1], \out, 0, \mix, 0.3], ~grupoReverb);
};

s.waitForBoot({


s.sync;
/////////////////////////////////////////EFECTOS



SynthDef(\reverb, {
		arg in=22, out=0, amp=1, mix=0.05, freqF=4000, decay=2.5, delay=0.05;
		var senal, wet, dry;
		dry = In.ar(in, 2);
		wet = dry;
		wet = DelayN.ar(wet, delay, delay);
		20.do{wet = AllpassN.ar(wet, 0.05,{Rand(0.001,0.05)}!2, decay); wet = LPF.ar(wet,freqF);};
		senal = XFade2.ar(dry, wet, mix*2-1, amp);
		Out.ar(out, senal);
}).add;

SynthDef(\distorsion, {
	arg corte=0.25, in=40, out=0;
	var senal;

	senal =In.ar(in, 2);
	senal = senal.fold2(corte);
	Out.ar(out, senal);
}).add;

s.sync;

////SYNTHDEF

(
SynthDef(\prova1, {
	arg atk=0.01, sus=0.1, rel =1, out=0, in=20, amp=1, pan = 0;
	var input, env, senal;
	input = In.ar(in, 1);
	env = Env([0, 1, 1, 0] * amp, [atk, sus, rel]).kr(2);
	senal = input * env;
	senal  = Pan2.ar(senal, pan);
	Out.ar(out, senal);
}).add
);

s.sync;


~peca = {

var freqFund, input1, input2, input_final, resonador1, resonador2, resonador3, resonador4, resonador5, resonador6, diferenciales,resonadorSuma, resonadorRitmo, temps, numArm, senal2, final, desafinador, modVol, modFiltro;
~ratios =  [1/1, 21/20, 9/8, 7/6, 5/4, 4/3, 7/5, 3/2, 14/9, 5/3, 7/4, 15/8];
~ratioEscogido =  [1/1, 5/4, 7/4, 7/6, 7/5];
~tonsdiferencials = [1/2, 1/12, 3/20, 7/12, 7/20, 7/30];



temps = 2;
freqFund = 55;
numArm = ~ratioEscogido.size;
desafinador = LFNoise2.kr(1!numArm).range(-0.15, 0.15).midiratio;
modVol = LFNoise1.kr((1/3)!numArm).range(0.9, 1.1);
modFiltro = LFNoise1.kr((3)!~tonsdiferencials.size).range(1.0, 2);

input1 = SyncSaw.ar( 55, 55, 0.25);
input2 = PinkNoise.ar(LFNoise1.kr(3).range(0.5, 0.75));


resonador1 =  CombC.ar(
					       input1,
				           1/ freqFund,
			               1 / ((freqFund  * ~ratioEscogido) * desafinador),
			               Array.geom(numArm, temps, 1.25),
					       Array.geom(5, 0.75, 0.75).reverse
			               //0.75
);

resonador2 =  CombC.ar(
					       input1,
				           1/ freqFund,
			               1 / ((freqFund  * 2 * ~ratioEscogido) * desafinador),
			               Array.geom(numArm, temps, 1.25),
					       Array.geom(5, 0.75, 0.75).reverse
			               //0.75
);

resonador3 =  CombC.ar(
					       input1,
				           1/ freqFund,
			               1 / ((freqFund  * 4 * ~ratioEscogido) * desafinador),
			               Array.geom(numArm, temps, 1.25),
					      Array.geom(5, 0.75, 0.75).reverse
			               //0.75
);

resonador4 =  CombC.ar(
					       input1,
				           1/ freqFund,
			               1 / ((freqFund  * 8 *  ~ratioEscogido) * desafinador),
			               Array.geom(numArm, temps, 1.25),
					      Array.geom(5, 0.75, 0.75).reverse
			               //0.75
);

resonador5 =  CombC.ar(
					       input1,
				           1/ freqFund,
			               1 / ((freqFund * 16 * ~ratioEscogido) * desafinador),
			               Array.geom(numArm, temps, 1.25),
					      Array.geom(5, 0.75, 0.75).reverse
			               //0.75
);


diferenciales =  Resonz.ar(
					       input2,
				           (freqFund  * 32  * ~tonsdiferencials) * desafinador,
			               0.005 * modFiltro,
		                	(Array.geom(~tonsdiferencials.size, 1, 0.85) * modVol) * 10;
);


4.do({ resonador1 = AllpassN.ar(resonador1, 0.05, { rrand(0.0075, 0.05) }!numArm, temps)});
resonador1 = LeakDC.ar(resonador1);

4.do({ resonador2 = AllpassN.ar(resonador2, 0.05, { rrand(0.0075, 0.05) }!numArm, temps)});
resonador2 = LeakDC.ar(resonador2);

4.do({ resonador3 = AllpassN.ar(resonador3, 0.05, { rrand(0.0075, 0.05) }!numArm, temps)});
resonador3 = LeakDC.ar(resonador3);

4.do({ resonador4 = AllpassN.ar(resonador4, 0.05, { rrand(0.0075, 0.05) }!numArm, temps)});
resonador4 = LeakDC.ar(resonador4);

4.do({ resonador5 = AllpassN.ar(resonador5, 0.05, { rrand(0.0075, 0.05) }!numArm, temps)});
resonador5 = LeakDC.ar(resonador5);


resonadorSuma = resonador1.mean;
4.do({ resonadorSuma = AllpassN.ar(resonadorSuma, 0.05, { rrand(0.0075, 0.05) }, temps)});
resonadorSuma = LeakDC.ar(resonadorSuma);


Out.ar(~bus[\net0], resonador1[0]);
Out.ar(~bus[\net1], resonador1[1]);
Out.ar(~bus[\net2], resonador1[2]);
Out.ar(~bus[\net3], resonador1[3]);
Out.ar(~bus[\net4], resonador1[4]);

Out.ar(~bus[\net5], resonador2[0]);
Out.ar(~bus[\net6], resonador2[1]);
Out.ar(~bus[\net7], resonador2[2]);
Out.ar(~bus[\net8], resonador2[3]);
Out.ar(~bus[\net9], resonador2[4]);

Out.ar(~bus[\net10], resonador3[0]);
Out.ar(~bus[\net11], resonador3[1]);
Out.ar(~bus[\net12], resonador3[2]);
Out.ar(~bus[\net13], resonador3[3]);
Out.ar(~bus[\net14], resonador3[4]);

Out.ar(~bus[\net15], resonador4[0]);
Out.ar(~bus[\net16], resonador4[1]);
Out.ar(~bus[\net17], resonador4[2]);
Out.ar(~bus[\net18], resonador4[3]);
Out.ar(~bus[\net19], resonador4[4]);

Out.ar(~bus[\net20], resonador5[0]);
Out.ar(~bus[\net21], resonador5[1]);
Out.ar(~bus[\net22], resonador5[2]);
Out.ar(~bus[\net23], resonador5[3]);
Out.ar(~bus[\net24], resonador5[4]);

Out.ar(~bus[\net25], diferenciales[0]);
Out.ar(~bus[\net26], diferenciales[1]);
Out.ar(~bus[\net27], diferenciales[2]);
Out.ar(~bus[\net28], diferenciales[3]);
Out.ar(~bus[\net29], diferenciales[4]);
Out.ar(~bus[\net30], diferenciales[5]);

Out.ar(~bus[\net31], resonadorSuma);
Out.ar(~bus[\net32], input1);

};
s.sync;

ServerTree.add(~grupos);
Pbindef.all.do(_.clear);
s.freeAll;
s.sync;
});
s.prepareForRecord;
)


(
//PBINDEF

~superposicio = Pgeom.fromEndpoints(6, 14, 8).asStream;

~patroFund = Pbindef(\fund,
	\instrument, \prova1,
	\group, ~grupoNet,
	\in,  Pwrand([ ~bus[\net0], ~bus[\net5], ~bus[\net10],  ~bus[\net15], ~bus[\net20], ~bus[\net34] ], [0.7, 0.2, 0.1, 0.0, 0.0, 0.0], inf),
	\dur, Pwrand([
			Pseq([1/8],8),
			Pseq([1/4],4),
			Pseq([1/3], 3),
			Pseq([1/2],2)
      ],[0.95,0.035, 0.01,0.05],inf),
	\atk, 0.01,
	\sus, 0.05,
	\rel, Pwrand([ Pwhite(0.01, 0.1, 1), Pwhite(0.5, 1.25, 1)], [0.9, 0.1], inf),
    \rel, 0.01,
	\amp, Pexprand(0.01, 0.2, inf) * Pseg([0.5, 2.5], [63]),
	\pan, Pwrand([ Pseq([-1, 1, -1, 1], 1), (Pwhite(0.5, 1, 1) * Prand([-1, 1], 1))], [0.1, 0.9], inf),
	\out, Pwrand([ 0, ~bus[\reverb0], ~bus[\reverb1]], [0.5, 0.35, 0.15], inf)
);

~patroBase = Pbindef(\76,
	\instrument, \prova1,
	\group, ~grupoNet,

	\in,  Pseq([

		Pwrand([ ~bus[\net1], ~bus[\net6], ~bus[\net11], ~bus[\net16], ~bus[\net21] ], [0.45, 0.35, 0.2, 0.0, 0.0], 16), Pseq([~bus[\net6]], 1),

	         	Pwrand([
		         	Pwrand([ ~bus[\net1], ~bus[\net6], ~bus[\net11], ~bus[\net16], ~bus[\net21] ], [0.4, 0.35, 0.25, 0.0, 0.0], 1),
		         	Pwrand([ ~bus[\net2], ~bus[\net7], ~bus[\net12], ~bus[\net17], ~bus[\net22] ], [0.4, 0.35, 0.25, 0.0, 0.0], 1)
		         ], [0.5, 0.5], 15), Pseq([~bus[\net2]], 1),

		        Pwrand([
		         	Pwrand([ ~bus[\net2], ~bus[\net7], ~bus[\net12], ~bus[\net17], ~bus[\net22] ], [0.35, 0.35, 0.25, 0.05, 0.0], 1),
		         	Pwrand([ ~bus[\net3], ~bus[\net8], ~bus[\net13], ~bus[\net18], ~bus[\net23] ], [0.35, 0.35, 0.25, 0.05, 0.0], 1)
		         ], [0.5, 0.5], 14), Pseq([~bus[\net13]], 1),

		        Pwrand([
			        Pwrand([ ~bus[\net1], ~bus[\net6], ~bus[\net11], ~bus[\net16], ~bus[\net21] ], [0.35, 0.3, 0.25, 0.1, 0.0], 1),
		         	Pwrand([ ~bus[\net3], ~bus[\net8], ~bus[\net13], ~bus[\net18], ~bus[\net23] ], [0.35, 0.3, 0.25, 0.1, 0.0], 1),
		         	Pwrand([ ~bus[\net4], ~bus[\net9], ~bus[\net14], ~bus[\net19], ~bus[\net24] ], [0.35, 0.3, 0.25, 0.1, 0.0], 1)
		         ], [1/3, 1/3, 1/3], 13), Pseq([~bus[\net14]], 1),

		        Pwrand([
			        Pwrand([ ~bus[\net1], ~bus[\net6], ~bus[\net11], ~bus[\net16], ~bus[\net21] ],  [0.3, 0.3, 0.25, 0.15, 0.0], 1),
		         	Pwrand([ ~bus[\net2], ~bus[\net7], ~bus[\net12], ~bus[\net17], ~bus[\net22] ],  [0.3, 0.3, 0.25, 0.15, 0.0], 1),
		         	Pwrand([ ~bus[\net4], ~bus[\net9], ~bus[\net14], ~bus[\net19], ~bus[\net24] ],  [0.3, 0.3, 0.25, 0.15, 0.0], 1)
		         ], [1/3, 1/3, 1/3], 12), Pseq([~bus[\net7]], 1),

		         Pwrand([
			        Pwrand([ ~bus[\net1], ~bus[\net6], ~bus[\net11], ~bus[\net16], ~bus[\net21] ], [0.3, 0.25, 0.25, 0.2, 0.0], 1),
		         	Pwrand([ ~bus[\net2], ~bus[\net7], ~bus[\net12], ~bus[\net17], ~bus[\net22] ], [0.3, 0.25, 0.25, 0.2, 0.0], 1),
		         	Pwrand([ ~bus[\net3], ~bus[\net8], ~bus[\net13], ~bus[\net18], ~bus[\net23] ], [0.3, 0.25, 0.25, 0.2, 0.0], 1)
		         ], [1/3, 1/3, 1/3], 11), Pseq([~bus[\net18]], 1),

		         Pwrand([
			        Pwrand([ ~bus[\net2], ~bus[\net7], ~bus[\net12], ~bus[\net17], ~bus[\net22] ], [0.3, 0.25, 0.2, 0.2, 0.05], 1),
		         	Pwrand([ ~bus[\net3], ~bus[\net8], ~bus[\net13], ~bus[\net18], ~bus[\net23] ], [0.3, 0.25, 0.2, 0.2, 0.05], 1),
		         	Pwrand([ ~bus[\net4], ~bus[\net9], ~bus[\net14], ~bus[\net19], ~bus[\net24] ], [0.3, 0.25, 0.2, 0.2, 0.05], 1)
		         ], [1/3, 1/3, 1/3], 10), Pseq([~bus[\net19]], 1),

		         Pwrand([
			        Pwrand([ ~bus[\net1], ~bus[\net6], ~bus[\net11], ~bus[\net16], ~bus[\net21] ], [0.3, 0.25, 0.2, 0.15, 0.1], 1),
			        Pwrand([ ~bus[\net2], ~bus[\net7], ~bus[\net12], ~bus[\net17], ~bus[\net22] ], [0.3, 0.25, 0.2, 0.15, 0.1], 1),
		         	Pwrand([ ~bus[\net3], ~bus[\net8], ~bus[\net13], ~bus[\net18], ~bus[\net23] ], [0.3, 0.25, 0.2, 0.15, 0.1], 1),
		         	Pwrand([ ~bus[\net4], ~bus[\net9], ~bus[\net14], ~bus[\net19], ~bus[\net24] ], [0.3, 0.25, 0.2, 0.15, 0.1], 1)
		         ], [1/4, 1/4, 1/4, 1/4], 9), Pseq([~bus[\net10]], 1)

	        ], 1),

	\dur, Pseq([
		        Pseq([1/8], 16), Pseq([6], 1),
		        Pseq([0.125], 12), Pseq([1/6], 3), Pseq([6], 1), //15   //8s
		        Pseq([0.125], 8), Pseq([1/6], 6), Pseq([6], 1), //14    //16s
		        Pseq([1/6], 3), Pseq([1/8], 8), Pseq([1/4], 2), Pseq([6], 1), //13    //24s
		        Pseq([1/8], 4), Pseq([1/6], 6), Pseq([1/4], 2), Pseq([6], 1), //12   //32s
		        Pseq([1/6], 3), Pseq([1/8], 4), Pseq([1/4], 4), Pseq([6], 1), //11    //40s
		        Pseq([1/8], 4), Pseq([1/6], 3), Pseq([1/3], 3), Pseq([6], 1), //10    //48s
		        Pseq([1/8], 4), Pseq([1/6], 3), Pseq([1/2], 2), Pseq([6], 1), //9    //56s
	            ], 1),

	\atk, Pseq([
		         Pseq([0.01],17),

		         Pseq([0.01],16),
		         Pseq([0.01],15),
		         Pseq([0.01],14),
		         Pseq([0.01],13),
		         Pseq([0.01],12),
		         Pseq([0.01],11),
		         Pseq([0.01],10),

	            ], inf),

	\sus, Pseq([
		         Pseq([0.125 * 0.5],16), Pseq([0.1], 1),

		         Pseq([0.125 * 0.5],15), Pseq([0.1], 1),
		         Pseq([0.125 * 0.5],14), Pseq([0.1], 1),
		         Pseq([0.125 * 0.5],13), Pseq([0.1], 1),
		         Pseq([0.125 * 0.5],12), Pseq([0.1], 1),
		         Pseq([0.125 * 0.5],11), Pseq([0.1], 1),
		         Pseq([0.125 * 0.5],10), Pseq([0.1], 1),
		         Pseq([0.125 * 0.5],9), Pseq([0.1], 1),


             	], inf),


	\rel, Pseq([
		Pwrand([ Pwhite(0.01, 0.1, 1), Pwhite(0.5, 1.25, 1)], [1, 0.0], 16), Pseq([~superposicio.next], 1),

		Pwrand([ Pwhite(0.01, 0.1, 1), Pwhite(0.5, 1.25, 1)], [1, 0.0], 15), Pseq([~superposicio.next], 1),
		Pwrand([ Pwhite(0.01, 0.1, 1), Pwhite(0.5, 1.25, 1)], [1, 0.0], 14), Pseq([~superposicio.next], 1),
		Pwrand([ Pwhite(0.01, 0.15, 1), Pwhite(0.5, 1.25, 1)], [1, 0.0], 13), Pseq([~superposicio.next], 1),
	Pwrand([ Pwhite(0.01, 0.2, 1), Pwhite(0.5, 1.25, 1)], [1, 0.0], 12), Pseq([~superposicio.next], 1),
	Pwrand([ Pwhite(0.01, 0.25, 1), Pwhite(0.5, 1.25, 1)], [1, 0.0], 11), Pseq([~superposicio.next], 1),
Pwrand([ Pwhite(0.01, 0.30, 1), Pwhite(0.5, 1.25, 1)], [1, 0.0], 10), Pseq([~superposicio.next], 1),
Pwrand([ Pwhite(0.01, 0.35, 1), Pwhite(0.5, 1.25, 1)], [1, 0.0], 9), Pseq([~superposicio.next /2], 1),


	            ], inf),

    \amp, (Pseq([
		          Pseq([ Pseq([0.75], 1), Pexprand(0.05, 0.40, 15), Pexprand(0.2, 0.3, 1)], 1), //17
		          Pseq([ Pseq([0.75], 1), Pexprand(0.05, 0.40, 14), Pexprand(0.2, 0.3, 1)], 1),//16
		          Pseq([0.0], 1), Pseq([ Pseq([0.75], 1), Pexprand(0.05, 0.40, 12), Pexprand(0.2, 0.3, 1)], 1), //15
		Pseq([0.0], 1), Pseq([ Pseq([0.75], 1), Pexprand(0.05, 0.40, 11), Pexprand(0.2, 0.3, 1)], 1), //14
		Pseq([0.0], 2), Pseq([ Pseq([0.85], 1), Pexprand(0.05, 0.40, 9), Pexprand(0.2, 0.3, 1)], 1), //13
		          Pseq([0.0], 2), Pseq([ Pseq([1], 1), Pexprand(0.05, 0.40, 8), Pexprand(0.2, 0.3, 1)], 1), //12
		          Pseq([0.0], 3), Pseq([ Pseq([1], 1), Pexprand(0.05, 0.40, 6), Pexprand(0.25, 0.35, 1)], 1), //11
		          Pseq([0.0], 4), Pseq([ Pseq([1], 1), Pexprand(0.05, 0.40, 4), Pexprand(0.25, 0.35, 1)], 1) //10

		         ], inf) * Pseg([1, 0.25], [63])),

	\pan, Pwrand([ Pseq([-0.5, 0.5, -0.25, 0.25], 1), (Pwhite(0.15, 0.5, 1) * Prand([-1, 1], 1))], [0.1, 0.9], inf),
	\out, Pwrand([ 0, ~bus[\reverb0], ~bus[\reverb1]], [0.5, 0.35, 0.15], inf),
);


~patroDiferencial = Pbindef(\diferencial,
	\instrument, \prova1,
	\group, ~grupoNet,
	\in,  Pseq([ ~bus[\net25],  ~bus[\net28],  [~bus[\net26],  ~bus[\net27]],  [~bus[\net25], ~bus[\net29] ],  [~bus[\net26], ~bus[\net28]],  [~bus[\net30], ~bus[\net29]] ], 1),
	\dur, 8,
	\atk, 8,
	\sus, 0,
	\rel, 4 * Pseg([1, 3], [63]),
	\amp, 0.075 * Pseg([1, 4], [63]),
	\pan, 0,
	\out, 0
);

~patroInput = Pbindef(\input,
	\instrument, \prova1,
	\group, ~grupoNet,
	\in,  ~bus[\net32],
	\dur, Pseq([
		          Pn(Plazy({ Pshuf([ 2, 2, 2, 1.6666666666667], 1)}), 1),
		          Pn(Plazy({ Pshuf([ 1.8333333333333, 1.8333333333333, 1.8333333333333, 1.5], 1)}), 1),
		          Pn(Plazy({ Pshuf([ 1.6666666666667, 1.6666666666667, 1.6666666666667, 1.3333333333333], 1)}), 1),
		        ],1 ).trace,
	\atk, 0.01,
	\sus, 0.5,
	\rel, 0.01,
	\amp, 0.3 * Pseg([0.5, 1], [ 30]),
	\pan, 0,
	\out, 0
);
)

s.record;

(
s.meter;
ClockFace.new.play;
~peca.play(~grupoPrincipal);
Routine({

~patroBase.play;

8.yield;
~patroDiferencial.play;
~patroFund.play;

24.yield;
~patroInput.play;

24.yield;
~patroFund.stop;

8.yield;
~patroBase.stop;
}).play
)