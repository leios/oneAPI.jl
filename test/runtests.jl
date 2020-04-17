using Test
using oneL0


# drivers

drvs = drivers()
@assert !isempty(drvs)
drv = first(drvs)

api_version(drv)


# devices

devs = devices(drv)
@assert !isempty(devs)
dev = first(devs)

properties(dev)
compute_properties(dev)
kernel_properties(dev)
memory_properties(dev)
memory_access_properties(dev)
cache_properties(dev)
image_properties(dev)
p2p_properties(dev, dev)


# commands

queue = ZeCommandQueue(dev)

list = ZeCommandList(dev)
append_barrier!(list)   # can't execute empty list
close(list)
execute!(queue, [list])
synchronize(queue)
reset(list)


# events

ZeEventPool(drv, 1)
ZeEventPool(drv, 1, dev)

pool = ZeEventPool(drv, 1)

event = pool[1]
@test !query(event)

signal(event)
append_signal!(list, event)
@test query(event)

wait(event, 1)
append_wait!(list, event)

reset(event)
append_reset!(list, event)

timed_pool = ZeEventPool(drv, 1; flags=oneL0.ZE_EVENT_POOL_FLAG_TIMESTAMP)
timed_event = timed_pool[1]
@test global_time(timed_event).start == nothing
@test context_time(timed_event).start == nothing
signal(timed_event)
@test global_time(timed_event).start != nothing
@test context_time(timed_event).start != nothing


# barriers

append_barrier!(list)
append_barrier!(list, event)
append_barrier!(list, event, event)

#device_barrier(dev)    # unsupported
