(

~bus = Dictionary.new;

~bus.add(\reverb0 -> Bus.audio(s,2));
~bus.add(\reverb1 -> Bus.audio(s,2));
~bus.add(\pitchShift -> Bus.audio(s,2));
~bus.add(\delay -> Bus.audio(s,2));
~bus.add(\distorsion -> Bus.audio(s,2));

~grupos = {
	~grupoPrincipal = Group.new;

	~grupoDelay = Group.after(~grupoPrincipal);
	    ~delay0 = Synth(\delay, [\in, ~bus[\delay], \out, 0], ~grupoDelay);

	~grupoDistorsion = Group.after(~grupoDelay);
	   ~distorsion0 = Synth(\distorsion, [\in, ~bus[\distorsion], \out, 0 ], ~grupoDistorsion);

	~grupoPitchShift = Group.after(~grupoDistorsion);
		~pitchShift0 = Synth(\pitchShift, [\in, ~bus[\pitchShift], \out, 0], ~grupoPitchShift);

	~grupoReverb = Group.after(~grupoPitchShift);
		~reverb0 = Synth(\reverb, [\in, ~bus[\reverb0], \out, 0, \mix, 0.025], ~grupoReverb);
		~reverb1 = Synth(\reverb, [\in, ~bus[\reverb1], \out, 0, \mix, 0.3], ~grupoReverb);

};

s.waitForBoot({


/////////////////////////////////////////EFECTOS

SynthDef(\reverb, {
		arg in=20, out=0, amp=1, mix=0.05, freqF=4000, decay=2.5, delay=0.05;
		var senal, wet, dry;
		dry = In.ar(in, 2);
		wet = dry;
		wet = DelayN.ar(wet, delay, delay);
		20.do{wet = AllpassN.ar(wet, 0.05,{Rand(0.001,0.05)}!2, decay); wet = LPF.ar(wet,freqF);};
		senal = XFade2.ar(dry, wet, mix*2-1, amp);
		Out.ar(out, senal);
}).add;

SynthDef(\pitchShift, {
	arg grainSize=0.5, pitchRatio=1, pitchDispersion=0.5, timeDispersion=0.25, in=30, out=0;
	var dry, senal;

	senal = In.ar(in, 2);
	senal = PitchShift.ar(
		senal,
		grainSize,
		pitchRatio, // de 0 a 4
		pitchDispersion,
		timeDispersion.clip(0,grainSize)
		);
	Out.ar(out, senal);
}).add;

SynthDef(\delay, {
	arg maxtime=0.2, time=0.1, decay= 2, in=40, out=0;
	var senal;

	senal =In.ar(in, 2);
	senal= AllpassN.ar(senal, maxtime, time.clip(0, maxtime), decay);
	Out.ar(out, senal);
}).add;

SynthDef(\distorsion, {
	arg corte=0.25, in=40, out=0;
	var senal;

	senal =In.ar(in, 2);
	senal = senal.fold2(corte);
	Out.ar(out, senal);
}).add;


///////////////////////////////////////SONIDOS
SynthDef(\sinDistort, {
	arg freq=50, amp=1, mix=0.25, corte=0.75, atk=0, sus=2, rel=0, pan= (-1), out=0;
	var senal, senalDist, env;
		env = Env([0, 1, 1, 0] * amp.clip(0, 1), [atk + 0.001, sus, rel + 0.001]).kr(2);
	senal = SinOsc.ar([freq, freq * 12.midiratio]).mean;
	senalDist = senal.fold2(corte);
	senal = XFade2.ar(senal, senalDist, mix.linlin(0,1,-1,1), -3.dbamp);
	senal = senal * env;
	senal = Pan2.ar(senal, pan);
	Out.ar(out, senal);
}).add;

SynthDef(\sinDistort2, {
	arg freq=50, amp=1, mix=0.25, corte=0.75, atk=0, sus=2, rel=0, pan= (-1), out=0;
	var senal, senalDist, env;
	env = Env([0, 1, 1, 0.001] * amp.clip(0, 1), [atk + 0.001, sus, rel + 0.001], [\lin, \lin, \exp]).kr(2);
	senal = SinOsc.ar([freq, freq * 12.midiratio]).mean;
	senalDist = senal.fold2(corte);
	senal = XFade2.ar(senal, senalDist, mix.linlin(0,1,-1,1), -3.dbamp);
	senal = senal * env;
	senal = Pan2.ar(senal, pan);
	Out.ar(out, senal);
}).add;

SynthDef(\noise, {
	arg hiFreqF= 12000, rqhiFreqF=0.1, lFreqF= 1200, rqlFreqF=0.1, atk=0.01, sus=0.5, rel=0.01, amp=0.01, pan=0, out=0;
	var senal, env;
	env = EnvGen.ar(Env([0,1,1,0],[atk,sus,rel]), doneAction:2);
	senal = WhiteNoise.ar;
	senal = HPF.ar(senal, hiFreqF, rqhiFreqF);
	//senal = LPF.ar(senal, lFreqF, rqlFreqF);
	senal = senal * env;
	senal = Pan2.ar(senal, pan, amp);
	Out.ar(out, senal);
}).add;



s.sync;


ServerTree.add(~grupos);
Pbindef.all.do(_.clear);
s.freeAll;

s.sync;
///////////////////////////////////////////////////////////////////////PBINDEF'S




~patternNoise = Pbindef(\noise1,
\instrument, \noise,
\dur, Pwrand([
			Pseq([1/8],8),
			Pseq([1/4],4),
			Pseq([1/3], 3),
			Pseq([1/2],2)
		],[0.95,0.02, 0.01,0.02],inf),

\hiFreqF, Pwhite(15000, 300, inf).stutter(5),
\sus, Pexprand(0.001, 0.075, inf),
//\sus, 0.001,
\rel, Pwhite(0.001, 0.05,inf),
\amp, Pexprand(0.01, 0.5, inf),
\pan, Pwhite(0.5, 1, inf) * Prand([-1, 1], inf) ,
\out,  0
);


~patternCops = Pbindef(\cops,
	\instrument, Prand([\sinDistort], inf),
	\dur, Pwrand([
			Pseq([1/8],8),
			Pseq([1/4],4),
			Pseq([1/3], 3),
			Pseq([1/2],2)
		],[0.9,0.03, 0.04,0.03],inf),
	\freq, 110 * Pwrand([1,2,4,8,16,32,64], [1,2,4,8,16,32,64].normalizeSum, inf),
	\sus, 0.001,
	\rel, Pwrand([ 0.001, 0.005], [0.9, 0.1], inf) * Pwrand([1, Pwhite(50, 100, 1)], [0.99, 0.01], inf),
	\amp, Pexprand(0.01, 0.3, inf),
	\pan, Pwhite(0.001, 0.35,inf) * Prand([-1, 1], inf),
	\corte, Pn(Plazy({Pshuf([0.5, 0.25, 0.25, 0.75], 1)}), inf),
	\out, Pwrand([ 0, ~bus[\reverb0], ~bus[\reverb1]], [0.5, 0.35, 0.15], inf)
);

~ratios =  [1/1, 21/20, 9/8, 7/6, 5/4, 4/3, 7/5, 3/2, 14/9, 5/3, 7/4, 15/8];
~ratioEscogido =  Pseq([1/1, 7/6, 5/4, 7/5, 7/4], inf).asStream;
~alcada = Pseq([8, 16, 32, 64], inf).asStream;
~release = Pseq( Array.geom(4, 4 , 0.85), inf).asStream;
~salida = Pseq([0, ~bus[\reverb0], ~bus[\reverb1],  ~bus[\reverb1]], inf).asStream;
~vol = Pseq([ Pseq(Array.exprand(5, 0.005, 0.01).sort.reverse, 1), Pn(Plazy({ Pseq(Array.exprand(5, 0.01, 0.03).sort.reverse, 1) }), inf)], 1).asStream;
~pan = (Pwhite(0.35, 0.5, inf) * Pseq([-1, 1], inf)).asStream;



~patternMelRand = Pbindef(\melRand,
	\instrument, Prand([\sinDistort], inf),
	\dur, 1/16,
	\ratio,  Pn(Plazy({Pseq(Array.fill(1, { \!7 ++ ~ratios.choose}).flat.scramble, 1)}), inf),
	\freq, (Pfuncn({ arg event; if( event[\ratio].isKindOf(Symbol), {0.0}, {[16, 32, 64].choose}) }, inf) * 110 * Pkey(\ratio)),
	\sus, 0.005,
	\rel, Pexprand(0.05, 0.2, inf),
	\amp, Pwhite(0.005, 0.01, inf),
	\pan, Pwhite(-1.0, 1, inf),
	\corte, Pwhite(0.01, 0.9, inf),
	\out, Pwrand([ 0, ~bus[\reverb0], ~bus[\reverb1]], [0.5, 0.35, 0.15], inf)
);

~patternMel1 = Pbindef(\mel1,
	\instrument, \sinDistort2,
	\dur, 1/8,
	\ratio, Pseq([ Pseq([~ratios[3]], 1), Pseq([\], 36) ], inf),
	\freq, (Pfuncn({ arg event; if( event[\ratio].isKindOf(Symbol), {0.0}, {~alcada.next}) }, inf) * 110 * Pkey(\ratio)),
	 \sus, 0.005,
	\rel, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0}, {~release.next}) }, inf).trace,
	\amp, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0.001}, {~vol.next}) }, inf).trace,
	\pan, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0}, {~pan.next}) }, inf),
	//\corte, Pn(Pshuf([0.5, 0.25, 0.25, 0.75], 1)),
	\out, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0}, {~salida.next}) }, inf)
);




