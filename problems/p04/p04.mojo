from memory import UnsafePointer
from gpu import thread_idx, block_dim, block_idx
from gpu.host import DeviceContext
from testing import assert_equal

# ANCHOR: add_10_2d
comptime SIZE = 2
comptime BLOCKS_PER_GRID = 1
comptime THREADS_PER_BLOCK = (3, 3)
comptime dtype = DType.float32


fn add_10_2d(
    output: UnsafePointer[Scalar[dtype], MutAnyOrigin],
    a: UnsafePointer[Scalar[dtype], MutAnyOrigin],
    size: UInt,
):
    i = thread_idx.y
    j = thread_idx.x
    # FILL ME IN (roughly 2 lines)
    # if i < size and j < size:
    # output[i * size + j] = a[i * size + j] + 10 + 2**j +
    output[i * size + j] = 2**j + 3**i


# ANCHOR_END: add_10_2d

# import sys


def main():
    with DeviceContext() as ctx:
        out = ctx.enqueue_create_buffer[dtype](SIZE * SIZE)
        out.enqueue_fill(0)
        expected = ctx.enqueue_create_host_buffer[dtype](SIZE * SIZE)
        expected.enqueue_fill(0)
        a = ctx.enqueue_create_buffer[dtype](SIZE * SIZE)
        a.enqueue_fill(0)
        with a.map_to_host() as a_host:
            # row-major
            for i in range(SIZE):
                for j in range(SIZE):
                    a_host[i * SIZE + j] = i * SIZE + j
                    expected[i * SIZE + j] = a_host[i * SIZE + j] + 10
            print(a_host)
            print(expected)
        # raise
        # assert False
        # 1 / 0
        # assert()
        # return
        # (THREADS_PER_BLOCK)
        ctx.enqueue_function_checked[add_10_2d, add_10_2d](
            out,
            a,
            UInt(SIZE),
            grid_dim=BLOCKS_PER_GRID,
            block_dim=THREADS_PER_BLOCK,
        )

        ctx.synchronize()

        def factorise(x: Float32):
            ith = 0
            for i in range(4):
                if x / (ith**i) % 1 == 0:
                    ith = i

            jth = 0
            for j in range(4):
                if x / (jth**j) % 1 == 0:
                    jth = j
            print("{}, {}", ith, jth)

        with out.map_to_host() as out_host:
            print("out:", out_host)
            print("expected:", expected)

            for i in range(SIZE):
                for j in range(SIZE):
                    factorise(out_host[i * SIZE + j])
            #         assert_equal(out_host[i * SIZE + j], expected[i * SIZE + j])
