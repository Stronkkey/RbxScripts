-- Please add LucasMZ_RBX FastSignal library to the child of this script https://www.roblox.com/library/6532460357/FastSignal-A-consistent-Signal-library or
-- change the FastSignal path to a copy of the module

local Timer = {}
Timer.__index = Timer
local inf = math.huge
local FastSignal = require(script.Parent:WaitForChild("FastSignal"))
Timer.NewTimerAdded = FastSignal.new()

local function CloseThread(thread: thread)
	if type(thread) == "thread" then
		coroutine.close(thread)
	end
end

function Timer.new(TimeWait)
	if type(TimeWait) ~= "number" then
		return
	end
	
	local self = {}
	self.waittime = os.clock() + TimeWait
	self.TimeWait = TimeWait
	self.TimeOut = 0
	self.TimerContinue = FastSignal.new()
	self.TimerPaused = FastSignal.new()
	self.TimerStopped = FastSignal.new()
	self.Resetted = FastSignal.new()
	self.TimerEnded = FastSignal.new()
	self._thread = task.delay(TimeWait, self.TimerEnded.Fire, self.TimerEnded)
	Timer.NewTimerAdded:Fire(self)
	return setmetatable(self, Timer)
end

function Timer:Pause()
	self.TimerContinue:Fire()
	self.TimeOut = self.waittime - os.clock()
	self.waittime = inf
	self.TimerPaused:Fire()
	CloseThread(self._thread)
	return true
end

function Timer:CleanUpEvents()
	self.TimerContinue:DisconnectAll()
	self.TimerPaused:DisconnectAll()
	self.TimerStopped:DisconnectAll()
	self.Resetted:DisconnectAll()
	self.TimerEnded:DisconnectAll()
	CloseThread(self._thread)
	return true
end

function Timer:Stop()
	self.TimerStopped:Fire()
	self:CleanUpEvents()
	table.clear(self)
	return true
end

function Timer:Continue()
	self.waittime = self.TimeOut + os.clock()
	self.TimerContinue:Fire()
	if not self._thread then
		self._thread = task.delay(self.TimeWait, self.TimerEnded.Fire, self.TimerEnded)
	end
	return true
end

function Timer:AmountTimePassed()
	local TimePassed = (tonumber(string.sub(self.waittime - os.clock(), 1, 7)) - self.TimeWait) * -1
	return TimePassed
end

function Timer:HasTimePassed()
	return if os.clock() >= self.waittime then true else false 
end

function Timer:Reset()
	self.waittime = os.clock() + self.TimeWait
	self.TimeOut = 0
	self.Resetted:Fire()
	CloseThread(self._thread)
	return true
end

function Timer:SetToZero()
	self.waittime = os.clock()
	self.TimerEnded:Fire()
	CloseThread(self._thread)
	return true
end

return Timer
