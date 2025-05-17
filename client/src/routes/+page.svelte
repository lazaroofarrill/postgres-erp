<h1 class="text-4xl font-medium m-4 text-center">My employees</h1>

<div class="flex flex-row justify-center"> 

<table>
	<thead class="bg-black text-white">
		<tr>
			<td class="p-2 text-center">Email</td>
			<td class="p-2 text-center">First Name</td>
			<td class="p-2 text-center">Last Name</td>
			<td class="p-2 text-center">Skills</td>
		</tr>
	</thead>
	<tbody>
			{#each data.employees as employee}
		<tr class="border">
			<td class="p-2">{employee.email}</td>
			<td class="px-2">{employee.first_name}</td>
			<td class="px-2">{employee.last_name}</td>
			<td class="px-2">
				<div class="flex flex-row gap-2">
					{#each employee.skills as skill}
					<FormattedSkill skill={skill}></FormattedSkill>
					{/each}
				</div>
			</td>
		</tr>
		{/each}
	</tbody>
</table>



</div>

<div class="flex flex-row justify-center"> 
<table>
<thead>
	<tr class="bg-black text-white">
		<td>Name</td>
	</tr>
</thead>
<tbody>
	{#each data.projects as project}
		<tr>
		<td>{project.name}</td>
		</tr>
	{/each}
</tbody>
</table>
</div>

<script>
	let { data } = $props();
	import FormattedSkill from '$lib/components/formatted-skill.svelte';
</script>
