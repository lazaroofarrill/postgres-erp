import { supabase } from '$lib/supabaseClient';

export async function load() {
	const { data: employees } = await supabase.from('employees_with_normalized_skills').select();

	const { data: projects } = await supabase.from('projects').select();

	return {
		employees: employees ?? [],
		projects: projects
	};
}
