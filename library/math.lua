print("[LUALIB] load math module ...")

function math.clamp(val, lower, upper)
    if(lower > upper) then lower, upper = upper, lower end
    return math.max(lower, math.min(upper, val))
end

function math.between(val, lower, upper)
    if(lower > upper) then lower, upper = upper, lower end
    return (val >= lower and val <= upper)
end

function math.lerp(a, b, t)
    return a + (b - a) * t
end

function math.sign(x)
    if x<0 then
        return -1
    elseif x>0 then
        return 1
    else
        return 0
    end
end

function math.map(value, inMin, inMax, outMin, outMax)
    return outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin)
end

function math.rnd(lower, greater)
    return lower + math.random()  * (greater - lower);
end

function math.rndVec3(l, g)
    return sq.math.vec3.new(math.rnd(l,g), math.rnd(l,g), math.rnd(l,g))
end

--function math.rndVec3(l, g)
--    return {math.rnd(l,g), math.rnd(l,g), math.rnd(l,g)}
--end

function math.rndVec4(l, g)
    return {math.rnd(l,g), math.rnd(l,g), math.rnd(l,g), math.rnd(l,g)}
end

function math.square(x)
    return x*x
end

--- @brief changes vector's length (direction stays unchanged) to be less or equal than maxLength
function math.clampVectorLength(v, maxLength)
    local length = v.length()
    if length > maxLength then
        return v * (maxLength / length)
    end
    return v
end

function math.signedAngleBetweenVec3InXZ(v1, v2)
    local vec1Norm = sq.math.normalize(v1)
    local vec2Norm = sq.math.normalize(v2)

    local angle = math.atan( vec1Norm.z, vec1Norm.x ) - math.atan( vec2Norm.z, vec2Norm.x )

    while(angle>math.pi) do
        angle = angle - math.pi*2
    end
    while(angle<-math.pi) do
        angle = angle + math.pi*2
    end

    return angle
end

function math.signedAngleBetweenVec3InXY(v1, v2)
    local vec1Norm = sq.math.normalize(v1)
    local vec2Norm = sq.math.normalize(v2)

    local angle = math.atan( vec1Norm.y, vec1Norm.x ) - math.atan( vec2Norm.y, vec2Norm.x )

    while(angle>math.pi) do
        angle = angle - math.pi*2
    end
    while(angle<-math.pi) do
        angle = angle + math.pi*2
    end

    return angle
end

return math
