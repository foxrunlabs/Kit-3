;===============================================================================
; Copyright 2020 Ryan Clarke
;
; Licensed under the Apache License, Version 2.0 (the "License"); you may not
; use this file except in compliance with the License. You may obtain a copy of
; the License at
; 
;     http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
; WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
; License for the specific language governing permissions and limitations under
; the License.
;===============================================================================

;===============================================================================
; Program   : Boot Loader
; File Name : bootload.inc
; Project   : Kit-3 8-bit Computer
; Author    : Ryan Clarke
; E-mail    : kj6msg@icloud.com
;-------------------------------------------------------------------------------
; Purpose   : Header file for the Kit-3 boot loader.
;===============================================================================


;===============================================================================
; ASCII CHARACTER CONSTANTS
;===============================================================================

NUL  = $00
SOH  = $01
_STX = $02
ETX  = $03
EOT  = $04
ENQ  = $05
ACK  = $06
BEL  = $07
BS   = $08
HT   = $09
LF   = $0A
VT   = $0B
FF   = $0C
CR   = $0D
SO   = $0E
SI   = $0F
DLE  = $10
DC1  = $11
DC2  = $12
DC3  = $13
DC4  = $14
NAK  = $15
SYN  = $16
ETB  = $17
CAN  = $18
EM   = $19
SUB  = $1A
ESC  = $1B
FS   = $1C
GS   = $1D
RS   = $1E
US   = $1F
DEL  = $7F


;===============================================================================
; ZERO PAGE MEMORY MAP
;===============================================================================

;= GENERAL REGISTERS ===========================================================

r16a = $00
r8a  = $00


;===============================================================================
; HARDWARE MEMORY MAP
;===============================================================================

IO = $0200

;= DISPLAY =====================================================================

DISPLAY = IO + $00
CTRL    = DISPLAY + $0
COLOR   = DISPLAY + $1
ADDRL   = DISPLAY + $2
ADDRH   = DISPLAY + $3
VRAM    = DISPLAY + $4
CURSL   = DISPLAY + $5
CURSH   = DISPLAY + $6
