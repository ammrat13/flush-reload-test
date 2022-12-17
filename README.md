# Flush+Reload Test

This repository serves as my testbed for the Flush+Reload exploit. It hosts my
own implementation of it on bare-metal Linux.


## Setup

This code was tested on an AMD Ryzen 5 2600X. The spy process was run on Logical
Processor 0 and the victim was run on Logical Processor 1. Importantly, the spy
and victim ran on two different threads on the same core, allowing them to share
an (inclusive) L2 cache.

```
$ cat /proc/version
Linux version 6.0.12-arch1-1 (linux@archlinux) (gcc (GCC) 12.2.0, GNU ld (GNU Binutils) 2.39.0) #1 SMP PREEMPT_DYNAMIC Thu, 08 Dec 2022 11:03:38 +0000

$ cat /proc/cpuinfo
processor       : 0
vendor_id       : AuthenticAMD
cpu family      : 23
model           : 8
model name      : AMD Ryzen 5 2600X Six-Core Processor
stepping        : 2
microcode       : 0x800820d
cpu MHz         : 3592.155
cache size      : 512 KB
physical id     : 0
siblings        : 12
core id         : 0
cpu cores       : 6
apicid          : 0
initial apicid  : 0
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb rdtscp lm constant_tsc rep_good nopl nonstop_tsc cpuid extd_apicid aperfmperf rapl pni pclmulqdq monitor ssse3 fma cx16 sse4_1 sse4_2 movbe popcnt aes xsave avx f16c rdrand lahf_lm cmp_legacy svm extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw skinit wdt tce topoext perfctr_core perfctr_nb bpext perfctr_llc mwaitx cpb hw_pstate ssbd ibpb vmmcall fsgsbase bmi1 avx2 smep bmi2 rdseed adx smap clflushopt sha_ni xsaveopt xsavec xgetbv1 xsaves clzero irperf xsaveerptr arat npt lbrv svm_lock nrip_save tsc_scale vmcb_clean flushbyasid decodeassists pausefilter pfthreshold avic v_vmsave_vmload vgif overflow_recov succor smca sev sev_es
bugs            : sysret_ss_attrs null_seg spectre_v1 spectre_v2 spec_store_bypass retbleed
bogomips        : 7188.75
TLB size        : 2560 4K pages
clflush size    : 64
cache_alignment : 64
address sizes   : 43 bits physical, 48 bits virtual
power management: ts ttp tm hwpstate eff_freq_ro [13] [14]
...
```


## Usage

This project has a few components to it. First is the spy program, which maps a
binary into memory then repeatedly probes at offsets into that file. The spy
program is the "main" project, and it can be built by running `nimble build
-d:release` in the root of this repository. It's important to build it in
release mode, or else the probe loop will not run fast enough. The command-line
options the program takes can be found in
`/src/flush_reload_test_pkg/config.nim`. In summary, it takes the file to probe
as the first argument, followed by any number of offsets into the file. It also
takes options for how long each timeslice should be and how many slices to
record.

A copy of the victim `gnupg` binary used can be found in the `/gnupg/`
directory. That folder also has the home directory used, as well as the script
used to build the program under GCC 12.2.0. One can use the `/run.sh` script to
spy on a signature and dump the raw data to standard out.

The raw data can be analyzed with the script `/analysis/analyze.nim`. Again, one
can check that file for the command-line options the script takes. It takes one
argument: the name of the file containing the data dumped by `/run.sh`. It also
takes options for all the thresholds used in analysis. The defaults reflect my
setup, and will likely differ on different processors. The result will be a
guess of `d_p`, from which one can factor `n`. It is highly suggested to run
this analysis multiple times and manually combine the results to clean the data.


## Results

This code is consistently able to recover `d_p` with approximately a 1% error
rate. These errors are often bit-flips, but the analysis also often mistakes two
consecutive `0`s for a `1` or vice versa.

It only works on 4096-bit RSA keys. It doesn't work for 2048-bit keys or lower.


## References

I found the original paper \[1\] most helpful. It covers most of the details
required to reproduce the attack, including the assembly code they used to probe
a cache line. Of course, the processor's manual \[2\] is a good reference too.

1. Y. Yarom and K. Falkner, "FLUSH+RELOAD: A High Resolution, Low Noise, L3
   Cache Side-Channel Attack," in 23rd USENIX Security Symposium (USENIX
   Security 14), Aug. 2014, pp. 719–732. \[Online\]. Available:
   https://www.usenix.org/conference/usenixsecurity14/technical-sessions/presentation/yarom
2. Intel Corporation, Intel 64 and IA-32 Architectures Software Developer's
   Manual. 2022. \[Online\]. Available:
   https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html
3. Wikichip contributors, "Zen+ - Microarchitectures - AMD". 2021. \[Online\].
   Available: https://en.wikichip.org/w/index.php?oldid=99243
4. Wikichip contributors, "Zen - Microarchitectures - AMD". 2021. \[Online\].
   Available: https://en.wikichip.org/w/index.php?oldid=99556
