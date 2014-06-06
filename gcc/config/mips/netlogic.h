/* NetLogic-specific overrides.  */

/* Force the default endianness and ABI flags onto the command line
   in order to make the other specs easier to write.  */
#undef DRIVER_SELF_SPECS
#define DRIVER_SELF_SPECS \
  BASE_DRIVER_SELF_SPECS, \
  /* -msym32 needs to come before -mplt filter in LINUX_DRIVER_SELF_SPECS.  */ \
  "%{!msym32:%{!mno-sym32:%{!mno-plt:%{mabi=64: -msym32 }}}}", \
  LINUX_DRIVER_SELF_SPECS \
  " %{!EB:%{!EL:%(endian_spec)}}" \
  " %{!mabi=*: -mabi=n32}" \
  " %{funwind-tables|fno-unwind-tables|ffreestanding|nostdlib:;: -funwind-tables}"

#undef SUBTARGET_CC1_SPEC
#define SUBTARGET_CC1_SPEC "%{O3:-funroll-loops --param max-unroll-times=2 --param max-unrolled-insns=400}"

