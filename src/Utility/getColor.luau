local Colors = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(255, 127, 0),
	Color3.fromRGB(255, 255, 0),
	Color3.fromRGB(0, 255, 0),
	Color3.fromRGB(0, 0, 255),
	Color3.fromRGB(148, 0, 211),
}

for i, color in Colors do
	local h, s, v = color:ToHSV()
	Colors[i] = Color3.fromHSV(h, s - 0.3, v)
end

return function(order: number)
	order -= 1
	local index = order % #Colors

	return Colors[index + 1]
end
