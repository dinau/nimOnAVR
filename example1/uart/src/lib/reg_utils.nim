#[
MIT License

2021 audin
    Modified and simplified for AVR 8bit
Copyright (c) 2018 audin
    Modified and added source code for Nucleo-F030R8.

Copyright (c) 2018 shima-529

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.]#

import volatile

template ld*[T: SomeInteger](reg: ptr T): T =
  volatileLoad(reg)

template st*[T: SomeInteger](reg: ptr T, val: SomeInteger) =
  volatileStore(reg, cast[T](val))


# For byte and word access
proc `v=`*[T:SomeInteger,U: SomeInteger](reg: ptr T, val:U) =
    reg.st  val

proc v*[T:SomeInteger](reg: ptr T): SomeInteger =
    reg.ld

# For bit access
proc `b0=`*[T:SomeInteger,U: SomeInteger](reg: ptr T, val:U) =
    if val != 0: reg.st  ( reg.ld or cast[T](1 shl 0) )
    else: reg.st  (reg.ld and not cast[T](1 shl 0) )
proc b0*[T:SomeInteger](reg: ptr T): SomeInteger =
    if 0 != ( reg.ld and cast[T](1 shl 0) ): 1 else: 0

proc `b1=`*[T:SomeInteger,U: SomeInteger](reg: ptr T, val:U) =
    if val != 0: reg.st  ( reg.ld or cast[T](1 shl 1) )
    else: reg.st  (reg.ld and not cast[T](1 shl 1) )
proc b1*[T:SomeInteger](reg: ptr T): SomeInteger =
    if 0 != ( reg.ld and cast[T](1 shl 1) ): 1 else: 0

proc `b2=`*[T:SomeInteger,U: SomeInteger](reg: ptr T, val:U) =
    if val != 0: reg.st  ( reg.ld or cast[T](1 shl 2) )
    else: reg.st  (reg.ld and not cast[T](1 shl 2) )
proc b2*[T:SomeInteger](reg: ptr T): SomeInteger =
    if 0 != ( reg.ld and cast[T](1 shl 2) ): 1 else: 0

proc `b3=`*[T:SomeInteger,U: SomeInteger](reg: ptr T, val:U) =
    if val != 0: reg.st  ( reg.ld or cast[T](1 shl 3) )
    else: reg.st  (reg.ld and not cast[T](1 shl 3) )
proc b3*[T:SomeInteger](reg: ptr T): SomeInteger =
    if 0 != ( reg.ld and cast[T](1 shl 3) ): 1 else: 0

proc `b4=`*[T:SomeInteger,U: SomeInteger](reg: ptr T, val:U) =
    if val != 0: reg.st  ( reg.ld or cast[T](1 shl 4) )
    else: reg.st  (reg.ld and not cast[T](1 shl 4) )
proc b4*[T:SomeInteger](reg: ptr T): SomeInteger =
    if 0 != ( reg.ld and cast[T](1 shl 4) ): 1 else: 0

proc `b5=`*[T:SomeInteger,U: SomeInteger](reg: ptr T, val:U) =
    if val != 0: reg.st  ( reg.ld or cast[T](1 shl 5) )
    else: reg.st  (reg.ld and not cast[T](1 shl 5) )
proc b5*[T:SomeInteger](reg: ptr T): SomeInteger =
    if 0 != ( reg.ld and cast[T](1 shl 5) ): 1 else: 0

proc `b6=`*[T:SomeInteger,U: SomeInteger](reg: ptr T, val:U) =
    if val != 0: reg.st  ( reg.ld or cast[T](1 shl 6) )
    else: reg.st  (reg.ld and not cast[T](1 shl 6) )
proc b6*[T:SomeInteger](reg: ptr T): SomeInteger =
    if 0 != ( reg.ld and cast[T](1 shl 6) ): 1 else: 0

proc `b7=`*[T:SomeInteger,U: SomeInteger](reg: ptr T, val:U) =
    if val != 0: reg.st  ( reg.ld or cast[T](1 shl 7) )
    else: reg.st  (reg.ld and not cast[T](1 shl 7) )
proc b7*[T:SomeInteger](reg: ptr T): SomeInteger =
    if 0 != ( reg.ld and cast[T](1 shl 7) ): 1 else: 0


template bit*[T: SomeInteger](n: varargs[T]): T =
  var ret: T = 0;
  for i in n:
    ret = ret or cast[T](1 shl i)
  ret

template shift*[T: SomeInteger](reg: ptr T, n: T): T =
    let tmp = reg.ld shl n
    reg.st tmp
    tmp

template bset*[T:SomeInteger](reg: ptr T, n :varargs) =
  reg.st ((reg.ld) or cast[T](bit(n)))

template bclr*[T:SomeInteger](reg: ptr T, n :varargs) =
  reg.st ((reg.ld) and not cast[T](bit(n)))

template bitIsSet*[T:SomeInteger](reg:ptr T, n: varargs): bool =
  (((reg.ld) and cast[T](bit(n))) != 0)

template bitIsClr*[T:SomeInteger](reg:ptr T, n: varargs): bool =
   (not bitIsSet(reg, n))

