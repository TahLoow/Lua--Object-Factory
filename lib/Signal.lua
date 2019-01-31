--- Lua-side duplication of the API of events on Roblox objects.
-- Signals are needed for to ensure that for local events objects are passed by
-- reference rather than by value where possible, as the BindableEvent objects
-- always pass signal arguments by value, meaning tables will be deep copied.
-- Roblox's deep copy method parses to a non-lua table compatable format.
-- @classmod Signal

-- Slight modification by WoolHat. 
-- Now includes a mandatory initialCallback parameter
-- 		initialCallback is a passed-in function that returns values to the handler when `:Connect` is triggered,
-- 		`:Wait` is resumed, or if initialCallback is true upon `:Connect` initialization
-- Now returns a unique constructor table. Events will no longer have the capability
-- 		to create more events, only the SigConstructor can.

local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"


local SigConstructor = {
	new = function(initalCallback)
		assert((initalCallback and type(initalCallback) == "function"))
		
		local self = setmetatable({}, Signal)
	
		self._bindableEvent = Instance.new("BindableEvent")
		self._initialCallback = initalCallback
	
		return self
	end
}


--- Fire the event with the given arguments. All handlers will be invoked. Handlers follow
-- Roblox signal conventions.
-- @treturn nil
function Signal:Fire(...)
	self._bindableEvent:Fire(...)
end

--- Connect a new handler to the event. Returns a connection object that can be disconnected.
-- @tparam function handler Function handler called with arguments passed when `:Fire(...)` is called
-- @treturn Connection Connection object that can be disconnected
function Signal:Connect(handler,initialPerform)
	if not (type(handler) == "function") then
		error(("connect(%s)"):format(typeof(handler)), 2)
	end
	
	if initialPerform then
		handler(self._initialCallback())
	end

	return self._bindableEvent.Event:Connect(function(...)
		return handler(self._initialCallback(...))
	end)
end

--- Wait for fire to be called, and return the arguments it was given.
-- @treturn ... Variable arguments from connection
function Signal:Wait()
	self._bindableEvent.Event:Wait()
	return self._initialCallback()
end

--- Disconnects all connected events to the signal. Voids the signal as unusable.
-- @treturn nil
function Signal:Destroy()
	if self._bindableEvent then
		self._bindableEvent:Destroy()
		self._bindableEvent = nil
	end
	
	self._dataCallback = nil
end

return SigConstructor


