local RepStor				= game:GetService("ReplicatedStorage")
local RunService			= game:GetService("RunService")


local ReplicatedModules		= RepStor:WaitForChild("Modules")
local ReplicatedUtilities	= ReplicatedModules:WaitForChild("Utilities")
local SignalModule			= ReplicatedUtilities:WaitForChild("Signal")

local GM					= require(RepStor.GlobalMethods)
local Signal				= require(SignalModule)
local ClassOrganizer		= require(script.ClassOrganizer) --Sorts all 

local AllClasses			= ClassOrganizer.AllClasses
local AllClassProperties	= ClassOrganizer.AllClassProperties

local IsClient				= RunService:IsClient()


local ObjectCache			= {} --Holds all created objects. May be unnecessary and/or lead to unwanted memory useage
local Factory				= {}



function Factory:ClassHas(ClassName,DependencySeek)
	local ModuleData = AllClasses[ClassName]
	if not ModuleData.Dependencies then return false end
	for i,ClassDependency in pairs(ModuleData.Dependencies) do
		if ClassDependency == DependencySeek then
			return true
		end
	end
end

function Factory:GetClassesWithDependency(DependencySeek)
	local Classes = {}
	for ClassName,ModuleData in pairs(AllClasses) do
		if ModuleData.Dependencies then
			for i,ClassDependency in pairs(ModuleData.Dependencies) do
				if ClassDependency == DependencySeek then
					Classes[ClassName] = true
				end
			end
		end
	end
	return Classes
end

function Factory:Create(ClassName,...)
	local BuildingClass = AllClasses[ClassName]
	if not BuildingClass then return end
	
	local ProxyObject = {} --returned interface object
	local ObjectProps = {} --Background object properties, inaccessible directly outside of internal methods
	local RWProps = AllClassProperties[ClassName].ReadWrite
	local ROProps = AllClassProperties[ClassName].ReadOnly
	
	local function isWriteable(Key)
		return RWProps[Key] ~= nil
	end
	
	local function importProperties(PropertyTable,IsEvents) --places key/value pairs from PropertyTable into ObjectProps.
		if not PropertyTable then return end
		if IsEvents then
			
			for EventName,EventMethod in pairs(PropertyTable) do
				ObjectProps[EventName] = Signal.new(function(...) --what is returned here becomes the parameters within any .Changed handle
					return EventMethod(ObjectProps,...) --pass in ObjectProps, along with any arguments passed into Signal:Fire(...)
				end)
			end
			
		else
			--same loop, different names
			for PropertyName,PropertyValue in pairs(PropertyTable) do
				if type(PropertyValue) == "table" and PropertyValue[1] == nil then
					PropertyValue = nil --for when the default value is nil, we still want to have it tagged as read/writeable.
				end
				
				ObjectProps[PropertyName] = PropertyValue --place value into ObjectProps table
			end
			
		end
	end
	
	local function loadClassModule(ClassName) --recursively load dependency classes
		local Module = AllClasses[ClassName]
		
		if Module.Dependencies and #Module.Dependencies >= 1 then
			for i,DependencyName in pairs(Module.Dependencies) do --possible stack overflow if circular dependency
				local DependencyModule = AllClasses[DependencyName]
				local Initializer = DependencyModule.Initialize
				if Initializer then
					ObjectProps["Initialize"..DependencyName] = Initializer --Dependency classes get their own InitializeClassName method.
				end															--This allows parent classes to do things like self:InitializeChildClass("Red")
				loadClassModule(DependencyName)
			end
		end
		
		importProperties(Module.ReadOnly)
		importProperties(Module.ReadWrite)
		importProperties(Module.Events,true)
	end
	
	loadClassModule("Generic")
	loadClassModule(ClassName)
	
	AllClasses.Generic.Initialize(ObjectProps,ClassName) --ugly way to make all objects have Generic properties
	
	if BuildingClass.Initialize then
		BuildingClass.Initialize(ObjectProps,...)
	end
	
	
	--Make ProxyObject interface act how we desire an object to.
	setmetatable(ProxyObject,{
		__index = function(self,Key)
			if ROProps[Key] or RWProps[Key] then						--If key exists in object
				if type(ObjectProps[Key]) == "function" then				--If key is a function
					return function(...)										--Return the object's function wrapped in a new function that.....
						local Args = {...}
						table.remove(Args,1)									--remove the 'self' arg
						ObjectProps[Key](ObjectProps,unpack(Args))				--...... passes in the ObjectProperties and the arguments. 
					end
				else
					return ObjectProps[Key]									--If key isn't a function, return the property.
				end
			elseif ROProps._subject and ObjectProps._subject then		--If key doesn't exist in the object, and the object has a subject (RBX Object), 
				return ObjectProps._subject[Key]							--return the subject's property of [key]
			else
				warn(tostring(Key).. " is not a valid member of ".. ClassName)
			end
		end,
		__newindex = function(self,Key,Value)						--Upon assignment
			if isWriteable(Key) then									--If key is writeable 
				ObjectProps[Key] = Value									--Set new value
				if ObjectProps.Changed then									--If object has a Changed function
					ObjectProps.Changed:Fire(Key,Value)							--Fire Changed
				end
			elseif ROProps._subject then								--If key is not writeable, but object has a subject, 
				ObjectProps._subject[Key] = Value							--set subject's property
			else
				warn("Cannot write to read-only value ".. Key)
			end
		end
	})
	
	ObjectCache[ProxyObject] = ClassName							--Cache object into Object holder
	return ProxyObject												--Return interface
end


return Factory
