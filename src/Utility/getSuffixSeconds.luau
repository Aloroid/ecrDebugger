return function(time: number)
	local ms = time * 1000
	local us = ms * 1000

	if us > 1000 then
		return `{math.round(ms)} ms`
	else
		return `{math.round(us)} μs`
	end
end