~patternMel2 = Pbindef(\mel2,
	\instrument, \sinDistort2,

	\dur, 1/8,
	\ratio, Pseq([ Pseq([\], 15), Pseq([ ~ratios[10]], 1), Pseq([\], 16) ], inf),
	\ratio, Pseq([ Pseq([~ratios[10]], 1), Pseq([\], 55) ], inf),
    \freq, (Pfuncn({ arg event; if( event[\ratio].isKindOf(Symbol), {0.0}, {~alcada.next}) }, inf) * 110 * Pkey(\ratio)),
	\sus, 0.005,
	//\rel, Pseq([ Pseq([2], 1), Pexprand(0.05, 0.2, 55) ], inf),

	\rel, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0}, {~release.next}) }, inf).trace,
	\amp, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0.001}, {~vol.next}) }, inf).trace,
	\pan, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0}, {~pan.next}) }, inf),
	//\corte, Pn(Pshuf([0.5, 0.25, 0.25, 0.75], 1)),
		\out, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0}, {~salida.next}) }, inf)
);


~patternMel3 = Pbindef(\mel3,
	\instrument, \sinDistort2,

	\dur, 1/8,
	\ratio, Pseq([ Pseq([\], 7), Pseq([~ratios[4]], 1), Pseq([\], 24) ], inf),
	\ratio, Pseq([ Pseq([~ratios[4]], 1), Pseq([\], 39) ], inf),
	 \freq, (Pfuncn({ arg event; if( event[\ratio].isKindOf(Symbol), {0.0}, {~alcada.next}) }, inf) * 110 * Pkey(\ratio)),

		\sus, 0.005,

	\rel, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0}, {~release.next}) }, inf).trace,
	\amp, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0.001}, {~vol.next}) }, inf).trace,
	\pan, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0}, {~pan.next}) }, inf),
	//\corte, Pn(Pshuf([0.5, 0.25, 0.25, 0.75], 1)),
		\out, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0}, {~salida.next}) }, inf)
);


