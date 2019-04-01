/-
  The map R → R[1/f] induces a homeomorphism Spec(R[1/f]) → D(f).

  https://stacks.math.columbia.edu/tag/00E4
-/

import topology.basic
import ring_theory.localization
import preliminaries.localisation
import spectrum_of_a_ring.zariski_topology
import spectrum_of_a_ring.induced_continuous_map

universes u

local attribute [instance] classical.prop_decidable

open localization_alt

section homeomorphism

parameters {R : Type u} [comm_ring R] 
parameters {Rf : Type u} [comm_ring Rf] {h : R → Rf} [is_ring_hom h]
parameters {f : R} (HL : is_localization (powers f) h) 

def φ : Spec Rf → Spec R := Zariski.induced h

-- There is no f^n in h⁻¹(I).

include HL

lemma powers_f_not_preimage (I : ideal Rf) (PI : ideal.is_prime I)
: ∀ fn ∈ powers f, fn ∉ ideal.comap h I :=
begin
  have PIinv := @ideal.is_prime.comap _ _ _ _ h _ I PI,
  intros fn Hfn HC,
  replace HC : h fn ∈ I := HC,
  have Hinvfn := HL.1 ⟨fn, Hfn⟩,
  rcases Hinvfn with ⟨s, Hs⟩,
  simp at Hs,
  have Hone := @ideal.mul_mem_right _ _ I _ s HC,
  rw Hs at Hone,
  apply PI.1,
  exact (ideal.eq_top_iff_one _).2 Hone,
end

lemma h_powers_f_not_mem (I : ideal Rf) (PI : ideal.is_prime I)
: ∀ fn ∈ powers f, h fn ∉ I :=
λ fn Hfn HC, (powers_f_not_preimage I PI) fn Hfn HC

lemma phi_injective : function.injective φ :=
begin
  intros x y Hxy,
  rcases x with ⟨I, PI⟩,
  rcases y with ⟨J, PJ⟩,
  simp [φ, Zariski.induced] at Hxy,
  have HhfnI := h_powers_f_not_mem I PI,
  have HhfnJ := h_powers_f_not_mem J PJ,
  rcases HL with ⟨Hinv, Hden, Hker⟩,
  -- TODO : very similar branches.
  simp,
  apply ideal.ext,
  intros x,
  split,
  { intros Hx,
    have Hdenx := Hden x,
    rcases Hdenx with ⟨⟨fn, r⟩, Hhr⟩,
    simp at Hhr,
    have Hinvfn := Hinv fn,
    rcases Hinvfn with ⟨s, Hfn⟩,
    have H := @ideal.mul_mem_left _ _ I (h fn) _ Hx,
    rw Hhr at H,
    replace H : r ∈ ideal.comap h I := H,
    rw Hxy at H, 
    replace H : h r ∈ J := H,
    rw ←Hhr at H,
    replace H := PJ.2 H,
    cases H,
    { exfalso,
      exact HhfnJ fn.1 fn.2 H, },
    { exact H, } },
  { intros Hx,
    have Hdenx := Hden x,
    rcases Hdenx with ⟨⟨fn, r⟩, Hhr⟩,
    simp at Hhr,
    have Hinvfn := Hinv fn,
    rcases Hinvfn with ⟨s, Hfn⟩,
    have H := @ideal.mul_mem_left _ _ J (h fn) _ Hx,
    rw Hhr at H,
    replace H : r ∈ ideal.comap h J := H,
    rw ←Hxy at H, 
    replace H : h r ∈ I := H,
    rw ←Hhr at H,
    replace H := PI.2 H,
    cases H,
    { exfalso,
      exact HhfnI fn.1 fn.2 H, },
    { exact H, } },
end

-- Random stuff.

lemma ring_hom.pow {A : Type u} [comm_ring A] {B : Type u} [comm_ring B]
(m : A → B) [is_ring_hom m] (a : A)
: ∀ (n : ℕ), m (a ^ n) = (m a) ^ n :=
begin
  intros n,
  induction n,
  { simp,
    exact is_ring_hom.map_one m, },
  { rw pow_succ,
    rw pow_succ,
    rw is_ring_hom.map_mul m,
    rw n_ih, }
end

