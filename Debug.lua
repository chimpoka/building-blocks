local Debug = {}

function Debug.getInfo(level)
	local info = debug.getinfo(level)
	print("error at '"..info.source.."', line "..info.currentline..", function '"..info.name.."'")
end

function Debug.pause()
	os.execute("pause")
end

return Debug