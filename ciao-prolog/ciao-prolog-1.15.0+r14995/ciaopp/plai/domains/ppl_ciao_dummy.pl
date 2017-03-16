
% empty interface so computers without PPL installed do not complain!

:- module(ppl_ciao_dummy,
[
        ppl_version_major/1,
        ppl_version_minor/1,
        ppl_version_revision/1,
        ppl_version_beta/1,
        ppl_version/1,
        ppl_banner/1,
        ppl_max_space_dimension/1,
        ppl_initialize/0,
        ppl_finalize/0,
        ppl_set_timeout_exception_atom/1,
        ppl_timeout_exception_atom/1,
        ppl_set_timeout/1,
        ppl_reset_timeout/0,
        ppl_new_Polyhedron_from_space_dimension/4,
        ppl_new_Polyhedron_from_Polyhedron/4,
        ppl_new_Polyhedron_from_constraints/3,
        ppl_new_Polyhedron_from_generators/3,
        ppl_new_Polyhedron_from_bounding_box/3,
        ppl_Polyhedron_swap/2,
        ppl_delete_Polyhedron/1,
        ppl_Polyhedron_space_dimension/2,
        ppl_Polyhedron_affine_dimension/2,
        ppl_Polyhedron_get_constraints/2,
        ppl_Polyhedron_get_minimized_constraints/2,
        ppl_Polyhedron_get_generators/2,
        ppl_Polyhedron_get_minimized_generators/2,
        ppl_Polyhedron_relation_with_constraint/3,
        ppl_Polyhedron_relation_with_generator/3,
        ppl_Polyhedron_get_bounding_box/3,
        ppl_Polyhedron_is_empty/1,
        ppl_Polyhedron_is_universe/1,
        ppl_Polyhedron_is_bounded/1,
        ppl_Polyhedron_bounds_from_above/2,
        ppl_Polyhedron_bounds_from_below/2,
        ppl_Polyhedron_maximize/5,
        ppl_Polyhedron_maximize_with_point/6,
        ppl_Polyhedron_minimize/5,
        ppl_Polyhedron_minimize_with_point/6,
        ppl_Polyhedron_is_topologically_closed/1,
        ppl_Polyhedron_contains_Polyhedron/2,
        ppl_Polyhedron_strictly_contains_Polyhedron/2,
        ppl_Polyhedron_is_disjoint_from_Polyhedron/2,
        ppl_Polyhedron_equals_Polyhedron/2,
        ppl_Polyhedron_OK/1,
        ppl_Polyhedron_add_constraint/2,
        ppl_Polyhedron_add_constraint_and_minimize/2,
        ppl_Polyhedron_add_generator/2,
        ppl_Polyhedron_add_generator_and_minimize/2,
        ppl_Polyhedron_add_constraints/2,
        ppl_Polyhedron_add_constraints_and_minimize/2,
        ppl_Polyhedron_add_generators/2,
        ppl_Polyhedron_add_generators_and_minimize/2,
        ppl_Polyhedron_intersection_assign/2,
        ppl_Polyhedron_intersection_assign_and_minimize/2,
        ppl_Polyhedron_poly_hull_assign/2,
        ppl_Polyhedron_poly_hull_assign_and_minimize/2,
        ppl_Polyhedron_poly_difference_assign/2,
        ppl_Polyhedron_affine_image/4,
        ppl_Polyhedron_affine_preimage/4,
        ppl_Polyhedron_generalized_affine_image/5,
        ppl_Polyhedron_generalized_affine_image_lhs_rhs/4,
        ppl_Polyhedron_time_elapse_assign/2,
        ppl_Polyhedron_topological_closure_assign/1,
        ppl_Polyhedron_BHRZ03_widening_assign_with_token/3,
        ppl_Polyhedron_BHRZ03_widening_assign/2,
        ppl_Polyhedron_limited_BHRZ03_extrapolation_assign_with_token/4,
        ppl_Polyhedron_limited_BHRZ03_extrapolation_assign/3,
        ppl_Polyhedron_bounded_BHRZ03_extrapolation_assign_with_token/4,
        ppl_Polyhedron_bounded_BHRZ03_extrapolation_assign/3,
        ppl_Polyhedron_H79_widening_assign_with_token/3,
        ppl_Polyhedron_H79_widening_assign/2,
        ppl_Polyhedron_limited_H79_extrapolation_assign_with_token/4,
        ppl_Polyhedron_limited_H79_extrapolation_assign/3,
        ppl_Polyhedron_bounded_H79_extrapolation_assign_with_token/4,
        ppl_Polyhedron_bounded_H79_extrapolation_assign/3,
        ppl_Polyhedron_add_space_dimensions_and_project/2,
        ppl_Polyhedron_add_space_dimensions_and_embed/2,
        ppl_Polyhedron_concatenate_assign/2,
        ppl_Polyhedron_remove_space_dimensions/2,
        ppl_Polyhedron_remove_higher_space_dimensions/2,
        ppl_Polyhedron_expand_space_dimension/3,
        ppl_Polyhedron_fold_space_dimensions/3,
        ppl_Polyhedron_map_space_dimensions/2
],
[
        assertions,
        basicmodes,
        regtypes,
        foreign_interface
]).


