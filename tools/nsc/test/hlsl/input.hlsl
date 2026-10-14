#include <nbl/builtin/hlsl/emulated/int64_t.hlsl>

// Exercise the out-of-class unary-minus definition on the HLSL path too.
RWStructuredBuffer<uint32_t2> output : register(u0);

[numthreads(256,1,1)]
void main(uint3 id : SV_DispatchThreadID)
{
    nbl::hlsl::emulated_int64_t value = nbl::hlsl::emulated_int64_t::create(id.x, 0);
    output[id.x] = value.operator-().data;
}
