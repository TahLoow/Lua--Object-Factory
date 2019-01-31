local GM = require(game.ReplicatedStorage.GlobalMethods)

local AllContentsData = require(GM.RepStor.Modules.Utilities.GetContentsData)

local ClassData = {
	ReadWrite = {},
	ReadOnly = {
		Contents = "",
		Capacity = 0,
		Quantity = 0,
		
		SetQuantity = function(self,NewValue)
			if type(NewValue) ~= "number" then return end
			self.Quantity = math.clamp(NewValue,0,self.Capacity)
		end,
		UpdateQuantity = function(self,Delta)
			self.SetQuantity(self,self.Quantity + Delta)
		end,
	},
	Events = {
		QuantityChanged = function(self)
			return self.Quantity
		end,
	},
	
	Initialize = function(self,Contents)
		local ContentsData = AllContentsData[Contents]
		if not ContentsData then return end
		self.Quantity = ContentsData.DefaultQuantity
		self.Capacity = ContentsData.DefaultCapacity
		self.Contents = Contents
		
		print(ContentsData)
		print("Container initialized")
		
		return ContentsData
	end,
	
	Dependencies = {}
}

return ClassData