lemma localization.zero (I : ideal R) [PI : ideal.is_prime I] 
(Hfn : (0 : R) ∈ powers f)
: (ideal.map h I : ideal Rf) = ⊥ :=
begin
  have HL' := HL,
  rcases HL' with ⟨Hinv, Hden, Hker⟩,
  apply ideal.ext,
  intros x,
  split,
  swap,
  { intros H,
    simp at H,
    rw H,
    rw ←is_ring_hom.map_zero h,
    apply ideal.mem_map_of_mem,
    simp, },
  { intros Hx,
    rcases (Hden x) with ⟨⟨a, b⟩, Hab⟩,
    simp at Hab,
    rcases (Hinv a) with ⟨w, Hw⟩,
    have Hall : ∀ (y : R), y ∈ submonoid_ann (powers f),
      intros y,
      simp [submonoid_ann, set.range, ann_aux],
      use [⟨y, ⟨0, Hfn⟩⟩],
      simp,
    have Htop : submonoid_ann (powers f) = ⊤,
      apply ideal.ext,
      intros x,
      split,
      { intros Hx,
        cases Hx,
        unfold ann_aux at Hx_w, },
      { intros Hx,
        exact (Hall x), },
    unfold ker at Hker,
    rw Htop at Hker,
    have Hx : (1 : R) ∈ (⊤ : ideal R),
      trivial,
    rw ←Hker at Hx,
    replace Hx : h 1 = 0 := Hx,
    rw (is_ring_hom.map_one h) at Hx,
    rw ←mul_one x,
    rw Hx,
    simp, },
end

def localisation_map_ideal (I : ideal R) : ideal Rf :=
{ carrier := { x | ∃ (y ∈ h '' I) (r : Rf), x = y * r },
  zero := -- ⟨0, ⟨I.2, is_ring_hom.map_zero h⟩⟩
    begin
      use [h 0, 0],
      exact ⟨I.2, rfl⟩,
      use 1,
      rw mul_one,
      rw ←is_ring_hom.map_zero h,
    end,
  add := 
    begin
      intros x y Hx Hy,
      rcases Hx with ⟨a, ⟨Ha, ⟨r, Hx⟩⟩⟩,
      rcases Hy with ⟨b, ⟨Hb, ⟨t, Hy⟩⟩⟩,
      rcases Ha with ⟨v, ⟨Hv, Ha⟩⟩,
      rcases Hb with ⟨w, ⟨Hw, Hb⟩⟩,
      rw ←Ha at Hx,
      rw ←Hb at Hy,
      rw [Hx, Hy],
      rcases HL with ⟨Hinv, Hden, Hker⟩,
      rcases (Hden r) with ⟨⟨fn, l⟩, Hl⟩,
      rcases (Hinv fn) with ⟨hfninv, Hfn⟩,
      simp at Hl,
      rw mul_comm at Hfn,
      rcases (Hden t) with ⟨⟨fm, k⟩, Hk⟩,
      rcases (Hinv fm) with ⟨hfminv, Hfm⟩,
      simp at Hk,
      rw mul_comm at Hfm,
      -- Get rid of r.
      rw ←one_mul (_ + _),
      rw ←Hfn,
      rw mul_assoc,
      rw mul_add,
      rw mul_comm _ r,
      rw ←mul_assoc _ r _,
      rw Hl,
      -- Get rid of t.
      rw ←one_mul (_ * _),
      rw ←Hfm,
      rw mul_assoc,
      rw ←mul_assoc (h _) _ _,
      rw mul_comm (h _),
      rw mul_assoc _ (h _) _,
      rw mul_add,
      rw ←mul_assoc _ _ t,
      rw add_comm,
      rw ←mul_assoc (h fm) _ _,
      rw mul_comm (h fm),
      rw mul_assoc _ _ t,
      rw Hk,
      -- Rearrange.
      repeat { rw ←is_ring_hom.map_mul h, },
      rw ←mul_assoc _ _ v,
      rw mul_assoc ↑fn,
      rw mul_comm w,
      rw ←mul_assoc ↑fn,
      rw ←is_ring_hom.map_add h,
      rw ←mul_assoc,
      rw mul_comm,
      -- Ready to prove it.
      have HyI : ↑fn * k * w + ↑fm * l * v ∈ ↑I,
        apply I.3,
        { apply I.4,
          exact Hw, },
        { apply I.4,
          exact Hv, },
      use [h (↑fn * k * w + ↑fm * l * v)],
      use [⟨↑fn * k * w + ↑fm * l * v, ⟨HyI, rfl⟩⟩],
      use [hfminv * hfninv],
    end,
  smul := 
    begin
      intros c x Hx,
      rcases Hx with ⟨a, ⟨Ha, ⟨r, Hx⟩⟩⟩,
      rcases Ha with ⟨v, ⟨Hv, Ha⟩⟩,
      rw [Hx, ←Ha],
      rw mul_comm _ r,
      unfold has_scalar.smul,
      rw mul_comm r,
      rw mul_comm c,
      rw mul_assoc,
      use [h v],
      use [⟨v, ⟨Hv, rfl⟩⟩],
      use [r * c],
    end, }

