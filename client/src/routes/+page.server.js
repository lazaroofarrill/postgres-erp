import { supabase } from '$lib/supabaseClient';

export async function load() {
	const { data } = await supabase.from('employees').select();
	const { data: projects } = await supabase.from('projects').select();

	return {
		employees: data ?? [],
		projects: projects
	};
}
