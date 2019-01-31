local GM = require(game.ReplicatedStorage.GlobalMethods)

local ClassData = {
	ReadWrite = {},
	ReadOnly = {
		ClassName = "Container",
		Contents = "",
		Capacity = 0,
		Quantity = 0,
		
		SetCapacity = function(self,NewValue)
			if type(NewValue) ~= "number" then return end
			self.Capacity = NewValue
		end,
		SetQuantity = function(self,NewValue)
			if type(NewValue) ~= "number" then return end
			self.Quantity = math.clamp(NewValue,0,self.Capacity)
		end,
		UpdateQuantity = function(self,Delta)
			self:SetQuantity(self.Quantity + Delta)
		end,
	},
	Events = {},
	
	Initialize = function(self,Contents,Capacity,Quantity)
		self.Contents = GM:TernaryTypeAssert(Contents,"string",Contents,"Unknown") --if Contents IsA string, assign Contents, else assign "Unknown"
		self.Capacity = GM:TernaryTypeAssert(Capacity,"number",Capacity,0)
		self.Quantity = GM:TernaryTypeAssert(Quantity,"number",Quantity,0)
		
		return
	end,
	
	Dependencies = {}
}

return ClassData