~patternMel4 = Pbindef(\mel4,
	\instrument, \sinDistort2,

	\dur, 1/8,
	\ratio, Pseq([ Pseq([\], 7), Pseq([~ratios[4]], 1), Pseq([\], 24) ], inf),
	\ratio, Pseq([ Pseq([~ratios[6]], 1), Pseq([\], 44) ], inf),
	 \freq, (Pfuncn({ arg event; if( event[\ratio].isKindOf(Symbol), {0.0}, {~alcada.next}) }, inf) * 110 * Pkey(\ratio)),

		\sus, 0.005,

	\rel, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0}, {~release.next}) }, inf).trace,
	\amp, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0.001}, {~vol.next}) }, inf).trace,
	\pan, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0}, {~pan.next}) }, inf),
	//\corte, Pn(Pshuf([0.5, 0.25, 0.25, 0.75], 1)),
		\out, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0}, {~salida.next}) }, inf)
);


~patternMel5 = Pbindef(\mel5,
	\instrument, \sinDistort2,

	\dur, 1/8,
	\ratio, Pseq([ Pseq([\], 7), Pseq([~ratios[4]], 1), Pseq([\], 24) ], inf),
	\ratio, Pseq([ Pseq([~ratios[0]], 1), Pseq([\], 31) ], inf),
	 \freq, (Pfuncn({ arg event; if( event[\ratio].isKindOf(Symbol), {0.0}, {~alcada.next}) }, inf) * 110 * Pkey(\ratio)),

		\sus, 0.005,

	\rel, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0}, {~release.next}) }, inf).trace,
	\amp, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0.001}, {~vol.next}) }, inf).trace,
	\pan, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0}, {~pan.next}) }, inf),
	//\corte, Pn(Pshuf([0.5, 0.25, 0.25, 0.75], 1)),
		\out, Pfuncn({ arg event;  if( event[\ratio].isKindOf(Symbol), {0}, {~salida.next}) }, inf)
);


});
s.prepareForRecord;
Window.closeAll;
)