lemma localisation_map_ideal.eq (I : ideal R) [PI : ideal.is_prime I] 
: ideal.map h I = localisation_map_ideal I :=
begin
  have HL' := HL,
  rcases HL' with ⟨Hinv, Hden, Hker⟩,
  apply le_antisymm,
  { have Hgen : h '' I ⊆ localisation_map_ideal I,
      intros x Hx,
      use [x, Hx, 1],
      simp,
    replace Hgen := ideal.span_mono Hgen,
    rw ideal.span_eq at Hgen,
    exact Hgen, },
  { intros x Hx,
    rcases Hx with ⟨y, ⟨z, ⟨HzI, Hzy⟩⟩, ⟨r, Hr⟩⟩,
    rw [Hr, ←Hzy],
    exact ideal.mul_mem_right _ (ideal.mem_map_of_mem HzI), }
end

lemma localisation_map_ideal.not_top (I : ideal R) [PI : ideal.is_prime I] 
(Hfn : ∀ fn, (fn ∈ powers f) → fn ∉ I)
: ideal.map h I ≠ ⊤ :=
begin
  have HL' := HL,
  rcases HL' with ⟨Hinv, Hden, Hker⟩,
  intros HC,
  rw localisation_map_ideal.eq at HC,
  rw ideal.eq_top_iff_one at HC,
  rcases HC with ⟨x, ⟨y, ⟨HyI, Hyx⟩⟩, ⟨r, Hr⟩⟩,
  rcases (Hden x) with ⟨⟨q, p⟩, Hpq⟩,
  simp at Hpq,
  rw ←Hyx at Hpq,
  have Hz : h (q * y - p) = 0,
    rw (is_ring_hom.map_sub h),
    rw (is_ring_hom.map_mul h),
    rw Hpq,
    simp,
  replace Hz : ↑q * y - p ∈ ker h := Hz,
  rw Hker at Hz,
  rcases Hz with ⟨⟨⟨u, v⟩, Huv⟩, Hz⟩,
  simp at Hz,
  simp at Huv,
  rw Hz at Huv,
  have HzI : (0 : R) ∈ I := ideal.zero_mem I,
  rw ←Huv at HzI,
  replace HzI := PI.2 HzI,
  cases HzI,
  { have HqyI : ↑q * y ∈ I := ideal.mul_mem_left I HyI,
    have HpI := (ideal.neg_mem_iff I).1 ((ideal.add_mem_iff_left I HqyI).1 HzI), 
    rcases (Hden r) with ⟨⟨b, a⟩, Hab⟩,
    simp at Hab,
    rw Hyx at Hpq,
    have Hz2 : h (q * b - p * a) = 0,
      rw (is_ring_hom.map_sub h),
      repeat { rw (is_ring_hom.map_mul h), },
      rw [←Hab, ←Hpq],
      rw ←mul_comm r,
      rw mul_assoc,
      rw ←mul_assoc x,
      rw ←Hr,
      simp,
    replace Hz2 : ↑q * ↑b - p * a ∈ ker h := Hz2,
    rw Hker at Hz2,
    rcases Hz2 with ⟨⟨⟨w, z⟩, Hwz⟩, Hz2⟩,
    simp at Hz2,
    simp at Hwz,
    rw Hz2 at Hwz,
    have HzI : (0 : R) ∈ I := ideal.zero_mem I,
    rw ←Hwz at HzI,
    replace HzI := PI.2 HzI,
    cases HzI with HzI HzI,
    { have HnpaI : -(p * a) ∈ I 
        := (ideal.neg_mem_iff I).2 (ideal.mul_mem_right I HpI),
      have HC := (ideal.add_mem_iff_right I HnpaI).1 HzI,
      replace HC := PI.2 HC,
      cases HC,
      { exact Hfn q q.2 HC, },
      { exact Hfn b b.2 HC, }, },
    { exact Hfn z z.2 HzI, } },
  { exact Hfn v v.2 HzI, }
