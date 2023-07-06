local function getAverage(samples: { number }): number
	local sum = 0

	for i, value in samples do
		sum += value
	end

	return sum / #samples
end

return getAverage
