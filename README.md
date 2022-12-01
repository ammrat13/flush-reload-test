# Flush+Reload Test

This repository serves as my testbed for the Flush+Reload exploit. It hosts my
own implementation of it on bare-metal Linux.


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
