from memory import UnsafePointer, stack_allocation
from gpu import thread_idx, block_idx, block_dim, barrier
from gpu.host import DeviceContext
from gpu.memory import AddressSpace
from sys import size_of
from testing import assert_equal

# ANCHOR: add_10_shared
comptime TPB = 4
comptime SIZE = 8
comptime BLOCKS_PER_GRID = (2, 1)
comptime THREADS_PER_BLOCK = (TPB, 1)
comptime dtype = DType.float32


fn add_10_shared(
    output: UnsafePointer[Scalar[dtype], MutAnyOrigin],
    a: UnsafePointer[Scalar[dtype], MutAnyOrigin],
    size: UInt,
):
    shared = stack_allocation[
        TPB,
        Scalar[dtype],
        address_space = AddressSpace.SHARED,
    ]()
    local_i = thread_idx.x  # fill in
    global_i = block_idx.x * block_dim.x + thread_idx.x  # fill in
    # local data into shared memory
    if global_i < size:
        shared[local_i] = a[global_i]
        # WHY?

    # wait for all threads to complete
    # works within a thread block
    barrier()

    # FILL ME IN (roughly 2 lines)
    if global_i < size:
        output[global_i] = shared[local_i] + 10


# ANCHOR_END: add_10_shared


def main():
    with DeviceContext() as ctx:
        out = ctx.enqueue_create_buffer[dtype](SIZE)
        out.enqueue_fill(0)
        a = ctx.enqueue_create_buffer[dtype](SIZE)
        a.enqueue_fill(1)

        expected = ctx.enqueue_create_host_buffer[dtype](SIZE)
        # expected.enqueue_fill(11)
        with a.map_to_host() as a_host:
            for j in range(SIZE):
                for i in range(SIZE):
                    k = j * SIZE + i
                    a_host[k] = k
                    expected[k] = k + 10

        ctx.enqueue_function_checked[add_10_shared, add_10_shared](
            out,
            a,
            UInt(SIZE),
            grid_dim=BLOCKS_PER_GRID,
            block_dim=THREADS_PER_BLOCK,
        )
        ctx.synchronize()

        with out.map_to_host() as out_host:
            print("out:", out_host)
            print("expected:", expected)
            for i in range(SIZE):
                assert_equal(out_host[i], expected[i])
