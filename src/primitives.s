## Basic assembly primitives for Flush+Reload
##
## The Flush+Reload attack, being a micro-architectural side-channel, relies on
## architecture-specific code. For instance, it has to flush the cache and read
## the cycle counters. This code implements the low-level primitives needed by
## the code.

.global rdtsc
rdtsc:
  ## Read the 64-bit timestamp counter
  ##
  ## As suggested by the manual, we add fences before the command. This way, we
  ## know all the commands before it have been executed, and that all the stores
  ## before it have been flushed to memory. Similarly, we have a fence after the
  ## command to ensure it completes before new commands are issued.
  ##
  ## See: Intel 64 and IA-32 Architectures Software Developer's Manual,
  ##      Volume 2, Chapter 4.3, RDTSC - Read Time-Stamp Counter
  ## See: Intel 64 and IA-32 Architectures Software Developer's Manual,
  ##      Volume 2, Chapter 4.3, MFENCE - Memory Fence
  ## See: Intel 64 and IA-32 Architectures Software Developer's Manual,
  ##      Volume 2, Chapter 3.2, LFENCE - Load Fence

  # Since %rdx is caller-saved and %rax is the return value, we don't need to
  # save any registers

  # Use the manual's suggestion for fences
  # In this case, the second lfence isn't really needed, but keep it anyway
  mfence
  lfence
  rdtsc
  lfence

  # Do bitwise magic to get the output format correct
  # We expect %rax to have all 64 bits, but right now %edx has the high 32
  shlq $32,  %rdx
  orq  %rdx, %rax

  ret