end

lemma localisation_map_ideal.is_prime (I : ideal R) [PI : ideal.is_prime I] 
(Hfn : ∀ fn, (fn ∈ powers f) → fn ∉ I)
: ideal.is_prime (ideal.map h I) :=
begin
  have HL' := HL,
  rcases HL' with ⟨Hinv, Hden, Hker⟩,
  constructor,
  { exact localisation_map_ideal.not_top I Hfn, },
  { intros x y Hxy,
    rw localisation_map_ideal.eq at Hxy,
    rcases Hxy with ⟨w, ⟨z, ⟨HzI, Hwz⟩⟩, ⟨r, Hr⟩⟩,
    rw ←Hwz at Hr,
    rcases (Hden r) with ⟨⟨q, p⟩,  Hpq⟩,
    rcases (Hden x) with ⟨⟨b₁, a₁⟩, Ha₁b₁⟩,
    rcases (Hden y) with ⟨⟨b₂, a₂⟩, Ha₂b₂⟩,
    simp at Hpq,
    simp at Ha₁b₁,
    simp at Ha₂b₂,
    have Hzpb₁b₂I : -(z * p * b₁ * b₂) ∈ I,
      rw mul_assoc,
      rw mul_assoc,
      rw ideal.neg_mem_iff I,
      exact ideal.mul_mem_right I HzI,
    have Hz : h (a₁ * a₂ * q - z * p * b₁ * b₂) = 0,
      rw (is_ring_hom.map_sub h),
      repeat { rw (is_ring_hom.map_mul h), },
      rw [←Hpq, ←Ha₁b₁, ←Ha₂b₂],
      rw ←mul_comm y,
      rw ←mul_assoc,
      rw mul_assoc _ x y,
      rw Hr,
      ring,
    replace Hz : a₁ * a₂ * q - z * p * b₁ * b₂ ∈ ker h := Hz,
    rw Hker at Hz,
    rcases Hz with ⟨⟨⟨u, v⟩, Huv⟩, Hz⟩,
    simp at Hz,
    simp at Huv,
    rw Hz at Huv,
    have H0I : (0 : R) ∈ I := ideal.zero_mem I,
    rw ←Huv at H0I,
    replace H0I := PI.2 H0I,
    cases H0I,
    { have Ha₁a₂q := (ideal.add_mem_iff_left I Hzpb₁b₂I).1 H0I,
      replace Ha₁a₂q := PI.2 Ha₁a₂q,
      cases Ha₁a₂q with Ha₁a₂ Hq,
      { replace Ha₁a₂ := PI.2 Ha₁a₂,
        cases Ha₁a₂ with Ha₁ Ha₂,
        { left,
          replace Ha₁ := @ideal.mem_map_of_mem _ _ _ _ h _ _ _ Ha₁,
          rcases (Hinv b₁) with ⟨w₁, Hw₁⟩,
          have Hx : x = h a₁ * w₁,
            rw ←(one_mul x),
            rw ←Hw₁,
            rw ←mul_comm w₁,
            rw mul_assoc,
            rw Ha₁b₁,
            ring,
          rw Hx,
          exact ideal.mul_mem_right _ Ha₁, },
        { right,
          replace Ha₂ := @ideal.mem_map_of_mem _ _ _ _ h _ _ _ Ha₂,
          rcases (Hinv b₂) with ⟨w₂, Hw₂⟩,
          have Hy : y = h a₂ * w₂,
            rw ←(one_mul y),
            rw ←Hw₂,
            rw ←mul_comm w₂,
            rw mul_assoc,
            rw Ha₂b₂,
            ring,
          rw Hy,
          exact ideal.mul_mem_right _ Ha₂, } },
      { exfalso,
        exact Hfn q q.2 Hq, }, },
    { exfalso,
      exact Hfn v v.2 H0I, }, }
end