s.record;
(
s.meter;
ClockFace.new.play;
s.plotTree;
Routine({

~patternNoise.play;

2.yield;
("ENTRA 1 PATRON, NO PITCH").postln;
Pbindef(\noise1, \amp, Pexprand(0.01, 0.5, inf));
~patternCops.play;

3.yield;
Pbindef(\noise1, \amp, Pexprand(0.01, 0.5, inf));
~patternCops.stop;

5.yield; //10
Pbindef(\noise1, \amp, Pexprand(0.01, 0.75, inf));
~patternCops.play;

2.yield;
Pbindef(\cops,\rel, Pwrand([ 0.001, 0.005], [0.9, 0.1], inf) * Pwrand([1, Pwhite(50, 100, 1)], [0.5, 0.5], inf));

3.yield; //15
~patternMel1.play;
~patternMel2.play;
~patternMel3.play;
~patternMel4.play;
~patternMel5.play;

5.yield; //20
Pbindef(\noise1, \amp, Pexprand(0.01, 0.5, inf));

2.yield;
Pbindef(\cops, \amp, Pexprand(0.01, 0.35, inf));

3.yield; //25
~patternMelRand.play;

5.yield;
Pbindef(\noise1, \amp, Pexprand(0.01, 0.5, inf) * Pseg([1, 3], [20]));

2.yield;
Pbindef(\cops, \amp, Pexprand(0.01, 0.4, inf));

3.yield; //35
Pbindef(\melRand,\dur, 1/32);

5.yield;
Pbindef(\melRand, \freq, (Pfuncn({ arg event; if( event[\ratio].isKindOf(Symbol), {0.0}, {[16, 32, 64].choose}) }, inf) * 110 * Pkey(\ratio)).stutter(5));

2.yield;
Pbindef(\cops,
\rel, Pwrand([ 0.001, 0.005], [0.9, 0.1], inf) * Pwrand([1, Pwhite(50, 150, 1)], [0.5, 0.5], inf)
);

3.yield; //45
Pbindef(\noise1, \hiFreqF, Pwhite(15000, 50, inf).stutter(5));

3.yield;
~patternMel1.stop;
~patternMel2.stop;
~patternMel3.stop;
~patternMel4.stop;
~patternMel5.stop;

2.yield;
~patternNoise.stop;

3.yield; //53
~patternCops.stop;
~patternMelRand.stop;
Pbindef.all.do(_.stop);




}).play
)
