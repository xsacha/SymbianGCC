;; Software Code Disclaimer
;; xlp.md   Machine Description for the NLM XLP Microprocessor
;; Copyright © 2006 Netlogic Microsystems. "NLM")
;;  
;; This program is free software.  You may use it, redistribute it  
;; and/or modify it under the terms of the GNU General Public License 
;; as published by the Free Software Foundation; either version two 
;; of the License or (at your option) any later version.
;; 								
;; This program is distributed in the hope that you will find it  
;; useful.  Notwithstanding the foregoing, you understand and agree  
;; that this program is provided by NLM "as is," and without any  
;; warranties, whether express, implied or statutory, including without  
;; limitation any implied warranty of non-infringement, merchantability  
;; or fitness for a particular purpose.  In no event will NLM be liable  
;; for any loss of data, lost profits, cost of procurement of substitute  
;; technology or services or for any direct, indirect, incidental,        
;; consequential or special damages arising from the use of this program,  
;; however caused.  Your unconditional agreement to these terms and    
;; conditions is an express condition to, and shall be deemed to occur  
;; upon, your use, redistribution and/or modification of this program.  
;; 
;; See the GNU General Public License for more details.
;;
;; DFA-based pipeline description for XLP
;;
;;
(define_automaton "xlp_cpu")

;; CPU function units.
(define_cpu_unit "xlp_ex0" "xlp_cpu")
(define_cpu_unit "xlp_ex1" "xlp_cpu")
(define_cpu_unit "xlp_ex2" "xlp_cpu")
(define_cpu_unit "xlp_ex3" "xlp_cpu")

;; Floating-point units.
(define_cpu_unit "xlp_fp" "xlp_cpu")

;; Integer Multiply Unit
(define_cpu_unit "xlp_div" "xlp_cpu")

;; Floating Point Sqrt/Divide
(define_cpu_unit "xlp_divsq" "xlp_cpu")

;; Define reservations for common combinations.

;;
;; The ordering of the instruction-execution-path/resource-usage
;; descriptions (also known as reservation RTL) is roughly ordered
;; based on the define attribute RTL for the "type" classification.
;; When modifying, remember that the first test that matches is the
;; reservation used!
;;
(define_insn_reservation "ir_xlp_unknown" 1
  (and (eq_attr "cpu" "xlp")
       (eq_attr "type" "unknown,multi"))
  "xlp_ex0+xlp_ex1+xlp_ex2+xlp_ex3")

(define_insn_reservation "ir_xlp_branch" 1
  (and (eq_attr "cpu" "xlp")
       (eq_attr "type" "branch,jump,call"))
  "xlp_ex3")

(define_insn_reservation "ir_xlp_prefeth" 1
  (and (eq_attr "cpu" "xlp")
       (eq_attr "type" "prefetch,prefetchx"))
  "xlp_ex0|xlp_ex1")

(define_insn_reservation "ir_xlp_load" 4
  (and (eq_attr "cpu" "xlp")
       (eq_attr "type" "load"))
  "xlp_ex0 | xlp_ex1")

(define_insn_reservation "ir_xlp_fpload" 5
  (and (eq_attr "cpu" "xlp")
       (eq_attr "type" "fpload,fpidxload"))
  "xlp_ex0 | xlp_ex1")

(define_insn_reservation "ir_xlp_alu" 1
  (and (eq_attr "cpu" "xlp")
       (eq_attr "type" "const,arith,shift,slt,clz,nop"))
  "xlp_ex0 | xlp_ex1 | xlp_ex2 | xlp_ex3")

(define_insn_reservation "ir_xlp_condmov" 1
  (and (eq_attr "cpu" "xlp")
       (eq_attr "type" "condmove"))
  "xlp_ex2")

(define_insn_reservation "ir_xlp_mul" 6
  (and (eq_attr "cpu" "xlp")
       (eq_attr "type" "imul,imul3,imadd"))
  "xlp_ex2")

(define_insn_reservation "ir_xlp_div" 36
  (and (eq_attr "cpu" "xlp")
       (eq_attr "type" "idiv"))
  "xlp_ex2+xlp_div,xlp_div*35")

(define_insn_reservation "ir_xlp_store" 1
  (and (eq_attr "cpu" "xlp")
       (eq_attr "type" "store,fpstore,fpidxstore"))
  "xlp_ex0 | xlp_ex1")

(define_insn_reservation "ir_xlp_fpmove" 2
  (and (eq_attr "cpu" "xlp")
       (eq_attr "type" "mfc"))
 "xlp_ex3,xlp_fp")

(define_insn_reservation "ir_xlp_hilo" 1
  (and (eq_attr "cpu" "xlp")
       (eq_attr "type" "mthilo,mfhilo"))
  "xlp_ex2")

(define_insn_reservation "ir_xlp_fpsimple" 6
  (and (eq_attr "cpu" "xlp")
       (eq_attr "type" "fmove,fadd,fmul,fmadd,fabs,fneg,fcmp,fcvt"))
  "xlp_fp")

(define_insn_reservation "ir_xlp_fpcomplex" 30
  (and (eq_attr "cpu" "xlp")
       (eq_attr "type" "fdiv,frdiv,frdiv1,frdiv2,fsqrt,frsqrt,frsqrt1,frsqrt2"))
  "xlp_fp+xlp_divsq,xlp_divsq*29")

(define_bypass 5 "ir_xlp_mul" "ir_xlp_hilo")