lemma phi_of_map (I : ideal R) [PI : ideal.is_prime I] 
(Hfn : ∀ fn, (fn ∈ powers f) → fn ∉ I)
: φ ⟨ideal.map h I, @localisation_map_ideal.is_prime I PI Hfn⟩ = ⟨I, PI⟩ :=
begin
  have HL' := HL,
  rcases HL' with ⟨Hinv, Hden, Hker⟩,
  simp [φ, Zariski.induced],
  -- Goal : h⁻¹ (h(I)Rf) = I.
  apply le_antisymm,
  { intros z Hz,
    replace Hz : z ∈ ideal.comap h (ideal.map h I) := Hz,
    rw ideal.mem_comap at Hz,
    -- TODO : Factor this out! Exactly the same as before.
    rw (@localisation_map_ideal.eq I PI) at Hz,
    rcases Hz with ⟨w, ⟨a, ⟨HaI, Hwa⟩⟩, ⟨t, Ht⟩⟩,
    rw ←Hwa at Ht,
    rcases (Hden t) with ⟨⟨q, p⟩,  Hpq⟩,
    simp at Hpq,
    have H0 : h (z * q - a * p) = 0,
      rw (is_ring_hom.map_sub h),
      repeat { rw (is_ring_hom.map_mul h), },
      rw ←Hpq, 
      rw mul_comm _ t,
      rw ←mul_assoc,
      rw ←Ht,
      ring,
    replace H0 : z * q - a * p ∈ ker h := H0,
    rw Hker at H0,
    rcases H0 with ⟨⟨⟨u, v⟩, Huv⟩, H0⟩,
    simp at H0,
    simp at Huv,
    rw H0 at Huv,
    have H0I : (0 : R) ∈ I := ideal.zero_mem I,
    rw ←Huv at H0I,
    replace H0I := PI.2 H0I,
    cases H0I,
    { have HnzpI : -(a * p) ∈ I 
        := (ideal.neg_mem_iff I).2 (ideal.mul_mem_right I HaI),
      replace H0I := (ideal.add_mem_iff_right I HnzpI).1 H0I,
      replace H0I := PI.2 H0I,
      cases H0I,
      { exact H0I, },
      { exfalso,
        exact Hfn q q.2 H0I, }, },
    { exfalso,
      exact Hfn v v.2 H0I, }, },
  { rw ←ideal.map_le_iff_le_comap,
    exact (le_refl _), }, 
end

