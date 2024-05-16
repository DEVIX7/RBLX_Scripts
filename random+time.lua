--test script
print(math.random(1,10))
print(os.date("%A, %d %B %Y %H:%M:%S"))
--function's
a1 = function(a2)
    if a2 == nil then
        a2 = os.clock()
    end
    if a2 then
        print(a2)
    end
return a2 - 15
end
print(a1())
b1, b2 = 80, 20
print(not (b1 <= b2))
--task
print'Ваш возраст:'
local Input = io.read()
local Age = tonumber(Input)
local ActivAccess = nil
if Age >= 70 then
    ActivAccess = false
    print("Ваш возраст превышает допустимый для участия в этой активности.")
elseif Age <= 16 then
    ActivAccess = false
    print("Ваш возраст недостаточен для участия в этой активности")
elseif Age >= 25 and Age < 70 then
    ActivAccess = true
    print("Ваш возраст подходит для участия в этой активности.")
end
local info = Age .. " " .. tostring(ActivAccess)
print(info)
--random
local a22 = 15
print(a22+b1-b2)
