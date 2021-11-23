##
# To use in nim language, this file was generated with c2nim and auto edited by
# modc2nimfile.exe (*.nim)
# by audin 2019/01,2021/10 (http://mpu.seesaa.net).
## 
const
  AVR_ARCH* = 0

const SFR_ASM_COMPAT = 0

##  Copyright (c) 2002, Marek Michalkiewicz <marekm@amelek.gda.pl>
##    All rights reserved.
##
##    Redistribution and use in source and binary forms, with or without
##    modification, are permitted provided that the following conditions are met:
##
##  Redistributions of source code must retain the above copyright
##      notice, this list of conditions and the following disclaimer.
##
##  Redistributions in binary form must reproduce the above copyright
##      notice, this list of conditions and the following disclaimer in
##      the documentation and/or other materials provided with the
##      distribution.
##
##  Neither the name of the copyright holders nor the names of
##      contributors may be used to endorse or promote products derived
##      from this software without specific prior written permission.
##
##    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
##    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
##    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
##    ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
##    LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
##    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
##    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
##    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
##    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
##    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
##    POSSIBILITY OF SUCH DAMAGE.
##  avr/sfr_defs.h - macros for accessing AVR special function registers
##  $Id$

when not defined(AVR_SFR_DEFS_H):
  const
    AVR_SFR_DEFS_H* = 1
  ## * \defgroup avr_sfr_notes Additional notes from <avr/sfr_defs.h>
  ##     \ingroup avr_sfr
  ##
  ##    The \c <avr/sfr_defs.h> file is included by all of the \c <avr/ioXXXX.h>
  ##    files, which use macros defined here to make the special function register
  ##    definitions look like C variables or simple constants, depending on the
  ##    <tt>_SFR_ASM_COMPAT</tt> define.  Some examples from \c <avr/iocanxx.h> to
  ##    show how to define such macros:
  ##
  ## \code
  ## #define PORTA   _SFR_IO8(0x02)
  ## #define EEAR    _SFR_IO16(0x21)
  ## #define UDR0    _SFR_MEM8(0xC6)
  ## #define TCNT3   _SFR_MEM16(0x94)
  ## #define CANIDT  _SFR_MEM32(0xF0)
  ## \endcode
  ##
  ##    If \c _SFR_ASM_COMPAT is not defined, C programs can use names like
  ##    <tt>PORTA</tt> directly in C expressions (also on the left side of
  ##    assignment operators) and GCC will do the right thing (use short I/O
  ##    instructions if possible).  The \c __SFR_OFFSET definition is not used in
  ##    any way in this case.
  ##
  ##    Define \c _SFR_ASM_COMPAT as 1 to make these names work as simple constants
  ##    (addresses of the I/O registers).  This is necessary when included in
  ##    preprocessed assembler (*.S) source files, so it is done automatically if
  ##    \c __ASSEMBLER__ is defined.  By default, all addresses are defined as if
  ##    they were memory addresses (used in \c lds/sts instructions).  To use these
  ##    addresses in \c in/out instructions, you must subtract 0x20 from them.
  ##
  ##    For more backwards compatibility, insert the following at the start of your
  ##    old assembler source file:
  ##
  ## \code
  ## #define __SFR_OFFSET 0
  ## \endcode
  ##
  ##    This automatically subtracts 0x20 from I/O space addresses, but it's a
  ##    hack, so it is recommended to change your source: wrap such addresses in
  ##    macros defined here, as shown below.  After this is done, the
  ##    <tt>__SFR_OFFSET</tt> definition is no longer necessary and can be removed.
  ##
  ##    Real example - this code could be used in a boot loader that is portable
  ##    between devices with \c SPMCR at different addresses.
  ##
  ## \verbatim
  ## <avr/iom163.h>: #define SPMCR _SFR_IO8(0x37)
  ## <avr/iom128.h>: #define SPMCR _SFR_MEM8(0x68)
  ## \endverbatim
  ##
  ## \code
  ## #if _SFR_IO_REG_P(SPMCR)
  ## 	out	_SFR_IO_ADDR(SPMCR), r24
  ## #else
  ## 	sts	_SFR_MEM_ADDR(SPMCR), r24
  ## #endif
  ## \endcode
  ##
  ##    You can use the \c in/out/cbi/sbi/sbic/sbis instructions, without the
  ##    <tt>_SFR_IO_REG_P</tt> test, if you know that the register is in the I/O
  ##    space (as with \c SREG, for example).  If it isn't, the assembler will
  ##    complain (I/O address out of range 0...0x3f), so this should be fairly
  ##    safe.
  ##
  ##    If you do not define \c __SFR_OFFSET (so it will be 0x20 by default), all
  ##    special register addresses are defined as memory addresses (so \c SREG is
  ##    0x5f), and (if code size and speed are not important, and you don't like
  ##    the ugly \#if above) you can always use lds/sts to access them.  But, this
  ##    will not work if <tt>__SFR_OFFSET</tt> != 0x20, so use a different macro
  ##    (defined only if <tt>__SFR_OFFSET</tt> == 0x20) for safety:
  ##
  ## \code
  ## 	sts	_SFR_ADDR(SPMCR), r24
  ## \endcode
  ##
  ##    In C programs, all 3 combinations of \c _SFR_ASM_COMPAT and
  ##    <tt>__SFR_OFFSET</tt> are supported - the \c _SFR_ADDR(SPMCR) macro can be
  ##    used to get the address of the \c SPMCR register (0x57 or 0x68 depending on
  ##    device).
  when not defined(ASSEMBLER):
    ##  These only work in C programs.
    template MMIO_BYTE*(mem_addr: untyped): untyped =
      (cast[ptr uint8]((mem_addr)))

    template MMIO_WORD*(mem_addr: untyped): untyped =
      (cast[ptr uint16]((mem_addr)))

    template MMIO_DWORD*(mem_addr: untyped): untyped =
      (cast[ptr uint32]((mem_addr)))

  when SFR_ASM_COMPAT==1:
    when not defined(SFR_OFFSET):
      ##  Define as 0 before including this file for compatibility with old asm
      ##    sources that don't subtract __SFR_OFFSET from symbolic I/O addresses.
      when AVR_ARCH >= 100:
        const
          SFR_OFFSET* = 0x00
      else:
        const
          SFR_OFFSET* = 0x20
    when (SFR_OFFSET != 0) and (SFR_OFFSET != 0x20):
      discard
    template SFR_MEM8*(mem_addr: untyped): untyped =
      (mem_addr)

    template SFR_MEM16*(mem_addr: untyped): untyped =
      (mem_addr)

    template SFR_MEM32*(mem_addr: untyped): untyped =
      (mem_addr)

    template SFR_IO8*(io_addr: untyped): untyped =
      ((io_addr) + SFR_OFFSET)

    template SFR_IO16*(io_addr: untyped): untyped =
      ((io_addr) + SFR_OFFSET)

    template SFR_IO_ADDR*(sfr: untyped): untyped =
      ((sfr) - SFR_OFFSET)

    template SFR_MEM_ADDR*(sfr: untyped): untyped =
      (sfr)

    template SFR_IO_REG_P*(sfr: untyped): untyped =
      ((sfr) < 0x40 + SFR_OFFSET)

    when (SFR_OFFSET == 0x20):
      ##  No need to use ?: operator, so works in assembler too.
      template SFR_ADDR*(sfr: untyped): untyped =
        SFR_MEM_ADDR(sfr)

    elif not defined(ASSEMBLER):
      template SFR_ADDR*(sfr: untyped): untyped =
        (if SFR_IO_REG_P(sfr): (SFR_IO_ADDR(sfr) + 0x20) else: SFR_MEM_ADDR(sfr))

  else:
    when not defined(SFR_OFFSET):
      when AVR_ARCH >= 100:
        const
          SFR_OFFSET* = 0x00
      else:
        const
          SFR_OFFSET* = 0x20
    template SFR_MEM8*(mem_addr: untyped): untyped =
      MMIO_BYTE(mem_addr)

    template SFR_MEM16*(mem_addr: untyped): untyped =
      MMIO_WORD(mem_addr)

    template SFR_MEM32*(mem_addr: untyped): untyped =
      MMIO_DWORD(mem_addr)

    template SFR_IO8*(io_addr: untyped): untyped =
      MMIO_BYTE((io_addr) + SFR_OFFSET)

    template SFR_IO16*(io_addr: untyped): untyped =
      MMIO_WORD((io_addr) + SFR_OFFSET)

    template SFR_MEM_ADDR*(sfr: untyped): untyped =
      ((uint16) and (sfr))

    template SFR_IO_ADDR*(sfr: untyped): untyped =
      (SFR_MEM_ADDR(sfr) - SFR_OFFSET)

    template SFR_IO_REG_P*(sfr: untyped): untyped =
      (SFR_MEM_ADDR(sfr) < 0x40 + SFR_OFFSET)

    template SFR_ADDR*(sfr: untyped): untyped =
      SFR_MEM_ADDR(sfr)

  template SFR_BYTE*(sfr: untyped): untyped =
    MMIO_BYTE(SFR_ADDR(sfr))

  template SFR_WORD*(sfr: untyped): untyped =
    MMIO_WORD(SFR_ADDR(sfr))

  template SFR_DWORD*(sfr: untyped): untyped =
    MMIO_DWORD(SFR_ADDR(sfr))

  ## * \name Bit manipulation
  ## @{
  ## * \def _BV
  ##     \ingroup avr_sfr
  ##
  ##     \code #include <avr/io.h>\endcode
  ##
  ##     Converts a bit number into a byte value.
  ##
  ##     \note The bit shift is performed by the compiler which then inserts the
  ##     result into the code. Thus, there is no run-time overhead when using
  ##     _BV().
  template BV*(bit: untyped): untyped =
    (1 shl (bit))

  ## @}
  when not defined(VECTOR):
    template VECTOR*(N: untyped): untyped =
      N
  when not defined(ASSEMBLER):
    ## * \name IO register bit manipulation
    ## @{
    ## * \def bit_is_set
    ##     \ingroup avr_sfr
    ##
    ##     \code #include <avr/io.h>\endcode
    ##
    ##     Test whether bit \c bit in IO register \c sfr is set.
    ##     This will return a 0 if the bit is clear, and non-zero
    ##     if the bit is set.
    template bit_is_set*(sfr, bit: untyped): untyped =
      (SFR_BYTE(sfr) and BV(bit))

    ## * \def bit_is_clear
    ##     \ingroup avr_sfr
    ##
    ##     \code #include <avr/io.h>\endcode
    ##
    ##     Test whether bit \c bit in IO register \c sfr is clear.
    ##     This will return non-zero if the bit is clear, and a 0
    ##     if the bit is set.
    template bit_is_clear*(sfr, bit: untyped): untyped =
      (not (SFR_BYTE(sfr) and BV(bit)))

    ## * \def loop_until_bit_is_set
    ##     \ingroup avr_sfr
    ##
    ##     \code #include <avr/io.h>\endcode
    ##
    ##     Wait until bit \c bit in IO register \c sfr is set.
    template loop_until_bit_is_set*(sfr, bit: untyped): void =
      while true:
        discard
        if not bit_is_clear(sfr, bit):
          break

    ## * \def loop_until_bit_is_clear
    ##     \ingroup avr_sfr
    ##
    ##     \code #include <avr/io.h>\endcode
    ##
    ##     Wait until bit \c bit in IO register \c sfr is clear.
    template loop_until_bit_is_clear*(sfr, bit: untyped): void =
      while true:
        discard
        if not bit_is_set(sfr, bit):
          break

    ## @}