lemma phi_opens : ∀ U : set (Spec Rf), is_open U ↔ is_open (φ '' U) :=
begin
  intros U,
  have HL' := HL,
  rcases HL' with ⟨Hinv, Hden, Hker⟩,
  split,
  { intros OU,
    cases OU with E HE,
    have HU : U = Spec.D E,
      simp [Spec.D],
      rw HE, 
      rw set.compl_compl,
    rw HU,
    let S := { x | ∃ (r) (s ∈ powers f) (y ∈ E), x = f * r ∧ h s * y = h r },
    existsi S,
    apply set.ext,
    rintros ⟨I, PI⟩,
    split,
    swap,
    { intros HI x Hx,
      simp,
      apply classical.by_contradiction,
      intros HC,
      rcases Hx with ⟨r, s, Hspow, y, HyE, ⟨Hx, Hy⟩⟩,
      have Hfs : f * s ∈ powers f,
        rcases Hspow with ⟨n, Hn⟩,
        use [nat.succ n],
        rw pow_succ,
        rw Hn,
      have HnfI : f ∉ I,
        intros HCfI,
        replace HCfI : f * r ∈ I := ideal.mul_mem_right I HCfI,
        rw ←Hx at HCfI,
        exact HC HCfI,
      have HnfnI : ∀ fn, fn ∈ powers f → fn ∉ I,
        intros fn Hfn HfnI,
        rcases Hfn with ⟨n, Hfn⟩,
        rw ←Hfn at HfnI,
        exact HnfI (ideal.is_prime.mem_of_pow_mem PI n HfnI),
      simp at HI,
      let hI : Spec Rf := ⟨ideal.map h I, @localisation_map_ideal.is_prime I PI HnfnI⟩,
      replace HI := HI hI,
      have HnrI : r ∉ I,
        intros Hr,
        replace Hr : f * r ∈ I := ideal.mul_mem_left I Hr,
        rw ←Hx at Hr,
        exact (HC Hr),
      have HnhIVE : hI ∉ Spec.V E,
        intros HhI,
        simp [Spec.V] at HhI,
        have HyhI : h s * y ∈ ideal.map h I := ideal.mul_mem_left _ (HhI HyE),
        rw Hy at HyhI,
        rw (@localisation_map_ideal.eq I PI) at HyhI,
        rcases HyhI with ⟨w, ⟨z, ⟨HzI, Hwz⟩⟩, ⟨t, Ht⟩⟩,
        rcases (Hden t) with ⟨⟨q, p⟩, Hpq⟩,
        simp at Hpq,
        rw ←Hwz at Ht,
        have Hz : h (r * q - z * p) = 0,
          rw (is_ring_hom.map_sub h),
          repeat { rw (is_ring_hom.map_mul h), },
          rw ←Hpq, 
          rw mul_comm _ t,
          rw ←mul_assoc,
          rw ←Ht,
          ring,
        replace Hz : r * q - z * p ∈ ker h := Hz,
        rw Hker at Hz,
        rcases Hz with ⟨⟨⟨u, v⟩, Huv⟩, Hz⟩,
        simp at Hz,
        simp at Huv,
        rw Hz at Huv,
        have H0I : (0 : R) ∈ I := ideal.zero_mem I,
        rw ←Huv at H0I,
        replace H0I := PI.2 H0I,
        cases H0I,
        { have HnzpI : -(z * p) ∈ I 
            := (ideal.neg_mem_iff I).2 (ideal.mul_mem_right I HzI), 
          replace H0I := (ideal.add_mem_iff_right I HnzpI).1 H0I,
          replace H0I := PI.2 H0I,
          cases H0I,
          { exact (HnrI H0I), },
          { exact HnfnI q q.2 H0I, }, },
        { exact HnfnI v v.2 H0I, },
      replace HI := HI HnhIVE,
      apply HI,
      exact @phi_of_map I PI HnfnI, },
    { intros HSJinv HC,
      rcases HC with ⟨⟨J, PJ⟩, HP, HφP⟩,
      rw ←HφP at HSJinv,
      simp [φ, Zariski.induced, Spec.V, ideal.comap] at HSJinv,
      replace HSJinv : S ⊆ h ⁻¹' J.1 := HSJinv,
      apply HP,
      intros x Hx,
      rcases (Hden x) with ⟨⟨fn, r⟩, Hhr⟩,
      simp at Hhr,
      rcases (Hinv fn) with ⟨s, Hfn⟩,
      have HfrS : f * r ∈ S := ⟨r, fn.1, fn.2, x, Hx, ⟨rfl, Hhr⟩⟩,
      replace HfrS := HSJinv HfrS,
      have HhfrJ : h (f * r) ∈ J := HfrS,
      rw is_ring_hom.map_mul h at HhfrJ,
      replace HhfrJ := PJ.2 HhfrJ, 
      have Hfpow : f ∈ powers f := ⟨1, by simp⟩,
      have : h f ∉ J := h_powers_f_not_mem J PJ f Hfpow,
      have : h fn ∉ J := h_powers_f_not_mem J PJ fn fn.2,
      cases HhfrJ,
      { contradiction, },
      { rw ←Hhr at HhfrJ,
        replace HhfrJ := PJ.2 HhfrJ,
        cases HhfrJ,
        { contradiction, },
        { exact HhfrJ, } } }, },
  { intros H,
    have Hcts : continuous φ := Zariski.induced.continuous h,
    have Hinv := Hcts _ H, 
    rw ←(set.preimage_image_eq U phi_injective),
    exact Hinv, }
end

lemma phi_image_Df : φ '' Spec.univ Rf = Spec.D'(f) :=
begin
  apply set.ext,
  rintros ⟨I, PI⟩,
  split,
  { intros HI,
    rcases HI with ⟨⟨J, PJ⟩, ⟨HJ, HIJ⟩⟩,
    show f ∉ I,
    have HnhfnJ := h_powers_f_not_mem J PJ f ⟨1, by simp⟩,
    simp [φ, Zariski.induced] at HIJ,
    intros HC,
    rw ←HIJ at HC,
    rw ideal.mem_comap at HC,
    exact (HnhfnJ HC), },
  { intros HI,
    replace HI : f ∉ I := HI,
    have Hfn : ∀ fn, fn ∈ powers f → fn ∉ I,
      intros fn Hfn HC,
      rcases Hfn with ⟨n, Hfn⟩,
      rw ←Hfn at HC,
      exact HI (ideal.is_prime.mem_of_pow_mem PI n HC),
    let hI : Spec Rf := ⟨ideal.map h I, @localisation_map_ideal.is_prime I PI Hfn⟩,
    use hI,
    split,
    { trivial, },
    { exact @phi_of_map I PI Hfn, }, }
end

end homeomorphism
