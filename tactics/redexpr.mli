(************************************************************************)
(*         *   The Coq Proof Assistant / The Coq Development Team       *)
(*  v      *         Copyright INRIA, CNRS and contributors             *)
(* <O___,, * (see version control and CREDITS file for authors & dates) *)
(*   \VV/  **************************************************************)
(*    //   *    This file is distributed under the terms of the         *)
(*         *     GNU Lesser General Public License Version 2.1          *)
(*         *     (see LICENSE file for the text of the license)         *)
(************************************************************************)

(** Interpretation layer of redexprs such as hnf, cbv, etc. *)

open Constr
open EConstr
open Pattern
open Genredexpr
open Reductionops
open Locus

type red_expr = (constr, Evaluable.t, constr_pattern) red_expr_gen

type red_expr_val

val out_with_occurrences : 'a with_occurrences -> occurrences * 'a

val eval_red_expr : Environ.env -> red_expr -> red_expr_val

val reduction_of_red_expr_val : ?occs:(Locus.occurrences_expr * int) ->
  red_expr_val -> e_reduction_function * cast_kind

(** Composition of {!reduction_of_red_expr_val} with {!eval_red_expr} *)
val reduction_of_red_expr :
  Environ.env -> red_expr -> e_reduction_function * cast_kind

(** [true] if we should use the vm to verify the reduction *)

(** Adding a custom reduction (function to be use at the ML level)
   NB: the effect is permanent. *)
val declare_reduction : string -> reduction_function -> unit

(** Adding a custom reduction (function to be called a vernac command).
   The boolean flag is the locality. *)
val declare_red_expr : bool -> string -> red_expr -> unit

(** Opaque and Transparent commands. *)

(** Sets the expansion strategy of a constant. When the boolean is
   true, the effect is non-synchronous (i.e. it does not survive
   section and module closure). *)
val set_strategy :
  bool -> (Conv_oracle.level * Evaluable.t list) list -> unit

(** call by value normalisation function using the virtual machine *)
val cbv_vm : reduction_function

(** [subst_red_expr sub c] performs the substitution [sub] on all kernel
   names appearing in [c] *)
val subst_red_expr : Mod_subst.substitution -> red_expr -> red_expr

val wit_red_expr : (raw_red_expr, glob_red_expr, red_expr) Genarg.genarg_type

module Intern : sig
  open Libnames
  open Constrexpr
  open Names

  type ('constr,'ref,'pat) intern_env = {
    strict_check : bool;
    local_ref : qualid -> 'ref option;
    global_ref : ?short:lident -> Evaluable.t -> 'ref;
    intern_constr : constr_expr -> 'constr;
    ltac_sign : Constrintern.ltac_sign;
    intern_pattern : constr_expr -> 'pat;
    pattern_of_glob : Glob_term.glob_constr -> 'pat;
  }

  val intern_red_expr : ('a,'b,'c) intern_env -> raw_red_expr -> ('a,'b,'c) red_expr_gen

  val from_env : Environ.env -> (Glob_term.glob_constr, Evaluable.t, Glob_term.glob_constr) intern_env

end