ppl_version_major(_).
ppl_version_minor(_).
ppl_version_revision(_).
ppl_version_beta(_).
ppl_version(_).
ppl_banner(_).
ppl_max_space_dimension(_).
ppl_initialize.
ppl_finalize.
ppl_set_timeout_exception_atom(_).
ppl_timeout_exception_atom(_).
ppl_set_timeout(_).
ppl_reset_timeout.
ppl_new_Polyhedron_from_space_dimension(_,_,_,_).
ppl_new_Polyhedron_from_Polyhedron(_,_,_,_).
ppl_new_Polyhedron_from_constraints(_,_,_).
ppl_new_Polyhedron_from_generators(_,_,_).
ppl_new_Polyhedron_from_bounding_box(_,_,_).
ppl_Polyhedron_swap(_,_).
ppl_delete_Polyhedron(_).
ppl_Polyhedron_space_dimension(_,_).
ppl_Polyhedron_affine_dimension(_,_).
ppl_Polyhedron_get_constraints(_,_).
ppl_Polyhedron_get_minimized_constraints(_,_).
ppl_Polyhedron_get_generators(_,_).
ppl_Polyhedron_get_minimized_generators(_,_).
ppl_Polyhedron_relation_with_constraint(_,_,_).
ppl_Polyhedron_relation_with_generator(_,_,_).
ppl_Polyhedron_get_bounding_box(_,_,_).
ppl_Polyhedron_is_empty(_).
ppl_Polyhedron_is_universe(_).
ppl_Polyhedron_is_bounded(_).
ppl_Polyhedron_bounds_from_above(_,_).
ppl_Polyhedron_bounds_from_below(_,_).
ppl_Polyhedron_maximize(_,_,_,_,_).
ppl_Polyhedron_maximize_with_point(_,_,_,_,_,_).
ppl_Polyhedron_minimize(_,_,_,_,_).
ppl_Polyhedron_minimize_with_point(_,_,_,_,_,_).
ppl_Polyhedron_is_topologically_closed(_).
ppl_Polyhedron_contains_Polyhedron(_,_).
ppl_Polyhedron_strictly_contains_Polyhedron(_,_).
ppl_Polyhedron_is_disjoint_from_Polyhedron(_,_).
ppl_Polyhedron_equals_Polyhedron(_,_).
ppl_Polyhedron_OK(_).
ppl_Polyhedron_add_constraint(_,_).
ppl_Polyhedron_add_constraint_and_minimize(_,_).
ppl_Polyhedron_add_generator(_,_).
ppl_Polyhedron_add_generator_and_minimize(_,_).
ppl_Polyhedron_add_constraints(_,_).
ppl_Polyhedron_add_constraints_and_minimize(_,_).
ppl_Polyhedron_add_generators(_,_).
ppl_Polyhedron_add_generators_and_minimize(_,_).
ppl_Polyhedron_intersection_assign(_,_).
ppl_Polyhedron_intersection_assign_and_minimize(_,_).
ppl_Polyhedron_poly_hull_assign(_,_).
ppl_Polyhedron_poly_hull_assign_and_minimize(_,_).
ppl_Polyhedron_poly_difference_assign(_,_).
ppl_Polyhedron_affine_image(_,_,_,_).
ppl_Polyhedron_affine_preimage(_,_,_,_).
ppl_Polyhedron_generalized_affine_image(_,_,_,_,_).
ppl_Polyhedron_generalized_affine_image_lhs_rhs(_,_,_,_).
ppl_Polyhedron_time_elapse_assign(_,_).
ppl_Polyhedron_topological_closure_assign(_).
ppl_Polyhedron_BHRZ03_widening_assign_with_token(_,_,_).
ppl_Polyhedron_BHRZ03_widening_assign(_,_).
ppl_Polyhedron_limited_BHRZ03_extrapolation_assign_with_token(_,_,_,_).
ppl_Polyhedron_limited_BHRZ03_extrapolation_assign(_,_,_).
ppl_Polyhedron_bounded_BHRZ03_extrapolation_assign_with_token(_,_,_,_).
ppl_Polyhedron_bounded_BHRZ03_extrapolation_assign(_,_,_).
ppl_Polyhedron_H79_widening_assign_with_token(_,_,_).
ppl_Polyhedron_H79_widening_assign(_,_).
ppl_Polyhedron_limited_H79_extrapolation_assign_with_token(_,_,_,_).
ppl_Polyhedron_limited_H79_extrapolation_assign(_,_,_).
ppl_Polyhedron_bounded_H79_extrapolation_assign_with_token(_,_,_,_).
ppl_Polyhedron_bounded_H79_extrapolation_assign(_,_,_).
ppl_Polyhedron_add_space_dimensions_and_project(_,_).
ppl_Polyhedron_add_space_dimensions_and_embed(_,_).
ppl_Polyhedron_concatenate_assign(_,_).
ppl_Polyhedron_remove_space_dimensions(_,_).
ppl_Polyhedron_remove_higher_space_dimensions(_,_).
ppl_Polyhedron_expand_space_dimension(_,_,_).
ppl_Polyhedron_fold_space_dimensions(_,_,_).
ppl_Polyhedron_map_space_dimensions(_,_).
