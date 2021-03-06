(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2012     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

open Names
open Term
open Context
open Environ
open Evd
open Reduction
open Proof_type
open Refiner
open Redexpr
open Tacexpr
open Glob_term
open Pattern
open Locus
open Misctypes

(** Operations for handling terms under a local typing context. *)

type 'a sigma   = 'a Evd.sigma;;
type tactic     = Proof_type.tactic;;

val sig_it  : 'a sigma   -> 'a
val project : goal sigma -> evar_map

val re_sig : 'a -> evar_map -> 'a sigma

val unpackage : 'a sigma -> evar_map ref * 'a
val repackage : evar_map ref -> 'a -> 'a sigma
val apply_sig_tac :
  evar_map ref -> (goal sigma -> (goal list) sigma) -> goal -> (goal list)

val pf_concl              : goal sigma -> types
val pf_env                : goal sigma -> env
val pf_hyps               : goal sigma -> named_context
(*i val pf_untyped_hyps       : goal sigma -> (Id.t * constr) list i*)
val pf_hyps_types         : goal sigma -> (Id.t * types) list
val pf_nth_hyp_id         : goal sigma -> int -> Id.t
val pf_last_hyp           : goal sigma -> named_declaration
val pf_ids_of_hyps        : goal sigma -> Id.t list
val pf_global             : goal sigma -> Id.t -> constr
val pf_parse_const        : goal sigma -> string -> constr
val pf_type_of            : goal sigma -> constr -> types
val pf_check_type         : goal sigma -> constr -> types -> unit
val pf_hnf_type_of        : goal sigma -> constr -> types

val pf_get_hyp            : goal sigma -> Id.t -> named_declaration
val pf_get_hyp_typ        : goal sigma -> Id.t -> types

val pf_get_new_id  : Id.t      -> goal sigma -> Id.t
val pf_get_new_ids : Id.t list -> goal sigma -> Id.t list

val pf_reduction_of_red_expr : goal sigma -> red_expr -> constr -> constr


val pf_apply : (env -> evar_map -> 'a) -> goal sigma -> 'a
val pf_reduce :
  (env -> evar_map -> constr -> constr) ->
  goal sigma -> constr -> constr

val pf_whd_betadeltaiota       : goal sigma -> constr -> constr
val pf_whd_betadeltaiota_stack : goal sigma -> constr -> constr * constr list
val pf_hnf_constr              : goal sigma -> constr -> constr
val pf_red_product             : goal sigma -> constr -> constr
val pf_nf                      : goal sigma -> constr -> constr
val pf_nf_betaiota             : goal sigma -> constr -> constr
val pf_reduce_to_quantified_ind : goal sigma -> types -> inductive * types
val pf_reduce_to_atomic_ind     : goal sigma -> types -> inductive * types
val pf_compute                 : goal sigma -> constr -> constr
val pf_unfoldn    : (occurrences * evaluable_global_reference) list
  -> goal sigma -> constr -> constr

val pf_const_value : goal sigma -> constant -> constr
val pf_conv_x      : goal sigma -> constr -> constr -> bool
val pf_conv_x_leq  : goal sigma -> constr -> constr -> bool

val pf_matches     : goal sigma -> constr_pattern -> constr -> patvar_map
val pf_is_matching : goal sigma -> constr_pattern -> constr -> bool


(** {6 The most primitive tactics. } *)

val refiner                   : rule -> tactic
val introduction_no_check     : Id.t -> tactic
val internal_cut_no_check     : bool -> Id.t -> types -> tactic
val internal_cut_rev_no_check : bool -> Id.t -> types -> tactic
val refine_no_check           : constr -> tactic
val convert_concl_no_check    : types -> cast_kind -> tactic
val convert_hyp_no_check      : named_declaration -> tactic
val thin_no_check             : Id.t list -> tactic
val thin_body_no_check        : Id.t list -> tactic
val move_hyp_no_check         :
  bool -> Id.t -> Id.t move_location -> tactic
val rename_hyp_no_check       : (Id.t*Id.t) list -> tactic
val order_hyps : Id.t list -> tactic
val mutual_fix      :
  Id.t -> int -> (Id.t * int * constr) list -> int -> tactic
val mutual_cofix    : Id.t -> (Id.t * constr) list -> int -> tactic

(** {6 The most primitive tactics with consistency and type checking } *)

val introduction     : Id.t -> tactic
val internal_cut     : bool -> Id.t -> types -> tactic
val internal_cut_rev : bool -> Id.t -> types -> tactic
val refine           : constr -> tactic
val convert_concl    : types -> cast_kind -> tactic
val convert_hyp      : named_declaration -> tactic
val thin             : Id.t list -> tactic
val thin_body        : Id.t list -> tactic
val move_hyp         : bool -> Id.t -> Id.t move_location -> tactic
val rename_hyp       : (Id.t*Id.t) list -> tactic

(** {6 Tactics handling a list of goals. } *)

type tactic_list = Refiner.tactic_list

val first_goal         : 'a list sigma -> 'a sigma
val goal_goal_list     : 'a sigma -> 'a list sigma
val apply_tac_list     : tactic -> tactic_list
val then_tactic_list   : tactic_list -> tactic_list -> tactic_list
val tactic_list_tactic : tactic_list -> tactic
val tclFIRSTLIST       : tactic_list list -> tactic_list
val tclIDTAC_list      : tactic_list

(** {6 Pretty-printing functions (debug only). } *)
val pr_gls    : goal sigma -> Pp.std_ppcmds
val pr_glls   : goal list sigma -> Pp.std_ppcmds

(* Variants of [Tacmach] functions built with the new proof engine *)
module New : sig
  open Proofview

  val pf_apply : (env -> evar_map -> 'a) -> Proofview.Goal.t -> 'a
  val pf_global : identifier -> Proofview.Goal.t -> constr
  val of_old : (Proof_type.goal Evd.sigma -> 'a) -> Proofview.Goal.t -> 'a

  val pf_type_of : Proofview.Goal.t -> Term.constr -> Term.types

  val pf_get_new_id  : identifier -> Proofview.Goal.t -> identifier
  val pf_ids_of_hyps : Proofview.Goal.t -> identifier list
  val pf_hyps_types : Proofview.Goal.t -> (identifier * types) list

  val pf_get_hyp : identifier -> Proofview.Goal.t -> named_declaration
  val pf_get_hyp_typ        : identifier -> Proofview.Goal.t -> types
  val pf_last_hyp           : Proofview.Goal.t -> named_declaration
end
