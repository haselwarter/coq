(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2012     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

(** [minus] (difference between two natural numbers) is defined in [Init/Peano.v] as:
<<
Fixpoint minus (n m:nat) : nat :=
  match n, m with
  | O, _ => n
  | S k, O => S k
  | S k, S l => k - l
  end
where "n - m" := (minus n m) : nat_scope.
>>
*)

Require Import Lt.
Require Import Le.

Local Open Scope nat_scope.

Implicit Types m n p : nat.

(** * 0 is right neutral *)

Lemma minus_n_O : forall n, n = n - 0.
Proof.
  induction n; simpl; auto with arith.
Qed.
Hint Resolve minus_n_O: arith v62.

(** * Permutation with successor *)

Lemma minus_Sn_m : forall n m, m <= n -> S (n - m) = S n - m.
Proof.
  intros n m Le; pattern m, n; apply le_elim_rel; simpl;
    auto with arith.
Qed.
Hint Resolve minus_Sn_m: arith v62.

Theorem pred_of_minus : forall n, pred n = n - 1.
Proof.
  intro x; induction x; simpl; auto with arith.
Qed.

(** * Diagonal *)

Lemma minus_diag : forall n, n - n = 0.
Proof.
  induction n; simpl; auto with arith.
Qed.

Lemma minus_diag_reverse : forall n, 0 = n - n.
Proof.
  auto using minus_diag.
Qed.
Hint Resolve minus_diag_reverse: arith v62.

Notation minus_n_n := minus_diag_reverse.

(** * Simplification *)

Lemma minus_plus_simpl_l_reverse : forall n m p, n - m = p + n - (p + m).
Proof.
  induction p; simpl; auto with arith.
Qed.
Hint Resolve minus_plus_simpl_l_reverse: arith v62.

(** * Relation with plus *)

Lemma plus_minus : forall n m p, n = m + p -> p = n - m.
Proof.
  intros n m p; pattern m, n; apply nat_double_ind; simpl;
    intros.
  replace (n0 - 0) with n0; auto with arith.
  absurd (0 = S (n0 + p)); auto with arith.
  auto with arith.
Qed.
Hint Immediate plus_minus: arith v62.

Lemma minus_plus : forall n m, n + m - n = m.
  symmetry ; auto with arith.
Qed.
Hint Resolve minus_plus: arith v62.

Lemma le_plus_minus : forall n m, n <= m -> m = n + (m - n).
Proof.
  intros n m Le; pattern n, m; apply le_elim_rel; simpl;
    auto with arith.
Qed.
Hint Resolve le_plus_minus: arith v62.

Lemma le_plus_minus_r : forall n m, n <= m -> n + (m - n) = m.
Proof.
  symmetry ; auto with arith.
Qed.
Hint Resolve le_plus_minus_r: arith v62.

(** * Relation with order *)

Theorem minus_le_compat_r : forall n m p : nat, n <= m -> n - p <= m - p.
Proof.
  intros n m p; generalize n m; clear n m; induction p as [|p HI].
    intros n m; rewrite <- (minus_n_O n); rewrite <- (minus_n_O m); trivial.

    intros n m Hnm; apply le_elim_rel with (n:=n) (m:=m); auto with arith.
    intros q r H _. simpl. auto using HI.
Qed.

Theorem minus_le_compat_l : forall n m p : nat, n <= m -> p - m <= p - n.
Proof.
  intros n m p; generalize n m; clear n m; induction p as [|p HI].
    trivial.

    intros n m Hnm; apply le_elim_rel with (n:=n) (m:=m); trivial.
      intros q; destruct q; auto with arith.
        simpl.
        apply le_trans with (m := p - 0); [apply HI | rewrite <- minus_n_O];
          auto with arith.

      intros q r Hqr _. simpl. auto using HI.
Qed.

Corollary le_minus : forall n m, n - m <= n.
Proof.
  intros n m; rewrite minus_n_O; auto using minus_le_compat_l with arith.
Qed.

Lemma lt_minus : forall n m, m <= n -> 0 < m -> n - m < n.
Proof.
  intros n m Le; pattern m, n; apply le_elim_rel; simpl;
    auto using le_minus with arith.
    intros; absurd (0 < 0); auto with arith.
Qed.
Hint Resolve lt_minus: arith v62.

Lemma lt_O_minus_lt : forall n m, 0 < n - m -> m < n.
Proof.
  intros n m; pattern n, m; apply nat_double_ind; simpl;
    auto with arith.
  intros; absurd (0 < 0); trivial with arith.
Qed.
Hint Immediate lt_O_minus_lt: arith v62.

Theorem not_le_minus_0 : forall n m, ~ m <= n -> n - m = 0.
Proof.
  intros y x; pattern y, x; apply nat_double_ind;
    [ simpl; trivial with arith
      | intros n H; absurd (0 <= S n); [ assumption | apply le_O_n ]
      | simpl; intros n m H1 H2; apply H1; unfold not; intros H3;
	apply H2; apply le_n_S; assumption ].
Qed.
