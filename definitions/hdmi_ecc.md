# HDMI BCH ECC Parity Equations

This document describes the BCH ECC (Error Correction Code) used in HDMI Data Island packets for the Header and Subpackets.

## Overview
HDMI Data Island packets use a BCH error correction scheme to ensure data integrity.
- **Header ECC**: BCH(32, 24) - 24 bits of data (HB0, HB1, HB2) protected by 8 bits of parity.
- **Subpacket ECC**: BCH(64, 56) - 56 bits of data (SB0-SB6) protected by 8 bits of parity.

## Generator Polynomial
The generator polynomial for both the Header and Subpacket ECC is:
$$G(x) = 1 + x + x^5 + x^6 + x^8$$

In binary form, this is `1 0 1 1 0 0 0 1 1` (0x163).

## Bit Ordering
Data is processed LSB-first. For a 24-bit header $[D_{23} \dots D_0]$:
- $D_0$ is the LSB of HB0.
- $D_8$ is the LSB of HB1.
- $D_{16}$ is the LSB of HB2.

## Header ECC XOR Equations (BCH(32,24))
Derived for 24 data bits $D_0 \dots D_{23}$:

- **P0** = D1 ^ D2 ^ D4 ^ D8 ^ D9 ^ D10 ^ D11 ^ D13 ^ D14 ^ D15 ^ D19 ^ D20 ^ D21 ^ D23
- **P1** = D0 ^ D2 ^ D3 ^ D4 ^ D7 ^ D11 ^ D12 ^ D15 ^ D18 ^ D21 ^ D22 ^ D23
- **P2** = D1 ^ D2 ^ D3 ^ D6 ^ D10 ^ D11 ^ D14 ^ D17 ^ D20 ^ D21 ^ D22
- **P3** = D0 ^ D1 ^ D2 ^ D5 ^ D9 ^ D10 ^ D13 ^ D16 ^ D19 ^ D20 ^ D21
- **P4** = D0 ^ D1 ^ D4 ^ D8 ^ D9 ^ D12 ^ D15 ^ D18 ^ D19 ^ D20
- **P5** = D0 ^ D1 ^ D2 ^ D3 ^ D4 ^ D7 ^ D9 ^ D10 ^ D13 ^ D15 ^ D17 ^ D18 ^ D20 ^ D21 ^ D23
- **P6** = D0 ^ D3 ^ D4 ^ D6 ^ D10 ^ D11 ^ D12 ^ D13 ^ D15 ^ D16 ^ D17 ^ D21 ^ D22 ^ D23
- **P7** = D2 ^ D3 ^ D5 ^ D9 ^ D10 ^ D11 ^ D12 ^ D14 ^ D15 ^ D16 ^ D20 ^ D21 ^ D22

## Subpacket ECC XOR Equations (BCH(64,56))
Derived for 56 data bits $D_0 \dots D_{55}$:

- **P0** = D0 ^ D1 ^ D2 ^ D3 ^ D4 ^ D6 ^ D8 ^ D13 ^ D14 ^ D15 ^ D18 ^ D19 ^ D20 ^ D21 ^ D26 ^ D27 ^ D29 ^ D30 ^ D33 ^ D34 ^ D36 ^ D40 ^ D41 ^ D42 ^ D43 ^ D45 ^ D46 ^ D47 ^ D51 ^ D52 ^ D53 ^ D55
- **P1** = D4 ^ D5 ^ D6 ^ D7 ^ D8 ^ D12 ^ D15 ^ D17 ^ D21 ^ D25 ^ D27 ^ D28 ^ D30 ^ D32 ^ D34 ^ D35 ^ D36 ^ D39 ^ D43 ^ D44 ^ D47 ^ D50 ^ D53 ^ D54 ^ D55
- **P2** = D3 ^ D4 ^ D5 ^ D6 ^ D7 ^ D11 ^ D14 ^ D16 ^ D20 ^ D24 ^ D26 ^ D27 ^ D29 ^ D31 ^ D33 ^ D34 ^ D35 ^ D38 ^ D42 ^ D43 ^ D46 ^ D49 ^ D52 ^ D53 ^ D54
- **P3** = D2 ^ D3 ^ D4 ^ D5 ^ D6 ^ D10 ^ D13 ^ D15 ^ D19 ^ D23 ^ D25 ^ D26 ^ D28 ^ D30 ^ D32 ^ D33 ^ D34 ^ D37 ^ D41 ^ D42 ^ D45 ^ D48 ^ D51 ^ D52 ^ D53
- **P4** = D1 ^ D2 ^ D3 ^ D4 ^ D5 ^ D9 ^ D12 ^ D14 ^ D18 ^ D22 ^ D24 ^ D25 ^ D27 ^ D29 ^ D31 ^ D32 ^ D33 ^ D36 ^ D40 ^ D41 ^ D44 ^ D47 ^ D50 ^ D51 ^ D52
- **P5** = D6 ^ D11 ^ D14 ^ D15 ^ D17 ^ D18 ^ D19 ^ D20 ^ D23 ^ D24 ^ D27 ^ D28 ^ D29 ^ D31 ^ D32 ^ D33 ^ D34 ^ D35 ^ D36 ^ D39 ^ D41 ^ D42 ^ D45 ^ D47 ^ D49 ^ D50 ^ D52 ^ D53 ^ D55
- **P6** = D0 ^ D1 ^ D2 ^ D3 ^ D4 ^ D5 ^ D6 ^ D8 ^ D10 ^ D15 ^ D16 ^ D17 ^ D20 ^ D21 ^ D22 ^ D23 ^ D28 ^ D29 ^ D31 ^ D32 ^ D35 ^ D36 ^ D38 ^ D42 ^ D43 ^ D44 ^ D45 ^ D47 ^ D48 ^ D49 ^ D53 ^ D54 ^ D55
- **P7** = D0 ^ D1 ^ D2 ^ D3 ^ D4 ^ D5 ^ D7 ^ D9 ^ D14 ^ D15 ^ D16 ^ D19 ^ D20 ^ D21 ^ D22 ^ D27 ^ D28 ^ D30 ^ D31 ^ D34 ^ D35 ^ D37 ^ D41 ^ D42 ^ D43 ^ D44 ^ D46 ^ D47 ^ D48 ^ D52 ^ D53 ^ D54

## Implementation Note
The equations above represent a parallel XOR implementation. Alternatively, an 8-bit Serial LFSR can be used, shifting the data in LSB-first for 24 or 56 cycles.
