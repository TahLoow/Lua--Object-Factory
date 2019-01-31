--Returns a table that mirrors and handles all interpreted FactoryObjects.
local RepStor					= game:GetService("ReplicatedStorage")
local RunService				= game:GetService("RunService")

local GM						= require(RepStor.GlobalMethods)

local DataPool					= RepStor:WaitForChild("DataPool")
local FactoryTemplatesFolder	= DataPool:WaitForChild("FactoryTemplates")

local IsClient					= RunService:IsClient()
local ScriptEnvironment			= IsClient and "Client" or "Server"


local AllClasses = {
--	[ModuleName] = Module
}
local AllClassProperties = {
--	[ClassName] = {
--		Readable = {},
--		Writable = {}
--	}
}

local ClassOrganizer				= {
	AllClasses				= AllClasses,
	AllClassProperties		= AllClassProperties
}

local function initializeClass(ClassName,ClassData)
	local RWProps = {}
	local ROProps = {}
	
	AllClassProperties[ClassName] = {
		ReadOnly = ROProps,
		ReadWrite = RWProps
	}
	
	local function identify(Src,Dest)
		if not Src then return end
		for PropertyName,IgnoredValue in pairs(Src) do
			Dest[PropertyName] = true --identify key in ROProps or RWProps table
		end
	end
	
	local function loadClassModule(Module)
		if Module.Dependencies then
			for i,Dependency in pairs(Module.Dependencies) do --possible stack overflow
				if ClassName == "Crate" then
				end
				loadClassModule(ClassOrganizer.AllClasses[Dependency])
			end
		end
		
		identify(Module.ReadOnly,ROProps)
		identify(Module.ReadWrite,RWProps)
		identify(Module.Events,ROProps)
	end
	
	loadClassModule(ClassData)
end


do
	for i,ClassFolder in pairs(FactoryTemplatesFolder:GetChildren()) do
		if ClassFolder:IsA("Folder") then
			local ClassName = ClassFolder.Name
			local ModuleName = ScriptEnvironment.."_"..ClassName
			local Module = ClassFolder:FindFirstChild(ModuleName)
			if Module then
				AllClasses[ClassName] = require(Module)
			end
		end
	end
	
	for ClassName,ClassData in pairs(ClassOrganizer.AllClasses) do
		initializeClass(ClassName,ClassData)
	end
	
	--GM:PrintDictionary(AllClasses)
end

return ClassOrganizer



