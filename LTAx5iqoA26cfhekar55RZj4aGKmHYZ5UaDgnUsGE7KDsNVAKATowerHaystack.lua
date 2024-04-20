--[[ 
	Stack V1 
  made by DEVIX7 
]]
local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			repeatNext = StrToNumber(Sub(byte, 1, 1));
			return "";
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local b = Rep(a, repeatNext);
				repeatNext = nil;
				return b;
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				Exponent = 1;
				IsNormal = 0;
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local Str;
		if not Len then
			Len = gBits32();
			if (Len == 0) then
				return "";
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local Type = gBits8();
			local Cons;
			if (Type == 1) then
				Cons = gBits8() ~= 0;
			elseif (Type == 2) then
				Cons = gFloat();
			elseif (Type == 3) then
				Cons = gString();
			end
			Consts[Idx] = Cons;
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local Descriptor = gBits8();
			if (gBit(Descriptor, 1, 1) == 0) then
				local Type = gBit(Descriptor, 2, 3);
				local Mask = gBit(Descriptor, 4, 6);
				local Inst = {gBits16(),gBits16(),nil,nil};
				if (Type == 0) then
					Inst[3] = gBits16();
					Inst[4] = gBits16();
				elseif (Type == 1) then
					Inst[3] = gBits32();
				elseif (Type == 2) then
					Inst[3] = gBits32() - (2 ^ 16);
				elseif (Type == 3) then
					Inst[3] = gBits32() - (2 ^ 16);
					Inst[4] = gBits16();
				end
				if (gBit(Mask, 1, 1) == 1) then
					Inst[2] = Consts[Inst[2]];
				end
				if (gBit(Mask, 2, 2) == 1) then
					Inst[3] = Consts[Inst[3]];
				end
				if (gBit(Mask, 3, 3) == 1) then
					Inst[4] = Consts[Inst[4]];
				end
				Instrs[Idx] = Inst;
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				Inst = Instr[VIP];
				Enum = Inst[1];
				if (Enum <= 63) then
					if (Enum <= 31) then
						if (Enum <= 15) then
							if (Enum <= 7) then
								if (Enum <= 3) then
									if (Enum <= 1) then
										if (Enum == 0) then
											Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
										else
											Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
										end
									elseif (Enum == 2) then
										local A = Inst[2];
										local Step = Stk[A + 2];
										local Index = Stk[A] + Step;
										Stk[A] = Index;
										if (Step > 0) then
											if (Index <= Stk[A + 1]) then
												VIP = Inst[3];
												Stk[A + 3] = Index;
											end
										elseif (Index >= Stk[A + 1]) then
											VIP = Inst[3];
											Stk[A + 3] = Index;
										end
									else
										local NewProto = Proto[Inst[3]];
										local NewUvals;
										local Indexes = {};
										NewUvals = Setmetatable({}, {__index=function(_, Key)
											local Val = Indexes[Key];
											return Val[1][Val[2]];
										end,__newindex=function(_, Key, Value)
											local Val = Indexes[Key];
											Val[1][Val[2]] = Value;
										end});
										for Idx = 1, Inst[4] do
											VIP = VIP + 1;
											local Mvm = Instr[VIP];
											if (Mvm[1] == 19) then
												Indexes[Idx - 1] = {Stk,Mvm[3]};
											else
												Indexes[Idx - 1] = {Upvalues,Mvm[3]};
											end
											Lupvals[#Lupvals + 1] = Indexes;
										end
										Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
									end
								elseif (Enum <= 5) then
									if (Enum > 4) then
										do
											return;
										end
									elseif (Inst[2] ~= Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum == 6) then
									Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
								elseif (Stk[Inst[2]] ~= Inst[4]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum <= 11) then
								if (Enum <= 9) then
									if (Enum > 8) then
										local A = Inst[2];
										local T = Stk[A];
										for Idx = A + 1, Top do
											Insert(T, Stk[Idx]);
										end
									else
										Stk[Inst[2]] = {};
									end
								elseif (Enum > 10) then
									local A = Inst[2];
									local Results, Limit = _R(Stk[A](Stk[A + 1]));
									Top = (Limit + A) - 1;
									local Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
								else
									local A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
								end
							elseif (Enum <= 13) then
								if (Enum == 12) then
									local A = Inst[2];
									local T = Stk[A];
									for Idx = A + 1, Inst[3] do
										Insert(T, Stk[Idx]);
									end
								else
									Stk[Inst[2]] = Upvalues[Inst[3]];
								end
							elseif (Enum > 14) then
								local A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Top));
							else
								local A = Inst[2];
								Stk[A](Stk[A + 1]);
							end
						elseif (Enum <= 23) then
							if (Enum <= 19) then
								if (Enum <= 17) then
									if (Enum == 16) then
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									else
										Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
									end
								elseif (Enum > 18) then
									Stk[Inst[2]] = Stk[Inst[3]];
								else
									Stk[Inst[2]] = Inst[3] ^ Stk[Inst[4]];
								end
							elseif (Enum <= 21) then
								if (Enum > 20) then
									if (Stk[Inst[2]] < Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local A = Inst[2];
									Stk[A] = Stk[A]();
								end
							elseif (Enum == 22) then
								local A = Inst[2];
								local Results = {Stk[A](Unpack(Stk, A + 1, Inst[3]))};
								local Edx = 0;
								for Idx = A, Inst[4] do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							else
								Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
							end
						elseif (Enum <= 27) then
							if (Enum <= 25) then
								if (Enum > 24) then
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
								elseif (Inst[2] ~= Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum == 26) then
								local A = Inst[2];
								local Index = Stk[A];
								local Step = Stk[A + 2];
								if (Step > 0) then
									if (Index > Stk[A + 1]) then
										VIP = Inst[3];
									else
										Stk[A + 3] = Index;
									end
								elseif (Index < Stk[A + 1]) then
									VIP = Inst[3];
								else
									Stk[A + 3] = Index;
								end
							else
								Stk[Inst[2]] = Inst[3] / Inst[4];
							end
						elseif (Enum <= 29) then
							if (Enum > 28) then
								Stk[Inst[2]] = {};
							else
								for Idx = Inst[2], Inst[3] do
									Stk[Idx] = nil;
								end
							end
						elseif (Enum == 30) then
							if not Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
							local A = Inst[2];
							local Cls = {};
							for Idx = 1, #Lupvals do
								local List = Lupvals[Idx];
								for Idz = 0, #List do
									local Upv = List[Idz];
									local NStk = Upv[1];
									local DIP = Upv[2];
									if ((NStk == Stk) and (DIP >= A)) then
										Cls[DIP] = NStk[DIP];
										Upv[1] = Cls;
									end
								end
							end
						end
					elseif (Enum <= 47) then
						if (Enum <= 39) then
							if (Enum <= 35) then
								if (Enum <= 33) then
									if (Enum == 32) then
										local A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
									else
										Stk[Inst[2]] = Stk[Inst[3]] % Stk[Inst[4]];
									end
								elseif (Enum == 34) then
									local A = Inst[2];
									Stk[A](Stk[A + 1]);
								elseif (Inst[2] < Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum <= 37) then
								if (Enum > 36) then
									local A = Inst[2];
									local Results = {Stk[A](Unpack(Stk, A + 1, Top))};
									local Edx = 0;
									for Idx = A, Inst[4] do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
								else
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
								end
							elseif (Enum > 38) then
								Stk[Inst[2]] = Stk[Inst[3]] % Inst[4];
							else
								Stk[Inst[2]] = Env[Inst[3]];
							end
						elseif (Enum <= 43) then
							if (Enum <= 41) then
								if (Enum > 40) then
									Upvalues[Inst[3]] = Stk[Inst[2]];
								else
									do
										return Stk[Inst[2]];
									end
								end
							elseif (Enum > 42) then
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							else
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							end
						elseif (Enum <= 45) then
							if (Enum == 44) then
								Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
							else
								Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
							end
						elseif (Enum > 46) then
							if (Stk[Inst[2]] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
							local A = Inst[2];
							local T = Stk[A];
							local B = Inst[3];
							for Idx = 1, B do
								T[Idx] = Stk[A + Idx];
							end
						end
					elseif (Enum <= 55) then
						if (Enum <= 51) then
							if (Enum <= 49) then
								if (Enum > 48) then
									local A = Inst[2];
									local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Top)));
									Top = (Limit + A) - 1;
									local Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
								else
									local A = Inst[2];
									do
										return Unpack(Stk, A, A + Inst[3]);
									end
								end
							elseif (Enum == 50) then
								Stk[Inst[2]] = Stk[Inst[3]] % Stk[Inst[4]];
							else
								for Idx = Inst[2], Inst[3] do
									Stk[Idx] = nil;
								end
							end
						elseif (Enum <= 53) then
							if (Enum == 52) then
								Stk[Inst[2]] = Inst[3] ~= 0;
							elseif not Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum > 54) then
							Stk[Inst[2]] = Upvalues[Inst[3]];
						else
							Stk[Inst[2]] = Stk[Inst[3]];
						end
					elseif (Enum <= 59) then
						if (Enum <= 57) then
							if (Enum > 56) then
								if (Stk[Inst[2]] <= Inst[4]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Stk[Inst[2]] <= Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum > 58) then
							local A = Inst[2];
							local Results = {Stk[A](Unpack(Stk, A + 1, Top))};
							local Edx = 0;
							for Idx = A, Inst[4] do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
						else
							Stk[Inst[2]] = Inst[3] ^ Stk[Inst[4]];
						end
					elseif (Enum <= 61) then
						if (Enum == 60) then
							if (Stk[Inst[2]] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
							local A = Inst[2];
							do
								return Unpack(Stk, A, Top);
							end
						end
					elseif (Enum == 62) then
						Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
					else
						Upvalues[Inst[3]] = Stk[Inst[2]];
					end
				elseif (Enum <= 95) then
					if (Enum <= 79) then
						if (Enum <= 71) then
							if (Enum <= 67) then
								if (Enum <= 65) then
									if (Enum > 64) then
										Stk[Inst[2]] = Stk[Inst[3]] - Inst[4];
									elseif (Stk[Inst[2]] == Inst[4]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum == 66) then
									if (Inst[2] == Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
								end
							elseif (Enum <= 69) then
								if (Enum > 68) then
									Stk[Inst[2]] = #Stk[Inst[3]];
								else
									Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
								end
							elseif (Enum == 70) then
								local A = Inst[2];
								do
									return Stk[A](Unpack(Stk, A + 1, Top));
								end
							else
								local A = Inst[2];
								local Results, Limit = _R(Stk[A](Stk[A + 1]));
								Top = (Limit + A) - 1;
								local Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							end
						elseif (Enum <= 75) then
							if (Enum <= 73) then
								if (Enum > 72) then
									Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
								else
									Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
								end
							elseif (Enum == 74) then
								Stk[Inst[2]] = Stk[Inst[3]] - Inst[4];
							elseif (Stk[Inst[2]] <= Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 77) then
							if (Enum == 76) then
								Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
							else
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							end
						elseif (Enum == 78) then
							local A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Top));
						elseif (Stk[Inst[2]] <= Inst[4]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum <= 87) then
						if (Enum <= 83) then
							if (Enum <= 81) then
								if (Enum == 80) then
									Stk[Inst[2]] = Inst[3] ~= 0;
								elseif (Stk[Inst[2]] == Inst[4]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum > 82) then
								Stk[Inst[2]] = Env[Inst[3]];
							elseif Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 85) then
							if (Enum == 84) then
								local A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
							else
								local A = Inst[2];
								local Index = Stk[A];
								local Step = Stk[A + 2];
								if (Step > 0) then
									if (Index > Stk[A + 1]) then
										VIP = Inst[3];
									else
										Stk[A + 3] = Index;
									end
								elseif (Index < Stk[A + 1]) then
									VIP = Inst[3];
								else
									Stk[A + 3] = Index;
								end
							end
						elseif (Enum == 86) then
							Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
						else
							local A = Inst[2];
							Stk[A] = Stk[A]();
						end
					elseif (Enum <= 91) then
						if (Enum <= 89) then
							if (Enum == 88) then
								VIP = Inst[3];
							else
								Stk[Inst[2]] = Inst[3];
							end
						elseif (Enum > 90) then
							local A = Inst[2];
							local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							Top = (Limit + A) - 1;
							local Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
						else
							Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
						end
					elseif (Enum <= 93) then
						if (Enum == 92) then
							local A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
						else
							local A = Inst[2];
							local T = Stk[A];
							for Idx = A + 1, Top do
								Insert(T, Stk[Idx]);
							end
						end
					elseif (Enum == 94) then
						Stk[Inst[2]] = Inst[3];
					else
						local A = Inst[2];
						local Step = Stk[A + 2];
						local Index = Stk[A] + Step;
						Stk[A] = Index;
						if (Step > 0) then
							if (Index <= Stk[A + 1]) then
								VIP = Inst[3];
								Stk[A + 3] = Index;
							end
						elseif (Index >= Stk[A + 1]) then
							VIP = Inst[3];
							Stk[A + 3] = Index;
						end
					end
				elseif (Enum <= 111) then
					if (Enum <= 103) then
						if (Enum <= 99) then
							if (Enum <= 97) then
								if (Enum > 96) then
									do
										return Stk[Inst[2]];
									end
								else
									local A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								end
							elseif (Enum == 98) then
								Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
							else
								local A = Inst[2];
								local Results = {Stk[A](Unpack(Stk, A + 1, Inst[3]))};
								local Edx = 0;
								for Idx = A, Inst[4] do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							end
						elseif (Enum <= 101) then
							if (Enum == 100) then
								if (Inst[2] < Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local A = Inst[2];
								Top = (A + Varargsz) - 1;
								for Idx = A, Top do
									local VA = Vararg[Idx - A];
									Stk[Idx] = VA;
								end
							end
						elseif (Enum == 102) then
							local A = Inst[2];
							do
								return Stk[A](Unpack(Stk, A + 1, Inst[3]));
							end
						else
							local A = Inst[2];
							Top = (A + Varargsz) - 1;
							for Idx = A, Top do
								local VA = Vararg[Idx - A];
								Stk[Idx] = VA;
							end
						end
					elseif (Enum <= 107) then
						if (Enum <= 105) then
							if (Enum > 104) then
								Stk[Inst[2]] = #Stk[Inst[3]];
							else
								local A = Inst[2];
								do
									return Stk[A](Unpack(Stk, A + 1, Inst[3]));
								end
							end
						elseif (Enum > 106) then
							local A = Inst[2];
							local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							Top = (Limit + A) - 1;
							local Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
						else
							local A = Inst[2];
							local Cls = {};
							for Idx = 1, #Lupvals do
								local List = Lupvals[Idx];
								for Idz = 0, #List do
									local Upv = List[Idz];
									local NStk = Upv[1];
									local DIP = Upv[2];
									if ((NStk == Stk) and (DIP >= A)) then
										Cls[DIP] = NStk[DIP];
										Upv[1] = Cls;
									end
								end
							end
						end
					elseif (Enum <= 109) then
						if (Enum > 108) then
							VIP = Inst[3];
						else
							local NewProto = Proto[Inst[3]];
							local NewUvals;
							local Indexes = {};
							NewUvals = Setmetatable({}, {__index=function(_, Key)
								local Val = Indexes[Key];
								return Val[1][Val[2]];
							end,__newindex=function(_, Key, Value)
								local Val = Indexes[Key];
								Val[1][Val[2]] = Value;
							end});
							for Idx = 1, Inst[4] do
								VIP = VIP + 1;
								local Mvm = Instr[VIP];
								if (Mvm[1] == 19) then
									Indexes[Idx - 1] = {Stk,Mvm[3]};
								else
									Indexes[Idx - 1] = {Upvalues,Mvm[3]};
								end
								Lupvals[#Lupvals + 1] = Indexes;
							end
							Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
						end
					elseif (Enum > 110) then
						if (Stk[Inst[2]] ~= Inst[4]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					else
						Stk[Inst[2]] = Inst[3] ~= 0;
						VIP = VIP + 1;
					end
				elseif (Enum <= 119) then
					if (Enum <= 115) then
						if (Enum <= 113) then
							if (Enum == 112) then
								Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
							else
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							end
						elseif (Enum > 114) then
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						else
							Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
						end
					elseif (Enum <= 117) then
						if (Enum > 116) then
							Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
						else
							local A = Inst[2];
							local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Top)));
							Top = (Limit + A) - 1;
							local Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
						end
					elseif (Enum > 118) then
						Stk[Inst[2]] = Inst[3] / Inst[4];
					else
						Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
					end
				elseif (Enum <= 123) then
					if (Enum <= 121) then
						if (Enum == 120) then
							if Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						end
					elseif (Enum == 122) then
						local A = Inst[2];
						local T = Stk[A];
						local B = Inst[3];
						for Idx = 1, B do
							T[Idx] = Stk[A + Idx];
						end
					else
						local A = Inst[2];
						do
							return Unpack(Stk, A, Top);
						end
					end
				elseif (Enum <= 125) then
					if (Enum == 124) then
						if (Inst[2] == Stk[Inst[4]]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Stk[Inst[2]] < Stk[Inst[4]]) then
						VIP = VIP + 1;
					else
						VIP = Inst[3];
					end
				elseif (Enum <= 126) then
					Stk[Inst[2]] = Stk[Inst[3]] % Inst[4];
				elseif (Enum > 127) then
					local A = Inst[2];
					do
						return Stk[A](Unpack(Stk, A + 1, Top));
					end
				else
					Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!123O0003083O00746F6E756D62657203063O00737472696E6703043O006279746503043O00636861722O033O0073756203043O00677375622O033O0072657003053O007461626C6503063O00636F6E63617403063O00696E7365727403043O006D61746803053O006C6465787003073O0067657466656E76030C3O007365746D6574617461626C6503053O007063612O6C03063O0073656C65637403063O00756E7061636B03202B2O004C4F4C213344334F3O3032384F3O3032374F2O30342O30333034334F2O30364536353738373430333034334F2O30363736313644363530333041334F2O30343736353734353336353732372O36393633363530332O31334F2O303532363537303643363936333631373436353634353337343646373236313637363530333045334F2O303532363536443646373436353436373536453633373436393646364530333043334F2O3034393645372O36463642362O353336353732372O3635373230333037334F2O3035333635324F373336393646364530333036334F2O3035333635363137323633363830333130334F2O3034393645372O36353645373436463732373932453534372O324F36463730373330333038334F2O303435373137353639324F37303635363430333035334F2O303734363136323643363530333036334F2O3036393645373336353732373430333038334F2O30373436463733373437323639364536373032364F3O3038342O3032364F2O30312O342O30333036334F2O3034323735324F37343646364530333044334F2O302O353730362O37323631363436353230353436462O373635373230333038334F2O302O34373236463730363436462O37364530333046334F2O303543324632303533363537343230353436462O373635372O32303543324630333038334F2O303643364636333631373436393646364530333032334F2O303546343730333034334F2O303O36433631363730333036334F2O303734372O324F36463730373330333034334F2O30364336393733373430333037334F2O30353336353633373436393646364530332O31334F2O303543324632303O343134453437342O352O323035413446344534353230354332463032364F2O303138342O30333038334F2O3035333635324F364332303431324F36433032364F2O303143342O3032364F2O304630334630333043334F2O3034333732363536313734362O353736393645363436462O3730333038334F2O303533373436313633364232303536333130333037334F2O30353036433631373936353732373330333042334F2O303443364636333631364335303643363137393635373230333038334F2O3034373635372O3444364637353733363530333035334F2O303730373236393645373430333143334F2O30324F3041344F30393533363337323639373037343230364436313634363532303632373932303O342O3536343935383337304130333036334F2O3036333646364536333631373430333032334F2O303243322O30333036334F2O3035343646324F36373643363530333038334F2O303533373436313633364236393645363730333042334F2O303733373436313633364235343646324F3637364336353032364F2O303130342O30333041334F2O30364336463631363437333734373236393645363730333037334F2O303438324F3734373034373635373430333441334F2O303638324F37343730372O3341324F3246373236312O373245363736393734363837353632373537333635373236333646364537343635364537343245363336463644324635333639363736443631364536393633324635323446343234433446353832463644363136393645324634443646363436393O363936333631373436393646364535373631324F364337392O35363930333036334F2O3035333643363936343635373230333036334F2O3034313644364637353645373430333037334F2O30373037323635363336393733363530313O30333037334F2O30363436353O3631373536433734324F302O334F2O30364436393645324F302O334F2O303644363137383032364F2O30322O342O30333044334F2O303543324632303O35303437353234313O343532303543324630333042334F2O302O353730362O373236313634363532303431324F364330333045334F2O303638324F36463642364436353734363136443635373436383646363430333041334F2O30324F3546364536313644363536333631324F364330333045334F2O30364436313634363532303632373932303O342O35363439353833372O304136334F2O3031323037334F3O3031344F2O302O323O30313O3042334F2O3032363146334F2O3032423O30313O30323O30343137334F2O3032423O3031324F2O3031333O3043364F2O3034313O30363O3043344F2O3031333O3043364F2O3034313O30373O3043334F2O30313233433O30433O302O334F2O30313233433O30443O3034334F2O30323035343O30443O30443O30352O30313230373O30463O3036344F2O3032443O30443O30463O30322O30323034373O30443O30443O30372O30323035343O30443O30443O30382O30313230373O30463O3039334F2O30313230372O30314O3041334F2O30313230372O302O313O3042344F2O30314O30442O302O313O30453O30343137334F2O3032383O30312O30323034372O302O312O30314O30432O30324F30362O302O312O3032383O3031334F3O30343137334F2O3032383O30312O30313230372O302O313O3031334F2O30323631462O302O312O3031383O30313O30313O30343137334F2O3031383O30312O30313233432O3031323O3044334F2O30323034372O3031322O3031323O3045324F2O3034312O3031333O3036344F2O3034312O3031343O3046344F2O3034362O3031322O3031343O30312O30313233432O3031323O3044334F2O30323034372O3031322O3031323O3045324F2O3034312O3031333O3037334F2O30313233432O3031343O3046344F2O3034312O3031353O3046344F2O3034382O3031342O303135344F3O30422O303132334F3O30313O30343137334F2O3032383O30313O30343137334F2O3031383O30313O303633453O30432O3031343O30313O30323O30343137334F2O3031343O30312O3031323037334F2O303130334F2O3032363146334F2O3034313O30312O302O313O30343137334F2O3034313O30312O30323035343O30433O30342O3031322O30313230373O30452O30312O334F3O303631433O3046334F3O30313O302O324F2O303334334F3O3038344F2O303334334F3O3032344F2O3034363O30433O30463O30312O30323035343O30433O30342O3031342O30313230373O30452O303135344F2O3031333O3046334F3O30332O30313233432O30313O303137334F2O30313031383O30462O3031362O30313O30333034463O30462O3031382O3031392O30313031383O30462O3031413O30363O303631432O30314O30313O30313O3031324F2O303334334F3O3038344F2O3034363O30432O30314O30312O30323035343O30433O30342O3031422O30313230373O30452O303143344F2O3034363O30433O30453O30312O3031323037334F2O303144334F2O3032363146334F2O3034413O30312O3031443O30343137334F2O3034413O30312O30323035343O30433O30342O3031322O30313230373O30452O303145334F3O303631433O30463O30323O30313O3031324F2O303334334F3O3032344F2O3034363O30433O30463O3031324F2O302O323O30413O3042334F2O3031323037334F2O303146334F2O3032363146334F2O3035413O30312O30324O30343137334F2O3035413O30312O30323035343O30433O30332O3032312O30313230373O30452O302O32344F2O3032443O30433O30453O302O324F2O3034313O30343O3043334F2O30313233433O30433O3034334F2O30323034373O30433O30432O3032332O30323034373O30433O30432O3032342O30323035343O30433O30432O303235324F2O3032413O30433O30323O302O324F2O3034313O30353O3043334F2O30313233433O30432O303236334F2O30313230373O30442O303237344F2O3031343O30433O30323O30312O3031323037334F3O3032334F2O3032363146334F2O3036423O30312O30314O30343137334F2O3036423O30312O30313233433O30432O303236334F2O30313233433O30443O3044334F2O30323034373O30443O30442O303238324F2O3034313O30453O3037334F2O30313230373O30462O303239344F2O302O333O30443O3046344F3O30423O3043334F3O30312O30323034373O30383O30362O30323O30323035343O30433O30342O3032412O30313230373O30452O303242344F2O3031333O3046334F3O30312O30333034463O30462O3031382O303243324F2O3032443O30433O30463O302O324F2O3034313O30393O3043334F2O3031323037334F2O303244334F2O3032363146334F2O3037443O30313O30313O30343137334F2O3037443O30312O30313230373O30312O303230334F2O30313233433O30433O3034334F2O30323035343O30433O30433O30352O30313230373O30453O3036344F2O3032443O30433O30453O30322O30323034373O30323O30433O30372O30313233433O30432O303245334F2O30313233433O30443O3034334F2O30323035343O30443O30442O3032462O30313230373O30462O303330344F3O30392O30314O3031344F2O302O333O30442O303130344F2O3032463O3043334F3O302O324F2O302O313O30433O30313O302O324F2O3034313O30333O3043334F2O3031323037334F2O303230334F2O3032363146334F2O3039323O30312O3032443O30343137334F2O3039323O30312O30323035343O30433O30342O3033312O30313230373O30452O303332344F2O3031333O3046334F3O30342O30333034463O30462O302O332O3033342O30333034463O30462O3033352O30323O30333034463O30462O3033362O30323O30333034463O30462O3033372O3033383O303631432O30314O30333O30313O3031324F2O303334334F3O3031344F2O3034363O30432O30314O30312O30323035343O30433O30342O3031422O30313230373O30452O303339344F2O3034363O30433O30453O30312O30323035343O30433O30342O3031322O30313230373O30452O303341334F3O303631433O30463O30343O30313O3031324F2O303334334F3O3032344F2O3034363O30433O30463O30312O3031323037334F2O302O31334F2O3032363146334F3O30323O30312O3031463O30343137334F3O30323O30312O30313233433O30432O303342334F2O30313233433O30443O3034334F2O30313230373O30452O303343334F3O303631433O30463O30353O30313O3035324F2O303334334F3O302O344F2O303334334F3O3032344F2O303334334F3O3031344F2O303334334F3O3041344F2O303334334F3O3042344F2O3032443O30433O30463O302O324F2O3034313O30423O3043334F2O30323035343O30433O30342O3031422O30313230373O30452O303344344F2O3034363O30433O30453O30313O30343137334F2O3041343O30313O30343137334F3O30323O3031324F2O30322O384F2O303142334F3O3031334F3O3036334F2O303137334F3O30333035334F2O303730363136393732373330333034334F2O30363736313644363530333039334F2O3035373646373236423733373036313633363530333036334F2O30353436462O3736353732373330333042334F2O3034373635372O3433363836393643363437323635364530333043334F2O30353736313639372O342O364637323433363836393643363430333035334F2O3034462O3736453635373230333035334F2O30352O363136433735363530333037334F2O30353036433631373936353732373330333042334F2O303443364636333631364335303643363137393635373230333036334F2O302O353733363537323439363430333041334F2O30353236353730364336393633363137343646373230333043334F2O3034373635372O3431324F373437323639363237353734363530333034334F2O3035343739373036353032384F3O30333043334F2O3034393645372O36463642362O353336353732372O3635373230333036334F2O303534372O324F36463730373330333037334F2O302O353730362O3732363136343635324F302O334F2O3035333635373430333035334F2O303534372O324F3646372O30333034334F2O30373436313733364230333034334F2O302O373631363937343032364F2O33432O33462O303335334F2O3031323343334F3O3031334F2O30313233433O30313O3032334F2O30323034373O30313O30313O30332O30323034373O30313O30313O30342O30323035343O30313O30313O3035324F2O3034383O30313O3032344F2O303432354F3O30323O30343137334F2O3033323O30312O30323035343O30353O30343O30362O30313230373O30373O3037344F2O3032443O30353O30373O30322O30323034373O30353O30353O30382O30313233433O30363O3032334F2O30323034373O30363O30363O30392O30323034373O30363O30363O30412O30323034373O30363O30363O30423O303633463O30352O3033323O30313O30363O30343137334F2O3033323O30312O30323035343O30353O30343O30362O30313230373O30373O3043344F2O3032443O30353O30373O30322O30323035343O30353O30353O30442O30313230373O30373O3045344F2O3032443O30353O30373O302O324F2O3033383O3036354F3O303633463O30352O3033323O30313O30363O30343137334F2O3033323O30312O30313230373O30353O3046344F2O302O323O30363O3036334F3O304534453O30462O3031443O30313O30353O30343137334F2O3031443O30312O30313230373O30363O3046334F2O30323631463O30362O30324O30313O30463O30343137334F2O30324O3031324F2O3033383O30373O3031334F2O30323035343O30373O30372O30313O30313230373O30392O302O31334F2O30313230373O30412O303132334F2O30313230373O30422O303133344F2O3031333O3043334F3O30312O30313031383O30432O3031343O3034324F2O3034363O30373O30433O30312O30313233433O30372O303135334F2O30323034373O30373O30372O3031362O30313230373O30382O303137344F2O3031343O30373O30323O30313O30343137334F2O3033323O30313O30343137334F2O30324O30313O30343137334F2O3033323O30313O30343137334F2O3031443O30313O30363345334F3O30383O30313O30323O30343137334F3O30383O3031324F2O303142334F3O3031394F2O30324F3O30313032344F3O302O384F2O303142334F3O3031374F2O30312O334F3O30333035334F2O303730363136393732373330333034334F2O30363736313644363530333039334F2O3035373646373236423733373036313633363530333036334F2O30353436462O3736353732373330333042334F2O3034373635372O3433363836393643363437323635364530333043334F2O30353736313639372O342O364637323433363836393643363430333035334F2O3034462O3736453635373230333035334F2O30352O363136433735363530333037334F2O30353036433631373936353732373330333042334F2O303443364636333631364335303643363137393635373230333036334F2O302O35373336353732343936343032384F3O30333043334F2O3034393645372O36463642362O353336353732372O3635373230333036334F2O303534372O324F36463730373330333034334F2O3035333635324F364330333035334F2O303534372O324F3646372O30333034334F2O30373436313733364230333034334F2O302O373631363937343032364F2O33432O33462O303242334F2O3031323343334F3O3031334F2O30313233433O30313O3032334F2O30323034373O30313O30313O30332O30323034373O30313O30313O30342O30323035343O30313O30313O3035324F2O3034383O30313O3032344F2O303432354F3O30323O30343137334F2O3032383O30312O30323035343O30353O30343O30362O30313230373O30373O3037344F2O3032443O30353O30373O30322O30323034373O30353O30353O30382O30313233433O30363O3032334F2O30323034373O30363O30363O30392O30323034373O30363O30363O30412O30323034373O30363O30363O30423O303633463O30352O3032383O30313O30363O30343137334F2O3032383O30312O30313230373O30353O3043344F2O302O323O30363O3036334F3O304534453O30432O3031343O30313O30353O30343137334F2O3031343O30312O30313230373O30363O3043334F2O30323631463O30362O3031373O30313O30433O30343137334F2O3031373O3031324F2O3033383O3037354F2O30323035343O30373O30373O30442O30313230373O30393O3045334F2O30313230373O30413O3046344F2O3031333O3042334F3O30312O30313031383O30422O30314O3034324F2O3034363O30373O30423O30312O30313233433O30372O302O31334F2O30323034373O30373O30372O3031322O30313230373O30382O303133344F2O3031343O30373O30323O30313O30343137334F2O3032383O30313O30343137334F2O3031373O30313O30343137334F2O3032383O30313O30343137334F2O3031343O30313O30363345334F3O30383O30313O30323O30343137334F3O30383O3031324F2O303142334F3O3031394F2O30324F3O30313032344F3O302O384F2O303142334F3O3031374F2O303134334F3O30333035334F2O303730363136393732373330333034334F2O30363736313644363530333039334F2O3035373646373236423733373036313633363530333036334F2O30353436462O3736353732373330333042334F2O3034373635372O3433363836393643363437323635364530333043334F2O30353736313639372O342O364637323433363836393643363430333035334F2O3034462O3736453635373230333035334F2O30352O363136433735363530333037334F2O30353036433631373936353732373330333042334F2O303443364636333631364335303643363137393635373230333036334F2O302O35373336353732343936343032384F3O30333043334F2O3034393645372O36463642362O353336353732372O3635373230333036334F2O303534372O324F36463730373330333037334F2O302O353730362O3732363136343635324F302O334F2O3035333635373430333035334F2O303534372O324F3646372O30333034334F2O30373436313733364230333034334F2O302O373631363937343032364F2O33432O33462O303236334F2O3031323343334F3O3031334F2O30313233433O30313O3032334F2O30323034373O30313O30313O30332O30323034373O30313O30313O30342O30323035343O30313O30313O3035324F2O3034383O30313O3032344F2O303432354F3O30323O30343137334F2O3032333O30312O30323035343O30353O30343O30362O30313230373O30373O3037344F2O3032443O30353O30373O30322O30323034373O30353O30353O30382O30313233433O30363O3032334F2O30323034373O30363O30363O30392O30323034373O30363O30363O30412O30323034373O30363O30363O30423O303633463O30352O3032333O30313O30363O30343137334F2O3032333O30312O30313230373O30353O3043334F2O30323631463O30352O3031333O30313O30433O30343137334F2O3031333O3031324F2O3033383O3036354F2O30323035343O30363O30363O30442O30313230373O30383O3045334F2O30313230373O30393O3046334F2O30313230373O30412O303130344F2O3031333O3042334F3O30312O30313031383O30422O302O313O3034324F2O3034363O30363O30423O30312O30313233433O30362O303132334F2O30323034373O30363O30362O3031332O30313230373O30372O30312O344F2O3031343O30363O30323O30313O30343137334F2O3032333O30313O30343137334F2O3031333O30313O30363345334F3O30383O30313O30323O30343137334F3O30383O3031324F2O303142334F3O3031374F3O3042334F3O3032384F3O3032364F2O304630334630333035334F2O303O36433631362O373330333042334F2O303733373436313633364235343646324F36373643363530333043334F2O3034393645372O36463642362O353336353732372O363537323032364F2O303130342O30333036334F2O303534372O324F3646373037333032374F2O30342O30333035334F2O303530364336313633363530333035334F2O303733373036312O37364530332O31334F2O30363736353734364536313644363536333631324F364336443635373436383646363430313541334F2O30313230373O30323O3031344F2O302O323O30333O3035334F2O30323631463O30322O3035333O30313O30323O30343137334F2O3035333O3031324F2O302O323O30353O3035334F2O30313230373O30363O3031334F2O30323631463O30363O30363O30313O30313O30343137334F3O30363O30312O30323631463O30332O3033443O30313O30323O30343137334F2O3033443O30312O30313230373O30373O3031334F3O304534453O30313O30423O30313O30373O30343137334F3O30423O3031324F2O3033383O3038354F2O30323034373O30383O30383O30332O30323034373O30383O30383O30342O30324F30363O30382O3033373O3031334F3O30343137334F2O3033373O30312O30323631463O30352O3033373O30313O30353O30343137334F2O3033373O3031324F2O3033383O30383O3031334F3O30363346334F2O3033373O30313O30383O30343137334F2O3033373O3031324F2O3035323O30383O3034334F2O30323631463O30382O3033373O30313O30363O30343137334F2O3033373O30312O30323034373O30383O30343O30322O30323631463O30382O3033373O30313O30373O30343137334F2O3033373O30312O30323034373O30383O30343O30382O30323631463O30382O3033373O30313O30393O30343137334F2O3033373O30312O30313230373O30383O3031344F2O302O323O30393O3039334F2O30323631463O30382O302O323O30313O30313O30343137334F2O302O323O30312O30313230373O30393O3031334F2O30323631463O30392O3032353O30313O30313O30343137334F2O3032353O30312O30313230373O30413O3031334F2O30323631463O30412O3032383O30313O30313O30343137334F2O3032383O30312O30313233433O30423O3041334F3O303631433O3043334F3O30313O3034324F2O303230334F3O3032344F2O303230334F3O3031344F2O303334334F3O302O344F2O303230334F3O3033344F2O3031343O30423O30323O3031324F2O302O323O30423O3042344F2O3033363O30423O3032334F3O30343137334F2O3032383O30313O30343137334F2O3032353O30313O30343137334F2O3033373O30313O30343137334F2O302O323O3031324F2O3033383O30383O302O344F2O3034313O3039364F2O30344O3041364F2O3033443O3038364F2O3031413O3038354F3O30343137334F3O30423O30312O30323631463O30333O30353O30313O30313O30343137334F3O30353O30312O30313230373O30373O3031334F2O30323631463O30372O302O343O30313O30323O30343137334F2O302O343O30312O30313230373O30333O3032334F3O30343137334F3O30353O30313O304534453O30312O30344O30313O30373O30343137334F2O30344O3031324F2O3031333O3038364F2O30344O3039364F2O3035363O3038334F3O3031324F2O3034313O30343O3038334F2O30313233433O30383O3042344F2O302O313O30383O30313O302O324F2O3034313O30353O3038334F2O30313230373O30373O3032334F3O30343137334F2O30344O30313O30343137334F3O30353O30313O30343137334F3O30363O30313O30343137334F3O30353O30313O30343137334F2O3035393O30312O30323631463O30323O30323O30313O30313O30343137334F3O30323O30312O30313230373O30333O3031344F2O302O323O30343O3034334F2O30313230373O30323O3032334F3O30343137334F3O30323O3031324F2O303142334F3O3031334F3O3031334F2O303132334F3O3032384F3O3032364F2O304630334630333043334F2O3034393645372O36463642362O353336353732372O363537323032374F2O30342O3032364F3O3038342O30333038334F2O303532364637343631373436393646364530333036334F2O30343334363732363136443635324F302O334F2O30364536352O373032364F2O30312O342O30333038334F2O303530364637333639373436393646364530333034334F2O30373436313733364230333034334F2O302O373631363937343032364F2O33432O334630333037334F2O30352O363536333734364637322O3330333031334F2O30353830333031334F2O3035413032364F2O303130342O30333031334F2O3035392O303438334F2O3031323037334F3O3031344F2O302O323O30313O3032334F2O3032363146334F2O3033463O30313O30323O30343137334F2O3033463O30312O30313230373O30333O3032344F2O3033383O3034354F2O30313230373O30353O3032334F3O303432393O30332O3033433O30312O30313230373O30373O3031334F2O30323631463O30372O3032433O30313O30323O30343137334F2O3032433O3031324F2O3033383O30383O3031334F2O30323035343O30383O30383O3033324F2O3033383O30413O3032334F2O30323034373O30413O30413O302O324F2O3033383O30423O3032334F2O30323034373O30423O30423O3034324F2O3033383O30433O3032334F2O30323034373O30433O30433O3035324F2O3031333O3044334F3O30322O30313233433O30453O3037334F2O30323034373O30453O30453O30382O30313230373O30463O3031334F2O30313230372O30314O3039334F2O30313230372O302O313O3031334F2O30313230372O3031323O3031334F2O30313230372O3031333O3039334F2O30313230372O3031343O3031334F2O30313230372O3031353O3031334F2O30313230372O3031363O3039334F2O30313230372O3031373O3031334F2O30313230372O3031383O3031334F2O30313230372O3031393O3039334F2O30313230372O3031413O3031344F2O3032443O30452O3031413O30322O30313031383O30443O30363O30452O30313031383O30443O30413O3031324F3O30393O30453O3031344F2O3034363O30383O30453O30312O30313233433O30383O3042334F2O30323034373O30383O30383O30432O30313230373O30393O3044344F2O3031343O30383O30323O30313O30343137334F2O3033423O30312O30323631463O30373O30393O30313O30313O30343137334F3O30393O30312O30313230373O30383O3032344F3O30383O30383O302O334F2O30313233433O30383O3045334F2O30323034373O30383O30383O30382O30323034373O30393O30313O30462O30322O30433O30413O30363O30322O30323031453O30413O30413O3039324F2O3033393O30413O30323O30412O30323034373O30423O30312O303130324F2O3032443O30383O30423O302O324F2O3034313O30313O3038334F2O30313230373O30373O3032334F3O30343137334F3O30393O30313O303435313O30333O30383O30312O30313230373O30333O3031344F3O30383O30333O302O334F3O30343137334F2O3034373O30312O3032363146334F3O30323O30313O30313O30343137334F3O30323O3031324F2O3033383O30333O3032334F2O30323034373O30333O30332O302O312O30323034373O30313O30333O30412O30323034373O30323O30312O3031322O3031323037334F3O3032334F3O30343137334F3O30323O3031324F2O303142334F3O3031374F2O3000333O0012263O00013O001226000100023O002073000100010003001226000200023O002073000200020004001226000300023O002073000300030005001226000400023O002073000400040006001226000500023O002073000500050007001226000600083O002073000600060009001226000700083O00207300070007000A0012260008000B3O00207300080008000C0012260009000D3O000635000900150001000100046D3O0015000100027000095O001226000A000E3O001226000B000F3O001226000C00103O001226000D00113O000635000D001D0001000100046D3O001D0001001226000D00083O002073000D000D0011001226000E00013O00066C000F00010001000C2O00133O00044O00133O00034O00133O00014O00138O00133O00024O00133O00054O00133O00084O00133O00064O00133O000C4O00133O000D4O00133O00074O00133O000A4O00360010000F3O001259001100124O0036001200094O00570012000100022O006500136O004600106O003D00106O00053O00013O00023O00013O0003043O005F454E5600033O0012263O00014O00283O00024O00053O00017O00033O00026O00F03F026O00144003023O002O2E02463O001259000300014O001C000400044O003700056O0037000600014O003600075O001259000800024O0060000600080002001259000700033O00066C00083O000100062O000D3O00024O00133O00044O000D3O00034O000D3O00014O000D3O00044O000D3O00054O00600005000800022O00363O00053O000270000500013O00066C00060002000100032O000D3O00024O00138O00133O00033O00066C00070003000100032O000D3O00024O00138O00133O00033O00066C00080004000100032O000D3O00024O00138O00133O00033O00066C00090005000100032O00133O00084O00133O00054O000D3O00063O00066C000A0006000100072O00133O00084O000D3O00014O00138O00133O00034O000D3O00044O000D3O00024O000D3O00074O0036000B00083O00066C000C0007000100012O000D3O00083O00066C000D0008000100072O00133O00064O00133O00094O00133O000A4O00133O00084O00133O00054O00133O00074O00133O000D3O00066C000E0009000100062O00133O000C4O000D3O00084O000D3O00094O000D3O000A4O000D3O000B4O00133O000E4O0036000F000E4O00360010000D4O00570010000100022O000800116O0036001200014O0060000F001200022O006500106O0046000F6O003D000F6O00053O00013O000A3O00053O00027O0040025O00C05340026O00F03F034O00026O00304001244O003700016O003600025O001259000300014O0060000100030002002640000100110001000200046D3O001100012O0037000100024O0037000200034O003600035O001259000400033O001259000500034O005B000200054O004D00013O00022O003F000100013O001259000100044O0028000100023O00046D3O002300012O0037000100044O0037000200024O003600035O001259000400054O005B000200044O004D00013O00022O0037000200013O0006520002002200013O00046D3O002200012O0037000200054O0036000300014O0037000400014O00600002000400022O001C000300034O003F000300014O0028000200023O00046D3O002300012O0028000100024O00053O00017O00033O00026O00F03F027O0040028O0003203O0006520002000F00013O00046D3O000F000100204A0003000100010010120003000200032O000600033O000300204A00040002000100204A0005000100012O00490004000400050020110004000400010010120004000200042O00320003000300040020270004000300012O00490004000300042O0028000400023O00046D3O001F0001001259000300034O001C000400043O002640000300110001000300046D3O0011000100204A0005000100010010120004000200052O00480005000400042O003200053O00050006380004001C0001000500046D3O001C0001001259000500013O0006350005001D0001000100046D3O001D0001001259000500034O0028000500023O00046D3O001100012O00053O00017O00023O00028O00026O00F03F00133O0012593O00014O001C000100013O0026403O00050001000200046D3O000500012O0028000100023O0026403O00020001000100046D3O000200012O003700026O0037000300014O0037000400024O0037000500024O00600002000500022O0036000100024O0037000200023O0020110002000200022O003F000200023O0012593O00023O00046D3O000200012O00053O00017O00043O00028O00026O00F03F026O007040027O004000173O0012593O00014O001C000100023O0026403O00070001000200046D3O0007000100205A0003000200032O00480003000300012O0028000300023O0026403O00020001000100046D3O000200012O003700036O0037000400014O0037000500024O0037000600023O0020110006000600042O00630003000600042O0036000200044O0036000100034O0037000300023O0020110003000300042O003F000300023O0012593O00023O00046D3O000200012O00053O00017O00053O00026O000840026O00F03F026O007041026O00F040026O00704000124O00378O0037000100014O0037000200024O0037000300023O0020110003000300012O00633O000300032O0037000400023O0020110004000400010020110004000400022O003F000400023O00205A00040003000300205A0005000200042O004800040004000500205A0005000100052O00480004000400052O0048000400044O0028000400024O00053O00017O000C3O00026O00F03F026O003440026O00F041026O003540026O003F40026O002O40026O00F0BF028O00025O00FC9F402O033O004E614E025O00F88F40026O00304300394O00378O00573O000100022O003700016O0057000100010002001259000200014O0037000300014O0036000400013O001259000500013O001259000600024O006000030006000200205A0003000300032O0048000300034O0037000400014O0036000500013O001259000600043O001259000700054O00600004000700022O0037000500014O0036000600013O001259000700064O00600005000700020026400005001A0001000100046D3O001A0001001259000500073O0006350005001B0001000100046D3O001B0001001259000500013O002640000400250001000800046D3O00250001002640000300220001000800046D3O0022000100205A0006000500082O0028000600023O00046D3O00300001001259000400013O001259000200083O00046D3O00300001002640000400300001000900046D3O003000010026400003002D0001000800046D3O002D00010030770006000100082O004C0006000500060006350006002F0001000100046D3O002F00010012260006000A4O004C0006000500062O0028000600024O0037000600024O0036000700053O00204A00080004000B2O006000060008000200202D00070003000C2O00480007000200072O004C0006000600072O0028000600024O00053O00017O00033O00028O00034O00026O00F03F01293O0006353O00090001000100046D3O000900012O003700026O00570002000100022O00363O00023O0026403O00090001000100046D3O00090001001259000200024O0028000200024O0037000200014O0037000300024O0037000400034O0037000500034O0048000500053O00204A0005000500032O00600002000500022O0036000100024O0037000200034O0048000200024O003F000200034O000800025O001259000300034O0069000400013O001259000500033O0004550003002400012O0037000700044O0037000800054O0037000900014O0036000A00014O0036000B00064O0036000C00064O005B0009000C4O003100086O004D00073O00022O00100002000600070004020003001900012O0037000300064O0036000400024O0066000300044O003D00036O00053O00017O00013O0003013O002300094O000800016O006500026O000900013O00012O003700025O001259000300014O006500046O003100026O003D00016O00053O00017O00073O00028O00027O0040026O000840026O00F03F026O001040026O001840026O00F0402O00022O0012593O00014O001C000100083O000E7C0002000600013O00046D3O000600012O001C000500063O0012593O00033O0026403O000A0001000400046D3O000A00012O001C000300043O0012593O00023O0026073O000D0001000100046D3O000D000100046D3O00100001001259000100014O001C000200023O0012593O00043O0026403O00140001000300046D3O001400012O001C000700083O0012593O00053O0026403O00020001000500046D3O00020001000E04000200190001000100046D3O0019000100046D3O00250001001259000900013O0026070009001D0001000100046D3O001D000100046D3O001F00012O001C000600073O001259000900043O002607000900220001000400046D3O0022000100046D3O001A0001001259000100033O00046D3O0025000100046D3O001A0001002640000100EB2O01000300046D3O00EB2O012O001C000800083O001259000900013O002640000900B72O01000100046D3O00B72O010026400002003E0001000100046D3O003E0001001259000A00013O002607000A00310001000400046D3O0031000100046D3O003500012O0008000B6O00360005000B3O001259000200043O00046D3O003E0001002607000A00380001000100046D3O0038000100046D3O002E00012O0008000B6O00360003000B4O0008000B6O00360004000B3O001259000A00043O00046D3O002E0001002640000200B62O01000200046D3O00B62O01001259000A00013O002607000A00440001000100046D3O0044000100046D3O00950001001259000B00013O002607000B00480001000100046D3O0048000100046D3O008F0001001259000C00044O0036000D00073O001259000E00043O000455000C008B0001001259001000014O001C001100133O002640001000530001000100046D3O00530001001259001100014O001C001200123O001259001000043O002607001000560001000400046D3O0056000100046D3O004E00012O001C001300133O0026400011006F0001000100046D3O006F0001001259001400013O0026400014005E0001000400046D3O005E0001001259001100043O00046D3O006F0001002607001400610001000100046D3O0061000100046D3O005A0001001259001500013O002640001500660001000400046D3O00660001001259001400043O00046D3O005A0001002640001500620001000100046D3O006200012O003700166O00570016000100022O0036001200164O001C001300133O001259001500043O00046D3O0062000100046D3O005A0001002640001100570001000400046D3O005700010026400012007A0001000400046D3O007A00012O003700146O0057001400010002002640001400780001000100046D3O007800012O006E00136O0034001300013O00046D3O00850001002640001200800001000200046D3O008000012O0037001400014O00570014000100022O0036001300143O00046D3O00850001002640001200850001000300046D3O008500012O0037001400024O00570014000100022O0036001300144O00100008000F001300046D3O008A000100046D3O0057000100046D3O008A000100046D3O004E0001000402000C004C00012O0037000C6O0057000C0001000200102A00060003000C001259000B00043O002607000B00920001000400046D3O0092000100046D3O00450001001259000A00043O00046D3O0095000100046D3O00450001002607000A00980001000400046D3O0098000100046D3O00410001001259000B00044O0037000C00034O0057000C00010002001259000D00043O000455000B00B32O01001259000F00014O001C001000133O002607000F00A20001000100046D3O00A2000100046D3O00A50001001259001000014O001C001100113O001259000F00043O002640000F00AC2O01000200046D3O00AC2O01000E7C0004009D2O01001000046D3O009D2O012O001C001300133O0026400011008D2O01000400046D3O008D2O01002640001200AC0001000100046D3O00AC00012O003700146O00570014000100022O0036001300144O0037001400044O0036001500133O001259001600043O001259001700044O0060001400170002002640001400B22O01000100046D3O00B22O01001259001400014O001C001500193O002607001400BD0001000200046D3O00BD000100046D3O00802O012O001C001900193O002607001500C10001000400046D3O00C1000100046D3O00CC0001001259001A00013O002607001A00C50001000100046D3O00C5000100046D3O00C700012O001C001800193O001259001A00043O002640001A00C20001000400046D3O00C20001001259001500023O00046D3O00CC000100046D3O00C20001002640001500D10001000100046D3O00D10001001259001600014O001C001700173O001259001500043O002607001500D40001000200046D3O00D4000100046D3O00BE0001002640001600EB0001000100046D3O00EB0001001259001A00013O002640001A00DB0001000400046D3O00DB0001001259001600043O00046D3O00EB0001000E7C000100D70001001A00046D3O00D700012O0037001B00044O0036001C00133O001259001D00023O001259001E00034O0060001B001E00022O00360017001B4O0037001B00044O0036001C00133O001259001D00053O001259001E00064O0060001B001E00022O00360018001B3O001259001A00043O00046D3O00D700010026400016004B2O01000400046D3O004B2O01001259001A00014O001C001B001B3O002640001A00EF0001000100046D3O00EF0001001259001B00013O002640001B00F60001000400046D3O00F60001001259001600023O00046D3O004B2O01002640001B00F20001000100046D3O00F20001001259001C00013O000E7C000100432O01001C00046D3O00432O012O0008001D00044O0037001E00054O0057001E000100022O0037001F00054O0057001F000100022O001C002000214O002E001D000400012O00360019001D3O002640001700212O01000100046D3O00212O01001259001D00014O001C001E001F3O002640001D000C2O01000100046D3O000C2O01001259001E00014O001C001F001F3O001259001D00043O002640001D00072O01000400046D3O00072O01000E04000100112O01001E00046D3O00112O0100046D3O000E2O01001259001F00013O002640001F00122O01000100046D3O00122O012O0037002000054O005700200001000200102A0019000300202O0037002000054O005700200001000200102A00190005002000046D3O00422O0100046D3O00122O0100046D3O00422O0100046D3O000E2O0100046D3O00422O0100046D3O00072O0100046D3O00422O01002640001700272O01000400046D3O00272O012O0037001D00034O0057001D0001000200102A00190003001D00046D3O00422O010026400017002E2O01000200046D3O002E2O012O0037001D00034O0057001D0001000200204A001D001D000700102A00190003001D00046D3O00422O01002640001700422O01000300046D3O00422O01001259001D00014O001C001E001E3O002640001D00322O01000100046D3O00322O01001259001E00013O000E7C000100352O01001E00046D3O00352O012O0037001F00034O0057001F0001000200204A001F001F000700102A00190003001F2O0037001F00054O0057001F0001000200102A00190005001F00046D3O00422O0100046D3O00352O0100046D3O00422O0100046D3O00322O01001259001C00043O000E7C000400F90001001C00046D3O00F90001001259001B00043O00046D3O00F2000100046D3O00F9000100046D3O00F2000100046D3O004B2O0100046D3O00EF00010026070016004E2O01000200046D3O004E2O0100046D3O006E2O01001259001A00013O002607001A00522O01000100046D3O00522O0100046D3O00682O012O0037001B00044O0036001C00183O001259001D00043O001259001E00044O0060001B001E0002002640001B005C2O01000400046D3O005C2O01002073001B001900022O0072001B0008001B00102A00190002001B2O0037001B00044O0036001C00183O001259001D00023O001259001E00024O0060001B001E0002002607001B00642O01000400046D3O00642O0100046D3O00672O01002073001B001900032O0072001B0008001B00102A00190003001B001259001A00043O002607001A006B2O01000400046D3O006B2O0100046D3O004F2O01001259001600033O00046D3O006E2O0100046D3O004F2O01002640001600D40001000300046D3O00D400012O0037001A00044O0036001B00183O001259001C00033O001259001D00034O0060001A001D0002002640001A007A2O01000400046D3O007A2O01002073001A001900052O0072001A0008001A00102A00190005001A2O00100003000E001900046D3O00B22O0100046D3O00D4000100046D3O00B22O0100046D3O00BE000100046D3O00B22O01002640001400852O01000100046D3O00852O01001259001500014O001C001600163O001259001400043O002640001400BA0001000400046D3O00BA00012O001C001700183O001259001400023O00046D3O00BA000100046D3O00B22O0100046D3O00AC000100046D3O00B22O01002640001100AA0001000100046D3O00AA0001001259001400013O002640001400942O01000400046D3O00942O01001259001100043O00046D3O00AA0001002607001400972O01000100046D3O00972O0100046D3O00902O01001259001200014O001C001300133O001259001400043O00046D3O00902O0100046D3O00AA000100046D3O00B22O01002640001000A70001000100046D3O00A70001001259001400013O002640001400A42O01000400046D3O00A42O01001259001000043O00046D3O00A70001000E7C000100A02O01001400046D3O00A02O01001259001100014O001C001200123O001259001400043O00046D3O00A02O0100046D3O00A7000100046D3O00B22O01002607000F00AF2O01000400046D3O00AF2O0100046D3O009F00012O001C001200133O001259000F00023O00046D3O009F0001000402000B009D0001001259000200033O00046D3O00B62O0100046D3O00410001001259000900043O002607000900BA2O01000400046D3O00BA2O0100046D3O00290001000E04000300BD2O01000200046D3O00BD2O0100046D3O00D82O01001259000A00014O001C000B000B3O000E04000100C22O01000A00046D3O00C22O0100046D3O00BF2O01001259000B00013O002607000B00C62O01000100046D3O00C62O0100046D3O00C32O01001259000C00013O002640000C00C72O01000100046D3O00C72O01001259000D00044O0037000E00034O0057000E00010002001259000F00043O000455000D00D32O0100204A0011001000042O0037001200064O00570012000100022O0010000400110012000402000D00CE2O012O0028000600023O00046D3O00C72O0100046D3O00C32O0100046D3O00D82O0100046D3O00BF2O01000E7C000400280001000200046D3O002800012O0008000A00044O0036000B00034O0036000C00044O001C000D000D4O0036000E00054O002E000A000400012O00360006000A4O0037000A00034O0057000A000100022O00360007000A4O0008000A6O00360008000A3O001259000200023O00046D3O0028000100046D3O0029000100046D3O0028000100046D3O00FF2O01000E7C000400F72O01000100046D3O00F72O01001259000900013O000E7C000100F22O01000900046D3O00F22O012O001C000400053O001259000900043O002640000900EE2O01000400046D3O00EE2O01001259000100023O00046D3O00F72O0100046D3O00EE2O01002640000100160001000100046D3O00160001001259000200014O001C000300033O001259000100043O00046D3O0016000100046D3O00FF2O0100046D3O000200012O00053O00017O00043O00028O00026O00F03F027O0040026O00084003193O001259000300014O001C000400063O002640000300070001000100046D3O0007000100207300043O000200207300053O0003001259000300023O002640000300020001000200046D3O0002000100207300063O000400066C00073O0001000B2O00133O00044O00133O00054O00133O00064O000D8O000D3O00014O000D3O00024O00133O00014O000D3O00034O000D3O00044O000D3O00054O00133O00024O0028000700023O00046D3O000200012O00053O00013O00013O005B3O00026O00F03F026O00F0BF03013O0023028O00026O004540026O003440026O002240026O001040027O0040026O000840026O001840026O001440026O001C40026O002040026O002C40026O002640026O002440026O002840026O002A40026O003140026O002E40026O003040026O003240026O003340026O003F40026O003940026O003640026O003540026O003740026O003840026O003C40026O003A40026O003B4003073O002O5F696E646578030A3O002O5F6E6577696E646578026O004A40026O003D40026O003E40026O004240025O00802O40026O002O40026O00414000025O00804140025O00804340025O00804240026O004340026O004440025O00804440026O005040025O00804A40025O00804740026O004640025O00804540025O00804640026O004740026O004940026O004840025O00804840025O00804940026O004D40025O00804B40026O004B40026O004C40025O00804C40025O00804E40025O00804D40026O004E40026O004F40025O00804F40025O00C05240025O00405140025O00805040025O00405040025O00C05040026O005140026O005240025O00805140025O00C05140025O00405240025O00805240026O005440025O00405340026O005340025O00805340025O00C05340025O00C05440025O00405440025O00805440026O005540025O004055400044053O003700016O0037000200014O0037000300024O0037000400033O001259000500013O001259000600024O000800076O000800086O006500096O000900083O00012O0037000900043O001259000A00034O0065000B6O004D00093O000200204A0009000900012O0008000A6O0008000B5O001259000C00044O0036000D00093O001259000E00013O000455000C002000010006380003001C0001000F00046D3O001C00012O00490010000F00030020110011000F00012O00720011000800112O001000070010001100046D3O001F00010020110010000F00012O00720010000800102O0010000B000F0010000402000C001500012O0049000C00090003002011000C000C00012O001C000D000E4O0072000D00010005002073000E000D0001002639000E00CC0201000500046D3O00CC0201002639000E003D2O01000600046D3O003D2O01002639000E00A80001000700046D3O00A80001002639000E00630001000800046D3O00630001002639000E003B0001000100046D3O003B0001002640000E00370001000400046D3O00370001002073000F000D00092O0072000F000B000F0020730010000D000A0020730011000D00082O0010000F0010001100046D3O00410501002073000F000D00090020730010000D000A2O0010000B000F001000046D3O00410501002639000E00450001000900046D3O00450001002073000F000D00090020730010000D000A2O00720010000B00100020730011000D00082O00720011000B00112O00480010001000112O0010000B000F001000046D3O00410501000E23000A005F0001000E00046D3O005F0001002073000F000D00092O0036001000044O00720011000B000F0020110012000F00012O00720012000B00122O0047001100124O002500103O00112O004800120011000F00204A000600120001001259001200044O00360013000F4O0036001400063O001259001500013O0004550013005E0001001259001700043O000E7C000400560001001700046D3O005600010020110012001200012O00720018001000122O0010000B0016001800046D3O005D000100046D3O0056000100040200130055000100046D3O00410501002073000F000D00092O000800106O0010000B000F001000046D3O00410501002639000E00920001000B00046D3O00920001000E23000C006F0001000E00046D3O006F0001002073000F000D00092O0072000F000B000F000652000F006D00013O00046D3O006D000100201100050005000100046D3O004105010020730005000D000A00046D3O00410501001259000F00044O001C001000123O002640000F007F0001000400046D3O007F00010020730010000D00092O000800136O00720014000B00102O0037001500054O00360016000B3O0020110017001000012O0036001800064O005B001500184O003100146O000900133O00012O0036001100133O001259000F00013O002640000F00710001000100046D3O00710001001259001200044O0036001300103O0020730014000D0008001259001500013O0004550013008F0001001259001700043O000E7C000400870001001700046D3O008700010020110012001200012O00720018001100122O0010000B0016001800046D3O008E000100046D3O0087000100040200130086000100046D3O0041050100046D3O0071000100046D3O00410501002639000E00980001000D00046D3O00980001002073000F000D00090020730010000D000A2O0010000B000F001000046D3O00410501000E23000E00A20001000E00046D3O00A20001002073000F000D00090020730010000D000A0026400010009F0001000400046D3O009F00012O006E00106O0034001000014O0010000B000F001000046D3O004105012O0037000F00063O0020730010000D000A0020730011000D00092O00720011000B00112O0010000F0010001100046D3O00410501002639000E00E20001000F00046D3O00E20001002639000E00BB0001001000046D3O00BB0001000E23001100B70001000E00046D3O00B70001002073000F000D00092O00720010000B000F2O0037001100054O00360012000B3O0020110013000F00012O0036001400064O005B001100144O004E00103O000100046D3O00410501002073000F000D00092O0072000F000B000F2O0028000F00023O00046D3O00410501002639000E00C40001001200046D3O00C40001002073000F000D00090020730010000D000A2O00720010000B00100020730011000D00082O00490010001000112O0010000B000F001000046D3O00410501002640000E00E00001001300046D3O00E00001002073000F000D00090020730010000D00080020110011000F00092O000800126O00720013000B000F0020110014000F00012O00720014000B00142O00720015000B00112O005B001300154O000900123O0001001259001300014O0036001400103O001259001500013O000455001300D800012O00480017001100162O00720018001200162O0010000B00170018000402001300D40001002073001300120001000652001300DE00013O00046D3O00DE00012O0010000B001100130020730005000D000A00046D3O0041050100201100050005000100046D3O004105010020730005000D000A00046D3O00410501002639000E001F2O01001400046D3O001F2O01002639000E00EF0001001500046D3O00EF0001002073000F000D00090020730010000D000A2O00720010000B00100020110011000F00012O0010000B001100100020730011000D00082O00720011001000112O0010000B000F001100046D3O00410501002640000E00142O01001600046D3O00142O01001259000F00044O001C001000123O002640000F003O01000400046D3O003O010020730010000D00092O000800136O00720014000B00102O0037001500054O00360016000B3O0020110017001000010020730018000D000A2O005B001500184O003100146O000900133O00012O0036001100133O001259000F00013O002640000F00F30001000100046D3O00F30001001259001200044O0036001300103O0020730014000D0008001259001500013O000455001300112O01001259001700043O002640001700092O01000400046D3O00092O010020110012001200012O00720018001100122O0010000B0016001800046D3O00102O0100046D3O00092O01000402001300082O0100046D3O0041050100046D3O00F3000100046D3O00410501001259000F00044O001C001000103O002640000F00162O01000400046D3O00162O010020730010000D00092O00720011000B00102O00570011000100022O0010000B0010001100046D3O0041050100046D3O00162O0100046D3O00410501002639000E00312O01001700046D3O00312O01001259000F00044O001C001000103O002640000F00232O01000400046D3O00232O010020730010000D00092O00720011000B00102O0037001200054O00360013000B3O0020110014001000012O0036001500064O005B001200154O004D00113O00022O0010000B0010001100046D3O0041050100046D3O00232O0100046D3O00410501002640000E00372O01001800046D3O00372O01002073000F000D00092O000800106O0010000B000F001000046D3O00410501002073000F000D00092O00720010000B000F0020110011000F00012O00720011000B00112O000E00100002000100046D3O00410501002639000E00180201001900046D3O00180201002639000E00812O01001A00046D3O00812O01002639000E00682O01001B00046D3O00682O01002640000E00632O01001C00046D3O00632O01002073000F000D00092O000800105O001259001100014O00690012000A3O001259001300013O000455001100622O01001259001500044O001C001600163O0026400015004D2O01000400046D3O004D2O012O00720016000A0014001259001700044O0069001800163O001259001900013O0004550017005F2O012O0072001B0016001A002073001C001B0001002073001D001B000900062F001C005E2O01000B00046D3O005E2O01000638000F005E2O01001D00046D3O005E2O012O0072001E001C001D2O00100010001D001E00102A001B00010010000402001700542O0100046D3O00612O0100046D3O004D2O010004020011004B2O0100046D3O00410501002073000F000D00092O00720010000B000F2O00570010000100022O0010000B000F001000046D3O00410501002639000E006C2O01001D00046D3O006C2O010020730005000D000A00046D3O00410501002640000E00752O01001E00046D3O00752O01002073000F000D00092O0072000F000B000F0020730010000D000A0020730011000D00082O00720011000B00112O0010000F0010001100046D3O00410501002073000F000D00092O00720010000B000F0020110011000F00012O0036001200063O001259001300013O000455001100802O012O0037001500074O0036001600104O00720017000B00142O000A0015001700010004020011007B2O0100046D3O00410501002639000E00D22O01001F00046D3O00D22O01002639000E00932O01002000046D3O00932O01001259000F00044O001C001000103O002640000F00872O01000400046D3O00872O010020730010000D00092O0037001100054O00360012000B4O0036001300104O0036001400064O0066001100144O003D00115O00046D3O0041050100046D3O00872O0100046D3O00410501000E23002100D02O01000E00046D3O00D02O01002073000F000D000A2O0072000F0002000F2O001C001000104O000800116O0037001200084O000800136O000800143O000200066C00153O000100012O00133O00113O00102A00140022001500066C00150001000100012O00133O00113O00102A0014002300152O00600012001400022O0036001000123O001259001200013O0020730013000D0008001259001400013O000455001200C72O01001259001600044O001C001700173O002640001600C02O01000100046D3O00C02O01002073001800170001002640001800B62O01002400046D3O00B62O0100204A0018001500012O0008001900024O0036001A000B3O002073001B0017000A2O002E0019000200012O001000110018001900046D3O00BC2O0100204A0018001500012O0008001900024O0037001A00063O002073001B0017000A2O002E0019000200012O00100011001800192O00690018000A3O0020110018001800012O0010000A0018001100046D3O00C62O01000E7C000400AA2O01001600046D3O00AA2O010020110005000500012O0072001700010005001259001600013O00046D3O00AA2O01000402001200A82O010020730012000D00092O0037001300094O00360014000F4O0036001500104O00370016000A4O00600013001600022O0010000B001200132O001F000F5O00046D3O004105012O00053O00013O00046D3O00410501002639000E00060201002500046D3O00060201002073000F000D000A2O0072000F0002000F2O001C001000104O000800116O0037001200084O000800136O000800143O000200066C00150002000100012O00133O00113O00102A00140022001500066C00150003000100012O00133O00113O00102A0014002300152O00600012001400022O0036001000123O001259001200013O0020730013000D0008001259001400013O000455001200FD2O010020110005000500012O0072001600010005002073001700160001002640001700F32O01002400046D3O00F32O0100204A0017001500012O0008001800024O00360019000B3O002073001A0016000A2O002E0018000200012O001000110017001800046D3O00F92O0100204A0017001500012O0008001800024O0037001900063O002073001A0016000A2O002E0018000200012O00100011001700182O00690017000A3O0020110017001700012O0010000A00170011000402001200E72O010020730012000D00092O0037001300094O00360014000F4O0036001500104O00370016000A4O00600013001600022O0010000B001200132O001F000F5O00046D3O00410501000E23002600110201000E00046D3O00110201002073000F000D00092O0072000F000B000F0020730010000D000800062F000F000F0201001000046D3O000F020100201100050005000100046D3O004105010020730005000D000A00046D3O00410501002073000F000D00090020730010000D000A2O00720010000B00100020730011000D00082O004C0010001000112O0010000B000F001000046D3O00410501002639000E00470201002700046D3O00470201002639000E002B0201002800046D3O002B0201000E23002900250201000E00046D3O00250201002073000F000D00090020730010000D000A2O00720010000B00100020730011000D00082O004C0010001000112O0010000B000F001000046D3O00410501002073000F000D00092O0037001000063O0020730011000D000A2O00720010001000112O0010000B000F001000046D3O00410501002639000E00340201002A00046D3O00340201002073000F000D00090020730010000D000A001259001100013O000455000F00330201002062000B0012002B000402000F0031020100046D3O00410501000E23002C00400201000E00046D3O00400201002073000F000D00092O00720010000B000F2O0037001100054O00360012000B3O0020110013000F00012O0036001400064O005B001100144O004600106O003D00105O00046D3O00410501002073000F000D00090020730010000D000A001259001100013O000455000F00460201002062000B0012002B000402000F0044020100046D3O00410501002639000E007C0201002D00046D3O007C0201002639000E00530201002E00046D3O00530201002073000F000D00090020730010000D000A002640001000500201000400046D3O005002012O006E00106O0034001000014O0010000B000F001000046D3O00410501002640000E00640201002F00046D3O00640201001259000F00044O001C001000103O002640000F00570201000400046D3O005702010020730010000D00092O00720011000B00102O0037001200054O00360013000B3O0020110014001000010020730015000D000A2O005B001200154O004E00113O000100046D3O0041050100046D3O0057020100046D3O00410501002073000F000D00092O00720010000B000F0020110011000F00092O00720011000B0011000E23000400730201001100046D3O007302010020110012000F00012O00720012000B0012000615001200700201001000046D3O007002010020730005000D000A00046D3O004105010020110012000F000A2O0010000B0012001000046D3O004105010020110012000F00012O00720012000B0012000615001000790201001200046D3O007902010020730005000D000A00046D3O004105010020110012000F000A2O0010000B0012001000046D3O00410501002639000E00A50201003000046D3O00A50201002073000F000D00092O000800105O001259001100014O00690012000A3O001259001300013O000455001100A40201001259001500044O001C001600163O002640001500860201000400046D3O008602012O00720016000A0014001259001700044O0069001800163O001259001900013O000455001700A10201001259001B00044O001C001C001E3O002640001B00940201000400046D3O009402012O0072001C0016001A002073001D001C0001001259001B00013O002640001B008F0201000100046D3O008F0201002073001E001C000900062F001D00A00201000B00046D3O00A00201000638000F00A00201001E00046D3O00A002012O0072001F001D001E2O00100010001E001F00102A001C0001001000046D3O00A0020100046D3O008F02010004020017008D020100046D3O00A3020100046D3O0086020100040200110084020100046D3O00410501002640000E00BF0201003100046D3O00BF0201002073000F000D00092O00720010000B000F0020110011000F00092O00720011000B0011000E23000400B60201001100046D3O00B602010020110012000F00012O00720012000B0012000615001200B30201001000046D3O00B302010020730005000D000A00046D3O004105010020110012000F000A2O0010000B0012001000046D3O004105010020110012000F00012O00720012000B0012000615001000BC0201001200046D3O00BC02010020730005000D000A00046D3O004105010020110012000F000A2O0010000B0012001000046D3O00410501001259000F00044O001C001000103O002640000F00C10201000400046D3O00C102010020730010000D00092O00720011000B00100020110012001000012O00720012000B00122O00200011000200022O0010000B0010001100046D3O0041050100046D3O00C1020100046D3O00410501002639000E00100401003200046D3O00100401002639000E00750301003300046D3O00750301002639000E002O0301003400046D3O002O0301002639000E00E50201003500046D3O00E50201000E23003600DE0201000E00046D3O00DE0201002073000F000D00092O0037001000054O00360011000B4O00360012000F4O0036001300064O0066001000134O003D00105O00046D3O00410501002073000F000D00090020730010000D000A2O00720010000B00100020730011000D00082O00720010001000112O0010000B000F001000046D3O00410501002639000E00F10201003700046D3O00F10201002073000F000D00092O00720010000B000F2O0037001100054O00360012000B3O0020110013000F00010020730014000D000A2O005B001100144O004D00103O00022O0010000B000F001000046D3O00410501000E23003800FD0201000E00046D3O00FD0201002073000F000D00092O00720010000B000F2O0037001100054O00360012000B3O0020110013000F00012O0036001400064O005B001100144O004D00103O00022O0010000B000F001000046D3O00410501002073000F000D00092O00720010000B000F0020110011000F00012O00720011000B00112O000E00100002000100046D3O00410501002639000E00500301003900046D3O00500301002639000E001D0301003A00046D3O001D0301002073000F000D00092O0036001000044O00720011000B000F2O0037001200054O00360013000B3O0020110014000F00010020730015000D000A2O005B001200154O003100116O002500103O00112O004800120011000F00204A000600120001001259001200044O00360013000F4O0036001400063O001259001500013O0004550013001C03010020110012001200012O00720017001000122O0010000B0016001700040200130018030100046D3O00410501002640000E00270301003B00046D3O00270301002073000F000D00092O0072000F000B000F000652000F002503013O00046D3O0025030100201100050005000100046D3O004105010020730005000D000A00046D3O00410501001259000F00044O001C001000123O000E7C0004002F0301000F00046D3O002F03010020730010000D00090020110013001000092O00720011000B0013001259000F00013O000E7C000100350301000F00046D3O003503012O00720013000B00102O00480012001300112O0010000B00100012001259000F00093O000E7C000900290301000F00046D3O00290301000E23000400460301001100046D3O004603010020110013001000012O00720013000B0013000638001200410501001300046D3O00410501001259001300043O0026400013003E0301000400046D3O003E03010020730005000D000A00201100140010000A2O0010000B0014001200046D3O0041050100046D3O003E030100046D3O004105010020110013001000012O00720013000B0013000638001300410501001200046D3O004105010020730005000D000A00201100130010000A2O0010000B0013001200046D3O0041050100046D3O0029030100046D3O00410501002639000E00680301003C00046D3O00680301002073000F000D00092O0036001000044O00720011000B000F2O0037001200054O00360013000B3O0020110014000F00010020730015000D000A2O005B001200154O003100116O002500103O00112O004800120011000F00204A000600120001001259001200044O00360013000F4O0036001400063O001259001500013O0004550013006703010020110012001200012O00720017001000122O0010000B0016001700040200130063030100046D3O00410501002640000E006F0301002400046D3O006F0301002073000F000D00090020730010000D000A2O00720010000B00102O0010000B000F001000046D3O00410501002073000F000D00090020730010000D000A2O00720010000B00102O0069001000104O0010000B000F001000046D3O00410501002639000E00BA0301003D00046D3O00BA0301002639000E00850301003E00046D3O00850301002640000E007F0301003F00046D3O007F0301002073000F000D00092O0072000F000B000F2O0028000F00023O00046D3O004105012O0037000F00063O0020730010000D000A0020730011000D00092O00720011000B00112O0010000F0010001100046D3O00410501002639000E008D0301004000046D3O008D0301002073000F000D00092O0037001000063O0020730011000D000A2O00720010001000112O0010000B000F001000046D3O00410501002640000E00970301004100046D3O00970301002073000F000D00090020730010000D000A2O00720010000B00100020730011000D00082O00720011000B00112O00480010001000112O0010000B000F001000046D3O00410501001259000F00044O001C001000123O002640000F00AA0301000100046D3O00AA0301001259001200044O0036001300103O0020730014000D0008001259001500013O000455001300A90301001259001700043O002640001700A10301000400046D3O00A103010020110012001200012O00720018001100122O0010000B0016001800046D3O00A8030100046D3O00A10301000402001300A0030100046D3O00410501002640000F00990301000400046D3O009903010020730010000D00092O000800136O00720014000B00102O0037001500054O00360016000B3O0020110017001000010020730018000D000A2O005B001500184O003100146O000900133O00012O0036001100133O001259000F00013O00046D3O0099030100046D3O00410501002639000E00D70301004200046D3O00D70301002639000E00C50301004300046D3O00C50301002073000F000D00090020730010000D000A2O00720010000B00100020730011000D00082O00490010001000112O0010000B000F001000046D3O00410501000E23004400D10301000E00046D3O00D10301002073000F000D00092O00720010000B000F2O0037001100054O00360012000B3O0020110013000F00012O0036001400064O005B001100144O004600106O003D00105O00046D3O00410501002073000F000D00092O00370010000A3O0020730011000D000A2O00720010001000112O0010000B000F001000046D3O00410501002639000E00F80301004500046D3O00F80301002073000F000D00090020730010000D00080020110011000F00092O000800126O00720013000B000F0020110014000F00012O00720014000B00142O00720015000B00112O005B001300154O000900123O0001001259001300014O0036001400103O001259001500013O000455001300EB03012O00480017001100162O00720018001200162O0010000B00170018000402001300E70301002073001300120001000652001300F603013O00046D3O00F60301001259001400043O002640001400EF0301000400046D3O00EF03012O0010000B001100130020730005000D000A00046D3O0041050100046D3O00EF030100046D3O0041050100201100050005000100046D3O00410501000E23004600060401000E00046D3O00060401002073000F000D00092O00480010000F000C00204A0006001000012O00360010000F4O0036001100063O001259001200013O0004550010000504012O004900140013000F2O00720014000700142O0010000B0013001400040200100001040100046D3O00410501002073000F000D00092O0072000F000B000F0020730010000D00082O00720010000B001000062F000F000E0401001000046D3O000E040100201100050005000100046D3O004105010020730005000D000A00046D3O00410501002639000E00A40401004700046D3O00A40401002639000E005C0401004800046D3O005C0401002639000E00360401004900046D3O00360401002640000E001D0401004A00046D3O001D0401002073000F000D00090020730010000D000A2O00720010000B00102O0010000B000F001000046D3O00410501002073000F000D00092O000800106O00720011000B000F2O0037001200054O00360013000B3O0020110014000F00012O0036001500064O005B001200154O003100116O000900103O0001001259001100044O00360012000F3O0020730013000D0008001259001400013O000455001200350401001259001600043O0026400016002D0401000400046D3O002D04010020110011001100012O00720017001000112O0010000B0015001700046D3O0034040100046D3O002D04010004020012002C040100046D3O00410501002639000E00440401004B00046D3O00440401002073000F000D00092O00480010000F000C00204A0006001000012O00360010000F4O0036001100063O001259001200013O0004550010004304012O004900140013000F2O00720014000700142O0010000B001300140004020010003F040100046D3O00410501002640000E004D0401004C00046D3O004D0401002073000F000D00092O0072000F000B000F0020730010000D000A0020730011000D00082O00720011000B00112O0010000F0010001100046D3O00410501001259000F00044O001C001000103O002640000F004F0401000400046D3O004F04010020730010000D00092O0037001100054O00360012000B4O0036001300103O0020730014000D000A2O00480014001000142O0066001100144O003D00115O00046D3O0041050100046D3O004F040100046D3O00410501002639000E008A0401004D00046D3O008A0401002639000E00690401004E00046D3O00690401002073000F000D00092O00720010000B000F2O0037001100054O00360012000B3O0020110013000F00010020730014000D000A2O005B001100144O004E00103O000100046D3O00410501000E23004F00830401000E00046D3O00830401002073000F000D00092O0036001000044O00720011000B000F0020110012000F00012O00720012000B00122O0047001100124O002500103O00112O004800120011000F00204A000600120001001259001200044O00360013000F4O0036001400063O001259001500013O000455001300820401001259001700043O0026400017007A0401000400046D3O007A04010020110012001200012O00720018001000122O0010000B0016001800046D3O0081040100046D3O007A040100040200130079040100046D3O00410501002073000F000D00090020730010000D000A2O00720010000B00100020730011000D00082O00720010001000112O0010000B000F001000046D3O00410501002639000E008E0401005000046D3O008E04012O00053O00013O00046D3O00410501002640000E009A0401005100046D3O009A0401002073000F000D00092O0072000F000B000F0020730010000D00082O00720010000B001000062F000F00980401001000046D3O0098040100201100050005000100046D3O004105010020730005000D000A00046D3O00410501002073000F000D00092O00720010000B000F2O0037001100054O00360012000B3O0020110013000F00010020730014000D000A2O005B001100144O004D00103O00022O0010000B000F001000046D3O00410501002639000E00DC0401005200046D3O00DC0401002639000E00C20401005300046D3O00C20401002640000E00B30401005400046D3O00B30401002073000F000D00092O0072000F000B000F0020730010000D000800062F000F00B10401001000046D3O00B1040100201100050005000100046D3O004105010020730005000D000A00046D3O00410501001259000F00044O001C001000103O002640000F00B50401000400046D3O00B504010020730010000D00092O00720011000B00102O0037001200054O00360013000B3O0020110014001000012O0036001500064O005B001200154O004E00113O000100046D3O0041050100046D3O00B5040100046D3O00410501002639000E00CD0401005500046D3O00CD0401002073000F000D00090020730010000D00082O00720010000B001000062F000F00CB0401001000046D3O00CB040100201100050005000100046D3O004105010020730005000D000A00046D3O00410501000E23005600D60401000E00046D3O00D60401002073000F000D00092O00720010000B000F0020110011000F00012O00720011000B00112O00200010000200022O0010000B000F001000046D3O00410501002073000F000D00092O0072000F000B000F0020730010000D000A0020730011000D00082O0010000F0010001100046D3O00410501002639000E001A0501005700046D3O001A0501002639000E00090501005800046D3O00090501001259000F00044O001C001000123O002640000F00E80401000400046D3O00E804010020730010000D00090020110013001000092O00720011000B0013001259000F00013O002640000F00010501000900046D3O00010501000E23000400F90401001100046D3O00F904010020110013001000012O00720013000B0013000638001200410501001300046D3O00410501001259001300043O002640001300F10401000400046D3O00F104010020730005000D000A00201100140010000A2O0010000B0014001200046D3O0041050100046D3O00F1040100046D3O004105010020110013001000012O00720013000B0013000638001300410501001200046D3O004105010020730005000D000A00201100130010000A2O0010000B0013001200046D3O00410501002640000F00E20401000100046D3O00E204012O00720013000B00102O00480012001300112O0010000B00100012001259000F00093O00046D3O00E2040100046D3O00410501000E23005900140501000E00046D3O00140501002073000F000D00090020730010000D00082O00720010000B001000062F000F00120501001000046D3O0012050100201100050005000100046D3O004105010020730005000D000A00046D3O00410501002073000F000D00090020730010000D000A2O00720010000B00102O0069001000104O0010000B000F001000046D3O00410501002639000E002E0501005A00046D3O002E0501001259000F00044O001C001000113O002640000F00240501000400046D3O002405010020730010000D00090020730012000D000A2O00720011000B0012001259000F00013O000E7C0001001E0501000F00046D3O001E05010020110012001000012O0010000B001200110020730012000D00082O00720012001100122O0010000B0010001200046D3O0041050100046D3O001E050100046D3O00410501002640000E00360501005B00046D3O00360501002073000F000D00092O00370010000A3O0020730011000D000A2O00720010001000112O0010000B000F001000046D3O00410501002073000F000D00092O00720010000B000F0020110011000F00012O0036001200063O001259001300013O0004550011004105012O0037001500074O0036001600104O00720017000B00142O000A0015001700010004020011003C050100201100050005000100046D3O002300012O00053O00013O00043O00033O00028O00026O00F03F027O0040020C3O001259000200014O001C000300033O002640000200020001000100046D3O000200012O003700046O00720003000400010020730004000300020020730005000300032O00720004000400052O0028000400023O00046D3O000200012O00053O00017O00033O00028O00026O00F03F027O0040030C3O001259000300014O001C000400043O002640000300020001000100046D3O000200012O003700056O00720004000500010020730005000400020020730006000400032O001000050006000200046D3O000B000100046D3O000200012O00053O00017O00023O00026O00F03F027O004002074O003700026O00720002000200010020730003000200010020730004000200022O00720003000300042O0028000300024O00053O00017O00023O00026O00F03F027O004003064O003700036O00720003000300010020730004000300010020730005000300022O00100004000500022O00053O00017O00", GetFEnv(), ...);