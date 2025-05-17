<script>
	function colorSkill(skill) {
		if (typeof skill?.level !== 'number' || skill?.level < 0 || skill?.level > 4) {
			throw new Error('Invalid skill level');
		}
		if (typeof skill?.skill !== 'string' || (skill?.skill?.length ?? '') === 0) {
			throw new Error('Invalid skill name');
		}

		const colors = [
			'text-red-800',
			'text-pink-600',
			'text-yellow-600',
			'text-orange-600',
			'text-green-800'
		];

		return colors[skill.level];
	}
	export let skill;
</script>

<span class="{colorSkill(skill)} font-bold">{skill.skill}</span>
